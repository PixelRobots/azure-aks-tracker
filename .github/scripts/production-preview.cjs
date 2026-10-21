#!/usr/bin/env node
'use strict';

const fs = require('node:fs');
const path = require('node:path');
const { escape } = require('./render-snapshot-preview.cjs');

function productionPreview(result, publicPage, demo) {
  if (typeof result.html !== 'string' || typeof result.digest_docs_html !== 'string') {
    throw new Error('Missing production generator HTML fields.');
  }
  if (/View PR|View change/.test(result.html + result.digest_docs_html)) {
    throw new Error('Snapshot publication must show documentation buttons only.');
  }
  const styles = [...publicPage.matchAll(/<style\b[^>]*>([\s\S]*?)<\/style>/gi)]
    .filter(match => match[1].includes('.aks-')).map(match => match[0]).join('\n');
  if (!styles.includes('.aks-updates') || !styles.includes('.aks-tabs')) {
    throw new Error('Could not retrieve live tracker styling; do not present an unstyled page as a production preview.');
  }
  const template = fs.readFileSync(path.join(__dirname, 'snapshot-preview.html'), 'utf8');
  const theme = template.slice(template.indexOf('<script>'), template.indexOf('</style>') + '</style>'.length);
  const banner = demo ? 'SYNTHETIC TEST DATA - not real documentation changes' : 'REAL SNAPSHOT PREVIEW - not published to WordPress';
  const content = result.html.replace('[email-subscribers-form id="2"]', '<p>Signup disabled in the isolated preview.</p>');
  return `<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="robots" content="noindex,nofollow"><title>Production-layout snapshot preview</title>
${theme}${styles}</head><body>
<div class="notice"><strong>${escape(banner)}</strong><br>Existing production markup and live-site tracker CSS. Signup and publishing are disabled; WordPress plugin injection is not run here.</div>
${content}
<script>
document.querySelectorAll('.aks-tab-link').forEach(link => link.addEventListener('click', event => {
  event.preventDefault();
  document.querySelectorAll('.aks-tab-link,.aks-tab-panel').forEach(element => element.classList.remove('active'));
  link.classList.add('active');
  document.querySelector(link.getAttribute('href')).classList.add('active');
}));
</script></body></html>`;
}

async function main() {
  const [outputDirectory] = process.argv.slice(2);
  const result = JSON.parse(fs.readFileSync(path.join(outputDirectory, 'production.json'), 'utf8').replace(/^\uFEFF/, ''));
  const summaries = JSON.parse(fs.readFileSync(path.join(outputDirectory, 'summaries.json'), 'utf8').replace(/^\uFEFF/, ''));
  const response = await fetch('https://pixelrobots.co.uk/aks-docs-tracker/', { signal: AbortSignal.timeout(60000) });
  if (!response.ok) throw new Error(`Cannot retrieve live-site tracker CSS: HTTP ${response.status}`);
  const page = productionPreview(result, await response.text(), summaries.input.demo);
  fs.writeFileSync(path.join(outputDirectory, 'production-tracker.html'), page);
  fs.writeFileSync(path.join(outputDirectory, 'wordpress-fragment.html'), result.html);
  fs.writeFileSync(path.join(outputDirectory, 'production-digest.html'),
    `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Production digest preview</title></head><body><p>${summaries.input.demo ? 'SYNTHETIC TEST DATA' : 'LIVE SNAPSHOT PREVIEW'} - not sent to WordPress or email.</p>${result.digest_docs_html}</body></html>`);
  if (result.digest_docs_count !== summaries.items.length) throw new Error('Production digest count does not match summary output.');
  console.log(`Production layout and digest rendered: ${result.digest_docs_count} docs cards, documentation buttons only.`);
}

module.exports = { productionPreview };
if (require.main === module) main().catch(error => { console.error(error.message); process.exitCode = 1; });
