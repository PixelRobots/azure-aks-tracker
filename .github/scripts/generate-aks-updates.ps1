#!/usr/bin/env pwsh
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# =========================
# ENHANCED CONFIG / ENV with multi-repository support
# =========================

# Repository configuration - easily extensible for more MS Docs sites
$Repositories = @(
  @{
    Owner = "MicrosoftDocs"
    Repo = "azure-aks-docs"
    PathFilter = "^articles/"  # Only files in articles/ folder
    DisplayName = "AKS"
    IconUrl = "https://learn.microsoft.com/en-gb/azure/media/index/kubernetes-services.svg"
    IconAlt = "Azure Kubernetes Service"
    DocsBaseUrl = "https://learn.microsoft.com/azure/aks/"
  },
  @{
    Owner = "MicrosoftDocs"
    Repo = "azure-management-docs"
    PathFilter = "^articles/container-registry/"  # Only ACR docs
    DisplayName = "ACR"
    IconUrl = "https://learn.microsoft.com/en-gb/azure/media/index/container-registry.svg"
    IconAlt = "Azure Container Registry"
    DocsBaseUrl = "https://learn.microsoft.com/azure/container-registry/"
  },
  @{
    Owner = "MicrosoftDocs"
    Repo = "azure-docs"
    PathFilter = "^articles/application-gateway/for-containers/"  # Only App Gateway for Containers docs
    DisplayName = "AGC"
    IconUrl = "https://courscape.com/wp-content/uploads/2024/01/agc-logo-1-1024x1024.png"
    IconAlt = "Application Gateway for Containers"
    DocsBaseUrl = "https://learn.microsoft.com/azure/application-gateway/for-containers/"
  }
)

$GitHubToken = $env:GITHUB_TOKEN
if (-not $GitHubToken) { Write-Error "GITHUB_TOKEN not set"; exit 1 }

# Prefer OpenAI if OpenAIKey exists, else AzureOpenAI if all vars exist, else disabled
$PreferProvider = if ($env:OpenAIKey) { 'OpenAI' } elseif ($env:AZURE_OPENAI_APIURI -and $env:AZURE_OPENAI_KEY -and $env:AZURE_OPENAI_API_VERSION -and $env:AZURE_OPENAI_DEPLOYMENT) { 'AzureOpenAI' } else { '' }

# Docs window: last 7 days from UTC midnight
$now = [DateTime]::UtcNow
$sinceMidnightUtc = (Get-Date -Date $now.ToString("yyyy-MM-dd") -AsUTC).AddDays(-7)
$SINCE_ISO = $sinceMidnightUtc.ToString("o")

# Releases source (GitHub Releases)
$ReleasesOwner = "Azure"
$ReleasesRepo = "AKS"
$ReleasesCount = 5

$ghHeaders = @{
  "Authorization" = "Bearer $GitHubToken"
  "Accept"        = "application/vnd.github+json"
  "User-Agent"    = "pixelrobots-aks-updates-pwsh"
}

# Run-mode flags (read early so they gate all downstream work)
# CVE_ONLY=true         - skip GitHub/docs/AI entirely, regenerate only the CVE section.
# CVE_REFRESH_VHD=true  - also fetch VHD node-image CVE data (26 OS image types).
$script:CveOnly       = ($env:CVE_ONLY       -eq 'true')
$script:RefreshVhdCve = ($env:CVE_REFRESH_VHD -eq 'true')

function Get-PullRequestFiles {
  param([int]$prNumber, [string]$Owner, [string]$Repo)
  $uri = "https://api.github.com/repos/$Owner/$Repo/pulls/$prNumber/files"
  try { 
    $response = Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
    return $response
  }
  catch { 
    Write-Warning "Failed to get files for PR #$prNumber in $Owner/$Repo`: $_"
    return @()
  }
}

function Get-CommitFiles {
  param([string]$sha, [string]$Owner, [string]$Repo)
  $uri = "https://api.github.com/repos/$Owner/$Repo/commits/$sha"
  try { 
    $response = Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
    return $response
  }
  catch { 
    Write-Warning "Failed to get commit details for $sha in $Owner/$Repo`: $_"
    return @{ files = @() }
  }
}

function Log($msg) { Write-Host "[$(Get-Date -Format HH:mm:ss)] $msg" }

# =========================
# ENHANCED FILTERING LOGIC
# =========================

# Expanded trivial patterns that should be skipped
$TrivialPatterns = @(
    # Author/metadata changes
    'ms\.author:\s*\w+',
    'author:\s*\w+',
    'ms\.date:\s*\d{2}\/\d{2}\/\d{4}',
    'ms\.topic:\s*\w+',
    'ms\.service:\s*\w+',
    'ms\.subservice:\s*\w+',
    'ms\.reviewer:\s*\w+',
    'ms\.custom:\s*\w+',
    
    # Navigation/callout additions that don't add content value
    'nextstepaction.*Deploy and Explore',
    'nextstepaction.*Learn more',
    'nextstepaction.*Get started',
    'callout.*Deploy and Explore',
    
    # Pure formatting/whitespace
    '^\+\s*$',
    '^\-\s*$',
    '^\+\s+\[.*\]\(.*\)\s*$',  # Just link changes
    '^\-\s+\[.*\]\(.*\)\s*$',
    
    # TOC/navigation only changes
    '^\+.*\[toc\]',
    '^\-.*\[toc\]',
    
    # Minor URL/link updates without content change
    '^\+.*https?://.*$',
    '^\-.*https?://.*$'
)

function Is-TrivialChange {
    param([string]$PatchSample, [string[]]$Subjects, [int]$TotalLines)
    
    # Only filter the most absolutely obvious trivial cases
    # Be extremely conservative - when in doubt, don't filter
    
    # Only filter if exactly 1 line AND it's just whitespace or comment
    if ($TotalLines -eq 1 -and $PatchSample -match '^\s*[\+\-]\s*$') { 
        return $true 
    }
    
    # Only filter pure ms.author changes with no other content
    if ($TotalLines -le 2 -and 
        $PatchSample -match 'ms\.author' -and 
        ($PatchSample -split "`n" | Where-Object { $_ -match '^[\+\-]' -and $_ -notmatch 'ms\.author|^\s*[\+\-]\s*$' }).Count -eq 0) {
        return $true
    }
    
    # Everything else goes to AI - be very permissive
    return $false
}

function Should-ForceKeepModified {
  param([int]$Adds, [int]$Dels, $Signals, [string]$PatchSample, [string[]]$Subjects)

  # First check if it's one of the very basic trivial cases
  $totalLines = $Adds + $Dels
  if (Is-TrivialChange -PatchSample $PatchSample -Subjects $Subjects -TotalLines $totalLines) {
    return $false
  }

  # Otherwise, let AI decide - be very permissive here
  # Only filter out completely empty changes
  if ($totalLines -eq 0) {
    return $false
  }
  
  # Everything else goes to AI for intelligent evaluation
  return $true
}

function Get-MeaningfulSignals {
  param([string]$PatchSample)

  if (-not $PatchSample) {
    return [pscustomobject]@{
      hasHeading     = $false
      hasCodeFence   = $false
      hasCli         = $false
      hasYamlKeys    = $false
      hasYamlColon   = $false
      hasAnnoKeys    = $false
      hasSecurityCue = $false
      flags          = @()
      keys           = @()
      annos          = @()
      cliExamples    = @()
      headings       = @()
    }
  }

  $lines = $PatchSample -split "`n"

  # Only count headings that are actual content, not navigation
  $headings = $lines | Where-Object { 
    $_ -match '^\+\s*#{2,}\s+' -and
    $_ -notmatch '(?i)(next steps|deploy and explore|learn more|get started)'
  } | ForEach-Object { ($_ -replace '^\+\s*#+\s+', '').Trim() } | Select-Object -Unique
  
  $codeFence = $lines | Where-Object { $_ -match '^\+\s*```' }
  $cli = $lines | Where-Object { $_ -match '^\+\s*(kubectl|helm|az)\b' } | ForEach-Object { $_ -replace '^\+\s*', '' }
  $flags = ($lines | ForEach-Object { [regex]::Matches($_, '--[a-zA-Z0-9\-]+') } | ForEach-Object { $_.Value }) | Select-Object -Unique
  $keys = ($lines | ForEach-Object { [regex]::Matches($_, '([A-Za-z0-9_.-]+)=("[^"]+"|''[^'']+''|[^ \t]+)') } | ForEach-Object { $_.Groups[1].Value }) | Select-Object -Unique
  $yamlColonKeys = $lines | Where-Object { $_ -match '^\+\s*[A-Za-z0-9_.-]+\s*:\s' }
  $annos = ($lines | ForEach-Object {
      [regex]::Matches($_, '(networking\.fleet\.azure\.com|service\.beta\.kubernetes\.io|service\.azure\.kubernetes\.io|service\.kubernetes\.io)[^ \t"]*')
    } | ForEach-Object { $_.Value }) | Select-Object -Unique

  $securityCue = $lines -match '(?i)\b(key\s*vault|secret|rotation|managed identity|entra|rbac|deny rule|nsg|tls|certificate)\b'

  [pscustomobject]@{
    hasHeading     = ($headings.Count -gt 0)
    hasCodeFence   = ($codeFence.Count -gt 0)
    hasCli         = ($cli.Count -gt 0)
    hasYamlKeys    = ($keys.Count -gt 0)
    hasYamlColon   = ($yamlColonKeys.Count -gt 0)
    hasAnnoKeys    = ($annos.Count -gt 0)
    hasSecurityCue = ($securityCue.Count -gt 0)
    flags          = $flags
    keys           = $keys
    annos          = $annos
    cliExamples    = $cli | Select-Object -First 3
    headings       = $headings | Select-Object -First 3
  }
}

function Get-ProductIconMeta([string]$FilePath, [string]$RepoName) {
  # Check file path first to distinguish between products in the same repo
  if ($FilePath -match '/kubernetes-fleet/' -or $FilePath -match 'fleet') {
    return @{
      url   = 'https://learn.microsoft.com/en-gb/azure/media/index/kubernetes-fleet-manager.svg'
      alt   = 'Kubernetes Fleet Manager'
      label = 'Fleet'
    }
  }
  elseif ($FilePath -match 'container-registry') {
    return @{
      url   = 'https://learn.microsoft.com/en-gb/azure/media/index/container-registry.svg'
      alt   = 'Azure Container Registry'
      label = 'ACR'
    }
  }
  elseif ($FilePath -match 'application-gateway/for-containers') {
    return @{
      url   = 'https://courscape.com/wp-content/uploads/2024/01/agc-logo-1-1024x1024.png'
      alt   = 'Application Gateway for Containers'
      label = 'AGC'
    }
  }
  
  # Then check repository configuration for default product
  $repoConfig = $Repositories | Where-Object { $_.Repo -eq $RepoName } | Select-Object -First 1
  
  if ($repoConfig) {
    return @{
      url   = $repoConfig.IconUrl
      alt   = $repoConfig.IconAlt
      label = $repoConfig.DisplayName
    }
  }
  
  # Final fallback
  return @{
    url   = 'https://learn.microsoft.com/en-gb/azure/media/index/kubernetes-services.svg'
    alt   = 'Azure Kubernetes Service'
    label = 'AKS'
  }
}

function Get-GitHubContentBase64([string]$path, [string]$Owner, [string]$Repo, [string]$ref = "main") {
  $uri = "https://api.github.com/repos/$Owner/$Repo/contents/$([uri]::EscapeDataString($path))?ref=$([uri]::EscapeDataString($ref))"
  try {
    $resp = Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
    if ($resp.content) { return [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($resp.content)) }
  }
  catch { }
  return $null
}

function Parse-YamlFrontMatter([string]$md) {
  # returns @{ title=""; description="" } if front matter exists, else empty values
  $o = @{ title = ""; description = "" }
  if (-not $md) { return $o }
  $m = [regex]::Match($md, '^(?:\uFEFF)?---\s*\r?\n([\s\S]*?)\r?\n---\s*\r?$', 'Multiline')
  if (-not $m.Success) { return $o }
  $yaml = $m.Groups[1].Value
  $title = [regex]::Match($yaml, '^\s*title\s*:\s*(.+)$', 'Multiline').Groups[1].Value.Trim()
  $desc = [regex]::Match($yaml, '^\s*description\s*:\s*(.+)$', 'Multiline').Groups[1].Value.Trim()
  if ($title) { $o.title = $title.Trim('"').Trim("'") }
  if ($desc) { $o.description = $desc.Trim('"').Trim("'") }
  return $o
}

function Get-MarkdownLead([string]$md) {
  if (-not $md) { return "" }
  # strip front matter
  $md = [regex]::Replace($md, '^(?:\uFEFF)?---\s*\r?\n[\s\S]*?\r?\n---\s*\r?\n?', '', 'Multiline')
  # first H1
  $h1 = [regex]::Match($md, '^\s*#\s+(.+)$', 'Multiline').Groups[1].Value.Trim()
  # first non-empty paragraph after H1 (skip images, headings, lists, blockquotes)
  $parts = $md -split "\r?\n\r?\n"
  $lead = ""
  $seenH1 = $false
  foreach ($p in $parts) {
    $t = $p.Trim()
    if (-not $t) { continue }
    if (-not $seenH1) {
      if ($t -match '^\s*#\s+') { $seenH1 = $true; continue }
      else { continue }
    }
    if ($t -match '^\s*[>#+\-*]') { continue }
    if ($t -match '!\[.*\]\(.*\)') { continue }
    $lead = $t
    break
  }
  if (-not $lead) {
    # fallback: first non-empty line
    $lead = ($md -split "\r?\n" | Where-Object { $_.Trim() } | Select-Object -First 1)
  }
  # clean markdown artifacts
  $lead = Convert-MarkdownToPlain $lead
  if ($h1 -and $lead) { return "$h1 — $lead" }
  if ($lead) { return $lead }
  if ($h1) { return $h1 }
  return ""
}

function Summarize-NewMarkdown([string]$path, [string]$Owner, [string]$Repo) {
  $raw = Get-GitHubContentBase64 -path $path -Owner $Owner -Repo $Repo
  if (-not $raw) { return "New page added." }
  $fm = Parse-YamlFrontMatter $raw
  if ($fm.description) { return Truncate $fm.description 280 }
  $lead = Get-MarkdownLead $raw
  if ($lead) { return Truncate $lead 280 }
  return "New page added."
}

function Escape-Html([string]$s) {
  if ($null -eq $s) { return "" }
  $s.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('"', '&quot;')
}
function ShortTitle([string]$path) { ($path -split '/')[ -1 ] }
function Get-LiveDocsUrl([string]$FilePath, [string]$RepoName, [string]$Owner, [string]$Repo) {
  if ($FilePath -match '^articles/(.+?)\.md$') {
    $p = $Matches[1] -replace '\\', '/'
    
    # Different URL patterns for different repositories
    if ($RepoName -eq 'azure-management-docs' -and $p -match '^container-registry/(.+)') {
      return "https://learn.microsoft.com/azure/container-registry/$($Matches[1])"
    }
    elseif ($p -match '^aks/(.+)') {
      return "https://learn.microsoft.com/azure/aks/$($Matches[1])"
    }
    elseif ($p -match '^kubernetes-fleet/(.+)') {
      return "https://learn.microsoft.com/azure/kubernetes-fleet/$($Matches[1])"
    }
    else {
      # Generic fallback
      if ($p -notmatch '^azure/') { $p = "azure/$p" }
      return "https://learn.microsoft.com/$p"
    }
  }
  return "https://github.com/$Owner/$Repo/blob/main/$FilePath"
}
function Truncate([string]$text, [int]$max = 400) {
  if (-not $text) { return "" }
  $t = $text.Trim()
  if ($t.Length -le $max) { return $t }
  return $t.Substring(0, $max).TrimEnd() + "…"
}
function Convert-MarkdownToPlain([string]$md) {
  if (-not $md) { return "" }
  $t = $md
  $t = [regex]::Replace($t, '```[\s\S]*?```', '', 'Singleline')
  $t = [regex]::Replace($t, '!\[([^\]]*)\]\([^)]+\)', '$1')
  $t = [regex]::Replace($t, '\[([^\]]+)\]\([^)]+\)', '$1')
  $t = $t -replace '(^|\n)#{1,6}\s*', '$1'
  $t = $t -replace '(\*\*|__)(.*?)\1', '$2'
  $t = $t -replace '(\*|_)(.*?)\1', '$2'
  $t = $t -replace '`([^`]+)`', '$1'
  $t = [regex]::Replace($t, '(?m)^\s*([-*+]|\d+\.)\s+', '')
  $t = [regex]::Replace($t, '(?m)^\s*>\s?', '')
  $t = [regex]::Replace($t, '\r', '')
  $t = [regex]::Replace($t, '\n{3,}', "`n`n")
  $t.Trim()
}

