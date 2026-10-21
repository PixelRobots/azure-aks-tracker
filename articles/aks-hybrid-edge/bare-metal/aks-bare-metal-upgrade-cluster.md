---
layout: Conceptual
title: Upgrade AKS on bare metal on Azure Linux (Preview) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/bare-metal/aks-bare-metal-upgrade-cluster
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
description: Upgrade the Kubernetes version for an AKS on bare metal cluster on Azure Linux by using the Azure portal.
ms.topic: how-to
ms.date: 2026-09-14T00:00:00.0000000Z
ai-usage: ai-assisted
author: SummerSmith
ms.author: sumsmith
ms.custom: bare-metal
locale: en-us
document_id: 6f2dbb84-c5bf-1a16-87ad-a5726c6945eb
document_version_independent_id: 5395cf7d-b575-a7b0-b548-7b585f14db4a
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/bare-metal/aks-bare-metal-upgrade-cluster.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/bare-metal/aks-bare-metal-upgrade-cluster
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/bare-metal/aks-bare-metal-upgrade-cluster.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 03ad57d1-858d-3378-36a1-456b239e50a9
---

# Upgrade AKS on bare metal on Azure Linux (Preview) | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

This article shows you how to upgrade the Kubernetes patch version for an AKS on bare metal cluster on Azure Linux by using the Azure portal. For Ubuntu, see [Upgrade an AKS on bare metal cluster on Ubuntu](aks-bare-metal-upgrade-cluster-ubuntu).

## Overview

AKS on bare metal supports in-place Kubernetes version upgrades. During an upgrade:

- The new Kubernetes binaries are downloaded to the host.
- The control plane components are upgraded.
- The node is cordoned, drained, and upgraded.
- Workloads are rescheduled after the upgrade completes.

Note

Since AKS on bare metal uses a single-node topology during public preview, **workloads are temporarily unavailable** during the upgrade process.

## Upgrade the cluster

1. Sign in to the [Azure portal](https://portal.azure.com).
2. Navigate to your Kubernetes cluster resource.
3. In the left menu, expand **Settings** and select **Cluster configuration**.

    [![Screenshot of the Cluster configuration option for your AKS on bare metal cluster.](../media/aks-bare-metal-upgrade-cluster/upgrade-cluster.png)](../media/aks-bare-metal-upgrade-cluster/upgrade-cluster.png#lightbox)
4. Under **Upgrade**, note your current Kubernetes version.
5. Select **Upgrade version**.
6. Select the target Kubernetes version and confirm.

The upgrade begins immediately. You can monitor the provisioning state on the cluster's **Overview** page.

## Supported upgrade paths

During public preview, the following Kubernetes versions are available:

| Version | Status |
| --- | --- |
| 1.34.2 | Supported. |
| 1.34.3 | Supported (latest). |

Note

You can only upgrade to a newer version. Downgrade isn't supported.

## Best practices

- **Schedule upgrades during maintenance windows**: The single-node topology means workloads are temporarily unavailable.
- **Back up critical workloads**: Use persistent storage backups before upgrading.
- **Test in a non-production cluster first**: If you have multiple clusters, upgrade the development cluster first.
- **Verify after upgrade**: Connect to the cluster and confirm the node version: `kubectl get nodes`.

## Troubleshooting

| Issue | Fix |
| --- | --- |
| Upgrade stuck in `Upgrading` state | Wait up to 30 minutes. If it doesn't complete, check Arc agent connectivity. |
| Pods not rescheduling after upgrade | Verify node is in `Ready` state: `kubectl get nodes`. |
| Target version not available | Check the supported upgrade paths table for available versions. |