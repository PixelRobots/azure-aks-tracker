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
$ReleasesOwner = "Azure"   # change if needed
$ReleasesRepo  = "AKS"     # change to the repo that actually publishes AKS releases
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

# Aggressive Markdown→plain fallback for release notes
function Convert-MarkdownToPlain([string]$md) {
  if (-not $md) { return "" }
  $t = $md
  # Remove code blocks
  $t = [regex]::Replace($t, '```[\s\S]*?```', '', 'Singleline')
  # Images ![alt](url) -> alt
  $t = [regex]::Replace($t, '!\[([^\]]*)\]\([^)]+\)', '$1')
  # Links [text](url) -> text
  $t = [regex]::Replace($t, '\[([^\]]+)\]\([^)]+\)', '$1')
  # Headings, emphasis, inline code, lists markers
  $t = $t -replace '(^|\n)#{1,6}\s*', '$1'
  $t = $t -replace '(\*\*|__)(.*?)\1', '$2'
  $t = $t -replace '(\*|_)(.*?)\1', '$2'
  $t = $t -replace '`([^`]+)`', '$1'
  $t = $t -replace '^\s*([-*+]|\d+\.)\s+', '', 'Multiline'
  # Blockquotes
  $t = $t -replace '^\s*>\s?', '', 'Multiline'
  # Excess whitespace
  $t = [regex]::Replace($t, '\r', '')
  $t = [regex]::Replace($t, '\n{3,}', "`n`n")
  $t.Trim()
}

# =========================
# FILTERS
# =========================
function Test-IsBot($Item) {
  $login = $Item.user.login
  return ($login -match '(bot|actions|github-actions|dependabot)')
}
function Test-IsNoiseMessage([string]$Message) {
  if (-not $Message) { return $false }
  $patterns = @(
    '^\s*merge\b', '^\s*sync\b', 'publish from', 'update submodule',
    '\btypo\b', '\bgrammar\b', '\blink[- ]?fix\b', '\bformat(ting)?\b',
    '\breadme\b', '^\s*chore\b', '^\s*ci\b', '^\s*build\b', 'automation',
    'localization', '\bloc\b', 'update\s+(metadata|front[- ]?matter)'
  )
  foreach ($p in $patterns) { if ($Message -imatch $p) { return $true } }
  return $false
}

# Commit-file trivial detector (front-matter/link-only/tiny)
function Test-IsDocsTrivialCommit {
  param(
    [object[]]$Files,
    [string]$Title = ''
  )
  if (-not $Files -or $Files.Count -eq 0) { return $true }

  # Only .md touched? If other assets changed, treat as non-trivial
  $allMd = ($Files | Where-Object { $_.filename -match '\.md$' }).Count -eq $Files.Count
  if (-not $allMd) { return $false }

  # Super tiny across all files
  $adds = ($Files | Measure-Object -Sum -Property additions).Sum
  $dels = ($Files | Measure-Object -Sum -Property deletions).Sum
  if (($adds + $dels) -le 4 -and $Files.Count -le 2) { return $true }

  foreach ($f in $Files) {
    $p = $f.patch
    if (-not $p) { continue }
    $lines = ($p -split "`n") | Where-Object { $_ -match '^[\+\-]' }
    foreach ($line in $lines) {
      $content = $line.Substring(1)

      # front matter bumps
      if ($content -match '^\s*ms\.(date|service|topic|author|reviewer|custom|subservice)\s*:') { continue }
      # link-only edits
      if ($content -match '\[[^\]]*\]\((https?://[^)]+)\)' -or $content -match 'https?://') { continue }
      # whitespace/punctuation-only
      $stripped = ($content -replace '[\s\p{P}]','')
      if ([string]::IsNullOrWhiteSpace($stripped)) { continue }

      # Non-trivial content found
      return $false
    }
  }

  # commit title hints
  if ($Title -imatch 'typo|grammar|spelling|link(s)?|format(ting)?|whitespace|lint|style|loc') { return $true }

  # If we got here, all changes seen were trivial
  return $true
}

# =========================
# FETCH COMMITS LAST 7 DAYS
# =========================
function Get-RecentCommits {
  $all = @()
  for ($page = 1; $page -le 5; $page++) {
    $uri = "https://api.github.com/repos/$Owner/$Repo/commits?since=$SINCE_ISO&per_page=100&page=$page"
    $resp = Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
    if (-not $resp) { break }
    $all += $resp
    if ($resp.Count -lt 100) { break }
  }
  return $all
}

