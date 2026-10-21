---
layout: Conceptual
title: Container networking with Azure Application Gateway for Containers | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/container-networking
breadcrumb_path: /azure/bread/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/148/azure-application-gateway/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/8ae9bf04-8326-ec11-b6e6-000d3a4f0789?c=8d429912-8326-ec11-b6e6-000d3a4f0789
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
manager: kumud
ms.reviewer: mbender
description: Learn how Azure Application Gateway for Containers works with different container networking interfaces.
services: application gateway
author: mbender-ms
ms.service: azure-application-gateway-containers
ms.topic: concept-article
ms.date: 2026-09-23T00:00:00.0000000Z
ms.author: mbender
locale: en-us
document_id: e2cd58c0-8957-a520-44e3-b25fd832406b
document_version_independent_id: 9c70ddf9-8101-39fd-a1db-1e38e4b2fb04
original_content_git_url: https://github.com/MicrosoftDocs/azure-docs-pr/blob/live/articles/application-gateway/for-containers/container-networking.md
site_name: Docs
depot_name: Azure.azure-documents
page_type: conceptual
toc_rel: toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/Azure.azure-documents/{branchName}{pdfName}
asset_id: application-gateway/for-containers/container-networking
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-gateway/for-containers/container-networking.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 1ea9dcec-bfab-2f90-3a7e-9e5805d12d0e
---

# Container networking with Azure Application Gateway for Containers | Microsoft Learn

Kubernetes uses Container Networking Interface (CNI) plugins to manage networking in Kubernetes clusters. CNIs are responsible for assigning IP addresses to pods, network routing between pods, Kubernetes Service routing, and more.

Azure Kubernetes Service (AKS) uses two main networking models: **overlay** network and **flat** network.

- **Overlay networks**:

    - Conserve VNet IP address space by using logically separate CIDR ranges for pods.
    - Maximum cluster scale support.
    - Simple IP address management.
- **Flat networks**:

    - Pods get full VNet connectivity and can be directly reached via their private IP address from connected networks.
    - Require large, nonfragmented VNet IP address space.

When choosing a networking model, consider the use cases for each CNI plugin and the type of network model it uses:

| CNI plugin | Networking model | Use case highlights |
| --- | --- | --- |
| **Azure CNI Overlay** | Overlay | - Best for VNET IP conservation- Max node count supported by API Server + 250 pods per node- Simpler configuration - No direct external pod IP access |
| **Azure CNI Pod Subnet** | Flat | - Direct external pod access- Modes for efficient VNet IP usage *or* large cluster scale support |
| **Azure CNI Node Subnet** | Flat | - Direct external pod access- Simpler configuration - Limited scale - Inefficient use of VNet IPs |

When provisioning Application Gateway for Containers into a cluster that has CNI Overlay or CNI enabled, Application Gateway for Containers automatically detects the intended network configuration. There are no changes needed in Gateway or Ingress API configuration to specify CNI Overlay or CNI.

## CNI Overlay and Application Gateway for Containers

![Diagram depicting traffic from the Internet ingressing into Application Gateway for Containers and being sent to backend pods in an overlay network in AKS.](media/container-networking/application-gateway-for-containers-cni-overlay.svg)

A separate routing domain is created in the Azure Networking stack for the pod's private CIDR space, which creates an Overlay network for direct communication between pods. When Application Gateway for Containers is provisioned, the Overlay routing domain is further extended to the Application Gateway for Containers subnet, allowing proxying of requests from Application Gateway for Containers directly to pods.

Application Gateway for Containers supports Azure Network Policies, Calico, and Cilium Kubernetes network policies running within the cluster.

### Limitations

- ALB Controller: You must be running version 1.7.9 or greater to take advantage of CNI Overlay.
- Subnet Size: The Application Gateway for Containers subnet must be a /24 prefix; only one deployment is supported per subnet. A larger or smaller prefix isn't supported.
- Regional VNet Peering: Application Gateway for Containers deployed in a virtual network in region A and the AKS cluster nodes in a separate virtual network in region A isn't supported.
- Global VNet Peering: Application Gateway for Containers deployed in a virtual network in region A and the AKS cluster nodes in a virtual network in region B isn't supported.

## CNI and Application Gateway for Containers

Application Gateway for Containers supports various deployments of Azure CNI running within your Kubernetes cluster.

- Azure CNI for dynamic IP allocation
- Azure CNI for static block allocation

In both cases, Application Gateway for Containers supports Azure Network Policies, Calico, and Cilium Kubernetes network policies running within the cluster.

## Kubenet and Application Gateway for Containers

Kubenet isn't supported by Application Gateway for Containers. If using Kubenet, we recommend [upgrading to CNI Overlay](/en-us/azure/aks/upgrade-aks-ipam-and-dataplane#kubenet-cluster-upgrade).

## FAQ

Q: Can I upgrade an existing cluster with Application Gateway for Containers from CNI to CNI Overlay? A: Yes, upgrade of the AKS cluster from CNI to CNI Overlay and Application Gateway for Containers automatically detects the change. It's recommended to schedule the upgrade during a maintenance window as traffic disruption can occur. The controller may take a few minutes post-cluster upgrade to detect and configure support for CNI Overlay.

Warning

Ensure the Application Gateway for Containers subnet is a /24 before upgrading. Upgrading from CNI to CNI Overlay with a larger subnet (/23 or larger) will lead to an outage and require the Application Gateway for Containers subnet to be recreated with a /24 subnet size.

Q: Can I upgrade an existing cluster with Kubenet to CNI Overlay? A: Yes, however, installation of Application Gateway for Containers on a cluster with Kubenet isn't supported. Install Application Gateway for Containers post-upgrade to CNI Overlay.

Q: If I use Application Gateway for Containers with CNI Overlay, can I forward requests to Azure Firewall or a Network Virtual Appliance (NVA)? A: No. With CNI Overlay, NVAs don't have access to proxy traffic to the overlay network. If you need Azure services or NVAs to access the overlay network, use Azure CNI (flat networking) instead of CNI Overlay.

Q: Can I deploy Application Gateway for Containers in a separate virtual network from my AKS cluster? A: No. Separate virtual networks for Application Gateway for Containers and AKS aren't currently supported. Application Gateway for Containers must be deployed in the same virtual network as your AKS cluster.

Q: Can Application Gateway for Containers proxy traffic to a cluster running CNI Overlay with Cilium and WireGuard enabled? A: Yes. Application Gateway for Containers can proxy traffic to a cluster configured with CNI Overlay, Cilium, and WireGuard. However, WireGuard doesn't encrypt traffic between Application Gateway for Containers and the destination pod.

Q: Does Application Gateway for Containers support virtual networks with VNet encryption enabled? A: Yes. You can deploy Application Gateway for Containers in a virtual network with VNet encryption enabled. However, Application Gateway for Containers doesn't use VNet encryption for traffic between the gateway and AKS.