#!/usr/bin/env node
'use strict';

const fs = require('node:fs');
const path = require('node:path');
const { execFileSync } = require('node:child_process');

const sources = [
  {
    repo: 'MicrosoftDocs/azure-aks-docs',
    routes: [
      ['articles/aks/', 'azure/aks/'],
      ['articles/aks-hybrid-edge/', 'azure/aks-hybrid-edge/'],
      ['articles/kubernetes-fleet/', 'azure/kubernetes-fleet/'],
      ['articles/application-network/', 'azure/application-network/']
    ]
  },
  {
    repo: 'MicrosoftDocs/azure-management-docs',
    routes: [
      ['articles/container-registry/', 'azure/container-registry/'],
      ['articles/azure-arc/kubernetes/', 'azure/azure-arc/kubernetes/'],
      ['articles/azure-linux/', 'azure/azure-linux/']
    ]
  },
  {
    repo: 'MicrosoftDocs/azure-docs',
    routes: [['articles/application-gateway/for-containers/', 'azure/application-gateway/for-containers/']]
  },
  {
    repo: 'MicrosoftDocs/SupportArticles-docs',
    routes: [
      'availability-performance', 'connectivity', 'create-upgrade-delete',
      'error-codes', 'extensions', 'load-bal-ingress-c', 'logs', 'security', 'storage'
    ].map(category => [
      `support/azure/azure-kubernetes/${category}/`,
      `troubleshoot/azure/azure-kubernetes/${category}/`
    ])
  }
];

function pageUrl(sourcePath, routes) {
  if (!sourcePath.endsWith('.md') || /(^|\/)(includes|media)\//.test(sourcePath)) return null;
  const route = routes.find(([prefix]) => sourcePath.startsWith(prefix));
  if (!route) return null;
  let slug = sourcePath.slice(route[0].length, -3);
  if (slug === 'toc' || slug.endsWith('/toc')) return null;
  if (slug === 'index') slug = '';
  return `https://learn.microsoft.com/en-us/${route[1]}${slug}`;
}

function githubJson(endpoint) {
  return JSON.parse(execFileSync('gh', ['api', endpoint], {
    encoding: 'utf8',
    maxBuffer: 64 * 1024 * 1024
  }));
}

function main() {
  const config = JSON.parse(fs.readFileSync(path.resolve(__dirname, '../../learn-mirror.config.json'), 'utf8'));
  const include = new RegExp(config.include);
  const urls = new Set();
  for (const source of sources) {
    const metadata = githubJson(`repos/${source.repo}`);
    let count = 0;
    for (const [prefix] of source.routes) {
      const subtree = `${metadata.default_branch}:${prefix.replace(/\/$/, '')}`;
      const tree = githubJson(`repos/${source.repo}/git/trees/${subtree}?recursive=1`);
      if (tree.truncated) throw new Error(`${source.repo}/${prefix}: truncated GitHub tree; seed list was not written`);
      for (const file of tree.tree) {
        if (file.type !== 'blob') continue;
        const url = pageUrl(prefix + file.path, source.routes);
        if (url && include.test(url)) {
          urls.add(url);
          count++;
        }
      }
    }
    if (count === 0) throw new Error(`${source.repo}: no matching pages; seed list was not written`);
    console.log(`${source.repo}: ${count} seed URLs`);
  }
  const target = path.resolve(__dirname, '../../learn-mirror-seed-urls.txt');
  fs.writeFileSync(target, [...urls].sort().join('\n') + '\n');
  console.log(`Wrote ${urls.size} URLs to ${target}`);
}

module.exports = { sources, pageUrl };
if (require.main === module) main();
