param(
  [switch]$UpdateCache,
  [string]$CachePath = 'retirements-cache.json',
  [string]$FeedUri = 'https://www.microsoft.com/releasecommunications/api/v2/azure/rss',
  [string]$ItemApiBaseUri = 'https://www.microsoft.com/releasecommunications/api/v2/azure'
)

function ConvertTo-RetirementPlainText {
  param([AllowNull()][string]$Html)

  if ([string]::IsNullOrWhiteSpace($Html)) { return '' }
  $text = $Html -replace '(?i)<br\s*/?>|</(?:p|li|ul|ol|div|h[1-6])\s*>|<(?:p|ul|ol|div|h[1-6])\b[^>]*>', "`n"
  $text = $text -replace '(?i)<li\b[^>]*>', '- '
  $text = $text -replace '<[^>]+>', ''
  $text = [System.Net.WebUtility]::HtmlDecode($text)
  $text = $text -replace '[\t ]+', ' '
  $text = $text -replace ' *\r?\n *', "`n"
  $text = $text -replace '\n{3,}', "`n`n"
  return $text.Trim()
}

function ConvertTo-RetirementIsoTimestamp {
  param([AllowNull()]$Value)

  if ($null -eq $Value) { return '' }
  if ($Value -is [DateTime]) { return $Value.ToUniversalTime().ToString("yyyy-MM-dd'T'HH:mm:ss'Z'") }
  try {
    return [DateTimeOffset]::Parse([string]$Value, [Globalization.CultureInfo]::InvariantCulture).ToUniversalTime().ToString("yyyy-MM-dd'T'HH:mm:ss'Z'")
  }
  catch { return [string]$Value }
}

function ConvertTo-AksRetirementRecord {
  param([Parameter(Mandatory)]$Item)

  $tags = @($Item.tags | ForEach-Object { [string]$_ })
  if ($tags -notcontains 'Retirements') { return $null }

  $description = ConvertTo-RetirementPlainText ([string]$Item.description)
  $metadataProducts = @($Item.products | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) })

  $productRules = @(
    @{ name = 'AKS'; pattern = '(?i)Azure Kubernetes Service|\bAKS\b' },
    @{ name = 'AKS Application Network'; pattern = '(?i)AKS Application Network|Application Network|\bIstio\b' },
    @{ name = 'Azure Arc-enabled Kubernetes'; pattern = '(?i)Azure Arc[- ]enabled Kubernetes|Kubernetes - Azure Arc|AKS Arc|Arc-enabled Kubernetes' },
    @{ name = 'Kubernetes Fleet Manager'; pattern = '(?i)Kubernetes Fleet Manager|\bFleet Manager\b' },
    @{ name = 'Azure Linux'; pattern = '(?i)Azure Linux|Azure Container Linux' },
    @{ name = 'Azure Container Registry'; pattern = '(?i)Azure Container Registry|\bACR\b' },
    @{ name = 'Application Gateway for Containers'; pattern = '(?i)Application Gateway for Containers|\bAGC\b' }
  )
  $products = @(
    foreach ($rule in $productRules) {
      if (($metadataProducts -join ' ') -match $rule.pattern) { $rule.name }
    }
  )
  if ($products.Count -eq 0) {
    $openingDescription = [regex]::Split($description, '(?<=[.!?])\s+', 2)[0]
    $fallbackText = '{0} {1}' -f [string]$Item.title, $openingDescription
    $products = @(
      foreach ($rule in $productRules) {
        if ($fallbackText -match $rule.pattern) { $rule.name }
      }
    )
  }
  if ($products.Count -eq 0) { return $null }

  $availability = @(
    foreach ($entry in @($Item.availabilities)) {
      if ([string]$entry.ring -ne 'Retirement') { continue }
      $monthDate = $null
      foreach ($format in @('MMMM', 'MMM')) {
        try {
          $monthDate = [DateTime]::ParseExact([string]$entry.month, $format, [Globalization.CultureInfo]::InvariantCulture)
          break
        }
        catch { }
      }
      if ($monthDate) {
        [pscustomobject]@{
          year = [int]$entry.year
          month = [string]$entry.month
          monthNumber = $monthDate.Month
        }
      }
    }
  ) | Sort-Object { $_.year * 100 + $_.monthNumber } | Select-Object -First 1

  $retirementDate = $null
  $retirementMonth = $null
  if ($availability) {
    $retirementMonth = '{0} {1}' -f $availability.month, $availability.year
    $datePattern = '(?i)\b(?<month>January|February|March|April|May|June|July|August|September|October|November|December)\s+(?<day>\d{1,2}),?\s+(?<year>\d{4})\b'
    foreach ($match in [regex]::Matches($description, $datePattern)) {
      $date = [DateTime]::ParseExact(
        ('{0} {1} {2}' -f $match.Groups['month'].Value, $match.Groups['day'].Value, $match.Groups['year'].Value),
        'MMMM d yyyy',
        [Globalization.CultureInfo]::InvariantCulture
      )
      if ($date.Year -eq $availability.year -and $date.Month -eq $availability.monthNumber) {
        $retirementDate = $date.ToString('yyyy-MM-dd')
        break
      }
    }
  }

  return [pscustomobject]@{
    id = [string]$Item.id
    title = [string]$Item.title
    products = $products
    retirementDate = $retirementDate
    retirementMonth = $retirementMonth
    description = $description
    url = 'https://azure.microsoft.com/updates?id={0}' -f [uri]::EscapeDataString([string]$Item.id)
    created = ConvertTo-RetirementIsoTimestamp $Item.created
    modified = ConvertTo-RetirementIsoTimestamp $Item.modified
  }
}

