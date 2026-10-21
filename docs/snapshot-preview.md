# Test the snapshot tracker without changing production

## What is implemented

The `feature/snapshot-docs-tracker` branch contains an isolated end-to-end
documentation preview:

1. Read the complete `docs-snapshots` history and the qualified baseline.
2. Compute net article-body changes in the existing seven-day UTC window.
3. Run those changes through the **existing PowerShell documentation filtering
   and OpenAI summary pipeline**.
4. Render self-contained tracker and weekly-digest HTML, plus a comparison report.
5. Upload downloadable GitHub Actions artifacts. No WordPress requests, SSH
   uploads, cache purges, production cache writes, emails or snapshot commits.

The production publishing workflow is unchanged. Snapshot mode explicitly
requires `DOCS_PREVIEW_ONLY=true` and stops before release/CVE acquisition or
production HTML generation. This is a docs-only shadow preview, not yet a
production source switch or a complete visual replica of the existing tracker.
Its standalone layout supports desktop/mobile, light/dark mode, search and a
product filter. It uses the same eligible articles in tracker and digest views.

## Run it and view the result

Open the **Preview snapshot documentation tracker** workflow's run on the
development branch. Relevant code pushes to that branch automatically run it.
The workflow also declares `workflow_dispatch`, but GitHub only exposes manual
dispatch after the workflow exists on the default branch. Until that is merged,
push a relevant change to the development branch to rerun the hosted preview.
Do **not** run the production WordPress workflow against preview output.

Each successful run produces two artifacts, retained for 30 days:

| Artifact | Contents |
|---|---|
| `snapshot-preview-live` | Actual changes after the qualified baseline |
| `snapshot-preview-demo` | Clearly labelled synthetic changes across all eight products |

Download and extract an artifact, then open **`tracker.html`** and
**`digest.html`** directly in your browser. No local server or plugin is needed.
GitHub's normal repository file viewer does not execute HTML. The artifacts also
include:

- `changes.json`: article diffs, canonical URLs, immutable snapshot evidence and
  detection timestamps before summary filtering.
- `summaries.json`: filtered summaries, product/category and whether each summary
  was AI-generated or heuristic/isolated-cache derived.
- `comparison.json`: whether each preview article is linked in the current
  committed production HTML. This is a review aid, not automatic parity:
  source PR history and published-page history observe different stages.

The first hosted collection at commit
`43fdba110daf1c48eeff521cb4ed8d59ce94fd49` is the explicit baseline in
`snapshot-preview.config.json`. It captured 1,352 articles with no failed or
unreached requests. A baseline-only preview correctly shows **zero updates**,
not 1,352 new pages. Real content changes will populate the live view as later
snapshots arrive.

The demo uses a temporary local Git repository with synthetic configuration and
security edits. It never modifies `docs-snapshots`. Its banners and inline diffs
explicitly identify fake data; it does not invent public evidence links.
Demo documentation links are best-effort fixture URLs, not evidence that those
sample changes occurred.

## AI enrichment

Code-push previews use the existing `OPENAI_API_KEY` repository secret and
`gpt-4o-mini`/the existing Responses API implementation. This can incur normal
OpenAI usage costs. Only public documentation diffs or labelled synthetic
fixtures are sent. No WordPress credentials are made available to the workflow.

The runner installs PSAI only if it is missing, as in the existing generator.
Missing credentials, provider initialization failures or failed AI calls fail
the preview visibly rather than masquerade as successful AI enrichment.
The current preview validates **OpenAI only**, not Azure OpenAI/GitHub Models
fallbacks. The no-AI heuristic path is covered by deterministic integration tests.
After manual dispatch is available, untick `enrich_with_ai` to exercise that
path in hosted runs.

Each matrix job has its own summary cache under `RUNNER_TEMP`; production caches
are never loaded or overwritten. Cards label heuristic summaries explicitly.
The synthetic test must produce eight cards and, when AI is requested, at least
one AI-generated final summary. The workflow summary reports actual counts.

