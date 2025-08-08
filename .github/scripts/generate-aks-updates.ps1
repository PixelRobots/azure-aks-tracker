#!/usr/bin/env pwsh
# Outputs JSON: { html: "<...>", hash: "<sha256>" }
# PowerShell 7+. PSAI optional (auto-installs if AI env is set).

param(
  [string]$Owner = "MicrosoftDocs",
  [string]$Repo  = "azure-aks-docs",
  [int]$Days     = 7
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$VerbosePreference = 'Continue'

function Log([string]$msg) { Write-Host "[AKS] $msg" }

# ===== Config / Env =====
$GitHubToken = $env:GITHUB_TOKEN
if (-not $GitHubToken) { Write-Error "GITHUB_TOKEN not set"; exit 1 }

$PreferProvider =
  if     ($env:OpenAIKey) { 'OpenAI' }
  elseif ($env:AZURE_OPENAI_APIURI -and $env:AZURE_OPENAI_KEY -and $env:AZURE_OPENAI_API_VERSION -and $env:AZURE_OPENAI_DEPLOYMENT) { 'AzureOpenAI' }
  else { '' }

$now = [DateTime]::UtcNow
$sinceMidnightUtc = (Get-Date -Date $now.ToString("yyyy-MM-dd") -AsUTC).AddDays(-$Days)
$SINCE_ISO = $sinceMidnightUtc.ToString("o")
Log "Window since $SINCE_ISO (UTC)"

$ghHeaders = @{
  "Authorization" = "Bearer $GitHubToken"
  "Accept"        = "application/vnd.github+json"
  "User-Agent"    = "pixelrobots-aks-updates-pwsh"
}

# ===== Helpers =====
function Escape-Html([string]$s) { $s.Replace('&','&amp;').Replace('<','&lt;').Replace('>','&gt;').Replace('"','&quot;') }
function ShortTitle([string]$path) { ($path -split '/')[ -1 ] }
function Test-IsBot($Commit) { $Commit.author.login -match '(bot|actions)' -or $Commit.commit.author.name -match '(bot|actions)' }
function Test-IsNoiseMessage([string]$Message) {
  if (-not $Message) { return $false }
  foreach ($p in @('^merge\b','^sync\b','publish from','update submodule','\btypo\b','\bgrammar\b','\blink[- ]?fix\b','\bformat(ting)?\b','\breadme\b','^chore\b')) {
    if ($Message -imatch $p) { return $true }
  }
  return $false
}
function Test-IsTinyDocsChange($Detail) {
  $adds = $Detail.stats.additions; if ($null -eq $adds) { $adds = 0 }
  $dels = $Detail.stats.deletions; if ($null -eq $dels) { $dels = 0 }
  $files = @($Detail.files); if ($files.Count -eq 0) { return $false }
  $allMd = (($files | Where-Object { $_.filename -notmatch '\.md$' }).Count -eq 0)
  return ($allMd -and ($adds + $dels) -le 3)
}

function Get-GitHubCommitsSince([string]$Owner,[string]$Repo,[string]$SinceIso) {
  $all = @()
  for ($page=1; $page -le 6; $page++) {
    $uri = "https://api.github.com/repos/$Owner/$Repo/commits?since=$([uri]::EscapeDataString($SinceIso))&per_page=100&page=$page"
    $resp = Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
    if (-not $resp -or $resp.Count -eq 0) { break }
    $all += $resp
    if ($resp.Count -lt 100) { break }
  }
  $all | Where-Object { -not (Test-IsBot $_) -and -not (Test-IsNoiseMessage $_.commit.message) }
}
function Get-GitHubCommitDetail([string]$Owner,[string]$Repo,[string]$Sha) {
  $uri = "https://api.github.com/repos/$Owner/$Repo/commits/$Sha"
  Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
}

# ===== AI via PSAI (optional) =====
$PSAIReady = $false
function Initialize-AIProvider {
  param([ValidateSet('OpenAI','AzureOpenAI')][string]$Provider)
  try {
    if (-not (Get-Module -ListAvailable -Name PSAI)) {
      Write-Host "::group::Install PSAI"
      Install-Module PSAI -Scope CurrentUser -Force -ErrorAction Stop
      Write-Host "::endgroup::"
    }
    Import-Module PSAI -ErrorAction Stop
  } catch {
    Write-Warning "PSAI not available; continuing without summaries. $_"
    return $false
  }
  switch ($Provider) {
    'OpenAI' {
      if (-not $env:OpenAIKey) { Write-Warning "OpenAIKey env not set"; return $false }
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
if ($PreferProvider) {
  $PSAIReady = Initialize-AIProvider -Provider $PreferProvider
  Log "AI provider: $PreferProvider (PSAI ready: $PSAIReady)"
}

function Get-PerFileSummariesViaAssistant {
  param([Parameter(Mandatory)][string]$JsonPath, [string]$Model = "gpt-4o-mini")
  if (-not $PSAIReady) { return @{} }
  try {
    $file = Invoke-OAIUploadFile -Path $JsonPath -Purpose assistants -ErrorAction Stop
    $vsName = "aks-docs-$(Get-Date -Format 'yyyyMMddHHmmss')"
    $vs = New-OAIVectorStore -Name $vsName -FileIds $file.id
    do {
      Start-Sleep -Seconds 2
      $all = Get-OAIVectorStore -limit 100 -order desc
      $vs = $all | Where-Object { $_.id -eq $vs.id }
    } while ($vs.status -ne 'completed')

    $instructions = @"
You are a technical writer summarizing Azure AKS documentation changes.
Ignore trivial changes (typos, formatting, link-only fixes).
Focus on substantive content (new sections, expanded guidance, examples, reorganizations).
Return a JSON array of: { "file": "<path>", "summary": "1–2 sentences" }.
Only include files in the uploaded JSON. No extra keys.
"@

    $assistant = New-OAIAssistant `
      -Name "AKS-Docs-Summarizer" `
      -Instructions $instructions `
      -Tools @{ type = 'file_search' } `
      -ToolResources @{ file_search = @{ vector_store_ids = @($vs.id) } } `
      -Model $Model

    $userMsg = "Summarize each file in the uploaded JSON and return only the JSON array."
    $run = New-OAIThreadAndRun -AssistantId $assistant.id -Thread @{ messages = @(@{ role='user'; content=$userMsg }) } -MaxCompletionTokens 1200
    $run = Wait-OAIOnRun -Run $run -Thread @{ id = $run.thread_id }

    $last = (Get-OAIMessage -ThreadId $run.thread_id -Order desc -Limit 1).data[0].content |
      Where-Object { $_.type -eq 'text' } |
      ForEach-Object { $_.text.value } |
      Out-String

    $clean = $last -replace '^\s*```(?:json)?\s*','' -replace '\s*```\s*$',''
    $match = [regex]::Match($clean,'\[(?:[^][]|(?<open>\[)|(?<-open>\]))*\](?(open)(?!))','Singleline')
    if (-not $match.Success) { return @{} }
    $arr = $match.Value | ConvertFrom-Json -ErrorAction Stop
    $map = @{}
    foreach ($i in $arr) { $map[$i.file] = $i.summary }
    $map
  } catch {
    Write-Warning "Assistant summaries failed: $_"
    @{}
  }
}

# ===== Fetch & hydrate =====
Write-Host "::group::Fetch & Hydrate"
$commits = Get-GitHubCommitsSince -Owner $Owner -Repo $Repo -SinceIso $SINCE_ISO
Log "Fetched $($commits.Count) commits (pre-filter)"

$details = @()
if ($commits.Count -gt 0) {
  $chunk = 10
  for ($i=0; $i -lt $commits.Count; $i += $chunk) {
    $end = [Math]::Min($i + $chunk - 1, $commits.Count - 1)
    $batch = $commits[$i..$end]
    foreach ($c in $batch) {
      $d = Get-GitHubCommitDetail -Owner $Owner -Repo $Repo -Sha $c.sha
      $details += $d
      Start-Sleep -Milliseconds 150
    }
  }
}
Log "Hydrated $($details.Count) commits with file stats"
Write-Host "::endgroup::"

# ===== Filter & group =====
Write-Host "::group::Filter & Group"
$substantive = $details | Where-Object {
  -not (Test-IsTinyDocsChange $_) -and -not (Test-IsNoiseMessage $_.commit.message)
} | Where-Object {
  $_.files | Where-Object filename -match '\.md$'
}
Log "Substantive commits touching .md: $(@($substantive).Count)"

$groups = @{}
foreach ($d in $substantive) {
  foreach ($f in $d.files) {
    if ($f.filename -notmatch '\.md$') { continue }
    if (-not $groups.ContainsKey($f.filename)) { $groups[$f.filename] = @() }
    $groups[$f.filename] += $d
  }
}
foreach ($k in @($groups.Keys)) {
  $sorted = $groups[$k] | Sort-Object { [DateTime]$_.commit.committer.date } -Descending
  if (-not ($sorted | Where-Object { [DateTime]::Parse($_.commit.committer.date).ToUniversalTime() -ge $sinceMidnightUtc })) {
    $groups.Remove($k)
  } else {
    $groups[$k] = $sorted
  }
}
Log "Grouped into $($groups.Keys.Count) doc pages"
Write-Host "::endgroup::"

# ===== AI input & summaries =====
Write-Host "::group::AI Summaries"
$TmpRoot = $env:RUNNER_TEMP; if ([string]::IsNullOrWhiteSpace($TmpRoot)) { $TmpRoot = $env:TEMP }
if ([string]::IsNullOrWhiteSpace($TmpRoot)) { $TmpRoot = $env:TMPDIR }
if ([string]::IsNullOrWhiteSpace($TmpRoot)) { $TmpRoot = [System.IO.Path]::GetTempPath() }
if ([string]::IsNullOrWhiteSpace($TmpRoot)) { $TmpRoot = "." }
New-Item -ItemType Directory -Force -Path $TmpRoot | Out-Null
$tempJsonPath = Join-Path $TmpRoot ("aks-doc-groups-{0}.json" -f (Get-Date -Format 'yyyyMMddHHmmss'))

$aiInput = [pscustomobject]@{
  since = $SINCE_ISO
  groups = @(
    foreach ($k in $groups.Keys) {
      $arr = $groups[$k]
      [pscustomobject]@{
        file = $k
        subjects = ($arr | ForEach-Object { ($_.commit.message -split "`n")[0] } | Where-Object { $_ } | Select-Object -Unique)
        commits = @(
          foreach ($a in $arr) {
            [pscustomobject]@{
              message = ($a.commit.message -split "`n")[0]
              url     = $a.html_url
              date    = ([DateTime]::Parse($a.commit.committer.date).ToUniversalTime().ToString("o"))
              additions = $a.stats.additions
              deletions = $a.stats.deletions
            }
          }
        )
      }
    }
  )
}
$aiInput | ConvertTo-Json -Depth 8 | Set-Content -Path $tempJsonPath -Encoding UTF8
Log "Prepared AI input: $tempJsonPath"

$summaries = @{}
if ($PreferProvider) { $summaries = Get-PerFileSummariesViaAssistant -JsonPath $tempJsonPath }
Log "Summaries returned for $($summaries.Keys.Count) files"
Write-Host "::endgroup::"

# ===== Render HTML =====
Write-Host "::group::Render & Output"
$sections = New-Object System.Collections.Generic.List[string]
foreach ($file in $groups.Keys) {
  $arr = $groups[$file]
  $fileUrl = "https://github.com/$Owner/$Repo/blob/main/$file"
  $summary = $summaries[$file]
  $lis = foreach ($a in $arr) {
    $subject = ($a.commit.message -split "`n")[0]; if (-not $subject) { $subject = "(no subject)" }
    $dateIso = ([DateTime]::Parse($a.commit.committer.date).ToUniversalTime()).ToString('yyyy-MM-dd')
    "<li><a href=""$($a.html_url)"">$(Escape-Html $subject)</a> <small>$dateIso</small></li>"
  }
  $section = @"
<section class="aks-doc-update">
  <h3><a href="$fileUrl">$(Escape-Html (ShortTitle $file))</a></h3>
  $(if ($summary) { "<p>$(Escape-Html $summary)</p>" } else { "" })
  <ul>
    $($lis -join "`n")
  </ul>
</section>
"@
  $sections.Add($section.Trim())
}
$html = @"
<div class="aks-updates" data-since="$SINCE_ISO">
  <h2>AKS documentation updates (last $Days days)</h2>
  $($sections -join "`n")
</div>
"@.Trim()

$sha256 = [System.Security.Cryptography.SHA256]::Create()
$bytes  = [Text.Encoding]::UTF8.GetBytes($html)
$hash   = ($sha256.ComputeHash($bytes) | ForEach-Object { $_.ToString("x2") }) -join ""
Log "Rendered $($sections.Count) sections → hash $hash"
Write-Host "::endgroup::"

# IMPORTANT: Only write the final JSON to stdout (captured by workflow)
[pscustomobject]@{ html = $html; hash = $hash } | ConvertTo-Json -Depth 6
