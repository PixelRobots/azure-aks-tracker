#!/usr/bin/env pwsh
# Requires: PowerShell 7+, PSAI (optional for summaries)

param(
  [string]$Owner = "MicrosoftDocs",
  [string]$Repo  = "azure-aks-docs",
  [int]$Days = 7,
  [string]$OpenAIModel = $env:OPENAI_MODEL  # e.g. "gpt-4o-mini"
)

# --- Setup: inclusive UTC-midnight window (last N days) ---
$now = [DateTime]::UtcNow
$sinceMidnightUtc = (Get-Date -Date $now.ToString("yyyy-MM-dd") -AsUTC).AddDays(-$Days)
$sinceIso = $sinceMidnightUtc.ToString("o")

# --- GitHub REST helpers ---
$GitHubToken = $env:GITHUB_TOKEN
if (-not $GitHubToken) {
  Write-Error "GITHUB_TOKEN not set."
  exit 1
}
$ghHeaders = @{
  "Authorization" = "Bearer $GitHubToken"
  "Accept"        = "application/vnd.github+json"
  "User-Agent"    = "pixelrobots-aks-updates-pwsh"
}

function Get-GitHubCommitsSince {
  param([string]$Owner,[string]$Repo,[string]$SinceIso)
  $all = @()
  for ($page=1; $page -le 6; $page++) {
    $uri = "https://api.github.com/repos/$Owner/$Repo/commits?since=$([uri]::EscapeDataString($SinceIso))&per_page=100&page=$page"
    $resp = Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
    if (-not $resp -or $resp.Count -eq 0) { break }
    $all += $resp
    if ($resp.Count -lt 100) { break }
  }
  return $all
}

function Get-GitHubCommitDetail {
  param([string]$Owner,[string]$Repo,[string]$Sha)
  $uri = "https://api.github.com/repos/$Owner/$Repo/commits/$Sha"
  Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
}

# --- Noise filters ---
function Test-IsBot {
  param($Commit)
  $authorLogin = $Commit.author.login
  $authorName  = $Commit.commit.author.name
  return ($authorLogin -match '(bot|actions)' -or $authorName -match '(bot|actions)')
}
function Test-IsNoiseMessage {
  param([string]$Message)
  if (-not $Message) { return $false }
  $patterns = @(
    '^merge\b','^sync\b','publish from','update submodule',
    '\btypo\b','\bgrammar\b','\blink[- ]?fix\b','\bformat(ting)?\b',
    '\breadme\b','^chore\b'
  )
  foreach ($p in $patterns) { if ($Message -imatch $p) { return $true } }
  return $false
}
function Test-IsTinyDocsChange {
  param($Detail)
  $adds = $Detail.stats.additions
  $dels = $Detail.stats.deletions
  if ($null -eq $adds) { $adds = 0 }
  if ($null -eq $dels) { $dels = 0 }
  $files = @($Detail.files)
  if ($files.Count -eq 0) { return $false }
  $onlyMd = $files | ForEach-Object { $_.filename } | Where-Object { $_ -notmatch '\.md$' } | Measure-Object | Select-Object -ExpandProperty Count
  # onlyMd = 0 means all are .md
  $allMd = ($onlyMd -eq 0)
  return ($allMd -and ($adds + $dels) -le 3)
}

# --- PSAI (optional summaries) ---
$usePSAI = $false
if ($env:OpenAIKey) {
  try {
    if (-not (Get-Module -ListAvailable -Name PSAI)) {
      Install-Module PSAI -Scope CurrentUser -Force -ErrorAction Stop
    }
    Import-Module PSAI -ErrorAction Stop
    # Explicitly set provider to OpenAI (optional but clear)
    Set-OAIProvider OpenAI | Out-Null
    $usePSAI = $true
  } catch {
    Write-Warning "PSAI module not available or failed to import. Continuing without AI summaries. $_"
    $usePSAI = $false
  }
}

function Get-DocSummary {
  param(
    [string]$File,
    [string[]]$Subjects
  )
  if (-not $usePSAI) { return $null }
  # Build prompt
  $joined = $Subjects | Select-Object -First 8 | ForEach-Object { "- $_" } | Out-String
  $user = @"
You are summarizing changes to an Azure AKS documentation page.
Ignore trivial changes (typos, formatting, link-only fixes).
Focus on substantive content: new sections, expanded guidance, examples, or reorganization that improves clarity.
Write 1–2 concise sentences in plain English for end users.

File: $File
Recent commit subjects:
$joined
Respond with just the summary sentences.
"@
  try {
    $args = @{
      Messages = @(
        @{ role="system"; content="You are a technical writer for Azure AKS documentation." },
        @{ role="user";   content=$user }
      )
    }
    if ($OpenAIModel) { $args.Model = $OpenAIModel }
    $resp = Invoke-OAIChat @args
    $text = $resp.choices[0].message.content.Trim()
    if ([string]::IsNullOrWhiteSpace($text)) { return $null }
    return $text
  } catch {
    Write-Warning "AI summary failed: $_"
    return $null
  }
}