function Get-CommitFiles($Sha) {
  $uri = "https://api.github.com/repos/$Owner/$Repo/commits/$Sha"
  $resp = Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
  return $resp.files
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

# ===== File-session AI (vector-store) =====
function Get-FileSessionSummariesViaAssistant {
  param([string]$JsonPath, [string]$Model = "gpt-4o-mini")
  if (-not $PSAIReady) { return @{} }
  try {
    Log "Uploading JSON to AI provider..."
    $file = Invoke-OAIUploadFile -Path $JsonPath -Purpose assistants -ErrorAction Stop

    $vsName = "aks-docs-file-sessions-$(Get-Date -Format 'yyyyMMddHHmmss')"
    $vs = New-OAIVectorStore -Name $vsName -FileIds $file.id
    Log "Waiting on vector store processing..."
    do {
      Start-Sleep -Seconds 2
      $current = Get-OAIVectorStore -limit 100 -order desc | Where-Object { $_.id -eq $vs.id }
      if ($current) { $vs = $current }
      Log "Vector store status: $($vs.status)"
    } while ($vs.status -ne 'completed')

    $instructions = @"
You receive AKS docs *file sessions*. Each item has:
- key: stable identifier for the session
- file: markdown doc path
- commit_titles: commit messages (unique)
- patch_sample: first ~150 +/- lines across commits in the session

Task: Summarize only *substantive* content changes (new sections/steps/parameters, breaking notes, meaningful rewrites).
Ignore trivial edits (typos, link target changes, ms.date/front-matter, whitespace).

Return ONLY a JSON array like:
[
  { "key":"<same key>", "file":"<path>", "summary":"2-3 sentences", "category":"Networking|Security|Compute|Storage|Operations|General" }
]
No markdown in values.
"@

    $assistant = New-OAIAssistant `
      -Name "AKS-Docs-FileSession-Summarizer" `
      -Instructions $instructions `
      -Tools @{ type = 'file_search' } `
      -ToolResources @{ file_search = @{ vector_store_ids = @($vs.id) } } `
      -Model $Model

    $userMsg = "Summarize each file session by key and return ONLY the JSON array as described."
    $run = New-OAIThreadAndRun -AssistantId $assistant.id -Thread @{ messages = @(@{ role = 'user'; content = $userMsg }) } -MaxCompletionTokens 1200 -Temperature 0.2
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
      $k = $i.key
      if (-not $k) { continue }
      $map[$k] = @{
        file     = $i.file
        summary  = $i.summary
        category = $i.PSObject.Properties['category'] ? $i.category : 'General'
      }
    }
    Log "AI: Summaries ready for $($map.Keys.Count) file sessions."
    return $map
  }
  catch {
    Write-Warning "AI summaries (file sessions) failed: $_"
    return @{}
  }
}

# =========================
# MAIN FLOW — DOCS (commit → file sessions)
# =========================
Log "Fetching commits merged in last 7 days..."
$commits = Get-RecentCommits | Where-Object { -not (Test-IsBot $_) }
Log "Found $($commits.Count) commit(s) in window."

# Collect commit-file events (already filtered)
$events = @()
foreach ($commit in $commits) {
  $msg = $commit.commit.message
  if (Test-IsNoiseMessage $msg) { continue }

  $sha    = $commit.sha
  $author = $commit.commit.author.name
  $date   = [DateTime]::Parse($commit.commit.author.date).ToUniversalTime()
  $url    = $commit.html_url

  $files = Get-CommitFiles $sha | Where-Object {
    $_.filename -match '^articles/.*\.md$' -and $_.filename -notmatch '/includes/|/media/'
  }
  if (-not $files) { continue }
  if (Test-IsDocsTrivialCommit -Files $files -Title $msg) { continue }

  foreach ($f in $files) {
    # Keep per-file event; store patch so AI can see actual +/- lines
    $events += [pscustomobject]@{
      filename     = $f.filename
      committed_at = $date
      author       = $author
      commit_msg   = $msg
      commit_url   = $url
      additions    = $f.additions
      deletions    = $f.deletions
      patch        = $f.patch
    }
  }
}

# Group by file into time-boxed sessions (6-hour window)
function Group-FileChangeSessions {
  param(
    [Parameter(Mandatory)] [object[]]$Events,
    [int]$GapHours = 6
  )
  $byFile = $Events | Group-Object filename
  $sessions = @()

  foreach ($g in $byFile) {
    $items = $g.Group | Sort-Object committed_at
    if (-not $items) { continue }

    $current = @()
    $lastAt = [DateTime]::MinValue

    foreach ($it in $items) {
      if ($current.Count -eq 0) {
        $current += $it; $lastAt = $it.committed_at; continue
      }
      $gap = ($it.committed_at - $lastAt).TotalHours
      if ($gap -le $GapHours) {
        $current += $it
      } else {
        $sessions += [pscustomobject]@{
          file        = $g.Name
          start_at    = $current[0].committed_at
          end_at      = $current[-1].committed_at
          items       = $current
        }
        $current = @($it)
      }
      $lastAt = $it.committed_at
    }

    if ($current.Count -gt 0) {
      $sessions += [pscustomobject]@{
        file     = $g.Name
        start_at = $current[0].committed_at
        end_at   = $current[-1].committed_at
        items    = $current
      }
    }
  }

  return $sessions
}

$sessions = Group-FileChangeSessions -Events $events -GapHours 6

# Build AI input for file sessions
$TmpRoot = $env:RUNNER_TEMP; if (-not $TmpRoot) { $TmpRoot = [System.IO.Path]::GetTempPath() }
$aiJsonPath = Join-Path $TmpRoot ("aks-file-sessions-{0}.json" -f (Get-Date -Format 'yyyyMMddHHmmss'))

# Create stable keys so we can map summaries back (file|start|end)
$fileSessionPayload = @(
  foreach ($s in $sessions) {
    $key = ("{0}|{1}|{2}" -f $s.file, $s.start_at.ToString('yyyyMMddHHmmss'), $s.end_at.ToString('yyyyMMddHHmmss'))
    $lines = @()
    foreach ($it in $s.items) {
      if ($it.patch) {
        $lines += (($it.patch -split "`n") | Where-Object { $_ -match '^[\+\-]' })
      }
    }
    $patchSample = ($lines | Select-Object -First 150) -join "`n"
    [pscustomobject]@{
      key           = $key
      file          = $s.file
      start_at      = $s.start_at.ToString('o')
      end_at        = $s.end_at.ToString('o')
      commit_titles = ($s.items.commit_msg | Select-Object -Unique)
      patch_sample  = $patchSample
    }
  }
)