## What to check

- **Real view:** no baseline replay; correct products, canonical article URLs,
  UTC "Detected" times and **View change** links to mirror commits.
- **Demo view:** eight product areas, summaries grounded in the shown synthetic
  diff, prominent fake-data warnings and no invented PR links.
- **Filtering:** new/meaningful technical content retained; metadata-only changes,
  net reversions and content-preserving moves do not appear as new articles.
- **Digest:** same eligible article set/count as the tracker, readable on mobile,
  and no PR/merge wording.
- **Comparison report:** explain differences from the current production page.
  It is expected that published-page changes differ from merged source PRs.
- **Isolation:** no production page, digest, cache or CVE/release changes.

The adapter rejects shallow/missing history, an unrelated baseline, malformed
canonical mappings and a snapshot HEAD older than 12 hours. This age check is
conservative: a successful crawl with no changed state may create no commit.
Inspect collector health rather than assuming an old commit proves a failure.
Preview warnings explicitly state that freshness alone does not prove a complete
crawl. Machine-readable completeness/heartbeat gating is still required before
production cutover.

Deletions are held for review, not announced as feature withdrawals. Simple
content-preserving moves are suppressed; more complex rename/redirect behaviour
still needs shadow review. Expanded includes in published Markdown may create
several affected articles from one shared-content edit.

## Optional private WordPress page

Start with downloaded HTML; it provides the same end-to-end data/AI/rendering
test without WordPress risks. No replacement plugin is required.

For a WordPress preview later, serve **the complete standalone HTML document**
from a separately access-controlled preview location and embed it in a private
page using an iframe, or add a page-specific rendering source. Do not change the
existing plugin's global source/cache settings, and do not paste a full HTML
document into the normal page editor.

Making the WordPress page private does **not** make an iframe's underlying HTML
URL private. Protect the HTML resource too if it must remain private. Uploaded
HTML may also be blocked by the host/WordPress configuration. There is no
automated WordPress preview upload in this branch.

## Local no-AI run

Requires Node.js 22, Git and PowerShell 7. Keep output outside the source checkout:

```powershell
$preview = Join-Path $env:TEMP 'aks-snapshot-preview'
New-Item -ItemType Directory -Path $preview -Force | Out-Null
node .\.github\scripts\snapshot-changes.cjs --demo=true "--output=$preview\changes.json"
$env:DOCS_SOURCE = 'snapshots'
$env:DOCS_PREVIEW_ONLY = 'true'
$env:SNAPSHOT_CHANGES_PATH = "$preview\changes.json"
$env:DOCS_PREVIEW_OUTPUT_DIR = $preview
$env:DOCS_PREVIEW_REQUIRE_AI = 'false'
$env:GITHUB_TOKEN = 'local-preview-not-used'
Remove-Item Env:OpenAIKey, Env:AZURE_OPENAI_APIURI -ErrorAction SilentlyContinue
& .\.github\scripts\generate-aks-updates.ps1 1> "$preview\summaries.json"
node .\.github\scripts\render-snapshot-preview.cjs "$preview\summaries.json" $preview .\wordpress\aks-tracker-page.html
Start-Process "$preview\tracker.html"
```

For real input, replace `--demo=true` with `--repo=<separate full snapshot
checkout> --baseline=43fdba110daf1c48eeff521cb4ed8d59ce94fd49`.
Local environment changes apply to your current PowerShell session; use a fresh
terminal for normal production-script use afterward.

Run deterministic tests with:

```powershell
node --test .\.github\scripts\tests\learn-mirror.test.cjs .\.github\scripts\tests\snapshot-preview.test.cjs
```

## Remaining cutover work

Follow [the migration plan](snapshot-tracker-migration-plan.md): repeat hosted
collection, at least seven days of shadow review including a weekly boundary,
machine-readable collector health and baseline-completion handling, wider
redirect/alias fixtures, and production HTML/weekly digest integration behind an
explicit source selector. The preview does not yet enable a WordPress swap.
