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
$ReleasesOwner = "Azure"
$ReleasesRepo  = "AKS"
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
    return "https://learn.microsoft.com/$p"   # keep your original behavior
  }
  return "https://github.com/$Owner/$Repo/blob/main/$FilePath"
}
function Truncate([string]$text, [int]$max = 400) {
  if (-not $text) { return "" }
  $t = $text.Trim()
  if ($t.Length -le $max) { return $t }
  return $t.Substring(0, $max).TrimEnd() + "…"
}
# Markdown→plain fallback for release notes
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

# Nice display name from filename (e.g., pci-data -> PCI Data, RBAC, AKS, etc.)
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

# =========================
# KIND PILL HELPERS
# =========================
function Get-SessionKind($items, [string]$summary) {
  $hasAdded   = ($items | Where-Object { $_.status -eq 'added' }).Count -gt 0
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
    "New"           { "🆕" }
    "Rework"        { "♻️" }
    "Removal"       { "🗑️" }
    "Deprecation"   { "⚠️" }
    "Migration"     { "➡️" }
    "Clarification" { "ℹ️" }
    default         { "✨" }
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
# FETCH PRs MERGED LAST 7 DAYS (no pre-AI filtering)
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
# ALSO FETCH DIRECT COMMITS (NO PR) — no pre-AI filtering
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
function Get-CommitFiles { param([string]$Sha)
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

# ===== Docs AI (vector-store) — STRICT FILTER =====
function Get-PerFileSummariesViaAssistant {
  param([string]$JsonPath, [string]$Model = "gpt-4o-mini")
  if (-not $PSAIReady) { return @{ ordered=@(); byFile=@{} } }
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
You are a strict filter for Azure AKS documentation updates.

INPUT JSON contains an array of file groups. Each has:
- file: full path (e.g., articles/aks/pci-data.md)
- subjects: unique PR/commit titles touching this file this week
- total_additions, total_deletions, commits_count
- statuses[]: added/modified/removed (from diffs)
- patch_sample: a compact unified diff subset with +/- lines only

KEEP ONLY pages with **user-facing, meaningful** changes:
- Adds/removes sections, steps, code blocks, examples
- Changes to parameters/flags/values in CLI or YAML
- Version/support/limits/regions/availability changes
- Security/networking/compatibility behavior changes
- New page or major rewrite

SKIP (omit from output) if trivial:
- Typos/grammar/formatting/whitespace/headings case
- Front matter/ms.* metadata only
- Link retargets, bare URL tweaks, image path changes, TOC shuffles
- Tiny net change (<5 lines) with no headings/commands/code changed

RULES:
- When in doubt, SKIP.
- Never invent beyond the diff/subjects.
- Output at most one result per file.
- Category must be one of:
  Networking, Security, Compute, Storage, Operations, Compliance, General.
- Summary: 1–2 factual sentences (plain text) naming sections/params if visible.

OUTPUT: Return ONLY a JSON array of KEPT items in desired display order:
[
  { "file": "<same file>", "summary": "…", "category": "Networking|Security|Compute|Storage|Operations|Compliance|General", "score": 0.0-1.0 }
]
"@

    $assistant = New-OAIAssistant `
      -Name "AKS-Docs-Filter" `
      -Instructions $instructions `
      -Tools @{ type = 'file_search' } `
      -ToolResources @{ file_search = @{ vector_store_ids = @($vs.id) } } `
      -Model $Model

    $userMsg = "Filter and summarize per the instructions. Return ONLY the JSON array."
    $run = New-OAIThreadAndRun -AssistantId $assistant.id -Thread @{ messages = @(@{ role = 'user'; content = $userMsg }) } -MaxCompletionTokens 1400 -Temperature 0.1
    $run = Wait-OAIOnRun -Run $run -Thread @{ id = $run.thread_id }

    $last = (Get-OAIMessage -ThreadId $run.thread_id -Order desc -Limit 1).data[0].content |
      Where-Object { $_.type -eq 'text' } |
      ForEach-Object { $_.text.value } |
      Out-String

    $clean = $last -replace '^\s*```(?:json)?\s*','' -replace '\s*```\s*$',''
    $match = [regex]::Match($clean, '\[(?:[^][]|(?<open>\[)|(?<-open>\]))*\](?(open)(?!))', 'Singleline')
    if (-not $match.Success) { Log "AI: No JSON array found in response."; return @{ ordered=@(); byFile=@{} } }

    $arr = $match.Value | ConvertFrom-Json -ErrorAction Stop

    # Build ordered list + map
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
    Log "AI: Kept $($ordered.Count) files after filtering."
    return @{ ordered = $ordered; byFile = $byFile }
  }
  catch {
    Write-Warning "AI summaries (docs) failed: $_"
    return @{ ordered=@(); byFile=@{} }
  }
}

# ===== Releases AI (vector-store) =====
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
  { "id": <same id>, "summary": "1–2 sentences", "breaking_changes": ["..."], "key_features": ["..."], "good_to_know": ["..."] }
]
Plain strings only.
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
  catch {
    Write-Warning "AI summaries (releases) failed: $_"
    return @{}
  }
}

# =========================
# MAIN FLOW — DOCS (PRs + direct commits, no pre-AI filtering)
# =========================
Log "Fetching PRs merged in last 7 days..."
$prs = Get-RecentMergedPRs
Log "Found $($prs.Count) PR(s) in window."

$groups = @{}

foreach ($pr in $prs) {
  $files = Get-PRFiles $pr.number
  foreach ($f in $files) {
    if ($f.filename -notmatch '^articles/(azure/)?(aks|kubernetes-fleet)/.*\.md$') { continue }

    if (-not $groups.ContainsKey($f.filename)) { $groups[$f.filename] = @() }
    $groups[$f.filename] += [pscustomobject]@{
      pr_title  = $pr.title
      pr_url    = $pr.html_url
      merged_at = [DateTime]::Parse($pr.merged_at).ToUniversalTime()
      filename  = $f.filename
      additions = $f.additions
      deletions = $f.deletions
      status    = $f.status
      patch     = $f.patch
    }
  }
}

# ---- Direct commits (no PR)
Log "Fetching individual commits in last 7 days..."
$commitList = Get-RecentCommits -SinceIso $SINCE_ISO

foreach ($c in $commitList) {
  $detail = Get-CommitFiles -Sha $c.sha
  if (-not $detail) { continue }

  $when = if ($detail.commit.committer.date) { [DateTime]::Parse($detail.commit.committer.date).ToUniversalTime() }
          elseif ($detail.commit.author.date) { [DateTime]::Parse($detail.commit.author.date).ToUniversalTime() }
          else { [DateTime]::UtcNow }

  $msg = $detail.commit.message.Split("`n")[0]

  foreach ($f in $detail.files) {
    if ($f.filename -notmatch '^articles/(azure/)?(aks|kubernetes-fleet)/.*\.md$') { continue }

    if (-not $groups.ContainsKey($f.filename)) { $groups[$f.filename] = @() }
    $groups[$f.filename] += [pscustomobject]@{
      pr_title  = $msg
      pr_url    = $detail.html_url
      merged_at = $when
      filename  = $f.filename
      additions = $f.additions
      deletions = $f.deletions
      status    = $f.status
      patch     = $f.patch
    }
  }
}

# ===== Build AI input with enough signal for filtering =====
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

      # compact +/- sample (first 1200 +/- lines total)
      $lines = @()
      foreach ($it in $items) { if ($it.patch) { $lines += (($it.patch -split "`n") | Where-Object { $_ -match '^[\+\-]' }) } }
      $patchSample = ($lines | Select-Object -First 1200) -join "`n"

      [pscustomobject]@{
        file             = $k
        subjects         = $subjects
        total_additions  = $adds
        total_deletions  = $dels
        commits_count    = $items.Count
        statuses         = $statuses
        patch_sample     = $patchSample
      }
    }
  )
}
$aiInput | ConvertTo-Json -Depth 6 | Set-Content -Path $aiJsonPath -Encoding UTF8
Log "AI Summaries"
Log "  [AKS] Prepared AI input: $aiJsonPath"