$aiInput = [pscustomobject]@{
  since = $SINCE_ISO
  file_sessions = $fileSessionPayload
}
$aiInput | ConvertTo-Json -Depth 6 | Set-Content -Path $aiJsonPath -Encoding UTF8

Log "AI Summaries"
Log "  [AKS] Prepared AI input: $aiJsonPath"

$summaries = @{}
if ($PreferProvider -and $sessions.Count -gt 0) {
  $summaries = Get-FileSessionSummariesViaAssistant -JsonPath $aiJsonPath
} else {
  Log "AI disabled or no file sessions."
}

# Render DOCS sections (one card per file-session)
$sections = New-Object System.Collections.Generic.List[string]
foreach ($s in ($sessions | Sort-Object end_at -Descending)) {
  $fileUrl  = Get-LiveDocsUrl -FilePath $s.file
  $title    = ($s.items | Sort-Object committed_at -Descending | Select-Object -First 1).commit_msg
  if (-not $title -or $title -eq "") { $title = ShortTitle $s.file }
  $lastAt   = $s.end_at.ToString('yyyy-MM-dd HH:mm')

  $key = ("{0}|{1}|{2}" -f $s.file, $s.start_at.ToString('yyyyMMddHHmmss'), $s.end_at.ToString('yyyyMMddHHmmss'))
  $summary  = $summaries[$key].summary
  $category = $summaries[$key].category

  # Minimum substance guard (if AI didn't produce a summary and delta is tiny)
  $delta = ( ($s.items | Measure-Object -Sum -Property additions).Sum +
             ($s.items | Measure-Object -Sum -Property deletions).Sum )
  if ($delta -lt 6 -and [string]::IsNullOrWhiteSpace($summary)) { continue }

  $commitsList = ($s.items | Sort-Object committed_at -Descending | Select-Object -First 3 |
    ForEach-Object { "<li><a href=""$($_.commit_url)"" target=""_blank"" rel=""noopener"">$(Escape-Html (Truncate $_.commit_msg 120))</a></li>" }) -join ''

  $section = @"
<div class="aks-doc-update">
  <h2><a href="$fileUrl">$(Escape-Html (Truncate $title 140))</a></h2>
  <div class="aks-doc-header">
    <span class="aks-doc-category">$category</span>
    <span class="aks-doc-updated-pill">Last updated: $lastAt</span>
  </div>
  <div class="aks-doc-summary">
    <strong>Summary</strong>
    <p>$(Escape-Html $summary)</p>
  </div>
  <ul class="aks-doc-files">
    <li>File: <a href="$fileUrl" target="_blank" rel="noopener">$(Escape-Html $s.file)</a></li>
  </ul>
  <details class="aks-commits"><summary>Recent commits in this session</summary><ul>$commitsList</ul></details>
  <div class="aks-doc-buttons">
    <a class="aks-doc-link" href="$fileUrl" target="_blank" rel="noopener">View Documentation</a>
  </div>
</div>
"@
  $sections.Add($section.Trim())
}

