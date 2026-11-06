param(
  [switch]$UpdateCache,
  [string]$CachePath = 'retirements-cache.json',
  [string]$CollectionUri = 'https://www.microsoft.com/releasecommunications/api/v2/azure'
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
    @{ name = 'AKS'; pattern = '(?i)Azure Kubernetes Service|\bAKS\b(?!-Engine\b)' },
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
  if ($products.Count -eq 0 -and $metadataProducts.Count -eq 0) {
    $fallbackText = [string]$Item.title
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
    $dateText = '{0}`n{1}' -f [string]$Item.title, $description
    $monthNames = 'January|February|March|April|May|June|July|August|September|Sept|October|November|December|Jan|Feb|Mar|Apr|Jun|Jul|Aug|Sep|Oct|Nov|Dec'
    $datePatterns = @(
      @{ pattern = "(?i)\b(?<month>$monthNames)\s+(?<day>\d{1,2})(?:st|nd|rd|th)?[,]?\s+(?<year>\d{4})\b"; order = 'month-first' },
      @{ pattern = "(?i)\b(?<day>\d{1,2})(?:st|nd|rd|th)?\s+(?<month>$monthNames)\s+(?<year>\d{4})\b"; order = 'day-first' },
      @{ pattern = '\b(?<year>\d{4})-(?<monthNumber>\d{2})-(?<day>\d{2})\b'; order = 'iso' }
    )
    foreach ($datePattern in $datePatterns) {
      foreach ($match in [regex]::Matches($dateText, $datePattern.pattern)) {
        try {
          if ($datePattern.order -eq 'iso') {
            $date = [DateTime]::ParseExact(
              ('{0}-{1}-{2}' -f $match.Groups['year'].Value, $match.Groups['monthNumber'].Value, $match.Groups['day'].Value),
              'yyyy-MM-dd',
              [Globalization.CultureInfo]::InvariantCulture
            )
          }
          else {
            $monthName = $match.Groups['month'].Value
            if ($monthName -eq 'Sept') { $monthName = 'Sep' }
            $monthFormat = if ($monthName.Length -gt 3) { 'MMMM' } else { 'MMM' }
            $date = [DateTime]::ParseExact(
              ('{0} {1}, {2}' -f $monthName, $match.Groups['day'].Value, $match.Groups['year'].Value),
              ($monthFormat + ' d, yyyy'),
              [Globalization.CultureInfo]::InvariantCulture
            )
          }
          if ($date.Year -eq $availability.year -and $date.Month -eq $availability.monthNumber) {
            $retirementDate = $date.ToString('yyyy-MM-dd')
            break
          }
        }
        catch { }
      }
      if ($retirementDate) { break }
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
    [Parameter(Mandatory)][string]$CollectionUri
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
    $filter = [uri]::EscapeDataString("tags/any(t:t eq 'Retirements')")
    $select = [uri]::EscapeDataString('id,title,tags,products,description,availabilities,created,modified')
    $sourceItems = [System.Collections.Generic.List[object]]::new()
    $expectedCount = $null
    $skip = 0

    while ($null -eq $expectedCount -or $sourceItems.Count -lt $expectedCount) {
      $requestUri = '{0}?$filter={1}&$select={2}&$count=true&$top=100&$skip={3}' -f $CollectionUri.TrimEnd('/'), $filter, $select, $skip
      $page = Invoke-RestMethod -Uri $requestUri -Headers @{ 'User-Agent' = 'azure-aks-tracker-action/1.0' }
      if ($null -eq $expectedCount) {
        $expectedCount = [int]$page.'@odata.count'
        if ($expectedCount -lt 0) { throw 'Retirement collection returned an invalid item count.' }
      }
      $pageItems = @($page.value)
      if ($pageItems.Count -eq 0) { throw 'Retirement collection returned an empty page before all records were fetched.' }
      foreach ($item in $pageItems) { $sourceItems.Add($item) }
      $skip += $pageItems.Count
    }

    if ($null -eq $expectedCount -or $sourceItems.Count -ne $expectedCount) {
      throw "Retirement collection was incomplete: fetched $($sourceItems.Count) of $expectedCount records."
    }
    if ($expectedCount -eq 0 -and $records.Count -gt 0) {
      throw 'Retirement collection unexpectedly returned no records; preserving the existing archive.'
    }
  }
  catch {
    Write-Warning "Could not refresh the complete retirement collection; keeping the existing archive: $_"
    return
  }

  $changed = -not (Test-Path -LiteralPath $Path)
  foreach ($item in $sourceItems) {
    $id = [string]$item.id
    if ([string]::IsNullOrWhiteSpace($id)) { continue }
    $sourceUpdated = ConvertTo-RetirementIsoTimestamp $item.modified
    if ([string]::IsNullOrWhiteSpace($sourceUpdated)) { $sourceUpdated = ConvertTo-RetirementIsoTimestamp $item.created }
    $storedFilterVersion = 0
    if ($records.ContainsKey($id)) {
      try { $storedFilterVersion = [int]$records[$id].filterVersion } catch { }
    }
    if ($records.ContainsKey($id) -and [string]$records[$id].sourceUpdated -eq $sourceUpdated -and $storedFilterVersion -eq 7) { continue }

    $record = ConvertTo-AksRetirementRecord $item
    if (-not $record) {
      if ($records.ContainsKey($id)) {
        $records.Remove($id)
        $changed = $true
      }
      continue
    }
    $record | Add-Member -NotePropertyName sourceUpdated -NotePropertyValue $sourceUpdated -Force
    $record | Add-Member -NotePropertyName filterVersion -NotePropertyValue 7 -Force
    $records[$id] = $record
    $changed = $true
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
  Update-AksRetirementCache -Path $CachePath -CollectionUri $CollectionUri
}