#!/usr/bin/env pwsh
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# =========================
# CONFIG / ENV
# =========================
$Owner = "MicrosoftDocs"
$Repo = "azure-aks-docs"

$GitHubToken = $env:GITHUB_TOKEN
if (-not $GitHubToken) { Write-Error "GITHUB_TOKEN not set"; exit 1 }

# Prefer OpenAI if OpenAIKey exists, else AzureOpenAI if all vars exist, else disabled
$PreferProvider = if ($env:OpenAIKey) { 'OpenAI' } elseif ($env:AZURE_OPENAI_APIURI -and $env:AZURE_OPENAI_KEY -and $env:AZURE_OPENAI_API_VERSION -and $env:AZURE_OPENAI_DEPLOYMENT) { 'AzureOpenAI' } else { '' }

# AI gate threshold (higher = stricter) — LOOSER by default; can override via env
$MinAIScore = if ($env:AI_MIN_SCORE) { [double]$env:AI_MIN_SCORE } else { 0.25 }

# =========================
# DOCS WINDOW (last 7 days from Europe/London midnight)
# =========================
try { $tz = [System.TimeZoneInfo]::FindSystemTimeZoneById("Europe/London") }
catch { try { $tz = [System.TimeZoneInfo]::FindSystemTimeZoneById("GMT Standard Time") } catch { $tz = [System.TimeZoneInfo]::Utc } }
$nowUtc = [DateTime]::UtcNow
$nowLocal = [System.TimeZoneInfo]::ConvertTimeFromUtc($nowUtc, $tz)
$sinceLocalMidnight = Get-Date -Date $nowLocal.ToString("yyyy-MM-dd") -Hour 0 -Minute 0 -Second 0
$sinceLocalMidnight = $sinceLocalMidnight.AddDays(-7)
$sinceMidnightUtc = [System.TimeZoneInfo]::ConvertTimeToUtc($sinceLocalMidnight, $tz)
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

function Log($msg) { Write-Host "[$(Get-Date -Format HH:mm:ss)] $msg" }

