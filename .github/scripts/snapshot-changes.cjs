#!/usr/bin/env node
'use strict';

const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { execFileSync, spawnSync } = require('node:child_process');
const { sources, pageUrl } = require('./seed-learn-mirror.cjs');

const products = ['AKS', 'AKS Arc', 'Fleet', 'Application Network', 'ACR', 'Arc K8s', 'Azure Linux', 'AGC', 'AKS Support', 'AKS Automatic'];
const routes = sources.flatMap(source => source.routes.map(route => ({ source, route })));
const config = JSON.parse(fs.readFileSync(path.resolve(__dirname, '../../learn-mirror.config.json'), 'utf8'));
const scope = new RegExp(config.trackedPaths);

function git(repo, ...args) {
  return execFileSync('git', ['-C', repo, ...args], {
    encoding: 'utf8', maxBuffer: 64 * 1024 * 1024, stdio: ['ignore', 'pipe', 'pipe']
  });
}

function body(text) {
  return text.replace(/^\uFEFF/, '').replace(/^---\r?\n[\s\S]*?\r?\n---(?:\r?\n|$)/, '')
    .replace(/\r\n/g, '\n').split('\n').map(line => line.trimEnd()).join('\n').trim() + '\n';
}

function title(text, file) {
  return /^#\s+(.+)$/m.exec(body(text))?.[1]?.trim() || path.posix.basename(file, '.md');
}

function routeFor(file) {
  const index = routes.findIndex(item => file.startsWith(item.route[0]));
  if (index < 0 || !scope.test(file)) throw new Error(`Untracked article path: ${file}`);
  if (/^articles\/aks\/(automatic\/|intro-aks-automatic\.md$)/.test(file)) {
    return { ...routes[index], product: 'AKS Automatic' };
  }
  return { ...routes[index], product: file.startsWith('support/') ? 'AKS Support' : products[index] };
}

function diffBodies(before, after) {
  const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'aks-content-diff-'));
  try {
    const oldFile = path.join(temp, 'before.md');
    const newFile = path.join(temp, 'after.md');
    fs.writeFileSync(oldFile, before);
    fs.writeFileSync(newFile, after);
    const result = spawnSync('git', ['diff', '--no-index', '--no-ext-diff', '--no-color',
      '--unified=3', '--', oldFile, newFile], { encoding: 'utf8', maxBuffer: 32 * 1024 * 1024 });
    if (result.error) throw result.error;
    if (![0, 1].includes(result.status)) throw new Error(`Content diff failed: ${result.stderr}`);
    return result.stdout.replace(/^diff --git.*\n|^index.*\n/gm, '')
      .replace(/^---.*$/m, '--- before.md').replace(/^\+\+\+.*$/m, '+++ after.md');
  } finally {
    fs.rmSync(temp, { recursive: true, force: true });
  }
}

function readArticle(repo, revision, file) {
  const exists = spawnSync('git', ['-C', repo, 'cat-file', '-e', `${revision}:${file}`], { encoding: 'utf8' });
  if (exists.error) throw exists.error;
  if (exists.status === 0) return git(repo, 'show', `${revision}:${file}`);
  if (exists.status !== 128) throw new Error(`Cannot inspect ${revision}:${file}: ${exists.stderr}`);
  return null;
}

