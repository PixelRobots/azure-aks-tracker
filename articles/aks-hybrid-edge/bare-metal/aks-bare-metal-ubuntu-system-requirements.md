---
layout: Conceptual
title: Prepare an Ubuntu Host for AKS on Bare Metal (Preview) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/bare-metal/aks-bare-metal-ubuntu-system-requirements
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
description: Review the Ubuntu, hardware, network, Azure, and Azure Arc requirements and prepare an Ubuntu host for AKS on bare metal.
ms.topic: how-to
ms.date: 2026-09-14T00:00:00.0000000Z
ai-usage: ai-assisted
author: rishimody
ms.author: rmody
ms.custom: bare-metal
locale: en-us
document_id: 9fd583fd-969e-4b34-810d-158b0551ae37
document_version_independent_id: 927275b5-c103-f225-ff3b-2c7d71b49904
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/bare-metal/aks-bare-metal-ubuntu-system-requirements.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/bare-metal/aks-bare-metal-ubuntu-system-requirements
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/bare-metal/aks-bare-metal-ubuntu-system-requirements.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 1af51898-e581-0341-1976-eec0784b01ef
---

# Prepare an Ubuntu Host for AKS on Bare Metal (Preview) | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

This article describes the requirements for deploying Azure Kubernetes Service (AKS) on bare metal on customer-provided Ubuntu hardware.

## Host operating system and hardware requirements

Use a physical machine that meets the following requirements:

| Requirement | Minimum | Recommended |
| --- | --- | --- |
| **Operating system** | Ubuntu 24.04.3 LTS or 24.04.4 LTS. | Ubuntu 24.04.3 LTS or 24.04.4 LTS. |
| **Processor architecture** | x86\_64. | x86\_64. |
| **CPU** | 2 physical cores. | 4 physical cores. |
| **Memory** | 4 GB RAM. | 8 GB RAM. |
| **Disk** | 256 GB of free disk space. | 256 GB or more of free disk space. |

AKS on Ubuntu supports one single-node cluster per host during the preview.

## Customer responsibilities

You own and maintain the Ubuntu host. AKS doesn't reimage the host or manage its operating system lifecycle. You're responsible for:

- Installing and configuring Ubuntu.
- Maintaining the operating system, kernel, system packages, and drivers.
- Applying security updates and patches.
- Configuring the host network, Domain Name System (DNS), proxy, and firewall.
- Maintaining enough CPU, memory, and disk capacity for Kubernetes and other host workloads.

AKS installs and manages the host-level packages, extensions, agents, services, and networking components required for the Kubernetes layer.

## Network requirements

Configure the host with fixed node and control plane IP addresses that don't change during the cluster lifecycle. The control plane IP must match the host IP or be an unused fixed IP address in the same subnet.

Allow outbound HTTPS traffic on TCP port 443.

## Azure requirements

| Requirement | Value |
| --- | --- |
| **Subscription** | An active Azure subscription. |
| **Region** | East US. Create the resource group and Arc-enabled server resource in this region. |
| **Permissions** | Owner, or Contributor plus User Access Administrator, on the resource group. Role assignments must be active and permanent. |
| **Resource providers** | `Microsoft.HybridCompute`, `Microsoft.HybridContainerService`, `Microsoft.Kubernetes`, `Microsoft.ExtendedLocation`, `Microsoft.HybridConnectivity`, and `Microsoft.AzureStackHCI`. |

Register the feature:

```azurecli
az feature register \
  --namespace Microsoft.HybridConnectivity \
  --name hiddenPreviewAccess
```

Register the required resource providers:

```azurecli
az provider register --namespace Microsoft.HybridCompute
az provider register --namespace Microsoft.HybridContainerService
az provider register --namespace Microsoft.Kubernetes
az provider register --namespace Microsoft.ExtendedLocation
az provider register --namespace Microsoft.HybridConnectivity
az provider register --namespace Microsoft.AzureStackHCI
```

## Prepare and connect the Ubuntu host

1. Configure fixed node and control plane IP addresses. Ensure the host can resolve DNS names and reach all required outbound endpoints.
2. Connect the machine to Azure Arc by following [Quickstart: Connect Linux machines to Azure Arc-enabled servers](/en-us/azure/azure-arc/servers/quick-onboard-linux).

    When you connect the machine, use the same East US resource group that you'll use for the AKS deployment and set the location to `eastus`.
3. Sign in and select the subscription that contains the Arc-enabled server.

    ```azurecli
    az login
    az account set --subscription <subscription-id>
    ```
4. Verify that the Arc-enabled server reports a `Connected` status:

    ```azurecli
    az connectedmachine show \
      --resource-group <resource-group> \
      --name <host-name> \
      --query status \
      --output tsv
    ```