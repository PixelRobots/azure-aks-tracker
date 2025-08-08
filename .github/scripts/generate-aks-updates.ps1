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

# Docs window: last 7 days from UTC midnight
$now = [DateTime]::UtcNow
$sinceMidnightUtc = (Get-Date -Date $now.ToString("yyyy-MM-dd") -AsUTC).AddDays(-7)
$SINCE_ISO = $sinceMidnightUtc.ToString("o")

# Releases source (GitHub Releases)
$ReleasesOwner = "Azure"   # <-- change if needed
$ReleasesRepo  = "AKS"     # <-- change to the repo that actually publishes AKS releases
$ReleasesCount = 5

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
  if ($null -eq $s) { return "" }
  $s.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('"', '&quot;')
}
function ShortTitle([string]$path) { ($path -split '/')[ -1 ] }
function Get-LiveDocsUrl([string]$FilePath, [string]$Locale = "en-us") {
  if ($FilePath -match '^articles/(.+?)\.md$') {
    $p = $Matches[1] -replace '\\', '/'
    if ($p -notmatch '^azure/') { $p = "azure/$p" }
    return "https://learn.microsoft.com/$Locale/$p"
  }
  return "https://github.com/$Owner/$Repo/blob/main/$FilePath"
}
function Truncate([string]$text, [int]$max = 400) {
  if (-not $text) { return "" }
  $t = $text.Trim()
  if ($t.Length -le $max) { return $t }
  return $t.Substring(0, $max).TrimEnd() + "…"
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
    '^merge\b', '^sync\b', 'publish from', 'update submodule',
    '\btypo\b', '\bgrammar\b', '\blink[- ]?fix\b', '\bformat(ting)?\b',
    '\breadme\b', '^chore\b'
  )
  foreach ($p in $patterns) { if ($Message -imatch $p) { return $true } }
  return $false
}
function Test-IsTinyDocsChange($Adds, $Dels, $Files) {
  $allMd = (($Files | Where-Object { $_.filename -notmatch '\.md$' }).Count -eq 0)
  $total = $Adds + $Dels
  if (-not $allMd) { return $false }
  if ($total -gt 2) { return $false }
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
  catch {
    Write-Warning "PSAI not available; skipping AI. $_"
    return $false
  }
  switch ($Provider) {
    'OpenAI'      { if (-not $env:OpenAIKey) { Write-Warning "OpenAIKey not set"; return $false }; Set-OAIProvider -Provider OpenAI | Out-Null; return $true }
    'AzureOpenAI' {
      $secrets = @{
        apiURI         = $env:AZURE_OPENAI_APIURI
        apiKey         = $env:AZURE_OPENAI_KEY
        apiVersion     = $env:AZURE_OPENAI_API_VERSION
        deploymentName = $env:AZURE_OPENAI_DEPLOYMENT
      }
      if ($secrets.Values -contains $null -or ($secrets.Values | Where-Object { [string]::IsNullOrWhiteSpace($_) })) {
        Write-Warning "Azure OpenAI envs incomplete."; return $false
      }
      Set-OAIProvider -Provider AzureOpenAI | Out-Null
      Set-AzOAISecrets @secrets | Out-Null
      return $true
    }
  }
}
if ($PreferProvider) { $PSAIReady = Initialize-AIProvider -Provider $PreferProvider }

