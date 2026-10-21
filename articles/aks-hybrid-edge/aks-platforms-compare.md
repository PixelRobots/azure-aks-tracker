---
layout: Conceptual
title: Azure Kubernetes Service (AKS) Cloud, Edge, and On-Premises Comparison | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/aks-platforms-compare
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
description: Learn about Azure Kubernetes Service (AKS) features, capabilities, and pricing across cloud, edge, and on-premises environments to choose the best deployment for your needs.
author: davidsmatlak
ms.topic: concept-article
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.reviewer: rmody
ms.custom: overview
locale: en-us
document_id: e3d07fca-dc53-b92c-8378-1d4cb78167c5
document_version_independent_id: d4690034-7dfe-7eab-b325-9e964156a46a
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/aks-platforms-compare.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../aks/toc.json
asset_id: aks-hybrid-edge/aks-platforms-compare
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/aks-platforms-compare.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
platformId: c9d9d4e5-4e81-bbfd-03f2-26d3a99365d9
---

# Azure Kubernetes Service (AKS) Cloud, Edge, and On-Premises Comparison | Microsoft Learn

Azure Kubernetes Service (AKS) is a fully managed Kubernetes platform that simplifies how organizations deploy, scale, and manage containerized applications in the cloud. As customer needs evolve to span cloud, on-premises, and edge environments, AKS expands its footprint and brings the same trusted Kubernetes capabilities to a broader range of edge and on-premises infrastructure.

With solutions like AKS on bare metal and AKS on Azure Local, organizations can now run AKS clusters closer to where their workloads and data reside, whether directly on edge hardware, in remote edge sites, or within their own datacenters, while maintaining a consistent operational and developer experience. While AKS is delivered differently across environments, the underlying platform stays aligned in its goals, behavior, and experience.

The focus is on delivering a cohesive and adaptable AKS offering that meets customers across cloud and edge, while preserving the simplicity and power that define the AKS experience.

This article describes how AKS extends features across multiple platforms and highlights the unique advantages and capabilities it brings to cloud, on-premises, and edge environments.

## General comparison of AKS across platforms

