'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { execFileSync, spawnSync } = require('node:child_process');
const { test } = require('node:test');
const { buildChanges, body, createDemo, routeFor } = require('../snapshot-changes.cjs');
const { render, compare } = require('../render-snapshot-preview.cjs');
const { recordHealth, validateHealth } = require('../snapshot-health.cjs');

const now = new Date();
const root = path.resolve(__dirname, '../../..');
const article = 'articles/aks/what-is-aks.md';

function fixture(run) {
  const repo = fs.mkdtempSync(path.join(os.tmpdir(), 'aks-snapshot-test-'));
  const git = (...args) => execFileSync('git', ['-C', repo, ...args], { encoding: 'utf8' }).trim();
  const commit = (message = 'Test content', date = now) => {
    git('add', '-A');
    const result = spawnSync('git', ['-C', repo, 'commit', '--allow-empty', '-m', message], {
      encoding: 'utf8', env: { ...process.env, GIT_AUTHOR_DATE: date.toISOString(), GIT_COMMITTER_DATE: date.toISOString() }
    });
    assert.equal(result.status, 0, result.stderr);
    return git('rev-parse', 'HEAD');
  };
  try {
    const baseline = createDemo(repo, now);
    run({ repo, git, commit, baseline, build: options => buildChanges({ repo, baseline, now, ...options }) });
  } finally {
    fs.rmSync(repo, { recursive: true, force: true });
  }
}

test('body normalization ignores front matter, CRLF and trailing whitespace', () => {
  assert.equal(body('---\nupdated_at: today\ntitle: One\n---\n# Article  \r\n\r\nText  \r\n'),
    body('---\nupdated_at: tomorrow\n---\n# Article\n\nText\n'));
});

test('all nine support routes retain the AKS Support product', () => {
  for (const category of ['availability-performance', 'connectivity', 'create-upgrade-delete',
    'error-codes', 'extensions', 'load-bal-ingress-c', 'logs', 'security', 'storage']) {
    assert.equal(routeFor(`support/azure/azure-kubernetes/${category}/test.md`).product, 'AKS Support');
  }
});

test('qualified baseline does not replay existing articles; demo changes cover all eight products', () => fixture(({ build, baseline }) => {
  const initial = build({ head: baseline });
  assert.equal(initial.changes.length, 0);
  assert.equal(initial.baseline_only, true);
  const changed = build();
  assert.equal(changed.changes.length, 8);
  assert.equal(new Set(changed.changes.map(item => item.product)).size, 8);
  for (const item of changed.changes) {
    assert.equal(item.status, 'modified');
    assert.ok(item.additions > 0);
    assert.ok(item.deletions > 0);
    assert.ok(item.patch.includes('## Security and operations'));
    assert.match(item.evidence_url, /\/commit\/[a-f0-9]{40}$/);
    assert.equal(new Date(item.detected_at).getTime(), Math.floor(now.getTime() / 1000) * 1000);
  }
}));

test('metadata-only/state changes do not emit articles; detection time follows content, not republish', () => fixture(({ repo, build, git, commit }) => {
  const head = git('rev-parse', 'HEAD');
  const file = path.join(repo, article);
  fs.writeFileSync(file, fs.readFileSync(file, 'utf8').replace('title:', 'updated_at: later\ntitle:'));
  const state = path.join(repo, '.learn-mirror/state.json');
  fs.writeFileSync(state, JSON.stringify(JSON.parse(fs.readFileSync(state, 'utf8')), null, 2));
  commit('Metadata only', new Date(now.getTime() + 1000));
  const changed = build();
  assert.equal(changed.changes.length, 8);
  assert.equal(changed.changes.find(item => item.filename === article).sha, head);
  const none = build({ baseline: head });
  assert.equal(none.changes.length, 0);
}));