function buildChanges({ repo, baseline, head = 'HEAD', now = new Date(), demo = false, maxAgeHours = 12, production = false, productBaselines = {} }) {
  if (git(repo, 'rev-parse', '--is-shallow-repository').trim() !== 'false') {
    throw new Error('Snapshot history is shallow; fetch the complete docs-snapshots branch.');
  }
  const resolve = ref => git(repo, 'rev-parse', '--verify', `${ref}^{commit}`).trim();
  const baselineRevision = resolve(baseline);
  const headRevision = resolve(head);
  const ancestor = spawnSync('git', ['-C', repo, 'merge-base', '--is-ancestor', baselineRevision, headRevision]);
  if (ancestor.status !== 0) throw new Error('Qualified baseline is not an ancestor of the snapshot head.');
  const headTime = git(repo, 'show', '-s', '--format=%cI', headRevision).trim();
  let health = null;
  if (production) {
    if (demo) throw new Error('Synthetic changes cannot be published.');
    // Require a committed heartbeat from a zero-error, complete pass, not just a recent article commit.
    const { validateHealth } = require('./snapshot-health.cjs');
    health = validateHealth(JSON.parse(git(repo, 'show', `${headRevision}:.learn-mirror/health.json`)), now, maxAgeHours);
  }
  const age = (now - new Date(headTime)) / 3600000;
  if (!production && (!Number.isFinite(age) || age < -1 || age > maxAgeHours)) {
    throw new Error(`Snapshot head is stale or future-dated (${headTime}); inspect the collector before previewing.`);
  }
  const since = new Date(now);
  since.setUTCHours(0, 0, 0, 0);
  since.setUTCDate(since.getUTCDate() - 7);
  const beforeWindow = new Date(since.getTime() - 1000).toISOString();
  let base = git(repo, 'rev-list', '--first-parent', '-1', `--before=${beforeWindow}`, headRevision).trim();
  if (!base || spawnSync('git', ['-C', repo, 'merge-base', '--is-ancestor', baselineRevision, base]).status !== 0) {
    base = baselineRevision;
  }
  const resolvedProductBaselines = {};
  for (const [prefix, revision] of Object.entries(productBaselines)) {
    if (!routes.some(item => item.route[0] === prefix)) throw new Error(`Unknown product baseline scope: ${prefix}`);
    const resolved = resolve(revision);
    if (spawnSync('git', ['-C', repo, 'merge-base', '--is-ancestor', baselineRevision, resolved]).status !== 0 ||
        spawnSync('git', ['-C', repo, 'merge-base', '--is-ancestor', resolved, headRevision]).status !== 0) {
      throw new Error(`Product baseline is outside the qualified snapshot history: ${prefix}`);
    }
    if (!git(repo, 'ls-tree', '-r', '--name-only', resolved, '--', prefix).trim()) {
      throw new Error(`Product baseline contains no articles: ${prefix}`);
    }
    resolvedProductBaselines[prefix] = resolved;
  }
  const baseFor = file => {
    const entry = Object.entries(resolvedProductBaselines).find(([prefix]) => file.startsWith(prefix));
    return entry && spawnSync('git', ['-C', repo, 'merge-base', '--is-ancestor', base, entry[1]]).status === 0
      ? entry[1] : base;
  };
  const state = JSON.parse(git(repo, 'show', `${headRevision}:.learn-mirror/state.json`));
  if (!state.pages || typeof state.pages !== 'object' || Array.isArray(state.pages)) {
    throw new Error('Snapshot state has no valid pages map.');
  }
  const byPath = new Map();
  for (const [url, entry] of Object.entries(state.pages)) {
    if (!entry || typeof entry !== 'object') throw new Error(`Malformed snapshot state for ${url}`);
    if (!entry.path || entry.aliasOf || entry.redirectedTo) continue;
    if (!new RegExp(config.include).test(url)) throw new Error(`Unexpected canonical URL in snapshot state: ${url}`);
    byPath.set(entry.path, url);
  }
  if (production) {
    const paths = new Set(Object.values(state.pages).map(entry => entry.path).filter(Boolean));
    const productScopes = new Set([...paths].map(file => routeFor(file).product));
    if (paths.size !== health.article_count || productScopes.size !== products.length) throw new Error('Collector health does not match snapshot state.');
    const committedFiles = new Set(git(repo, 'ls-tree', '-r', '--name-only', '-z', headRevision).split('\0'));
    for (const file of paths) if (!committedFiles.has(file)) throw new Error(`Snapshot file missing from committed history: ${file}`);
  }
  const files = git(repo, 'diff', '--name-only', '-z', '--no-renames', base, headRevision, '--', 'articles', 'support')
    .split('\0').filter(file => scope.test(file));
  const changes = [];
  const suppressed = [];
  const deletedBodies = new Map(files.map(file => [file, readArticle(repo, headRevision, file)])
    .filter(([, text]) => text === null)
    .map(([file]) => [body(git(repo, 'show', `${baseFor(file)}:${file}`)), file]));
  for (const file of files) {
    const fileBase = baseFor(file);
    const before = readArticle(repo, fileBase, file);
    const after = readArticle(repo, headRevision, file);
    if (after === null) {
      suppressed.push({ filename: file, reason: 'Deletion requires confirmation; not announced as a withdrawal.' });
      continue;
    }
    const oldBody = before === null ? '' : body(before);
    const newBody = body(after);
    if (oldBody === newBody) continue;
    if (before === null && deletedBodies.has(newBody)) {
      suppressed.push({ filename: file, reason: `Content-preserving move from ${deletedBodies.get(newBody)}; not a newly published article.` });
      continue;
    }
    const route = routeFor(file);
    const canonical = byPath.get(file);
    if (!canonical) throw new Error(`Changed article has no canonical URL in snapshot state: ${file}`);
    const patch = diffBodies(oldBody, newBody);
    const revisions = git(repo, 'log', '--format=%H', `${fileBase}..${headRevision}`, '--', file).trim().split('\n').filter(Boolean);
    let detectedRevision;
    for (const revision of revisions) {
      const parent = git(repo, 'rev-parse', `${revision}^`).trim();
      const previous = readArticle(repo, parent, file);
      const current = readArticle(repo, revision, file);
      if ((previous === null ? '' : body(previous)) !== (current === null ? '' : body(current))) {
        detectedRevision = revision;
        break;
      }
    }
    if (!detectedRevision) throw new Error(`Cannot resolve content-change evidence for ${file}`);
    changes.push({
      filename: file,
      repo_name: route.source.repo.split('/')[1],
      product: route.product,
      status: before === null ? 'added' : 'modified',
      additions: patch.split('\n').slice(2).filter(line => line.startsWith('+')).length,
      deletions: patch.split('\n').slice(2).filter(line => line.startsWith('-')).length,
      patch, title: title(after, file), canonical_url: canonical,
      detected_at: git(repo, 'show', '-s', '--format=%cI', detectedRevision).trim(),
      evidence_url: demo ? null : `https://github.com/PixelRobots/azure-aks-tracker/commit/${detectedRevision}`,
      sha: detectedRevision
    });
  }
  changes.sort((a, b) => b.detected_at.localeCompare(a.detected_at) || a.filename.localeCompare(b.filename));
  return {
    schema_version: 1, source: 'learn-snapshot', demo, production_ready: production,
    collection_health: health,
    baseline_revision: baselineRevision, base_revision: base, head_revision: headRevision,
    product_baselines: resolvedProductBaselines,
    since: since.toISOString(), generated_at: now.toISOString(), snapshot_at: headTime,
    baseline_only: headRevision === baselineRevision,
    warnings: [
      ...(production ? [] : ['Preview only: collection freshness does not prove a complete crawl. Confirm the collector Actions summary before cutover.']),
      ...(demo ? ['SYNTHETIC TEST DATA: not real Microsoft documentation changes.'] : [])
    ],
    suppressed, changes
  };
}