# =========================
# HELPERS
# =========================
function Escape-Html([string]$s) {
  if ($null -eq $s) { return "" }
  $s.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('"', '&quot;')
}
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
    -replace '[-_]+', ' ' `
    -replace '\s{2,}', ' ' `
    -replace '^\s+|\s+$', ''
  $name = Convert-ToTitleCase $name
  $name = $name -replace '\bAks\b', 'AKS' `
    -replace '\bAad\b', 'AAD' `
    -replace '\bCli\b', 'CLI' `
    -replace '\bRbac\b', 'RBAC' `
    -replace '\bIp\b', 'IP' `
    -replace '\bIps\b', 'IPs' `
    -replace '\bVm(s)?\b', 'VM$1' `
    -replace '\bVnet(s)?\b', 'VNet$1' `
    -replace '\bApi\b', 'API' `
    -replace '\bUrl(s)?\b', 'URL$1'
  return $name
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
  $t = $t -replace '^\s*([-*+]|\d+\.)\s+', '', 'Multiline'
  $t = $t -replace '^\s*>\s?', '', 'Multiline'
  $t = [regex]::Replace($t, '\r', '')
  $t = [regex]::Replace($t, '\n{3,}', "`n`n")
  $t.Trim()
}

# ---------- Title & Kind helpers (short titles) ----------
function Get-FirstSentence([string]$text) {
  if ([string]::IsNullOrWhiteSpace($text)) { return "" }
  $t = $text.Trim()
  $parts = [regex]::Split($t, '(?<=[\.!?])\s+')
  if ($parts.Count -gt 0) { return $parts[0].Trim(@([char]' ', [char]'"', [char]0x27)) }  # fix: Trim takes char[]
  return $t
}
function InferShortAction([string]$summary) {
  if ([string]::IsNullOrWhiteSpace($summary)) { return "Update" }
  $s = $summary.ToLower()
  if ($s -match '\b(deprecat|retir)\w*\b') { return "Deprecation" }
  if ($s -match '\b(new|introduc|add(ed)?|create)\b') { return "New" }
  if ($s -match '\b(overhaul|rework|rewrite|significant|major)\b') { return "Rework" }
  if ($s -match '\b(migrat|replace|move)\w*\b') { return "Migration" }
  if ($s -match '\b(fix|correct|clarif)\w*\b') { return "Clarification" }
  return "Update"
}
function Build-ShortTitle([string]$display, [string]$summary, [string]$kind) {
  # Prefer the kind/action label; keep it compact
  $action = if ($kind) { $kind } else { InferShortAction $summary }
  return "$display — $action"
}
function Get-SessionKind($session, $verdict) {
  $hasAdded   = ($session.items | Where-Object { $_.status -eq 'added' }).Count -gt 0
  $hasRemoved = ($session.items | Where-Object { $_.status -eq 'removed' }).Count -gt 0

  $delta = ( ($session.items | Measure-Object -Sum -Property additions).Sum +
             ($session.items | Measure-Object -Sum -Property deletions).Sum )
  $commits = $session.items.Count

  $summary = ($verdict.summary ?? "")
  $heavySummary = $summary -match '(?i)\b(overhaul|rework|rewrite|significant|major)\b'

  if ($hasRemoved -and -not $hasAdded) { return "Removal" }
  if ($hasAdded) { return "New" }
  if ($heavySummary -or $delta -ge 80 -or $commits -ge 3) { return "Rework" }
  return "Update"
}
function KindToPillHtml([string]$kind) {
  $emoji = switch ($kind) {
    "New"         { "🆕" }
    "Rework"      { "♻️" }
    "Removal"     { "🗑️" }
    "Deprecation" { "⚠️" }
    "Migration"   { "➡️" }
    "Clarification" { "ℹ️" }
    default       { "✨" }
  }
  $class = switch ($kind) {
    "New"     { "aks-pill-kind aks-pill-new" }
    "Rework"  { "aks-pill-kind aks-pill-rework" }
    "Removal" { "aks-pill-kind aks-pill-removal" }
    default   { "aks-pill-kind aks-pill-update" }
  }
  "<span class=""$class"">$emoji $kind</span>"
}

# =========================
# FILTERS (minimal — only bot + scope to AKS .md)
# =========================
function Test-IsBot($Item) {
  $login = $Item.user.login
  return ($login -match '(bot|actions|github-actions|dependabot)')
}
function Test-IsDocsNoisePath([string]$Path) {
  # ALLOW all .md under aks — includes `/includes` and TOC; AI will filter noise
  if ($Path -notmatch '^articles/(azure/)?aks/.*\.md$') { return $true }
  return $false
}

# =========================
# FETCH PRs MERGED LAST 7 DAYS (use merged_at)
# =========================
function Get-RecentMergedPRs {
  param([string]$Owner, [string]$Repo, [string]$SinceIso)
  $sinceDate = ([DateTime]::Parse($SinceIso)).ToString('yyyy-MM-dd')
  $q = "repo:$Owner/$Repo is:pr is:merged merged:>=$sinceDate"
  $perPage = 100; $page = 1; $all = @()
  do {
    $uri = "https://api.github.com/search/issues?q=$([uri]::EscapeDataString($q))&per_page=$perPage&page=$page"
    $resp = Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
    if (-not $resp.items) { break }
    $all += $resp.items
    $page++
  } while ($resp.items.Count -eq $perPage)
  return $all
}
function Get-PRDetails { param([int]$Number)
  $uri = "https://api.github.com/repos/$Owner/$Repo/pulls/$Number"
  Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
}
function Get-PRFiles { param([int]$Number)
  $perPage = 100; $page = 1; $files = @()
  do {
    $uri = "https://api.github.com/repos/$Owner/$Repo/pulls/$Number/files?per_page=$perPage&page=$page"
    $resp = Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
    if (-not $resp) { break }
    $files += $resp; $page++
  } while ($resp.Count -eq $perPage)
  return $files
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

function Get-FileSessionVerdictsViaAssistant {
  param([string]$JsonPath, [string]$Model = "gpt-4o-mini")
  if (-not $PSAIReady) { return @{} }
  try {
    Log "Uploading JSON to AI provider..."
    $file = Invoke-OAIUploadFile -Path $JsonPath -Purpose assistants -ErrorAction Stop
    $vsName = "aks-docs-file-verdicts-$(Get-Date -Format 'yyyyMMddHHmmss')"
    $vs = New-OAIVectorStore -Name $vsName -FileIds $file.id
    Log "Waiting on vector store processing..."
    do {
      Start-Sleep -Seconds 2
      $current = Get-OAIVectorStore -limit 100 -order desc | Where-Object { $_.id -eq $vs.id }
      if ($current) { $vs = $current }
      Log "Vector store status: $($vs.status)"
    } while ($vs.status -ne 'completed')

$instructions = @"
You are an assistant that summarizes Azure AKS documentation file changes.

You receive file-sessions with:
- file, total_additions, total_deletions, commits_count
- commit_titles[], patch_sample (first ~600 +/- lines)

For each session, write a short, factual 1–2 sentence summary of what changed.
Focus on concrete details visible in the patch, such as section names, parameter changes, new examples, or removals.

Always provide a "verdict" of "keep".
Also include:
- "score": 1.0
- "category": one of Networking, Security, Compute, Storage, Operations, General (best guess)
- "summary": your short summary

Never skip a session. If unsure, say "Minor text changes" in summary.

Output ONLY JSON array:
[
  { "key": "<same key>", "verdict": "keep", "score": 1.0, "reason": "always kept", "category": "General", "summary": "..." }
]
Plain strings only.
"@


    $assistant = New-OAIAssistant -Name "AKS-Docs-FileVerdict-Summarizer" -Instructions $instructions -Tools @{ type = 'file_search' } -ToolResources @{ file_search = @{ vector_store_ids = @($vs.id) } } -Model $Model
    $userMsg = "Return ONLY the JSON array of verdicts as specified."
    $run = New-OAIThreadAndRun -AssistantId $assistant.id -Thread @{ messages = @(@{ role = 'user'; content = $userMsg }) } -MaxCompletionTokens 1400 -Temperature 0.1
    $run = Wait-OAIOnRun -Run $run -Thread @{ id = $run.thread_id }

    $last = (Get-OAIMessage -ThreadId $run.thread_id -Order desc -Limit 1).data[0].content | Where-Object { $_.type -eq 'text' } | ForEach-Object { $_.text.value } | Out-String
    $clean = $last -replace '^\s*```(?:json)?\s*', '' -replace '\s*```\s*$', ''
    $match = [regex]::Match($clean, '\[(?:[^][]|(?<open>\[)|(?<-open>\]))*\](?(open)(?!))', 'Singleline')
    if (-not $match.Success) { Log "AI: No JSON array found in response."; return @{} }

    $arr = $match.Value | ConvertFrom-Json -ErrorAction Stop
    $map = @{}
    foreach ($i in $arr) {
      $k = $i.key
      if (-not $k) { continue }
      $map[$k] = @{
        verdict  = ($i.verdict ?? "skip")
        score    = [double]($i.score ?? 0)
        reason   = ($i.reason ?? "")
        category = ($i.PSObject.Properties['category'] ? $i.category : 'General')
        summary  = ($i.PSObject.Properties['summary']  ? $i.summary  : "")
      }
    }
    Log "AI: Verdicts ready for $($map.Keys.Count) file sessions."
    return $map
  }
  catch { Write-Warning "AI verdicts failed: $_"; return @{} }
}

# =========================
# MAIN FLOW — DOCS (PRs → file sessions)
# =========================
Log "Fetching PRs merged in last 7 days..."
$prs = Get-RecentMergedPRs -Owner $Owner -Repo $Repo -SinceIso $SINCE_ISO
$prs = $prs | Where-Object { -not (Test-IsBot $_) }
Log "Found $($prs.Count) merged PR(s) in window."

$events = @()
foreach ($pr in $prs) {
  $number = $pr.number
  if (-not $number) { continue }

  $prDetail = Get-PRDetails -Number $number
  if (-not $prDetail.merged_at) { continue }  # safety

  $mergedAt = [DateTime]::Parse($prDetail.merged_at).ToUniversalTime()
  $author   = $prDetail.user.login
  $title    = $prDetail.title
  $prUrl    = $prDetail.html_url

  $files = Get-PRFiles -Number $number
  if (-not $files) { continue }

  # Keep all AKS docs markdown (includes `/includes` and TOC)
  $files = $files | Where-Object { $_.filename -match '^articles/(azure/)?aks/.*\.md$' -and -not (Test-IsDocsNoisePath $_.filename) }
  if (-not $files) { continue }

  foreach ($f in $files) {
    $events += [pscustomobject]@{
      filename     = $f.filename
      status       = $f.status             # added | modified | removed | renamed
      committed_at = $mergedAt             # use merged time for sessioning
      author       = $author
      pr_number    = $number
      pr_url       = $prUrl
      commit_msg   = $title                # PR title
      commit_url   = $prUrl
      additions    = $f.additions
      deletions    = $f.deletions
      patch        = $f.patch
    }
  }
}

# Group by file into time-boxed sessions (6-hour window)
function Group-FileChangeSessions {
  param([Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Events,[int]$GapHours = 6)
  $byFile = $Events | Group-Object filename
  $sessions = @()
  foreach ($g in $byFile) {
    $items = $g.Group | Sort-Object committed_at
    if (-not $items) { continue }
    $current = @(); $lastAt = [DateTime]::MinValue
    foreach ($it in $items) {
      if ($current.Count -eq 0) { $current += $it; $lastAt = $it.committed_at; continue }
      $gap = ($it.committed_at - $lastAt).TotalHours
      if ($gap -le $GapHours) { $current += $it }
      else {
        $sessions += [pscustomobject]@{ file=$g.Name; start_at=$current[0].committed_at; end_at=$current[-1].committed_at; items=$current }
        $current = @($it)
      }
      $lastAt = $it.committed_at
    }
    if ($current.Count -gt 0) {
      $sessions += [pscustomobject]@{ file=$g.Name; start_at=$current[0].committed_at; end_at=$current[-1].committed_at; items=$current }
    }
  }
  return $sessions
}

if (-not $events -or $events.Count -eq 0) { Log "No qualifying doc events found in window."; $sessions = @() }
else { $sessions = Group-FileChangeSessions -Events $events -GapHours 6 }

# Build AI input for file sessions (NO pre-AI trimming)
$TmpRoot = $env:RUNNER_TEMP; if (-not $TmpRoot) { $TmpRoot = [System.IO.Path]::GetTempPath() }
$aiJsonPath = Join-Path $TmpRoot ("aks-file-sessions-{0}.json" -f (Get-Date -Format 'yyyyMMddHHmmss'))

$fileSessionPayload = @(
  foreach ($s in $sessions) {
    $key = ("{0}|{1}|{2}" -f $s.file, $s.start_at.ToString('yyyyMMddHHmmss'), $s.end_at.ToString('yyyyMMddHHmmss'))
    $adds = ($s.items | Measure-Object -Sum -Property additions).Sum
    $dels = ($s.items | Measure-Object -Sum -Property deletions).Sum
    $commitsCount = $s.items.Count
    $lines = @()
    foreach ($it in $s.items) { if ($it.patch) { $lines += (($it.patch -split "`n") | Where-Object { $_ -match '^[\+\-]' }) } }
    $patchSample = ($lines | Select-Object -First 600) -join "`n"
    [pscustomobject]@{
      key             = $key
      file            = $s.file
      start_at        = $s.start_at.ToString('o')
      end_at          = $s.end_at.ToString('o')
      total_additions = $adds
      total_deletions = $dels
      commits_count   = $commitsCount
      commit_titles   = ($s.items.commit_msg | Select-Object -Unique)
      patch_sample    = $patchSample
    }
  }
)
$aiInput = [pscustomobject]@{ since = $SINCE_ISO; file_sessions = $fileSessionPayload }
$aiInput | ConvertTo-Json -Depth 6 | Set-Content -Path $aiJsonPath -Encoding UTF8

