---
layout: Conceptual
title: Network requirements for AKS on Azure Local for multi-rack deployments | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/multi-rack/network-system-requirements
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
description: Learn about the network requirements for deploying AKS enabled by Azure Arc clusters on Azure Local (multi-rack), including logical network configuration, IP address requirements, and port requirements.
ms.topic: concept-article
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: sanjanamohan
ms.custom: multi-rack
author: sanjanamsft
locale: en-us
document_id: 869f4b4b-4f61-6d2e-39fb-371a41758457
document_version_independent_id: 6448a4f1-cba5-3586-2275-f033ae3ee748
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/multi-rack/network-system-requirements.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/multi-rack/network-system-requirements
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/multi-rack/network-system-requirements.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/289b8734-3abd-4162-bc19-e661c3f4c940
- https://authoring-docs-microsoft.poolparty.biz/devrel/f98c9a19-e481-4f15-8047-76b641e6ed57
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/6a94795e-9024-410d-b38e-b67941440893
- https://authoring-docs-microsoft.poolparty.biz/devrel/f5685781-a4fd-40f1-8126-59abde4643bf
platformId: 6304ecde-9a8a-974b-18d2-c093395e7378
---

# Network requirements for AKS on Azure Local for multi-rack deployments | Microsoft Learn

This article introduces core networking concepts for your VMs and applications in AKS enabled by Azure Arc. The article also describes the required networking prerequisites for creating Kubernetes clusters. We recommend that you work with a network administrator to provide and set up the networking parameters required to deploy AKS enabled by Arc.

In this conceptual article, the following key components are introduced.

- Logical network for AKS Arc VMs and control plane IP
- Load balancer for containerized applications

## Logical networks for AKS Arc VMs and control plane IP

Kubernetes nodes are deployed as specialized virtual machines in AKS enabled by Arc. These VMs are allocated IP addresses to enable communication between Kubernetes nodes. AKS Arc uses Azure Local logical networks to provide IP addresses and networking for the underlying VMs of the Kubernetes clusters. For more information about logical networks, see [Logical networks for Azure Local](/en-us/azure/azure-local/multi-rack/multi-rack-create-logical-networks). You must plan for one IP address per AKS cluster node VM in your Azure Local environment.

AKS clusters on Azure Local (multi-rack) require a logical network with the following configuration:

| Requirement | Details |
| --- | --- |
| **Static** | Only LNETs with ip-allocation-type "Static" supported. Assignment of IP addresses to AKS Arc VMs from these known static IP pools is done automatically. |
| **Subnet size** | The subnet must be /28 or larger (minimum 16 addresses). Size the subnet based on the total number of nodes across all clusters you plan to deploy. For more information, see [Plan IP addresses](plan-aks-ip-address) for sizing guidance. |
| **Provisioning** | The logical network must be provisioned before creating AKS clusters. |

The following parameters are required in order to use a logical network for AKS Arc cluster create operation:

| [Az CLI logical networks parameter](/en-us/azure/azure-local/manage/create-logical-networks?tabs=azurecli) | Description | Required parameter for AKS Arc cluster |
| --- | --- | --- |
| `--address-prefixes` | AddressPrefix for the network. Currently only one address prefix is supported. Usage: `--address-prefixes "10.220.32.16/24"`. | ![Supported](media/network-system-requirements/check.png) |
| `--dns-servers` | Space-separated list of DNS server IP addresses. Usage: `--dns-servers 10.220.32.16 10.220.32.17`. | Optional, but highly recommended |
| `--no-gateway` | Specify `--no-gateway`. | ![Supported](media/network-system-requirements/check.png) |
| `--ip-allocation-method` | The IP address allocation method. Supported values are `Static`. Usage: `--ip-allocation-method "Static"`. | ![Supported](media/network-system-requirements/check.png) |
| `--fabric-network-configuration-id` | Azure Resource Manager resource ID of the Layer 3 Internal Network. | ![Supported](media/network-system-requirements/check.png) |
| `--ip-pool-start` | If you use MetalLB or any other non-Microsoft load balancer in L2/ARP mode, we highly recommend using IP pools to separate AKS Arc IP requirements from load balancer IPs. This recommendation is to help avoid IP address conflicts that can lead to unintended and hard-to-diagnose failures. This value is the start IP address of your IP pool. The address must be in the range of the address prefix. Usage: `--ip-pool-start "10.220.32.18"`. | Optional, but highly recommended. |
| `--ip-pool-end` | If you use MetalLB or any other non-Microsoft load balancer in L2/ARP mode, we highly recommend using IP pools to separate AKS Arc IP requirements from load balancer IPs. This recommendation is to help avoid IP address conflicts that can lead to unintended and hard-to-diagnose failures. This value is the end IP address of your IP pool. The address must be in the range of the address prefix. Usage: `--ip-pool-end "10.220.32.38"`. | Optional, but highly recommended. |

## IP address requirements

For detailed IP planning guidance and examples, see [Plan IP addresses for AKS on Azure Local (multi-rack)](plan-aks-ip-address).

## Control plane IP

Kubernetes uses a control plane to ensure every component in the Kubernetes cluster is kept in the desired state. The control plane also manages and maintains the worker nodes that hold the containerized applications. AKS enabled by Arc deploys the KubeVIP load balancer to ensure that the API server IP address of the Kubernetes control plane is always available. This KubeVIP instance requires a single immutable "control plane IP address" to function correctly.

**Auto-allocation (only supported mode)**: By default, the control plane endpoint IP is automatically allocated from the logical network subnet. We only support system-assigned control plane IPs currently.

Note

You can't specify the control plane IP because it's system assigned.

## Load balancer IPs for containerized applications

The main purpose of a load balancer is to distribute traffic across multiple nodes in a Kubernetes cluster. This load balancing can help prevent downtime and improve overall performance of application. The *MetalLB extension for Azure Arc enabled Kubernetes* is a tool that allows you to generate external IPs for your applications and services. Arc-enabled Kubernetes clusters can integrate with MetalLB using the extension for MetalLB for Azure Arc enabled Kubernetes.

You must provide a set of IP addresses to the load balancer service. You have the following options:

- Provide IP addresses for your services from the same subnet as the AKS Arc VMs.
- Use a different network and list of IP addresses if your application needs external load balancing.

Regardless of the option you choose, you must ensure that the IP addresses allocated to the load balancer don't conflict with the IP addresses in the logical network. Conflicting IP addresses can lead to unforeseen failures in your AKS deployment and applications.

For more information about configuring MetalLB, see [Deploy MetalLB load balancer using Azure Arc extension](/en-us/azure/aks/aksarc/deploy-metallb).

## Proxy configuration

In Azure Local for multi-rack deployments, users can optionally provide a proxy for workload AKS Arc cluster traffic. For example, customer image pulls from a container registry. This proxy isn't used for any infrastructure or control plane traffic.

The proxy must be set up before you create the AKS Arc cluster and must be reachable from the logical network of the AKS Arc cluster. The proxy endpoint is specified as an

```json
{
  "type": "Microsoft.HybridContainerService/provisionedClusterInstances",
  "apiVersion": "2024-01-01",
  "name": "default",
  "tags": {
    "https-proxy": "https://<proxyIPAddress>:3128"
  },
  ...
}
```

The proxy tag can be updated post-cluster creation, if needed. This proxy applies to all nodes in the cluster. A proxy can't be configured per node pool.

Note

The proxy endpoint must be an IPv4 address. IPv6 isn't supported.

## Software Defined Networking (SDN)

SDN isn't supported for AKS on Azure Local. Use logical networks without SDN for AKS cluster networking.