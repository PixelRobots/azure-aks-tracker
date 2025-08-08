#!/usr/bin/env pwsh
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ====================================================================================
# Config
# ====================================================================================
$Owner = "MicrosoftDocs"
$Repo  = "azure-aks-docs"

$GitHubToken = $env:GITHUB_TOKEN
if (-not $GitHubToken) { Write-Error "GITHUB_TOKEN not set"; exit 1 }

# Prefer OpenAI if OpenAIKey is present; otherwise Azure OpenAI if all vars set
$PreferProvider = if ($env:OpenAIKey) { 'OpenAI' } elseif ($env:AZURE_OPENAI_APIURI -and $env:AZURE_OPENAI_KEY -and $env:AZURE_OPENAI_API_VERSION -and $env:AZURE_OPENAI_DEPLOYMENT) { 'AzureOpenAI' } else { '' }

$now = [DateTime]::UtcNow
$sinceMidnightUtc = (Get-Date -Date $now.ToString("yyyy-MM-dd") -AsUTC).AddDays(-7)
$SINCE_ISO = $sinceMidnightUtc.ToString("o")

$ghHeaders = @{
  "Authorization" = "Bearer $GitHubToken"
  "Accept"        = "application/vnd.github+json"
  "User-Agent"    = "pixelrobots-aks-updates-pwsh"
}

# ====================================================================================
# Helpers
# ====================================================================================
function Log($msg) { Write-Host "[AKS] $msg" }

function Escape-Html([string]$s) {
  $s.Replace('&','&amp;').Replace('<','&lt;').Replace('>','&gt;').Replace('"','&quot;')
}

function ShortTitle([string]$path) { ($path -split '/')[ -1 ] }

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

function Get-RecentMergedPRs {
  param([string]$Owner,[string]$Repo,[DateTime]$SinceUtc)
  $all = @()
  for ($page=1; $page -le 6; $page++) {
    $uri = "https://api.github.com/repos/$Owner/$Repo/pulls?state=closed&sort=updated&direction=desc&per_page=100&page=$page"
    $resp = Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
    if (-not $resp -or $resp.Count -eq 0) { break }
    $recent = $resp | Where-Object { $_.merged_at -and ([DateTime]::Parse($_.merged_at).ToUniversalTime() -ge $SinceUtc) }
    $all += $recent
    $oldestMerged = ($resp | Where-Object merged_at | Sort-Object { [DateTime]$_.merged_at } | Select-Object -First 1).merged_at
    if ($oldestMerged -and ([DateTime]::Parse($oldestMerged).ToUniversalTime() -lt $SinceUtc)) { break }
    if ($resp.Count -lt 100) { break }
  }
  return $all
}

function Get-PRFiles { param([string]$Owner,[string]$Repo,[int]$Number)
  $uri = "https://api.github.com/repos/$Owner/$Repo/pulls/$Number/files?per_page=100"
  Invoke-RestMethod -Uri $uri -Headers $ghHeaders -Method GET
}

# ====================================================================================
# AI (PSAI) init — optional, never fatal
# ====================================================================================
$PSAIReady = $false
function Initialize-AIProvider { param([ValidateSet('OpenAI','AzureOpenAI')][string]$Provider)
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
        Write-Warning "Azure OpenAI envs incomplete; skipping AI."
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
} else {
  Log "AI disabled (no env configured); proceeding without summaries"
}

function Get-PerFileSummariesViaAssistant {
  param([Parameter(Mandatory)][string]$JsonPath,[string]$Model = "gpt-4o-mini")
  if (-not $PSAIReady) { Log "AI not ready; returning empty summaries"; return @{} }
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
Input contains per-file groups with recent merged PRs, including titles/bodies and limited patches.
Write 1–2 clear sentences per file explaining the substantive doc changes (new sections, expanded guidance, new examples, major reorg), not typos.
Ignore trivial edits. Use PR content/patch hints to infer what changed in the docs.
Return ONLY a JSON array of: { "file": "<path>", "summary": "…" }.
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

    $clean = $last -replace '^\s*```(?:json)?\s*','' -replace '\s*```\s*$',''
    $match = [regex]::Match($clean,'\[(?:[^][]|(?<open>\[)|(?<-open>\]))*\](?(open)(?!))','Singleline')
    if (-not $match.Success) { Log "AI returned no JSON array; skipping"; return @{} }

    $arr = $match.Value | ConvertFrom-Json -ErrorAction Stop
    $map = @{}; foreach ($i in $arr) { $map[$i.file] = $i.summary }
    return $map
  } catch {
    Write-Warning "Assistant summaries failed: $_"
    return @{}
  }
}

# ====================================================================================
# Fetch PRs & files
# ====================================================================================
Write-Host "::group::Fetch PRs"
$prs = Get-RecentMergedPRs -Owner $Owner -Repo $Repo -SinceUtc $sinceMidnightUtc
Log "Recent merged PRs in window: $($prs.Count)"