$aiVerdicts = @{ ordered=@(); byFile=@{} }
if ($PreferProvider) { $aiVerdicts = Get-PerFileSummariesViaAssistant -JsonPath $aiJsonPath }
else { Log "AI disabled (no provider env configured)." }

# Render DOCS sections — ONLY what AI kept, preserving AI order
$sections = New-Object System.Collections.Generic.List[string]
foreach ($row in @($aiVerdicts.ordered)) {
  $file = $row.file
  if (-not $groups.ContainsKey($file)) { continue }  # safety

  $arr         = $groups[$file] | Sort-Object merged_at -Descending
  $fileUrl     = Get-LiveDocsUrl -FilePath $file
  $summary     = $aiVerdicts.byFile[$file].summary
  $category    = if ($aiVerdicts.byFile[$file].category) { $aiVerdicts.byFile[$file].category } else { "General" }
  $lastUpdated = $arr[0].merged_at.ToString('yyyy-MM-dd HH:mm')
  $prLink      = $arr[0].pr_url

  # Better, consistent title from file + kind
  $display   = Get-DocDisplayName $file
  $kind      = Get-SessionKind -items $arr -summary ($summary ?? "")
  $kindPill  = KindToPillHtml $kind
  $cardTitle = "AKS - $display"

  $section = @"
<div class="aks-doc-update">
  <h2><a href="$fileUrl">$(Escape-Html $cardTitle)</a></h2>
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
# MAIN FLOW — RELEASES
# =========================
function Get-GitHubReleases([string]$owner, [string]$repo, [int]$count = 5) {
  $uri = "https://api.github.com/repos/$owner/$repo/releases?per_page=$count"
  try { Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET }
  catch {
    Write-Warning ("Failed to fetch releases from {0}/{1}: {2}" -f $owner, $repo, $_.Exception.Message)
    return @()
  }
}
$releases = Get-GitHubReleases -owner $ReleasesOwner -repo $ReleasesRepo -count $ReleasesCount

# Build releases JSON for AI
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
  $titleRaw     = ($r.name ?? $r.tag_name)
  $title        = Escape-Html $titleRaw
  $url          = $r.html_url
  $isPrerelease = [bool]$r.prerelease
  $publishedAt  = if ($r.published_at) { [DateTime]::Parse($r.published_at).ToUniversalTime().ToString("yyyy-MM-dd") } else { "" }

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
$updateCount = @($aiVerdicts.ordered).Count  # only kept ones

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

[pscustomobject]@{ html = $html; hash = $hash; ai_summaries = $aiVerdicts } | ConvertTo-Json -Depth 6
