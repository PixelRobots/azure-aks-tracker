---
layout: Conceptual
title: Azure Arc-enabled Kubernetes network requirements - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/network-requirements
breadcrumb_path: ../../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/146/azure-arc/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/5c778dec-0625-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: davidsmatlak
learn_banner_products:
- azure
ms.reviewer: davidsmatlak
ms.author: davidsmatlak
ms.service: azure-arc
ms.subservice: azure-arc-kubernetes
description: Learn about the networking requirements to connect Kubernetes clusters to Azure Arc.
ms.date: 2026-06-11T00:00:00.0000000Z
ms.topic: concept-article
ms.custom: references-regions
locale: en-us
document_id: 9a9f2669-b07d-0931-3950-9647f89f6bc6
document_version_independent_id: ea9b4182-1a9d-e7fd-12a4-f4135d3f41b5
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/network-requirements.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/network-requirements
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/network-requirements.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 795b6e69-e26a-e0f5-5d6e-9dc022aa272d
---

# Azure Arc-enabled Kubernetes network requirements - Azure Arc | Microsoft Learn

This topic describes the networking requirements for connecting a Kubernetes cluster to Azure Arc and supporting various Arc-enabled Kubernetes scenarios.

Tip

For the Azure public cloud, you can reduce the number of required endpoints by using the [Azure Arc gateway](arc-gateway-simplify-networking).

## Details

Generally, connectivity requirements include these principles:

- All connections are TCP unless otherwise specified.
- All HTTP connections use HTTPS and SSL/TLS with officially signed and verifiable certificates.
- All connections are outbound unless otherwise specified.

To use a proxy, verify that the agents and the machine performing the onboarding process meet the network requirements in this article.

# [Azure Cloud](#tab/azure-cloud)
Important

Azure Arc agents require the following outbound URLs on `https://:443` (unless otherwise noted). For `*.servicebus.windows.net`, websockets need to be enabled for outbound access on firewall and proxy.

| Endpoint (DNS) | Description |
| --- | --- |
| `https://management.azure.com` | Required for the agent to connect to Azure and register the cluster. |
| `https://<region>.dp.kubernetesconfiguration.azure.com` | Data plane endpoint for the agent to push status and fetch configuration information. |
| `https://login.microsoftonline.com``https://<region>.login.microsoft.com``login.windows.net` | Required to fetch and update Azure Resource Manager tokens. |
| `https://mcr.microsoft.com``https://*.data.mcr.microsoft.com` | Required to pull container images for Azure Arc agents. |
| `dl.k8s.io` | Required to download kubectl binaries during Azure Arc onboarding by Azure CLI [connectedk8s extension](/en-us/cli/azure/connectedk8s). |
| `https://gbl.his.arc.azure.com` | Required to get the regional endpoint for pulling system-assigned Managed Identity certificates. |
| `https://*.his.arc.azure.com` | Required to pull system-assigned Managed Identity certificates. |
| `guestnotificationservice.azure.com``*.guestnotificationservice.azure.com``sts.windows.net` | For [Cluster Connect](cluster-connect) and for [Custom Location](custom-locations) based scenarios. |
| `*.servicebus.windows.net` | For [Cluster Connect](cluster-connect) and for [Custom Location](custom-locations) based scenarios. |
| `https://graph.microsoft.com/` | Required when [Azure RBAC](azure-rbac) is configured. |
| `*.arc.azure.net` | Required to manage connected clusters in Azure portal. |
| `https://<region>.obo.arc.azure.com:8084/` | Required when [Cluster Connect](cluster-connect) and [Azure RBAC](azure-rbac) is configured. |
| `https://linuxgeneva-microsoft.azurecr.io` | Required if using [Azure Arc-enabled Kubernetes extensions](conceptual-extensions). |
| `gcs.prod.monitoring.core.windows.net``*.prod.microsoftmetrics.com``*.prod.hot.ingest.monitor.core.windows.net``*.prod.warm.ingest.monitor.core.windows.net` | Required if using [Azure IoT Operations](/en-us/azure/iot-operations/overview-iot-operations), [Azure Key Vault Secret Store extension (SSE)](secret-store-extension), or [Certificate Management for edge workloads connected with Azure Arc](cert-manager-overview). |

To translate the `*.servicebus.windows.net` wildcard into specific endpoints, use the command:

```rest
GET https://guestnotificationservice.azure.com/urls/allowlist?api-version=2020-01-01&location=<region>
```

To get the region segment of a regional endpoint, remove all spaces from the Azure region name. For example, *East US 2* region, the region name is `eastus2`.

For example: `*.<region>.arcdataservices.com` should be `*.eastus2.arcdataservices.com` in the East US 2 region.

To see a list of all regions, run this command:

```azurecli
az account list-locations -o table
```

```azurepowershell
Get-AzLocation | Format-Table
```