test('new articles emit once, net reverts disappear, deletions are held for review', () => fixture(({ repo, build, git, commit, baseline }) => {
  const newFile = 'articles/aks/new-security-guide.md';
  fs.writeFileSync(path.join(repo, newFile), '# New security guide\n\nRequire managed identity.\n');
  const statePath = path.join(repo, '.learn-mirror/state.json');
  const state = JSON.parse(fs.readFileSync(statePath, 'utf8'));
  state.pages['https://learn.microsoft.com/en-us/azure/aks/new-security-guide'] = { path: newFile };
  fs.writeFileSync(statePath, JSON.stringify(state));
  fs.writeFileSync(path.join(repo, article), git('show', `${baseline}:${article}`) + '\n');
  fs.rmSync(path.join(repo, 'articles/application-network/overview.md'));
  commit();
  const result = build();
  assert.equal(result.changes.find(item => item.filename === newFile).status, 'added');
  assert.equal(result.changes.some(item => item.filename === article), false);
  assert.equal(result.changes.some(item => item.product === 'Application Network'), false);
  assert.equal(result.suppressed.length, 1);
}));

test('content-preserving moves are not reported as newly published pages', () => fixture(({ repo, build, commit, git }) => {
  const baseline = git('rev-parse', 'HEAD');
  const replacement = 'articles/aks/renamed-guide.md';
  fs.renameSync(path.join(repo, article), path.join(repo, replacement));
  const statePath = path.join(repo, '.learn-mirror/state.json');
  const state = JSON.parse(fs.readFileSync(statePath, 'utf8'));
  state.pages['https://learn.microsoft.com/en-us/azure/aks/renamed-guide'] = { path: replacement };
  fs.writeFileSync(statePath, JSON.stringify(state));
  commit();
  const result = build({ baseline });
  assert.equal(result.changes.length, 0);
  assert.equal(result.suppressed.length, 2);
}));

test('missing baseline, stale head, shallow history and missing canonical data fail explicitly', () => fixture(({ repo, build, commit }) => {
  assert.throws(() => build({ baseline: 'missing-baseline' }));
  assert.throws(() => build({ now: new Date(now.getTime() + 13 * 3600000) }), /stale/);
  const statePath = path.join(repo, '.learn-mirror/state.json');
  const state = JSON.parse(fs.readFileSync(statePath, 'utf8'));
  delete state.pages['https://learn.microsoft.com/en-us/azure/aks/what-is-aks'];
  fs.writeFileSync(statePath, JSON.stringify(state));
  commit();
  assert.throws(() => build(), /no canonical URL/);
  const shallow = path.join(repo, 'shallow-checkout');
  execFileSync('git', ['clone', '--depth=1', new URL(`file:///${repo.replace(/\\/g, '/').replace(/^\//, '')}`).href, shallow], { stdio: 'pipe' });
  assert.throws(() => buildChanges({ repo: shallow, baseline: 'HEAD', now }), /shallow/);
}));

test('UTC window includes a content edit exactly at midnight, excluding earlier edits', () => fixture(({ repo, build, git, baseline: originalBaseline }) => {
  const since = new Date(now);
  since.setUTCHours(0, 0, 0, 0);
  since.setUTCDate(since.getUTCDate() - 7);
  git('config', 'core.autocrlf', 'false');
  // Re-date the fixture history to exercise the actual seven-day boundary.
  const beforeTree = git('rev-parse', 'HEAD^{tree}');
  const baselineTree = git('rev-parse', `${originalBaseline}^{tree}`);
  const file = path.join(repo, article);
  fs.appendFileSync(file, '\n## Midnight boundary\n\nRequire a new configuration version.\n');
  git('add', '-A');
  const boundaryTree = git('write-tree');
  const old = new Date(since.getTime() - 3600000);
  const envCommit = (date, tree, parent) => execFileSync('git', ['-C', repo, 'commit-tree', tree,
    ...(parent ? ['-p', parent] : []), '-m', 'Window fixture'], {
    encoding: 'utf8', env: { ...process.env, GIT_AUTHOR_DATE: date.toISOString(), GIT_COMMITTER_DATE: date.toISOString() }
  }).trim();
  const baseline = envCommit(old, baselineTree);
  const before = envCommit(new Date(since.getTime() - 1000), beforeTree, baseline);
  const boundary = envCommit(since, boundaryTree, before);
  const recent = envCommit(now, boundaryTree, boundary);
  const result = build({ baseline, head: recent });
  assert.equal(result.base_revision, before);
  assert.equal(result.changes.length, 1);
  assert.equal(result.changes[0].filename, article);
  assert.equal(result.changes[0].sha, boundary);
  assert.equal(new Date(result.changes[0].detected_at).getTime(), since.getTime());
}));

