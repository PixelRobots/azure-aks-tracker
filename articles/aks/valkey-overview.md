---
layout: Conceptual
title: Solution Overview for Deploying a Valkey Cluster on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/valkey-overview
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
description: In this article, we provide an overview of deploying a Valkey cluster on Azure Kubernetes Service (AKS) using the Kubernetes stateful framework.
ms.topic: overview
ms.date: 2025-09-15T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: stateful-workloads, aks-data-messaging
locale: en-us
document_id: 66c1324d-1eff-96a5-e7af-343bdbeac911
document_version_independent_id: 43f7e883-67f7-161a-c128-b352c9ec9280
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/valkey-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/valkey-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/valkey-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 195b8849-96ab-a73b-2dc0-39f914d515d2
---

# Solution Overview for Deploying a Valkey Cluster on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article summarizes the steps to deploy Valkey, an open source (BSD) high-performance key/value datastore, on Azure Kubernetes Service (AKS). The Valkey deployment focuses on leveraging replicas and availability zones for high availability and resilience. We also provide guidance to test the resilience of your Valkey deployment using the [Locust load testing framework](https://github.com/locustio/locust).

Important

Open-source software is mentioned throughout AKS documentation and samples. Software that you deploy is excluded from AKS service-level agreements, limited warranty, and Azure support. As you use open-source technology alongside AKS, consult the support options available from the respective communities and project maintainers to develop a plan.

Microsoft takes responsibility for building the open-source packages that we deploy on AKS. That responsibility includes having complete ownership of the build, scan, sign, validate, and hotfix process, along with control over the binaries in container images. For more information, see [Vulnerability management for AKS](concepts-vulnerability-management#aks-container-images) and [AKS support coverage](support-policies#aks-support-coverage).

## What is Valkey?

[Valkey](https://valkey.io/) is a fork of the [Redis project](https://redis.io/) that preserves its original open-source license. Valkey is a high performance database that supports a key-value datastore, and you can use it for caching, session storage, message queues, and more. A *Valkey cluster* has multiple nodes that are responsible for hosting your Valkey data stores. Valkey shards data into smaller portions and disperses it among the nodes. In a simplified Valkey cluster consisting of *three* primary nodes, a single replica node supports each node to enable basic failover capabilities. The data is distributed across the nodes, enabling the cluster to continue functioning even if one of the nodes fails.

![Architecture diagram of Valkey deployed on AKS with three primary nodes and one replica for each primary.](media/valkey-stateful-workload/valkey-cluster.png)

For more information, see the [Valkey documentation](https://valkey.io/docs/).

## Valkey solution overview

This solution deploys three Valkey primary pods across two availability zones with one replica pod per primary in a third zone, running on `Standard_E64_v5` SKU nodes. You create two distinct `StatefulSet` resources with `spec.affinity` rules that ensure zone distribution for high availability. You create one [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) for the Valkey primary pods and another for the replica pods.

Note

Note that the solution suggested in this article differs from the Valkey documentation, where cluster Pods belong to a single `StatefulSet`, and the `spec.affinity` only ensures that the Pods are placed on different nodes. The automatic Valkey cluster initialization presented in the Valkey documentation doesn't ensure that the primary and replica Pods for the same shard are placed in different availability zones.