Log "AI Verdicts"
Log "  [AKS] Prepared AI input: $aiJsonPath"

$aiVerdicts = @{}
if ($PreferProvider -and $sessions.Count -gt 0) { $aiVerdicts = Get-FileSessionVerdictsViaAssistant -JsonPath $aiJsonPath }
else { Log "AI disabled or no file sessions." }

# =========================
# RENDER DOCS — show everything; AI only decorates
# =========================
$sections = New-Object System.Collections.Generic.List[string]

foreach ($s in ($sessions | Sort-Object end_at -Descending)) {
  $key = ("{0}|{1}|{2}" -f $s.file, $s.start_at.ToString('yyyyMMddHHmmss'), $s.end_at.ToString('yyyyMMddHHmmss'))
  $v = $aiVerdicts[$key]  # may be $null

  # --- fields (with safe fallbacks if AI is null)
  $fileUrl  = Get-LiveDocsUrl -FilePath $s.file
  $display  = Get-DocDisplayName $s.file

  $adds = ($s.items | Measure-Object -Sum -Property additions).Sum
  $dels = ($s.items | Measure-Object -Sum -Property deletions).Sum
  $statusSet = ($s.items.status | Select-Object -Unique) -join ', '

  $summary  = if ($v -and $v.summary) { $v.summary } else { "Changes ($statusSet): +$adds / -$dels." }
  $category = if ($v -and $v.category) { $v.category } else { "General" }

  $kind     = Get-SessionKind -session $s -verdict $v
  $title    = Build-ShortTitle -display $display -summary $summary -kind $kind
  $lastAt   = $s.end_at.ToString('yyyy-MM-dd HH:mm')
  $kindPill = KindToPillHtml $kind

  # PR link (use first item)
  $prNum = $s.items[0].pr_number
  $prUrl = $s.items[0].pr_url
  $prLink = if ($prNum) { "<a class=""aks-doc-pr"" href=""$prUrl"" target=""_blank"" rel=""noopener"">PR #$prNum</a>" } else { "" }

  $section = @"
<div class="aks-doc-update">
  <h2><a href="$fileUrl">$(Escape-Html (Truncate $title 120))</a></h2>
  <div class="aks-doc-header">
    <span class="aks-doc-category">$category</span>
    $kindPill
    <span class="aks-doc-updated-pill">Last updated: $lastAt</span>
    $prLink
  </div>
  <div class="aks-doc-summary">
    <strong>Summary</strong>
    <p>$(Escape-Html $summary)</p>
  </div>
  <div class="aks-doc-buttons">
    <a class="aks-doc-link" href="$fileUrl" target="_blank" rel="noopener">View Documentation</a>
  </div>
</div>
"@
  $sections.Add($section.Trim())
}