# Title-casing + acronyms
function Convert-ToTitleCase([string]$s) {
  if ([string]::IsNullOrWhiteSpace($s)) { return $s }
  $textInfo = (Get-Culture).TextInfo
  $tc = $textInfo.ToTitleCase($s.ToLower())
  $words = $tc -split ' '
  $stops = 'a|an|and|as|at|but|by|for|in|of|on|or|the|to|with'
  for ($i = 1; $i -lt $words.Count; $i++) { if ($words[$i] -match "^(?:$stops)$") { $words[$i] = $words[$i].ToLower() } }
  ($words -join ' ')
}
function Get-DocDisplayName([string]$Path) {
  $name = [System.IO.Path]::GetFileNameWithoutExtension($Path) `
    -replace '[-_]+' , ' ' `
    -replace '\s{2,}', ' ' `
    -replace '^\s+|\s+$', ''
  $name = Convert-ToTitleCase $name
  $name = $name -replace '\bAks\b', 'AKS' -replace '\bAad\b', 'AAD' -replace '\bCli\b', 'CLI' -replace '\bRbac\b', 'RBAC' `
    -replace '\bIp\b', 'IP' -replace '\bIps\b', 'IPs' -replace '\bVm(s)?\b', 'VM$1' -replace '\bVnet(s)?\b', 'VNet$1' `
    -replace '\bApi\b', 'API' -replace '\bUrl(s)?\b', 'URL$1'
  return $name
}

# Rough category fallback (by path)
function Compute-Category([string]$file) {
  $f = $file.ToLower()
  if ($f -match '/pci-') { return 'Compliance' }
  if ($f -match '/network|/cni|/load-balancer|/egress|/ingress|/vnet|/subnet') { return 'Networking' }
  if ($f -match '/security|/rbac|/aad|/defender|/keyvault|/tls|/certificate') { return 'Security' }
  if ($f -match '/storage|/disk|/snapshot') { return 'Storage' }
  if ($f -match '/node|/vm|/cvm|/keda|/gpu|/virt|/compute') { return 'Compute' }
  if ($f -match '/monitor|/logging|/diagnostic|/troubleshoot|/upgrade|/backup') { return 'Operations' }
  return 'General'
}

# =========================
# KIND PILL HELPERS
# =========================
function Get-SessionKind($items, [string]$summary) {
  $hasAdded = ($items | Where-Object { $_.status -eq 'added' }).Count -gt 0
  $hasRemoved = ($items | Where-Object { $_.status -eq 'removed' }).Count -gt 0
  $delta = ( ($items | Measure-Object -Sum -Property additions).Sum +
    ($items | Measure-Object -Sum -Property deletions).Sum )
  $heavySummary = $summary -match '(?i)\b(overhaul|rework|rewrite|significant|major)\b'
  if ($hasRemoved -and -not $hasAdded) { return "Removal" }
  if ($hasAdded) { return "New" }
  if ($heavySummary -or $delta -ge 80 -or $items.Count -ge 3) { return "Rework" }
  return "Update"
}
function KindToPillHtml([string]$kind) {
  $emoji = switch ($kind) {
    "New" { "🆕" }
    "Rework" { "♻️" }
    "Removal" { "🗑️" }
    "Deprecation" { "⚠️" }
    "Migration" { "➡️" }
    "Clarification" { "ℹ️" }
    default { "✨" }
  }
  $class = switch ($kind) {
    "New" { "aks-pill-kind aks-pill-new" }
    "Rework" { "aks-pill-kind aks-pill-rework" }
    "Removal" { "aks-pill-kind aks-pill-removal" }
    default { "aks-pill-kind aks-pill-update" }
  }
  "<span class=""$class"">$emoji $kind</span>"
}

# =========================
# FETCH PRs MERGED LAST 7 DAYS
# =========================
function Get-RecentMergedPRs {
  $all = @()
  for ($page = 1; $page -le 5; $page++) {
    $uri = "https://api.github.com/repos/$Owner/$Repo/pulls?state=closed&sort=updated&direction=desc&per_page=50&page=$page"
    $resp = Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
    if (-not $resp) { break }
    foreach ($pr in $resp) {
      if ($pr.merged_at -and ([DateTime]::Parse($pr.merged_at).ToUniversalTime() -ge $sinceMidnightUtc)) {
        $all += $pr
      }
    }
    if ($resp.Count -lt 50) { break }
  }
  return $all
}
function Get-PRFiles($Number) {
  $uri = "https://api.github.com/repos/$Owner/$Repo/pulls/$Number/files"
  Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
}

# =========================
# ALSO FETCH DIRECT COMMITS (NO PR)
# =========================
function Get-RecentCommits {
  param([string]$SinceIso)
  $all = @()
  for ($page = 1; $page -le 5; $page++) {
    $uri = "https://api.github.com/repos/$Owner/$Repo/commits?since=$SinceIso&per_page=100&page=$page"
    $resp = Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
    if (-not $resp) { break }
    $all += $resp
    if ($resp.Count -lt 100) { break }
  }
  return $all
}
function Get-CommitFiles {
  param([string]$Sha)
  $uri = "https://api.github.com/repos/$Owner/$Repo/commits/$Sha"
  Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
}

# =========================
# AI INIT (optional via PSAI)
# =========================
$PSAIReady = $false
function Initialize-AIProvider {
  param([ValidateSet('OpenAI', 'AzureOpenAI')][string]$Provider)
  try {
    if (-not (Get-Module -ListAvailable -Name PSAI)) {
      Install-Module PSAI -Scope CurrentUser -Force -ErrorAction Stop
    }
    Import-Module PSAI -ErrorAction Stop
  }
  catch { Write-Warning "PSAI not available; skipping AI. $_"; return $false }
  switch ($Provider) {
    'OpenAI' { if (-not $env:OpenAIKey) { Write-Warning "OpenAIKey not set"; return $false }; Set-OAIProvider -Provider OpenAI | Out-Null; return $true }
    'AzureOpenAI' {
      $secrets = @{
        apiURI         = $env:AZURE_OPENAI_APIURI
        apiKey         = $env:AZURE_OPENAI_KEY
        apiVersion     = $env:AZURE_OPENAI_API_VERSION
        deploymentName = $env:AZURE_OPENAI_DEPLOYMENT
      }
      if ($secrets.Values -contains $null -or ($secrets.Values | Where-Object { [string]::IsNullOrWhiteSpace($_) })) { Write-Warning "Azure OpenAI envs incomplete."; return $false }
      Set-OAIProvider -Provider AzureOpenAI | Out-Null
      Set-AzOAISecrets @secrets | Out-Null
      return $true
    }
  }
}
if ($PreferProvider) { $PSAIReady = Initialize-AIProvider -Provider $PreferProvider }

# =========================
# SHARED AI HELPERS
# =========================

# Pattern used to detect OpenAI/AzureOpenAI rate limit errors in catch blocks.
# Covers HTTP 429, common rate-limit/quota phrases, and OpenAI's insufficient_quota error code.
$RateLimitPattern = '\b429\b|rate[_\s-]limit|RateLimitExceeded|quota[\s_-]exceeded|exceeded.{0,50}quota|insufficient[_\s]quota'

# Maximum characters of an AI response to include in diagnostic log previews.
$PreviewMaxLength = 500

# Strips markdown code fences and OpenAI citation annotations (e.g. 【4:0†source.json】)
# from an AI response string before JSON parsing.
function Remove-AIResponseArtifacts([string]$Text) {
  return $Text -replace '(?m)^\s*```(?:json)?\s*$', '' -replace '(?m)^\s*```\s*$', '' -replace '【[^】]*】', ''
}

# Returns true if the error record indicates an API rate limit was reached.
# Checks the full exception chain so inner exceptions from PSAI wrappers are not missed.
function Test-IsRateLimitError($_err) {
  $parts = @("$_err")
  $ex = $_err.Exception
  while ($ex) {
    $parts += $ex.Message
    $ex = $ex.InnerException
  }
  $msg = $parts -join ' '
  return $msg -match $RateLimitPattern
}

# =========================
# GITHUB MODELS FALLBACK (used when OpenAI/AzureOpenAI rate limits are hit)
# Uses the GitHub Models inference API authenticated with GITHUB_TOKEN.
# Unlike the Assistants API, this uses Chat Completions with response_format:
# json_object, so no file upload, vector store, or complex regex parsing needed.
# =========================

function Invoke-GitHubModelsChatJson {
  param(
    [string]$SystemMessage,
    [string]$UserMessage,
    [string]$Model = "gpt-4o-mini",
    [int]$MaxTokens = 4096,
    [double]$Temperature = 0.05
  )
  $headers = @{
    "Authorization" = "Bearer $env:GITHUB_TOKEN"
    "Content-Type"  = "application/json"
  }
  $body = @{
    model    = $Model
    messages = @(
      @{ role = "system"; content = $SystemMessage }
      @{ role = "user";   content = $UserMessage }
    )
    max_tokens      = $MaxTokens
    temperature     = $Temperature
    response_format = @{ type = "json_object" }
  } | ConvertTo-Json -Depth 5 -Compress
  $response = Invoke-RestMethod -Uri "https://models.inference.ai.azure.com/chat/completions" `
    -Method POST -Headers $headers -Body $body -TimeoutSec 120 -ErrorAction Stop
  return $response.choices[0].message.content
}

function Get-PerFileSummariesViaGitHubModels {
  param([string]$JsonPath, [string]$Model = "gpt-4o-mini")
  try {
    Log "GitHub Models fallback: filtering docs..."
    $data = Get-Content -Path $JsonPath -Raw | ConvertFrom-Json -ErrorAction Stop

    # Build condensed input — metadata only, no large patch_sample — to stay within context limits
    $condensedGroups = @(
      foreach ($g in $data.groups) {
        @{
          file            = $g.file
          subjects        = $g.subjects
          total_additions = $g.total_additions
          total_deletions = $g.total_deletions
          commits_count   = $g.commits_count
          statuses        = $g.statuses
        }
      }
    )
    $condensedJson = (@{ since = $data.since; groups = $condensedGroups } | ConvertTo-Json -Depth 5 -Compress)

    $systemMsg = @"
You are filtering Azure AKS documentation updates. Be INCLUSIVE - when in doubt, KEEP IT.
ONLY EXCLUDE: pure ms.author/metadata-only changes, single-word typo fixes, pure whitespace changes.
ALWAYS KEEP: new features, commands, security, policy, version updates, tutorial improvements, technical corrections, new content, new files.
Return a JSON object with a single key "results" containing an array of kept items:
{"results": [{"file": "<path>", "summary": "2-3 factual sentences", "category": "Networking|Security|Compute|Storage|Operations|Compliance|General", "score": 0.0-1.0}]}
"@
    $userMsg = "Filter these documentation changes and return the JSON object:`n$condensedJson"

    $raw = Invoke-GitHubModelsChatJson -SystemMessage $systemMsg -UserMessage $userMsg `
      -Model $Model -MaxTokens 4096 -Temperature 0.05
    $content = $raw | ConvertFrom-Json -ErrorAction Stop

    $arr = $content.results
    $ordered = @()
    $byFile = @{}
    foreach ($i in $arr) {
      if (-not $i.file) { continue }
      $ordered += $i
      $byFile[$i.file] = @{
        summary  = $i.summary
        category = ($i.PSObject.Properties['category'] ? $i.category : 'General')
        score    = [double]($i.PSObject.Properties['score'] ? $i.score : 1.0)
      }
    }
    Log "GitHub Models fallback: kept $($ordered.Count) files after filtering."
    return @{ ordered = $ordered; byFile = $byFile }
  }
  catch {
    Write-Warning "GitHub Models fallback (docs) failed: $_"
    return @{ ordered = @(); byFile = @{} }
  }
}

function Get-ReleaseSummariesViaGitHubModels {
  param([string]$JsonPath, [string]$Model = "gpt-4o-mini")
  try {
    Log "GitHub Models fallback: summarizing releases..."
    $relJson = Get-Content -Path $JsonPath -Raw

    $systemMsg = @"
You are summarizing AKS GitHub Releases. The JSON array contains: id, title, tag_name, published_at, body (markdown).
Return a JSON object with a single key "results" containing an array:
{"results": [{"id": <same numeric id>, "summary": "2-3 sentences", "breaking_changes": ["..."], "key_features": ["..."], "good_to_know": ["..."]}]}
Rules: plain strings only, 2-5 items per list, never fabricate content not in the text.
"@
    $userMsg = "Summarize each release and return the JSON object:`n$relJson"

    $raw = Invoke-GitHubModelsChatJson -SystemMessage $systemMsg -UserMessage $userMsg `
      -Model $Model -MaxTokens 3000 -Temperature 0.2
    $content = $raw | ConvertFrom-Json -ErrorAction Stop

    $map = @{}
    foreach ($i in $content.results) {
      $map[$i.id] = @{
        summary          = $i.summary
        breaking_changes = $i.PSObject.Properties['breaking_changes'] ? $i.breaking_changes : @()
        key_features     = $i.PSObject.Properties['key_features']     ? $i.key_features     : @()
        good_to_know     = $i.PSObject.Properties['good_to_know']     ? $i.good_to_know     : @()
      }
    }
    Log "GitHub Models fallback: release summaries ready for $($map.Keys.Count) releases."
    return $map
  }
  catch {
    Write-Warning "GitHub Models fallback (releases) failed: $_"
    return @{}
  }
}

# ===== Enhanced Docs AI with SELECTIVE FILTERING =====
function Get-PerFileSummariesViaAssistant {
  param([string]$JsonPath, [string]$Model = "gpt-4o-mini")
  if (-not $PSAIReady) { return @{ ordered = @(); byFile = @{} } }
  try {
    Log "Uploading JSON to AI provider..."
    $file = Invoke-OAIUploadFile -Path $JsonPath -Purpose assistants -ErrorAction Stop

    $vsName = "aks-docs-prs-$(Get-Date -Format 'yyyyMMddHHmmss')"
    $vs = New-OAIVectorStore -Name $vsName -FileIds $file.id
    Log "Waiting on vector store processing..."
    $vsMaxIterations = 60  # 60 iterations × 2 s = up to 120 s
    $vsWaitCount = 0
    do {
      Start-Sleep -Seconds 2
      $vsWaitCount++
      $current = Get-OAIVectorStore -limit 100 -order desc | Where-Object { $_.id -eq $vs.id }
      if ($current) { $vs = $current }
      Log "Vector store status: $($vs.status)"
    } while ($vs.status -ne 'completed' -and $vs.status -ne 'failed' -and $vs.status -ne 'cancelled' -and $vsWaitCount -lt $vsMaxIterations)
    if ($vs.status -ne 'completed') {
      Write-Warning "Vector store processing did not complete (status: $($vs.status)) — falling back to GitHub Models"
      return Get-PerFileSummariesViaGitHubModels -JsonPath $JsonPath -Model $Model
    }

    $instructions = @"
You are filtering Azure AKS documentation updates. Your job is to be INCLUSIVE and keep most changes.

**CRITICAL: Be very permissive. When in doubt, KEEP IT.**

**ONLY EXCLUDE these very specific cases:**
1. Pure ms.author metadata changes with zero content changes
2. Single-word typo fixes with no other changes  
3. Pure whitespace/formatting changes with no content impact

**ALWAYS KEEP (even if small):**
- Learn Editor updates with ANY content changes
- Bot commits with ANY documentation improvements  
- New features, commands, or procedures (any size)
- Security, policy, or compliance updates
- Version updates or compatibility changes
- Tutorial improvements or new examples
- Corrections to technical information
- New sections or content reorganization
- Any change with technical substance

**EVALUATION APPROACH:**
- Default to KEEPING unless obviously trivial
- Look for ANY technical value or user benefit
- Bot/automated commits often contain valuable updates
- Small changes can still be meaningful
- Size doesn't determine value

**ALWAYS KEEP:** New files (status "added") regardless of content.

**Your goal:** High signal-to-noise ratio while being inclusive of valuable updates.

OUTPUT: JSON array of kept items:
[
  { "file": "<path>", "summary": "2-3 factual sentences", "category": "Networking|Security|Compute|Storage|Operations|Compliance|General", "score": 0.0-1.0 }
]
"@

    $assistant = New-OAIAssistant `
      -Name "AKS-Docs-SelectiveFilter" `
      -Instructions $instructions `
      -Tools @{ type = 'file_search' } `
      -ToolResources @{ file_search = @{ vector_store_ids = @($vs.id) } } `
      -Model $Model

    $userMsg = "Apply selective filtering using the guidelines provided. Be inclusive rather than exclusive - keep changes that have technical value or substance. Return ONLY the JSON array."
    $run = New-OAIThreadAndRun -AssistantId $assistant.id -Thread @{ messages = @(@{ role = 'user'; content = $userMsg }) } -MaxCompletionTokens 4096 -Temperature 0.05
    $run = Wait-OAIOnRun -Run $run -Thread @{ id = $run.thread_id }

    if ($run.status -ne 'completed') {
      $errCode = if ($run.last_error -and $run.last_error.code -and $run.last_error.message) { " ($($run.last_error.code): $($run.last_error.message))" } else { '' }
      throw "Docs assistant run did not complete (status: $($run.status))$errCode"
    }

    # Filter to assistant messages only — a failed run leaves only the user message in the thread,
    # which would cause the JSON regex to match against the prompt instead of a real response.
    $messages = (Get-OAIMessage -ThreadId $run.thread_id -Order desc -Limit 10).data
    $assistantMsg = $messages | Where-Object { $_.role -eq 'assistant' } | Select-Object -First 1
    if (-not $assistantMsg) {
      Log "AI: No assistant reply found in thread — falling back to GitHub Models."
      return Get-PerFileSummariesViaGitHubModels -JsonPath $JsonPath -Model $Model
    }
    $last = $assistantMsg.content | Where-Object { $_.type -eq 'text' } | ForEach-Object { $_.text.value } | Out-String

    # Strip markdown code fences and OpenAI citation annotations (e.g. 【4:0†source.json】)
    $clean = Remove-AIResponseArtifacts $last
    $match = [regex]::Match($clean, '\[(?:[^][]|(?<open>\[)|(?<-open>\]))*\](?(open)(?!))', 'Singleline')
    if (-not $match.Success) {
      $preview = if ($clean) { $clean.Substring(0, [Math]::Min($PreviewMaxLength, $clean.Length)) } else { '(empty response)' }
      Log "AI: No JSON array found in response — falling back to GitHub Models. Raw response (first $PreviewMaxLength chars): $preview"
      return Get-PerFileSummariesViaGitHubModels -JsonPath $JsonPath -Model $Model
    }

    $arr = $match.Value | ConvertFrom-Json -ErrorAction Stop

    $ordered = @()
    $byFile = @{}
    foreach ($i in $arr) {
      if (-not $i.file) { continue }
      $ordered += $i
      $byFile[$i.file] = @{
        summary  = $i.summary
        category = ($i.PSObject.Properties['category'] ? $i.category : 'General')
        score    = [double]($i.PSObject.Properties['score'] ? $i.score : 1.0)
      }
    }
    Log "AI: Kept $($ordered.Count) files after selective filtering."
    return @{ ordered = $ordered; byFile = $byFile }
  }
  catch {
    if (Test-IsRateLimitError $_) {
      Write-Warning "OpenAI rate limit reached for docs — falling back to GitHub Models. Error: $($_.Exception.Message)"
      return Get-PerFileSummariesViaGitHubModels -JsonPath $JsonPath -Model $Model
    }
    Write-Warning "AI summaries (docs) failed: $_"
    return @{ ordered = @(); byFile = @{} }
  }
  finally {
    # Clean up AI resources to avoid accumulating orphaned objects
    if ($assistant) { try { Remove-OAIAssistant -AssistantId $assistant.id | Out-Null } catch {} }
    if ($vs) { try { Remove-OAIVectorStore -VectorStoreId $vs.id | Out-Null } catch {} }
    if ($file) { try { Remove-OAIFile -FileId $file.id | Out-Null } catch {} }
  }
}

function Summarize-ModifiedPatch {
  param(
    [string]$FilePath,
    [string[]]$Subjects,
    [string]$PatchSample,
    $Signals,
    [string]$Model = "gpt-4o-mini"
  )

  # Enhanced check for trivial changes
  if (Is-TrivialChange -PatchSample $PatchSample -Subjects $Subjects -TotalLines ($PatchSample -split "`n").Count) {
    return "Trivial update detected - likely metadata or navigation changes only."
  }

  # If AI available, do a tiny targeted run
  if ($PSAIReady -and $PatchSample) {
    try {
      $instructions = @"
Summarize documentation changes for a CHANGELOG card. Focus ONLY on user-impacting changes.

IGNORE and don't mention:
- Author/metadata changes (ms.author, ms.date, etc.)
- "Deploy and Explore" or navigation callouts
- Pure formatting/whitespace
- Link updates without content changes

Rules:
- 2–3 sentences, plain text, no bullets
- Mention specific sections, commands, parameters, or features changed
- Be specific about what users can now do differently
- If only trivial changes detected, say "Minor documentation maintenance updates"
"@

      $assistant = New-OAIAssistant -Name "AKS-Doc-SelectiveSummarizer" -Instructions $instructions -Model $Model
      $content = @"
File: $FilePath

Subjects:
- $(($Subjects | Select-Object -Unique) -join "`n- ")

Patch excerpt:
$PatchSample
"@
      $run = New-OAIThreadAndRun -AssistantId $assistant.id -Thread @{ messages = @(@{ role = 'user'; content = $content }) } -MaxCompletionTokens 220 -Temperature 0.1
      $run = Wait-OAIOnRun -Run $run -Thread @{ id = $run.thread_id }
      $text = (Get-OAIMessage -ThreadId $run.thread_id -Order desc -Limit 1).data[0].content | Where-Object { $_.type -eq 'text' } | ForEach-Object { $_.text.value } | Out-String
      return (Truncate $text.Trim() 400)
    }
    catch { }
  }

  # Enhanced heuristic summary with trivial filtering
  $bits = @()

  if ($Signals.headings.Count -gt 0) {
    $h = $Signals.headings -join '; '
    $bits += "Adds/updates section(s): $h"
  }

  if ($Signals.annos.Count -gt 0) {
    # Detect replacements like old → new
    $annoLine = ($Signals.annos -join ', ')
    if ($PatchSample -match 'service\.beta\.kubernetes\.io' -and $PatchSample -match 'networking\.fleet\.azure\.com') {
      $bits += "Replaces service annotations with Fleet-scoped keys (e.g., networking.fleet.azure.com)."
    }
    else {
      $bits += "Updates service annotations/keys ($annoLine)."
    }
  }

  if ($Signals.flags.Count -gt 0) {
    $bits += "Changes CLI flags: " + (($Signals.flags | Select-Object -First 4) -join ', ')
  }

  if ($Signals.hasCli) {
    $bits += "Adds runnable examples (e.g., " + (($Signals.cliExamples | Select-Object -First 1) -replace '\s+', ' ') + ")."
  }

  if ($Signals.hasSecurityCue) {
    $bits += "Includes security/operational guidance (Key Vault/managed identity/NSG)."
  }

  # If no meaningful signals found, check if we should even keep this
  if ($bits.Count -eq 0) {
    if ($PatchSample -match '(?i)(nextstepaction|deploy and explore|ms\.author|author:)') {
      return "Minor documentation maintenance updates."
    }
    $bits += "Updates content with clarifications and improvements."
  }

  $s = ($bits -join ' ')
  return (Truncate $s 300)
}

