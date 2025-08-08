#!/usr/bin/env pwsh
# Outputs JSON: { html: "<...>", hash: "<sha256>" }
# Requires: PowerShell 7+. PSAI is optional (it will install automatically if AI is enabled).

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

param(
  [int]$Days = 7
)

# ====================================================================================
# Config / Env
# ====================================================================================
$GitHubToken = $env:GITHUB_TOKEN
if (-not $GitHubToken) { Write-Error "GITHUB_TOKEN not set"; exit 1 }

# AI provider selection via env (default OpenAI if OpenAIKey present; otherwise AzureOpenAI if Azure env present)
$PreferProvider = if ($env:OpenAIKey) { 'OpenAI' } elseif ($env:AZURE_OPENAI_APIURI -and $env:AZURE_OPENAI_KEY -and $env:AZURE_OPENAI_API_VERSION -and $env:AZURE_OPENAI_DEPLOYMENT) { 'AzureOpenAI' } else { '' }

# Inclusive UTC-midnight window
$now = [DateTime]::UtcNow
$sinceMidnightUtc = (Get-Date -Date $now.ToString("yyyy-MM-dd") -AsUTC).AddDays(-$Days)
$SINCE_ISO = $sinceMidnightUtc.ToString("o")

# HTTP defaults
$ghHeaders = @{
  "Authorization" = "Bearer $GitHubToken"
  "Accept"        = "application/vnd.github+json"
  "User-Agent"    = "pixelrobots-aks-updates-pwsh"
}

# ====================================================================================
# Helpers
# ====================================================================================
function Escape-Html([string]$s) {
  $s.Replace('&','&amp;').Replace('<','&lt;').Replace('>','&gt;').Replace('"','&quot;')
}

function ShortTitle([string]$path) { ($path -split '/')[ -1 ] }