# =========================
# MAIN FLOW — RELEASES
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

# Build releases JSON for AI
$TmpRoot = $env:RUNNER_TEMP; if (-not $TmpRoot) { $TmpRoot = [System.IO.Path]::GetTempPath() }  # re-ensure
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
  # Reuse your existing releases assistant
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
The uploaded JSON contains an array of objects with: id, title, tag_name, published_at, body (markdown).
Return ONLY JSON with this exact shape:
[
  {
    "id": <same id as input>,
    "summary": "1-3 sentences plain text",
    "breaking_changes": ["..."],
    "key_features": ["..."],
    "good_to_know": ["..."]
  }
]
- Keep bullets concise (3-8 per section when applicable).
- No markdown in values, plain strings only.
"@

      $assistant = New-OAIAssistant `
        -Name "AKS-Releases-Summarizer" `
        -Instructions $instructions `
        -Tools @{ type = 'file_search' } `
        -ToolResources @{ file_search = @{ vector_store_ids = @($vs.id) } } `
        -Model $Model

      $userMsg = "Summarize each release in the uploaded JSON by ID. Only return the JSON array described in the instructions."
      $run = New-OAIThreadAndRun -AssistantId $assistant.id -Thread @{ messages = @(@{ role = 'user'; content = $userMsg }) } -MaxCompletionTokens 1500 -Temperature 0.2
      $run = Wait-OAIOnRun -Run $run -Thread @{ id = $run.thread_id }

      $last = (Get-OAIMessage -ThreadId $run.thread_id -Order desc -Limit 1).data[0].content |
        Where-Object { $_.type -eq 'text' } |
        ForEach-Object { $_.text.value } |
        Out-String

      $clean = $last -replace '^\s*```(?:json)?\s*', '' -replace '\s*```\s*$',''
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
  $releaseSummaries = Get-ReleaseSummariesViaAssistant -JsonPath $relJsonPath
} else {
  Log "AI disabled or no releases."
}

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

  # Get AI structured summary by release id; fallback to cleaned/truncated body
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
# PAGE HTML (Tabs + Panels)
# =========================
$lastUpdated = (Get-Date -Format 'dd/MM/yyyy, HH:mm:ss')
$updateCount = $sessions.Count

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
      <h2>AKS Documentation Updates</h2>
      <div class="aks-docs-desc">Meaningful updates to the Azure Kubernetes Service (AKS) documentation from the last 7 days.</div>
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

# =========================
# OUTPUT (JSON with html + hash)
# =========================
$sha256 = [System.Security.Cryptography.SHA256]::Create()
$bytes = [Text.Encoding]::UTF8.GetBytes($html)
$hash = ($sha256.ComputeHash($bytes) | ForEach-Object { $_.ToString("x2") }) -join ""

[pscustomobject]@{ html = $html; hash = $hash; ai_summaries = $summaries } | ConvertTo-Json -Depth 6
