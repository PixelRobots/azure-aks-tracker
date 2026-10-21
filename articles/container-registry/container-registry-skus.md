---
layout: Conceptual
title: Azure Container Registry SKU Features and Limits - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-skus
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
author: KumudD
learn_banner_products:
- azure
manager: kumud
ms.reviewer: kumud
ms.author: kumud
ms.service: azure-container-registry
description: Learn about the features and limits in various SKUs of Azure Container Registry.
ms.topic: concept-article
ms.date: 2026-10-15T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: dfe5a2a3-6fd3-2cca-0387-5c0d9b19906c
document_version_independent_id: 3b1ddae9-b0c3-78ff-15a5-428abea3773e
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-skus.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-skus
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-skus.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/57eae307-c3a1-4cac-b645-1a899934bac8
- https://authoring-docs-microsoft.poolparty.biz/devrel/fcc3cd4a-59ea-47a2-9cc1-784142a5a25d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/ee561821-1ac7-45a8-9409-6ba5eb7a5b97
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7a55faf-a992-4e27-aa3a-eadc9830e778
platformId: 5ed8c9e7-3dbd-903a-203c-fe63a7e13b2d
---

# Azure Container Registry SKU Features and Limits - Azure Container Registry | Microsoft Learn

Azure Container Registry is available in multiple SKUs. These SKUs, also known as pricing plans or tiers, support predictable pricing and align to different capacity and usage patterns of your private container registry in Azure.

When you create a registry, you select a **Pricing Plan** that determines the features and limits of your registry. Choose the plan that aligns with your expected usage patterns, such as the number of images, storage needs, and performance requirements.

Azure Container Registry offers three **Pricing Plan** options: Basic, Standard, and Premium. Each SKU offers a different set of features and limits to accommodate various scenarios, from development and testing to production workloads.

