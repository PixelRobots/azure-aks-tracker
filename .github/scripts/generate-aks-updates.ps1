#!/usr/bin/env pwsh
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# =========================
# CONFIG / ENV
# =========================
$Owner = "MicrosoftDocs"
$Repo  = "azure-aks-docs"
$GitHubToken = $env:GITHUB_TOKEN
if (-not $GitHubToken) { Write-Error "GITHUB_TOKEN not set"; exit 1 }

# Prefer OpenAI if OpenAIKey exists, else AzureOpenAI if all vars exist, else disabled
$PreferProvider = if ($env:OpenAIKey) { 'OpenAI' } elseif ($env:AZURE_OPENAI_APIURI -and $env:AZURE_OPENAI_KEY -and $env:AZURE_OPENAI_API_VERSION -and $env:AZURE_OPENAI_DEPLOYMENT) { 'AzureOpenAI' } else { '' }

# Inclusive UTC-midnight window for last 7 days
$now = [DateTime]::UtcNow
$sinceMidnightUtc = (Get-Date -Date $now.ToString("yyyy-MM-dd") -AsUTC).AddDays(-7)
$SINCE_ISO = $sinceMidnightUtc.ToString("o")

$ghHeaders = @{
  "Authorization" = "Bearer $GitHubToken"
  "Accept"        = "application/vnd.github+json"
  "User-Agent"    = "pixelrobots-aks-updates-pwsh"
}

function Log($msg) { Write-Host "[$(Get-Date -Format HH:mm:ss)] $msg" }

# =========================
# HELPERS
# =========================
function Escape-Html([string]$s) {
  $s.Replace('&','&amp;').Replace('<','&lt;').Replace('>','&gt;').Replace('"','&quot;')
}
function ShortTitle([string]$path) { ($path -split '/')[ -1 ] }
function Get-LiveDocsUrl([string]$FilePath, [string]$Locale = "en-us") {
  if ($FilePath -match '^articles/(.+?)\.md$') {
    $p = $Matches[1] -replace '\\','/'
    if ($p -notmatch '^azure/') { $p = "azure/$p" }
    return "https://learn.microsoft.com/$Locale/$p"
  }
  return "https://github.com/$Owner/$Repo/blob/main/$FilePath"
}

# =========================
# FILTERS
# =========================
function Test-IsBot($Item) {
  $login = $Item.user.login
  return ($login -match '(bot|actions)')
}
function Test-IsNoiseMessage([string]$Message) {
  if (-not $Message) { return $false }
  $patterns = @(
    '^merge\b','^sync\b','publish from','update submodule',
    '\btypo\b','\bgrammar\b','\blink[- ]?fix\b','\bformat(ting)?\b',
    '\breadme\b','^chore\b'
  )
  foreach ($p in $patterns) { if ($Message -imatch $p) { return $true } }
  return $false
}
function Test-IsTinyDocsChange($Adds, $Dels, $Files) {
  $allMd = (($Files | Where-Object { $_.filename -notmatch '\.md$' }).Count -eq 0)
  $total = $Adds + $Dels
  if (-not $allMd) { return $false }
  if ($total -gt 2) { return $false }
  # Check for important tokens in diff or PR title
  $tokens = 'true|false|default|kubectl|az |MutatingWebhook|ValidatingWebhook|load balanc|port|TLS|deprecate|breaking'
  $diffText = ($Files | ForEach-Object { $_.patch }) -join ' '
  $prTitle = ($Files | ForEach-Object { $_.pr_title }) -join ' '
  if ($diffText -match $tokens -or $prTitle -match $tokens) { return $false }
  return $true
}

