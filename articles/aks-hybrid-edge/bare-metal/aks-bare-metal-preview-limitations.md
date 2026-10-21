---
layout: Conceptual
title: Public preview limitations for AKS on bare metal (preview) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/bare-metal/aks-bare-metal-preview-limitations
breadcrumb_path: /azure/breadcrumb/azure-aks/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/200/azure-kubernetes-service/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
learn_banner_products:
- azure
ms.service: azure-kubernetes-service-hybrid
description: Known limitations and scope for the Azure Kubernetes Service on bare metal public preview.
ms.topic: concept-article
ms.date: 2026-09-14T00:00:00.0000000Z
ai-usage: ai-assisted
author: SummerSmith
ms.author: sumsmith
ms.custom: bare-metal
locale: en-us
document_id: 1e9a44b5-e3f8-2b0c-dcb3-dd1f7634f975
document_version_independent_id: 5703bc78-7684-f99d-2d5c-5f29c952b5b9
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/bare-metal/aks-bare-metal-preview-limitations.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/bare-metal/aks-bare-metal-preview-limitations
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/bare-metal/aks-bare-metal-preview-limitations.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 286cf052-a383-8c66-4595-046c69e8cd9f
---

# Public preview limitations for AKS on bare metal (preview) | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

This article lists the known limitations and scope boundaries for the AKS on bare metal public preview.

## Supported scope

| Area | Azure Linux | Ubuntu |
| --- | --- | --- |
| **Host infrastructure** | Validated Azure Local small form factor hardware. | Customer-provided hardware that meets the published requirements. |
| **Host operating system** | Azure Linux 3.0. | Ubuntu 24.04.3 LTS or 24.04.4 LTS. |
| **Processor architecture** | x86\_64. | x86\_64. |
| **Cluster topology** | Single-node cluster. | Single-node cluster, with one cluster per host. |
| **Kubernetes version** | Kubernetes 1.34. | Kubernetes 1.35.5 by default. See [Supported Kubernetes versions](aks-bare-metal-create-cluster-ubuntu-cli#supported-kubernetes-versions) for the versions available during deployment. |
| **Cluster creation** | Azure portal, Azure Resource Manager template, or Bicep. | Azure CLI |
| **Patch-version upgrades** | Azure portal. | Azure CLI. |
| **Cluster deletion** | Ordered Azure resource deletion. | Use Azure CLI for structured deletion of cluster and dependent resources. |
| **Portal experience** | Cluster creation, status, and patch-version upgrades. | Read-only cluster status. |
| **Cluster access** | `az connectedk8s proxy`. | `az connectedk8s proxy` or `az aksarc get-credentials`. |
| **Container networking** | Cilium CNI. | Cilium CNI. |

## Known limitations

| Limitation | Azure Linux | Ubuntu |
| --- | --- | --- |
| **Multi-node clusters and scaling** | Not supported. | Not supported. |
| **Multiple clusters per host** | Not supported. | Not supported. |
| **Region** | East US only. | East US only. |
| **Kubernetes upgrades** | Patch-version upgrades only. | Patch-version upgrades only. |
| **Cluster creation through the Azure portal** | Supported. | Not supported. Use Azure CLI. |
| **Cluster creation with ARM or Bicep** | Supported. | Not supported. Use Azure CLI. |
| **Host OS lifecycle** | Use the Azure Local platform lifecycle. | Customer-managed. |

### Ubuntu 24.04.5 LTS isn't supported yet

AKS on bare metal doesn't currently support Ubuntu 24.04.5 LTS. Support is planned for a future update. Until support is available, use Ubuntu 24.04.3 LTS or 24.04.4 LTS.

## Transition to general availability

Important

Clusters you create during the public preview might not support an in-place upgrade to the generally available version. When general availability is released, you might need to delete and recreate your cluster. Plan to back up and redeploy your workloads.

## Billing

AKS on bare metal public preview uses **zero-rated billing meters**. There are no charges for the AKS cluster resources during the preview period. Standard Azure charges for the underlying Arc-enabled machine and any Azure services (Monitor, Policy, and so on) still apply.

## Support

Customer support provides **best-effort** assistance for public preview features. Preview features:

- Aren't recommended for production workloads.
- Might have limited or no SLA.
- Might introduce breaking changes before GA.
- Might be deprecated or removed.