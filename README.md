# Azure Container Services Documentation & Release Tracker

Stay on top of meaningful changes to **Azure Kubernetes Service (AKS)**, **Azure Container Registry (ACR)**, **Application Gateway for Containers (AGC)**, and **Kubernetes Fleet Manager** docs and releases.
This project fetches updates from multiple Microsoft repos, filters out noise with AI, then publishes a clean tracker page to WordPress. It also creates a weekly digest post for email.

**Live tracker:** [https://pixelrobots.co.uk/aks-docs-tracker/](https://pixelrobots.co.uk/aks-docs-tracker/)


## What it does

* **Multi-repository docs updates**
  Pulls the last 7 days of activity from multiple Microsoft documentation repositories:
  - `MicrosoftDocs/azure-aks-docs` (AKS and Fleet Manager)
  - `MicrosoftDocs/azure-management-docs` (Azure Container Registry)
  - `MicrosoftDocs/azure-docs` (Application Gateway for Containers)
  
  Groups changes by page, filters trivial edits, and writes AI summaries with intelligent product categorization.

* **AKS releases**
  Fetches the latest releases from `Azure/AKS` and generates short summaries with highlights.

* **Publishes to WordPress**
  Updates a single WordPress Page every 6 hours via REST API.

* **Weekly email digest**
  On Sundays at 09:00 UTC, generates a compact roundup post in a hidden category for Icegram Express to send.


## How it works

* **PowerShell script**
  `.github/scripts/generate-aks-updates.ps1` pulls data, runs optional AI summaries, and emits:

  * `html` for the tracker page
  * `digest_html` and `digest_title` for the weekly post
  * a `hash` to avoid unnecessary page updates

* **GitHub Actions**
  `.github/workflows/publish-aks-updates.yml` runs on a schedule:

  * Every 6 hours: regenerate content and push to the WordPress Page
  * Sundays 09:00 UTC: publish the weekly digest WordPress Post


## Repo layout

```
.github/
  workflows/
    publish-aks-updates.yml   # CI that runs the script and publishes to WP
  scripts/
    generate-aks-updates.ps1  # main script
```

## Requirements

* A WordPress site with:

  * Application Password for a user that can edit pages/posts
  * A Page created for the tracker (note its numeric ID)
  * Optional: Icegram Express for the weekly email
  * Optional: a hidden Category for the digest (note its ID)

* GitHub repository secrets:

| Secret name                | What it is                                       |
| -------------------------- | ------------------------------------------------ |
| `GITHUB_TOKEN`             | Provided by GitHub Actions by default            |
| `WP_URL`                   | Base URL, e.g. `https://pixelrobots.co.uk`       |
| `WP_USER`                  | WordPress username                               |
| `WP_APP_PASSWORD`          | WordPress Application Password                   |
| `WP_PAGE_ID`               | Numeric ID of the tracker page                   |
| `WP_WEEKLY_CATEGORY_ID`    | Numeric ID for hidden digest category (optional) |
| `OPENAI_API_KEY`           | Only if using OpenAI summaries (optional)        |
| `AZURE_OPENAI_APIURI`      | Only if using Azure OpenAI (optional)            |
| `AZURE_OPENAI_KEY`         | Only if using Azure OpenAI (optional)            |
| `AZURE_OPENAI_API_VERSION` | Only if using Azure OpenAI (optional)            |
| `AZURE_OPENAI_DEPLOYMENT`  | Only if using Azure OpenAI (optional)            |

> The script detects which AI provider is configured. If none, it still runs with simpler summaries.


## Schedule

* Page refresh: `0 */6 * * *` (every 6 hours)
* Weekly digest: `0 9 * * 0` (Sundays 09:00 UTC)

You can change these in `.github/workflows/publish-aks-updates.yml`.


## WordPress rendering

The Action wraps generated HTML in a `wp:html` block so the content is inserted as-is.
For the weekly digest, the post is created with `status: "publish"` and the optional `categories: [<WP_WEEKLY_CATEGORY_ID>]`.

If you are using Icegram Express:

* Create a list and a campaign that sends the latest post from the digest category.
* Add a signup form to your tracker page so people can subscribe.

Inline form example on the tracker page:

```
[email-subscribers-form id="2"]
```

Place it anywhere in the page HTML where you want the form to render.


## Local testing

You can run the script locally to see the generated JSON:

```powershell
pwsh ./.github/scripts/generate-aks-updates.ps1 | Set-Content out.json
Get-Content out.json -Raw | ConvertFrom-Json | Format-List *
```

To eyeball the HTML, write it out:

```powershell
$j = Get-Content out.json -Raw | ConvertFrom-Json
$j.html        | Set-Content content.html -Encoding UTF8
$j.digest_html | Set-Content digest.html  -Encoding UTF8
```

Open `content.html` in a browser to preview the structure.

## Contributing

Issues and PRs welcome. If you are adding sources, filters, or layout changes, include a short note in your PR that explains the rationale and shows a before/after.


## License

MIT. See [LICENSE](LICENSE).


Built by [pixelrobots.co.uk](https://pixelrobots.co.uk) with a little help from Open AI, GitHub Actions, and PowerShell.
