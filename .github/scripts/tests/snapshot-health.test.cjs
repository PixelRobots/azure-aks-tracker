'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const { test } = require('node:test');
const { createDemo } = require('../snapshot-changes.cjs');
const { recordHealth, validateHealth, readCollectionSummary } = require('../snapshot-health.cjs');

const now = new Date();
const url = 'https://learn.microsoft.com/en-us/azure/aks/best-practices-gpu-observability';

function summary(attempted, errors, unreached = 0) {
  const failures = Array.from({ length: errors }, (_, index) =>
    ({ url: `${url}-${index}`, error: 'HTTP 200 text/html' }));
  return '### Learn mirror\n\n' +
    '| Pages | Unchanged (304) | Fetched | Gone | Errors | Not reached | Added | Changed | Removed | Throttled | Seconds |\n' +
    '|---|---|---|---|---|---|---|---|---|---|---|\n' +
    `| ${attempted} | ${attempted - errors - unreached} | 0 | 0 | ${errors} | ${unreached} | 0 | 0 | 0 | 0 | 1 |\n\n` +
    (errors ? `<details><summary>Errors</summary>\n\n${failures.map(item => `- ${item.url}: ${item.error}`).join('\n')}\n</details>\n` : '');
}

function fixture(run) {
  const repo = fs.mkdtempSync(path.join(os.tmpdir(), 'aks-health-test-'));
  try {
    createDemo(repo, now);
    run(repo);
  } finally {
    fs.rmSync(repo, { recursive: true, force: true });
  }
}

test('pinned collector summary records request counts and exact failed URLs and reasons', () => {
  const report = readCollectionSummary(summary(1494, 1));
  assert.deepEqual(report, {
    attempted: 1494, errors: 1, unreached: 0,
    failed_pages: [{ url: `${url}-0`, error: 'HTTP 200 text/html' }]
  });
  assert.deepEqual(readCollectionSummary(summary(100, 0)).failed_pages, []);
  assert.equal(readCollectionSummary(summary(100, 1, 2)).unreached, 2);
  for (const invalid of [
    '', summary(100, 1).replace(`- ${url}-0: HTTP 200 text/html\n`, ''),
    summary(100, 1).replace('| 100 | 99 |', '| 100 | 98 |'),
    summary(100, 1).replace(url, 'https://example.com/article'),
    summary(100, 1).replace('HTTP 200 text/html', ''),
    summary(100, 1).replace('text/html\n', `text/html\n- ${url}-0: duplicate\n`)
  ]) assert.throws(() => readCollectionSummary(invalid), /summary|inconsistent/);
});

test('publication accepts at most five failures and one percent without claiming completeness', () => fixture(repo => {
  for (const [attempted, errors, allowed] of [
    [1494, 1, true], [100, 1, true], [99, 1, false],
    [500, 5, true], [499, 5, false], [10000, 6, false], [100, 0, true]
  ]) {
    const collection = readCollectionSummary(summary(attempted, errors));
    const health = recordHealth(repo, {
      errors, unreached: 0, collection, now,
      runUrl: 'https://github.com/PixelRobots/azure-aks-tracker/actions/runs/1'
    });
    assert.equal(health.complete, errors === 0);
    assert.equal(health.publishable, allowed, `${errors}/${attempted}`);
    assert.deepEqual(health.failed_pages, collection.failed_pages);
    assert.deepEqual(JSON.parse(fs.readFileSync(path.join(repo, '.learn-mirror/health.json'), 'utf8')), health);
    if (allowed) assert.equal(validateHealth(health, now), health);
    else assert.throws(() => validateHealth(health, now), /incomplete or failed/);
  }
}));

test('unreached pages, stale health, missing coverage and inconsistent reports still fail closed', () => fixture(repo => {
  const collection = readCollectionSummary(summary(100, 1));
  const health = recordHealth(repo, { errors: 1, unreached: 0, collection, now });
  assert.throws(() => recordHealth(repo, { errors: 0, unreached: 0, collection, now }), /does not match/);
  assert.throws(() => validateHealth(health, new Date(now.getTime() + 13 * 3600000)), /stale/);
  for (const changes of [
    { complete: true }, { publishable: false }, { attempted: 99 },
    { failed_pages: [] }, { failed_pages: [{ url, error: '' }] },
    { products: ['AKS'] }, { unreached: 1 }, { schema_version: 3 },
    { errors: -1 }, { attempted: NaN }
  ]) assert.throws(() => validateHealth({ ...health, ...changes }, now), /incomplete or failed/);
  const partial = recordHealth(repo, {
    errors: 1, unreached: 1, now, collection: readCollectionSummary(summary(100, 1, 1))
  });
  assert.equal(partial.publishable, false);
  assert.throws(() => validateHealth(partial, now), /incomplete or failed/);
  const legacy = recordHealth(repo, { errors: 1, unreached: 0, now });
  assert.throws(() => validateHealth(legacy, now), /incomplete or failed/);
}));

test('workflow CLI records degraded warnings and shares the production publication gate', () => fixture(repo => {
  const script = path.resolve(__dirname, '../snapshot-health.cjs');
  const report = path.join(repo, 'collector-summary.md');
  const stepSummary = path.join(repo, 'actions-summary.md');
  for (const [errors, allowed] of [[1, true], [6, false]]) {
    fs.writeFileSync(report, summary(1494, errors));
    const recorded = spawnSync(process.execPath, [script, repo, String(errors), '0', report], {
      encoding: 'utf8', env: { ...process.env, GITHUB_STEP_SUMMARY: stepSummary }
    });
    assert.equal(recorded.status, 0, recorded.stderr);
    assert.match(recorded.stderr, /::warning::/);
    const gated = spawnSync(process.execPath, [script, '--validate', repo], { encoding: 'utf8' });
    assert.equal(gated.status, allowed ? 0 : 1, gated.stderr);
    assert.match(fs.readFileSync(stepSummary, 'utf8'), allowed ? /Publication allowed/ : /Publication blocked/);
  }
}));
