---
layout: Conceptual
title: Node Image Updates for Node Auto-Provisioning (NAP) in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/node-auto-provisioning-upgrade-image
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
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn about node image updates for NAP in AKS, including how it works, recommended maintenance windows, and examples to get started.
ai-usage: ai-assisted
ms.topic: overview
ms.custom: devx-track-azurecli
ms.date: 2026-10-01T00:00:00.0000000Z
ms.author: wilsondarko
author: wdarko1
locale: en-us
document_id: 7157bd62-1f5b-dab3-f9bb-e7c6d61f4195
document_version_independent_id: 78b595f3-7ab9-be86-100d-38366feaae55
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/node-auto-provisioning-upgrade-image.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/node-auto-provisioning-upgrade-image
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/node-auto-provisioning-upgrade-image.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
platformId: 3c505b77-f641-ce33-2845-35c068b52740
---

# Node Image Updates for Node Auto-Provisioning (NAP) in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article provides an overview of node image updates for node auto-provisioning (NAP) in Azure Kubernetes Service (AKS), including how it works, recommended maintenance windows, and examples to get started.

You can control when node image updates in NAP happen and the amount of disruption by using three main components:

- Azure-based node OS maintenance windows
- Pod disruption budgets
- Karpenter node-level disruption budgets

## How do node image updates work for node auto-provisioning nodes?

By default, NAP node pool virtual machines (VMs) are automatically updated when a new image version is available. You can configure an AKS-managed node operating system (OS) upgrade schedule maintenance window to control when new images are picked up and applied to your NAP nodes, or use Karpenter Node Disruption Budgets and Pod Disruption Budgets to control how and when disruption occurs during upgrades.

When you omit `spec.versions`, nodes use the observed AKS control-plane Kubernetes version, and the provider automatically resolves compatible node images. When the provider detects a control-plane Kubernetes version upgrade, it marks node images as not ready and resolves images for that Kubernetes version. The provider doesn't currently automatically downgrade node Kubernetes versions.

### Pin node image and Kubernetes version

NAP supports pinning the latest node image version and supported Kubernetes versions for NAP-managed nodes via the `spec.versions` field in the `AKSNodeClass` custom resource. The latest node image version can be pinned until its Kubernetes version is no longer supported (or not in Long-Term Support). When a pinned node image's Kubernetes version is no longer supported, the node image automatically updates to the next available supported node image version.

To pin Kubernetes or node image versions in NAP, see [Configure `AKSNodeClass` version settings](node-auto-provisioning-aksnodeclass#kubernetes-and-node-image-versions).

## Node OS upgrade maintenance windows for NAP

Use the [AKS planned maintenance feature](planned-maintenance) with a [node OS auto-upgrade channel](auto-upgrade-node-os-image) to configure an `aksManagedNodeOSUpgradeSchedule` maintenance window. This window controls when to perform node OS security patching scheduled by your designated node OS auto-upgrade channel.

### Node OS upgrade maintenance window behavior and considerations

Keep the following information in mind when configuring a node OS upgrade maintenance window for NAP:

- The `aksManagedNodeOSUpgradeSchedule` maintenance window gates routine automatic node image roll-forward. This configuration doesn't necessarily determine when existing nodes are disrupted.
- The upgrade mechanism and decision criteria are specific to NAP/Karpenter and are evaluated by NAP's drift logic. NAP respects Karpenter Node Disruption Budgets and Pod Disruption Budgets. For more information about drift, see the [NAP Drift documentation](node-auto-provisioning-disruption#drift).
- The maintenance window doesn't defer required image initialization, image pin changes or removal, or image refreshes associated with Kubernetes version changes.
- These NAP upgrade decisions are separate from the cluster `NodeImage` and `SecurityPatch` channels.
- We recommend using a maintenance window of four hours or more for reliable operation.
- If the provider doesn't find upcoming maintenance-window data, it treats the window as open. Routine image roll-forward can therefore happen outside an explicitly configured window.
- Allow at least 30 minutes between creating or updating a maintenance configuration and the scheduled start time to ensure AKS has time to reconcile the new configuration.

### Recommended schedule pattern for NAP-managed nodes

We recommend the following schedule pattern for NAP-managed nodes:

- **Weekly cadence**: Recommended for routine node image roll outs (for example: *Every week on Sunday*).

For complete details, examples, and advanced scenarios, see [Use Planned Maintenance to schedule maintenance windows for your AKS cluster](planned-maintenance).

## Karpenter Node Disruption Budgets and Pod Disruption Budgets for NAP

In addition to AKS specific maintenance window controls, use node-level and pod-level disruption budgets to control when and where updates happen. For more information on configuring Karpenter Node Disruption Budgets and Pod Disruption Budgets for NAP, see the following articles:

- [Node Auto-Provisioning disruption documentation](node-auto-provisioning-disruption#disruption-budgets)
- [AKS scheduling best practice documentation](operator-best-practices-scheduler#limit-disruption-impact-by-using-pod-disruption-budgets-pdbs)
- [Pod-level controls for disruption](https://karpenter.sh/docs/concepts/disruption/#pod-level-controls)