# =========================
# MAIN FLOW — RELEASES (unchanged)
# =========================
function Get-GitHubReleases([string]$owner, [string]$repo, [int]$count = 5) {
  $uri = "https://api.github.com/repos/$owner/$repo/releases?per_page=$count"
  try { Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET }
  catch { Write-Warning ("Failed to fetch releases from {0}/{1}: {2}" -f $owner, $repo, $_.Exception.Message); return @() }
}
$releases = Get-GitHubReleases -owner $ReleasesOwner -repo $ReleasesRepo -count $ReleasesCount

$TmpRoot = $env:RUNNER_TEMP; if (-not $TmpRoot) { $TmpRoot = [System.IO.Path]::GetTempPath() }
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
  { ""id"": <same id>, ""summary"": ""1-3 sentences"", ""breaking_changes"": [""...""], ""key_features"": [""...""], ""good_to_know"": [""...""] }
]
Plain strings only.
"@

      $assistant = New-OAIAssistant -Name "AKS-Releases-Summarizer" -Instructions $instructions -Tools @{ type = 'file_search' } -ToolResources @{ file_search = @{ vector_store_ids = @($vs.id) } } -Model $Model
      $userMsg = "Summarize each release by ID. Return ONLY the JSON array."
      $run = New-OAIThreadAndRun -AssistantId $assistant.id -Thread @{ messages = @(@{ role = 'user'; content = $userMsg }) } -MaxCompletionTokens 1500 -Temperature 0.2
      $run = Wait-OAIOnRun -Run $run -Thread @{ id = $run.thread_id }

      $last = (Get-OAIMessage -ThreadId $run.thread_id -Order desc -Limit 1).data[0].content | Where-Object { $_.type -eq 'text' } | ForEach-Object { $_.text.value } | Out-String
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
    catch { Write-Warning "AI summaries (releases) failed: $_"; return @{} }
  }
  $releaseSummaries = Get-ReleaseSummariesViaAssistant -JsonPath $relJsonPath
}
else { Log "AI disabled or no releases." }

