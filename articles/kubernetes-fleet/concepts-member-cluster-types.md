---
layout: Conceptual
title: Azure Kubernetes Fleet Manager member cluster types | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/concepts-member-cluster-types
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
adobe-target: true
learn_banner_products:
- azure
description: This article provides a conceptual overview of the different types of member clusters supported in Azure Kubernetes Fleet Manager.
ms.date: 2026-09-24T00:00:00.0000000Z
author: Ealianis
ms.author: sehobbs
ms.service: azure-kubernetes-fleet-manager
ms.topic: concept-article
locale: en-us
document_id: e368012e-6420-bf4c-f034-38c41151ef8d
document_version_independent_id: b7dcb66d-3bce-6087-39ad-4987e4026360
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/concepts-member-cluster-types.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: kubernetes-fleet/concepts-member-cluster-types
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/concepts-member-cluster-types.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: c83e2fcd-d07b-ff91-2e89-ba009f45fef5
---

# Azure Kubernetes Fleet Manager member cluster types | Microsoft Learn

Azure Kubernetes Fleet Manager supports two types of member clusters:

- [Azure Kubernetes Service (AKS) clusters](/en-us/azure/aks/).
- [Arc-enabled Kubernetes clusters](/en-us/azure/azure-arc/kubernetes/overview).

The following table outlines which Azure Kubernetes Fleet Manager capabilities are supported for each member cluster type.

| Capability | AKS cluster | Arc-enabled Kubernetes cluster |
| --- | --- | --- |
| Kubernetes and node image updates | ✅ GA | ❌ Unsupported |
| Cross-cluster networking | ✅ Preview | ❌ Unsupported |
| Workload placement | ✅ GA | ✅ GA |
| DNS load balancing | ✅ GA | ❌ Unsupported |
| Managed Namespaces | ✅ GA | ❌ Unsupported |
| Managed Namespace RBAC | ✅ GA | ❌ Unsupported |
| Non-public Azure regions | ✅ GA | ❌ Unsupported |

## Arc-enabled Kubernetes clusters important considerations

Depending on your environment and configuration, certain limitations might apply when connecting an Arc-enabled Kubernetes cluster to an Azure Kubernetes Fleet Manager hub. Review the following considerations.

Note

When you delete an Azure Arc-enabled Kubernetes cluster without first removing it from Fleet Manager, the Fleet Manager member cluster resource remains active, even though the target cluster no longer exists. We expect to address this limitation in a future release.

### Cluster resource requirements

When you add an Arc-enabled Kubernetes cluster to Fleet Manager, the member cluster must meet the following conditions:

- At least **210 MB** memory and **2%** of one CPU core available.
- Reserve **3 pods** for the Azure Kubernetes Fleet Manager Arc extension agents.
- Create the **fleet-system** namespace for Fleet-related components and don't directly modify it.

### Private Fleet

For **Private Fleets**, configure your Arc-enabled Kubernetes cluster to use [Azure Arc Gateway](/en-us/azure/azure-arc/servers/arc-gateway).

### Networking

**TLS-terminating proxies aren't supported.** If you use a **passthrough proxy**, configure your Arc-enabled Kubernetes cluster to use [Azure Arc Gateway](/en-us/azure/azure-arc/servers/arc-gateway).

## Non-public region limitation

Fleet Manager Arc-enabled Kubernetes cluster support is available only in Azure public cloud regions due to the dependency on Azure Arc Gateway.

If you attempt to create an Arc-enabled member cluster in a non-public cloud region, you receive an error of type `FeatureNotAvailableInCloud` with the message `The feature 'Arc Member Cluster' is not available in cloud environment`.

Track the status of Azure Arc Gateway regional availability via its [official documentation](/en-us/azure/azure-arc/kubernetes/arc-gateway-simplify-networking).