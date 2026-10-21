---
layout: Conceptual
title: Azure Container Registry endpoint reference - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-endpoint-reference
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/62/azure-container-registry/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/180a533d-0d25-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: johnsonshi
learn_banner_products:
- azure
manager: kumud
ms.reviewer: kumud
ms.author: johsh
ms.service: azure-container-registry
description: Reference for all Azure Container Registry endpoint types, including global, regional, and dedicated data endpoints, along with CLI flag details.
ms.topic: reference
ms.date: 2026-06-15T00:00:00.0000000Z
locale: en-us
document_id: 3520ded9-73c2-c029-368c-96ef6a43928f
document_version_independent_id: c0744789-9b72-e179-4bbd-6e22cde7233d
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-endpoint-reference.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-endpoint-reference
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-endpoint-reference.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: 5e7b9cb8-d0a1-0729-2f59-1cc482ef0bda
---

# Azure Container Registry endpoint reference - Azure Container Registry | Microsoft Learn

Azure Container Registry exposes several endpoint types depending on your registry's configuration. This article provides a reference for each endpoint type, how to view them, and the CLI flags that control them.

For information on geo-replication and regional endpoints, see [Geo-replication in Azure Container Registry](container-registry-geo-replication). For information on dedicated data endpoints, see [Dedicated data endpoints in Azure Container Registry](container-registry-dedicated-data-endpoints).

## Endpoint types

| Endpoint type | URL format | Purpose | Use case |
| --- | --- | --- | --- |
| Global endpoint | `myregistry.azurecr.io` | Login server with Azure-managed routing to any geo-replica | Default; optimal for most scenarios |
| Regional endpoint | `myregistry.<region-name>.geo.azurecr.io` | Login server for a specific geo-replica | Predictable routing, client-side failover, regional affinity, troubleshooting |
| Dedicated data endpoint | `myregistry.<region-name>.data.azurecr.io` | Layer blob downloads for registries with dedicated data endpoints or private endpoints | Scoped firewall rules; automatic 307 redirect from login server during pulls |
| Storage account | `*.blob.core.windows.net` | Layer blob downloads for registries without dedicated data endpoints or private endpoints | Automatic redirect from login server |

## View all endpoints

Use the `az acr show-endpoints` command to view all endpoints for your registry, including the global URL, regional endpoints (if enabled), and dedicated data endpoints (if enabled):

```azurecli
az acr show-endpoints --name myregistry --resource-group myrg
```

Example output for a registry with regional endpoints and dedicated data endpoints enabled:

```output
{
    "loginServer": "myregistry.azurecr.io",
    "dataEndpoints": [
        {
            "region": "eastus",
            "endpoint": "myregistry.eastus.data.azurecr.io"
        },
        {
            "region": "westus",
            "endpoint": "myregistry.westus.data.azurecr.io"
        }
    ],
    "regionalEndpoints": [
        {
            "region": "eastus",
            "endpoint": "myregistry.eastus.geo.azurecr.io"
        },
        {
            "region": "westus",
            "endpoint": "myregistry.westus.geo.azurecr.io"
        }
    ]
}
```

## CLI flags for registry endpoints

Important

Several CLI flags control different endpoint behaviors. Understanding the distinction is important to avoid misconfiguration.

| Flag | Scope | Purpose |
| --- | --- | --- |
| `--regional-endpoints` | Registry-level (on `az acr create` or `az acr update`) | Enables dedicated regional endpoint URLs (`myregistry.<region>.geo.azurecr.io`) for **all** geo-replicas. |
| `--global-endpoint-routing` | Per-geo-replica (on `az acr replication create` or `az acr replication update`) | Controls whether the **global endpoint** (`myregistry.azurecr.io`) routes traffic to a specific geo-replica. Set to `false` to temporarily exclude a geo-replica from global endpoint routing (for maintenance or troubleshooting). Data continues syncing regardless of this setting. See [Temporarily exclude a geo-replica from global endpoint routing](container-registry-geo-replication#temporarily-exclude-a-geo-replica-from-global-endpoint-routing). |
| `--data-endpoint-enabled` | Registry-level (on `az acr create` or `az acr update`) | Enables dedicated data endpoints (`myregistry.<region>.data.azurecr.io`) for layer blob downloads. Auto-enabled when at least one private endpoint is configured. See [Dedicated data endpoints](container-registry-dedicated-data-endpoints). |
| `--endpoint-protocol` | Registry-level (on `az acr update`) | Sets the endpoint protocol of the registry to `IPv4` (default) or `IPv4AndIPv6` (dual stack). Setting `IPv4AndIPv6` requires dedicated data endpoints to be enabled (`--data-endpoint-enabled true`). Requires Azure CLI 2.87.0 or later. See [IPv6 dual-stack endpoints](container-registry-ipv6-dual-stack). |

### Relationship between `--regional-endpoints` and `--global-endpoint-routing`

`--regional-endpoints` and `--global-endpoint-routing` are independent. Setting `--global-endpoint-routing false` on a geo-replica:

- Excludes that geo-replica from **global endpoint** routing only.
- Does **not** disable the geo-replica's **regional endpoint** URL. If `--regional-endpoints` is enabled at the registry level, clients can still directly access that geo-replica via the regional endpoint URL.
- Does **not** stop data syncing to that geo-replica.

**In short:**

- Use `--regional-endpoints` at the registry level to **enable dedicated regional URLs** for direct access to specific geo-replicas.
- Use `--global-endpoint-routing` on a specific geo-replica to **control global endpoint routing** to that geo-replica.
- Use `--data-endpoint-enabled` at the registry level to **enable dedicated data endpoints** for scoped layer blob downloads.
- Use `--endpoint-protocol` at the registry level to **set the endpoint protocol** to `IPv4` or `IPv4AndIPv6` (dual stack).