function ToListHtml($arr) {
  if (-not $arr -or $arr.Count -eq 0) { return "" }
  $lis = ($arr | ForEach-Object { '<li>' + (Escape-Html $_) + '</li>' }) -join ''
  return "<ul class=""aks-rel-list"">$lis</ul>"
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
    $ai = @{ summary = Truncate $bodyPlain 400; breaking_changes=@(); key_features=@(); good_to_know=@() }
  }

  $summaryHtml = "<p>" + (Escape-Html $ai.summary) + "</p>"
  $sectionsHtml = ""
  if ($ai.breaking_changes -and $ai.breaking_changes.Count) { $sectionsHtml += "<div class=""aks-rel-sec""><div class=""aks-rel-sec-head""><span class=""aks-rel-ico"">❌</span><h3>Breaking Changes</h3></div>$(ToListHtml $ai.breaking_changes)</div>" }
  if ($ai.key_features -and $ai.key_features.Count)   { $sectionsHtml += "<div class=""aks-rel-sec""><div class=""aks-rel-sec-head""><span class=""aks-rel-ico"">🔑</span><h3>Key Features</h3></div>$(ToListHtml $ai.key_features)</div>" }
  if ($ai.good_to_know -and $ai.good_to_know.Count)   { $sectionsHtml += "<div class=""aks-rel-sec""><div class=""aks-rel-sec-head""><span class=""aks-rel-ico"">💡</span><h3>Good to Know</h3></div>$(ToListHtml $ai.good_to_know)</div>" }
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
$updateCount = $sections.Count

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
      <div class="aks-docs-desc">PRs merged in the last 7 days; AI filters & summarizes page-level changes.</div>
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

[pscustomobject]@{ html = $html; hash = $hash; ai_summaries = $aiVerdicts } | ConvertTo-Json -Depth 6