function Test-IsBot($Commit) {
  $login = $Commit.author.login
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

function Test-IsTinyDocsChange($Detail) {
  $adds = $Detail.stats.additions; if ($null -eq $adds) { $adds = 0 }
  $dels = $Detail.stats.deletions; if ($null -eq $dels) { $dels = 0 }
  $files = @($Detail.files)
  if ($files.Count -eq 0) { return $false }
  $allMd = (($files | Where-Object { $_.filename -notmatch '\.md$' }).Count -eq 0)
  return ($allMd -and ($adds + $dels) -le 3)
}

function Get-GitHubCommitsSince([string]MicrosoftDocs,[string]azure-aks-docs,[string]$SinceIso) {
  $all = @()
  for ($page=1; $page -le 6; $page++) {
    $uri = "https://api.github.com/repos/MicrosoftDocs/azure-aks-docs/commits?since=$([uri]::EscapeDataString($SinceIso))&per_page=100&page=$page"
    $resp = Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
    if (-not $resp -or $resp.Count -eq 0) { break }
    $all += $resp
    if ($resp.Count -lt 100) { break }
  }
  # early filter
  return $all | Where-Object { -not (Test-IsBot $_) -and -not (Test-IsNoiseMessage $_.commit.message) }
}

function Get-GitHubCommitDetail([string]MicrosoftDocs,[string]azure-aks-docs,[string]$Sha) {
  $uri = "https://api.github.com/repos/MicrosoftDocs/azure-aks-docs/commits/$Sha"
  Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
}

# ====================================================================================
# AI (PSAI) like your example: upload JSON → vector store → assistant → run → parse JSON
# ====================================================================================
$PSAIReady = $false
function Initialize-AIProvider {
  param([ValidateSet('OpenAI','AzureOpenAI')][string]$Provider)

  try {
    if (-not (Get-Module -ListAvailable -Name PSAI)) {
      Install-Module PSAI -Scope CurrentUser -Force -ErrorAction Stop
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
        Write-Warning "Azure OpenAI envs incomplete; set AZURE_OPENAI_APIURI, AZURE_OPENAI_KEY, AZURE_OPENAI_API_VERSION, AZURE_OPENAI_DEPLOYMENT."
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
  param(
    [Parameter(Mandatory)][string]$JsonPath,   # file with { groups: [ { file, subjects[], commits[] } ] }
    [string]$Model = "gpt-4o-mini"
  )
  if (-not $PSAIReady) { return @{} }

  try {
    # Upload file
    $file = Invoke-OAIUploadFile -Path $JsonPath -Purpose assistants -ErrorAction Stop

    # Vector store
    $vsName = "aks-docs-$(Get-Date -Format 'yyyyMMddHHmmss')"
    $vs = New-OAIVectorStore -Name $vsName -FileIds $file.id

    # Wait until processed (your pattern)
    do {
      Start-Sleep -Seconds 2
      $all = Get-OAIVectorStore -limit 100 -order desc
      $vs = $all | Where-Object { $_.id -eq $vs.id }
    } while ($vs.status -ne 'completed')

    $instructions = @"
You are a technical writer summarizing Azure AKS documentation changes.
You will search the uploaded JSON to produce concise, end-user friendly summaries.
Rules:
- Ignore trivial changes (typos, formatting, link-only fixes).
- Focus on substantive content: new sections, expanded guidance, examples, reorganizations that improve clarity.
- Return a JSON array where each item is: { "file": "<path>", "summary": "1–2 sentences" }.
- Only include files present in the uploaded JSON. No extra keys or commentary.
"@

    $assistant = New-OAIAssistant `
      -Name "AKS-Docs-Summarizer" `
      -Instructions $instructions `
      -Tools @{ type = 'file_search' } `
      -ToolResources @{ file_search = @{ vector_store_ids = @($vs.id) } } `
      -Model $Model

    $userMsg = "Summarize each file in the uploaded JSON per the instructions and return only the JSON array."
    $run = New-OAIThreadAndRun -AssistantId $assistant.id -Thread @{ messages = @(@{ role='user'; content=$userMsg }) } -MaxCompletionTokens 1200
    $run = Wait-OAIOnRun -Run $run -Thread @{ id = $run.thread_id }

    $last = (Get-OAIMessage -ThreadId $run.thread_id -Order desc -Limit 1).data[0].content |
      Where-Object { $_.type -eq 'text' } |
      ForEach-Object { $_.text.value } |
      Out-String

    # Strip fenced code if present & extract JSON
    $clean = $last -replace '^\s*```(?:json)?\s*','' -replace '\s*```\s*$',''
    $match = [regex]::Match($clean,'\[(?:[^][]|(?<open>\[)|(?<-open>\]))*\](?(open)(?!))','Singleline')
    if (-not $match.Success) { return @{} }

    $arr = $match.Value | ConvertFrom-Json -ErrorAction Stop
    $map = @{}
    foreach ($i in $arr) { $map[$i.file] = $i.summary }
    return $map
  }
  catch {
    Write-Warning "Assistant summaries failed: $_"
    return @{}
  }
}

# ====================================================================================
# Fetch → hydrate → filter → group
# ====================================================================================
$commits = Get-GitHubCommitsSince -Owner MicrosoftDocs -Repo azure-aks-docs -SinceIso $SINCE_ISO
$details = @()
$chunk = 10
for ($i=0; $i -lt $commits.Count; $i += $chunk) {
  $batch = $commits[$i..([Math]::Min($i+$chunk-1, $commits.Count-1))]
  foreach ($c in $batch) {
    $d = Get-GitHubCommitDetail -Owner MicrosoftDocs -Repo azure-aks-docs -Sha $c.sha
    $details += $d
    Start-Sleep -Milliseconds 150
  }
}

$substantive = $details | Where-Object {
  -not (Test-IsTinyDocsChange $_) -and -not (Test-IsNoiseMessage $_.commit.message)
} | Where-Object {
  $_.files | Where-Object filename -match '\.md$'
}

# Group by .md path
$groups = @{}
foreach ($d in $substantive) {
  foreach ($f in $d.files) {
    if ($f.filename -notmatch '\.md$') { continue }
    if (-not $groups.ContainsKey($f.filename)) { $groups[$f.filename] = @() }
    $groups[$f.filename] += $d
  }
}
# Sort each group by committer date desc and enforce 7-day inclusion
foreach ($k in @($groups.Keys)) {
  $sorted = $groups[$k] | Sort-Object { [DateTime]$_.commit.committer.date } -Descending
  # keep group only if at least one commit in window
  if (-not ($sorted | Where-Object { [DateTime]::Parse($_.commit.committer.date).ToUniversalTime() -ge $sinceMidnightUtc })) {
    $groups.Remove($k)
  } else {
    $groups[$k] = $sorted
  }
}

# ====================================================================================
# Build AI input JSON per your style, upload, get summaries
# ====================================================================================
$tempJsonPath = Join-Path $env:TEMP ("aks-doc-groups-{0}.json" -f (Get-Date -Format 'yyyyMMddHHmmss'))
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

$summaries = @{}
if ($PreferProvider) {
  $summaries = Get-PerFileSummariesViaAssistant -JsonPath $tempJsonPath
}

# ====================================================================================
# Render HTML
# ====================================================================================
$sections = New-Object System.Collections.Generic.List[string]
foreach ($file in $groups.Keys) {
  $arr = $groups[$file]
  $fileUrl = "https://github.com/MicrosoftDocs/azure-aks-docs/blob/main/$file"
  $summary = $summaries[$file]

  $lis = foreach ($a in $arr) {
    $subject = ($a.commit.message -split "`n")[0]
    if (-not $subject) { $subject = "(no subject)" }
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

# Hash for idempotent updates
$sha256 = [System.Security.Cryptography.SHA256]::Create()
$bytes  = [Text.Encoding]::UTF8.GetBytes($html)
$hash   = ($sha256.ComputeHash($bytes) | ForEach-Object { $_.ToString("x2") }) -join ""

# Emit JSON for the workflow step
[pscustomobject]@{ html = $html; hash = $hash } | ConvertTo-Json -Depth 6
