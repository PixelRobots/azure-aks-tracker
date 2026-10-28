# Snapshot tracker: production cutover and testing

## What merging this branch does

Merging `feature/snapshot-docs-tracker` into `main` triggers the existing
publishing workflow with **published Learn snapshots** as its documentation
source. Subsequent scheduled and manual runs use that source too.

No new WordPress plugin, page, credential or setting is required. The generator
continues writing the existing `wordpress/aks-tracker-page.html` and CVE HTML
sources, using the existing upload, cache and weekly-post steps.

The tracker keeps its current markup, CSS classes, tabs, mobile styling,
subscription form, release cards and CVE integration. The documentation cards
and weekly docs digest now:

- Link only to the canonical Microsoft Learn article.
- Have **no View PR or View change button**.
- Label the timestamp **Detected**, rather than implying a source merge time.

Updated articles also have a collapsed **Show changes** disclosure below the
documentation button. It shows the same net article-body diff used for the
summary, as escaped source Markdown with surrounding context and line counts.
Green/red edge markers and `+`/`-` prefixes distinguish additions/removals without
relying on colour alone. Long diffs have a keyboard-focusable scrolling region;
long lines wrap on mobile. No JavaScript or plugin update is required.
New articles instead explain that there is no earlier snapshot to compare.
Weekly email digests remain summary-only, with the documentation link and no
embedded diff.

The collector's Git history and change evidence remain available in the
`docs-snapshots` branch and diagnostic JSON, not as reader-facing buttons.

## Collection and publication safety

Every full publishing run first calls the reusable snapshot collector. The
collector commits its Markdown/state plus `.learn-mirror/health.json`, including
the check timestamp, errors, unreached pages, article count, all nine product
scopes and the Actions run URL.

Production requires a complete pass with zero errors/unreached pages. A partial
pass is saved for continuation but fails the publication prerequisite. Failed
validation leaves the existing WordPress HTML untouched; it is not treated as
"no documentation changes".

The adapter reads a single captured Git revision, verifies complete history and
baseline ancestry, and validates the committed health marker against its state
and article files. A missing/incomplete marker, inconsistent coverage, or a
check older than 12 hours blocks publication. A heartbeat is committed even when
article content is unchanged.

The baseline is the first verified hosted collection:
`43fdba110daf1c48eeff521cb4ed8d59ce94fd49` (1,352 articles), recorded in
`snapshot-preview.config.json`. It is never replayed as 1,352 newly added pages.
The first cutover can therefore show zero documentation updates until real
changes are detected after that baseline. This does not preserve the old PR
collector's seven-day list: source and published-page histories are different.

New product scopes use `product_baselines` in the same configuration, keyed by
source-path prefix. Azure Linux uses its first complete, zero-error collection,
`ce655a297b4c3f32e5fd22745e5742c9265ac43c`, as its baseline. Both production
and live previews compare that scope against the later of its baseline and the
seven-day window boundary. This suppresses the initial import without hiding
later edits, new pages or updates to other products. Synthetic previews ignore
these live-history baselines.

The adapter aggregates net article-body changes in the last seven days from UTC
midnight, ignores metadata-only edits/reversions and holds deletions for review.
Simple content-preserving moves are not new articles. AI summaries and filtering
reuse the existing pipeline. Production snapshot summaries have a separate
`snapshot-docs-summary-cache.json`; legacy summaries cannot satisfy new-source
requests. Failed configured snapshot AI calls are explicit failures, not a
metadata-only GitHub Models fallback.

Current snapshot AI validation covers **OpenAI**, using the existing repository
secret and Responses API. With no provider configured the existing heuristic
path remains available; a configured but broken/unsupported provider fails
visibly. No new secret is needed for the current repository.

Snapshot enrichment sends article paths and patch samples directly in small
batches, rather than relying on file-search retrieval from an uploaded JSON
file. Each batch contains at most five articles and targets 60,000 input
characters; larger individual articles are sent alone without further truncation.
Returned identities must exactly match an article in that batch, with a nonempty
summary and no duplicates. Invalid responses still block publication rather than
silently dropping articles or falling back to metadata-only summaries.

The explicit **CVE-only** and **SSH-upload-only** manual modes bypass the
documentation prerequisite. Release/CVE APIs, rendering, cache behaviour and
weekly-post conditions otherwise retain their existing implementation.

## End-to-end preview before merging

The **Preview snapshot documentation tracker** workflow runs tests, refreshes
real snapshots, and generates two isolated artifact sets:

| Artifact | Purpose |
|---|---|
| `snapshot-preview-live` | Actual changes after the qualified baseline |
| `snapshot-preview-demo` | Clearly labelled synthetic changes across all nine products |

