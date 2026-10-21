'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { execFileSync } = require('node:child_process');
const { test } = require('node:test');
const { sources, pageUrl } = require('../seed-learn-mirror.cjs');

const root = path.resolve(__dirname, '../../..');
const config = JSON.parse(fs.readFileSync(path.join(root, 'learn-mirror.config.json'), 'utf8'));
const include = new RegExp(config.include);
const tracked = new RegExp(config.trackedPaths);
const cases = [
  ['articles/aks/what-is-aks.md', 'azure/aks/what-is-aks'],
  ['articles/aks-hybrid-edge/overview.md', 'azure/aks-hybrid-edge/overview'],
  ['articles/kubernetes-fleet/overview.md', 'azure/kubernetes-fleet/overview'],
  ['articles/application-network/overview.md', 'azure/application-network/overview'],
  ['articles/container-registry/container-registry-intro.md', 'azure/container-registry/container-registry-intro'],
  ['articles/azure-arc/kubernetes/overview.md', 'azure/azure-arc/kubernetes/overview'],
  ['articles/application-gateway/for-containers/overview.md', 'azure/application-gateway/for-containers/overview'],
  ['support/azure/azure-kubernetes/storage/test.md', 'troubleshoot/azure/azure-kubernetes/storage/test']
];

test('every tracked product has a source-to-published-URL mapping', () => {
  for (const [file, slug] of cases) {
    const source = sources.find(item => item.routes.some(([prefix]) => file.startsWith(prefix)));
    assert.ok(source, file);
    const url = pageUrl(file, source.routes);
    assert.equal(url, `https://learn.microsoft.com/en-us/${slug}`);
    assert.ok(include.test(url), url);
    assert.ok(tracked.test(file), file);
    assert.ok(config.sourceRepos.includes(source.repo));
    assert.ok(config.sourceRepos.includes(`${source.repo}-pr`));
  }
});

test('support scopes match all nine existing tracker categories', () => {
  const source = sources.find(item => item.repo.endsWith('/SupportArticles-docs'));
  assert.equal(source.routes.length, 9);
  for (const [prefix] of source.routes) {
    assert.ok(tracked.test(`${prefix}example.md`));
    assert.ok(include.test(pageUrl(`${prefix}example.md`, source.routes)));
  }
  assert.equal(tracked.test('support/azure/azure-kubernetes/other/example.md'), false);
  assert.equal(include.test('https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/other/example'), false);
});

test('discovery excludes unrelated products, hosts and locales', () => {
  for (const url of [
    'https://learn.microsoft.com/en-us/azure/aks-malicious/test',
    'https://learn.microsoft.com/en-us/azure/virtual-machines/overview',
    'https://learn.microsoft.com/fr-fr/azure/aks/what-is-aks',
    'https://example.com/en-us/azure/aks/what-is-aks'
  ]) assert.equal(include.test(url), false, url);
  assert.equal(tracked.test('articles/virtual-machines/overview.md'), false);
  assert.equal(tracked.test('articles/aks/toc.yml'), false);
});

test('seed mapping excludes includes and media, and maps index pages', () => {
  const routes = sources[0].routes;
  for (const file of ['articles/aks/includes/example.md', 'articles/aks/media/image.md', 'articles/aks/toc.md']) {
    assert.equal(pageUrl(file, routes), null, file);
  }
  assert.equal(pageUrl('articles/aks/index.md', routes), 'https://learn.microsoft.com/en-us/azure/aks/');
  assert.ok(config.tocs.includes('https://learn.microsoft.com/en-us/azure/application-network/toc.json'));
  assert.equal(pageUrl('articles/application-network/overview.md', routes),
    'https://learn.microsoft.com/en-us/azure/application-network/overview');
});

test('sitemap scope includes only current English Azure and troubleshooting shards', () => {
  const pattern = new RegExp(config.sitemaps);
  for (const name of ['azure_en-us_1.xml', 'azure_en-us_7.xml', 'troubleshoot_en-us_1.xml']) {
    assert.ok(pattern.test(`https://learn.microsoft.com/_sitemaps/${name}`));
  }
  for (const name of ['azure_fr-fr_1.xml', 'previous-versions_en-us_1.xml', 'entra_en-us_1.xml']) {
    assert.equal(pattern.test(`https://learn.microsoft.com/_sitemaps/${name}`), false);
  }
});

