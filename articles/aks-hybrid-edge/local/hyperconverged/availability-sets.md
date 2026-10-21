---
layout: Conceptual
title: Availability sets in AKS Hybrid and Edge | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/availability-sets
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
description: Learn how to enable availability sets in AKS to improve the availability and distribution of your Kubernetes workloads.
ms.topic: how-to
author: davidsmatlak
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.reviewer: rbaziwane
ms.lastreviewed: 2024-08-15T00:00:00.0000000Z
ms.custom: hyperconverged
locale: en-us
document_id: e79170e3-bdb9-0ace-1196-4c8992462dd3
document_version_independent_id: cea018be-b064-3412-45c5-f23f9b082abf
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/availability-sets.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/availability-sets
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/availability-sets.md
platformId: b1a9f5f7-5bb2-2202-6407-3594bfd42b81
---

# Availability sets in AKS Hybrid and Edge | Microsoft Learn

*Availability sets* are logical groups of VMs that have weak anti-affinity relationships with each other, to ensure that they are spread evenly across the available fault domains in a physical cluster. A fault domain in this context is a physical host or a group of physical hosts. By using availability sets, AKS can improve the availability and distribution of your Kubernetes workloads. Availability sets can avoid scenarios in which a single node failure can cause multiple VMs to go down or become unbalanced.

## Overview

Availability sets offer several benefits for AKS on Azure Local users, such as:

- Improves the availability and resilience of your applications by avoiding scenarios in which multiple VMs within the same node pool or control plane go down or become unbalanced due to a single node failure.
- Optimizes the resource usage and performance of your cluster by ensuring that VMs are evenly distributed across the available nodes and not concentrated on a single node or a subset of nodes.
- Aligns with the best practices and expectations of your customers and partners who are looking for a reliable and consistent on-premises Kubernetes experience.

## Enable availability sets

With AKS on Azure Local, the availability sets feature is enabled by default when you create a node pool. With AKS on Windows Server, you can enable the availability sets feature by adding the `-enableAvailabilitySet` parameter when you create an AKS cluster; for example, `New-AksHciCluster -Name <name> -controlPlaneNodeCount 3 -osType Linux -kubernetesVersion $kubernetesVersion -enableAvailabilitySet`.

## How availability sets work in AKS Hybrid and Edge

When you create a new AKS cluster, AKS automatically creates availability sets, one for the control plane VMs and another one for each of the node pools in the Kubernetes cluster. Each node pool has its own availability set. With this layout, AKS ensures that VMs of the same role (control plane or node pool) are never located on the same physical host and that they're distributed across the available nodes in a cluster.

Once the availability sets are created and the VMs assigned, the system automatically places them on the appropriate physical nodes. If a node fails, the system also automatically fails over the VMs to other nodes and rebalances them when the node recovers. This way, you can achieve high availability and optimal distribution of your Kubernetes workloads without manual intervention.

Consider an AKS on Azure Local cluster with two physical host machines, **Host A** and **Host B**, three control plane VMs, and two worker node VMs, **Nodepool1VM1** and **Nodepool1VM2**. To ensure high availability of your Kubernetes applications, the node pool VMs must never share the same host, unless one of the hosts is temporarily unavailable for planned maintenance or capacity issue, which can cause the VM (virtual machine) to be temporarily placed on an alternative host.

In the following diagram, each color represents an anti-affinity group: 

![Diagram showing hosts in anti-affinity group.](../../media/availability-sets/anti-affinity-1.png)

If **Host B** goes down due to a reboot, **Control Plane VM2**, **Control Plane VM3**, and **Nodepool1VM2** fail over to **Host A** as shown in the following figure. Assuming your application is running pods in **NodePoolVM1**, this reboot has no impact on your application:

![Diagram showing host B down.](../../media/availability-sets/anti-affinity-2.png)

In the old architecture, if **Host B** came back online after a reboot, there was no guarantee that the VMs would move back from Host A to Host B (rebalancing), thus forcing the workloads to stay on the same host, and create a single point of failure, as shown in the following diagram:

![Diagram showing no rebalancing.](../../media/availability-sets/anti-affinity-3.png)

Availability sets for AKS can help to rebalance VMs once a host recovers from temporary outage. In this example, **ControlPlaneVM2**, **ControlPlaneVM3**, and **Nodepool1VM2** automatically move to **Host B**, as shown here:

![Diagram showing hosts in anti-affinity group.](../../media/availability-sets/anti-affinity-1.png)

Important

Availability sets in AKS is a new feature that's still evolving and improving. We do not yet support manual configuration of the fault domains or availability sets. You can't change the fault domains of an availability set after it's created. VMs are assigned to an availability set at cluster creation, and can't be migrated to a different availability set.

## Add or delete machines

In a host deletion scenario, the host is no longer considered a part of the cluster. This deletion typically occurs when you replace a machine due to hardware issues, or scale down the Azure Local cluster for other reasons. During a node outage, the node remains part of the Azure Local cluster but appears as **Down**.

If a physical machine (fault domain) is permanently deleted from the cluster, the availability set configuration isn't modified to reduce the number of fault domains. In this scenario, the availability set enters an unhealthy state. We recommend that you redeploy your Kubernetes clusters so that the availability set is updated with the proper number of fault domains.

When a new physical machine (fault domain) is added to the cluster, the availability set configuration is automatically expanded to include the new machine. However, the existing VMs don't rebalance to apply this new configuration, since they are already assigned to availability sets. We recommend that you redeploy your Kubernetes clusters so that the availability set is updated with the proper number of fault domains.