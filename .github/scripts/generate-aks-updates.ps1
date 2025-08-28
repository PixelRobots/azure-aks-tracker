#!/usr/bin/env pwsh
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# =========================
# ENHANCED CONFIG / ENV with better filtering
# =========================
$Owner = "MicrosoftDocs"
$Repo = "azure-aks-docs"

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

function Get-PullRequestFiles {
  param([int]$prNumber)
  $uri = "https://api.github.com/repos/$Owner/$Repo/pulls/$prNumber/files"
  try { 
    $response = Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
    return $response
  }
  catch { 
    Write-Warning "Failed to get files for PR #$prNumber`: $_"
    return @()
  }
}

function Get-CommitFiles {
  param([string]$sha)
  $uri = "https://api.github.com/repos/$Owner/$Repo/commits/$sha"
  try { 
    $response = Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
    return $response
  }
  catch { 
    Write-Warning "Failed to get commit details for $sha`: $_"
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

function Get-ProductIconMeta([string]$FilePath) {
  if ($FilePath -match '/kubernetes-fleet/') {
    return @{
      url   = 'https://learn.microsoft.com/en-gb/azure/media/index/kubernetes-fleet-manager.svg'
      alt   = 'Kubernetes Fleet Manager'
      label = 'Fleet'
    }
  }
  else {
    return @{
      url   = 'https://learn.microsoft.com/en-gb/azure/media/index/kubernetes-services.svg'
      alt   = 'Azure Kubernetes Service'
      label = 'AKS'
    }
  }
}

function Get-GitHubContentBase64([string]$path, [string]$ref = "main") {
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

function Summarize-NewMarkdown([string]$path) {
  $raw = Get-GitHubContentBase64 -path $path
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
function Get-LiveDocsUrl([string]$FilePath) {
  if ($FilePath -match '^articles/(.+?)\.md$') {
    $p = $Matches[1] -replace '\\', '/'
    if ($p -notmatch '^azure/') { $p = "azure/$p" }
    return "https://learn.microsoft.com/$p"
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
    do {
      Start-Sleep -Seconds 2
      $current = Get-OAIVectorStore -limit 100 -order desc | Where-Object { $_.id -eq $vs.id }
      if ($current) { $vs = $current }
      Log "Vector store status: $($vs.status)"
    } while ($vs.status -ne 'completed')

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
    $run = New-OAIThreadAndRun -AssistantId $assistant.id -Thread @{ messages = @(@{ role = 'user'; content = $userMsg }) } -MaxCompletionTokens 1400 -Temperature 0.05
    $run = Wait-OAIOnRun -Run $run -Thread @{ id = $run.thread_id }

    $last = (Get-OAIMessage -ThreadId $run.thread_id -Order desc -Limit 1).data[0].content |
    Where-Object { $_.type -eq 'text' } |
    ForEach-Object { $_.text.value } |
    Out-String

    $clean = $last -replace '^\s*```(?:json)?\s*', '' -replace '\s*```\s*$', ''
    $match = [regex]::Match($clean, '\[(?:[^][]|(?<open>\[)|(?<-open>\]))*\](?(open)(?!))', 'Singleline')
    if (-not $match.Success) { Log "AI: No JSON array found in response."; return @{ ordered = @(); byFile = @{} } }

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
    Write-Warning "AI summaries (docs) failed: $_"
    return @{ ordered = @(); byFile = @{} }
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
# MAIN EXECUTION - COLLECT DATA
# =========================

# Initialize AI if provider is configured
if ($PreferProvider) {
  $PSAIReady = Initialize-AIProvider -Provider $PreferProvider
  if ($PSAIReady) { Log "AI provider ($PreferProvider) initialized." }
} else {
  Log "No AI provider configured - running without AI summaries."
}

# Collect PR and commit data
Log "Collecting GitHub data since $SINCE_ISO..."

# Get recent pull requests
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

Log "Found $($prs.Count) recently updated PRs"

# Get recent commits directly from main branch
$commits = @()
$page = 1
do {
  $uri = "https://api.github.com/repos/$Owner/$Repo/commits?sha=main&since=$SINCE_ISO&per_page=100&page=$page"
  $response = Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
  $commits += $response
  $page++
} while ($response.Count -eq 100)

Log "Found $($commits.Count) recent commits"

# Process PRs and commits to get file changes
$allFiles = @()

# Process PRs
foreach ($pr in $prs) {
  try {
    $files = Get-PullRequestFiles -prNumber $pr.number
    foreach ($file in $files) {
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
      }
    }
  }
  catch {
    Write-Warning "Failed to get files for PR #$($pr.number): $_"
  }
}

# Process commits that aren't from PRs
foreach ($commit in $commits) {
  # Skip commits that are already covered by PRs
  $existingCommit = $allFiles | Where-Object { $_.sha -eq $commit.sha }
  if ($existingCommit) { continue }
  
  try {
    $commitDetail = Get-CommitFiles -sha $commit.sha
    foreach ($file in $commitDetail.files) {
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
      }
    }
  }
  catch {
    Write-Warning "Failed to get files for commit $($commit.sha): $_"
  }
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
    $forcedSummary = Summarize-NewMarkdown $k
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
  $fileUrl = Get-LiveDocsUrl -FilePath $file
  $summary = $finalResults.byFile[$file].summary
  $category = if ($finalResults.byFile[$file].category) { $finalResults.byFile[$file].category } else { Compute-Category $file }
  
  # Handle both PR merged_at and commit date
  $lastUpdatedDate = if ($arr[0].merged_at) { $arr[0].merged_at } else { $arr[0].date }
  $lastUpdated = [DateTime]::Parse($lastUpdatedDate).ToString('yyyy-MM-dd HH:mm')
  $prLink = $arr[0].pr_url

  $display = Get-DocDisplayName $file
  $kind = Get-SessionKind -items $arr -summary ($summary ?? "")
  $kindPill = KindToPillHtml $kind
  $product = Get-ProductIconMeta $file
  $iconUrl = $product.url
  $iconAlt = $product.alt
  $cardTitle = "$($product.label) - $display"

  $summary = if ($summary) { $summary } else { "Unable to summarize but a meaningful update was detected (details in linked PR/doc)." }

  $section = @"
<div class="aks-doc-update"
     data-category="$category"
     data-kind="$kind"
     data-product="$($product.label)"
     data-updated="$([DateTime]::Parse($lastUpdatedDate).ToString('o'))"
     data-title="$(Escape-Html $display)">
  <h2 class="aks-doc-title">
    <img class="aks-doc-icon" src="$iconUrl" alt="$iconAlt" width="20" height="20" loading="lazy" />
    <a href="$fileUrl">$(Escape-Html $cardTitle)</a>
  </h2>
  <div class="aks-doc-header">
    <span class="aks-doc-category">$category</span>
    $kindPill
    <span class="aks-doc-updated-pill">Last updated: $lastUpdated</span>
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
    do {
      Start-Sleep -Seconds 2
      $current = Get-OAIVectorStore -limit 100 -order desc | Where-Object { $_.id -eq $vs.id }
      if ($current) { $vs = $current }
      Log "Releases VS status: $($vs.status)"
    } while ($vs.status -ne 'completed')

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
    $run = New-OAIThreadAndRun -AssistantId $assistant.id -Thread @{ messages = @(@{ role = 'user'; content = $userMsg }) } -MaxCompletionTokens 1500 -Temperature 0.2
    $run = Wait-OAIOnRun -Run $run -Thread @{ id = $run.thread_id }

    $last = (Get-OAIMessage -ThreadId $run.thread_id -Order desc -Limit 1).data[0].content |
    Where-Object { $_.type -eq 'text' } |
    ForEach-Object { $_.text.value } |
    Out-String

    $clean = $last -replace '^\s*```(?:json)?\s*', '' -replace '\s*```\s*$', ''
    $match = [regex]::Match($clean, '\[(?:[^][]|(?<open>\[)|(?<-open>\]))*\](?(open)(?!))', 'Singleline')
    if (-not $match.Success) { Log "AI (releases): No JSON array found."; return @{} }

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
    Write-Warning "AI summaries (releases) failed: $_"
    return @{}
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
# PAGE HTML (Tabs + Panels) - Same as original
# =========================
$lastUpdated = (Get-Date -Format 'dd/MM/yyyy, HH:mm:ss')
$updateCount = @($finalResults.ordered).Count

$formShortcode = '[email-subscribers-form id="2"]'

$html = @"
<div class="aks-updates" data-since="$SINCE_ISO">

  <div class="aks-intro">
    <h1>About this tracker</h1>
    <p>This tool keeps an eye on Microsoft's Azure Kubernetes Service (AKS) and Kubernetes Fleet Manager documentation and release notes.</p>
    <p>It automatically scans for changes, then uses AI to summarize and highlight updates that are most likely to matter — such as new features, deprecations, and significant content revisions.</p>
    <p>Minor edits (like typos, formatting tweaks, and other low-impact changes) are usually filtered out. Because the process is automated, some updates may be missed or summaries may not capture every nuance.</p>
    <p>For complete accuracy, you can always follow the provided links to the original Microsoft documentation.</p>

    <p><strong>With this tracker, you can:</strong></p>
    <ul>
      <li>Quickly scan meaningful AKS and Fleet documentation changes from the past 7 days</li>
      <li>Stay up to date with the latest AKS release notes without digging through every doc page</li>
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
    </nav>

    <div class="aks-tab-panel" id="aks-tab-releases">
      <div class="aks-releases">
      <h2>AKS Releases</h2>
      <p>Latest 5 AKS releases with AI-generated summaries, breaking changes, and Good to Know information.</p>
      <div class="aks-rel-header">
          <div class="aks-rel-title-row">
              <span class="aks-pill aks-pill-updated">Last updated: $lastUpdated</span>
          </div>
      </div>
        $releasesHtml
      </div>
    </div>

    <div class="aks-tab-panel active" id="aks-tab-docs">
      <h2>Documentation Updates</h2>
      <div class="aks-docs-desc">Meaningful updates to AKS and Fleet docs from the last 7 days.</div>
      <div class="aks-docs-updated-main">
        <span class="aks-pill aks-pill-updated">Last updated: $lastUpdated</span>
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
$sortedDocs = @($aiVerdicts.ordered) | Sort-Object {
  $file = $_.file
  if ($filteredGroups.ContainsKey($file)) {
    ($filteredGroups[$file] | Sort-Object merged_at -Descending | Select-Object -First 1).merged_at
  }
  else { Get-Date 0 }
} -Descending

$digestItems = New-Object System.Collections.Generic.List[string]
foreach ($row in $sortedDocs) {
  $file = $row.file
  if (-not $filteredGroups.ContainsKey($file)) { continue }
  $arr = $filteredGroups[$file] | Sort-Object { if ($_.merged_at) { $_.merged_at } else { $_.date } } -Descending
  $fileUrl = Get-LiveDocsUrl -FilePath $file
  $summary = $aiVerdicts.byFile[$file].summary
  $category = if ($aiVerdicts.byFile[$file].category) { $aiVerdicts.byFile[$file].category } else { Compute-Category $file }
  
  # Handle both PR merged_at and commit date
  $lastUpdatedDate = if ($arr[0].merged_at) { $arr[0].merged_at } else { $arr[0].date }
  $lastUpdated = [DateTime]::Parse($lastUpdatedDate).ToString('yyyy-MM-dd HH:mm')
  $product = (Get-ProductIconMeta $file).label
  $title = "$(Escape-Html ($product + ' - ' + (Get-DocDisplayName $file)))"
  $prLink = $arr[0].pr_url

  $li = @"
<li style="margin:12px 0 18px;">
  <div style="font-weight:700; font-size:16px; line-height:1.3;">
    <a href="$fileUrl" style="text-decoration:none; color:#2563eb;">$title</a>
  </div>
  <div style="font-size:12px; color:#6b7280; margin:4px 0 6px;">
    <span>$category</span> · <span>$product</span> · <span>Last updated: $lastUpdated</span>
  </div>
  <div style="font-size:14px; color:#111827;">$(Escape-Html $summary)</div>
  <div style="margin-top:6px;">
    <a href="$fileUrl" style="font-size:13px; color:#2563eb; text-decoration:none;">View doc</a>
    <span style="color:#9ca3af;"> · </span>
    <a href="$prLink" style="font-size:13px; color:#2563eb; text-decoration:none;">View PR</a>
  </div>
</li>
"@
  $digestItems.Add($li.Trim())
}

$weekStart = (Get-Date -Date ((Get-Date).ToUniversalTime().ToString('yyyy-MM-dd')) -AsUTC).AddDays(-7)
$weekEnd = (Get-Date).ToUniversalTime()
$digestTitle = "AKS & Fleet Docs – Weekly Update (" + $weekStart.ToString('yyyy-MM-dd') + " to " + $weekEnd.ToString('yyyy-MM-dd') + ")"

$digestHtml = @"
<div style="font-family:system-ui,-apple-system,Segoe UI,Roboto,Arial,sans-serif; max-width:800px; margin:0 auto;">
  <h2 style="margin:0 0 8px; font-size:20px;">$digestTitle</h2>
  <p style="margin:0 0 14px; font-size:14px; color:#374151;">
    The most meaningful AKS and Kubernetes Fleet Manager documentation changes from the last 7 days. Summaries are AI-filtered to skip trivial edits.
  </p>
  <ul style="padding-left:18px; margin:0; list-style:disc;">
    $($digestItems -join "`n")
  </ul>
  <p style="margin-top:16px; font-size:12px; color:#6b7280;">
    Full tracker (with filters): <a href="https://pixelrobots.co.uk/aks-docs-tracker/" style="color:#2563eb; text-decoration:none;">AKS Docs Tracker</a>
  </p>
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
  ai_summaries = $aiVerdicts
  digest_html  = $digestHtml
  digest_title = $digestTitle
} | ConvertTo-Json -Depth 6

Log "Enhanced AKS Docs Tracker completed successfully!"
Log "Minimal pre-filtering removed $skippedCount obvious trivial changes"
Log "Final output includes $($aiVerdicts.ordered.Count) meaningful updates"