| SKU | Description |
| --- | --- |
| **Basic** | A cost-optimized entry point for developers learning about Azure Container Registry. Basic registries have most of the same capabilities as Standard and Premium registries, such as Microsoft Entra [authentication integration](container-registry-authentication#individual-login-with-azure-ad), [image deletion](container-registry-delete), and [webhooks](container-registry-webhook). However, the included storage and image throughput are most appropriate for lower usage scenarios, and some features aren't available. |
| **Standard** | Standard registries offer the same capabilities as Basic, with increased included storage and image throughput. Standard registries satisfy the needs of many production scenarios. |
| **Premium** | Premium registries provide the highest amount of included storage and concurrent operations, enabling high-volume scenarios. In addition to higher image throughput, Premium adds features such as [geo-replication](container-registry-geo-replication) for high availability through managing a single registry across multiple regions, [private link with private endpoints](container-registry-private-endpoints) to restrict access to the registry, and higher API concurrency and bandwidth throughput for large-scale concurrent deployments. |

Each SKU includes a specific amount of free storage, with additional storage available at a per-GB rate. Each SKU also has a different maximum storage limit.

The Basic, Standard, and Premium SKUs all provide the same programmatic capabilities and data plane APIs. They also all benefit from [image storage](container-registry-storage) managed entirely by Azure, and all SKUs have [zone redundancy](zone-redundancy) enabled by default in supported regions. However, the Premium SKU enables a wider range of features and has higher limits.

## SKU features and limits

The following table details the features and registry limits of the Basic, Standard, and Premium SKUs.

| Resource | Basic | Standard | Premium |
| --- | --- | --- | --- |
| Included storage^1^ (GiB) | 10 | 100 | 500 |
| Storage limit (TiB) | 40 | 40 | 100 |
| Maximum image layer size (GiB) | 195 | 195 | 195 |
| Maximum manifest size (MiB) | 4 | 4 | 4 |
| Webhooks | 2 | 10 | 500 |
| Private link with private endpoints | N/A | N/A | [Supported](/en-us/azure/container-registry/container-registry-private-link) |
| • Private endpoints | N/A | N/A | 200 |
| Public IP network rules | N/A | N/A | 200 |
| Service endpoint VNet access | N/A | N/A | [Preview](/en-us/azure/container-registry/container-registry-vnet) |
| • Virtual network rules | N/A | N/A | 100 |
| Repository-scoped permissions with Microsoft Entra role assignments | [Supported](/en-us/azure/container-registry/container-registry-rbac-abac-repository-permissions) | [Supported](/en-us/azure/container-registry/container-registry-rbac-abac-repository-permissions) | [Supported](/en-us/azure/container-registry/container-registry-rbac-abac-repository-permissions) |
| Repository-scoped permissions with non-Microsoft Entra tokens and scope maps | [Supported](/en-us/azure/container-registry/container-registry-repository-scoped-permissions) | [Supported](/en-us/azure/container-registry/container-registry-repository-scoped-permissions) | [Supported](/en-us/azure/container-registry/container-registry-repository-scoped-permissions) |
| • Non-Microsoft Entra tokens | 100 | 500 | 50,000 |
| • Non-Microsoft Entra token scope maps | 100 | 500 | 50,000 |
| • Actions per non-Microsoft Entra token scope map | 500 | 500 | 500 |
| • Repositories per non-Microsoft Entra token scope map^2^ | 500 | 500 | 500 |
| Anonymous pull access | N/A | [Supported](/en-us/azure/container-registry/anonymous-pull-access) | [Supported](/en-us/azure/container-registry/anonymous-pull-access) |
| Geo-replication | N/A | N/A | [Supported](/en-us/azure/container-registry/container-registry-geo-replication) |
| Dedicated data endpoints | N/A | N/A | [Supported](/en-us/azure/container-registry/container-registry-dedicated-data-endpoints) |
| Availability zones | [Supported](/en-us/azure/container-registry/zone-redundancy) | [Supported](/en-us/azure/container-registry/zone-redundancy) | [Supported](/en-us/azure/container-registry/zone-redundancy) |
| Content trust | N/A | N/A | [Supported](/en-us/azure/container-registry/container-registry-content-trust) |
| Customer-managed keys | N/A | N/A | [Supported](/en-us/azure/container-registry/tutorial-enable-customer-managed-keys) |
| Connected registries | N/A | N/A | [Supported](/en-us/azure/container-registry/intro-connected-registry) |
| Artifact streaming | N/A | N/A | [Supported](/en-us/azure/container-registry/container-registry-artifact-streaming) |
| Artifact cache rules | N/A | [Supported](/en-us/azure/container-registry/artifact-cache-overview) | [Supported](/en-us/azure/container-registry/artifact-cache-overview) |
| IP access rule configuration | N/A | N/A | [Supported](/en-us/azure/container-registry/container-registry-access-selected-networks) |
| Retention policy for untagged manifests | N/A | N/A | [Supported](/en-us/azure/container-registry/container-registry-retention-policy) |
| Artifact transfer | N/A | N/A | [Supported](/en-us/azure/container-registry/container-registry-transfer-prerequisites) |
| Export policy | N/A | N/A | [Supported](/en-us/azure/container-registry/data-loss-prevention) |
| Dedicated agent pools for Tasks | N/A | N/A | [Supported](/en-us/azure/container-registry/tasks-agent-pools) |

^1^ Storage included in the daily rate for each tier. Additional storage may be used, up to the registry storage limit, at an additional daily rate per GiB. For rate information, see [Azure Container Registry pricing](https://azure.microsoft.com/pricing/details/container-registry/). If you need storage beyond the registry storage limit, please contact Azure Support.

^2^ Individual *actions* of `content/delete`, `content/read`, `content/write`, `metadata/read`, `metadata/write` correspond to the limit of repositories per non-Microsoft Entra token scope map.

ACR also has the following image pull and push performance limits.

### API request rate limits

In addition to the storage and feature limits in the preceding table, Azure Container Registry enforces request rate limits on registry APIs. Rate limits are measured in requests per minute (r/m) and are determined by your registry's SKU. When your request rate exceeds a limit, the registry returns an HTTP `429 Too Many Requests` error. The response includes a `Retry-After` header that indicates how long to wait before retrying.

To monitor request traffic and investigate throttling, see Throttling and bandwidth constraints.

Requests are throttled in the following operation categories. Some categories are subsets of a broader category, and requests in those categories count against both limits:

| Operation category | HTTP methods | Examples |
| --- | --- | --- |
| **DataplaneRead** | GET, HEAD, OPTIONS | Getting (pulling) image manifests and layers. Getting layer blob location. Checking the existence of a digest or tag. Other read operations. Includes MetadataRead and ListReferrers requests. |
| **MetadataRead** | GET | Reading metadata about a registry and its contents. Includes the following [`ApiName` values](monitor-container-registry-reference#api-name-values) for the `Transactions` metric: `GetListRepositories`, `GetListTags`, `GetListManifests`, `GetManifestProperties`, and `GetRepositoryProperties`. MetadataRead requests also count toward the DataplaneRead limit. |
| **ListReferrers** | GET | Listing the referrer artifacts of a manifest, such as signatures and SBOMs. This category appears as `GetListReferrers` in the [`ApiName` values](monitor-container-registry-reference#api-name-values) for the `Transactions` metric. ListReferrers requests also count toward the DataplaneRead limit. |
| **DataplaneWrite** | PUT, PATCH, POST | Pushing image manifests and layers. Pushing tags. Other write operations. |
| **DataplaneDelete** | DELETE | Deleting images, manifests, and tags. |
| **OAuth** | Authentication (AuthN) and authorization (AuthZ) | Authentication requests that clients make when logging in to a registry login server, such as exchanging from a Microsoft Entra ID access token, a registry admin token, or a non-Microsoft Entra scope mapped token, to a registry refresh token. Authorization requests that clients make before push, pull, and other registry data plane operations, such as exchanging from a registry refresh token to a scoped registry access token. |

The following request rate limits are enforced for each SKU:

| Operation | Scope | Basic and Standard | Premium |
| --- | --- | --- | --- |
| DataplaneRead | Per registry | 10,000 r/m | 20,000 r/m |
| DataplaneRead | Per identity per registry | 5,000 r/m | 10,000 r/m |
| MetadataRead^1^ | Per registry | 4,000 r/m | 8,000 r/m |
| MetadataRead^1^ | Per identity per registry | 2,000 r/m | 4,000 r/m |
| ListReferrers^1^ | Per registry | 500 r/m | 2,000 r/m |
| ListReferrers^1^ | Per identity per registry | 250 r/m | 1,000 r/m |
| DataplaneWrite | Per registry | 2,000 r/m | 4,000 r/m |
| DataplaneWrite | Per identity per registry | 1,000 r/m | 2,000 r/m |
| DataplaneDelete | Per registry | 1,000 r/m | 4,000 r/m |
| DataplaneDelete | Per identity per registry | 500 r/m | 2,000 r/m |
| OAuth | Per registry | 10,000 r/m | 20,000 r/m |

^1^ MetadataRead and ListReferrers requests also count toward the DataplaneRead limit. For more information, see Requests that count against multiple limits.

Note

The rate limits listed in the preceding table are **best-effort approximate maximums** and are **not backed by an SLA**. Actual throughput may vary across registries and over time depending on infrastructure conditions, traffic patterns, and other factors. These numbers represent the rough maximum request rates you can expect under typical operating conditions, but Azure Container Registry does not guarantee these exact rates at all times.

#### Per-registry and per-identity limits

- **Per registry** limits apply to the combined request rate from all clients and identities to a single registry.
- **Per identity per registry** limits apply to the request rate from a single identity to a single registry. Per identity limits prevent a single client, such as a vulnerability scanner or a misconfigured deployment, from consuming a registry's entire request capacity. Per identity per registry limits are tracked separately for each registry, so an identity that authenticates to multiple registries isn't throttled across those registries together.
- For a registry that has [unauthenticated anonymous pull access](anonymous-pull-access) enabled, all **anonymous (unauthenticated) requests** are throttled together as a single identity for that single registry.
- For a registry that has the [admin user account](container-registry-authentication#admin-account) enabled, all requests that authenticate with **admin credentials** are throttled together as a single identity for that single registry. The admin account has two passwords (`password` and `password2`), but both passwords share the same identity for throttling purposes. If multiple clients or automation workflows authenticate with admin credentials, they all consume the same per-identity rate limit bucket.
- **OAuth** authentication and authorization requests are throttled per registry only, without separate per identity per registry limits.

#### Requests that count against multiple limits

Some requests count against more than one operation category, and a request is throttled if *any* applicable limit is exceeded. For example, a request to list the referrers of a manifest is both a ListReferrers request and a DataplaneRead request, and it consumes capacity from both limits. If your registry has already exhausted its DataplaneRead limit, referrers requests are also throttled, even if the ListReferrers limit hasn't been reached. Likewise, a high rate of referrers requests reduces the DataplaneRead capacity that remains for other read operations, such as image pulls.

MetadataRead requests work the same way. Each MetadataRead request counts against both the MetadataRead and DataplaneRead limits.

#### How rate limits are enforced

Rate limits are enforced by using a token bucket algorithm. Each operation category has a bucket of request capacity that refills continuously at the rate shown in the preceding table. This approach is designed to tolerate bursty workloads:

- **Short bursts above the steady rate are allowed.** A spike of requests, such as a large-scale deployment pulling images across many nodes at the same time, succeeds as long as capacity remains in the bucket.
- **Sustained traffic must stay at or below the limit.** If a burst empties the bucket, subsequent requests are rejected with `429 Too Many Requests` until capacity refills, which can result in requests being throttled for up to a full minute after a large burst.

The `Retry-After` value in a `429` response indicates the number of seconds remaining until the current throttling period ends, so the value counts down across consecutive throttled requests rather than staying fixed. For example, the first throttled response might return `Retry-After: 60`. If you retry 10 seconds later and the request is still throttled, the response returns `Retry-After: 50`. Because the value is calculated dynamically for each request, don't take a dependency on a fixed `Retry-After` value.

When you receive a `429` response, honor the `Retry-After` header and implement retry logic with exponential backoff. For more mitigation guidance, see Throttling and bandwidth constraints.

Occasionally, during a sudden, aggressive ramp-up from a low baseline (such as a thundering herd), you might temporarily observe lower throughput than the published limits while the registry's infrastructure scales out to meet demand.

Note

Some limits in this table can be increased by contacting [Azure Support](https://azure.microsoft.com/support/create-ticket/). Increase requests are supported for:

- Registry storage limits
- Maximum private endpoints (Private Link connections) per registry
- Image push and pull performance limits, including throttling, bandwidth, and data-plane API request-rate limits

The following limits are fixed and can't be increased through a support request:

- Maximum public IP network rules
- Maximum service endpoint virtual network rules
- Maximum non-Microsoft Entra tokens
- Maximum non-Microsoft Entra token scope maps
- Maximum actions per non-Microsoft Entra token scope map
- Maximum repositories per non-Microsoft Entra token scope map

Azure Support might review requests to increase storage capacity, private endpoint count, and persistent data-plane throttling or push/pull bandwidth limits. Approval is case-by-case. Other limits in this table aren't adjustable unless explicitly stated.

For pricing information on each of the Azure Container Registry SKUs, see [Container Registry pricing](https://azure.microsoft.com/pricing/details/container-registry/). For details about pricing for data transfers, see [Bandwidth pricing](https://azure.microsoft.com/pricing/details/bandwidth/).

## Registry image pull and push performance limits

API concurrency, bandwidth throughput, and throttling during high-volume operations primarily affect image pull and push performance. Your registry SKU, network configuration, and client configuration determine these factors.

### API concurrency and bandwidth throughput limits

Your SKU determines API concurrency and bandwidth throughput. Higher SKUs support more concurrent operations and greater bandwidth for data-plane operations like listing, deleting, pushing, and pulling images.

The following factors affect API concurrency and bandwidth throughput during image pulls and pushes:

- Number and size of image layers
- Reuse of layers across images in the registry
- Additional API calls required for each operation
- Scale of concurrent deployments, such as Kubernetes deployments pulling images across multiple nodes simultaneously

The following client environment factors affect performance:

- Docker daemon or Podman configuration for concurrent operations
- Container runtime configuration, such as `containerd` or CRI-O concurrency settings
- Cluster configuration or cluster data plane settings

The following network factors affect performance:

- Network bandwidth and latency for the network hops from clients to the registry
- Client-side network configuration, such as firewall rules and proxy settings
- Geographic distance to the registry or nearest replica if [geo-replicated](container-registry-geo-replication)

For more information about API operations that happen during image push and pull, see the [Docker HTTP API V2](https://docs.docker.com/registry/spec/api/) documentation. For help troubleshooting, see [Troubleshoot registry performance](container-registry-troubleshoot-performance).

### Throttling and bandwidth constraints

During periods of high request volume, you might encounter throttling with an HTTP 429 `Too many requests` error or slow bandwidth throughput.

#### Audit throttling and bandwidth

Use Azure Monitor metrics to identify the affected operations and regions:

- Filter `Transactions` by `ResponseType = Throttled` to identify throttled requests.
- Split `Transactions` by `ApiName` to identify the affected registry operations.
- Split `Transactions` by `Region` to determine which replicas are affected.
- Split `DataTransfer` by `ApiName` or `Region` to compare transferred data by operation or serving region.

For definitions, see [API name values](monitor-container-registry-reference#api-name-values) and [Response type values](monitor-container-registry-reference#response-type-values). For reusable visualizations, see [Grafana dashboards in Azure Container Registry](/en-us/azure/container-registry/container-registry-dashboards-with-grafana).

#### Mitigate throttling and bandwidth constraints

After you identify the affected traffic, use one or more of the following mitigation options:

- Implement retry logic with exponential backoff and jitter.
- Reduce the rate of concurrent requests.
- Space out large-scale deployments to reduce simultaneous image pulls across multiple nodes.
- If you're experiencing throttling after a sudden increase in traffic from a previously low baseline, you might temporarily see lower throughput while the registry's infrastructure scales out to meet demand.

Note

If you experience persistent API throttling or slow bandwidth throughput, consider updating your registry's SKU to a higher one. You can also contact Azure support to [request a limit increase](https://azure.microsoft.com/support/create-ticket/).

## Show registry usage

Usage information helps you make decisions about changing the SKU when your registry nears a limit, and helps you [manage consumption](container-registry-best-practices#manage-registry-size).

To get a snapshot of your registry's current consumption of storage and other resources, compared with the limits for that registry's SKU, check the **Overview** page of your registry in the Azure portal. You can also use APIs such as [az acr show-usage](/en-us/cli/azure/acr#az-acr-show-usage) (Azure CLI), [Get-AzContainerRegistryUsage](/en-us/powershell/module/az.containerregistry/get-azcontainerregistryusage) (Azure PowerShell), or [Registries - List Usages](/en-us/rest/api/container-registry/registries/list-usages) (REST API).

Note

The registry's storage usage might not reflect all recent registry operations. Monitor the registry's [`StorageUsed` metric](monitor-service-reference#metrics) for up-to-date data.

Depending on your registry's SKU, usage information includes some or all of the following, along with the limit in that SKU:

- Storage consumed in bytes
- Number of [webhooks](container-registry-webhook)
- Number of [geo-replications](container-registry-geo-replication) (includes the home replica)
- Number of [private endpoints](container-registry-private-endpoints)
- Number of [IP access rules](container-registry-access-selected-networks)
- Number of [virtual network rules](container-registry-vnet)

In a geo-replicated registry, storage usage is shown for the home region. Multiply by the number of replicas for the total amount of storage.

## Change registry SKU

You can change a registry's SKU in the Azure portal or by using [Azure CLI](/en-us/cli/azure/acr#az-acr-update) or [Azure PowerShell](/en-us/powershell/module/az.containerregistry/update-azcontainerregistry). You can move freely between SKUs as long as the SKU you're switching to has the required maximum storage capacity.

When you change a registry's SKU, there's no downtime or impact on registry operations. However, if you move from Premium to a lower SKU, features specific to premium are disabled. In some cases, you need to remove resources related to these features before you can switch SKUS. For example, you must delete any geo-replications or connected registries before you can switch from Premium to Standard or Basic.

To change SKUs in the Azure portal, go to your container registry. In the service menu, under **Settings**, select **Properties**. Change the option for **Pricing plan**, and then select **Save**.

To change SKUs by using the Azure CLI, use the [az acr update](/en-us/cli/azure/acr#az-acr-update) command. For example, to switch to Premium:

```azurecli
az acr update --name myContainerRegistry --sku Premium
```

To change SKUs by using Azure PowerShell, use the [Update-AzContainerRegistry](/en-us/powershell/module/az.containerregistry/update-azcontainerregistry) cmdlet. For example, to switch to Premium:

```azurepowershell
Update-AzContainerRegistry -ResourceGroupName myResourceGroup -Name myContainerRegistry -Sku Premium
```