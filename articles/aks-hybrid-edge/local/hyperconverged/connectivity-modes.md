---
layout: Conceptual
title: Connectivity modes in AKS on Azure Local | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/connectivity-modes
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
description: Learn about running AKS on Azure Local in disconnected and semi-connected mode.
ms.topic: overview
ms.date: 2026-09-01T00:00:00.0000000Z
author: davidsmatlak
ms.author: davidsmatlak
ms.reviewer: srikantsarwa
ms.lastreviewed: 2025-04-08T00:00:00.0000000Z
ms.custom: conceptual, hyperconverged
locale: en-us
document_id: b6899ef6-eac0-ff3e-0caf-d1fd9939026c
document_version_independent_id: 1bdeb56b-4bb3-5166-2556-6a8bfe9b96ae
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/connectivity-modes.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/connectivity-modes
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/connectivity-modes.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/289b8734-3abd-4162-bc19-e661c3f4c940
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/6a94795e-9024-410d-b38e-b67941440893
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 06babab1-7ec6-db4d-bf88-aa7a688292b2
---

# Connectivity modes in AKS on Azure Local | Microsoft Learn

Note

This article describes the connectivity states of a standard, cloud-connected AKS on Azure Local cluster. It's not the same as [disconnected operations](../disconnected-operations/overview), which is a distinct Azure Local deployment mode with its own local control plane for running AKS without any connection to the Azure public cloud.

AKS on Azure Local requires connectivity to Azure in order to use features such as Kubernetes cluster upgrades, and identity and access options such as Azure Entra ID. Also, Azure Arc agents on the AKS cluster must remain connected to enable functionality such as [configuring (GitOps)](/en-us/azure/azure-arc/kubernetes/conceptual-gitops-flux2), Arc extensions, and [cluster connect](/en-us/azure/azure-arc/kubernetes/conceptual-cluster-connect). Since AKS on Azure Local clusters deployed at the edge might not always have stable network access, the Kubernetes cluster might occasionally be unable to reach Azure when it operates in a semi-connected state.

## Understand connectivity modes

When working with AKS on Azure Local clusters, it's important to understand how network connectivity modes impact your operations.

- **Fully connected**: With ongoing network connectivity, AKS and Arc agents can consistently communicate with Azure. In this mode, there is typically little delay with tasks such as scaling out your AKS cluster, upgrading the Kubernetes version, propagating GitOps configurations, enforcing Azure Policy and Gatekeeper policies, or collecting workload metrics and logs in Azure Monitor.
- **Semi-connected**: Refers to a temporary loss of connectivity with Azure, which is supported for a duration of up to 30 days. This constraint is due to the 30-day validity period of certificates managed by AKS on Azure Local. If network connectivity is not restored within this timeframe, the AKS cluster may cease to function. To maintain cluster operability, it is recommended that the AKS cluster establish connectivity with Azure at least once every 30 days. Failure to do so may result in certificate expiration, requiring the cluster to be deleted and redeployed.
- **Disconnected**: We currently do not support running AKS on Azure Local in a disconnected environment beyond 30 days.

## Impact of semi-connected mode (temporary disconnection) on AKS on Azure Local operations

The connectivity status of a cluster is determined by the time of the latest heartbeat received from the Azure Arc agents deployed on the cluster.

| AKS operation | Impact of temporary disconnection | Details | Workaround |
| --- | --- | --- | --- |
| Creating, updating, upgrading, and deleting Kubernetes clusters | Not supported | Since Kubernetes CRUD operations are driven by Azure, you can't perform any CRUD operations while disconnected. | No supported workaround. |
| Scaling the Kubernetes cluster | Partially supported | You can't manually scale an existing nodepool or add a new nodepool to the Kubernetes cluster. | Your Kubernetes cluster scales dynamically if you [enabled autoscalar](auto-scale-aks-arc) while creating the Kubernetes cluster. |
| Access the Kubernetes cluster | Partially supported | You can't use [Azure Entra](enable-authentication-microsoft-entra-id) and `az connectedk8s proxy`, since they require connectivity to Azure. | [Retrieve admin kubeconfig](retrieve-admin-kubeconfig) to access the Kubernetes cluster. |
| Viewing Kubernetes cluster status | Partially supported | You can't use the Azure portal or Azure Resource Manager APIs to view Kubernetes cluster status. | Use local tools such as [kubectl get](https://kubernetes.io/docs/reference/kubectl/quick-reference/#viewing-and-finding-resources). |
| MetalLB Arc extension | Partially supported | Your load balancer continues working but you can't add or remove IP pools or update MetalLB configuration. | No supported workaround. |
| AKS cluster and application observability | Partially supported | You can't use Container Insights and [create diagnostic settings using Container Insights](kubernetes-monitor-audit-events#create-a-diagnostic-setting), since they require connectivity to Azure. | Use [3rd party on-premises monitoring solutions](aks-monitor-logging). |
| SSH into the Kubernetes VMs | Supported | You can SSH into Kubernetes VMs. | No workaround needed. |
| Collect logs for troubleshooting | Supported | You can collect logs for troubleshooting issues. | No workaround needed. |