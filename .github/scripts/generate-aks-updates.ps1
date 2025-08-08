#!/usr/bin/env pwsh
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# =========================
# CONFIG / ENV
# =========================
$Owner = "MicrosoftDocs"
$Repo  = "azure-aks-docs"
$GitHubToken = $env:GITHUB_TOKEN
if (-not $GitHubToken) { Write-Error "GITHUB_TOKEN not set"; exit 1 }

$PreferProvider = if ($env:OpenAIKey) { 'OpenAI' } elseif ($env:AZURE_OPENAI_APIURI -and $env:AZURE_OPENAI_KEY -and $env:AZURE_OPENAI_API_VERSION -and $env:AZURE_OPENAI_DEPLOYMENT) { 'AzureOpenAI' } else { '' }

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
function Test-IsBot($Commit) {
  $login = $Commit.user.login
  $name  = $Commit.commit.author.name
  return ($login -match '(bot|actions)' -or $name -match '(bot|actions)')
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
  return ($allMd -and ($Adds + $Dels) -le 3)
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
# AI INIT
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
    $vsName = "aks-docs-prs-$(Get-Date -Format 'yyyyMMddHHmmss')"
    $vs = New-OAIVectorStore -Name $vsName -FileIds $file.id

    $timeout = [DateTime]::UtcNow.AddMinutes(2)
    do {
      Start-Sleep -Seconds 2
      $vs = Get-OAIVectorStore -VectorStoreId $vs.id
      Log "Vector store status: $($vs.status)"
      if ($vs.status -eq 'failed') { throw "Vector store failed" }
    } while ($vs.status -ne 'completed' -and [DateTime]::UtcNow -lt $timeout)
    if ($vs.status -ne 'completed') { throw "Timed out waiting for vector store" }

    $instructions = @"
You are summarizing substantive Azure AKS documentation changes from PRs.
Ignore trivial edits (typos, link fixes).
For each file, return JSON: [ { "file": "<path>", "summary": "1–2 sentences" } ]
"@
    $assistant = New-OAIAssistant `
      -Name "AKS-Docs-Summarizer" `
      -Instructions $instructions `
      -Tools @{ type='file_search' } `
      -ToolResources @{ file_search=@{ vector_store_ids=@($vs.id) } } `
      -Model $Model

    $userMsg = "Summarize each file from the uploaded JSON per instructions. Only JSON array in output."
    $run = New-OAIThreadAndRun -AssistantId $assistant.id -Thread @{ messages=@(@{ role='user'; content=$userMsg }) } -MaxCompletionTokens 1200
    $run = Wait-OAIOnRun -Run $run -Thread @{ id=$run.thread_id } -TimeoutSec 120

    $last = (Get-OAIMessage -ThreadId $run.thread_id -Order desc -Limit 1).data[0].content |
      Where-Object { $_.type -eq 'text' } |
      ForEach-Object { $_.text.value } |
      Out-String
    $clean = $last -replace '^\s*```(?:json)?\s*','' -replace '\s*```\s*$',''
    $match = [regex]::Match($clean,'\[(?:[^][]|(?<open>\[)|(?<-open>\]))*\](?(open)(?!))','Singleline')
    if (-not $match.Success) { return @{} }

    $arr = $match.Value | ConvertFrom-Json -ErrorAction Stop
    $map = @{}; foreach ($i in $arr) { $map[$i.file] = $i.summary }
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
  $files = Get-PRFiles $pr.number
  foreach ($f in $files) {
    if ($f.filename -notmatch '\.md$') { continue }
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

# Prepare AI input JSON
$TmpRoot = $env:RUNNER_TEMP; if (-not $TmpRoot) { $TmpRoot = [System.IO.Path]::GetTempPath() }
$tempJsonPath = Join-Path $TmpRoot ("aks-doc-pr-groups-{0}.json" -f (Get-Date -Format 'yyyyMMddHHmmss'))
$aiInput = [pscustomobject]@{
  since  = $SINCE_ISO
  groups = @(
    foreach ($k in $groups.Keys) {
      [pscustomobject]@{
        file    = $k
        subjects= ($groups[$k] | ForEach-Object { $_.pr_title } | Select-Object -Unique)
      }
    }
  )
}
$aiInput | ConvertTo-Json -Depth 6 | Set-Content -Path $tempJsonPath -Encoding UTF8
Log "AI Summaries - Prepared AI input: $tempJsonPath"

# Get summaries (with timeout)
$summaries = @{}
if ($PreferProvider) { $summaries = Get-PerFileSummariesViaAssistant -JsonPath $tempJsonPath }

# =========================
# RENDER HTML
# =========================
$sections = New-Object System.Collections.Generic.List[string]
foreach ($file in $groups.Keys) {
  $arr = $groups[$file] | Sort-Object merged_at -Descending
  $fileUrl = Get-LiveDocsUrl -FilePath $file
  $summary = $summaries[$file]

  $lis = foreach ($x in $arr) {
    "<li><a href=""$($x.pr_url)"">$(Escape-Html $x.pr_title)</a> <small>$($x.merged_at.ToString('yyyy-MM-dd'))</small></li>"
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
  <h2>AKS documentation updates (last 7 days)</h2>
  $($sections -join "`n")
</div>
"@.Trim()

$sha256 = [System.Security.Cryptography.SHA256]::Create()
$bytes  = [Text.Encoding]::UTF8.GetBytes($html)
$hash   = ($sha256.ComputeHash($bytes) | ForEach-Object { $_.ToString("x2") }) -join ""

[pscustomobject]@{ html = $html; hash = $hash } | ConvertTo-Json -Depth 6
