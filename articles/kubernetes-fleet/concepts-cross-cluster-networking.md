---
layout: Conceptual
title: Cross-cluster networking for Azure Kubernetes Fleet Manager | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/concepts-cross-cluster-networking
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
description: This article provides a conceptual overview of Cross-cluster networking for Azure Kubernetes Fleet Manager.
ms.date: 2026-05-14T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
ms.topic: concept-article
locale: en-us
document_id: 5b27272d-130a-7bac-611d-7982170f3710
document_version_independent_id: c1142716-f975-81f0-6101-da6814690347
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/concepts-cross-cluster-networking.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: kubernetes-fleet/concepts-cross-cluster-networking
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/concepts-cross-cluster-networking.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 1c8e7f75-6c25-fc43-a1bb-113b6028fe12
---

# Cross-cluster networking for Azure Kubernetes Fleet Manager | Microsoft Learn

**Applies to**: ✔️ Fleet Manager ✔️ Fleet Manager with hub cluster

Azure Kubernetes Fleet Manager provides a dedicated cross-cluster networking solution that extends the Kubernetes datapath across multiple clusters. Using cross-cluster networking enables any connected cluster to communicate directly with endpoints on any other connected cluster with full network‑policy enforcement. Using cross-cluster networking allowing clusters to publish services such that any connected cluster can call them as if they were local.

Multiple cross-cluster network profiles can be created in Fleet Manager, with the only restriction being that member clusters can only participate in a single cross-cluster network.

In this article, we introduce key concepts for cross-cluster networking for Azure Kubernetes Fleet Manager.

Important

Azure Kubernetes Fleet Manager preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. Azure Kubernetes Fleet Manager previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use.

## Prerequisites and limitations

- A cross-cluster network can have up to 255 member clusters.
- Fleet Manager member clusters can only participate in a single cross-cluster network at any time.
- Clusters must run Kubernetes v1.32 or above and have [Advanced Container Networking Services (ACNS)](../aks/use-advanced-container-networking-services?pivots=cilium) with Cilium enabled.
- Clusters must be connected to a [single flat network](../aks/concepts-network-cni-overview#flat-networks) (virtual network or multiple peered networks).
- Overlay networking with tunnels is not supported.
- Self-managed Cilium multi-cluster can't be deployed at the same time.
- ACNS sets the Cilium version and enabled features. These can't currently be directly modified.

## Foundational concepts

Cross-cluster networking for Azure Kubernetes Fleet Manager provides a Fleet-managed [Cilium multi-cluster](https://docs.cilium.io/en/stable/network/clustermesh/intro/) deployment that removes the overhead of configuring and managing Cilium multi-cluster's data plane components on each member cluster.

When a cluster joins a cross-cluster network, the Cilium agent (cilium-agent) and clustermesh-apiserver are deployed on the cluster's control plane by Fleet Manager. Existing clusters on the same cross-cluster network are updated with the newly added cluster's details and the Cilium agent configures eBPF-based routing to allow pods on each cluster to communicate directly without proxies or gateways.

Each cluster retains its local CIDR IP addressing configuration for pods and service. Local Cilium components are responsible for routing allowing pods in one cluster to reach services in remote clusters as if they were local.

For traffic flow control, Cilium network policies ([CiliumNetworkPolicy](https://docs.cilium.io/en/latest/security/policy/index.html)) can be used to control cross-cluster data flow, allowing administrators to enforce boundaries within the cross-cluster network.

## Defining global services

Kubernetes [Services](https://kubernetes.io/docs/concepts/services-networking/service/) on any cross-cluster networking member can be made globally available on the cross-cluster network when **both** of the following conditions are met:

- The Namespace containing the Service has the annotation `clustermesh.cilium.io/global` with a value of `true`.
- The Service has the annotation `service.cilium.io/global` with a value of `true`.

Deploying a Service with these annotations to multiple cross-cluster networking member clusters transparently load balances requests across those clusters.

Note

Fleet Manager's managed Cilium multi-cluster installation sets `clustermesh-default-global-namespace: false`, which differs from the Cilium default. This setting improves scalability by limiting the amount of state (CiliumEndpoints, CiliumIdentities, and Services) synchronized across clusters to only those resources in Namespaces with the `clustermesh.cilium.io/global` annotation set to a value of `true`. As a result, explicit opt-in is required per Namespace by setting that annotation.

You can temporarily remove a Service from a load balanced global service by removing the `service.cilium.io/global` annotation (or setting it to `false`) on that Service. To stop sharing every Service in a Namespace from a given cluster, remove the `clustermesh.cilium.io/global` annotation on the Namespace (or set it to `false`) on that cluster.

## Debugging and troubleshooting

The standard Cilium commandline interface (CLI) tools work with cross-cluster networking for Fleet Manager. Some commands such `upgrade` and `clustermesh connect` don't work because they perform actions Fleet Manager is now responsible for.

Here's the high-level steps to getting started with debugging and troubleshooting:

- Install the latest stable Cilium CLI for your operating system from the official [Cilium CLI GitHub repository](https://github.com/cilium/cilium-cli).
- Select a cross-cluster network member cluster and retrieve its kubeconfig by using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.
- Use the Cilium CLI, passing the cluster context using the `--context` parameter.

The Cilium CLI can manage multiple Cilium versions.

## Updating cross-cluster networking

One reason to adopt cross-cluster networking over installing and running Cilium multi-cluster yourself is that Fleet Manager keeps Cilium's components up to date.

Cross-cluster networking's Cilium component updates are bundled as part of AKS Kubernetes releases. Upgrades are simplified by pre-validation that Cilium components work with the Kubernetes version your cluster runs, ensuring the cross-cluster network remains stable.

This approach means you can use Fleet Manager's [Update Runs and Strategies](concepts-update-orchestration) to upgrade the control plane of your clusters, defining the order in which clusters are updated.