test('committed seeds are sorted, unique and cover every configured route', () => {
  const seeds = fs.readFileSync(path.join(root, 'learn-mirror-seed-urls.txt'), 'utf8').trim().split(/\r?\n/);
  assert.deepEqual(seeds, [...new Set(seeds)].sort());
  for (const url of seeds) assert.ok(include.test(url), url);
  for (const source of sources) {
    for (const [, slug] of source.routes) {
      assert.ok(seeds.some(url => url.startsWith(`https://learn.microsoft.com/en-us/${slug}`)), slug);
    }
  }
});

test('pinned upstream tool accepts config and preserves content while stripping publish noise', {
  skip: !process.env.LEARN_MIRROR_TOOL
}, () => {
  const tool = require(path.resolve(process.env.LEARN_MIRROR_TOOL));
  const loaded = tool.loadMirrorConfig(path.join(root, 'learn-mirror.config.json'));
  const toc = { items: [{ href: 'what-is-aks', children: [{ href: '/en-us/azure/kubernetes-fleet/overview' }] }] };
  const urls = tool.selectPageUrls(tool.parseTocHrefs(toc, config.tocs[0]), loaded);
  assert.equal(urls.length, 2);
  const original = '---\ntitle: AKS\nsource_path: articles/aks/what-is-aks.md\nupdated_at: yesterday\ngit_commit_id: abc\ngitcommit: example\nword_count: 10\n---\n# AKS\nBody\n';
  const cleaned = tool.stripFrontMatterKeys(original, loaded.stripFrontMatter);
  assert.ok(cleaned.includes('source_path: articles/aks/what-is-aks.md'));
  assert.ok(cleaned.endsWith('# AKS\nBody\n'));
  assert.equal(/updated_at|git_commit_id|gitcommit|word_count/.test(cleaned), false);
  assert.equal(tool.mirrorPathFor('articles/aks/what-is-aks.md'), 'articles/aks/what-is-aks.md');
});

test('snapshot storage starts empty on an orphan branch and can be reopened', () => {
  const temporary = fs.mkdtempSync(path.join(os.tmpdir(), 'aks-mirror-worktree-'));
  const repo = path.join(temporary, 'tracker');
  const snapshots = path.join(temporary, 'snapshots');
  fs.mkdirSync(repo);
  const git = (...args) => execFileSync('git', args, {
    cwd: repo, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe']
  }).trim();
  try {
    git('init');
    git('config', 'user.name', 'Snapshot test');
    git('config', 'user.email', 'test@example.invalid');
    fs.writeFileSync(path.join(repo, 'source-only.txt'), 'source');
    git('add', 'source-only.txt');
    git('commit', '-m', 'Source fixture');
    git('worktree', 'add', '--orphan', '-b', 'docs-snapshots', snapshots);
    assert.equal(fs.existsSync(path.join(snapshots, 'source-only.txt')), false);
    fs.writeFileSync(path.join(snapshots, 'snapshot.txt'), 'baseline');
    git('-C', snapshots, 'add', '-A');
    git('-C', snapshots, 'commit', '-m', 'Baseline fixture');
    assert.equal(git('-C', snapshots, 'rev-list', '--count', 'HEAD'), '1');
    const revision = git('-C', snapshots, 'rev-parse', 'HEAD');
    git('worktree', 'remove', snapshots);
    git('branch', '-D', 'docs-snapshots');
    git('worktree', 'add', '-b', 'docs-snapshots', snapshots, revision);
    assert.equal(fs.readFileSync(path.join(snapshots, 'snapshot.txt'), 'utf8'), 'baseline');
    assert.equal(fs.existsSync(path.join(repo, 'source-only.txt')), true);
  } finally {
    fs.rmSync(temporary, { recursive: true, force: true });
  }
});