Relevant development-branch pushes trigger it automatically. Manual branch
dispatch is also supported using its registered workflow ID:

```powershell
gh workflow run 391958843 --repo PixelRobots/azure-aks-tracker --ref feature/snapshot-docs-tracker -f enrich_with_ai=true
```

Use `-f enrich_with_ai=false` to validate heuristic summaries. AI-enabled runs
use the existing `OPENAI_API_KEY` and incur normal provider usage costs. The
preview has no WordPress credentials and performs no WordPress requests, SSH
uploads, cache purges, weekly publishing or subscriber emails. It only writes
real documentation snapshots to the data branch; synthetic data never leaves
its temporary fixture repository as collection history.

Download and extract a successful run's artifacts:

- **`production-tracker.html`**: existing production tracker markup with current
  live-site tracker CSS copied into an isolated browser page, a preview banner
  and working tabs. Signup is disabled in this wrapper. WordPress plugin
  injection and the full WordPress theme shell are not executed locally.
- **`production-digest.html`**: actual existing email-safe docs digest layout,
  with a preview warning.
- **`wordpress-fragment.html`**: exact generated production fragment.
- **`production.json`**: the unchanged publishing output contract, including
  `html`, `hash`, docs digest/count, releases and CVE fields.
- **`changes.json`**, **`summaries.json`**, **`comparison.json`**: source diffs,
  summary methods and comparison with links in current committed production
  HTML. This comparison is a review aid, not automatic PR/snapshot parity.
- **`tracker.html`** and **`digest.html`**: the earlier simplified diagnostic
  views, not a claim to reproduce the production theme.

Open the downloaded files directly in a browser; GitHub's file viewer does not
execute HTML. The production wrapper requires public live-site CSS during
generation and fails visibly if that stylesheet cannot be retrieved.

The demo intentionally fabricates configuration/security changes, not product
guidance. Check its warning banner and use it only to exercise all product paths,
AI enrichment and presentation. A real baseline-only preview correctly has
zero updates.

## Review checklist

- Existing cards, colour scheme, tabs and responsive styling match the current
  tracker; only the documentation PR button and date wording differ.
- Each docs card/digest entry has exactly one documentation button and no PR or
  mirror-change button. Application Network uses `/azure/application-network/`.
- Modified cards open their own **Show changes** disclosure by mouse or keyboard;
  it starts collapsed, escapes HTML, retains the complete diff and has no
  page-level horizontal overflow on mobile. New articles show a new-page notice,
  not a full article masquerading as a modification. Emails contain no diff.
- Tracker and digest have the same eligible article set and accurate counts.
- Real timestamps are detection times; synthetic data is conspicuously labelled.
- Metadata-only edits, the initial baseline, reversions and simple moves do not
  generate fake new-page alerts.
- Releases and CVE controls/data still render; CVE-only mode works without
  snapshot input.
- Missing/stale/incomplete collection blocks publishing, rather than replacing
  the page with a misleading empty success.

Continue reviewing real changes over the first week and a weekly-digest boundary.
Snapshot monitoring cannot recover source changes before collection began, or
edits made and reversed between checks. Complex redirects/renames and expanded
includes can require manual review; deletion announcements remain suppressed.

## Optional private WordPress page

The downloaded production preview is sufficient for initial visual review.
For a real theme/plugin check, use a separate private page or staging site and
paste **`wordpress-fragment.html`** into a Custom HTML block. This is a fragment,
not a complete standalone document. The site must load the same tracker styles
and tab/filter scripts as the production page; those may be page-specific in
WordPress. Plugin CVE injection also depends on how the plugin recognises the
tracker page. Do not change its global source/cache settings to test.

If instead embedding a standalone HTML resource in an iframe, protect the
underlying URL too: a private parent page does not make the resource private.
The branch deliberately does not automate a WordPress staging upload.

## Deterministic tests and rollback

Requires Node.js 22, Git and PowerShell 7:

```powershell
node --test .\.github\scripts\tests\learn-mirror.test.cjs .\.github\scripts\tests\snapshot-preview.test.cjs
```

Tests use synthetic Git history, fixture HTTP responses and the actual production
generator to verify the diff window, baseline, health gates, no-AI path, identical
output contract, docs-only buttons, releases and CVE-only compatibility. Hosted
previews separately exercise the real OpenAI and release/CVE endpoints.

Rollback is a code/config change setting `DOCS_SOURCE: github` in the publishing
workflow and removing its snapshot collection/history prerequisite if necessary.
The legacy acquisition path and its summary cache remain intact. It only works
while the upstream public repositories remain usable; otherwise stop docs
publishing visibly and retain the last good HTML. Never merge, squash or delete
`docs-snapshots` during rollback.
