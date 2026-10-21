---
layout: Conceptual
title: Azure Arc-enabled Kubernetes connectivity modes - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/conceptual-connectivity-modes
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
ms.date: 2026-09-14T00:00:00.0000000Z
ms.topic: concept-article
description: This article provides an overview of the connectivity modes supported by Azure Arc-enabled Kubernetes
locale: en-us
document_id: 8f55f6ba-b30e-1e22-a396-6cfce495daa0
document_version_independent_id: a3f5deb5-d9f9-6024-b510-4bb008d5630a
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/conceptual-connectivity-modes.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/conceptual-connectivity-modes
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/conceptual-connectivity-modes.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
platformId: 7e49a522-1c76-5293-1ab2-e1f62a38fa66
---

# Azure Arc-enabled Kubernetes connectivity modes - Azure Arc | Microsoft Learn

Azure Arc-enabled Kubernetes requires deployment of Azure Arc agents on your Kubernetes clusters so that capabilities such as [configurations (GitOps)](conceptual-gitops-flux2), extensions, [cluster connect](conceptual-cluster-connect), and [custom location](conceptual-custom-locations) are made available on the cluster. Because Kubernetes clusters deployed on the edge might not have constant network connectivity, the agents might not always be able to reach the Azure Arc services while in a semi-connected mode.

## Understand connectivity modes

When you work with Azure Arc-enabled Kubernetes clusters, it's important to understand how network connectivity modes impact your operations.

- **Fully connected**: With ongoing network connectivity, agents can consistently communicate with Azure. In this mode, there's typically little delay with tasks such as propagating GitOps configurations, enforcing Azure Policy and Gatekeeper policies, or collecting workload metrics and logs in Azure Monitor.
- **Semi-connected**: Azure Arc agents can pull desired state specification from the Arc services, then later realize this state on the cluster.

    Important

    The managed identity certificate that the `clusteridentityoperator` pulls down is valid for up to 90 days before it expires. The agents try to renew the certificate during this time period; however, if there's no network connectivity, the certificate might expire, and the Azure Arc-enabled Kubernetes resource stops working. Because of this condition, ensure that the connected cluster has network connectivity at least once every 30 days. If the certificate expires, you need to delete and then recreate the Azure Arc-enabled Kubernetes resource and agents to reactivate Azure Arc features on the cluster.
- **Disconnected**: Kubernetes clusters in disconnected environments that can't access Azure aren't currently supported by Azure Arc-enabled Kubernetes.

## Connectivity status

The connectivity status of a cluster is determined by the time of the latest heartbeat received from the Arc agents deployed on the cluster:

| Status | Description |
| --- | --- |
| Connecting | The Azure Arc-enabled Kubernetes resource was created in Azure, but the service didn't receive the agent heartbeat yet. |
| Connected | The Azure Arc-enabled Kubernetes service received an agent heartbeat within the previous 15 minutes. |
| Offline | The Azure Arc-enabled Kubernetes resource was previously connected, but the service didn't receive any agent heartbeat for at least 15 minutes. |
| Expired | The managed identity certificate of the cluster expired. In this state, Azure Arc features no longer work on the cluster. For more information about how to address expired Azure Arc-enabled Kubernetes resources, see the [FAQ](faq#how-do-i-address-expired-azure-arc-enabled-kubernetes-resources). |