function createDemo(repo, now = new Date()) {
  fs.mkdirSync(repo, { recursive: true });
  git(repo, 'init');
  git(repo, 'config', 'user.name', 'Snapshot preview fixture');
  git(repo, 'config', 'user.email', 'preview@example.invalid');
  git(repo, 'config', 'core.autocrlf', 'false');
  const pages = {};
  const files = [
    'articles/aks/what-is-aks.md', 'articles/aks-hybrid-edge/overview.md',
    'articles/kubernetes-fleet/overview.md', 'articles/application-network/overview.md',
    'articles/container-registry/container-registry-intro.md', 'articles/azure-arc/kubernetes/overview.md',
    'articles/azure-linux/azure-linux-overview.md', 'articles/application-gateway/for-containers/overview.md',
    'support/azure/azure-kubernetes/storage/troubleshoot-pvc.md',
    'articles/aks/automatic/quick-automatic-managed-network.md'
  ];
  for (const file of files) {
    const route = routeFor(file);
    pages[pageUrl(file, route.source.routes)] = { path: file, etag: 'fixture' };
    const target = path.join(repo, file);
    fs.mkdirSync(path.dirname(target), { recursive: true });
    fs.writeFileSync(target, `---\ntitle: ${route.product} sample\n---\n# ${route.product} sample\n\n## Configuration\n\nSynthetic preview fixture. This is not product guidance.\n\nExample configuration version: 1.\n`);
  }
  fs.mkdirSync(path.join(repo, '.learn-mirror'));
  fs.writeFileSync(path.join(repo, '.learn-mirror/state.json'), JSON.stringify({ pages }));
  const commit = message => {
    git(repo, 'add', '-A');
    const result = spawnSync('git', ['-C', repo, 'commit', '-m', message], {
      encoding: 'utf8',
      env: { ...process.env, GIT_AUTHOR_DATE: now.toISOString(), GIT_COMMITTER_DATE: now.toISOString() }
    });
    if (result.status !== 0) throw new Error(result.stderr);
    return git(repo, 'rev-parse', 'HEAD').trim();
  };
  const baseline = commit('Synthetic baseline - not published documentation');
  for (const file of files) {
    const target = path.join(repo, file);
    fs.writeFileSync(target, fs.readFileSync(target, 'utf8').replace('version: 1.',
      'version: 2.\n\n## Security and operations\n\nSynthetic test only: require managed identity for this example. Use `az aks update --enable-managed-identity` in the example procedure. Validate the configuration before deployment.'));
  }
  commit('Synthetic configuration and security changes - not real documentation updates');
  return baseline;
}

