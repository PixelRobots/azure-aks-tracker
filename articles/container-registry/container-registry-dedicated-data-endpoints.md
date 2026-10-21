---
layout: Conceptual
title: Dedicated data endpoints for Azure Container Registry - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-dedicated-data-endpoints
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
description: Learn how dedicated data endpoints in Azure Container Registry enable scoped firewall rules and mitigate data exfiltration risks for container image layer downloads.
ms.topic: how-to
ms.date: 2026-06-15T00:00:00.0000000Z
locale: en-us
document_id: 54ef7e21-d074-ab8b-1e29-2f65a547422d
document_version_independent_id: fa643b27-380d-679a-24a1-87b3dd823c69
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-dedicated-data-endpoints.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-dedicated-data-endpoints
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-dedicated-data-endpoints.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/a9a12e3a-5d9d-4197-ad96-b826bc774b60
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/6dfd60ec-b0d6-48ef-9c74-057162ea03fb
platformId: 19f46537-8742-2d4d-4ba3-ea1b08602921
---

# Dedicated data endpoints for Azure Container Registry - Azure Container Registry | Microsoft Learn

Dedicated data endpoints in Azure Container Registry provide scoped, registry-specific URLs for container image layer downloads, replacing the default wildcard Azure storage account endpoints (`*.blob.core.windows.net`). This enables tightly scoped client firewall rules and mitigates data exfiltration risks.

Note

Dedicated data endpoints are only used during layer blob **downloads** (pulls). When uploading blobs during pushes, they go via the login server (global endpoint or regional endpoint), not the dedicated data endpoint.

The dedicated data endpoints feature is available for registries in the **Premium**[service tier](container-registry-skus).

Dedicated data endpoints are also a prerequisite for [IPv6 dual-stack endpoints](container-registry-ipv6-dual-stack). A registry must have dedicated data endpoints enabled before its endpoint protocol can be set to `IPv4AndIPv6`.

## How container image downloads work: login server and 307 redirect to data endpoints

Pulling content from a registry involves two types of endpoints:

1. **Login server endpoint** — used for authentication and content discovery. The login server can be either:

    - The **global endpoint** (`contoso.azurecr.io`) — ACR automatically routes requests to the geo-replica with the best network performance profile for the client. For more information, see [geo-replication](container-registry-geo-replication).
    - A **regional endpoint** (`contoso.eastus.geo.azurecr.io`) — routes requests directly to a specific geo-replica, bypassing Azure-managed routing. For more information, see [geo-replication](container-registry-geo-replication).

    When you run a command like `docker pull contoso.azurecr.io/hello-world` (global endpoint) or `docker pull contoso.eastus.geo.azurecr.io/hello-world` (regional endpoint), the client authenticates against the login server and negotiates which layers make up the requested artifact.
2. **Data endpoint** — used for downloading the actual image layer blobs. After the login server identifies the required layers, it redirects the client to download them from a data endpoint.

![Diagram to illustrate endpoints.](media/dedicated-data-endpoints/endpoints.png)

ACR manages the underlying storage accounts for data endpoints. Benefits include load balancing, content splitting across storage accounts for higher concurrent delivery, and multi-region support with [geo-replication](container-registry-geo-replication).

### Without dedicated data endpoints

Without dedicated data endpoints, the login server issues a 307 redirect for layer blob downloads to Azure storage accounts using wildcard URLs (`*.blob.core.windows.net`).

**Using the global endpoint (Azure-managed routing):**

![Diagram showing the request flow without dedicated data endpoints using the global endpoint: a client connects to contoso.azurecr.io, Azure-managed routing selects the best geo-replica, and the geo-replica issues a 307 redirect to *.blob.core.windows.net for layer blob downloads.](media/dedicated-data-endpoints/without-dedicated-data-endpoints-global-endpoint.png)

**Using a regional endpoint (client-specified routing):**

![Diagram showing the request flow without dedicated data endpoints using a regional endpoint: a client connects to contoso.eastus.geo.azurecr.io, the request goes directly to the East US geo-replica, and the geo-replica issues a 307 redirect to *.blob.core.windows.net for layer blob downloads.](media/dedicated-data-endpoints/without-dedicated-data-endpoints-regional-endpoint.png)

In both cases, to allow these downloads through a firewall, you must permit `*.blob.core.windows.net` — a broad wildcard that covers all Azure storage accounts, not just your registry's storage.

### With dedicated data endpoints

With dedicated data endpoints enabled, the login server issues a 307 redirect for layer blob downloads to registry-specific, region-scoped URLs.

**Using the global endpoint (Azure-managed routing):**

![Diagram showing the request flow with dedicated data endpoints using the global endpoint: a client connects to contoso.azurecr.io, Azure-managed routing selects the best geo-replica, and the geo-replica issues a 307 redirect to contoso.eastus.data.azurecr.io for layer blob downloads.](media/dedicated-data-endpoints/dedicated-data-endpoints-with-global-endpoint.png)

**Using a regional endpoint (client-specified routing):**

![Diagram showing the request flow with dedicated data endpoints using a regional endpoint: a client connects to contoso.eastus.geo.azurecr.io, the request goes directly to the East US geo-replica, and the geo-replica issues a 307 redirect to contoso.eastus.data.azurecr.io for layer blob downloads.](media/dedicated-data-endpoints/dedicated-data-endpoints-with-regional-endpoint.png)

Each geo-replica gets its own dedicated data endpoint using the pattern `[registry].[region].data.azurecr.io`. Your firewall rules can be scoped to these specific endpoints instead of a broad wildcard.

## Why dedicated data endpoints matter

### Data exfiltration risk without dedicated data endpoints

