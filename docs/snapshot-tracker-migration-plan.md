# Testing a snapshot-based documentation tracker

## Status and boundaries

- Production collection: `main`, using the scheduled Learn snapshot workflow.
- Published-page history: `docs-snapshots`, an orphan data branch.
- Development and preview: `feature/snapshot-docs-tracker`.
- Current PR/commit-based tracker and WordPress publishing remain unchanged.
- This document is an implementation plan, not an implemented tracker switch.

The collector covers AKS, AKS Arc, Fleet, Application Network, ACR, Arc Kubernetes,
AGC and the nine existing AKS support categories. See
[collector documentation](learn-snapshots.md).

## 1. Establish and qualify the baseline

1. Verify the first hosted workflow succeeds and pushes `docs-snapshots`.
2. Record its content revision as the baseline in explicit tracker-consumer
   state. Do not infer that every file in the root commit is a new article.
3. Check the run summary for errors and unreached pages and inspect all eight
   product scopes. The initial local reference contained 1,352 Markdown files;
   use it as a comparison, not a permanent exact-count requirement.
4. Confirm a subsequent hosted collection loads saved ETags and does not
   reproduce unchanged article additions.
5. Record newly discovered pages during baseline completion as baseline content,
   not automatically as newly published articles.

Gate: all eight scopes have content, a complete pass has no unexplained fetch
errors/unreached pages, and a repeat pass successfully revalidates saved state.
Do not enable reader-facing new-page alerts until this gate is met.

## 2. Build a snapshot-to-change adapter

Prefer a small Node.js adapter alongside the existing PowerShell generator;
reusing the current summarization and presentation pipeline avoids a full
rewrite. Fetch snapshot history with sufficient depth, resolve immutable commit
IDs once per run, and read files/state from the same revisions.

Proposed versioned JSON contract:

```json
{
  "schema_version": 1,
  "source": "learn-snapshot",
  "baseline_revision": "<qualified baseline commit>",
  "head_revision": "<captured snapshot head>",
  "since": "<UTC midnight seven days ago>",
  "changes": [
    {
      "filename": "articles/application-network/overview.md",
      "repo_name": "azure-aks-docs",
      "product": "Application Network",
      "status": "modified",
      "additions": 3,
      "deletions": 1,
      "patch": "<unified content diff>",
      "title": "<article title>",
      "canonical_url": "https://learn.microsoft.com/en-us/azure/application-network/overview",
      "detected_at": "<UTC mirror commit timestamp>",
      "evidence_url": "<immutable mirror commit link>"
    }
  ]
}
```

- Use a seven-day window matching the current UTC-midnight convention. Compare
  article content at the window boundaries, bounded by the qualified baseline;
  aggregate by article, not every metadata/state commit.
- Skip state/config/provenance files and no-content commits. Reverted/net-zero
  changes should not become reader-facing updates.
- Keep the most recent content-change detection timestamp per article separately
  from Learn's publish metadata. Never represent it as a merge date.
- Map products and source repositories from configured path scopes; preserve the
  canonical Learn URL, especially Application Network's actual published route.
- Resolve renamed pages, aliases and deletions explicitly. A redirect or one
  missing-page response is not evidence that a feature was withdrawn.
- Retain evidence and last-known URL/title for deleted articles. Exclude deletion
  announcements from reader-facing output until confirmed or reviewed.
- Baseline missing, insufficient history, malformed state, missing files and
  stale/failed collection must produce explicit diagnostics, not "no updates".
- Decide and test a stale-data threshold before enabling publication; begin with
  a maximum age of 12 hours since the last successfully committed collection.
  Validate collection completeness separately from commit freshness.

## 3. Wire the existing generator behind an explicit mode

Add a `DOCS_SOURCE` selector with `github` as the unchanged default and
`snapshots` as the opt-in mode. Validate its value and require valid adapter
output in snapshot mode; never silently fall back to GitHub or an empty result.

Integration points in `.github/scripts/generate-aks-updates.ps1`:

- Replace only the documentation acquisition stage before grouping into
  `$groups` and `$filteredGroups`. Leave release notes and CVE acquisition alone.
- Adapt the new records to the existing additions/deletions/status/patch inputs,
  and reuse filtering and AI summaries without inventing PR titles.
- Include source mode and content revision/hash in summary-cache keys so PR
  summaries cannot accidentally satisfy snapshot summary requests.
- Update tracker rows, mobile views, evidence links, sorting and weekly docs
  digest together. Audit assumptions involving `pr_title`, `pr_url`,
  `merged_at`, `date`, `commits_count` and repository labels.
- Label snapshot timestamps "Detected" and evidence "View change"; do not show
  fabricated PR/author information.
- Preserve the existing generated JSON fields used by the publishing workflow,
  including `html`, `hash`, `digest_docs_html`, `digest_docs_title` and
  `digest_docs_count`. Confirm any other required fields from the caller.
- Preserve `CVE_ONLY`, release summaries, caching and the no-AI path.

## 4. Add a preview-only workflow

Create a manually dispatched workflow on the development branch:

1. Capture `docs-snapshots` HEAD and generate the adapter JSON.
2. Run the generator in opt-in snapshot mode.
3. Upload tracker HTML, weekly documentation digest, adapter input and a
   comparison report as workflow artifacts.
4. Compare against the current GitHub collector where public access still works.
5. Do not provide WordPress credentials, upload to Krystal, purge caches, commit
   live generated files or create/send weekly posts.
6. Use separate preview AI-cache files; avoid rewriting production caches.

If a WordPress visual preview is later needed, use a separately approved staging
page/site. Existing publish workflows must not run against preview output.

## 5. Tests and acceptance criteria

Use synthetic Git history plus small fixture articles/state, not live Learn
traffic, for deterministic adapter tests:

| Scenario | Required outcome |
|---|---|
| Initial baseline | Zero reader-facing updates |
| Same content / changed ETag or metadata | Zero updates |
| Meaningful article edit | One correct content diff and Learn/evidence links |
| Several edits to one article | One grouped result with correct window/detection time |
| Edit then revert | No net content update |
| New page after baseline qualification | One addition, not a baseline replay |
| Time-window boundary / UTC midnight | Correct inclusion and ordering |
| Rename, redirect, alias, 404/410 | No duplicate or premature withdrawal announcement |
| Partial crawl / retry / rate limit | Last good data preserved; explicit health diagnostic |
| Stale state / missing baseline / shallow history | Publication blocked with actionable error |
| All eight products | Correct scope, category, URL and source repository |
| AI disabled / cache reuse | Useful fallback; cache keys isolated by source/content |
| Tracker and weekly digest | Same eligible set, accurate count and valid JSON contract |
| CVE-only and releases | Existing behaviour unchanged |

Before switching production:

- Complete at least seven days of shadow collection, including one weekly-digest
  boundary, without publishing preview results.
- Explain every substantive discrepancy against the PR collector. Published
  differences and source-only/unpublished changes are expected distinctions.
- Review sample desktop/mobile tracker rows and weekly digest output.
- Confirm fixtures detect duplicate updates, baseline replay, stale data and
  broken canonical/evidence links.

## 6. Controlled cutover and rollback

Only after preview acceptance, expose the source selector in the production
workflow and explicitly opt into `snapshots`. Do not mix PR and snapshot results
for the same article or duplicate digest entries during transition.

Keep the legacy path and source-specific caches during the trial. Roll back by
selecting `github` where its repositories remain available; otherwise stop
documentation publication visibly rather than claim freshness. Releases and
CVEs should continue independently. Snapshot collection and its history remain
enabled regardless of which tracker source is selected.