test('renderer escapes content, rejects unsafe URLs, and uses detection dates and docs-only buttons', () => fixture(({ build }) => {
  const input = build({ demo: true });
  const data = {
    docs_source: 'snapshots', preview_only: true, input, ai_summary_count: 0,
    items: input.changes.map(item => ({ ...item, summary: '<script>attack()</script>', summary_method: 'Heuristic', category: 'Security' }))
  };
  for (const mode of ['tracker', 'digest']) {
    const html = render(data, mode);
    assert.equal((html.match(/<article /g) || []).length, 8);
    assert.ok(html.includes('SYNTHETIC TEST DATA'));
    assert.ok(html.includes('Detected:'));
    assert.ok(html.includes('View documentation'));
    assert.equal(html.includes('View change'), false);
    assert.equal(html.includes('View PR'), false);
    assert.equal(html.includes('<script>attack()'), false);
    assert.ok(html.includes('&lt;script&gt;attack()'));
    assert.equal(/@@[A-Z_]+@@/.test(html), false);
  }
  const comparison = compare(data, '<a href="https://learn.microsoft.com/azure/aks/what-is-aks">Live</a>');
  assert.equal(comparison.articles.filter(item => item.also_linked_in_current_production_html).length, 1);
  data.input.demo = false;
  for (const item of data.items) item.evidence_url = `https://github.com/PixelRobots/azure-aks-tracker/commit/${'a'.repeat(40)}`;
  assert.equal(render(data).includes('View change'), false);
  data.items[0].canonical_url = 'javascript:alert(1)';
  assert.throws(() => render(data), /Unsafe/);
}));

test('existing generator produces isolated no-AI summaries and matching HTML without network collection', () => fixture(({ repo, build }) => {
  const input = path.join(repo, 'changes.json');
  const output = path.join(repo, 'output');
  fs.writeFileSync(input, JSON.stringify(build({ demo: true })));
  const command = `$ErrorActionPreference='Stop'; & '${path.join(root, '.github/scripts/generate-aks-updates.ps1').replace(/'/g, "''")}' 1> '${path.join(repo, 'summaries.json').replace(/'/g, "''")}'`;
  const result = spawnSync('pwsh', ['-NoProfile', '-Command', command], {
    encoding: 'utf8', timeout: 120000,
    env: {
      ...process.env, DOCS_SOURCE: 'snapshots', DOCS_PREVIEW_ONLY: 'true',
      SNAPSHOT_CHANGES_PATH: input, DOCS_PREVIEW_OUTPUT_DIR: output,
      GITHUB_TOKEN: 'fixture-not-used', OpenAIKey: '', AZURE_OPENAI_APIURI: '',
      DOCS_PREVIEW_REQUIRE_AI: 'false', CVE_ONLY: '', CVE_REFRESH_VHD: ''
    }
  });
  assert.equal(result.status, 0, result.stdout + result.stderr);
  const data = JSON.parse(fs.readFileSync(path.join(repo, 'summaries.json'), 'utf8').replace(/^\uFEFF/, ''));
  assert.equal(data.items.length, 8);
  assert.equal(data.ai_summary_count, 0);
  assert.equal(new Set(data.items.map(item => item.product)).size, 8);
  assert.ok(fs.existsSync(path.join(output, 'docs-summary-cache.json')));
  assert.equal(data.preview_only, true);
  assert.ok(render(data).includes('8 updates'));
  assert.ok(render(data, 'digest').includes('8 updates'));
  assert.equal(result.stdout.includes('Processing AKS repository'), false);
  assert.equal(result.stdout.includes('Fetching AKS CVE'), false);
}));

