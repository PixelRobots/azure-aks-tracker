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
    if ($notRetirement) { throw 'Non-retirement item was included.' }
    @{ record = $record; vm_retirement = $vmRetirement } | ConvertTo-Json -Depth 6 -Compress
  `;
  const result = spawnSync('pwsh', ['-NoProfile', '-Command', command], { encoding: 'utf8', timeout: 30000 });
  assert.equal(result.status, 0, result.stdout + result.stderr);
  const { record, vm_retirement: vmRetirement } = JSON.parse(result.stdout);
  assert.equal(record.id, '571257');
  assert.equal(record.retirementDate, '2026-12-10');
  assert.equal(record.modified, '2026-09-11T18:08:28Z');
  assert.ok(record.products.includes('Azure Linux'));
  assert.ok(record.products.includes('AKS'));
  assert.match(record.description, /Move affected node pools/);
  assert.match(record.description, /Recommended action:\n- Move affected node pools/);
  assert.match(record.description, /March 10, 2027/);
  assert.doesNotMatch(record.description, /<[^>]+>/);
  assert.equal(vmRetirement, null, 'migration suggestions should not classify unrelated VM retirements as AKS');
});

test('does not create an empty archive when all detail API requests fail', () => {
  const cachePath = path.join(os.tmpdir(), `aks-retirements-${process.pid}-${Date.now()}.json`).replace(/'/g, "''");
  const command = `
    $script:feedFixture = '<rss><channel><item><guid>571257</guid><category>Retirements</category><pubDate>Fri, 11 Sep 2026 18:08:28 Z</pubDate></item></channel></rss>'
    function Invoke-WebRequest { param($Uri,$Headers) [pscustomobject]@{ Content = $script:feedFixture } }
    function Invoke-RestMethod { param($Uri,$Headers) throw 'simulated detail API outage' }
    & '${scriptPath}' -UpdateCache -CachePath '${cachePath}' -FeedUri 'https://feed.test/rss' -ItemApiBaseUri 'https://api.test' | Out-Null
    if (Test-Path -LiteralPath '${cachePath}') { throw 'An empty cache was created after all detail requests failed.' }
  `;
  try {
    const result = spawnSync('pwsh', ['-NoProfile', '-Command', command], { encoding: 'utf8', timeout: 30000 });
    assert.equal(result.status, 0, result.stdout + result.stderr);
  } finally {
    fs.rmSync(cachePath, { force: true });
  }
});