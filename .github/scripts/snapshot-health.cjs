#!/usr/bin/env node
'use strict';

const fs = require('node:fs');
const path = require('node:path');
const { routeFor } = require('./snapshot-changes.cjs');

function recordHealth(root, { errors, unreached, now = new Date(), runUrl }) {
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
  if (products.size !== 9) throw new Error(`Incomplete product coverage: ${[...products].join(', ')}`);
  const health = {
    schema_version: 1,
    checked_at: now.toISOString(),
    complete: errors === 0 && unreached === 0,
    errors, unreached, article_count: paths.size,
    products: [...products].sort(),
    run_url: runUrl
  };
  fs.writeFileSync(path.join(root, '.learn-mirror/health.json'), JSON.stringify(health, null, 2) + '\n');
  return health;
}

function validateHealth(health, now, maxAgeHours = 12) {
  if (health?.schema_version !== 1 || health.complete !== true || health.errors !== 0 || health.unreached !== 0 ||
      !Number.isSafeInteger(health.article_count) || health.article_count < 9 ||
      !Array.isArray(health.products) || new Set(health.products).size !== 9) {
    throw new Error('Latest snapshot collection is missing, incomplete or failed; retain the published page and inspect the collector run.');
  }
  const age = (now - new Date(health.checked_at)) / 3600000;
  if (!Number.isFinite(age) || age < -1 || age > maxAgeHours) {
    throw new Error('Latest complete snapshot collection is stale or future-dated; refresh before publishing.');
  }
  return health;
}

module.exports = { recordHealth, validateHealth };
if (require.main === module) {
  try {
    const [root, errors, unreached] = process.argv.slice(2);
    if (!root || errors === undefined || unreached === undefined || errors === '' || unreached === '') {
      throw new Error('Usage: snapshot-health.cjs snapshot-root errors unreached');
    }
    const health = recordHealth(root, {
      errors: Number(errors), unreached: Number(unreached),
      runUrl: process.env.GITHUB_SERVER_URL && `${process.env.GITHUB_SERVER_URL}/${process.env.GITHUB_REPOSITORY}/actions/runs/${process.env.GITHUB_RUN_ID}`
    });
    console.log(`Collector health: ${health.complete ? 'complete' : 'INCOMPLETE'}, ${health.article_count} articles across nine products.`);
  } catch (error) { console.error(error.message); process.exitCode = 1; }
}