| Feature | Azure (Cloud) | Azure Local (Edge/On-premises) | Edge Essentials (Edge/On-premises, Windows IoT client/server) | Windows Server (Edge/On-premises) |
| --- | --- | --- | --- | --- |
| Supported infrastructure for Kubernetes cluster | Azure cloud | Azure Local, version 23H2 or later | - Windows 10/11 IoT Enterprise- Windows 10/11 Enterprise- Windows 10/11 Pro- Windows Server 2019/2022 | - Windows Server 2019- Windows Server 2022 |
| CNCF conformant | Yes | Yes | Yes | Yes |
| Kubernetes cluster lifecycle management tools (create, scale, upgrade, and delete clusters) | - Azure CLI- Azure PowerShell- Azure portal- Azure Resource Manager (ARM) templates- Bicep- Bicep Kubernetes Provider- Azure Developer CLI | - Azure portal- Azure CLI- ARM templates- Bicep templates | PowerShell | - PowerShell- Windows Admin Center |
| Kubernetes cluster management plane | AKS is a managed Kubernetes offering. The AKS control plane is hosted and managed by Microsoft. AKS worker nodes are created in customer subscriptions. | Kubernetes clusters are managed through a lightweight management appliance that's automatically created when Azure Local gets deployed. | Kubernetes clusters are self-managed, to preserve resources. | Kubernetes clusters are managed using a *management cluster* that's installed using PowerShell before you can create Kubernetes workload clusters. |
| Support for Kubectl or other open source Kubernetes tool | Yes | Yes | Yes | Yes |
| Supported K8s versions | Continuous updates to supported Kubernetes versions. For the latest version support, run [az aks get-versions](/en-us/cli/azure/aks#az_aks_get_versions). | Supports K8s only.For the latest version support, run [az aksarc get-versions](/en-us/cli/azure/aks#az_aks_get_versions). | Supports K3s and K8s. For the latest K8s version support, see [steps to prepare your machine for AKS Edge Essentials](edge-essentials/aks-edge-howto-setup-machine#download-aks-edge-essentials). | - Supports K8s only.- Continuous updates to supported Kubernetes versions. For the latest version support, see [AKS hybrid releases on GitHub](https://github.com/Azure/aksArc/releases). |
| Azure Fleet Manager integration | Yes | No | No | No |
| Terraform integration | Yes | Yes (Preview) | No | No |
| Support for Taints and Labels | Yes | Yes | Not validated. These settings don't persist when cluster is upgraded. | Yes |
| AKS automatic | Yes | No | No | No |

## Monitoring and diagnostic capabilities

| Feature | Azure (Cloud) | Azure Local (Edge/On-premises) | Edge Essentials (Edge/On-premises, Windows IoT client/server) | Windows Server (Edge/On-premises) |
| --- | --- | --- | --- | --- |
| Azure Monitor Container Insights | Yes | Yes, via Arc extensions | Yes, via Arc extensions | Yes, via Arc extensions |
| Azure Monitor Managed Prometheus and control plane metrics scraping | Yes | Yes, via Arc extensions | Yes, via Arc extensions | Yes, via Arc extensions |
| Control plane audit logs | Yes | Yes, via Arc extensions | No | No |
| Platform/Shoebox metrics | Yes | Yes, via Arc extensions | No | No |
| Diagnostics log collection (local) | Yes | Yes | Yes | Yes |

## Node pool capabilities

| Feature | Azure (Cloud) | Azure Local (Edge/On-premises) | Edge Essentials (Edge/On-premises, Windows IoT client/server) | Windows Server (Edge/On-premises) |
| --- | --- | --- | --- | --- |
| Windows node pool support | - Yes- Windows Server 2019 Datacenter- Windows Server 2022 Datacenter | - Yes- Windows Server 2019 Datacenter- Windows Server 2022 Datacenter | - Yes- Windows Server 2022 Datacenter (Core) | - Yes- Windows Server 2019 Datacenter- Windows Server 2022 Datacenter |
| Linux OS offerings | - Ubuntu 18.04- Azure Linux | [Azure Linux](https://github.com/microsoft/azurelinux) | [Azure Linux](https://github.com/microsoft/azurelinux) | [Azure Linux](https://github.com/microsoft/azurelinux) |
| Container runtime | Containerd for Linux and Windows nodes | Containerd for Linux and Windows nodes | Containerd for Linux and Windows nodes | Containerd for Linux and Windows nodes |
| Node pool auto-scaler | - Manual- Auto-scaler- Horizontal pod scaler | - Manual- Auto-scaler | Manual | - Manual- Auto-scaler- Horizontal pod scaler |
| Azure Container Registry | Yes | Yes | Yes | Yes |
| Azure Container Instance | Yes | Yes | No | No |
| Start/stop a Kubernetes cluster | Yes | Yes | Yes | Yes |
| Virtual nodes | Yes | Yes | Yes | Yes |
| Private cluster | Yes | No | No | No |
| Node pool snapshot | Yes | No | No | No |
| Custom node configuration at deployment | Yes | Yes | Yes | Yes |
| SSH to nodes | Yes | Yes | Yes | Yes |
| Availability zones | Yes | No | No | No |
| Proximity placement groups | Yes | No | No | No |

## Networking capabilities

| Feature | Azure (Cloud) | Azure Local (Edge/On-premises) | Edge Essentials (Edge/On-premises, Windows IoT client/server) | Windows Server (Edge/On-premises) |
| --- | --- | --- | --- | --- |
| Network creation and management | By default, Azure creates a virtual network and subnet for you. You can also choose an existing virtual network in which to create your AKS clusters. | Setting up networking parameters is a required prerequisite to deploy AKS on Azure Local. Network must have connectivity and IP address availability for successful operation of the cluster. | You must provide the IP address range for node IPs and service IPs that are available and have the right connection. The network configuration needed for the cluster is handled by AKS. See [AKS Edge Essentials networking](edge-essentials/aks-edge-concept-networking). | You must create the network in Windows Server before creating an AKS cluster. Network must have connectivity and IP address availability for successful operation of the cluster. |
| Supported networking option | Bring your own Azure virtual network for AKS clusters. | Static IP networks with or without VLAN ID. | Static IP address or use reserved IPs when using DHCP. | - DHCP networks with or without VLAN ID.- Static IP networks with or without VLAN ID. |
| SDN support | Not applicable since the cluster runs on Azure. | No | No | Yes |
| Support for Arc Gateway | N/A (works with Azure Application Gateway) | Yes | Yes – support for Azure IoT Operations only | No |
| Supported CNIs | - Azure CNI- Calico- Azure CNI overlay (Cillium)- Bring your own CNI | Calico | - Calico (K8s)- Flannel (K3s) | Calico |
| Service Mesh | Istio add-on | Open Service Mesh, via Arc extensions. | Open Service Mesh, via Arc extensions. | Open Service Mesh, via Arc extensions. |
| Load Balancer | - Azure load balancer – Basic SKU or Standard SKU- Internal load balancer- Bring your own load balancer (BYOLB) | - Bring your own load balancer (BYOLB)- MetalLB Arc Extension | - KubeVIP- Bring your own load balancer (BYOLB) | - HAProxy- SDN load balancer- Bring your own load balancer (BYOLB) |

## Storage features

| Feature | Azure (Cloud) | Azure Local (Edge/On-premises) | Edge Essentials (Edge/On-premises, Windows IoT client/server) | Windows Server (Edge/On-premises) |
| --- | --- | --- | --- | --- |
| Types of supported persistent volumes | - Read Write Once- Read Write Many | - VHDX – Read Write Once- SMB or NFS – Read Write Many- ACSA - Read Write Many | - PVC using local storage- ACSA | - VHDX – Read Write Once- SMB or NFS - Read Write Many |
| Container storage interface (CSI) support | Yes | Yes | Yes | Yes |
| CSI drivers | - Azure Storage- Azure Files and Azure Disk- Premium CSI drivers deployed by default. | Disk and file (SMB and NFS) drivers installed by default. | Support for SMB and NFS storage drivers. | Support for SMB and NFS storage drivers. |
| Dynamic provisioning support | Yes | Yes | Yes | Yes |
| Volume resizing support | Yes | Yes | Yes | Yes |
| Volume snapshots support | Yes | No | No | No |

## Security and authentication options

| Feature | Azure (Cloud) | Azure Local (Edge/On-premises) | Edge Essentials (Edge/On-premises, Windows IoT client/server) | Windows Server (Edge/On-premises) |
| --- | --- | --- | --- | --- |
| Access to Kubernetes cluster | Kubectl | Kubectl | Kubectl | Kubectl |
| Kubernetes cluster authorization (RBAC) | - Kubernetes RBAC- Azure RBAC | - Kubernetes RBAC- Azure RBAC | Kubernetes RBAC | Kubernetes RBAC |
| Kubernetes cluster authentication | - Certificate-based Kubeconfig- Microsoft Entra ID | - Certificate-based Kubeconfig- Microsoft Entra ID | Certificate-based Kubeconfig- Microsoft Entra ID | - Certificate-based Kubeconfig- Microsoft Entra ID |
| Support for network policies | Yes | No | No | Yes – only for Linux containers |
| Support for workload identity | Yes | Yes | Yes - (Support for AIO only) | Yes |
| Limit source networks that can access API server | Yes | Yes | Yes | Yes |
| Encrypt etcd secrets | Yes | Yes | Yes | Yes |
| Certificate rotation and encryption | Yes | Yes | Yes | Yes |
| Secrets store CSI driver | Yes | Yes | Yes | Yes |
| gMSA support | Yes | No | Yes | Yes |
| Azure Policy | Yes | Yes, via Arc extensions | Yes, via Arc extensions | Yes, via Arc extensions |
| Azure Defender | Yes | Yes, via Arc extensions (preview) | Yes, via Arc extensions (preview) | Yes, via Arc extensions (preview) |

## Pricing and SLA details

| Feature | Azure (Cloud) | Azure Local (Edge/On-premises) | Edge Essentials (Edge/On-premises, Windows IoT client/server) | Windows Server (Edge/On-premises) |
| --- | --- | --- | --- | --- |
| Pricing | - Unlimited free clusters, pay for on-demand compute of worker node VMs.- Paid tier available with uptime SLA, support for 5k nodes. | Included in Azure Local at no extra cost. | Cost is per device per month. | Pricing is based on the number of workload cluster vCPUs. Control plane nodes and load balancer VMs are free. |
| Azure Hybrid Benefit support | Not applicable | Not applicable - AKS already included at no extra cost. | No | Yes |
| SLA | Paid uptime SLA clusters for production with fixed cost on the API + worker node compute, storage and networking costs. | No SLA offered as the Kubernetes cluster is running on premises. | No SLA offered as the Kubernetes cluster is running on premises. | No SLA offered as the Kubernetes cluster is running on premises. |

### AI and machine learning capabilities offered in each platform

| Feature | Azure (Cloud) | Azure Local (Edge/On-premises) | Edge Essentials (Edge/On-premises, Windows IoT client/server) | Windows Server (Edge/On-premises) |
| --- | --- | --- | --- | --- |
| GPU support | Yes | Yes | Yes | Yes |
| KAITO (Kubernetes AI toolchain operator) | Yes | Yes, via Arc extensions | No | No |
| Edge RAG | Yes | Yes | No | No |