function Escape-Html([string]$s) {
  $s.Replace('&','&amp;').Replace('<','&lt;').Replace('>','&gt;').Replace('"','&quot;')
}

# --- Fetch → hydrate ---
$commits = Get-GitHubCommitsSince -Owner $Owner -Repo $Repo -SinceIso $sinceIso | Where-Object {
  -not (Test-IsBot $_) -and -not (Test-IsNoiseMessage $_.commit.message)
}

$details = @()
$chunk = 10
for ($i=0; $i -lt $commits.Count; $i += $chunk) {
  $batch = $commits[$i..([Math]::Min($i+$chunk-1, $commits.Count-1))]
  foreach ($c in $batch) {
    $d = Get-GitHubCommitDetail -Owner $Owner -Repo $Repo -Sha $c.sha
    $details += $d
    Start-Sleep -Milliseconds 150
  }
}

# --- Post-filter: tiny diffs + only .md files ---
$substantive = $details | Where-Object {
  -not (Test-IsTinyDocsChange $_) -and -not (Test-IsNoiseMessage $_.commit.message)
} | Where-Object {
  $_.files | Where-Object filename -match '\.md$'
}

# --- Group by .md path ---
$groups = @{}
foreach ($d in $substantive) {
  foreach ($f in $d.files) {
    if ($f.filename -notmatch '\.md$') { continue }
    if (-not $groups.ContainsKey($f.filename)) { $groups[$f.filename] = @() }
    $groups[$f.filename] += $d
  }
}
# Sort each group by committer date desc
foreach ($k in @($groups.Keys)) {
  $groups[$k] = $groups[$k] | Sort-Object { [DateTime]$_.commit.committer.date } -Descending
}

function Get-ShortTitleFromPath([string]$path) {
  ($path -split '/')[-1]
}

# --- Build sections ---
$sections = New-Object System.Collections.Generic.List[string]
foreach ($kv in $groups.GetEnumerator()) {
  $file = $kv.Key
  $arr  = $kv.Value

  # include group if any commit committer-date within window
  $hasRecent = $false
  foreach ($a in $arr) {
    if ([DateTime]::Parse($a.commit.committer.date).ToUniversalTime() -ge $sinceMidnightUtc) { $hasRecent = $true; break }
  }
  if (-not $hasRecent) { continue }

  $subjects = $arr | ForEach-Object { ($_.commit.message -split "`n")[0] } | Where-Object { $_ } | Select-Object -Unique
  $summary = Get-DocSummary -File $file -Subjects $subjects

  $fileUrl = "https://github.com/$Owner/$Repo/blob/main/$file"

  $lis = foreach ($a in $arr) {
    $subject = (($_.commit.message) -split "`n")[0]
    $subject = if ($subject) { $subject } else { ($a.commit.message -split "`n")[0] }
    $subject = if ($subject) { $subject } else { "(no subject)" }
    $dateIso = ([DateTime]::Parse($a.commit.committer.date).ToUniversalTime()).ToString('yyyy-MM-dd')
    "<li><a href=""$($a.html_url)"">$(Escape-Html $subject)</a> <small>$dateIso</small></li>"
  }

  $section = @"
<section class="aks-doc-update">
  <h3><a href="$fileUrl">$(Escape-Html (Get-ShortTitleFromPath $file))</a></h3>
  $(if ($summary) { "<p>$(Escape-Html $summary)</p>" } else { "" })
  <ul>
    $($lis -join "`n")
  </ul>
</section>
"@
  $sections.Add($section.Trim())
}

# --- Final HTML + hash, emit JSON ---
$html = @"
<div class="aks-updates" data-since="$sinceIso">
  <h2>AKS documentation updates (last $Days days)</h2>
  $($sections -join "`n")
</div>
"@.Trim()

$sha256 = [System.Security.Cryptography.SHA256]::Create()
$bytes  = [Text.Encoding]::UTF8.GetBytes($html)
$hash   = ($sha256.ComputeHash($bytes) | ForEach-Object { $_.ToString("x2") }) -join ""

$payload = [pscustomobject]@{ html = $html; hash = $hash }
$payload | ConvertTo-Json -Depth 6