# [Azure Government](#tab/azure-government)
Important

Azure Arc agents require the following outbound URLs on `https://:443` to function. For `*.servicebus.usgovcloudapi.net`, websockets need to be enabled for outbound access on firewall and proxy.

| Endpoint (DNS) | Description |
| --- | --- |
| `https://management.usgovcloudapi.net` | Required for the agent to connect to Azure and register the cluster. |
| `https://<region>.dp.kubernetesconfiguration.azure.us` | Data plane endpoint for the agent to push status and fetch configuration information. |
| `https://login.microsoftonline.us``<region>.login.microsoftonline.us` | Required to fetch and update Azure Resource Manager tokens. |
| `https://mcr.microsoft.com``https://*.data.mcr.microsoft.com` | Required to pull container images for Azure Arc agents. |
| `https://gbl.his.arc.azure.us` | Required to get the regional endpoint for pulling system-assigned Managed Identity certificates. |
| `https://usgv.his.arc.azure.us` | Required to pull system-assigned Managed Identity certificates. |
| `guestnotificationservice.azure.us``*.guestnotificationservice.azure.us``sts.windows.net` | For [Cluster Connect](cluster-connect) and for [Custom Location](custom-locations) based scenarios. |
| `*.servicebus.usgovcloudapi.net` | For [Cluster Connect](cluster-connect) and for [Custom Location](custom-locations) based scenarios. |
| `https://graph.microsoft.com/` | Required when [Azure RBAC](azure-rbac) is configured. |
| `https://usgovvirginia.obo.arc.azure.us:8084/` | Required when [Cluster Connect](cluster-connect) is configured. |

To translate the `*.servicebus.usgovcloudapi.net` wildcard into specific endpoints, use the command:

```rest
GET https://guestnotificationservice.azure.us/urls/allowlist?api-version=2020-01-01&location=<region>
```

To get the region segment of a regional endpoint, remove all spaces from the Azure region name. For example, *East US 2* region, the region name is `eastus2`.

For example: `*.<region>.arcdataservices.com` should be `*.eastus2.arcdataservices.com` in the East US 2 region.

To see a list of all regions, run this command:

```azurecli
az account list-locations -o table
```

```azurepowershell
Get-AzLocation | Format-Table
```

# [Microsoft Azure operated by 21Vianet](#tab/azure-china)
Important

Azure Arc agents require the following outbound URLs on `https://:443` to function. For `*.servicebus.chinacloudapi.cn`, websockets need to be enabled for outbound access on firewall and proxy.

| Endpoint (DNS) | Description |
| --- | --- |
| `https://management.chinacloudapi.cn` | Required for the agent to connect to Azure and register the cluster. |
| `https://<region>.dp.kubernetesconfiguration.azure.cn` | Data plane endpoint for the agent to push status and fetch configuration information. |
| `https://login.chinacloudapi.cn``https://<region>.login.chinacloudapi.cn``login.partner.microsoftonline.cn` | Required to fetch and update Azure Resource Manager tokens. |
| `mcr.azk8s.cn` | Required to pull container images for Azure Arc agents. |
| `https://gbl.his.arc.azure.cn` | Required to get the regional endpoint for pulling system-assigned Managed Identity certificates. |
| `https://*.his.arc.azure.cn` | Required to pull system-assigned Managed Identity certificates. |
| `guestnotificationservice.azure.cn``*.guestnotificationservice.azure.cn``sts.chinacloudapi.cn` | For [Cluster Connect](cluster-connect) and for [Custom Location](custom-locations) based scenarios. |
| `*.servicebus.chinacloudapi.cn` | For [Cluster Connect](cluster-connect) and for [Custom Location](custom-locations) based scenarios. |
| `https://graph.chinacloudapi.cn/` | Required when [Azure RBAC](azure-rbac) is configured. |
| `*.arc.azure.cn` | Required to manage connected clusters in Azure portal. |
| `https://<region>.obo.arc.azure.cn:8084/` | Required when [Cluster Connect](cluster-connect) is configured. |
| `quay.azk8s.cn``registryk8s.azk8s.cn``k8sgcr.azk8s.cn``usgcr.azk8s.cn``dockerhub.azk8s.cn/<repo-name>/<image-name>:<version>` | Container registry proxy servers for Azure China VMs. |

---

## Additional endpoints

Depending on your scenario, you may need connectivity to other URLs, such as those used by the Azure portal, management tools, or other Azure services. In particular, review these lists to ensure that you allow connectivity to any necessary endpoints:

- [Azure portal URLs](../../azure-portal/azure-portal-safelist-urls)
- [Azure CLI endpoints for proxy bypass](/en-us/cli/azure/azure-cli-endpoints)

For a complete list of network requirements for Azure Arc features and Azure Arc-enabled services, see [Azure Arc network requirements](../network-requirements-consolidated).