# =========================
# FETCH PRs MERGED LAST 7 DAYS
# =========================
function Get-RecentMergedPRs {
  $all = @()
  for ($page=1; $page -le 5; $page++) {
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
# AI INIT (PSAI) — strictly your working pattern
# =========================
$PSAIReady = $false
function Initialize-AIProvider {
  param([ValidateSet('OpenAI','AzureOpenAI')][string]$Provider)
  try {
    if (-not (Get-Module -ListAvailable -Name PSAI)) {
      Install-Module PSAI -Scope CurrentUser -Force -ErrorAction Stop
    }
    Import-Module PSAI -ErrorAction Stop
  } catch {
    Write-Warning "PSAI not available; skipping AI. $_"
    return $false
  }
  switch ($Provider) {
    'OpenAI' {
      if (-not $env:OpenAIKey) { Write-Warning "OpenAIKey not set"; return $false }
      Set-OAIProvider -Provider OpenAI | Out-Null
      return $true
    }
    'AzureOpenAI' {
      $secrets = @{
        apiURI         = $env:AZURE_OPENAI_APIURI
        apiKey         = $env:AZURE_OPENAI_KEY
        apiVersion     = $env:AZURE_OPENAI_API_VERSION
        deploymentName = $env:AZURE_OPENAI_DEPLOYMENT
      }
      if ($secrets.Values -contains $null -or ($secrets.Values | Where-Object { [string]::IsNullOrWhiteSpace($_) })) {
        Write-Warning "Azure OpenAI envs incomplete."
        return $false
      }
      Set-OAIProvider -Provider AzureOpenAI | Out-Null
      Set-AzOAISecrets @secrets | Out-Null
      return $true
    }
  }
}
if ($PreferProvider) { $PSAIReady = Initialize-AIProvider -Provider $PreferProvider }

function Get-PerFileSummariesViaAssistant {
  param([string]$JsonPath,[string]$Model="gpt-4o-mini")
  if (-not $PSAIReady) { return @{} }
  try {
    Log "Uploading JSON to AI provider..."
    $file = Invoke-OAIUploadFile -Path $JsonPath -Purpose assistants -ErrorAction Stop

    # Create vector store and poll for status by ID (robust pattern)
    $vsName = "aks-docs-prs-$(Get-Date -Format 'yyyyMMddHHmmss')"
    $vs = New-OAIVectorStore -Name $vsName -FileIds $file.id
    Log "Waiting on vector store processing..."
    do {
      Start-Sleep -Seconds 2
      $current = Get-OAIVectorStore -limit 100 -order desc | Where-Object { $_.id -eq $vs.id }
      if (-not $current) {
        Log "Vector store not found (ID: $($vs.id)). Retrying..."
        continue
      }
      $vs = $current
      Log "Vector store status: $($vs.status)"
    } while ($vs.status -ne 'completed')

  $instructions = @"
You are summarizing substantive Azure AKS documentation changes from PRs.
Ignore trivial edits (typos, link fixes).
For each file, return JSON: [ { "file": "<path>", "summary": "2–4 sentences about what changed", "impact": ["bullet point 1", "bullet point 2"], "category": "<category>" } ]
Category should be a short, meaningful tag like 'General', 'Ingress', 'Security', etc.
Summary should be 2–4 sentences describing the change for a reader.
Impact should be 1–3 bullet points about how this change affects users/readers (e.g., new features, improved clarity, breaking changes, etc.).
Only return the JSON array.
"@

    Log "Creating assistant + run..."
    $assistant = New-OAIAssistant `
      -Name "AKS-Docs-Summarizer" `
      -Instructions $instructions `
      -Tools @{ type = 'file_search' } `
      -ToolResources @{ file_search = @{ vector_store_ids = @($vs.id) } } `
      -Model $Model

    $userMsg = "Summarize each file listed in the uploaded JSON per the instructions. Only return the JSON array."
    $run = New-OAIThreadAndRun -AssistantId $assistant.id -Thread @{ messages = @(@{ role = 'user'; content = $userMsg }) } -MaxCompletionTokens 1200
    $run = Wait-OAIOnRun -Run $run -Thread @{ id = $run.thread_id }

    $last = (Get-OAIMessage -ThreadId $run.thread_id -Order desc -Limit 1).data[0].content |
      Where-Object { $_.type -eq 'text' } |
      ForEach-Object { $_.text.value } |
      Out-String

    # Strip fences and extract JSON array
    $clean = $last -replace '^\s*```(?:json)?\s*','' -replace '\s*```\s*$',''
    $match = [regex]::Match($clean,'\[(?:[^][]|(?<open>\[)|(?<-open>\]))*\](?(open)(?!))','Singleline')
    if (-not $match.Success) { Log "AI: No JSON array found in response."; return @{} }

    $arr = $match.Value | ConvertFrom-Json -ErrorAction Stop
    $map = @{}
    foreach ($i in $arr) {
      $map[$i.file] = @{
        summary = $i.summary
        impact = $i.PSObject.Properties['impact'] ? $i.impact : @()
        category = $i.PSObject.Properties['category'] ? $i.category : 'General'
      }
    }
    Log "AI: Summaries ready for $($map.Keys.Count) files."
    return $map
  }
  catch {
    Write-Warning "AI summaries failed: $_"
    return @{}
  }
}

# =========================
# MAIN FLOW
# =========================
Log "Fetching PRs merged in last 7 days..."
$prs = Get-RecentMergedPRs | Where-Object { -not (Test-IsBot $_) }
Log "Found $($prs.Count) PR(s) in window."

$groups = @{}
foreach ($pr in $prs) {
  if (Test-IsNoiseMessage $pr.title) { continue }

  $files = Get-PRFiles $pr.number
  foreach ($f in $files) {
  if ($f.filename -notmatch '\.md$') { continue }
  # Attach PR title to file object for filter
  $f | Add-Member -NotePropertyName pr_title -NotePropertyValue $pr.title -Force
  if (Test-IsTinyDocsChange $f.additions $f.deletions @($f)) { continue }
    if (-not $groups.ContainsKey($f.filename)) { $groups[$f.filename] = @() }
    $groups[$f.filename] += [pscustomobject]@{
      pr_title = $pr.title
      pr_url   = $pr.html_url
      merged_at= [DateTime]::Parse($pr.merged_at).ToUniversalTime()
      filename = $f.filename
    }
  }
}

# Prepare AI input JSON (like your working flow)
$TmpRoot = $env:RUNNER_TEMP; if (-not $TmpRoot) { $TmpRoot = [System.IO.Path]::GetTempPath() }
$aiJsonPath = Join-Path $TmpRoot ("aks-doc-pr-groups-{0}.json" -f (Get-Date -Format 'yyyyMMddHHmmss'))

$aiInput = [pscustomobject]@{
  since  = $SINCE_ISO
  groups = @(
    foreach ($k in $groups.Keys) {
      [pscustomobject]@{
        file     = $k
        subjects = ($groups[$k] | ForEach-Object { $_.pr_title } | Select-Object -Unique)
      }
    }
  )
}
$aiInput | ConvertTo-Json -Depth 6 | Set-Content -Path $aiJsonPath -Encoding UTF8
Log "AI Summaries"
Log "  [AKS] Prepared AI input: $aiJsonPath"

# AI summaries (optional)
$summaries = @{}
if ($PreferProvider) {
  $summaries = Get-PerFileSummariesViaAssistant -JsonPath $aiJsonPath
} else {
  Log "AI disabled (no provider env configured)."
}

# =========================
# RENDER HTML
# =========================
$sections = New-Object System.Collections.Generic.List[string]
foreach ($file in $groups.Keys) {
  $arr = $groups[$file] | Sort-Object merged_at -Descending
  $fileUrl = Get-LiveDocsUrl -FilePath $file
  $summary = $summaries[$file].summary
  $category = $summaries[$file].category

  $lis = ""
  foreach ($x in $arr) {
    $prUrl = $x.pr_url
    $prTitle = Escape-Html $x.pr_title
    $prDate = $x.merged_at.ToString('yyyy-MM-dd')
    # $lis += '<li><a href="' + $prUrl + '">' + $prTitle + '</a> <small>' + $prDate + '</small></li>'
  }

  $lastUpdated = $arr[0].merged_at.ToString('yyyy-MM-dd HH:mm')
  $summaryText = $summary
  $impactHtml = ""
  if ($impactArr -and $impactArr.Count -gt 0) {
    $impactHtml = '<div class="aks-doc-impact"><strong>Impact</strong><ul>'
    foreach ($impactItem in $impactArr) {
      $impactHtml += '<li>' + (Escape-Html $impactItem) + '</li>'
    }
    $impactHtml += '</ul></div>'
  }

  $prLink = $arr[0].pr_url
  # Prefer PR title for card header, fallback to file name
  $cardTitle = $arr[0].pr_title
  if (-not $cardTitle -or $cardTitle -eq "") { $cardTitle = ShortTitle $file }
  $section = @"
<section class=\"aks-doc-update\">
  <h2><a href=\"$fileUrl\">$(Escape-Html $cardTitle)</a></h2>
  <div class=\"aks-doc-header\">
    <span class=\"aks-doc-category\">$category</span>
  <span class=\"aks-doc-updated-pill\">Last updated: $lastUpdated</span>
  </div>
  <div class=\"aks-doc-summary\">
    <strong>Summary</strong>
    <p>$(Escape-Html $summary)</p>
  </div>
  $impactHtml
  <ul>
    $lis
  </ul>
  <div class=\"aks-doc-buttons\">
    <a class=\"aks-doc-link\" href=\"$fileUrl\" target=\"_blank\">View Documentation</a>
    <a class=\"aks-doc-link aks-doc-link-pr\" href=\"$prLink\" target=\"_blank\">View PR</a>
  </div>
</section>
"@
  $section = $section.Trim()
  $sections.Add($section)
}

$lastUpdated = (Get-Date -Format 'dd/MM/yyyy, HH:mm:ss')

$html = @"
<div class="aks-updates" data-since="$SINCE_ISO">
  <div class="aks-intro">
    <p>Welcome! This tool automatically tracks and summarizes meaningful updates to the Azure Kubernetes Service (AKS) documentation and releases.</p>
    <p>It filters out typos, minor edits, and bot changes, so you only see what really matters.<br>
    Check back often as data is automatically refreshed every 12 hours.</p>
  </div>
  <h2>Documentation Updates</h2>
  <div class="aks-docs-desc">Meaningful updates to the Azure Kubernetes Service (AKS) documentation from the last 7 days.</div>
  <span class="aks-doc-updated-pill">Last updated: $lastUpdated</span>
  <div class="aks-docs-list">
    $($sections -join "`n")
  </div>
</div>
"@.Trim()

# Hash for idempotency
$sha256 = [System.Security.Cryptography.SHA256]::Create()
$bytes  = [Text.Encoding]::UTF8.GetBytes($html)
$hash   = ($sha256.ComputeHash($bytes) | ForEach-Object { $_.ToString("x2") }) -join ""

# Emit JSON (Action step will read this)
[pscustomobject]@{ html = $html; hash = $hash; ai_summaries = $summaries } | ConvertTo-Json -Depth 6
