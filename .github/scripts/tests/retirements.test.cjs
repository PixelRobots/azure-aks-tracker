'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const { test } = require('node:test');

const scriptPath = path.resolve(__dirname, '../retirements.ps1').replace(/'/g, "''");

test('normalizes full notices and matches AKS products when API metadata is empty', () => {
  const command = `
    $ErrorActionPreference = 'Stop'
    . '${scriptPath}'
    $item = [pscustomobject]@{
      id = '571257'
      title = 'Retirement: Azure Linux with OS Guard in Azure Kubernetes Service'
      tags = @('Retirements')
      products = @()
      productCategories = @()
      description = 'Support for Azure Linux with OS Guard in Azure Kubernetes Service will end on December 10, 2026. <b>Recommended action:</b><ul><li>Move affected node pools.</li></ul> On March 10, 2027, AKS will remove the images.'
      availabilities = @([pscustomobject]@{ ring = 'Retirement'; year = 2026; month = 'December' })
      created = '2026-09-11T18:08:28Z'
      modified = '2026-09-11T18:08:28Z'
    }
    $record = ConvertTo-AksRetirementRecord $item
    $shortMonthDate = ConvertTo-AksRetirementRecord ([pscustomobject]@{
      id = 'aks-gpu'; title = 'Retirement: AKS GPU image retires Jan 10, 2025'
      tags = @('Retirements'); products = @('Azure Kubernetes Service (AKS)')
      description = ''; availabilities = @([pscustomobject]@{ ring = 'Retirement'; year = 2025; month = 'January' })
    })
    $dayFirstDate = ConvertTo-AksRetirementRecord ([pscustomobject]@{
      id = 'aks-legacy'; title = 'AKS legacy integration retires on 29 February 2024'
      tags = @('Retirements'); products = @('Azure Kubernetes Service (AKS)')
      description = ''; availabilities = @([pscustomobject]@{ ring = 'Retirement'; year = 2024; month = 'February' })
    })
    $isoDate = ConvertTo-AksRetirementRecord ([pscustomobject]@{
      id = 'aks-iso'; title = 'Retirement: AKS feature'
      tags = @('Retirements'); products = @('Azure Kubernetes Service (AKS)')
      description = 'The feature retires on 2027-03-15.'
      availabilities = @([pscustomobject]@{ ring = 'Retirement'; year = 2027; month = 'March' })
    })
    $notRetirement = ConvertTo-AksRetirementRecord ([pscustomobject]@{
      id = 'feature-1'; title = 'AKS preview'; tags = @('Features'); products = @('Azure Kubernetes Service (AKS)')
      productCategories = @(); description = ''; availabilities = @()
    })
    $vmRetirement = ConvertTo-AksRetirementRecord ([pscustomobject]@{
      id = '569592'; title = 'Retirement: DCsv3 and DCdsv3-series Azure Virtual Machines'
      tags = @('Retirements'); products = @('Virtual Machines'); productCategories = @('Compute', 'Virtual Machines')
      description = 'On October 31, 2029, DCsv3 and DCdsv3-series virtual machines will retire. For containerized applications, consider Azure Kubernetes Service (AKS).'
      availabilities = @([pscustomobject]@{ ring = 'Retirement'; year = 2029; month = 'October' })
    })
    $appServiceRetirement = ConvertTo-AksRetirementRecord ([pscustomobject]@{
      id = '500016'; title = 'Retirement: Azure App Service on Azure Arc enabled Kubernetes'
      tags = @('Retirements'); products = @('App Service'); productCategories = @()
      description = 'Azure App Service on Azure Arc enabled Kubernetes is retiring. Migrate to AKS.'
      availabilities = @()
    })
    $aksEngineRetirement = ConvertTo-AksRetirementRecord ([pscustomobject]@{
      id = 'aks-engine-monitor'; title = 'Retirement: Azure Monitor for AKS-Engine'
      tags = @('Retirements'); products = @(); productCategories = @()
      description = 'Azure Monitor for AKS-Engine is retiring.'
      availabilities = @()
    })
    if ($notRetirement) { throw 'Non-retirement item was included.' }
    @{ record = $record; short_month_date = $shortMonthDate; day_first_date = $dayFirstDate; iso_date = $isoDate; vm_retirement = $vmRetirement; app_service_retirement = $appServiceRetirement; aks_engine_retirement = $aksEngineRetirement } | ConvertTo-Json -Depth 6 -Compress
  `;
  const result = spawnSync('pwsh', ['-NoProfile', '-Command', command], { encoding: 'utf8', timeout: 30000 });
  assert.equal(result.status, 0, result.stdout + result.stderr);
  const { record, short_month_date: shortMonthDate, day_first_date: dayFirstDate, iso_date: isoDate, vm_retirement: vmRetirement, app_service_retirement: appServiceRetirement, aks_engine_retirement: aksEngineRetirement } = JSON.parse(result.stdout);
  assert.equal(record.id, '571257');
  assert.equal(record.retirementDate, '2026-12-10');
  assert.equal(record.modified, '2026-09-11T18:08:28Z');
  assert.ok(record.products.includes('Azure Linux'));
  assert.ok(record.products.includes('AKS'));
  assert.match(record.description, /Move affected node pools/);
  assert.match(record.description, /Recommended action:\n- Move affected node pools/);
  assert.match(record.description, /March 10, 2027/);
  assert.doesNotMatch(record.description, /<[^>]+>/);
  assert.equal(shortMonthDate.retirementDate, '2025-01-10');
  assert.equal(dayFirstDate.retirementDate, '2024-02-29');
  assert.equal(isoDate.retirementDate, '2027-03-15');
  assert.equal(vmRetirement, null, 'migration suggestions should not classify unrelated VM retirements as AKS');
  assert.equal(appServiceRetirement, null, 'unrelated nonempty product metadata should not fall back to Kubernetes title text');
  assert.equal(aksEngineRetirement, null, 'AKS-Engine should not be classified as Azure Kubernetes Service');
});

test('refreshes retirement records across every collection page', () => {
  const cachePath = path.join(os.tmpdir(), `aks-retirements-${process.pid}-${Date.now()}.json`).replace(/'/g, "''");
  const command = `
    function Invoke-RestMethod {
      param($Uri,$Headers)
      if ($Uri -match '\\$skip=0') {
        return [pscustomobject]@{
          '@odata.count' = 2
          '@odata.nextLink' = 'https://api.test/azure?$skip=1'
          value = @([pscustomobject]@{
            id = 'aks-1'; title = 'Retirement: AKS test'; tags = @('Retirements')
            products = @('Azure Kubernetes Service (AKS)'); description = 'AKS support ends on December 10, 2026.'
            availabilities = @([pscustomobject]@{ ring = 'Retirement'; year = 2026; month = 'December' })
            created = '2026-09-11T18:08:28Z'; modified = '2026-09-11T18:08:28Z'
          })
        }
      }
      if ($Uri -match '\\$skip=1') {
        return [pscustomobject]@{
          '@odata.count' = 2
          value = @([pscustomobject]@{
            id = 'other-1'; title = 'Retirement: unrelated VM'; tags = @('Retirements')
            products = @('Virtual Machines'); description = 'VMs retire on December 10, 2026.'
            availabilities = @([pscustomobject]@{ ring = 'Retirement'; year = 2026; month = 'December' })
            created = '2026-09-11T18:08:28Z'; modified = '2026-09-11T18:08:28Z'
          })
        }
      }
      throw "Unexpected page request: $Uri"
    }
    & '${scriptPath}' -UpdateCache -CachePath '${cachePath}' -CollectionUri 'https://api.test/azure' | Out-Null
    $cache = Get-Content -LiteralPath '${cachePath}' -Raw | ConvertFrom-Json
    if ($cache.items.Count -ne 1 -or $cache.items[0].id -ne 'aks-1') { throw 'The full paginated collection was not filtered and archived correctly.' }
    if ($cache.items[0].filterVersion -ne 7) { throw 'The archive filter version was not updated.' }
  `;
  try {
    const result = spawnSync('pwsh', ['-NoProfile', '-Command', command], { encoding: 'utf8', timeout: 30000 });
    assert.equal(result.status, 0, result.stdout + result.stderr);
  } finally {
    fs.rmSync(cachePath, { force: true });
  }
});

test('does not create an empty archive when the retirement collection is unavailable', () => {
  const cachePath = path.join(os.tmpdir(), `aks-retirements-${process.pid}-${Date.now()}.json`).replace(/'/g, "''");
  const command = `
    function Invoke-RestMethod { param($Uri,$Headers) throw 'simulated collection API outage' }
    & '${scriptPath}' -UpdateCache -CachePath '${cachePath}' -CollectionUri 'https://api.test/azure' | Out-Null
    if (Test-Path -LiteralPath '${cachePath}') { throw 'An empty cache was created after the collection API failed.' }
  `;
  try {
    const result = spawnSync('pwsh', ['-NoProfile', '-Command', command], { encoding: 'utf8', timeout: 30000 });
    assert.equal(result.status, 0, result.stdout + result.stderr);
  } finally {
    fs.rmSync(cachePath, { force: true });
  }
});