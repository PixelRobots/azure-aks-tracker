---
layout: Conceptual
title: Application availability in AKS on Windows Server | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/app-availability
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
description: Learn about application availability in on Windows Server.
author: davidsmatlak
ms.topic: concept-article
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-01-14T00:00:00.0000000Z
ms.reviewer: rbaziwane
ms.custom: windows-server
locale: en-us
document_id: db2ad323-a2f2-582f-a002-e5c7fc6d3961
document_version_independent_id: 27a97687-8926-c23e-46aa-3cb516d93970
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/app-availability.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/app-availability
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/app-availability.md
platformId: 49e7deff-acb0-4cc6-322e-11414c12e104
---

# Application availability in AKS on Windows Server | Microsoft Learn

> 
> Applies to: AKS on Windows Server

Azure Kubernetes Service (AKS) on Windows Server offers a fully supported container platform that can run cloud-native applications on the [Kubernetes container orchestration platform](https://kubernetes.io/). The architecture supports running virtualized Windows and Linux workloads.

The AKS architecture is built with failover clustering and live migration that is automatically enabled for target (workload) clusters. During various disruption events, virtual machines that host customer workloads are freely moved around without perceived application downtime. This architecture means that a traditional enterprise customer, who's managing a legacy application as a singleton to AKS on Windows Server, gets similar (or better) uptime than what's currently experienced on a legacy VM application.

This article describes some fundamental concepts for users who want to run containerized applications on AKS with live migration enabled in order to ensure applications are available during a disruption. Kubernetes terminology, such as *voluntary disruption* and *involuntary disruption*, is used to refer to downtime of an application running in a pod.

## What is live migration?

[*Live migration*](/en-us/windows-server/virtualization/hyper-v/manage/live-migration-overview) is a Hyper-V feature that allows you to transparently move running virtual machines from one Hyper-V host to another without perceived downtime. The primary benefit of live migration is flexibility; running virtual machines is not tied to a single host machine. This allows users to perform actions such as draining a specific host of virtual machines before decommissioning or upgrading the host. When paired with Windows Failover Clustering, live migration enables the creation of highly available and fault tolerant systems.

The current architecture of AKS on Windows Server assumes that you enabled live migration in your Windows Server clustered environment. Therefore, all Kubernetes worker node VMs are created with live migration configured. These nodes can be moved around physical hosts in the event of a disruption to ensure the platform is highly available.

[![Diagram showing AKS on Windows Server with Failover Clustering enabled.](../media/app-availability/cluster-architecture.png)](../media/app-availability/cluster-architecture.png#lightbox)

When you run a legacy application as a singleton on top of Kubernetes, this architecture meets your high availability needs. Kubernetes manages the scheduling of pods on available worker nodes while live migration manages the scheduling of worker node VMs on available physical hosts.

[![Diagram showing an example legacy application running as a singleton.](../media/app-availability/singleton.png)](../media/app-availability/singleton.png#lightbox)

## Application disruption scenarios

A comparative study of the recovery times for applications running in VMs on AKS on Windows Server clearly shows that there is minimal impact on the application when common disruption events occur. Three example disruption scenarios include:

- Applying an update that results in a reboot of the physical machine.
- Applying an update that involves recreating the worker node.
- Unplanned hardware failure of a physical machine.

Note

These scenarios assume that the application owner still uses Kubernetes affinity and anti-affinity settings to ensure proper scheduling of pods across worker nodes.

| Disruption event | Running applications in VMs on Windows Server |
| --- | --- |
| Apply an update that results in a reboot of the physical machine | No impact |
| Apply an update that involves recreating the worker node (or rebooting the VM) | Varies |
| Unplanned hardware failure of a physical machine | 6-8 minutes |

### Apply an update that results in a reboot of the physical machine

During a physical host maintenance event, such as applying an update that results in the reboot of a host machine, no impact is expected for applications running in the cluster. The cluster administrator drains the host and ensures that all VMs are live migrated before applying the update.

### Apply an update that involves recreating the worker node

This scenario involves bringing down a worker node VM to perform routine maintenance. To prepare for the update, the cluster administrator drains and isolates the node, so that all pods are evicted to an available worker node before applying updates. Once the update is completed, the worker node is rejoined and made available for scheduling.

Note

The availability of an application varies, as it includes the time it takes to download the base container image, especially for larger images stored in the public cloud. Therefore, it's recommended that you use small base container images, and for Windows containers, it's recommended that you use the `nano server` base image.

### Unplanned hardware failure of a physical machine

In this scenario, an involuntary disruption event occurs to a physical machine hosting a legacy application container/pod in one of the worker node VMs. Failover clustering places the host in an isolated state, and then after a period of 6 to 8 minutes, starts the process of live migrating these VMs to surviving hosts. In this case, the application downtime is the equivalent of the time it takes to restart the host and worker node VMs.

## Conclusion

AKS failover clustering technologies are designed to ensure that computing environments in Windows Server are highly available and fault tolerant. However, the application owner still has to configure deployments to use Kubernetes features, such as `Deployments`, `Affinity Mapping`, `RelicaSets`, to ensure that the pods are resilient in disruption scenarios.