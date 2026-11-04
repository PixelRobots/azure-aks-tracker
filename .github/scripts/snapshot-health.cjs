#!/usr/bin/env node
'use strict';

const fs = require('node:fs');
const path = require('node:path');
const { products: expectedProducts, routeFor } = require('./snapshot-changes.cjs');

function validFailures(failures, errors) {
  return Array.isArray(failures) && failures.length === errors &&
    new Set(failures.map(item => item?.url)).size === errors &&
    failures.every(item => typeof item?.url === 'string' &&
      /^https:\/\/learn\.microsoft\.com\/en-us\/\S+$/.test(item.url) &&
      typeof item.error === 'string' && item.error.trim().length > 0);
}

function readCollectionSummary(summary) {
  const lines = summary.split(/\r?\n/);
  const header = '| Pages | Unchanged (304) | Fetched | Gone | Errors | Not reached | Added | Changed | Removed | Throttled | Seconds |';
  const index = lines.indexOf(header);
  const cells = index >= 0 ? lines[index + 2]?.split('|').slice(1, -1).map(cell => cell.trim()) : undefined;
  if (!cells || cells.length !== 11 || !cells.every(cell => /^\d+$/.test(cell))) {
    throw new Error('Missing or malformed pinned Learn mirror collection summary.');
  }
  const counts = cells.map(Number);
  const [attempted, unchanged, fetched, gone, errors, unreached] = counts;
  const failed_pages = [...summary.matchAll(/^- (https:\/\/learn\.microsoft\.com\/\S+): (.+)$/gm)]
    .map(match => ({ url: match[1], error: match[2].trim() }));
  if (!counts.every(Number.isSafeInteger) || attempted < 1 ||
      unchanged + fetched + gone + errors + unreached !== attempted ||
      !validFailures(failed_pages, errors)) {
    throw new Error('Collection summary counts or failed-page details are inconsistent.');
  }
  return { attempted, errors, unreached, failed_pages };
}

function publishableCollection(health) {
  if (health.unreached !== 0 || !Number.isSafeInteger(health.errors) || health.errors < 0) return false;
  if (health.schema_version === 1) return health.complete === true && health.errors === 0;
  return health.schema_version === 2 &&
    Number.isSafeInteger(health.attempted) && health.attempted > 0 &&
    health.errors <= 5 && health.errors * 100 <= health.attempted &&
    health.complete === (health.errors === 0) &&
    validFailures(health.failed_pages, health.errors);
}

function recordHealth(root, { errors, unreached, collection, now = new Date(), runUrl }) {
  for (const [key, value] of Object.entries({ errors, unreached })) {
    if (!Number.isSafeInteger(value) || value < 0) throw new Error(`Collector did not supply a valid ${key} count.`);
  }
  const state = JSON.parse(fs.readFileSync(path.join(root, '.learn-mirror/state.json'), 'utf8'));
  if (!state.pages || typeof state.pages !== 'object') throw new Error('Missing collector pages.');
  const paths = new Set(Object.values(state.pages).map(page => page.path).filter(Boolean));
  const products = new Set();
  for (const file of paths) {
    if (!fs.existsSync(path.join(root, file))) throw new Error(`Snapshot file missing: ${file}`);
    products.add(routeFor(file).product);
  }
  if (products.size !== expectedProducts.length) throw new Error(`Incomplete product coverage: ${[...products].join(', ')}`);
  if (collection && (collection.errors !== errors || collection.unreached !== unreached ||
      !Number.isSafeInteger(collection.attempted) || collection.attempted < errors + unreached ||
      collection.attempted < 1 || !validFailures(collection.failed_pages, errors))) {
    throw new Error('Collection summary does not match collector outputs.');
  }
  const health = {
    schema_version: collection ? 2 : 1,
    checked_at: now.toISOString(),
    complete: errors === 0 && unreached === 0,
    errors, unreached, article_count: paths.size,
    products: [...products].sort(),
    run_url: runUrl
  };
  if (collection) {
    health.attempted = collection.attempted;
    health.failed_pages = collection.failed_pages;
    health.publishable = publishableCollection(health);
  }
  fs.writeFileSync(path.join(root, '.learn-mirror/health.json'), JSON.stringify(health, null, 2) + '\n');
  return health;
}

function validateHealth(health, now, maxAgeHours = 12) {
  if (!health || !publishableCollection(health) ||
      (health.schema_version === 2 && health.publishable !== true) ||
      !Number.isSafeInteger(health.article_count) || health.article_count < expectedProducts.length ||
      !Array.isArray(health.products) || health.products.length !== expectedProducts.length ||
      !expectedProducts.every(product => health.products.includes(product))) {
    throw new Error('Latest snapshot collection is missing, incomplete or failed; retain the published page and inspect the collector run.');
  }
  const age = (now - new Date(health.checked_at)) / 3600000;
  if (!Number.isFinite(age) || age < -1 || age > maxAgeHours) {
    throw new Error('Latest snapshot collection is stale or future-dated; refresh before publishing.');
  }
  return health;
}

function warnFailures(health) {
  if (!health.errors) return;
  const message = `${health.errors} Learn page(s) failed; previous snapshots are retained where available. ` +
    `Publication ${publishableCollection(health) ? 'is allowed within the 5-page/1% limit' : 'is blocked'}.`;
  console.warn(`::warning::${message}`);
}

module.exports = { recordHealth, validateHealth, readCollectionSummary };
if (require.main === module) {
  try {
    const [root, errors, unreached, summaryFile] = process.argv.slice(2);
    if (root === '--validate') {
      const health = validateHealth(JSON.parse(fs.readFileSync(path.join(errors, '.learn-mirror/health.json'), 'utf8')), new Date());
      warnFailures(health);
      return;
    }
    if (!root || errors === undefined || unreached === undefined || errors === '' || unreached === '') {
      throw new Error('Usage: snapshot-health.cjs snapshot-root errors unreached [summary-path], or --validate snapshot-root');
    }
    const health = recordHealth(root, {
      errors: Number(errors), unreached: Number(unreached),
      collection: summaryFile ? readCollectionSummary(fs.readFileSync(summaryFile, 'utf8')) : undefined,
      runUrl: process.env.GITHUB_SERVER_URL && `${process.env.GITHUB_SERVER_URL}/${process.env.GITHUB_REPOSITORY}/actions/runs/${process.env.GITHUB_RUN_ID}`
    });
    console.log(`Collector health: ${health.complete ? 'complete' : publishableCollection(health) ? 'degraded (publishable)' : 'INCOMPLETE'}, ${health.article_count} articles across ${health.products.length} products.`);
    warnFailures(health);
    if (process.env.GITHUB_STEP_SUMMARY) {
      fs.appendFileSync(process.env.GITHUB_STEP_SUMMARY,
        `\n### Snapshot publication health\n\n${publishableCollection(health) ? 'Publication allowed' : 'Publication blocked'}; ` +
        `${health.errors} failed page(s), ${health.unreached} not reached. ` +
        'Failed pages retain previous snapshots where available and will be retried on the next collection. ' +
        'Failures are recorded in `.learn-mirror/health.json` and the Learn mirror summary above.\n');
    }
  } catch (error) { console.error(error.message); process.exitCode = 1; }
}
