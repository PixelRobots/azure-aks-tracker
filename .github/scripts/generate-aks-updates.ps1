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

# (Kept for compatibility; not used as a gate in rendering anymore)
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
    -replace '[-_]+' , ' ' `
    -replace '\s{2,}', ' ' `
    -replace '^\s+|\s+$', ''
  $name = Convert-ToTitleCase $name
  $name = $name -replace '\bAks\b','AKS' -replace '\bAad\b','AAD' -replace '\bCli\b','CLI' -replace '\bRbac\b','RBAC' `
                 -replace '\bIp\b','IP'  -replace '\bIps\b','IPs' -replace '\bVm(s)?\b','VM$1' -replace '\bVnet(s)?\b','VNet$1' `
                 -replace '\bApi\b','API' -replace '\bUrl(s)?\b','URL$1'
  return $name
}
function ShortTitle([string]$path) { ($path -split '/')[ -1 ] }
function Get-LiveDocsUrl([string]$FilePath) {
  if ($FilePath -match '^articles/(.+?)\.md$') {
    $p = $Matches[1] -replace '\\','/'
    if ($p -notmatch '^azure/') { $p = "azure/$p" }
    return "https://learn.microsoft.com/$p"
  }
  return "https://github.com/$Owner/$Repo/blob/main/$FilePath"
}
function Truncate([string]$text, [int]$max = 400) {
  if (-not $text) { return "" }
  $t = $text.Trim()
  if ($t.Length -le $max) { return $t }
  return $t.Substring(0,$max).TrimEnd() + "…"
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

# ===== Commits: helpers =====
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
function Get-CommitFiles { param([string]$Sha)
  $uri = "https://api.github.com/repos/$Owner/$Repo/commits/$Sha"
  Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
}

# ---------- Title & Kind helpers (short titles) ----------
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
# FILTERS (minimal — only bot + docs markdown paths)
# =========================
function Test-IsBot($Item) {
  $login = ""
  if ($Item.PSObject.Properties['user'] -and $Item.user -and $Item.user.login) { $login = $Item.user.login }
  elseif ($Item.PSObject.Properties['author'] -and $Item.author -and $Item.author.login) { $login = $Item.author.login }
  $name = ""
  if ($Item.PSObject.Properties['commit'] -and $Item.commit -and $Item.commit.author -and $Item.commit.author.name) { $name = $Item.commit.author.name }
  return ($login -match '(bot|actions|github-actions|dependabot)' -or $name -match '(?i)bot')
}
function Test-IsDocsNoisePath([string]$Path) {
  # Allow AKS + Fleet markdown only
  if ($Path -notmatch '^articles/(azure/)?(aks|kubernetes-fleet)/.*\.md$') { return $true }
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
  param([ValidateSet('OpenAI','AzureOpenAI')][string]$Provider)
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

function Get-FileBundleVerdictsViaAssistant {
  param([string]$JsonPath, [string]$Model = "gpt-4o-mini")
  if (-not $PSAIReady) { return @{} }
  try {
    Log "Uploading JSON to AI provider..."
    $file = Invoke-OAIUploadFile -Path $JsonPath -Purpose assistants -ErrorAction Stop
    $vsName = "aks-docs-file-bundles-$(Get-Date -Format 'yyyyMMddHHmmss')"
    $vs = New-OAIVectorStore -Name $vsName -FileIds $file.id
    Log "Waiting on vector store processing..."
    do {
      Start-Sleep -Seconds 2
      $current = Get-OAIVectorStore -limit 100 -order desc | Where-Object { $_.id -eq $vs.id }
      if ($current) { $vs = $current }
      Log "Vector store status: $($vs.status)"
    } while ($vs.status -ne 'completed')

$instructions = @"
You are a strict filter for Azure AKS documentation updates.

INPUT: A list of file-bundles (one per docs page for the last 7 days). Each bundle includes:
- file (path), total_additions, total_deletions, commits_count
- commit_titles[] (includes PR titles and commit messages)
- pr_numbers[], pr_urls[]
- patch_sample (unified diff with +/- lines)

TASK: Produce at most ONE result per bundle key (per docs page) by JOINING all PRs + commits for that page.
Keep ONLY pages with meaningful user-facing changes:
- Adds/removes sections, steps, tasks, or examples
- Changes to parameters/flags/values in procedures or CLI
- Version/support/limits/regions changes
- Security/networking/compatibility behavior changes
- New page (status=added) or major rewrite

SKIP (omit from output) if trivial:
- Typos, grammar, whitespace, heading case, formatting-only
- Front matter/ms.* metadata only
- Link retargets, bare URL tweaks, image path changes, TOC shuffles
- Tiny net change (<5 lines) with no headings/commands/code changed

RULES:
- When in doubt, SKIP.
- Never invent beyond the patch.
- ONE result maximum per key.
- IMPORTANT: The "key" MUST be copied EXACTLY from the input. Do not alter, shorten, or normalize it. If unsure, SKIP.

OUTPUT: JSON array of ONLY kept bundles:
[
  { ""key"": ""<same key>"", ""verdict"": ""keep"", ""score"": 0.0-1.0, ""category"": ""Networking|Security|Compute|Storage|Operations|General"", ""summary"": ""1–2 factual sentences naming sections/params if visible"" }
]
Return nothing for skipped bundles. Plain JSON only.
"@

    $assistant = New-OAIAssistant -Name "AKS-Docs-FileBundle-Summarizer" -Instructions $instructions -Tools @{ type = 'file_search' } -ToolResources @{ file_search = @{ vector_store_ids = @($vs.id) } } -Model $Model
    $userMsg = "Return ONLY the JSON array of verdicts as specified."
    $run = New-OAIThreadAndRun -AssistantId $assistant.id -Thread @{ messages = @(@{ role = 'user'; content = $userMsg }) } -MaxCompletionTokens 1400 -Temperature 0.1
    $run = Wait-OAIOnRun -Run $run -Thread @{ id = $run.thread_id }

    $last = (Get-OAIMessage -ThreadId $run.thread_id -Order desc -Limit 1).data[0].content | Where-Object { $_.type -eq 'text' } | ForEach-Object { $_.text.value } | Out-String
    $clean = $last -replace '^\s*```(?:json)?\s*','' -replace '\s*```\s*$',''
    $match = [regex]::Match($clean, '\[(?:[^][]|(?<open>\[)|(?<-open>\]))*\](?(open)(?!))', 'Singleline')
    if (-not $match.Success) { Log "AI: No JSON array found in response."; return @{ ordered=@(); byKey=@{} } }

    $arr = $match.Value | ConvertFrom-Json -ErrorAction Stop

    $ordered = @()
    $map = @{}
    foreach ($i in $arr) {
      $k = $i.key
      if (-not $k) { continue }
      $ordered += $i
      $map[$k] = @{
        verdict  = ($i.verdict ?? "keep")
        score    = [double]($i.score ?? 1.0)
        reason   = ($i.reason ?? "")
        category = ($i.PSObject.Properties['category'] ? $i.category : 'General')
        summary  = ($i.PSObject.Properties['summary']  ? $i.summary  : "")
      }
    }
    Log "AI: Verdicts ready for $($ordered.Count) kept bundle(s)."
    return @{ ordered = $ordered; byKey = $map }
  }
  catch { Write-Warning "AI verdicts failed: $_"; return @{ ordered=@(); byKey=@{} } }
}

# =========================
# MAIN FLOW — DOCS (PRs → + commits → bundles)
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
  if (-not $prDetail.merged_at) { continue }

  $mergedAt = [DateTime]::Parse($prDetail.merged_at).ToUniversalTime()
  $author   = $prDetail.user.login
  $title    = $prDetail.title
  $prUrl    = $prDetail.html_url

  $files = Get-PRFiles -Number $number
  if (-not $files) { continue }

  # Keep AKS + Fleet markdown
  $files = $files | Where-Object { $_.filename -match '\.md$' -and -not (Test-IsDocsNoisePath $_.filename) }
  if (-not $files) { continue }

  foreach ($f in $files) {
    $events += [pscustomobject]@{
      filename     = $f.filename
      status       = $f.status
      committed_at = $mergedAt
      author       = $author
      pr_number    = $number
      pr_url       = $prUrl
      commit_msg   = $title
      commit_url   = $prUrl
      additions    = $f.additions
      deletions    = $f.deletions
      patch        = $f.patch
    }
  }
}

# Also capture commits directly
Log "Fetching individual commits in last 7 days..."
$commitList = Get-RecentCommits -SinceIso $SINCE_ISO | Where-Object { -not (Test-IsBot $_) }
Log "Found $($commitList.Count) commits in window."

foreach ($c in $commitList) {
  $sha = $c.sha
  $detail = Get-CommitFiles -Sha $sha
  if (-not $detail) { continue }

  $when = if ($detail.commit.committer.date) { [DateTime]::Parse($detail.commit.committer.date).ToUniversalTime() }
          elseif ($detail.commit.author.date) { [DateTime]::Parse($detail.commit.author.date).ToUniversalTime() }
          else { [DateTime]::UtcNow }

  $author = $detail.commit.author.name
  $msg    = $detail.commit.message
  $url    = $detail.html_url

  foreach ($f in $detail.files) {
    if ($f.filename -match '\.md$' -and -not (Test-IsDocsNoisePath $f.filename)) {
      $events += [pscustomobject]@{
        filename     = $f.filename
        status       = $f.status
        committed_at = $when
        author       = $author
        pr_number    = $null
        pr_url       = $null
        commit_msg   = $msg
        commit_url   = $url
        additions    = $f.additions
        deletions    = $f.deletions
        patch        = $f.patch
      }
    }
  }
}

# Group by file into weekly bundles (one per file)
function Group-FileBundles {
  param([Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Events)

  $byFile = $Events | Group-Object filename
  $bundles = @()

  foreach ($g in $byFile) {
    $items   = $g.Group | Sort-Object committed_at
    if (-not $items) { continue }

    $startAt = $items[0].committed_at
    $endAt   = $items[-1].committed_at

    $adds = ($items | Measure-Object -Sum -Property additions).Sum
    $dels = ($items | Measure-Object -Sum -Property deletions).Sum

    $commitTitles = ($items.commit_msg | Where-Object { $_ } | Select-Object -Unique)
    $prNumbers    = ($items.pr_number  | Where-Object { $_ } | Select-Object -Unique)
    $prUrls       = ($items.pr_url     | Where-Object { $_ } | Select-Object -Unique)

    $lines = @()
    foreach ($it in $items) {
      if ($it.patch) {
        $lines += (($it.patch -split "`n") | Where-Object { $_ -match '^[\+\-]' })
      }
    }
    $patchSample = ($lines | Select-Object -First 1200) -join "`n"

    $bundles += [pscustomobject]@{
      file          = $g.Name
      start_at      = $startAt
      end_at        = $endAt
      items         = $items
      total_adds    = $adds
      total_dels    = $dels
      commits_count = $items.Count
      commit_titles = $commitTitles
      pr_numbers    = $prNumbers
      pr_urls       = $prUrls
      patch_sample  = $patchSample
    }
  }

  return $bundles
}

if (-not $events -or $events.Count -eq 0) { Log "No qualifying doc events found in window."; $bundles = @() }
else { $bundles = Group-FileBundles -Events $events }

# =========================
# Build AI input (one bundle per file; NO pre-AI trimming)
# =========================
$TmpRoot = $env:RUNNER_TEMP; if (-not $TmpRoot) { $TmpRoot = [System.IO.Path]::GetTempPath() }
$aiJsonPath = Join-Path $TmpRoot ("aks-file-bundles-{0}.json" -f (Get-Date -Format 'yyyyMMddHHmmss'))

# Keep a key->bundle map so we can render from AI results only
$bundleByKey = @{}

$fileBundlePayload = @(
  foreach ($b in $bundles) {
    $key = $b.file  # one key per docs page
    $bundleByKey[$key] = $b

    [pscustomobject]@{
      key             = $key
      file            = $b.file
      start_at        = $b.start_at.ToString('o')
      end_at          = $b.end_at.ToString('o')
      total_additions = $b.total_adds
      total_deletions = $b.total_dels
      commits_count   = $b.commits_count
      commit_titles   = $b.commit_titles
      pr_numbers      = $b.pr_numbers
      pr_urls         = $b.pr_urls
      patch_sample    = $b.patch_sample
    }
  }
)
$aiInput = [pscustomobject]@{ since = $SINCE_ISO; file_bundles = $fileBundlePayload }
$aiInput | ConvertTo-Json -Depth 6 | Set-Content -Path $aiJsonPath -Encoding UTF8

# =========================
# AI Verdicts (load + robust key matching + diagnostics)
# =========================
Log "AI Verdicts"
Log "[AKS] Prepared AI input: $aiJsonPath"

$aiVerdictsBundle = @{}
if ($PreferProvider -and $bundles.Count -gt 0) {
  $aiVerdictsBundle = Get-FileBundleVerdictsViaAssistant -JsonPath $aiJsonPath
} else {
  Log "AI disabled or no file bundles."
  $aiVerdictsBundle = @{ ordered = @(); byKey = @{} }
}

$aiList = @()
$aiDict = @{}
if ($aiVerdictsBundle.PSObject.Properties['ordered']) { $aiList = $aiVerdictsBundle.ordered }
if ($aiVerdictsBundle.PSObject.Properties['byKey'])    { $aiDict = $aiVerdictsBundle.byKey }

# --- Diagnostics: dump raw AI response count + sample keys
$rawCount = @($aiList).Count
if ($rawCount -gt 0) {
  $rawSample = (@($aiList) | Select-Object -First 5 | ForEach-Object { [string]($_.key) }) -join ' | '
  Log "AI raw kept count: $rawCount (sample keys: $rawSample)"
} else {
  Log "AI returned 0 kept bundles in its JSON array."
}

# Save raw AI list for post-mortem (non-fatal)
try {
  $aiRawPath = Join-Path $TmpRoot ("aks-ai-raw-{0}.json" -f (Get-Date -Format 'yyyyMMddHHmmss'))
  @($aiList) | ConvertTo-Json -Depth 6 | Set-Content -Path $aiRawPath -Encoding UTF8
  Log "AI raw output saved to: $aiRawPath"
} catch { Log "Warn: failed to write AI raw output: $($_.Exception.Message)" }

# --- Build a case-insensitive key map from bundles
$keyMap = @{}   # lower -> original
foreach ($k in $bundleByKey.Keys) { $keyMap[$k.ToLower()] = $k }

# --- Keep only rows whose keys map back to a known bundle (case-insensitive, trimmed)
$bad = New-Object System.Collections.Generic.List[object]
$normed = New-Object System.Collections.Generic.List[object]

foreach ($row in @($aiList)) {
  $k = ([string]$row.key).Trim()
  if (-not $k) { $bad.Add($row) | Out-Null; continue }
  $lk = $k.ToLower()
  if ($keyMap.ContainsKey($lk)) {
    # normalize key back to the exact original so downstream lookups work
    $row.key = $keyMap[$lk]
    $normed.Add($row) | Out-Null
  } else {
    $bad.Add($row) | Out-Null
  }
}

if ($bad.Count -gt 0) {
  $samples = ($bad | Select-Object -First 5 | ForEach-Object { [string]$_.key }) -join ' | '
  Log "AI returned $($bad.Count) item(s) with unknown key(s) after normalization. Sample: $samples"
}

$aiList = @($normed)

# --- De-dupe by key (prefer highest score)
if ($aiList.Count -gt 0) {
  $aiList = $aiList | Group-Object -Property key | ForEach-Object {
    $_.Group | Sort-Object @{Expression='score';Descending=$true} | Select-Object -First 1
  }
  $sampleKeys = ($aiList | Select-Object -First 5 | ForEach-Object { $_.key }) -join ' | '
  Log "AI kept keys after filtering: $($aiList.Count) (sample: $sampleKeys)"
} else {
  # Extra help when zero: show a few known bundle keys to compare
  $bundleSample = ($bundleByKey.Keys | Select-Object -First 5) -join ' | '
  Log "After filtering, 0 AI items remain. Bundle key sample (expected format): $bundleSample"
}

Log "AI will render $($aiList.Count) item(s) out of $($bundles.Count) bundles."

# =========================
# RENDER DOCS — render ONLY what AI returned (ordered)
# =========================
$sections = New-Object System.Collections.Generic.List[string]

foreach ($v in $aiList) {
  $key = $v.key
  $b   = $bundleByKey[$key]
  if (-not $b) { continue }  # safety

  $fileUrl  = Get-LiveDocsUrl -FilePath $b.file
  $display  = Get-DocDisplayName $b.file

  $adds = $b.total_adds
  $dels = $b.total_dels

  $summary  = if ($v.summary)  { $v.summary }  else { "Changes: +$adds / -$dels." }
  $category = if ($v.category) { $v.category } else { "General" }

  $kind     = Get-SessionKind -session $b -verdict $v
  $title    = Build-ShortTitle -display $display -summary $summary -kind $kind
  $lastAt   = $b.end_at.ToString('yyyy-MM-dd HH:mm')
  $kindPill = KindToPillHtml $kind

  # Prefer a PR link if one exists in the bundle
  $prNum = if ($b.pr_numbers -and $b.pr_numbers.Count -gt 0) { $b.pr_numbers[0] } else { $null }
  $prUrl = if ($b.pr_urls    -and $b.pr_urls.Count    -gt 0) { $b.pr_urls[0]    } else { $null }
  $prLink = if ($prNum -and $prUrl) { "<a class=""aks-doc-pr"" href=""$prUrl"" target=""_blank"" rel=""noopener"">PR #$prNum</a>" } else { "" }

  $sections.Add(@"
<div class=""aks-doc-update"">
  <h2><a href=""$fileUrl"">$(Escape-Html (Truncate $title 120))</a></h2>
  <div class=""aks-doc-header"">
    <span class=""aks-doc-category"">$category</span>
    $kindPill
    <span class=""aks-doc-updated-pill"">Last updated: $lastAt</span>
    $prLink
  </div>
  <div class=""aks-doc-summary"">
    <strong>Summary</strong>
    <p>$(Escape-Html $summary)</p>
  </div>
  <div class=""aks-doc-buttons"">
    <a class=""aks-doc-link"" href=""$fileUrl"" target=""_blank"" rel=""noopener"">View Documentation</a>
  </div>
</div>
"@.Trim())
}

# =========================
# MAIN FLOW — RELEASES (unchanged from your working setup)
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
      $clean = $last -replace '^\s*```(?:json)?\s*','' -replace '\s*```\s*$',''
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
    <p>It relies on AI to filter out trivial edits, and surfaces only substantive changes.</p>
  </div>

  <div class="aks-tabs">
    <nav class="aks-tabs-nav">
      <a class="aks-tab-link active" href="#aks-tab-docs">Documentation Updates</a>
      <a class="aks-tab-link" href="#aks-tab-releases">AKS Releases</a>
    </nav>

    <div class="aks-tab-panel active" id="aks-tab-docs">
      <h2>AKS Documentation Updates</h2>
      <div class="aks-docs-desc">PRs and direct commits merged in the last 7 days; AI filters & summarizes page-level changes.</div>
      <div class="aks-docs-updated-main">
        <span class="aks-pill aks-pill-updated">Last updated: $lastUpdated</span>
        <span class="aks-pill aks-pill-count">$updateCount updates</span>
      </div>
      <div class="aks-docs-list">
        $($sections -join "`n")
      </div>
    </div>

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

[pscustomobject]@{ html = $html; hash = $hash; ai_summaries = $aiVerdictsBundle } | ConvertTo-Json -Depth 6
