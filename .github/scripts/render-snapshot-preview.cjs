#!/usr/bin/env node
'use strict';

const fs = require('node:fs');
const path = require('node:path');

function escape(value) {
  return String(value ?? '').replace(/[&<>"']/g, char => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
  })[char]);
}

function safeUrl(value, evidence = false) {
  const url = new URL(value);
  const valid = evidence
    ? /^https:\/\/github\.com\/PixelRobots\/azure-aks-tracker\/commit\/[a-f0-9]{40}$/.test(url.href)
    : url.protocol === 'https:' && url.hostname === 'learn.microsoft.com' && !url.username && !url.password;
  if (!valid) throw new Error(`Unsafe ${evidence ? 'evidence' : 'documentation'} URL: ${value}`);
  return escape(url.href);
}

function render(data, mode = 'tracker') {
  if (data.docs_source !== 'snapshots' || data.preview_only !== true || !Array.isArray(data.items)) {
    throw new Error('Expected isolated snapshot preview JSON.');
  }
  const input = data.input;
  const items = [...data.items].sort((a, b) => b.detected_at.localeCompare(a.detected_at) || a.filename.localeCompare(b.filename));
  const cards = items.map((item, index) => {
    const detected = new Date(item.detected_at);
    if (!Number.isFinite(detected.getTime())) throw new Error(`Invalid detection date: ${item.filename}`);
    const evidence = input.demo
      ? `<a href="#diff-${index}">View sample diff</a>`
      : `<a href="${safeUrl(item.evidence_url, true)}" target="_blank" rel="noopener noreferrer">View change</a>`;
    return `<article data-product="${escape(item.product)}">
<div class="badges"><span class="badge">${escape(item.product)}</span><span class="badge">${escape(item.category)}</span><span class="badge">${item.status === 'added' ? 'New page' : 'Updated'}</span><span class="badge">${escape(item.summary_method)}</span></div>
<h2><a href="${safeUrl(item.canonical_url)}" target="_blank" rel="noopener noreferrer">${escape(item.title)}</a></h2>
<p class="muted">Detected: <time datetime="${escape(detected.toISOString())}">${escape(detected.toISOString().replace('T', ' ').replace('.000Z', ' UTC'))}</time></p>
<p>${escape(item.summary)}</p>
<div class="links"><a href="${safeUrl(item.canonical_url)}" target="_blank" rel="noopener noreferrer">View documentation</a>${evidence}</div>
<details id="diff-${index}"${input.demo ? ' open' : ''}><summary>${input.demo ? 'Synthetic test diff (not real product guidance)' : 'Captured article diff'}</summary><pre>${escape(item.patch)}</pre></details>
</article>`;
  }).join('\n');
  const values = {
    TITLE: mode === 'digest' ? 'Weekly documentation digest preview' : 'Snapshot documentation tracker',
    MODE: mode,
    BANNER: input.demo ? 'SYNTHETIC TEST DATA - not real Microsoft documentation changes' : 'LIVE SNAPSHOT DATA - shadow preview',
    SINCE: input.since, SNAPSHOT: input.snapshot_at,
    INPUT_COUNT: input.changes.length, COUNT: items.length, AI_COUNT: data.ai_summary_count,
    PROVENANCE: `Baseline ${input.baseline_revision}; window base ${input.base_revision}; head ${input.head_revision}. ${input.baseline_only ? 'Baseline-only history: no new updates are inferred from the first scan.' : ''}`,
    WARNINGS: `<ul>${[...input.warnings, ...input.suppressed.map(item => `${item.filename}: ${item.reason}`)].map(message => `<li>${escape(message)}</li>`).join('')}</ul>`,
    PRODUCTS: [...new Set(items.map(item => item.product))].sort().map(product => `<option value="${escape(product)}">${escape(product)}</option>`).join(''),
    CARDS: cards || '<p>No eligible changes since the qualified baseline within this window. This is not a replay of the initial snapshot.</p>'
  };
  return fs.readFileSync(path.join(__dirname, 'snapshot-preview.html'), 'utf8')
    .replace(/@@([A-Z_]+)@@/g, (_, key) => ['WARNINGS', 'PRODUCTS', 'CARDS'].includes(key) ? values[key] : escape(values[key]));
}

function compare(data, liveHtml) {
  const liveUrls = new Set([...liveHtml.matchAll(/href="(https:\/\/learn\.microsoft\.com\/[^"]+)"/g)].map(match => match[1].replace(/\/en-(us|gb)\//, '/')));
  const normalized = url => url.replace(/\/en-(us|gb)\//, '/');
  return {
    preview_only: true, demo: data.input.demo,
    interpretation: 'Published snapshots and PR history observe different stages. Differences require review, not automatic parity or publication.',
    snapshot_head: data.input.head_revision,
    snapshot_input_count: data.input.changes.length,
    snapshot_included_count: data.items.length,
    production_learn_link_count: liveUrls.size,
    articles: data.items.map(item => ({
      filename: item.filename, canonical_url: item.canonical_url, summary_method: item.summary_method,
      also_linked_in_current_production_html: liveUrls.has(normalized(item.canonical_url))
    }))
  };
}

function main() {
  const [inputFile, outputDirectory, productionFile] = process.argv.slice(2);
  if (!inputFile || !outputDirectory || !productionFile) throw new Error('Usage: render-snapshot-preview.cjs summaries.json output-directory production.html');
  const data = JSON.parse(fs.readFileSync(inputFile, 'utf8').replace(/^\uFEFF/, ''));
  fs.mkdirSync(outputDirectory, { recursive: true });
  fs.writeFileSync(path.join(outputDirectory, 'tracker.html'), render(data));
  fs.writeFileSync(path.join(outputDirectory, 'digest.html'), render(data, 'digest'));
  fs.writeFileSync(path.join(outputDirectory, 'comparison.json'),
    JSON.stringify(compare(data, fs.readFileSync(productionFile, 'utf8')), null, 2) + '\n');
  console.log(`Rendered ${data.items.length} ${data.input.demo ? 'synthetic' : 'live'} preview cards and matching digest items.`);
}

module.exports = { render, compare, escape, safeUrl };
if (require.main === module) {
  try { main(); } catch (error) { console.error(error.message); process.exitCode = 1; }
}