test('production health requires a complete fresh pass and matches committed content', () => fixture(({ repo, build, commit }) => {
  assert.throws(() => build({ production: true }), /Command failed/);
  recordHealth(repo, { errors: 0, unreached: 2, now });
  commit('Incomplete collector heartbeat');
  assert.throws(() => build({ production: true }), /incomplete or failed/);
  const health = recordHealth(repo, { errors: 0, unreached: 0, now });
  assert.equal(health.article_count, 8);
  assert.equal(validateHealth(health, now).complete, true);
  commit('Complete collector heartbeat');
  const data = build({ production: true });
  assert.equal(data.production_ready, true);
  assert.equal(data.changes.length, 8);
  assert.throws(() => build({ production: true, now: new Date(now.getTime() + 13 * 3600000) }), /stale/);
  assert.throws(() => build({ production: true, demo: true }), /Synthetic/);
  assert.throws(() => recordHealth(repo, { errors: NaN, unreached: 0 }), /valid errors/);
  assert.throws(() => validateHealth({ ...health, products: ['AKS'] }, now), /incomplete or failed/);
}));

test('production generator preserves layout, releases and CVEs and removes PR buttons in both docs surfaces', () => fixture(({ repo, build, commit }) => {
  const input = path.join(repo, 'changes.json');
  const output = path.join(repo, 'output');
  fs.mkdirSync(output);
  fs.writeFileSync(input, JSON.stringify(build({ demo: true })));
  const command = `
    $ErrorActionPreference='Stop'
    function Invoke-RestMethod {
      param($Uri, $Headers, $Method, $TimeoutSec)
      if ($Uri -match 'api.github.com/repos/Azure/AKS/releases') {
        return @([pscustomobject]@{ id=123; name='AKS fixture release'; tag_name='test'; published_at='2026-01-01T00:00:00Z'; body='Fixture release notes'; html_url='https://github.com/Azure/AKS/releases/tag/test'; prerelease=$false })
      }
      if ($Uri -match 'cve-api.prod-aks.azure.com/api/v1/aks-releases/_index') { return [pscustomobject]@{ aks_release_versions=@('fixture-version') } }
      if ($Uri -match '/scan-reports$') { return [pscustomobject]@{ container_targets=@(); report_time='2026-01-01T00:00:00Z' } }
      throw "Unexpected network request: $Uri"
    }
    Set-Location -LiteralPath '${repo.replace(/'/g, "''")}'
    & '${path.join(root, '.github/scripts/generate-aks-updates.ps1').replace(/'/g, "''")}' 1> '${path.join(output, 'production.json').replace(/'/g, "''")}'
  `;
  const result = spawnSync('pwsh', ['-NoProfile', '-Command', command], {
    encoding: 'utf8', timeout: 120000,
    env: {
      ...process.env, DOCS_SOURCE: 'snapshots', DOCS_PREVIEW_ONLY: 'true', DOCS_PREVIEW_RENDER_PRODUCTION: 'true',
      SNAPSHOT_CHANGES_PATH: input, DOCS_PREVIEW_OUTPUT_DIR: output,
      GITHUB_TOKEN: 'fixture-not-used', OpenAIKey: '', AZURE_OPENAI_APIURI: '',
      DOCS_PREVIEW_REQUIRE_AI: 'false', CVE_ONLY: '', CVE_REFRESH_VHD: ''
    }
  });
  assert.equal(result.status, 0, result.stdout + result.stderr);
  const data = JSON.parse(fs.readFileSync(path.join(output, 'production.json'), 'utf8').replace(/^\uFEFF/, ''));
  assert.equal(data.digest_docs_count, 8);
  for (const name of ['html', 'digest_docs_html', 'digest_docs_title', 'cve_section_html', 'digest_releases_html', 'hash']) {
    assert.equal(typeof data[name], 'string', name);
    assert.ok(data[name].length > 0, name);
  }
  assert.equal((data.html.match(/class="aks-doc-update"/g) || []).length, 8);
  assert.equal((data.html.match(/>View Documentation<\/a>/g) || []).length, 8);
  assert.equal((data.digest_docs_html.match(/View Documentation<\/a>/g) || []).length, 8);
  assert.equal(/View PR|View change|aks-doc-link-pr/.test(data.html + data.digest_docs_html), false);
  assert.equal((data.html.match(/Detected:/g) || []).length, 8);
  assert.equal((data.digest_docs_html.match(/Detected:/g) || []).length, 8);
  assert.ok(data.html.includes('class="aks-tabs"'));
  assert.ok(data.html.includes('id="aks-tab-releases"'));
  assert.ok(data.html.includes('id="aks-tab-cve"'));
  assert.ok(data.html.includes('AKS fixture release'));
  assert.ok(data.cve_section_html.includes('fixture-version'));
  assert.ok(data.html.includes('https://learn.microsoft.com/en-us/azure/application-network/overview'));
  assert.equal(result.stdout.includes('Processing AKS repository'), false);

  const productionEnv = {
    ...process.env, DOCS_SOURCE: 'snapshots', DOCS_PREVIEW_ONLY: '',
    SNAPSHOT_CHANGES_PATH: input, DOCS_PREVIEW_OUTPUT_DIR: '',
    GITHUB_TOKEN: 'fixture-not-used', OpenAIKey: '', AZURE_OPENAI_APIURI: '',
    DOCS_PREVIEW_REQUIRE_AI: 'false', CVE_ONLY: '', CVE_REFRESH_VHD: ''
  };
  const rejected = spawnSync('pwsh', ['-NoProfile', '-Command', command], {
    encoding: 'utf8', timeout: 120000, env: productionEnv
  });
  assert.notEqual(rejected.status, 0);
  assert.ok((rejected.stdout + rejected.stderr).includes('non-synthetic'));

  recordHealth(repo, { errors: 0, unreached: 0, now });
  commit('Complete collection heartbeat');
  fs.writeFileSync(input, JSON.stringify(build({ production: true })));
  const actual = spawnSync('pwsh', ['-NoProfile', '-Command', command], {
    encoding: 'utf8', timeout: 120000, env: productionEnv
  });
  assert.equal(actual.status, 0, actual.stdout + actual.stderr);
  const production = JSON.parse(fs.readFileSync(path.join(output, 'production.json'), 'utf8').replace(/^\uFEFF/, ''));
  assert.equal(production.digest_docs_count, 8);
  assert.equal(/View PR|View change/.test(production.html + production.digest_docs_html), false);
  assert.ok(fs.existsSync(path.join(repo, 'snapshot-docs-summary-cache.json')));

  const cveOnly = spawnSync('pwsh', ['-NoProfile', '-Command', command], {
    encoding: 'utf8', timeout: 120000, env: { ...productionEnv, CVE_ONLY: 'true', SNAPSHOT_CHANGES_PATH: '' }
  });
  assert.equal(cveOnly.status, 0, cveOnly.stdout + cveOnly.stderr);
  const cve = JSON.parse(fs.readFileSync(path.join(output, 'production.json'), 'utf8').replace(/^\uFEFF/, ''));
  assert.equal(cve.cve_only, true);
  assert.ok(cve.cve_section_html.includes('fixture-version'));
}));