function Update-AksRetirementCache {
  param(
    [Parameter(Mandatory)][string]$Path,
    [Parameter(Mandatory)][string]$RssUri,
    [Parameter(Mandatory)][string]$ApiBaseUri
  )

  $records = @{}
  if (Test-Path -LiteralPath $Path) {
    try {
      $cache = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
      if ([int]$cache.schema_version -notin @(1, 2)) { throw 'Unsupported retirement cache schema.' }
      foreach ($record in @($cache.items)) {
        if (-not [string]::IsNullOrWhiteSpace([string]$record.id)) {
          $records[[string]$record.id] = $record
        }
      }
    }
    catch {
      Write-Warning "Could not load retirement cache at '$Path'; preserving the file and skipping refresh: $_"
      return
    }
  }

  try {
    $feedResponse = Invoke-WebRequest -Uri $RssUri -Headers @{ 'User-Agent' = 'azure-aks-tracker-action/1.0' }
    $feedContent = ([string]$feedResponse.Content).TrimStart([char]0xFEFF, [char]0x20, [char]0x09, [char]0x0D, [char]0x0A)
    $feed = [xml]$feedContent
    $feedItems = @($feed.SelectNodes('/rss/channel/item'))
    if ($feedItems.Count -eq 0) { throw 'Azure Updates RSS feed returned no items.' }
  }
  catch {
    Write-Warning "Could not refresh retirement feed; keeping the existing archive: $_"
    return
  }

  $changed = -not (Test-Path -LiteralPath $Path)
  $detailFailures = 0
  foreach ($feedItem in $feedItems) {
    $categories = @($feedItem.SelectNodes('./category') | ForEach-Object { [string]$_.InnerText })
    if ($categories -notcontains 'Retirements') { continue }

    $idNode = $feedItem.SelectSingleNode('./guid')
    $id = if ($idNode) { [string]$idNode.InnerText } else { '' }
    if ([string]::IsNullOrWhiteSpace($id)) { continue }

    $updatedNode = $feedItem.SelectSingleNode('./*[local-name()="updated"]')
    $sourceUpdated = if ($updatedNode) { [string]$updatedNode.InnerText } else { [string]$feedItem.pubDate }
    $storedFilterVersion = 0
    if ($records.ContainsKey($id)) {
      try { $storedFilterVersion = [int]$records[$id].filterVersion } catch { }
    }
    if ($records.ContainsKey($id) -and [string]$records[$id].sourceUpdated -eq $sourceUpdated -and $storedFilterVersion -eq 5) { continue }

    try {
      $detailUri = '{0}/{1}' -f $ApiBaseUri.TrimEnd('/'), [uri]::EscapeDataString($id)
      $detail = Invoke-RestMethod -Uri $detailUri -Headers @{ 'User-Agent' = 'azure-aks-tracker-action/1.0' }
      $record = ConvertTo-AksRetirementRecord $detail
      if (-not $record) {
        if ($records.ContainsKey($id) -and $storedFilterVersion -lt 5) {
          $records.Remove($id)
          $changed = $true
        }
        continue
      }
      $record | Add-Member -NotePropertyName sourceUpdated -NotePropertyValue $sourceUpdated -Force
      $record | Add-Member -NotePropertyName filterVersion -NotePropertyValue 5 -Force
      $records[$id] = $record
      $changed = $true
    }
    catch {
      $detailFailures++
      Write-Warning "Could not fetch retirement update '$id'; keeping its previous record if available: $_"
    }
  }

  if ($detailFailures -gt 0 -and $records.Count -eq 0) {
    Write-Warning 'No retirement details were fetched; leaving the archive untouched.'
    return
  }

  if (-not $changed) {
    Write-Host 'Retirement archive is unchanged.'
    return
  }

  $archive = [ordered]@{
    schema_version = 2
    source = 'Microsoft Azure Updates / Release Communications API'
    items = @($records.Values | Sort-Object id)
  }
  $archive | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $Path -Encoding utf8
  Write-Host "Saved $($archive.items.Count) tracked retirement notices to '$Path'."
}

if ($UpdateCache) {
  Update-AksRetirementCache -Path $CachePath -RssUri $FeedUri -ApiBaseUri $ItemApiBaseUri
}