function Get-PerFileSummariesViaAssistant {
  param([string]$JsonPath, [string]$Model = "gpt-4o-mini")
  if (-not $PSAIReady) { return @{} }
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
You are summarizing substantive Azure AKS documentation changes from PRs.
Ignore trivial edits (typos, link fixes).
For each file, return JSON: [ { "file": "<path>", "summary": "2–4 sentences about what changed", "impact": ["bullet point 1", "bullet point 2"], "category": "<category>" } ]
Category should be a short, meaningful tag like 'General', 'Ingress', 'Security', etc.
Summary should be 2–4 sentences describing the change for a reader.
Impact should be 1–3 bullet points about how this change affects users/readers.
Only return the JSON array.
"@

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

    $clean = $last -replace '^\s*```(?:json)?\s*', '' -replace '\s*```\s*$',''
    $match = [regex]::Match($clean, '\[(?:[^][]|(?<open>\[)|(?<-open>\]))*\](?(open)(?!))', 'Singleline')
    if (-not $match.Success) { Log "AI: No JSON array found in response."; return @{} }

    $arr = $match.Value | ConvertFrom-Json -ErrorAction Stop
    $map = @{}
    foreach ($i in $arr) {
      $map[$i.file] = @{
        summary  = $i.summary
        impact   = $i.PSObject.Properties['impact'] ? $i.impact : @()
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
# MAIN FLOW — DOCS
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
    $f | Add-Member -NotePropertyName pr_title -NotePropertyValue $pr.title -Force
    if (Test-IsTinyDocsChange $f.additions $f.deletions @($f)) { continue }
    if (-not $groups.ContainsKey($f.filename)) { $groups[$f.filename] = @() }
    $groups[$f.filename] += [pscustomobject]@{
      pr_title  = $pr.title
      pr_url    = $pr.html_url
      merged_at = [DateTime]::Parse($pr.merged_at).ToUniversalTime()
      filename  = $f.filename
    }
  }
}

# AI summaries input (optional)
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

$summaries = @{}
if ($PreferProvider) { $summaries = Get-PerFileSummariesViaAssistant -JsonPath $aiJsonPath }
else { Log "AI disabled (no provider env configured)." }

# Render DOCS sections
$sections = New-Object System.Collections.Generic.List[string]
foreach ($file in $groups.Keys) {
  $arr = $groups[$file] | Sort-Object merged_at -Descending
  $fileUrl  = Get-LiveDocsUrl -FilePath $file
  $summary  = $summaries[$file].summary
  $category = $summaries[$file].category

  $lastUpdated = $arr[0].merged_at.ToString('yyyy-MM-dd HH:mm')

  $prLink   = $arr[0].pr_url
  $cardTitle = $arr[0].pr_title
  if (-not $cardTitle -or $cardTitle -eq "") { $cardTitle = ShortTitle $file }

  $section = @"
<div class="aks-doc-update">
  <h2><a href="$fileUrl">$(Escape-Html $cardTitle)</a></h2>
  <div class="aks-doc-header">
    <span class="aks-doc-category">$category</span>
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


function Get-ReleaseAISummary {
  param(
    [string]$Title,
    [string]$Body,
    [string]$Model = "gpt-4o-mini"  # or your Azure deployment name if using Azure OpenAI
  )
  # Fallback quickly if AI not ready or body empty
  if (-not $PSAIReady -or [string]::IsNullOrWhiteSpace($Body)) {
    return $null
  }

  $sys = @"
You are an assistant that reads a GitHub release note and extracts a structured summary.
Return ONLY valid JSON with this shape:
{
  "summary": "1-2 sentences top-level summary in plain text",
  "breaking_changes": ["..."],
  "key_features": ["..."],
  "good_to_know": ["..."]
}
Make bullets concise, 3-8 items per section when applicable. Omit marketing fluff. No markdown in values.
"@

  $user = @"
TITLE: $Title

BODY (GitHub Markdown):
$Body
"@

  try {
    # Ask the model for JSON
    $resp = Invoke-OAIChatCompletion -Model $Model -System $sys -Input $user -MaxTokens 800 -Temperature 0.2

    # Extract JSON robustly (strip fences if present)
    $text = $resp.Content | Out-String
    $clean = $text -replace '^\s*```(?:json)?\s*', '' -replace '\s*```\s*$',''

    # Try parse; if it fails, try to find the first {...} object in the text
    try {
      return ($clean | ConvertFrom-Json -ErrorAction Stop)
    } catch {
      $m = [regex]::Match($clean, '\{(?:[^{}]|(?<o>\{)|(?<-o>\}))*\}(?(o)(?!))', 'Singleline')
      if ($m.Success) { return ($m.Value | ConvertFrom-Json -ErrorAction Stop) }
      throw
    }
  }
  catch {
    Write-Warning "AI release summary failed for '$Title': $($_.Exception.Message)"
    return $null
  }
}

# =========================
# MAIN FLOW — RELEASES (AI-enhanced)
# =========================
function Get-GitHubReleases([string]$owner, [string]$repo, [int]$count = 5) {
  $uri = "https://api.github.com/repos/$owner/$repo/releases?per_page=$count"
  try {
    Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
  }
  catch {
    Write-Warning ("Failed to fetch releases from {0}/{1}: {2}" -f $owner, $repo, $_.Exception.Message)
    return @()
  }
}

$releases = Get-GitHubReleases -owner $ReleasesOwner -repo $ReleasesRepo -count $ReleasesCount

function ToListHtml($arr) {
  if (-not $arr -or $arr.Count -eq 0) { return "" }
  $lis = ($arr | ForEach-Object { '<li>' + (Escape-Html $_) + '</li>' }) -join ''
  return "<ul class=""aks-rel-list"">$lis</ul>"
}

$releaseCards = New-Object System.Collections.Generic.List[string]

foreach ($r in $releases) {
  $version      = Escape-Html ($r.tag_name ?? $r.name)
  $titleRaw     = ($r.name ?? $r.tag_name)
  $title        = Escape-Html $titleRaw
  $url          = $r.html_url
  $isPrerelease = [bool]$r.prerelease
  $publishedAt  = if ($r.published_at) { [DateTime]::Parse($r.published_at).ToUniversalTime().ToString("yyyy-MM-dd") } else { "" }

  # Try AI summary first
  $ai = Get-ReleaseAISummary -Title $titleRaw -Body ($r.body ?? "")
  if (-not $ai) {
    # Fallback to crude summary
    $bodyRaw = ($r.body ?? "") -replace '```[\s\S]*?```','' `
                               -replace '!\[[^\]]*\]\([^)]+\)','' `
                               -replace '\[[^\]]*\]\([^)]+\)','' `
                               -replace '\r',''
    $ai = @{
      summary          = Truncate $bodyRaw 400
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
  <div class="aks-rel-sec-head"><span class="aks-rel-ico">❌</span><h4>Breaking Changes</h4></div>
  $(ToListHtml $ai.breaking_changes)
</div>
"@
  }
  if ($ai.key_features -and $ai.key_features.Count) {
    $sectionsHtml += @"
<div class="aks-rel-sec">
  <div class="aks-rel-sec-head"><span class="aks-rel-ico">🔑</span><h4>Key Features</h4></div>
  $(ToListHtml $ai.key_features)
</div>
"@
  }
  if ($ai.good_to_know -and $ai.good_to_know.Count) {
    $sectionsHtml += @"
<div class="aks-rel-sec">
  <div class="aks-rel-sec-head"><span class="aks-rel-ico">💡</span><h4>Good to Know</h4></div>
  $(ToListHtml $ai.good_to_know)
</div>
"@
  }

  $badge = if ($isPrerelease) { '<span class="aks-rel-badge">Pre-release</span>' } else { '' }

  $card = @"
<div class="aks-rel-card">
  <div class="aks-rel-head">
    <div class="aks-rel-title">
      <h3>$title</h3>$badge
    </div>
    <a class="aks-rel-link" href="$url" target="_blank" rel="noopener">View Release</a>
  </div>
  <div class="aks-rel-meta">
    <span class="aks-rel-date">$publishedAt</span>
    <span class="aks-rel-version">$version</span>
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
# PAGE HTML (Tabs + Panels)
# =========================
$lastUpdated = (Get-Date -Format 'dd/MM/yyyy, HH:mm:ss')
$updateCount = $groups.Keys.Count

# Build "N release(s)" label safely outside the here-string
[string]$relPlural = if ($releases.Count -ne 1) { 's' } else { '' }
$releasesCountLabel = "$($releases.Count) release$relPlural"


$html = @"
<div class="aks-updates" data-since="$SINCE_ISO">

  <div class="aks-intro">
    <p>Welcome! This tool automatically tracks and summarizes meaningful updates to the Azure Kubernetes Service (AKS) documentation and releases.</p>
    <p>It filters out typos, minor edits, and bot changes, so you only see what really matters.<br>
    Check back often as data is automatically refreshed every 12 hours.</p>
  </div>

  <div class="aks-tabs">
    <nav class="aks-tabs-nav">
      <a class="aks-tab-link active" href="#aks-tab-docs">Documentation Updates</a>
      <a class="aks-tab-link" href="#aks-tab-releases">AKS Releases</a>
    </nav>

    <div class="aks-tab-panel" id="aks-tab-releases">
      <div class="aks-releases">
        <div class="aks-rel-header">
          <h2>AKS Releases</h2>
          <div class="aks-docs-desc">Latest 5 AKS releases with AI-generated summaries, breaking changes, and Good to Know information.</div>
          <span class="aks-pill aks-pill-count">$releasesCountLabel</span>
        </div>
        $releasesHtml
      </div>
    </div>

    <div class="aks-tab-panel active" id="aks-tab-docs">
      <div class="aks-docs-desc">Meaningful updates to the Azure Kubernetes Service (AKS) documentation from the last 7 days.</div>
      <div class="aks-docs-updated-main">
        <span class="aks-pill aks-pill-updated">Last updated: $lastUpdated</span>
        <span class="aks-pill aks-pill-count">$updateCount updates</span>
      </div>
      <div class="aks-docs-list">
        $($sections -join "`n")
      </div>
    </div>
  </div>

</div>
"@.Trim()

# =========================
# OUTPUT (JSON with html + hash)
# =========================
$sha256 = [System.Security.Cryptography.SHA256]::Create()
$bytes = [Text.Encoding]::UTF8.GetBytes($html)
$hash = ($sha256.ComputeHash($bytes) | ForEach-Object { $_.ToString("x2") }) -join ""

[pscustomobject]@{ html = $html; hash = $hash; ai_summaries = $summaries } | ConvertTo-Json -Depth 6