Without dedicated data endpoints, firewall rules must allow `*.blob.core.windows.net` to permit layer downloads. This broad wildcard opens access to all Azure storage accounts — not just your registry's storage. A bad actor could deploy code that writes data to any Azure storage account reachable from the network.

![Diagram to illustrate client data exfiltration risks.](media/dedicated-data-endpoints/client-firewall-2.png)

### Scoped firewall rules with dedicated data endpoints

Dedicated data endpoints let you replace the broad `*.blob.core.windows.net` wildcard with scoped firewall rules for your specific registry's data endpoints. For example, you can allow only `contoso.eastus.data.azurecr.io` and `contoso.westeurope.data.azurecr.io` in your firewall configuration — limiting access to your registry's storage and blocking exfiltration to other storage accounts.

![Diagram to illustrate contoso example with dedicated data endpoints.](media/dedicated-data-endpoints/contoso-example-0.png)

This applies to clients connecting from on-premises hosts, IoT devices, custom build agents, or any environment where private endpoints aren't an option.

## Dedicated data endpoints with geo-replication

For [geo-replicated](container-registry-geo-replication) registries, each geo-replica gets its own dedicated data endpoint. The URL pattern is `[registry].[region].data.azurecr.io`.

When you pull an image from the global endpoint, ACR routes the request to the geo-replica with the best network performance profile for the client. The serving geo-replica then issues a 307 redirect for layer blob downloads to the serving geo-replica's own dedicated data endpoint. The redirect always stays within the **same region** as the serving geo-replica — a pull routed to the East US geo-replica always redirects to `contoso.eastus.data.azurecr.io`, never to a dedicated data endpoint in a different region.

This also applies when using [regional endpoints](container-registry-geo-replication#regional-endpoints-of-a-geo-replicated-registry-preview). A pull from a regional endpoint (`contoso.eastus.geo.azurecr.io`) redirects layer downloads to `contoso.eastus.data.azurecr.io` — never cross-region. This means your firewall rules can be scoped per region.

## Enable dedicated data endpoints

Note

If you previously configured client firewall access to the existing `*.blob.core.windows.net` endpoints, switching to dedicated data endpoints impacts client connectivity, causing pull failures. To ensure clients have consistent access, add the new data endpoint rules to the client firewall rules. Once completed, enable dedicated data endpoints for your registries using the Azure CLI or other tools.

During image pulls, if dedicated data endpoints are enabled, ACR gives the client a temporary download link each time it needs to fetch an image layer. This link points to the dedicated data endpoint and is valid for at least 20 minutes and up to 30 minutes, providing a secure, short-lived URL for downloading the layer. After the link expires, the client simply requests a new one if it needs to download another layer when pulling images.

You can enable dedicated data endpoints using the Azure portal or the Azure CLI. The data endpoints follow a regional pattern, `<registry-name>.<region>.data.azurecr.io`. In a geo-replicated registry, enabling data endpoints enables endpoints in all replica regions.

### Enable dedicated data endpoints using the Azure portal

1. Go to your container registry.
2. In the service menu, under **Settings**, select **Networking**.
3. In **Public access**, select the **Use dedicated data endpoint** checkbox.
4. Select **Save**.

You now see the data endpoints in the Azure portal.

### Enable dedicated data endpoints using the Azure CLI

```azurecli
az acr update --name myregistry --data-endpoint-enabled
```

To view the data endpoints, use the [az acr show-endpoints](/en-us/cli/azure/acr#az-acr-show-endpoints) command:

```azurecli
az acr show-endpoints --name myregistry
```

This example output shows the full endpoint schema, including dedicated data endpoints and regional endpoints (if enabled):

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

After you set up dedicated data endpoints for your registry, you can enable client firewall access rules for the data endpoints. Enable data endpoint access rules for all required registry regions. For more information, see [Configure rules to access an Azure container registry behind a firewall](container-registry-firewall-rules).

## Restricting network access to data endpoints

After enabling dedicated data endpoints, you can restrict how clients reach those endpoints. There are two approaches:

### Azure private endpoints (virtual network)

[Azure private endpoints](container-registry-private-endpoints) are the most secure way to control network access from clients in a virtual network to the registry. When private endpoints are configured, both the login server (global endpoint and regional endpoints) and data endpoints are accessible from within the virtual network using private IPs assigned to a private endpoint resource in the virtual network. Customers can also [disable public network access](container-registry-private-endpoints#disable-public-access-to-a-registry) on the registry, ensuring that dedicated data endpoints are only reachable through the private endpoint.

If a registry has at least one private endpoint configured, dedicated data endpoints are automatically enabled. For more information, see [Connect privately to a registry from a virtual network using private endpoints](container-registry-private-endpoints).

#### Private endpoint IP address considerations

Each private endpoint resource consumes private IP addresses from the virtual network subnet. Plan your subnet sizing accordingly:

- **1 IP** for the global endpoint (`myregistry.azurecr.io`)
- **1 IP per geo-replica** for dedicated data endpoints (`myregistry.<region>.data.azurecr.io`) — automatically enabled when a private endpoint is configured
- **1 IP per geo-replica** for regional endpoints (`myregistry.<region>.geo.azurecr.io`) — only if regional endpoints are enabled on the registry

For example, a registry with 3 geo-replicas and regional endpoints enabled requires 1 (global) + 3 (data) + 3 (regional) = **7 private IP addresses** per private endpoint resource. For more information, see [Connect privately to a registry from a virtual network using private endpoints](container-registry-private-endpoints).

### Client firewall rules

If private endpoints aren't an option, configure your client firewall rules to allow access to the dedicated data endpoints for each required registry region. For more information, see [Configure rules to access an Azure container registry behind a firewall](container-registry-firewall-rules).