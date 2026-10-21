---
layout: Conceptual
title: Impact to AKS clusters when Azure Arc resource bridge is deleted or recovered | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/azure-arc-resource-bridge-deleted-recovered
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
description: Learn what happens to AKS clusters on Azure Local when the Azure Arc resource bridge is deleted, becomes unavailable, or is recovered, and how to plan for recovery.
ms.topic: troubleshooting
author: davidsmatlak
ms.author: davidsmatlak
ms.date: 2026-09-11T00:00:00.0000000Z
ms.custom: hyperconverged
locale: en-us
document_id: df3a1d83-24b4-1286-999b-9e42f2462794
document_version_independent_id: 8f15417c-f844-2ba9-2186-640502447638
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/azure-arc-resource-bridge-deleted-recovered.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/azure-arc-resource-bridge-deleted-recovered
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/azure-arc-resource-bridge-deleted-recovered.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
platformId: 19bbdda2-d5fe-c50a-c52d-57a08a403823
---

# Impact to AKS clusters when Azure Arc resource bridge is deleted or recovered | Microsoft Learn

This article describes what happens to existing AKS clusters on Azure Local when the Azure Arc resource bridge (ARB) is deleted, goes offline, or is recovered. It also describes the support boundaries you should be aware of when planning for this scenario.

## Overview

The Azure Arc resource bridge hosts the management components that Azure uses to create, update, and delete AKS clusters on Azure Local. If ARB is deleted or becomes unavailable, it doesn't automatically delete your existing AKS control-plane VMs, worker VMs, or their running workloads. These resources can continue running temporarily.

However, ARB also hosts the management state that Azure uses to operate and repair those clusters going forward. If a new ARB is deployed without restoring that management state, your existing clusters aren't automatically rediscovered or adopted by the new ARB. In that situation, the clusters are considered **orphaned**: they might still be running, but Azure can no longer manage, repair, or reliably report on them.

Unless Microsoft Support validates and completes a recovery process that restores your original management state, you should plan to:

1. Preserve your application data.
2. Work with Microsoft Support to clean up the orphaned cluster resources.
3. Recreate the AKS clusters.
4. Restore your applications and data to the new clusters.

## What to expect in common scenarios

| Scenario | Effect on your running workloads | Effect on cluster management |
| --- | --- | --- |
| Only the Azure resource bridge's Azure resource (its "connection" to Azure) is removed, and the underlying appliance is intact | No effect | Can typically be recreated using the standard resource bridge recovery process |
| The resource bridge appliance itself is offline or deleted, but your Azure Local infrastructure and storage are intact | Existing workloads can continue running | Azure-driven operations, such as create, upgrade, scale, and delete, aren't available until ARB is restored |
| A new resource bridge is deployed with a fresh, empty management state | Existing VMs might keep running, but aren't automatically reconnected | Cluster management components are missing until explicitly restored by Microsoft Support |
| Underlying Azure Local infrastructure, storage, or virtual hard disks are removed | Workloads can stop, and data can be lost | Full cleanup and cluster/application recreation is generally required |
| A validated recovery restores the original management state | Existing clusters might be preserved | Must be explicitly confirmed by Microsoft Support; don't assume this outcome without confirmation |

## Why running workloads can be temporarily unaffected, but aren't fully supported

Many day-to-day Kubernetes functions, such as an already-scheduled pod continuing to run, don't require ARB to be present at that exact moment. Because of this, you might not notice an immediate impact after ARB is deleted or goes offline.

However, several important functions do depend on ARB and the Azure Local management components it hosts:

- **Creating, updating, scaling, or deleting clusters** through Azure.
- **Replacing a failed node** or expanding cluster capacity.
- **Recovering a control plane** if it experiences problems, since some encryption and identity operations require the underlying management connection to remain healthy.
- **Attaching or moving persistent storage** to a different node, such as when a pod is rescheduled.
- **Certificate renewal** for cluster components, since AKS-managed certificates require periodic Azure connectivity to stay current.

Because of these dependencies, a cluster that appears healthy right after ARB is deleted can still stop working later if any of these events occur before recovery is complete.

## There's no guaranteed grace period

There's no supported grace period that guarantees your clusters will keep running after ARB is deleted or becomes unavailable.

Two separate, unrelated support limits are sometimes confused with a grace period for this scenario, but neither applies here:

- AKS on Azure Local supports temporary disconnection from Azure for up to **30 days**, based on the validity period of AKS-managed certificates. This limit applies to general Azure connectivity loss, not specifically to ARB deletion, and the documentation notes that clusters might stop working and require redeployment if connectivity isn't restored in time.
- The Azure Arc resource bridge itself shouldn't remain offline for more than **45 days**, due to a security key expiration on the appliance.

Neither of these numbers should be treated as a promise that your clusters will keep running for that long after ARB is deleted. A node failure, pod rescheduling, control-plane restart, storage operation, or certificate expiration can affect your workloads at any time while ARB is unavailable.

For more information, see [Connectivity modes in AKS on Azure Local](connectivity-modes) and [Azure Arc resource bridge maintenance and recovery](/en-us/azure/azure-arc/resource-bridge/maintenance).

## Recommended actions

If you know that ARB will be deleted, replaced, or is otherwise unavailable, take the following steps:

1. **Don't assume your existing clusters are automatically restored** by a newly deployed resource bridge. Treat this as something that must be explicitly confirmed by Microsoft Support before you rely on it.
2. **Engage Microsoft Support as early as possible** if ARB is deleted unexpectedly or if you're planning a resource bridge recovery, so that a validated recovery path can be assessed for your environment.
3. **Back up your application data and configuration**before any planned resource bridge maintenance, including:
    - Application manifests or your GitOps source of truth.
    - Persistent volume data and any application-consistent backups for stateful workloads.
    - Any external DNS, Azure Load Balancer, ingress, or certificate configuration your applications depend on.
4. **Plan for cluster recreation** as the expected outcome unless Microsoft Support confirms that the existing management state was successfully restored and validated.
5. **Don't delete Azure Local infrastructure, storage, or virtual hard disks** associated with your clusters just because ARB is offline. These resources might contain your only copy of running workload data, and Microsoft Support might need them to help restore your environment.