function main() {
  const args = Object.fromEntries(process.argv.slice(2).map(arg => {
    const index = arg.indexOf('=');
    if (!arg.startsWith('--') || index < 0) throw new Error(`Expected --name=value, received ${arg}`);
    return [arg.slice(2, index), arg.slice(index + 1)];
  }));
  const temporary = args.demo === 'true' ? fs.mkdtempSync(path.join(os.tmpdir(), 'aks-preview-demo-')) : null;
  try {
    const repo = temporary || args.repo;
    if (!repo || (!temporary && !args.baseline) || !args.output) throw new Error('Required: --repo, --baseline and --output (or --demo=true --output).');
    const baseline = temporary ? createDemo(repo) : args.baseline;
    const productBaselines = temporary ? {} : JSON.parse(fs.readFileSync(
      path.resolve(__dirname, '../../snapshot-preview.config.json'), 'utf8')).product_baselines || {};
    const result = buildChanges({ repo, baseline, head: args.head || 'HEAD', demo: Boolean(temporary), production: args.production === 'true', productBaselines });
    fs.mkdirSync(path.dirname(path.resolve(args.output)), { recursive: true });
    fs.writeFileSync(args.output, JSON.stringify(result, null, 2) + '\n');
    console.log(`${result.demo ? 'SYNTHETIC' : 'Live'} preview: ${result.changes.length} content changes; ${result.suppressed.length} deletions held for review.`);
  } finally {
    if (temporary) fs.rmSync(temporary, { recursive: true, force: true });
  }
}

module.exports = { products, body, diffBodies, routeFor, buildChanges, createDemo };
if (require.main === module) {
  try { main(); } catch (error) { console.error(error.message); process.exitCode = 1; }
}