# =========================
# CVE VULNERABILITY DATA (AKS CVE API - Public Preview)
# =========================
function Get-AksCveTabHtml {
  $cveApiBase     = "https://cve-api.prod-aks.azure.com"
  $cveExplorerUrl = "https://cve-api.prod-aks.azure.com/viewer/index.html"

  try {
    # ── CONTAINER IMAGE DATA ────────────────────────────────────────────────────
    Log "Fetching AKS CVE release index..."
    $index    = Invoke-RestMethod -Uri "$cveApiBase/api/v1/aks-releases/_index" -Method GET -TimeoutSec 30
    $versions = @($index.aks_release_versions)
    if (-not $versions -or $versions.Count -eq 0) {
      return '<p style="color:#94a3b8;">CVE data temporarily unavailable.</p>'
    }

    $latestVersion = $versions[-1]

    # Pre-fetch ALL versions and embed data in the HTML. This avoids browser CORS issues
    # since the CVE API does not return Access-Control-Allow-Origin headers for cross-origin requests.
    Log "Pre-fetching CVE scan reports for all $($versions.Count) AKS releases..."
    $allReports = @{}
    foreach ($ver in $versions) {
      Log "  Fetching container CVE data for $ver..."
      $allReports[$ver] = Invoke-RestMethod -Uri "$cveApiBase/api/v1/aks-releases/$ver/scan-reports" -Method GET -TimeoutSec 30
    }

    # Build compact JS data for container images
    $jsVersionsArr  = "[" + (($versions | ForEach-Object { "`"$_`"" }) -join ",") + "]"
    $byVersionParts = [System.Collections.Generic.List[string]]::new()
    $initActive = 0; $initMitigated = 0; $initAffected = 0; $initTotal = 0
    $initDate = "N/A"; $initTopRowsHtml = ""

    foreach ($ver in $versions) {
      $report     = $allReports[$ver]
      $containers = @($report.container_targets)
      $rDate      = if ($report.report_time) { [DateTime]::Parse($report.report_time).ToString("yyyy-MM-dd") } else { "N/A" }

      $uActive = @{}; $uMit = @{}; $withCves = 0
      $cveMap  = [ordered]@{}

      foreach ($c in $containers) {
        $had = $false
        foreach ($cv in @($c.active_cves)) {
          if ($cv.id) {
            $uActive[$cv.id] = 1; $had = $true
            if (-not $cveMap.Contains($cv.id)) { $cveMap[$cv.id] = @{ a = [System.Collections.Generic.List[string]]::new(); m = [System.Collections.Generic.List[string]]::new() } }
            $cveMap[$cv.id].a.Add($c.container_name)
          }
        }
        foreach ($cv in @($c.mitigated_cves_from_previous_release)) {
          if ($cv.id) {
            $uMit[$cv.id] = 1
            if (-not $cveMap.Contains($cv.id)) { $cveMap[$cv.id] = @{ a = [System.Collections.Generic.List[string]]::new(); m = [System.Collections.Generic.List[string]]::new() } }
            $cveMap[$cv.id].m.Add($c.container_name)
          }
        }
        if ($had) { $withCves++ }
      }

      $activeCount    = $uActive.Count
      $mitigatedCount = $uMit.Count

      $top10 = @($containers |
        Where-Object { $_.active_cves -and $_.active_cves.Count -gt 0 } |
        Sort-Object { $_.active_cves.Count } -Descending |
        Select-Object -First 10)

      $topArrJson = "[" + (($top10 | ForEach-Object {
        $mitCnt = if ($_.PSObject.Properties['mitigated_cves_from_previous_release']) { $_.mitigated_cves_from_previous_release.Count } else { 0 }
        $ns = $_.pod_namespace  -replace '\\', '\\' -replace '"', '\"'
        $cn = $_.container_name -replace '\\', '\\' -replace '"', '\"'
        "[`"$ns`",`"$cn`",$($_.active_cves.Count),$mitCnt]"
      }) -join ",") + "]"

      $cveJsonParts = [System.Collections.Generic.List[string]]::new()
      foreach ($cveId in $cveMap.Keys) {
        $eid = $cveId -replace '\\', '\\' -replace '"', '\"'
        $aJ  = ($cveMap[$cveId].a | ForEach-Object { "`"$($_ -replace '\\','\\' -replace '"','\"')`"" }) -join ","
        $mJ  = ($cveMap[$cveId].m | ForEach-Object { "`"$($_ -replace '\\','\\' -replace '"','\"')`"" }) -join ","
        $cveJsonParts.Add("`"$eid`":{`"a`":[$aJ],`"m`":[$mJ]}")
      }
      $cveIdxJson = "{" + ($cveJsonParts -join ",") + "}"

      $byVersionParts.Add("`"$ver`":{`"date`":`"$rDate`",`"active`":$activeCount,`"mitigated`":$mitigatedCount,`"affected`":$withCves,`"total`":$($containers.Count),`"top`":$topArrJson,`"cves`":$cveIdxJson}")

      if ($ver -eq $latestVersion) {
        $initActive    = $activeCount
        $initMitigated = $mitigatedCount
        $initAffected  = $withCves
        $initTotal     = $containers.Count
        $initDate      = $rDate
        $initTopRowsHtml = ($top10 | ForEach-Object {
          $cnt       = $_.active_cves.Count
          $mitInCont = if ($_.PSObject.Properties['mitigated_cves_from_previous_release']) { $_.mitigated_cves_from_previous_release.Count } else { 0 }
          $mitCell   = if ($mitInCont -gt 0) {
            "<td style=""color:#34d399;font-weight:600;text-align:center;"">&#9989; $mitInCont</td>"
          } else { "<td style=""color:#6b7280;text-align:center;"">&mdash;</td>" }
          $nsDisplay = Escape-Html $_.pod_namespace
          $cnDisplay = Escape-Html $_.container_name
          # Highlight K8s core components (kube-system)
          $k8sTag = if ($_.pod_namespace -eq 'kube-system') { "<span style=""display:inline-block;padding:1px 5px;background:rgba(99,102,241,0.2);color:#a5b4fc;border-radius:3px;font-size:10px;margin-left:4px;"">k8s</span>" } else { "" }
          "<tr style=""border-top:1px solid rgba(255,255,255,0.06);""><td style=""padding:6px 10px;font-size:13px;color:#94a3b8;"">$nsDisplay</td><td style=""padding:6px 10px;font-size:13px;font-weight:500;"">$cnDisplay$k8sTag</td><td style=""padding:6px 10px;font-size:13px;font-weight:700;color:#f87171;text-align:center;"">$cnt</td>$mitCell</tr>"
        }) -join "`n"
      }
    }

    $byVersionJson  = "{" + ($byVersionParts -join ",") + "}"
    $versionCount   = $versions.Count

    # Version dropdown options (newest first)
    $versionOptions = ($versions | Sort-Object -Descending | ForEach-Object {
      $sel = if ($_ -eq $latestVersion) { ' selected' } else { '' }
      "<option value=""$_""$sel>$_</option>"
    }) -join "`n        "

    # ── VHD NODE IMAGE DATA ─────────────────────────────────────────────────────
    $vhdAvailable    = $false
    $jsVhdImagesArr  = "[]"
    $vhdByImageJson  = "{}"
    $vhdInitActive   = 0; $vhdInitMitigated = 0; $vhdInitAffected = 0; $vhdInitTotal = 0
    $vhdInitDate     = "N/A"; $vhdInitImage = "N/A"; $vhdInitTopRowsHtml = ""
    $vhdImageOptions = ""

    if ($script:RefreshVhdCve) {
    try {
      Log "Fetching VHD node-image index..."
      $nodeIndex = Invoke-RestMethod -Uri "$cveApiBase/api/v1/vhd-releases/_index" -Method GET -TimeoutSec 30
      Log "  VHD index response keys: $($nodeIndex.PSObject.Properties.Name -join ', ')"

      # Extract all release entries from the index; try multiple known property names.
      # The API typically returns full "{imageType}/{version}" paths for all available releases.
      $rawEntries = @(
        if     ($nodeIndex.PSObject.Properties['vhd_release_versions']) { $nodeIndex.vhd_release_versions }
        elseif ($nodeIndex.PSObject.Properties['vhd_releases'])         { $nodeIndex.vhd_releases }
        elseif ($nodeIndex.PSObject.Properties['vhd_release_names'])    { $nodeIndex.vhd_release_names }
        elseif ($nodeIndex.PSObject.Properties['node_image_names'])     { $nodeIndex.node_image_names }
        elseif ($nodeIndex.PSObject.Properties['images'])               { $nodeIndex.images }
        elseif ($nodeIndex -is [array])                                 { $nodeIndex }
        else                                                            { @() }
      )
      Log "  VHD raw entries from index: $($rawEntries.Count) total"

      # Partition entries into full-path (type/version) and bare image-type names.
      # Keep the last $VHD_HISTORY_PER_OS versions per OS type (newest first) so the
      # browse tab and CVE search cover recent history, not just a single snapshot.
      $VHD_HISTORY_PER_OS = 3
      $typeVersionsMap = [ordered]@{}   # OS -> [all versions found]
      $bareNames     = [System.Collections.Generic.List[string]]::new()
      foreach ($entry in $rawEntries) {
        if ($entry -match '^([^/]+)/(.+)$') {
          $imgType = $Matches[1]
          $imgVer  = $Matches[2]
          if (-not $typeVersionsMap.Contains($imgType)) {
            $typeVersionsMap[$imgType] = [System.Collections.Generic.List[string]]::new()
          }
          $typeVersionsMap[$imgType].Add($imgVer)
        } else {
          $bareNames.Add($entry)
        }
      }

      $vhdImages = [System.Collections.Generic.List[string]]::new()
      foreach ($imgType in $typeVersionsMap.Keys) {
        $topVersions = @($typeVersionsMap[$imgType] | Sort-Object -Descending) | Select-Object -First $VHD_HISTORY_PER_OS
        foreach ($ver in $topVersions) {
          Log "  Queuing ${imgType}: $ver"
          $vhdImages.Add("$imgType/$ver")
        }
      }

      # For bare image-type names, look up the latest available version from the per-image index.
      foreach ($name in $bareNames) {
        Log "  Looking up versions for image type: $name ..."
        try {
          $imgIdx = Invoke-RestMethod -Uri "$cveApiBase/api/v1/vhd-releases/$name/_index" -Method GET -TimeoutSec 30
          Log "    Image type index response keys: $($imgIdx.PSObject.Properties.Name -join ', ')"
          $imgVersions = @(
            if     ($imgIdx.PSObject.Properties['vhd_release_versions']) { $imgIdx.vhd_release_versions }
            elseif ($imgIdx.PSObject.Properties['versions'])             { $imgIdx.versions }
            elseif ($imgIdx.PSObject.Properties['release_versions'])     { $imgIdx.release_versions }
            elseif ($imgIdx -is [array])                                 { $imgIdx }
            else                                                         { @() }
          )
          if ($imgVersions.Count -gt 0) {
            $latestVer = ($imgVersions | Sort-Object {
              $v = $_
              try { [System.Version]::new($v) }
              catch { Write-Warning "  Could not parse version '$v' for ${name}, using 0.0.0"; [System.Version]::new("0.0.0") }
            } -Descending)[0]
            Log "    Latest version for ${name}: $latestVer"
            $vhdImages.Add("$name/$latestVer")
          } else {
            Write-Warning "  No versions found in index for image type: $name"
          }
        } catch {
          Write-Warning "  Failed to fetch version index for ${name}: $_"
        }
      }
      Log "  VHD images to fetch ($($vhdImages.Count)): $($vhdImages -join ', ')"

      if ($vhdImages.Count -gt 0) {
        Log "Pre-fetching VHD CVE scan reports for $($vhdImages.Count) node images..."
        $vhdReports = @{}
        foreach ($img in $vhdImages) {
          Log "  Fetching VHD CVE data for $img..."
          $vhdRpt = Invoke-RestMethod -Uri "$cveApiBase/api/v1/vhd-releases/$img/scan-reports" -Method GET -TimeoutSec 30
          Log "    Scan-report response keys: $($vhdRpt.PSObject.Properties.Name -join ', ')"
          $pkgCount = if ($vhdRpt.os_package_targets) { $vhdRpt.os_package_targets.Count }
                      elseif ($vhdRpt.packages)        { $vhdRpt.packages.Count }
                      else                             { 0 }
          Log "    Package targets returned: $pkgCount"
          $vhdReports[$img] = $vhdRpt
        }
        # Validate that actual CVE data was retrieved before marking as available
        $totalVhdActiveCves = 0
        foreach ($img in $vhdImages) {
          $rpt  = $vhdReports[$img]
          $pkgs = @(if ($rpt.os_package_targets) { $rpt.os_package_targets } elseif ($rpt.packages) { $rpt.packages } else { @() })
          $totalVhdActiveCves += ($pkgs | ForEach-Object { @($_.active_cves).Count } | Measure-Object -Sum).Sum
        }
        Log "VHD data summary: $($vhdImages.Count) images fetched, $totalVhdActiveCves total active CVE references across all packages"
        if ($totalVhdActiveCves -eq 0) {
          Write-Warning "VHD scan reports returned 0 active CVEs for $($vhdImages.Count) images ($($vhdImages -join ', ')) — this may indicate empty data or a wrong API endpoint. Verify the URL structure."
        }

        $vhdAvailable   = $true
        $jsVhdImagesArr = "[" + (($vhdImages | ForEach-Object { "`"$_`"" }) -join ",") + "]"
        $vhdByImageParts = [System.Collections.Generic.List[string]]::new()

        # Sort images so Linux images come first, then Windows
        $sortedVhdImages = @($vhdImages | Sort-Object {
          $img = $_
          if ($img -match 'windows|Windows') { 1 } else { 0 }
        })

        foreach ($img in $sortedVhdImages) {
          $vhdRpt   = $vhdReports[$img]
          $vhdDate  = if ($vhdRpt.report_time) { [DateTime]::Parse($vhdRpt.report_time).ToString("yyyy-MM-dd") } else { "N/A" }

          # Support both 'os_package_targets' and 'packages' field names
          $pkgTargets = @(
            if ($vhdRpt.os_package_targets) { $vhdRpt.os_package_targets }
            elseif ($vhdRpt.packages)        { $vhdRpt.packages }
            else                             { @() }
          )

          $vActive = @{}; $vMit = @{}; $pkgWithCves = 0
          $vCveMap = [ordered]@{}

          foreach ($pkg in $pkgTargets) {
            $pkgName = if ($pkg.package_name) { $pkg.package_name } elseif ($pkg.name) { $pkg.name } else { "unknown" }
            $had = $false
            foreach ($cv in @($pkg.active_cves)) {
              if ($cv.id) {
                $vActive[$cv.id] = 1; $had = $true
                if (-not $vCveMap.Contains($cv.id)) { $vCveMap[$cv.id] = @{ a = [System.Collections.Generic.List[string]]::new(); m = [System.Collections.Generic.List[string]]::new() } }
                $vCveMap[$cv.id].a.Add($pkgName)
              }
            }
            foreach ($cv in @($pkg.mitigated_cves_from_previous_release)) {
              if ($cv.id) {
                $vMit[$cv.id] = 1
                if (-not $vCveMap.Contains($cv.id)) { $vCveMap[$cv.id] = @{ a = [System.Collections.Generic.List[string]]::new(); m = [System.Collections.Generic.List[string]]::new() } }
                $vCveMap[$cv.id].m.Add($pkgName)
              }
            }
            if ($had) { $pkgWithCves++ }
          }

          $vActive10 = @($pkgTargets |
            Where-Object {
              $_.active_cves -and @($_.active_cves).Count -gt 0
            } |
            Sort-Object { @($_.active_cves).Count } -Descending |
            Select-Object -First 10)

          $vTopArrJson = "[" + (($vActive10 | ForEach-Object {
            $pn  = if ($_.package_name) { $_.package_name } elseif ($_.name) { $_.name } else { "unknown" }
            $pv  = if ($_.package_version) { $_.package_version } elseif ($_.version) { $_.version } else { "" }
            $mit = if ($_.PSObject.Properties['mitigated_cves_from_previous_release']) { @($_.mitigated_cves_from_previous_release).Count } else { 0 }
            $pnJ = $pn -replace '\\','\\' -replace '"','\"'
            $pvJ = $pv -replace '\\','\\' -replace '"','\"'
            "[`"$pnJ`",`"$pvJ`",$(@($_.active_cves).Count),$mit]"
          }) -join ",") + "]"

          $vCveJsonParts = [System.Collections.Generic.List[string]]::new()
          foreach ($cveId in $vCveMap.Keys) {
            $eid = $cveId -replace '\\','\\' -replace '"','\"'
            $aJ  = ($vCveMap[$cveId].a | ForEach-Object { "`"$($_ -replace '\\','\\' -replace '"','\"')`"" }) -join ","
            $mJ  = ($vCveMap[$cveId].m | ForEach-Object { "`"$($_ -replace '\\','\\' -replace '"','\"')`"" }) -join ","
            $vCveJsonParts.Add("`"$eid`":{`"a`":[$aJ],`"m`":[$mJ]}")
          }
          $vCveIdxJson = "{" + ($vCveJsonParts -join ",") + "}"

          $imgJ = $img -replace '\\','\\' -replace '"','\"'
          $vhdByImageParts.Add("`"$imgJ`":{`"date`":`"$vhdDate`",`"active`":$($vActive.Count),`"mitigated`":$($vMit.Count),`"affected`":$pkgWithCves,`"total`":$($pkgTargets.Count),`"top`":$vTopArrJson,`"cves`":$vCveIdxJson}")
        }

        $vhdByImageJson = "{" + ($vhdByImageParts -join ",") + "}"

        # Aggregate totals across all VHD images for summary
        $allVhdActive    = [System.Collections.Generic.HashSet[string]]::new()
        $allVhdMitigated = [System.Collections.Generic.HashSet[string]]::new()
        foreach ($img in $sortedVhdImages) {
          $vhdRpt = $vhdReports[$img]
          $pkgT   = @(if ($vhdRpt.os_package_targets) { $vhdRpt.os_package_targets } elseif ($vhdRpt.packages) { $vhdRpt.packages } else { @() })
          foreach ($pkg in $pkgT) {
            foreach ($cv in @($pkg.active_cves))                             { if ($cv.id) { $null = $allVhdActive.Add($cv.id)    } }
            foreach ($cv in @($pkg.mitigated_cves_from_previous_release))    { if ($cv.id) { $null = $allVhdMitigated.Add($cv.id)  } }
          }
        }
        $vhdInitActive    = $allVhdActive.Count
        $vhdInitMitigated = $allVhdMitigated.Count
        $vhdInitTotal     = $sortedVhdImages.Count

        # Top images by active CVE count
        $topVhdImages = @($sortedVhdImages | ForEach-Object {
          $img = $_
          $vhdRpt = $vhdReports[$img]
          $pkgT   = @(if ($vhdRpt.os_package_targets) { $vhdRpt.os_package_targets } elseif ($vhdRpt.packages) { $vhdRpt.packages } else { @() })
          $actCnt = ($pkgT | ForEach-Object { @($_.active_cves).Count } | Measure-Object -Sum).Sum
          $mitCnt = ($pkgT | ForEach-Object { @($_.mitigated_cves_from_previous_release).Count } | Measure-Object -Sum).Sum
          [pscustomobject]@{ img=$img; active=$actCnt; mitigated=$mitCnt }
        } | Sort-Object { -$_.active } | Select-Object -First 10)

        $vhdInitAffected = ($topVhdImages | Where-Object { $_.active -gt 0 }).Count
        $vhdInitImage    = $sortedVhdImages[0]
        $vhdInitDate     = if ($vhdReports[$vhdInitImage].report_time) { [DateTime]::Parse($vhdReports[$vhdInitImage].report_time).ToString("yyyy-MM-dd") } else { "N/A" }

        $vhdInitTopRowsHtml = ($topVhdImages | ForEach-Object {
          $imgParts    = $_.img -split '/', 2
          $imgTypeName = Escape-Html $imgParts[0]
          $imgVerLabel = if ($imgParts.Count -gt 1) { "<span style=""display:block;font-size:11px;color:#6b7280;font-weight:400;"">$($imgParts[1])</span>" } else { "" }
          $mitCell     = if ($_.mitigated -gt 0) {
            "<td style=""color:#34d399;font-weight:600;text-align:center;"">&#9989; $($_.mitigated)</td>"
          } else { "<td style=""color:#6b7280;text-align:center;"">&mdash;</td>" }
          $osTag = if ($_.img -match 'ubuntu|Ubuntu') { "<span style=""padding:1px 5px;background:rgba(251,146,60,0.15);color:#fb923c;border-radius:3px;font-size:10px;margin-left:4px;"">Ubuntu</span>" }
                   elseif ($_.img -match 'azurelinux|AzureLinux|mariner|Mariner') { "<span style=""padding:1px 5px;background:rgba(52,211,153,0.15);color:#34d399;border-radius:3px;font-size:10px;margin-left:4px;"">Azure Linux</span>" }
                   elseif ($_.img -match 'windows|Windows') { "<span style=""padding:1px 5px;background:rgba(96,165,250,0.15);color:#60a5fa;border-radius:3px;font-size:10px;margin-left:4px;"">Windows</span>" }
                   else { "" }
          "<tr style=""border-top:1px solid rgba(255,255,255,0.06);""><td style=""padding:6px 10px;font-size:13px;font-weight:500;"">$imgTypeName$osTag$imgVerLabel</td><td style=""padding:6px 10px;font-size:13px;font-weight:700;color:#f87171;text-align:center;"">$($_.active)</td>$mitCell</tr>"
        }) -join "`n"

        # Image selector dropdown for VHD tab
        $vhdImageOptions = ($sortedVhdImages | ForEach-Object {
          $sel    = if ($_ -eq $vhdInitImage) { ' selected' } else { '' }
          $parts  = $_ -split '/', 2
          $label  = if ($parts.Count -gt 1) { "$($parts[0]) ($($parts[1]))" } else { $_ }
          "<option value=""$_""$sel>$label</option>"
        }) -join "`n        "

        # ── Save VHD data to cache so other runs can reuse it ─────────────
        try {
          $vhdCacheObj = [ordered]@{
            jsVhdImagesArr    = $jsVhdImagesArr
            vhdByImageJson    = $vhdByImageJson
            vhdInitActive     = $vhdInitActive
            vhdInitMitigated  = $vhdInitMitigated
            vhdInitAffected   = $vhdInitAffected
            vhdInitTotal      = $vhdInitTotal
            vhdInitDate       = $vhdInitDate
            vhdInitImage      = $vhdInitImage
            vhdInitTopRowsHtml = $vhdInitTopRowsHtml
            vhdImageOptions   = $vhdImageOptions
            cachedAt          = (Get-Date -Format 'o')
          }
          $vhdCacheObj | ConvertTo-Json -Depth 2 -Compress | Set-Content -LiteralPath 'vhd-cache.json' -Encoding UTF8
          Log "VHD data saved to vhd-cache.json ($($vhdImages.Count) images, $vhdInitActive active CVEs)"
        } catch {
          Write-Warning "Failed to write VHD cache: $_"
        }
      }
    }
    catch {
      Write-Warning "VHD node-image CVE fetch failed (non-fatal): $_"
    }
    } # end if ($script:RefreshVhdCve)

    # ── Load VHD data from cache when not doing a live refresh ─────────────────
    if (-not $vhdAvailable -and (Test-Path 'vhd-cache.json')) {
      try {
        Log "Loading VHD data from cache (vhd-cache.json)..."
        $vhdCacheObj       = Get-Content 'vhd-cache.json' -Raw | ConvertFrom-Json
        $jsVhdImagesArr    = $vhdCacheObj.jsVhdImagesArr
        $vhdByImageJson    = $vhdCacheObj.vhdByImageJson
        $vhdInitActive     = [int]$vhdCacheObj.vhdInitActive
        $vhdInitMitigated  = [int]$vhdCacheObj.vhdInitMitigated
        $vhdInitAffected   = [int]$vhdCacheObj.vhdInitAffected
        $vhdInitTotal      = [int]$vhdCacheObj.vhdInitTotal
        $vhdInitDate       = $vhdCacheObj.vhdInitDate
        $vhdInitImage      = $vhdCacheObj.vhdInitImage
        $vhdInitTopRowsHtml = $vhdCacheObj.vhdInitTopRowsHtml
        $vhdImageOptions   = $vhdCacheObj.vhdImageOptions
        $vhdAvailable      = $true
        Log "VHD cache loaded (cached $($vhdCacheObj.cachedAt)): $vhdInitActive active CVEs across $vhdInitTotal images"
      } catch {
        Write-Warning "Failed to load VHD cache: $_"
      }
    }

    # ── BUILD HTML ──────────────────────────────────────────────────────────────

    $searchTabStyle    = "display:block"
    $vhdTabStyle       = "display:none"
    $containerTabStyle = "display:none"
    $searchBtnActive   = "border-bottom:2px solid #818cf8;color:#818cf8;background:rgba(99,102,241,0.08);"
    $vhdBtnActive      = ""
    $contBtnActive     = ""

    # VHD unavailable notice (shown inside VHD panel when no data)
    $vhdUnavailHtml = if (-not $vhdAvailable) { @"
    <div style="padding:20px;text-align:center;color:#94a3b8;">
      <div style="font-size:32px;margin-bottom:8px;">&#128679;</div>
      <div style="font-size:14px;font-weight:600;color:#e2e8f0;margin-bottom:6px;">VHD Node Image data refreshes daily</div>
      <div style="font-size:13px;">VHD CVE data is fetched once per day (06:00 UTC) to keep API call counts manageable. Check back later or use the <a href="$cveExplorerUrl" target="_blank" rel="noopener" style="color:#60a5fa;">CVE Explorer</a> for live data.</div>
    </div>
"@ } else { "" }

    return @"
<div id="aks-cve-root" style="padding:4px 0;">

  <!-- Banner -->
  <div style="display:flex;align-items:flex-start;gap:12px;background:rgba(59,130,246,0.1);border:1px solid rgba(147,197,253,0.25);border-radius:8px;padding:16px 20px;margin-bottom:16px;">
    <span style="font-size:28px;flex-shrink:0;">&#128737;&#65039;</span>
    <div>
      <strong style="font-size:16px;color:#93c5fd;">AKS CVE Security Dashboard</strong>
      <span style="display:inline-block;padding:2px 8px;background:rgba(251,191,36,0.15);color:#fbbf24;border-radius:12px;font-size:11px;font-weight:600;margin-left:8px;">Public Preview</span>
      <p style="margin:6px 0 0;font-size:13px;color:#bfdbfe;line-height:1.5;">
        Multi-layer CVE tracking for AKS: VHD node images (OS packages) and Kubernetes platform containers, sourced from the
        <a href="$cveExplorerUrl" target="_blank" rel="noopener" style="color:#60a5fa;font-weight:600;">AKS CVE API</a>.
        All data is pre-loaded for instant results — no browser API calls needed.
      </p>
    </div>
  </div>

  <!-- Sub-tab Navigation -->
  <div style="display:flex;gap:0;border-bottom:1px solid rgba(255,255,255,0.12);margin-bottom:20px;">
    <button id="aks-cve-btn-search" onclick="aksCveShowTab('search')"
      style="padding:10px 20px;border:none;border-radius:6px 6px 0 0;font-size:13px;font-weight:600;cursor:pointer;background:transparent;color:#e2e8f0;transition:all 0.15s;$searchBtnActive">
      &#128269; CVE Search
    </button>
    <button id="aks-cve-btn-vhd" onclick="aksCveShowTab('vhd')"
      style="padding:10px 20px;border:none;border-radius:6px 6px 0 0;font-size:13px;font-weight:600;cursor:pointer;background:transparent;color:#94a3b8;transition:all 0.15s;$vhdBtnActive">
      &#128187; VHD Node Images
    </button>
    <button id="aks-cve-btn-containers" onclick="aksCveShowTab('containers')"
      style="padding:10px 20px;border:none;border-radius:6px 6px 0 0;font-size:13px;font-weight:600;cursor:pointer;background:transparent;color:#94a3b8;transition:all 0.15s;$contBtnActive">
      &#128230; AKS Containers
    </button>
  </div>

  <!-- ═══════════════════════ SEARCH TAB ═══════════════════════════ -->
  <div id="aks-cve-panel-search" style="$searchTabStyle">
    <div style="max-width:680px;margin:0 auto 32px;">
      <div style="text-align:center;margin-bottom:24px;">
        <div style="font-size:40px;margin-bottom:8px;">&#128269;</div>
        <h2 style="margin:0 0 6px;font-size:20px;font-weight:700;color:#e2e8f0;">CVE Lookup</h2>
        <p style="margin:0;font-size:13px;color:#94a3b8;">Instantly check any CVE across all $versionCount AKS container releases and the last 3 VHD builds per node OS type.</p>
      </div>
      <div style="display:flex;gap:8px;align-items:center;margin-bottom:20px;">
        <input id="aks-cve-search-input" type="text" placeholder="Enter a CVE ID, e.g. CVE-2025-23266" spellcheck="false" autofocus
          style="flex:1;padding:12px 16px;border-radius:8px;border:1px solid rgba(255,255,255,0.2);background:rgba(255,255,255,0.08);color:inherit;font-size:14px;outline:none;" />
        <button id="aks-cve-search-btn" onclick="aksCveSearch()"
          style="padding:12px 22px;border-radius:8px;border:none;background:#4f46e5;color:#fff;font-size:14px;font-weight:700;cursor:pointer;white-space:nowrap;">
          Search
        </button>
      </div>
      <div id="aks-cve-search-results" style="font-size:13px;color:#94a3b8;"></div>
    </div>
  </div><!-- /search panel -->

  <!-- ═══════════════════════════ VHD TAB ════════════════════════════ -->
  <div id="aks-cve-panel-vhd" style="$vhdTabStyle">

    $vhdUnavailHtml

    <div style="background:rgba(255,255,255,0.04);border:1px solid rgba(255,255,255,0.1);border-radius:8px;overflow:hidden;margin-bottom:20px;">

      <!-- Filter bar -->
      <div style="padding:12px 16px;background:rgba(255,255,255,0.06);border-bottom:1px solid rgba(255,255,255,0.1);display:flex;gap:16px;flex-wrap:wrap;align-items:center;">
        <div style="display:flex;gap:8px;align-items:center;">
          <label style="font-size:12px;font-weight:600;color:#9ca3af;white-space:nowrap;">Node OS</label>
          <div style="position:relative;">
            <select id="aks-vhd-os-select"
              style="padding:6px 28px 6px 10px;border-radius:6px;border:1px solid rgba(255,255,255,0.2);background:#1e293b;color:#e2e8f0;font-size:13px;font-weight:600;cursor:pointer;appearance:none;-webkit-appearance:none;min-width:210px;">
            </select>
            <span style="position:absolute;right:8px;top:50%;transform:translateY(-50%);pointer-events:none;color:#94a3b8;font-size:10px;">&#9660;</span>
          </div>
        </div>
        <div style="display:flex;gap:8px;align-items:center;">
          <label style="font-size:12px;font-weight:600;color:#9ca3af;white-space:nowrap;">Version</label>
          <div style="position:relative;">
            <select id="aks-vhd-ver-select"
              style="padding:6px 28px 6px 10px;border-radius:6px;border:1px solid rgba(255,255,255,0.2);background:#1e293b;color:#e2e8f0;font-size:13px;cursor:pointer;appearance:none;-webkit-appearance:none;min-width:160px;">
            </select>
            <span style="position:absolute;right:8px;top:50%;transform:translateY(-50%);pointer-events:none;color:#94a3b8;font-size:10px;">&#9660;</span>
          </div>
        </div>
        <div style="display:flex;gap:16px;margin-left:auto;flex-wrap:wrap;align-items:center;">
          <span style="font-size:12px;color:#94a3b8;">Active CVEs:&nbsp;<strong id="aks-vhd-stat-active" style="color:#f87171;">&#8212;</strong></span>
          <span style="font-size:12px;color:#94a3b8;">Mitigated:&nbsp;<strong id="aks-vhd-stat-mitigated" style="color:#34d399;">&#8212;</strong></span>
          <span style="font-size:12px;color:#94a3b8;">Scan:&nbsp;<strong id="aks-vhd-stat-date" style="color:#e2e8f0;">&#8212;</strong></span>
        </div>
      </div>

      <!-- Package table -->
      <div style="overflow-x:auto;">
        <table style="width:100%;border-collapse:collapse;font-size:13px;">
          <thead>
            <tr style="background:rgba(255,255,255,0.05);">
              <th style="padding:8px 10px;color:#9ca3af;font-weight:600;text-align:left;">Package</th>
              <th style="padding:8px 10px;color:#9ca3af;font-weight:600;text-align:left;">Version</th>
              <th style="padding:8px 10px;color:#9ca3af;font-weight:600;text-align:center;">Active CVEs</th>
              <th style="padding:8px 10px;color:#9ca3af;font-weight:600;text-align:center;">Mitigated</th>
            </tr>
          </thead>
          <tbody id="aks-vhd-pkg-tbody">
            <tr><td colspan="4" style="padding:20px;text-align:center;color:#6b7280;">Select a node OS above to view package CVE data.</td></tr>
          </tbody>
        </table>
      </div>
    </div>

  </div><!-- /vhd panel -->

  <!-- ═══════════════════════ CONTAINER TAB ══════════════════════════ -->
  <div id="aks-cve-panel-containers" style="$containerTabStyle">

    <div style="background:rgba(255,255,255,0.04);border:1px solid rgba(255,255,255,0.1);border-radius:8px;overflow:hidden;margin-bottom:20px;">

      <!-- Filter bar -->
      <div style="padding:12px 16px;background:rgba(255,255,255,0.06);border-bottom:1px solid rgba(255,255,255,0.1);display:flex;gap:16px;flex-wrap:wrap;align-items:center;">
        <div style="display:flex;gap:8px;align-items:center;">
          <label style="font-size:12px;font-weight:600;color:#9ca3af;white-space:nowrap;">AKS Release</label>
          <div style="position:relative;">
            <select id="aks-cve-version-select"
              style="padding:6px 28px 6px 10px;border-radius:6px;border:1px solid rgba(255,255,255,0.2);background:#1e293b;color:#e2e8f0;font-size:13px;font-weight:600;cursor:pointer;appearance:none;-webkit-appearance:none;min-width:180px;">
              $versionOptions
            </select>
            <span style="position:absolute;right:8px;top:50%;transform:translateY(-50%);pointer-events:none;color:#94a3b8;font-size:10px;">&#9660;</span>
          </div>
        </div>
        <div style="display:flex;gap:16px;margin-left:auto;flex-wrap:wrap;align-items:center;">
          <span style="font-size:12px;color:#94a3b8;">Active CVEs:&nbsp;<strong id="aks-cve-active-count" style="color:#f87171;">$initActive</strong></span>
          <span style="font-size:12px;color:#94a3b8;">Mitigated:&nbsp;<strong id="aks-cve-mitigated-count" style="color:#34d399;">$initMitigated</strong></span>
          <span style="font-size:12px;color:#94a3b8;">Affected:&nbsp;<strong id="aks-cve-containers-count" style="color:#f59e0b;">$initAffected</strong>&nbsp;<span id="aks-cve-containers-sub" style="color:#6b7280;">of $initTotal</span></span>
          <span id="aks-cve-report-date" style="font-size:12px;color:#6b7280;">$initDate</span>
        </div>
      </div>

      <!-- Top containers table -->
      <div style="overflow-x:auto;">
        <table style="width:100%;border-collapse:collapse;">
          <thead>
            <tr style="background:rgba(255,255,255,0.05);">
              <th style="padding:8px 10px;font-size:12px;font-weight:600;color:#9ca3af;text-align:left;">Namespace</th>
              <th style="padding:8px 10px;font-size:12px;font-weight:600;color:#9ca3af;text-align:left;">Container&nbsp;<span style="display:inline-block;padding:1px 5px;background:rgba(99,102,241,0.2);color:#a5b4fc;border-radius:3px;font-size:10px;">k8s</span>&nbsp;= core</th>
              <th style="padding:8px 10px;font-size:12px;font-weight:600;color:#9ca3af;text-align:center;">Active CVEs</th>
              <th style="padding:8px 10px;font-size:12px;font-weight:600;color:#9ca3af;text-align:center;">Mitigated</th>
            </tr>
          </thead>
          <tbody id="aks-cve-top-tbody">
$initTopRowsHtml
          </tbody>
        </table>
      </div>
    </div>

  </div><!-- /containers panel -->

  <!-- search input/results live in #aks-cve-panel-search above -->

  <!-- Explorer link -->
  <div style="display:flex;justify-content:flex-end;padding:4px 0;">
    <a href="$cveExplorerUrl" target="_blank" rel="noopener"
       style="display:inline-block;padding:10px 18px;font-size:13px;font-weight:600;text-decoration:none;border-radius:6px;background:#2563eb;color:#fff;">
      &#128269; Open Interactive CVE Explorer
    </a>
  </div>

  <script>
  (function() {
    // All CVE data is pre-embedded — no API calls needed from the browser (avoids CORS).
    var CDATA = {versions:$jsVersionsArr,byVersion:$byVersionJson};
    var VDATA = {images:$jsVhdImagesArr,byImage:$vhdByImageJson};

    function esc(s) {
      return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
    }

    // ── Tab switching ──────────────────────────────────────────────────
    var TAB_IDS = ['search','containers','vhd'];
    var TAB_COLORS = {
      search:     {active:'border-bottom:2px solid #818cf8;color:#818cf8;background:rgba(99,102,241,0.08);',  inactive:'border-bottom:none;color:#94a3b8;background:transparent;'},
      containers: {active:'border-bottom:2px solid #93c5fd;color:#93c5fd;background:rgba(59,130,246,0.08);', inactive:'border-bottom:none;color:#94a3b8;background:transparent;'},
      vhd:        {active:'border-bottom:2px solid #f59e0b;color:#f59e0b;background:rgba(245,158,11,0.08);',  inactive:'border-bottom:none;color:#94a3b8;background:transparent;'}
    };
    window.aksCveShowTab = function(tab) {
      TAB_IDS.forEach(function(t) {
        var btn   = document.getElementById('aks-cve-btn-'      + t);
        var panel = document.getElementById('aks-cve-panel-'    + t);
        if (!btn || !panel) return;
        var isActive = (t === tab);
        panel.style.display = isActive ? 'block' : 'none';
        var style = isActive ? TAB_COLORS[t].active : TAB_COLORS[t].inactive;
        btn.setAttribute('style',
          'padding:10px 20px;border:none;border-radius:6px 6px 0 0;font-size:13px;font-weight:600;cursor:pointer;transition:all 0.15s;' + style);
      });
    };

    // ── VHD OS type / version cascade ─────────────────────────────────
    function renderVhdImage(imgName) {
      var d = VDATA.byImage[imgName];
      if (!d) return;
      var sa = document.getElementById('aks-vhd-stat-active');
      var sm = document.getElementById('aks-vhd-stat-mitigated');
      var sd = document.getElementById('aks-vhd-stat-date');
      if (sa) sa.textContent = d.active;
      if (sm) sm.textContent = d.mitigated;
      if (sd) sd.textContent = d.date;
      var html = '';
      (d.top || []).forEach(function(row) {
        var mitCell = row[3] > 0
          ? '<td style="color:#34d399;font-weight:600;text-align:center;">&#9989; ' + row[3] + '</td>'
          : '<td style="color:#6b7280;text-align:center;">&mdash;</td>';
        html += '<tr style="border-top:1px solid rgba(255,255,255,0.06);">'
          + '<td style="padding:6px 10px;font-size:13px;font-weight:500;">' + esc(row[0]) + '</td>'
          + '<td style="padding:6px 10px;font-size:12px;color:#94a3b8;">'   + esc(row[1]) + '</td>'
          + '<td style="padding:6px 10px;font-size:13px;font-weight:700;color:#f87171;text-align:center;">' + row[2] + '</td>'
          + mitCell + '</tr>';
      });
      document.getElementById('aks-vhd-pkg-tbody').innerHTML = html ||
        '<tr><td colspan="4" style="padding:12px;text-align:center;color:#6b7280;">No package CVE data for this image.</td></tr>';
    }
    (function() {
      var osSel  = document.getElementById('aks-vhd-os-select');
      var verSel = document.getElementById('aks-vhd-ver-select');
      if (!osSel || !verSel) return;
      // Build { osType -> [img keys sorted newest-first] } from VDATA.images
      var osToImgs = {};
      (VDATA.images || []).forEach(function(img) {
        var sl = img.indexOf('/');
        if (sl < 0) return;
        var os = img.substring(0, sl);
        if (!osToImgs[os]) osToImgs[os] = [];
        osToImgs[os].push(img);
      });
      Object.keys(osToImgs).forEach(function(os) {
        osToImgs[os].sort(function(a, b) { return a < b ? 1 : -1; }); // newest first
      });
      var osTypes = Object.keys(osToImgs).sort();
      osTypes.forEach(function(os) {
        var opt = document.createElement('option');
        opt.value = os; opt.textContent = os;
        osSel.appendChild(opt);
      });
      function populateVersions(os) {
        verSel.innerHTML = '';
        (osToImgs[os] || []).forEach(function(imgKey, idx) {
          var sl  = imgKey.indexOf('/');
          var ver = sl >= 0 ? imgKey.substring(sl + 1) : imgKey;
          var opt = document.createElement('option');
          opt.value = imgKey;
          opt.textContent = ver + (idx === 0 ? ' (latest)' : '');
          verSel.appendChild(opt);
        });
        if (verSel.options.length) renderVhdImage(verSel.value);
      }
      osSel.addEventListener('change', function() { populateVersions(osSel.value); });
      verSel.addEventListener('change', function() { renderVhdImage(verSel.value); });
      if (osTypes.length) populateVersions(osTypes[0]);
    })();

    // ── Container version selector ─────────────────────────────────────
    var vsel = document.getElementById('aks-cve-version-select');
    function renderVersion(ver) {
      var d = CDATA.byVersion[ver];
      if (!d) return;
      document.getElementById('aks-cve-active-count').textContent     = d.active;
      document.getElementById('aks-cve-mitigated-count').textContent  = d.mitigated;
      document.getElementById('aks-cve-containers-count').textContent = d.affected;
      document.getElementById('aks-cve-containers-sub').textContent   = 'of ' + d.total;
      document.getElementById('aks-cve-report-date').textContent      = d.date;
      var html = '';
      (d.top || []).forEach(function(row) {
        var mitCell = row[3] > 0
          ? '<td style="color:#34d399;font-weight:600;text-align:center;">&#9989; ' + row[3] + '</td>'
          : '<td style="color:#6b7280;text-align:center;">&mdash;</td>';
        var k8sTag = row[0] === 'kube-system'
          ? '<span style="display:inline-block;padding:1px 5px;background:rgba(99,102,241,0.2);color:#a5b4fc;border-radius:3px;font-size:10px;margin-left:4px;">k8s</span>'
          : '';
        html += '<tr style="border-top:1px solid rgba(255,255,255,0.06);">'
          + '<td style="padding:6px 10px;font-size:13px;color:#94a3b8;">'  + esc(row[0]) + '</td>'
          + '<td style="padding:6px 10px;font-size:13px;font-weight:500;">' + esc(row[1]) + k8sTag + '</td>'
          + '<td style="padding:6px 10px;font-size:13px;font-weight:700;color:#f87171;text-align:center;">' + row[2] + '</td>'
          + mitCell + '</tr>';
      });
      document.getElementById('aks-cve-top-tbody').innerHTML = html ||
        '<tr><td colspan="4" style="padding:12px;text-align:center;color:#6b7280;">No containers with active CVEs.</td></tr>';
    }
    if (vsel) vsel.addEventListener('change', function() { renderVersion(vsel.value); });

    // ── Unified CVE Search: searches container + VHD data ─────────────
    window.aksCveSearch = function() {
      var rawId = (document.getElementById('aks-cve-search-input').value || '').trim().toUpperCase();
      var outEl = document.getElementById('aks-cve-search-results');

      if (!rawId) {
        outEl.innerHTML = '<span style="color:#f59e0b;">&#9888;&#65039; Please enter a CVE ID.</span>';
        return;
      }

      // Search container releases
      var allVersions = CDATA.versions;
      var hits = {};
      allVersions.forEach(function(ver) {
        var entry = CDATA.byVersion[ver] && CDATA.byVersion[ver].cves && CDATA.byVersion[ver].cves[rawId];
        if (entry && (entry.a.length > 0 || entry.m.length > 0)) hits[ver] = entry;
      });

      // Search VHD images
      var vhdHits = {};
      (VDATA.images || []).forEach(function(img) {
        var entry = VDATA.byImage[img] && VDATA.byImage[img].cves && VDATA.byImage[img].cves[rawId];
        if (entry && (entry.a.length > 0 || entry.m.length > 0)) vhdHits[img] = entry;
      });

      var noContainerHits = Object.keys(hits).length === 0;
      var noVhdHits       = Object.keys(vhdHits).length === 0;
      var vhdImagesLoaded = (VDATA.images || []).length > 0;

      // Only short-circuit if there's genuinely nothing to show at all
      if (noContainerHits && noVhdHits && !vhdImagesLoaded) {
        outEl.innerHTML = '<div style="margin-top:8px;padding:12px 16px;background:rgba(16,185,129,0.1);border:1px solid rgba(52,211,153,0.25);border-radius:8px;color:#34d399;font-size:13px;">'
          + '&#9989; <strong>' + esc(rawId) + '</strong> was not found in any of the '
          + allVersions.length + ' AKS container releases or any VHD node images. It may not affect AKS.</div>';
        return;
      }

      var out = '';

      // VHD node image table — always render when VHD data is loaded
      if (vhdImagesLoaded) {
        var vhdImgNames   = Object.keys(vhdHits);
        var vhdActiveImgs = vhdImgNames.filter(function(i) { return vhdHits[i].a.length > 0; });
        var hasActive     = vhdActiveImgs.length > 0;
        var totalImgs     = (VDATA.images || []).length;

        var sumBg  = hasActive ? 'rgba(220,38,38,0.12)' : 'rgba(16,185,129,0.1)';
        var sumBd  = hasActive ? 'rgba(248,113,113,0.3)' : 'rgba(52,211,153,0.25)';
        var sumIco = hasActive ? '&#x1F534;' : '&#x2705;';
        var sumTxt = noVhdHits
          ? '<strong style="color:#34d399;">' + esc(rawId) + '</strong> was <strong style="color:#34d399;">not found</strong> in any of the <strong>' + totalImgs + '</strong> VHD node image builds scanned.'
          : hasActive
            ? '<strong style="color:#f87171;">' + esc(rawId) + '</strong> is <strong style="color:#f87171;">still active</strong> in <strong>' + vhdActiveImgs.length + '</strong> of ' + vhdImgNames.length + ' VHD node image(s) scanned.'
            : '<strong style="color:#34d399;">' + esc(rawId) + '</strong> is <strong style="color:#34d399;">mitigated</strong> in all ' + vhdImgNames.length + ' VHD node image(s) where it was found.';

        var bannerRadius = noVhdHits ? '8px' : '8px 8px 0 0';
        out += '<div style="margin-bottom:16px;">'
          + '<div style="padding:10px 14px;background:' + sumBg + ';border:1px solid ' + sumBd + ';border-radius:' + bannerRadius + ';font-size:13px;">'
          + '<span style="font-size:13px;font-weight:700;color:#f59e0b;margin-right:10px;">&#128187; VHD Node Images</span>'
          + sumIco + ' ' + sumTxt
          + '</div>';
        if (!noVhdHits) {
          out += '<div style="overflow-x:auto;border:1px solid rgba(255,255,255,0.1);border-top:none;border-radius:0 0 8px 8px;">'
            + '<table style="width:100%;border-collapse:collapse;font-size:13px;">'
            + '<thead><tr style="background:rgba(255,255,255,0.05);">'
            + '<th style="padding:8px 12px;color:#9ca3af;font-weight:600;text-align:left;white-space:nowrap;">Node OS</th>'
            + '<th style="padding:8px 12px;color:#9ca3af;font-weight:600;text-align:left;white-space:nowrap;">VHD Version</th>'
            + '<th style="padding:8px 12px;color:#9ca3af;font-weight:600;text-align:center;white-space:nowrap;">Status</th>'
            + '<th style="padding:8px 12px;color:#9ca3af;font-weight:600;text-align:left;">Affected packages</th>'
            + '</tr></thead><tbody>';

        // Sort: active first, then newest version first within same status
        var sortedVhdImgs = vhdImgNames.slice().sort(function(a, b) {
          var aAct = vhdHits[a].a.length > 0 ? 0 : 1;
          var bAct = vhdHits[b].a.length > 0 ? 0 : 1;
          if (aAct !== bAct) return aAct - bAct;
          // newest version first: sort full img key descending
          return a < b ? 1 : -1;
        });

        sortedVhdImgs.forEach(function(img) {
          var entry  = vhdHits[img];
          var sl     = img.indexOf('/');
          var osName = sl >= 0 ? img.substring(0, sl) : img;
          var ver    = sl >= 0 ? img.substring(sl + 1) : '—';
          var isAct  = entry.a.length > 0;
          var rowBg  = isAct ? 'background:rgba(220,38,38,0.05);' : '';
          var badge  = isAct
            ? '<span style="display:inline-block;padding:2px 10px;background:rgba(220,38,38,0.2);color:#f87171;border-radius:4px;font-weight:700;font-size:12px;white-space:nowrap;">&#x1F534; Active</span>'
            : '<span style="display:inline-block;padding:2px 10px;background:rgba(16,185,129,0.15);color:#34d399;border-radius:4px;font-weight:700;font-size:12px;white-space:nowrap;">&#x2705; Mitigated</span>';
          var pkgs = (isAct ? entry.a : entry.m).map(function(p) {
            var pkgBg = isAct ? 'rgba(248,113,113,0.12)' : 'rgba(52,211,153,0.1)';
            var pkgCl = isAct ? '#fca5a5' : '#6ee7b7';
            return '<code style="background:' + pkgBg + ';color:' + pkgCl + ';padding:1px 6px;border-radius:3px;font-size:11px;display:inline-block;margin:1px;">' + esc(p) + '</code>';
          }).join('');
          out += '<tr style="border-top:1px solid rgba(255,255,255,0.06);' + rowBg + '">'
            + '<td style="padding:8px 12px;font-weight:700;color:#e2e8f0;white-space:nowrap;">' + esc(osName) + '</td>'
            + '<td style="padding:8px 12px;font-family:monospace;font-size:12px;color:#93c5fd;white-space:nowrap;">' + esc(ver) + '</td>'
            + '<td style="padding:8px 12px;text-align:center;">' + badge + '</td>'
            + '<td style="padding:8px 12px;">' + (pkgs || '<span style="color:#6b7280;">&mdash;</span>') + '</td>'
            + '</tr>';
        });

          out += '</tbody></table></div>';
        }
        out += '</div>';
      }

      // Container release history
      if (!noContainerHits) {
        var latestVer    = allVersions[allVersions.length - 1];
        var activeLatest = hits[latestVer] && hits[latestVer].a.length > 0;
        var firstFixed = null, lastActive = null, activeRels = 0;
        for (var i = 0; i < allVersions.length; i++) {
          var h = hits[allVersions[i]];
          if (h) {
            if (h.m.length > 0 && !firstFixed) firstFixed = allVersions[i];
            if (h.a.length > 0) { lastActive = allVersions[i]; activeRels++; }
          }
        }

        var sbg  = activeLatest ? 'rgba(220,38,38,0.12)' : 'rgba(16,185,129,0.1)';
        var sbd  = activeLatest ? 'rgba(248,113,113,0.3)' : 'rgba(52,211,153,0.25)';
        var sico = activeLatest ? '&#x1F534;' : '&#x2705;';
        var stxt = activeLatest
          ? '<strong style="color:#f87171;">' + esc(rawId) + '</strong> is <strong style="color:#f87171;">still unpatched</strong> in the latest container release (<strong>' + esc(latestVer) + '</strong>).'
          : '<strong style="color:#34d399;">' + esc(rawId) + '</strong> is <strong style="color:#34d399;">not active</strong> in the latest container release (<strong>' + esc(latestVer) + '</strong>).';

        var pills = '';
        if (firstFixed) pills += '<span style="display:inline-block;padding:3px 10px;margin:2px;background:rgba(16,185,129,0.15);color:#34d399;border-radius:4px;font-size:12px;font-weight:600;">&#x1F527; First fixed: ' + esc(firstFixed) + '</span>';
        if (lastActive)  pills += '<span style="display:inline-block;padding:3px 10px;margin:2px;background:rgba(220,38,38,0.12);color:#f87171;border-radius:4px;font-size:12px;font-weight:600;">&#x1F534; Last active: ' + esc(lastActive) + '</span>';
        pills += '<span style="display:inline-block;padding:3px 10px;margin:2px;background:rgba(255,255,255,0.08);color:#94a3b8;border-radius:4px;font-size:12px;">Affected ' + activeRels + ' release' + (activeRels === 1 ? '' : 's') + '</span>';

        out += '<div style="margin-bottom:12px;padding:12px 16px;background:' + sbg + ';border:1px solid ' + sbd + ';border-radius:8px;">'
          + '<div style="font-size:13px;font-weight:600;color:#93c5fd;margin-bottom:6px;">&#128230; Container Releases</div>'
          + '<div style="font-size:14px;margin-bottom:8px;">' + sico + ' ' + stxt + '</div>'
          + '<div>' + pills + '</div></div>';

        out += '<div style="overflow-x:auto;">'
          + '<div style="margin-bottom:6px;font-size:12px;color:#94a3b8;">Container release history for <strong style="color:#60a5fa;">' + esc(rawId) + '</strong> &mdash; newest first, only affected releases shown:</div>'
          + '<table style="width:100%;border-collapse:collapse;font-size:13px;">'
          + '<thead><tr style="background:rgba(255,255,255,0.05);">'
          + '<th style="padding:7px 10px;color:#9ca3af;font-weight:600;text-align:left;">Version</th>'
          + '<th style="padding:7px 10px;color:#9ca3af;font-weight:600;text-align:center;">Status</th>'
          + '<th style="padding:7px 10px;color:#9ca3af;font-weight:600;text-align:left;">Affected containers</th>'
          + '<th style="padding:7px 10px;color:#9ca3af;font-weight:600;text-align:left;">Fixed in this version</th>'
          + '</tr></thead><tbody>';

        allVersions.slice().reverse().forEach(function(ver) {
          var h = hits[ver];
          if (!h) return;
          var isAct  = h.a.length > 0;
          var badge  = isAct
            ? '<span style="display:inline-block;padding:2px 8px;background:rgba(220,38,38,0.2);color:#f87171;border-radius:4px;font-weight:600;font-size:12px;">&#x1F534; Active</span>'
            : '<span style="display:inline-block;padding:2px 8px;background:rgba(16,185,129,0.2);color:#34d399;border-radius:4px;font-weight:600;font-size:12px;">&#x2705; Fixed</span>';
          var aNames = h.a.map(function(c) {
            return '<code style="background:rgba(255,255,255,0.08);padding:1px 5px;border-radius:3px;font-size:11px;display:inline-block;margin:1px;">' + esc(c) + '</code>';
          }).join('');
          var mNames = h.m.map(function(c) {
            return '<code style="background:rgba(16,185,129,0.12);padding:1px 5px;border-radius:3px;font-size:11px;display:inline-block;margin:1px;color:#34d399;">' + esc(c) + '</code>';
          }).join('');
          out += '<tr style="border-top:1px solid rgba(255,255,255,0.06);' + (isAct ? 'background:rgba(220,38,38,0.05);' : '') + '">'
            + '<td style="padding:7px 10px;font-weight:600;color:#e2e8f0;white-space:nowrap;">' + esc(ver) + '</td>'
            + '<td style="padding:7px 10px;text-align:center;">' + badge + '</td>'
            + '<td style="padding:7px 10px;">' + (aNames || '<span style="color:#6b7280;">&mdash;</span>') + '</td>'
            + '<td style="padding:7px 10px;">' + (mNames || '<span style="color:#6b7280;">&mdash;</span>') + '</td>'
            + '</tr>';
        });

        out += '</tbody></table></div>';
      }

      outEl.innerHTML = out;
    };

    document.getElementById('aks-cve-search-input').addEventListener('keydown', function(e) {
      if (e.key === 'Enter') window.aksCveSearch();
    });
  })();
  </script>

</div>
"@.Trim()
  }
  catch {
    Write-Warning "CVE API fetch failed: $_"
    return '<p style="color:#94a3b8;">CVE data temporarily unavailable. Visit <a href="https://cve-api.prod-aks.azure.com/viewer/index.html" target="_blank" rel="noopener">cve-api.prod-aks.azure.com</a> for the full interactive explorer.</p>'
  }
}
# =========================
# MAIN EXECUTION - COLLECT DATA FROM ALL REPOSITORIES
# =========================

# Initialize AI if provider is configured
if ($PreferProvider) {
  $PSAIReady = Initialize-AIProvider -Provider $PreferProvider
  if ($PSAIReady) { Log "AI provider ($PreferProvider) initialized." }
} else {
  Log "No AI provider configured - running without AI summaries."
}

# Collect PR and commit data from all repositories
Log "Collecting GitHub data since $SINCE_ISO from $($Repositories.Count) repositories..."

$allFiles = @()

if ($script:CveOnly) {
  Log "CVE_ONLY mode — skipping GitHub/docs/AI fetch."
  Log "Fetching AKS CVE vulnerability data (CVE-only run)..."
  $cveTabHtml = Get-AksCveTabHtml
  # NOTE: The section wrapper below must stay in sync with the full-page CVE section
  # generated further below (search for CVE_SECTION_START in the main here-string).
  $cveSectionHtml = @"
    <!-- CVE_SECTION_START -->
    <div class="aks-tab-panel" id="aks-tab-cve">
      <h2>AKS CVE Security</h2>
      <p>CVE security data for AKS container images and VHD node images, sourced from the <strong>AKS Vulnerability Data API</strong> (Public Preview). Search any CVE ID instantly, or browse active CVEs by container release or node image.</p>
      $cveTabHtml
    </div>
    <!-- CVE_SECTION_END -->
"@
  [pscustomobject]@{
    cve_only         = $true
    cve_section_html = $cveSectionHtml
  } | ConvertTo-Json -Depth 3
  Log "CVE-only run complete."
  return
}

foreach ($repoConfig in $Repositories) {
  $Owner = $repoConfig.Owner
  $Repo = $repoConfig.Repo
  $PathFilter = $repoConfig.PathFilter
  $DisplayName = $repoConfig.DisplayName
  
  Log "Processing $DisplayName repository: $Owner/$Repo"
  Log "  Path filter: $PathFilter"

  # Get recent pull requests for this repository
  $prs = @()
  $page = 1
  do {
    $uri = "https://api.github.com/repos/$Owner/$Repo/pulls?state=closed&sort=updated&direction=desc&per_page=100&page=$page"
    $response = Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
    $relevantPRs = $response | Where-Object { 
      $_.updated_at -gt $SINCE_ISO -and $_.merged_at 
    }
    $prs += $relevantPRs
    $page++
  } while ($response.Count -eq 100 -and $relevantPRs.Count -gt 0)

  Log "  Found $($prs.Count) recently updated PRs"

  # Get recent commits directly from main branch for this repository
  $commits = @()
  $page = 1
  do {
    $uri = "https://api.github.com/repos/$Owner/$Repo/commits?sha=main&since=$SINCE_ISO&per_page=100&page=$page"
    $response = Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
    $commits += $response
    $page++
  } while ($response.Count -eq 100)

  Log "  Found $($commits.Count) recent commits"

  # Process PRs for this repository
  foreach ($pr in $prs) {
    try {
      $files = Get-PullRequestFiles -prNumber $pr.number -Owner $Owner -Repo $Repo
      foreach ($file in $files) {
        # Apply path filter - only include files matching the filter
        if ($file.filename -notmatch $PathFilter) { continue }
        # Only include markdown files for documentation updates
        if ($file.filename -notmatch '\.md$') { continue }
        
        $allFiles += [PSCustomObject]@{
          filename = $file.filename
          status = $file.status
          additions = $file.additions
          deletions = $file.deletions
          patch = $file.patch
          pr_number = $pr.number
          pr_title = $pr.title
          pr_url = $pr.html_url
          sha = $pr.merge_commit_sha
          date = $pr.merged_at
          source = "PR"
          repo_owner = $Owner
          repo_name = $Repo
          repo_display = $DisplayName
        }
      }
    }
    catch {
      Write-Warning "Failed to get files for PR #$($pr.number) in $Owner/$Repo`: $_"
    }
  }

  # Process commits that aren't from PRs for this repository
  foreach ($commit in $commits) {
    # Skip commits that are already covered by PRs
    $existingCommit = $allFiles | Where-Object { $_.sha -eq $commit.sha }
    if ($existingCommit) { continue }
    
    try {
      $commitDetail = Get-CommitFiles -sha $commit.sha -Owner $Owner -Repo $Repo
      foreach ($file in $commitDetail.files) {
        # Apply path filter - only include files matching the filter
        if ($file.filename -notmatch $PathFilter) { continue }
        # Only include markdown files for documentation updates
        if ($file.filename -notmatch '\.md$') { continue }
        
        $allFiles += [PSCustomObject]@{
          filename = $file.filename
          status = $file.status
          additions = $file.additions
          deletions = $file.deletions
          patch = $file.patch
          pr_number = $null
          pr_title = $commit.commit.message.Split("`n")[0]
          pr_url = $commit.html_url
          sha = $commit.sha
          date = $commit.commit.committer.date
          source = "Commit"
          repo_owner = $Owner
          repo_name = $Repo
          repo_display = $DisplayName
        }
      }
    }
    catch {
      Write-Warning "Failed to get files for commit $($commit.sha) in $Owner/$Repo`: $_"
    }
  }
  
  Log "  Collected files from $DisplayName repository"
}

Log "Collected $($allFiles.Count) file changes"

# Group files by filename for processing
$groups = @{}
foreach ($file in $allFiles) {
  if (-not $groups[$file.filename]) {
    $groups[$file.filename] = @()
  }
  $groups[$file.filename] += $file
}

Log "Grouped into $($groups.Keys.Count) unique files"

# =========================
# AI INPUT PREPARATION
# =========================

# ===== Build AI input with enhanced pre-filtered data =====
$TmpRoot = $env:RUNNER_TEMP; if (-not $TmpRoot) { $TmpRoot = [System.IO.Path]::GetTempPath() }
$aiJsonPath = Join-Path $TmpRoot ("aks-doc-pr-groups-{0}.json" -f (Get-Date -Format 'yyyyMMddHHmmss'))

$aiInput = [pscustomobject]@{
  since  = $SINCE_ISO
  groups = @(
    foreach ($k in $groups.Keys) {
      $items = $groups[$k]
      $adds = ($items | Measure-Object -Sum -Property additions).Sum
      $dels = ($items | Measure-Object -Sum -Property deletions).Sum
      $statuses = ($items.status | Where-Object { $_ } | Select-Object -Unique)
      $subjects = ($items.pr_title | Where-Object { $_ } | Select-Object -Unique)

      $lines = @()
      foreach ($it in $items) { if ($it.patch) { $lines += (($it.patch -split "`n") | Where-Object { $_ -match '^[\+\-]' }) } }
      $patchSample = ($lines | Select-Object -First 1200) -join "`n"

      [pscustomobject]@{
        file            = $k
        subjects        = $subjects
        total_additions = $adds
        total_deletions = $dels
        commits_count   = $items.Count
        statuses        = $statuses
        patch_sample    = $patchSample
      }
    }
  )
}
$aiInput | ConvertTo-Json -Depth 6 | Set-Content -Path $aiJsonPath -Encoding UTF8
Log "AI input prepared: $aiJsonPath"

# Apply minimal pre-filtering before sending to AI - let AI do the heavy lifting
Log "Applying minimal pre-filtering (only obvious trivial cases)..."
Log "Total file groups to process: $($groups.Keys.Count)"
$filteredGroups = @{}
$skippedCount = 0

foreach ($k in $groups.Keys) {
  $items = $groups[$k]
  $statuses = ($items.status | Where-Object { $_ } | Select-Object -Unique)
  
  Log "Processing file: $k, statuses: $($statuses -join ', ')"
  
  # Always keep newly added files
  if ($statuses -contains 'added') {
    $filteredGroups[$k] = $items
    Log "Kept new file: $k"
    continue
  }
  
  # For modified files, apply minimal pre-filtering (let AI handle the rest)
  if ($statuses -contains 'modified') {
    $adds = ($items | Measure-Object -Sum -Property additions).Sum
    $dels = ($items | Measure-Object -Sum -Property deletions).Sum
    $subjects = ($items.pr_title | Where-Object { $_ } | Select-Object -Unique)
    
    Log "Modified file $k - +$adds -$dels lines, subjects: $($subjects -join ', ')"
    
    # Build combined patch sample
    $lines = @()
    foreach ($it in $items) { 
      if ($it.patch) { 
        $lines += (($it.patch -split "`n") | Where-Object { $_ -match '^[\+\-]' }) 
      } 
    }
    $patchSample = ($lines | Select-Object -First 1200) -join "`n"
    
    # Apply minimal trivial change detection (single lines and pure metadata only)
    if (Is-TrivialChange -PatchSample $patchSample -Subjects $subjects -TotalLines ($adds + $dels)) {
      $skippedCount++
      Log "Skipped obvious trivial change: $k (subjects: $($subjects -join ', '))"
      continue
    }

    # Apply very permissive filtering - let AI handle nuanced decisions
    if (-not (Should-ForceKeepModified -Adds $adds -Dels $dels -Signals $null -PatchSample $patchSample -Subjects $subjects)) {
      $skippedCount++
      Log "Skipped empty change: $k"
      continue
    }
    
    $filteredGroups[$k] = $items
    Log "Kept modified file: $k"
  } else {
    Log "Unknown status for file $k - $($statuses -join ', ') - keeping"
    $filteredGroups[$k] = $items
  }
}

Log "Minimal pre-filtering complete: kept $($filteredGroups.Keys.Count) files, skipped $skippedCount obvious trivial changes"

# Get AI summaries using enhanced filtering
$aiVerdicts = @{ ordered = @(); byFile = @{} }
if ($PreferProvider) { 
  $aiVerdicts = Get-PerFileSummariesViaAssistant -JsonPath $aiJsonPath 
}
else { 
  Log "AI disabled (no provider env configured)." 
}

# ---- Fallback: force-keep any "added" files that AI missed
$aiKeptSet = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($o in @($aiVerdicts.ordered)) { [void]$aiKeptSet.Add([string]$o.file) }

$forced = New-Object System.Collections.Generic.List[object]
foreach ($k in $filteredGroups.Keys) {
  $statuses = ($filteredGroups[$k].status | Where-Object { $_ } | Select-Object -Unique)
  if ($statuses -contains 'added' -and -not $aiKeptSet.Contains($k)) {
    # Get repository info from the first file entry
    $firstItem = $filteredGroups[$k][0]
    $repoOwner = $firstItem.repo_owner
    $repoName = $firstItem.repo_name
    
    $forcedSummary = Summarize-NewMarkdown -path $k -Owner $repoOwner -Repo $repoName
    $forced.Add([pscustomobject]@{
        file     = $k
        summary  = $forcedSummary
        category = Compute-Category $k
        score    = 1.0
      }) | Out-Null
  }
}
if ($forced.Count -gt 0) {
  Log "Force-keeping $($forced.Count) newly added page(s) the AI skipped."
  $aiVerdicts.ordered += $forced
  foreach ($f in $forced) { 
    $aiVerdicts.byFile[$f.file] = @{ summary=$f.summary; category=$f.category; score=$f.score }
    [void]$aiKeptSet.Add([string]$f.file)
  }
}

# ---- Post-AI safety: also keep meaningful MODIFIED files the AI skipped
$forcedModified = New-Object System.Collections.Generic.List[object]

foreach ($k in $filteredGroups.Keys) {
  if ($aiKeptSet.Contains($k)) { continue }
  $items = $filteredGroups[$k]
  $statuses = ($items.status | Where-Object { $_ } | Select-Object -Unique)
  if ($statuses -notcontains 'modified') { continue }

  $adds = ($items | Measure-Object -Sum -Property additions).Sum
  $dels = ($items | Measure-Object -Sum -Property deletions).Sum

  $lines = @()
  foreach ($it in $items) { if ($it.patch) { $lines += (($it.patch -split "`n") | Where-Object { $_ -match '^[\+\-]' }) } }
  $patchSample = ($lines | Select-Object -First 1200) -join "`n"

  $signals = Get-MeaningfulSignals -PatchSample $patchSample
  if (-not (Should-ForceKeepModified -Adds $adds -Dels $dels -Signals $signals -PatchSample $patchSample -Subjects ($items.pr_title | Select-Object -Unique))) { continue }

  $subjects = ($items.pr_title | Where-Object { $_ } | Select-Object -Unique)
  $summary = Summarize-ModifiedPatch -FilePath $k -Subjects $subjects -PatchSample $patchSample -Signals $signals

  $forcedModified.Add([pscustomobject]@{
      file     = $k
      summary  = $summary
      category = Compute-Category $k
      score    = 0.9
    }) | Out-Null
}

function Apply-FinalTrivialFiltering {
  param([object]$aiVerdicts, [hashtable]$filteredGroups)
  
  Log "Applying final filtering to remove trivial changes and duplicates..."
  
  $finalKept = New-Object System.Collections.Generic.List[object]
  $finalByFile = @{}
  
  foreach ($item in $aiVerdicts.ordered) {
    $file = $item.file
    if (-not $filteredGroups.ContainsKey($file)) { continue }
    
    $items = $filteredGroups[$file]
    $summary = $item.summary
    $category = $item.category
    
    # Build patch sample for analysis
    $lines = @()
    foreach ($it in $items) { 
      if ($it.patch) { 
        $lines += (($it.patch -split "`n") | Where-Object { $_ -match '^[\+\-]' }) 
      } 
    }
    $patchSample = ($lines | Select-Object -First 1200) -join "`n"
    
    $adds = ($items | Measure-Object -Sum -Property additions).Sum
    $dels = ($items | Measure-Object -Sum -Property deletions).Sum
    $totalLines = $adds + $dels
    
    # Final trivial check - be more aggressive than pre-filtering
    $isTrivial = $false
    
    # Pure metadata changes
    if ($totalLines -le 5 -and $patchSample -match '(ms\.author|ms\.date|author:|date:)' -and 
        ($patchSample -split "`n" | Where-Object { $_ -match '^[\+\-]' -and $_ -notmatch '(ms\.author|ms\.date|author:|date:)|^\s*[\+\-]\s*$' }).Count -eq 0) {
      $isTrivial = $true
      Log "  Final filter: Removed pure metadata change: $file"
    }
    
    # "Deploy and Explore" noise - check both patch and summary
    elseif (($patchSample -match 'deploy.*explore|nextstepaction.*Deploy.*Explore' -or 
            $summary -match '(?i)deploy.*explore|call-to-action') -and 
            $summary -notmatch '(?i)(new feature|security|performance|configuration|technical|command|procedure)') {
      $isTrivial = $true
      Log "  Final filter: Removed Deploy and Explore callout noise: $file"
    }
    
    # "Minor documentation maintenance updates" - this is clearly noise
    elseif ($summary -match '(?i)minor.*documentation.*maintenance|maintenance.*update') {
      $isTrivial = $true
      Log "  Final filter: Removed minor maintenance update: $file"
    }
    
    # Author changes 
    elseif ($summary -match '(?i)author.*metadata.*updated|author.*assignment|updating.*author') {
      $isTrivial = $true
      Log "  Final filter: Removed author assignment change: $file"
    }
    
    # Navigation/formatting only changes
    elseif ($summary -match '(?i)enhance.*navigation|improve.*navigation|direct.*link|guide.*user.*navigation' -and
           $summary -notmatch '(?i)(new|feature|security|technical|command|procedure|configuration)') {
      $isTrivial = $true
      Log "  Final filter: Removed navigation-only change: $file"
    }
    
    # Generic "enhancement" without substance
    elseif ($totalLines -le 15 -and 
           $summary -match '(?i)enhancement.*aim.*improve|addition.*enhance|improve.*user.*experience' -and
           $summary -notmatch '(?i)(new feature|security|performance|technical|command|procedure|configuration)') {
      $isTrivial = $true
      Log "  Final filter: Removed generic enhancement: $file"
    }
    
    if ($isTrivial) { continue }
    
    # Check for duplicates based on file path similarity and content
    $isDuplicate = $false
    $bestExisting = $null
    
    foreach ($existing in $finalKept) {
      # Check if files are very similar (e.g., different versions of same doc)
      $fileBase = $file -replace '\d+$', '' -replace '-v\d+$', ''
      $existingBase = $existing.file -replace '\d+$', '' -replace '-v\d+$', ''
      
      if ($fileBase -eq $existingBase -or 
          [System.IO.Path]::GetFileNameWithoutExtension($file) -eq [System.IO.Path]::GetFileNameWithoutExtension($existing.file)) {
        
        # Similar files found - keep the one with better summary or newer date
        $existingItems = $filteredGroups[$existing.file]
        $existingDate = if ($existingItems[0].merged_at) { $existingItems[0].merged_at } else { $existingItems[0].date }
        $currentDate = if ($items[0].merged_at) { $items[0].merged_at } else { $items[0].date }
        
        if ($existing.summary.Length -gt $summary.Length -or [DateTime]::Parse($existingDate) -gt [DateTime]::Parse($currentDate)) {
          $isDuplicate = $true
          Log "  Final filter: Removed duplicate (keeping better version): $file vs $($existing.file)"
          break
        } else {
          $bestExisting = $existing
          Log "  Final filter: Replacing inferior duplicate: $($existing.file) with $file"
          break
        }
      }
    }
    
    if ($isDuplicate) { continue }
    
    # Remove the inferior version if we found one
    if ($bestExisting) {
      $finalKept.Remove($bestExisting) | Out-Null
      $finalByFile.Remove($bestExisting.file)
    }
    
    # Add this item
    $finalKept.Add($item) | Out-Null
    $finalByFile[$file] = @{ 
      summary = $summary
      category = $category
      score = $item.score
    }
    
    Log "  Final filter: Kept meaningful update: $file"
  }
  
  Log "Final filtering complete: kept $($finalKept.Count) of $($aiVerdicts.ordered.Count) items"
  
  return @{
    ordered = $finalKept.ToArray()
    byFile = $finalByFile
  }
}

if ($forcedModified.Count -gt 0) {
  Log "Force-keeping $($forcedModified.Count) modified page(s) the AI skipped."
  foreach ($f in $forcedModified) {
    $items = $filteredGroups[$f.file]
    $adds = ($items | Measure-Object -Sum -Property additions).Sum
    $dels = ($items | Measure-Object -Sum -Property deletions).Sum
    $subjects = ($items.pr_title | Where-Object { $_ } | Select-Object -Unique)
    
    Log "  Force-kept: $($f.file)"
    Log "    Reason: +$adds -$dels lines, subjects: $($subjects -join ', ')"
    Log "    Category: $($f.category), Summary: $($f.summary)"
  }
  
  $aiVerdicts.ordered += $forcedModified
  foreach ($f in $forcedModified) { $aiVerdicts.byFile[$f.file] = @{ summary = $f.summary; category = $f.category; score = $f.score } }
}

# Apply final filtering to remove trivial changes and duplicates
$finalResults = Apply-FinalTrivialFiltering -aiVerdicts $aiVerdicts -filteredGroups $filteredGroups

# Render DOCS sections — ONLY what passed final filtering, preserving order
$sections = New-Object System.Collections.Generic.List[string]
foreach ($row in @($finalResults.ordered)) {
  $file = $row.file
  if (-not $filteredGroups.ContainsKey($file)) { continue }

  $arr = $filteredGroups[$file] | Sort-Object { if ($_.merged_at) { $_.merged_at } else { $_.date } } -Descending
  
  # Get repository info from the first item
  $repoOwner = $arr[0].repo_owner
  $repoName = $arr[0].repo_name
  $repoDisplay = $arr[0].repo_display
  
  $fileUrl = Get-LiveDocsUrl -FilePath $file -RepoName $repoName -Owner $repoOwner -Repo $repoName
  $summary = $finalResults.byFile[$file].summary
  $category = if ($finalResults.byFile[$file].category) { $finalResults.byFile[$file].category } else { Compute-Category $file }
  
  # Handle both PR merged_at and commit date
  $lastUpdatedDate = if ($arr[0].merged_at) { $arr[0].merged_at } else { $arr[0].date }
  $lastUpdated = [DateTime]::Parse($lastUpdatedDate).ToString('yyyy-MM-dd HH:mm')
  $prLink = $arr[0].pr_url

  $display = Get-DocDisplayName $file
  $kind = Get-SessionKind -items $arr -summary ($summary ?? "")
  $kindPill = KindToPillHtml $kind
  $product = Get-ProductIconMeta -FilePath $file -RepoName $repoName
  $iconUrl = $product.url
  $iconAlt = $product.alt
  $cardTitle = "$($product.label) - $display"
  $cardTitle = "$($product.label) - $display"

  $summary = if ($summary) { $summary } else { "Unable to summarize but a meaningful update was detected (details in linked PR/doc)." }

  $section = @"
<div class="aks-doc-update"
     data-category="$category"
     data-kind="$kind"
     data-product="$($product.label)"
     data-updated="$([DateTime]::Parse($lastUpdatedDate).ToString('o'))"
     data-title="$(Escape-Html $display)">
  <h2 class="aks-doc-title" style="display: flex; align-items: center; gap: 0.5rem;">
    <img class="aks-doc-icon" src="$iconUrl" alt="$iconAlt" loading="lazy" style="height: 1em; width: auto; flex-shrink: 0;" />
    <a href="$fileUrl">$(Escape-Html $cardTitle)</a>
  </h2>
  <div class="aks-doc-header">
    <span class="aks-doc-category">$category</span>
    $kindPill
    <span class="aks-doc-updated-pill">Modified: $lastUpdated</span>
  </div>
  <div class="aks-doc-summary">
    <strong>Summary</strong>
    <p>$(Escape-Html $summary)</p>
  </div>
  <ul></ul>
  <div class="aks-doc-buttons">
    <a class="aks-doc-link" href="$fileUrl" target="_blank" rel="noopener">View Documentation</a>
    <a class="aks-doc-link aks-doc-link-pr" href="$prLink" target="_blank" rel="noopener">View PR</a>
  </div>
</div>
"@
  $sections.Add($section.Trim())
}

# =========================
# RELEASES HANDLING (unchanged from original)
# =========================
function Get-GitHubReleases([string]$owner, [string]$repo, [int]$count = 5) {
  $uri = "https://api.github.com/repos/$owner/$repo/releases?per_page=$count"
  try { Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET }
  catch {
    Write-Warning ("Failed to fetch releases from {0}/{1}: {2}" -f $owner, $repo, $_.Exception.Message)
    return @()
  }
}

function Get-ReleaseSummariesViaAssistant {
  param([string]$JsonPath, [string]$Model = "gpt-4o-mini")
  if (-not $PSAIReady) { return @{} }
  try {
    Log "Uploading Releases JSON to AI provider..."
    $file = Invoke-OAIUploadFile -Path $JsonPath -Purpose assistants -ErrorAction Stop

    $vsName = "aks-releases-$(Get-Date -Format 'yyyyMMddHHmmss')"
    $vs = New-OAIVectorStore -Name $vsName -FileIds $file.id
    Log "Waiting on releases vector store..."
    $vsMaxIterations = 60  # 60 iterations × 2 s = up to 120 s
    $vsWaitCount = 0
    do {
      Start-Sleep -Seconds 2
      $vsWaitCount++
      $current = Get-OAIVectorStore -limit 100 -order desc | Where-Object { $_.id -eq $vs.id }
      if ($current) { $vs = $current }
      Log "Releases VS status: $($vs.status)"
    } while ($vs.status -ne 'completed' -and $vs.status -ne 'failed' -and $vs.status -ne 'cancelled' -and $vsWaitCount -lt $vsMaxIterations)
    if ($vs.status -ne 'completed') {
      Write-Warning "Releases vector store did not complete (status: $($vs.status)) — falling back to GitHub Models"
      return Get-ReleaseSummariesViaGitHubModels -JsonPath $JsonPath -Model $Model
    }

$instructions = @"
You are summarizing AKS GitHub Releases.
The uploaded JSON contains: id, title, tag_name, published_at, body (markdown).

Return ONLY JSON:
[
  { "id": <same id>, "summary": "2-3 sentences",
    "breaking_changes": ["..."],
    "key_features": ["..."],
    "good_to_know": ["..."] }
]

Extraction rules (very important):
- Actively mine the body for *implicit* signals (not just headings). Use concrete text evidence.
- Prefer short, standalone bullets (max ~14 words each), no markdown, no duplication across lists.
- If an item is broad, split it into two concrete facets (e.g., "Default X -> Y" and "Action required: update flag --foo").
- **Target 2-5 items per list.** If the body clearly supports only 1 item for a list, return that 1 (do NOT invent).
- Never fabricate content that isn't supported by the text.

Section criteria:
- breaking_changes: API/CLI flag removals or renames, default changes with behavioral impact,
  deprecations requiring migration, minimum-version bumps, feature removals, config incompatibilities.
- key_features: new features, GA announcements, preview additions, performance/scalability improvements,
  new regions/limits, major bugfix clusters.
- good_to_know: caveats, known issues, mitigations, upgrade/migration tips, feature gates/preview flags,
  noteworthy docs clarifications, timeframes, rollout/region availability notes.

Output format requirements:
- Plain strings only; no markdown; no trailing punctuation unless needed.
- Do not repeat the summary content verbatim in the lists.
- Ensure JSON is valid and contains all three arrays.
"@

    $assistant = New-OAIAssistant `
      -Name "AKS-Releases-Summarizer" `
      -Instructions $instructions `
      -Tools @{ type = 'file_search' } `
      -ToolResources @{ file_search = @{ vector_store_ids = @($vs.id) } } `
      -Model $Model

    $userMsg = "Summarize each release by ID. Return ONLY the JSON array."
    $run = New-OAIThreadAndRun -AssistantId $assistant.id -Thread @{ messages = @(@{ role = 'user'; content = $userMsg }) } -MaxCompletionTokens 3000 -Temperature 0.2
    $run = Wait-OAIOnRun -Run $run -Thread @{ id = $run.thread_id }

    if ($run.status -ne 'completed') {
      $errCode = if ($run.last_error -and $run.last_error.code -and $run.last_error.message) { " ($($run.last_error.code): $($run.last_error.message))" } else { '' }
      throw "Releases assistant run did not complete (status: $($run.status))$errCode"
    }

    # Filter to assistant messages only — a failed run leaves only the user message in the thread,
    # which would cause the JSON regex to match against the prompt instead of a real response.
    $messages = (Get-OAIMessage -ThreadId $run.thread_id -Order desc -Limit 10).data
    $assistantMsg = $messages | Where-Object { $_.role -eq 'assistant' } | Select-Object -First 1
    if (-not $assistantMsg) {
      Log "AI (releases): No assistant reply found in thread — falling back to GitHub Models."
      return Get-ReleaseSummariesViaGitHubModels -JsonPath $JsonPath -Model $Model
    }
    $last = $assistantMsg.content | Where-Object { $_.type -eq 'text' } | ForEach-Object { $_.text.value } | Out-String

    # Strip markdown code fences and OpenAI citation annotations (e.g. 【4:0†source.json】)
    $clean = Remove-AIResponseArtifacts $last
    $match = [regex]::Match($clean, '\[(?:[^][]|(?<open>\[)|(?<-open>\]))*\](?(open)(?!))', 'Singleline')
    if (-not $match.Success) {
      $preview = if ($clean) { $clean.Substring(0, [Math]::Min($PreviewMaxLength, $clean.Length)) } else { '(empty response)' }
      Log "AI (releases): No JSON array found — falling back to GitHub Models. Raw response (first $PreviewMaxLength chars): $preview"
      return Get-ReleaseSummariesViaGitHubModels -JsonPath $JsonPath -Model $Model
    }

    $arr = $match.Value | ConvertFrom-Json -ErrorAction Stop
    $map = @{}
    foreach ($i in $arr) {
      $map[$i.id] = @{
        summary          = $i.summary
        breaking_changes = $i.PSObject.Properties['breaking_changes'] ? $i.breaking_changes : @()
        key_features     = $i.PSObject.Properties['key_features']     ? $i.key_features     : @()
        good_to_know     = $i.PSObject.Properties['good_to_know']     ? $i.good_to_know     : @()
      }
    }
    Log "AI: Release summaries ready for $($map.Keys.Count) releases."
    return $map
  }
  catch {
    if (Test-IsRateLimitError $_) {
      Write-Warning "OpenAI rate limit reached for releases — falling back to GitHub Models. Error: $($_.Exception.Message)"
      return Get-ReleaseSummariesViaGitHubModels -JsonPath $JsonPath -Model $Model
    }
    Write-Warning "AI summaries (releases) failed: $_"
    return @{}
  }
  finally {
    # Clean up AI resources to avoid accumulating orphaned objects
    if ($assistant) { try { Remove-OAIAssistant -AssistantId $assistant.id | Out-Null } catch {} }
    if ($vs) { try { Remove-OAIVectorStore -VectorStoreId $vs.id | Out-Null } catch {} }
    if ($file) { try { Remove-OAIFile -FileId $file.id | Out-Null } catch {} }
  }
}

function ToListHtml($arr) {
  if (-not $arr -or $arr.Count -eq 0) { return "" }
  $lis = ($arr | ForEach-Object { '<li>' + (Escape-Html $_) + '</li>' }) -join ''
  return "<ul class=""aks-rel-list"">$lis</ul>"
}

$releases = Get-GitHubReleases -owner $ReleasesOwner -repo $ReleasesRepo -count $ReleasesCount

# Build releases JSON for AI
$relJsonPath = Join-Path $TmpRoot ("aks-releases-{0}.json" -f (Get-Date -Format 'yyyyMMddHHmmss'))
$relInput = @(
  foreach ($r in $releases) {
    [pscustomobject]@{
      id           = $r.id
      title        = ($r.name ?? $r.tag_name)
      tag_name     = $r.tag_name
      published_at = $r.published_at
      body         = $r.body
      html_url     = $r.html_url
      prerelease   = [bool]$r.prerelease
    }
  }
)
$relInput | ConvertTo-Json -Depth 6 | Set-Content -Path $relJsonPath -Encoding UTF8

$releaseSummaries = @{}
if ($PreferProvider -and $releases.Count -gt 0) {
  $releaseSummaries = Get-ReleaseSummariesViaAssistant -JsonPath $relJsonPath
}
else {
  Log "AI disabled or no releases."
}

$releaseCards = New-Object System.Collections.Generic.List[string]
foreach ($r in $releases) {
  $titleRaw = ($r.name ?? $r.tag_name)
  $title = Escape-Html $titleRaw
  $url = $r.html_url
  $isPrerelease = [bool]$r.prerelease
  $publishedAt = if ($r.published_at) { [DateTime]::Parse($r.published_at).ToUniversalTime().ToString("yyyy-MM-dd") } else { "" }

  $ai = $releaseSummaries[$r.id]
  if (-not $ai) {
    $bodyPlain = Convert-MarkdownToPlain ($r.body ?? "")
    $ai = @{
      summary          = Truncate $bodyPlain 400
      breaking_changes = @()
      key_features     = @()
      good_to_know     = @()
    }
  }

  $summaryHtml = "<p>" + (Escape-Html $ai.summary) + "</p>"

  $sectionsHtml = ""
  if ($ai.breaking_changes -and $ai.breaking_changes.Count) {
    $sectionsHtml += @"
<div class="aks-rel-sec">
  <div class="aks-rel-sec-head"><span class="aks-rel-ico">❌</span><h3>Breaking Changes</h3></div>
  $(ToListHtml $ai.breaking_changes)
</div>
"@
  }
  if ($ai.key_features -and $ai.key_features.Count) {
    $sectionsHtml += @"
<div class="aks-rel-sec">
  <div class="aks-rel-sec-head"><span class="aks-rel-ico">🔑</span><h3>Key Features</h3></div>
  $(ToListHtml $ai.key_features)
</div>
"@
  }
  if ($ai.good_to_know -and $ai.good_to_know.Count) {
    $sectionsHtml += @"
<div class="aks-rel-sec">
  <div class="aks-rel-sec-head"><span class="aks-rel-ico">💡</span><h3>Good to Know</h3></div>
  $(ToListHtml $ai.good_to_know)
</div>
"@
  }

  $badge = if ($isPrerelease) { '<span class="aks-rel-badge">Pre-release</span>' } else { '' }

  $card = @"
<div class="aks-rel-card">
  <div class="aks-rel-head">
    <div class="aks-rel-title">
      <h2>$title</h2>$badge
    </div>
    <a class="aks-rel-link" href="$url" target="_blank" rel="noopener">View Release</a>
  </div>
  <div class="aks-rel-meta">
    <span class="aks-rel-date">📅 $publishedAt</span>
  </div>
  <div class="aks-rel-summary">
    $summaryHtml
  </div>
  $sectionsHtml
</div>
"@
  $releaseCards.Add($card.Trim())
}

$releasesHtml = if ($releaseCards.Count -gt 0) { $releaseCards -join "`n" } else { '<p class="aks-rel-empty">No releases found (yet).</p>' }

# =========================
# CVE DATA (fetched once, rendered for both page tab and email digest)
# =========================
Log "Fetching AKS CVE vulnerability data..."
$cveTabHtml = Get-AksCveTabHtml

# Email-safe (table-based, inline styles only) CVE snapshot for the weekly digest
function Get-AksCveDigestHtml {
  $cveApiBase     = "https://cve-api.prod-aks.azure.com"
  $cveExplorerUrl = "https://cve-api.prod-aks.azure.com/viewer/index.html"
  $trackerUrl     = "https://pixelrobots.co.uk/aks-docs-tracker/"

  try {
    $index   = Invoke-RestMethod -Uri "$cveApiBase/api/v1/aks-releases/_index" -Method GET -TimeoutSec 30
    $versions = @($index.aks_release_versions)
    if (-not $versions -or $versions.Count -eq 0) { return '' }

    $latestVersion = $versions[-1]
    $report    = Invoke-RestMethod -Uri "$cveApiBase/api/v1/aks-releases/$latestVersion/scan-reports" -Method GET -TimeoutSec 30
    $reportDate = if ($report.report_time) { [DateTime]::Parse($report.report_time).ToString('yyyy-MM-dd') } else { 'N/A' }
    $containers = @($report.container_targets)

    $uniqueActive    = @($containers | ForEach-Object { $_.active_cves } | Where-Object { $_ } | Select-Object -ExpandProperty id | Sort-Object -Unique)
    $uniqueMitigated = @($containers | ForEach-Object {
        if ($_.PSObject.Properties['mitigated_cves_from_previous_release']) { $_.mitigated_cves_from_previous_release }
      } | Where-Object { $_ } | Select-Object -ExpandProperty id | Sort-Object -Unique)

    $activeCount     = $uniqueActive.Count
    $mitigatedCount  = $uniqueMitigated.Count
    $totalContainers = $containers.Count
    $containersWithCves = ($containers | Where-Object { $_.active_cves -and $_.active_cves.Count -gt 0 }).Count

    $topContainers = $containers |
      Where-Object { $_.active_cves -and $_.active_cves.Count -gt 0 } |
      Sort-Object { $_.active_cves.Count } -Descending |
      Select-Object -First 5

    $topRows = ($topContainers | ForEach-Object {
        $cnt = $_.active_cves.Count
        $mit = if ($_.PSObject.Properties['mitigated_cves_from_previous_release']) { $_.mitigated_cves_from_previous_release.Count } else { 0 }
        $mitCell = if ($mit -gt 0) { "<td style='padding:6px 10px;font-size:12px;color:#059669;font-weight:600;'>$mit mitigated</td>" } else { "<td style='padding:6px 10px;font-size:12px;color:#9ca3af;'>—</td>" }
        "<tr style='border-bottom:1px solid #f3f4f6;'><td style='padding:6px 10px;font-size:12px;color:#6b7280;'>$(Escape-Html $_.pod_namespace)</td><td style='padding:6px 10px;font-size:12px;font-weight:500;color:#111827;'>$(Escape-Html $_.container_name)</td><td style='padding:6px 10px;font-size:12px;font-weight:700;color:#dc2626;'>$cnt active</td>$mitCell</tr>"
      }) -join "`n"

    # ── VHD node-image summary for digest ──────────────────────────────────────
    $vhdDigestBlock = ''
    try {
      $nodeIndex  = Invoke-RestMethod -Uri "$cveApiBase/api/v1/vhd-releases/_index" -Method GET -TimeoutSec 30
      Log "  Digest VHD index response keys: $($nodeIndex.PSObject.Properties.Name -join ', ')"
      $vhdImageNames  = @(
        if ($nodeIndex.vhd_release_names)    { $nodeIndex.vhd_release_names }
        elseif ($nodeIndex.node_image_names) { $nodeIndex.node_image_names }
        elseif ($nodeIndex.images)           { $nodeIndex.images }
        elseif ($nodeIndex -is [array])      { $nodeIndex }
        else                                 { @() }
      )
      Log "  Digest VHD image names from index ($($vhdImageNames.Count)): $($vhdImageNames -join ', ')"
      # Resolve each name to a full {type}/{version} path for the scan-reports endpoint
      $vhdImages = [System.Collections.Generic.List[string]]::new()
      foreach ($name in $vhdImageNames) {
        if ($name -match '/') {
          $vhdImages.Add($name)
        } else {
          Log "  Looking up versions for image type: $name ..."
          try {
            $imgIdx = Invoke-RestMethod -Uri "$cveApiBase/api/v1/vhd-releases/$name/_index" -Method GET -TimeoutSec 30
            Log "    Image type index response keys: $($imgIdx.PSObject.Properties.Name -join ', ')"
            $versions = @(
              if ($imgIdx.vhd_release_versions) { $imgIdx.vhd_release_versions }
              elseif ($imgIdx.versions)          { $imgIdx.versions }
              elseif ($imgIdx.release_versions)  { $imgIdx.release_versions }
              elseif ($imgIdx -is [array])       { $imgIdx }
              else                               { @() }
            )
            if ($versions.Count -gt 0) {
              $latestVer = ($versions | Sort-Object {
                $v = $_
                try { [System.Version]::new($v) }
                catch { Write-Warning "  Could not parse version '$v' as System.Version, using 0.0.0"; [System.Version]::new("0.0.0") }
              } -Descending)[0]
              Log "    Latest version for ${name}: $latestVer"
              $vhdImages.Add("$name/$latestVer")
            } else {
              Write-Warning "  No versions found in index for image type: $name"
            }
          } catch {
            Write-Warning "  Failed to fetch version index for ${name}: $_"
          }
        }
      }
      if ($vhdImages.Count -gt 0) {
        $vhdActiveAll = [System.Collections.Generic.HashSet[string]]::new()
        $vhdMitAll    = [System.Collections.Generic.HashSet[string]]::new()
        $vhdTop5 = [System.Collections.Generic.List[pscustomobject]]::new()
        foreach ($img in $vhdImages) {
          $vhdRpt   = Invoke-RestMethod -Uri "$cveApiBase/api/v1/vhd-releases/$img/scan-reports" -Method GET -TimeoutSec 30
          Log "  Digest VHD $img — response keys: $($vhdRpt.PSObject.Properties.Name -join ', ')"
          $pkgT     = @(if ($vhdRpt.os_package_targets) { $vhdRpt.os_package_targets } elseif ($vhdRpt.packages) { $vhdRpt.packages } else { @() })
          $imgAct   = 0; $imgMit = 0
          foreach ($pkg in $pkgT) {
            foreach ($cv in @($pkg.active_cves))                             { if ($cv.id) { $null = $vhdActiveAll.Add($cv.id); $imgAct++ } }
            foreach ($cv in @($pkg.mitigated_cves_from_previous_release))    { if ($cv.id) { $null = $vhdMitAll.Add($cv.id);  $imgMit++ } }
          }
          $vhdTop5.Add([pscustomobject]@{ img=$img; active=$imgAct; mitigated=$imgMit })
        }
        $vhdTop5Sorted = @($vhdTop5 | Sort-Object { -$_.active } | Select-Object -First 5)
        $vhdTotalActive = $vhdActiveAll.Count
        $vhdTotalMit    = $vhdMitAll.Count
        $vhdImgCount    = $vhdImages.Count

        $vhdTopRows = ($vhdTop5Sorted | ForEach-Object {
          $mitCell = if ($_.mitigated -gt 0) { "<td style='padding:6px 10px;font-size:12px;color:#059669;font-weight:600;'>$($_.mitigated) mitigated</td>" } else { "<td style='padding:6px 10px;font-size:12px;color:#9ca3af;'>—</td>" }
          "<tr style='border-bottom:1px solid #f3f4f6;'><td style='padding:6px 10px;font-size:12px;font-weight:500;color:#111827;'>$(Escape-Html $_.img)</td><td style='padding:6px 10px;font-size:12px;font-weight:700;color:#dc2626;'>$($_.active) active</td>$mitCell</tr>"
        }) -join "`n"

        $vhdDigestBlock = @"
    <tr>
      <td style="padding-bottom:16px;">
        <p style="margin:0 0 8px;font-size:13px;font-weight:700;color:#111827;">&#128187; VHD Node Image CVEs (OS-level)</p>
        <table width="100%" cellpadding="0" cellspacing="0" border="0">
          <tr>
            <td width="30%" style="padding:10px;background:#fff5f5;border:1px solid #fecaca;border-radius:6px;text-align:center;">
              <div style="font-size:24px;font-weight:800;color:#dc2626;line-height:1;">$vhdTotalActive</div>
              <div style="font-size:11px;font-weight:600;color:#374151;margin-top:3px;">Active CVEs</div>
              <div style="font-size:10px;color:#9ca3af;">across all node images</div>
            </td>
            <td width="4%"></td>
            <td width="30%" style="padding:10px;background:#f0fdf4;border:1px solid #bbf7d0;border-radius:6px;text-align:center;">
              <div style="font-size:24px;font-weight:800;color:#059669;line-height:1;">$vhdTotalMit</div>
              <div style="font-size:11px;font-weight:600;color:#374151;margin-top:3px;">Mitigated</div>
              <div style="font-size:10px;color:#9ca3af;">vs previous build</div>
            </td>
            <td width="4%"></td>
            <td width="32%" style="padding:10px;background:#fffbeb;border:1px solid #fde68a;border-radius:6px;text-align:center;">
              <div style="font-size:24px;font-weight:800;color:#d97706;line-height:1;">$vhdImgCount</div>
              <div style="font-size:11px;font-weight:600;color:#374151;margin-top:3px;">Node Image Types</div>
              <div style="font-size:10px;color:#9ca3af;">Linux &amp; Windows</div>
            </td>
          </tr>
        </table>
        <p style="margin:10px 0 6px;font-size:12px;font-weight:600;color:#374151;">Top images by active CVEs:</p>
        <table width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#ffffff;border:1px solid #e5e7eb;border-radius:6px;overflow:hidden;">
          <thead>
            <tr style="background:#f3f4f6;">
              <th style="padding:6px 10px;font-size:11px;font-weight:600;color:#6b7280;text-align:left;">Node Image</th>
              <th style="padding:6px 10px;font-size:11px;font-weight:600;color:#6b7280;text-align:left;">Active CVEs</th>
              <th style="padding:6px 10px;font-size:11px;font-weight:600;color:#6b7280;text-align:left;">Mitigated</th>
            </tr>
          </thead>
          <tbody>
            $vhdTopRows
          </tbody>
        </table>
      </td>
    </tr>
"@
      }
    }
    catch {
      Write-Warning "VHD digest CVE fetch failed (non-fatal): $_"
    }

    return @"
<div style="margin:20px 0;padding:20px;background-color:#eff6ff;border:1px solid #bfdbfe;border-radius:8px;">
  <table width="100%" cellpadding="0" cellspacing="0" border="0">
    <tr>
      <td style="padding-bottom:12px;">
        <h2 style="margin:0;font-size:17px;font-weight:700;color:#1e3a8a;">🛡️ AKS CVE Security Snapshot</h2>
        <p style="margin:6px 0 0;font-size:12px;color:#1e40af;">Latest AKS release: <strong>$latestVersion</strong> &nbsp;·&nbsp; Data as of $reportDate &nbsp;·&nbsp; Source: <a href="$cveExplorerUrl" style="color:#2563eb;">AKS Vulnerability Data API</a> (Public Preview)</p>
      </td>
    </tr>
    $vhdDigestBlock
    <tr>
      <td style="padding-bottom:16px;">
        <p style="margin:0 0 8px;font-size:13px;font-weight:700;color:#111827;">&#128230; Container Image CVEs (K8s &amp; AKS platform)</p>
        <table width="100%" cellpadding="0" cellspacing="0" border="0">
          <tr>
            <td width="25%" style="padding:12px;background:#fff5f5;border:1px solid #fecaca;border-radius:6px;text-align:center;">
              <div style="font-size:28px;font-weight:800;color:#dc2626;line-height:1;">$activeCount</div>
              <div style="font-size:12px;font-weight:600;color:#374151;margin-top:4px;">Active CVEs</div>
              <div style="font-size:11px;color:#9ca3af;">unique, latest release</div>
            </td>
            <td width="4%"></td>
            <td width="25%" style="padding:12px;background:#f0fdf4;border:1px solid #bbf7d0;border-radius:6px;text-align:center;">
              <div style="font-size:28px;font-weight:800;color:#059669;line-height:1;">$mitigatedCount</div>
              <div style="font-size:12px;font-weight:600;color:#374151;margin-top:4px;">Mitigated</div>
              <div style="font-size:11px;color:#9ca3af;">vs previous release</div>
            </td>
            <td width="4%"></td>
            <td width="42%" style="padding:12px;background:#f9fafb;border:1px solid #e5e7eb;border-radius:6px;text-align:center;">
              <div style="font-size:24px;font-weight:800;color:#f59e0b;line-height:1;">$containersWithCves / $totalContainers</div>
              <div style="font-size:12px;font-weight:600;color:#374151;margin-top:4px;">Containers with active CVEs</div>
            </td>
          </tr>
        </table>
      </td>
    </tr>
    <tr>
      <td style="padding-bottom:12px;">
        <p style="margin:0 0 8px;font-size:13px;font-weight:600;color:#111827;">Top containers by active CVEs:</p>
        <table width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#ffffff;border:1px solid #e5e7eb;border-radius:6px;overflow:hidden;">
          <thead>
            <tr style="background:#f3f4f6;">
              <th style="padding:6px 10px;font-size:11px;font-weight:600;color:#6b7280;text-align:left;">Namespace</th>
              <th style="padding:6px 10px;font-size:11px;font-weight:600;color:#6b7280;text-align:left;">Container</th>
              <th style="padding:6px 10px;font-size:11px;font-weight:600;color:#6b7280;text-align:left;">Active CVEs</th>
              <th style="padding:6px 10px;font-size:11px;font-weight:600;color:#6b7280;text-align:left;">Mitigated</th>
            </tr>
          </thead>
          <tbody>
            $topRows
          </tbody>
        </table>
      </td>
    </tr>
    <tr>
      <td style="padding-top:4px;">
        <a href="$trackerUrl" style="display:inline-block;padding:10px 18px;font-size:13px;font-weight:600;text-decoration:none;border-radius:6px;background-color:#2563eb;color:#ffffff;">🔍 View Full CVE Security Tab</a>
      </td>
    </tr>
  </table>
</div>
"@.Trim()
  }
  catch {
    Write-Warning "CVE digest block failed: $_"
    return ''
  }
}

# =========================
# PAGE HTML (Tabs + Panels) - Same as original
# =========================
$lastUpdated = (Get-Date -Format 'dd/MM/yyyy, HH:mm:ss')
$updateCount = @($finalResults.ordered).Count

$formShortcode = '[email-subscribers-form id="2"]'

$html = @"
<div class="aks-updates" data-since="$SINCE_ISO">

  <div class="aks-intro">
    <h1>About this tracker</h1>
    <p>This tool keeps an eye on Microsoft's Azure Kubernetes Service (AKS), Kubernetes Fleet Manager documentation, Azure Container Registry (ACR), and Azure Application Gateway for Containers (AGC). It also shows the last 5 release notes from AKS.</p>
    <p>It automatically scans for changes, then uses AI to summarize and highlight updates that are most likely to matter — such as new features, deprecations, and significant content revisions.</p>
    <p>Minor edits (like typos, formatting tweaks, and other low-impact changes) are usually filtered out. Because the process is automated, some updates may be missed or summaries may not capture every nuance.</p>
    <p>For complete accuracy, you can always follow the provided links to the original Microsoft documentation.</p>

    <p><strong>With this tracker, you can:</strong></p>
    <ul>
      <li>Quickly scan meaningful AKS, ACR, AGC, and Fleet documentation changes from the past 7 days</li>
      <li>Stay up to date with the latest AKS release notes without digging through every doc page</li>
      <li>Search and browse CVE security data across AKS container images and VHD node images, powered by the <strong>AKS Vulnerability Data API</strong> (Public Preview)</li>
    </ul>

    </br>
    <p><strong>Get the Latest AKS Docs - Every Week, in Your Inbox</strong></p>
    <!-- Inline signup form -->
    <div style="margin-top:1rem;">
      $formShortcode
    </div>
  </div>

  <div class="aks-tabs">
    <nav class="aks-tabs-nav">
      <a class="aks-tab-link active" href="#aks-tab-docs">Documentation Updates</a>
      <a class="aks-tab-link" href="#aks-tab-releases">AKS Releases</a>
      <a class="aks-tab-link" href="#aks-tab-cve">🛡️ CVE Security</a>
    </nav>

    <!-- CVE_SECTION_START -->
    <div class="aks-tab-panel" id="aks-tab-cve">
      <h2>AKS CVE Security</h2>
      <p>CVE security data for AKS container images and VHD node images, sourced from the <strong>AKS Vulnerability Data API</strong> (Public Preview). Search any CVE ID instantly, or browse active CVEs by container release or node image.</p>
      $cveTabHtml
    </div>
    <!-- CVE_SECTION_END -->

    <div class="aks-tab-panel" id="aks-tab-releases">
      <div class="aks-releases">
      <h2>AKS Releases</h2>
      <p>Latest 5 AKS releases with AI-generated summaries, breaking changes, and Good to Know information.</p>
      <div class="aks-rel-header">
          <div class="aks-rel-title-row">
              <span class="aks-pill aks-pill-updated">updated: $lastUpdated</span>
          </div>
      </div>
        $releasesHtml
      </div>
    </div>

    <div class="aks-tab-panel active" id="aks-tab-docs">
      <h2>Documentation Updates</h2>
      <div class="aks-docs-desc">Meaningful updates to AKS, ACR, AGC, and Fleet docs from the last 7 days.</div>
      <div class="aks-docs-updated-main">
        <span class="aks-pill aks-pill-updated">updated: $lastUpdated</span>
        <span class="aks-pill aks-pill-count">$updateCount updates</span>
      </div>
      <div class="aks-docs-list">
        $($sections -join "`n")
      </div>
    </div>
    </br>
    </br>
  </div>

</div>
"@.Trim()

# ===== Weekly digest (compact HTML without tabs/filters) =====
$sortedDocs = @($finalResults.ordered) | Sort-Object {
  $file = $_.file
  if ($filteredGroups.ContainsKey($file)) {
    ($filteredGroups[$file] | Sort-Object merged_at -Descending | Select-Object -First 1).merged_at
  }
  else { Get-Date 0 }
} -Descending

# Calculate counts per repository/product for digest
$digestRepoCounts = @{}
foreach ($row in $sortedDocs) {
  $file = $row.file
  if (-not $filteredGroups.ContainsKey($file)) { continue }
  
  $product = (Get-ProductIconMeta $file).label
  
  if (-not $digestRepoCounts.ContainsKey($product)) {
    $digestRepoCounts[$product] = 0
  }
  $digestRepoCounts[$product]++
}

# Create count breakdown for digest
$digestCountBreakdown = ($digestRepoCounts.GetEnumerator() | Sort-Object Name | ForEach-Object { 
  "$($_.Name) ($($_.Value))" 
}) -join ", "

$digestItems = New-Object System.Collections.Generic.List[string]
foreach ($row in $sortedDocs) {
  $file = $row.file
  if (-not $filteredGroups.ContainsKey($file)) { continue }
  $arr = $filteredGroups[$file] | Sort-Object { if ($_.merged_at) { $_.merged_at } else { $_.date } } -Descending
  $fileUrl = Get-LiveDocsUrl -FilePath $file
  $summary = $finalResults.byFile[$file].summary
  $category = if ($finalResults.byFile[$file].category) { $finalResults.byFile[$file].category } else { Compute-Category $file }
  
  # Handle both PR merged_at and commit date
  $lastUpdatedDate = if ($arr[0].merged_at) { $arr[0].merged_at } else { $arr[0].date }
  $lastUpdated = [DateTime]::Parse($lastUpdatedDate).ToString('yyyy-MM-dd HH:mm')
  $product = (Get-ProductIconMeta $file).label
  $productMeta = Get-ProductIconMeta -FilePath $file
  $iconUrl = $productMeta.url
  $iconAlt = $productMeta.alt
  $display = Get-DocDisplayName $file
  $title = "$(Escape-Html ($product + ' - ' + $display))"
  $prLink = $arr[0].pr_url

  $li = @"
<div style="margin: 20px 0; padding: 18px; background-color: #ffffff; border: 1px solid #e5e7eb; border-radius: 6px;">
  <table width="100%" cellpadding="0" cellspacing="0" border="0">
    <tr>
      <td>
        <h3 style="margin: 0 0 10px 0; font-size: 17px; font-weight: 600; line-height: 1.4; color: #1e40af;">
          <img src="$iconUrl" alt="$iconAlt" style="height: 18px; width: auto; vertical-align: middle; margin-right: 6px;" />
          <a href="$fileUrl" style="text-decoration: none; color: #1e40af;">$title</a>
        </h3>
      </td>
    </tr>
    <tr>
      <td style="padding: 8px 0;">
        <span style="display: inline-block; padding: 4px 10px; margin-right: 6px; background-color: #f3f4f6; color: #374151; border-radius: 4px; font-size: 12px; font-weight: 500;">$category</span>
        <span style="display: inline-block; padding: 4px 10px; margin-right: 6px; background-color: #dbeafe; color: #1e40af; border-radius: 4px; font-size: 12px; font-weight: 500;">$product</span>
        <span style="display: inline-block; padding: 4px 10px; background-color: #fef3c7; color: #92400e; border-radius: 4px; font-size: 12px; font-weight: 500;">Modified: $lastUpdated</span>
      </td>
    </tr>
    <tr>
      <td style="padding: 12px 0;">
        <p style="margin: 0 0 6px 0; font-size: 13px; font-weight: 600; color: #111827;">Summary</p>
        <p style="margin: 0; font-size: 14px; line-height: 1.6; color: #374151;">$(Escape-Html $summary)</p>
      </td>
    </tr>
    <tr>
      <td style="padding-top: 12px;">
        <table cellpadding="0" cellspacing="0" border="0">
          <tr>
            <td style="padding-right: 10px;">
              <a href="$fileUrl" style="display: inline-block; padding: 10px 18px; font-size: 13px; font-weight: 600; text-decoration: none; border-radius: 6px; background-color: #2563eb; color: #ffffff;">📖 View Documentation</a>
            </td>
            <td>
              <a href="$prLink" style="display: inline-block; padding: 10px 18px; font-size: 13px; font-weight: 600; text-decoration: none; border-radius: 6px; background-color: #f8fafc; color: #475569; border: 1px solid #e2e8f0;">🔗 View PR</a>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</div>
"@
  $digestItems.Add($li.Trim())
}

$weekStart = (Get-Date -Date ((Get-Date).ToUniversalTime().ToString('yyyy-MM-dd')) -AsUTC).AddDays(-7)
$weekEnd = (Get-Date).ToUniversalTime()
$digestTitle = "Azure Container Services Docs - Weekly Update (" + $weekStart.ToString('yyyy-MM-dd') + " to " + $weekEnd.ToString('yyyy-MM-dd') + ")"

Log "Building CVE digest block..."
$cveDigestBlock = Get-AksCveDigestHtml

$digestHtml = @"
<div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; background-color: #f9fafb;">
  <div style="background-color: #ffffff; padding: 20px; border-radius: 6px; margin-bottom: 20px; border: 1px solid #e5e7eb;">
    <h2 style="margin: 0 0 10px 0; font-size: 22px; font-weight: 700; color: #111827;">$digestTitle</h2>
    <p style="margin: 0 0 12px 0; font-size: 14px; line-height: 1.6; color: #4b5563;">
      The most meaningful Azure Kubernetes Service, Container Registry, Application Gateway for Containers, and Fleet Manager documentation changes from the last 7 days. Summaries are AI-filtered to skip trivial edits.
    </p>
    <p style="margin: 0; font-size: 13px; color: #059669; font-weight: 600;">
      📊 Updates this week: $digestCountBreakdown
    </p>
  </div>
  <div>
    $($digestItems -join "`n")
  </div>
  $cveDigestBlock
  <div style="margin-top: 20px; padding: 16px; background-color: #ffffff; border-radius: 6px; border: 1px solid #e5e7eb; text-align: center;">
    <p style="margin: 0; font-size: 13px; color: #6b7280;">
      Full tracker with filters: <a href="https://pixelrobots.co.uk/aks-docs-tracker/" style="color: #2563eb; text-decoration: none; font-weight: 600;">Azure Container Services Docs Tracker</a>
    </p>
  </div>
</div>
"@.Trim()

# =========================
# OUTPUT (JSON with html + hash)
# =========================
$sha256 = [System.Security.Cryptography.SHA256]::Create()
$bytes = [Text.Encoding]::UTF8.GetBytes($html)
$hash = ($sha256.ComputeHash($bytes) | ForEach-Object { $_.ToString("x2") }) -join ""

[pscustomobject]@{
  html         = $html
  hash         = $hash
  ai_summaries = $finalResults
  digest_html  = $digestHtml
  digest_title = $digestTitle
  digest_saved_to = $digestHtmlPath
} | ConvertTo-Json -Depth 6

Log "Enhanced AKS Docs Tracker completed successfully!"
Log "Minimal pre-filtering removed $skippedCount obvious trivial changes"
Log "Final output includes $($finalResults.ordered.Count) meaningful updates"
