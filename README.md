# Published Microsoft Learn snapshots

This is a history of the **published English documentation** used by
[Azure AKS Tracker](https://github.com/PixelRobots/azure-aks-tracker).
The publishing workflow consumes this history for documentation updates;
GitHub releases and CVE data keep their existing sources.

## Collector and storage

The `Snapshot published Learn documentation` workflow runs every six hours,
at 02:20, 08:20, 14:20 and 20:20 UTC, and can also be started manually.
The workflow uses [merill/learn-mirror](https://github.com/merill/learn-mirror),
pinned to commit `4f6c802dd18d00a99397504b8872ae0841ac5c38` (v1), with Node.js 22.
No npm packages or Python environment are needed.

The workflow creates the `docs-snapshots` orphan branch on its first successful
run. That branch contains published Markdown at the original `articles/...` and
`support/...` paths, plus `.learn-mirror/state.json` with ETags, page metadata and
the rotation cursor. Git commits preserve previous versions. Nothing is pushed
to the source branch and no WordPress page or digest is updated.
The existing publishing workflow calls collection as a prerequisite before
generating and publishing its usual HTML. Merging the data branch is never needed.

The first pass is a baseline, not evidence that every article is newly published.
A time-limited pass may need subsequent runs to finish discovery and collection.
Check the workflow summary's errors and pages-not-reached counts before treating
the baseline as complete. Snapshot commits record when we **detected** changes,
not their exact publication time, author or original PR.

## Coverage

| Public source repository | Published documentation |
|---|---|
| `MicrosoftDocs/azure-aks-docs` | AKS, Kubernetes Fleet Manager, AKS Application Network, AKS Hybrid and Edge / AKS Arc |
| `MicrosoftDocs/azure-management-docs` | Azure Container Registry, Azure Arc-enabled Kubernetes and Azure Linux |
| `MicrosoftDocs/azure-docs` | Application Gateway for Containers |
| `MicrosoftDocs/SupportArticles-docs` | The same nine AKS troubleshooting categories as the existing tracker |

Public and private (`-pr`) repository names are accepted in Learn's source
metadata. Private GitHub access is **not** needed to retrieve published pages.
AKS releases, App Net GitHub release notes and CVE scans retain their existing
collectors; they are not Learn documentation repositories.

Discovery combines English Azure and troubleshooting sitemaps, eight tables of
contents, the committed seed list and previously known pages. The AKS table of
contents includes AKS Arc; its standalone `toc.json` currently returns 404.
URL and source-path filters keep the mirror within the tracked product scopes.
Source-repository metadata also has to match the configured allowlist.
Application Network is published under `/azure/application-network/`, not
`/azure/aks/application-network/`.

## Fetching and failure behaviour

The upstream tool requests `text/markdown`, revalidates known pages with ETags
and removes volatile publish metadata from stored Markdown. Metadata remains
available in its state file. A republish without content changes should therefore
not generate an article diff.

Requests are limited to four per second across four workers, with adaptive
throttling and retries. Each collection has a 25-minute budget and continues
from the saved cursor next time. Fetch errors are reported in logs and the
Actions summary; previous content is retained for failed requests. A committed
`.learn-mirror/health.json` heartbeat records completeness, zero-error status,
coverage and the check time. Production validates this marker and requires a
fresh, complete pass; partial collection is saved but blocks publishing.

An article disappearing from discovery alone does not remove its snapshot.
The pinned tool handles 404/410 responses and redirects, and refuses unusually
large deletion sets (more than the greater of 25 files or 10% of mirrored files).
It also refuses writes when errors exceed the greater of 10 requests or half the
checked pages. Smaller partial failures are saved, but our workflow then fails
its publication gate rather than allowing an incomplete run to publish.
It does **not** require a second 404 confirmation before removal; Git history
retains removed content.

This observes published states, not every source revision. Edits made and
reversed between checks may be missed. Learn endpoint, source-path or repository
changes may require configuration updates. Respect Microsoft Learn's crawling
policies; reduce the configured request rate if needed.

## Seeds and maintenance

`learn-mirror-seed-urls.txt` is generated from the public repository trees while
they are available. It is committed so future snapshots do not depend on those
repositories remaining accessible. Includes, media and TOC files are excluded.
Source paths are best-effort URL candidates: unpublished pages and custom-slug
articles can return 404. Sitemaps and TOCs supply actual published URLs as well.

To refresh seeds from the tracker source checkout, authenticate `gh`, then run:

```powershell
node .\.github\scripts\seed-learn-mirror.cjs
node --test .\.github\scripts\tests\learn-mirror.test.cjs
```

The generator uses scoped GitHub trees to avoid truncation in large repositories.
It refuses to overwrite the seed list on API failure, truncated trees or empty
repository scopes. Seed refresh is manual, not a prerequisite of scheduled runs.

To collect locally, clone/check out the `docs-snapshots` branch separately and
download the pinned upstream tool into a different directory. From the mirror
checkout, run the tool with `--config` and `--seed-urls` pointing to the files in
the tracker source checkout:

```powershell
node C:\tools\learn-mirror\learn-mirror.js --config=C:\src\azure-aks-tracker\learn-mirror.config.json --seed-urls=C:\src\azure-aks-tracker\learn-mirror-seed-urls.txt --max-minutes=25
```

The tool writes to the current working directory; do not run collection in the
tracker's source checkout. Commit local snapshot changes to preserve their
history. Avoid concurrent local and workflow pushes: the workflow deliberately
uses a normal push, not a force push, so a conflicting push fails visibly.
Use the manual workflow's `full` option to ignore saved ETags when diagnosing
missing/stale content.

## Testing the replacement tracker

See [the end-to-end preview and cutover guide](snapshot-preview.md). The same
production tracker markup/styles and docs digest layout are reused; snapshot
entries have a documentation link only, not a PR/change button.

## Attribution

The collector is MIT-licensed by [Merill Fernando](https://github.com/merill/learn-mirror).
Mirrored Microsoft Learn documentation is copyright Microsoft and respective
contributors; documentation licensing and any page-specific exceptions apply.
See [Microsoft Learn licensing](https://learn.microsoft.com/en-us/contribute/content/license)
and [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Each mirrored
article retains its canonical URL and source metadata for attribution. Mirroring
does not change the original content's licence or make it this project's MIT
code.