$prDetails = @()
foreach ($pr in $prs) {
  $files = Get-PRFiles -Owner $Owner -Repo $Repo -Number $pr.number
  $prDetails += [pscustomobject]@{
    number     = $pr.number
    html_url   = $pr.html_url
    title      = $pr.title
    body       = $pr.body
    user       = $pr.user.login
    merged_at  = $pr.merged_at
    files      = $files
  }
}
Log "Hydrated PRs with files: $($prDetails.Count)"
Write-Host "::endgroup::"

# ====================================================================================
# Filter & Group
# ====================================================================================
Write-Host "::group::Filter & Group"
$prFiltered = $prDetails | Where-Object { ($_ .user -notmatch '(bot|actions)') -and (-not (Test-IsNoiseMessage $_.title)) }

$entries = foreach ($pr in $prFiltered) {
  foreach ($f in $pr.files) {
    if ($f.filename -notmatch '\.md$') { continue }
    $adds = $f.additions; if ($null -eq $adds) { $adds = 0 }
    $dels = $f.deletions; if ($null -eq $dels) { $dels = 0 }
    if (($adds + $dels) -le 3) { continue }
    [pscustomobject]@{
      file       = $f.filename
      pr_number  = $pr.number
      pr_url     = $pr.html_url
      pr_title   = $pr.title
      pr_body    = $pr.body
      merged_at  = ([DateTime]::Parse($pr.merged_at).ToUniversalTime())
      additions  = $adds
      deletions  = $dels
      patch      = $f.patch
    }
  }
}

$groups = @{}
foreach ($e in $entries) {
  if (-not $groups.ContainsKey($e.file)) { $groups[$e.file] = @() }
  $groups[$e.file] += $e
}
foreach ($k in @($groups.Keys)) {
  $sorted = $groups[$k] | Sort-Object merged_at -Descending
  if (-not ($sorted | Where-Object { $_.merged_at -ge $sinceMidnightUtc })) {
    $groups.Remove($k)
  } else {
    $groups[$k] = $sorted
  }
}
Log "Grouped into $($groups.Keys.Count) doc pages"
Write-Host "::endgroup::"

# ====================================================================================
# AI input & summaries (never fatal)
# ====================================================================================
Write-Host "::group::AI Summaries"
$TmpRoot = $env:RUNNER_TEMP; if ([string]::IsNullOrWhiteSpace($TmpRoot)) { $TmpRoot = $env:TEMP }
if ([string]::IsNullOrWhiteSpace($TmpRoot)) { $TmpRoot = $env:TMPDIR }
if ([string]::IsNullOrWhiteSpace($TmpRoot)) { $TmpRoot = [System.IO.Path]::GetTempPath() }
if ([string]::IsNullOrWhiteSpace($TmpRoot)) { $TmpRoot = "." }
New-Item -ItemType Directory -Force -Path $TmpRoot | Out-Null
$tempJsonPath = Join-Path $TmpRoot ("aks-doc-pr-groups-{0}.json" -f (Get-Date -Format 'yyyyMMddHHmmss'))

$aiInput = [pscustomobject]@{
  since  = $SINCE_ISO
  groups = @(
    foreach ($k in $groups.Keys) {
      $arr = $groups[$k]
      [pscustomobject]@{
        file = $k
        prs  = @(
          foreach ($x in $arr | Select-Object -First 8) {
            $patch = $x.patch
            if ($patch -and $patch.Length -gt 5000) { $patch = $patch.Substring(0,5000) + "…[truncated]" }
            [pscustomobject]@{
              number    = $x.pr_number
              title     = $x.pr_title
              body      = $x.pr_body
              merged_at = ($x.merged_at.ToString("o"))
              additions = $x.additions
              deletions = $x.deletions
              patch     = $patch
              url       = $x.pr_url
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
try {
  if ($PreferProvider -and $PSAIReady) {
    $summaries = Get-PerFileSummariesViaAssistant -JsonPath $tempJsonPath
    Log "Summaries returned for $($summaries.Keys.Count) files"
  } else {
    Log "AI unavailable; skipping summaries"
  }
} catch {
  Write-Warning "AI step failed unexpectedly: $_"
  $summaries = @{}
}
Write-Host "::endgroup::"

# ====================================================================================
# Render HTML (always)
# ====================================================================================
$sections = New-Object System.Collections.Generic.List[string]
foreach ($file in $groups.Keys) {
  $arr = $groups[$file]
  $fileUrl = "https://github.com/$Owner/$Repo/blob/main/$file"
  $summary = $summaries[$file]

  # Prefer PR list per file
  $lis = foreach ($x in $arr) {
    $dateIso = $x.merged_at.ToString('yyyy-MM-dd')
    "<li><a href=""$($x.pr_url)"">$(Escape-Html $x.pr_title)</a> <small>$dateIso</small></li>"
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

# Always output JSON so the workflow can parse it
[pscustomobject]@{ html = $html; hash = $hash } | ConvertTo-Json -Depth 6
