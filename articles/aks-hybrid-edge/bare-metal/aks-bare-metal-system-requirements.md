---
layout: Conceptual
title: System requirements and prerequisites for AKS on bare metal Azure Linux (preview) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/bare-metal/aks-bare-metal-system-requirements
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
description: Review Azure Local hardware, network, and Azure requirements for deploying AKS on bare metal on Azure Linux.
ms.topic: concept-article
ms.date: 2026-09-14T00:00:00.0000000Z
ai-usage: ai-assisted
author: SummerSmith
ms.author: sumsmith
ms.custom: bare-metal
locale: en-us
document_id: a64bbac6-c290-0b90-82d0-7498333a7632
document_version_independent_id: ff604c0e-6c02-0b25-b916-e6df490f9bfa
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/bare-metal/aks-bare-metal-system-requirements.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/bare-metal/aks-bare-metal-system-requirements
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/bare-metal/aks-bare-metal-system-requirements.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/289b8734-3abd-4162-bc19-e661c3f4c940
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/6a94795e-9024-410d-b38e-b67941440893
platformId: f4331a71-09e7-b48f-cfb8-2d51b9ac76b2
---

# System requirements and prerequisites for AKS on bare metal Azure Linux (preview) | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

This article describes the requirements for deploying Azure Kubernetes Service (AKS) on bare metal on Azure Linux and validated Azure Local small form factor hardware. For customer-provided Ubuntu hardware, see [System requirements and prepare your Ubuntu host](aks-bare-metal-ubuntu-system-requirements).

## Hardware requirements

Use one of the [supported devices for small form factor deployments of Azure Local.](/en-us/azure/azure-local/small-form-factor/small-form-factor-overview#supported-devices)

## Network requirements

### Outbound internet connectivity

The bare metal host requires outbound internet access to the following endpoints:

| Endpoint | Purpose |
| --- | --- |
| `*.arc.azure.net` | Azure Arc connectivity |
| `management.azure.com` | Azure Resource Manager |
| `login.microsoftonline.com` | Microsoft Entra authentication |
| `mcr.microsoft.com` | Container image pulls |
| `*.data.mcr.microsoft.com` | Container image data |
| `guestnotificationservice.azure.com` | Arc guest notifications |

### IP address planning

You need one IP address planned before deployment:

| IP type | Purpose | Notes |
| --- | --- | --- |
| Control plane IP | Kubernetes API server endpoint | Must be in the same subnet as the host or match the host IP |

## Azure prerequisites

### Subscription and permissions

| Requirement | Details |
| --- | --- |
| Azure subscription | Active subscription with billing enabled |
| Region | **East US** (only supported region for public preview) |
| Role | **Owner** or **Contributor + User Access Administrator** on the resource group |
| Role assignment status | Must be both **Active** and **Permanent** |
| Resource providers | [`Microsoft.HybridCompute`](/en-us/azure/templates/microsoft.hybridcompute/machines?pivots=deployment-language-bicep), [`Microsoft.HybridContainerService`](/en-us/azure/templates/microsoft.hybridcontainerservice/provisionedclusters?pivots=deployment-language-bicep), [`Microsoft.Kubernetes`](/en-us/azure/templates/microsoft.kubernetes/connectedclusters?pivots=deployment-language-bicep), [`Microsoft.ExtendedLocation`](/en-us/azure/templates/microsoft.extendedlocation/customlocations?pivots=deployment-language-bicep) must be registered |

Important

If your role assignment isn't active and permanent, you might need to temporarily elevate your permissions before running deployment commands.

### Check directory and subscription settings

1. In the Azure portal, select **Settings** &gt; **Directories + subscriptions**.
2. If you have more than one directory, select the directory you're using for this deployment.
3. Make sure your default subscription filter includes the subscription you're using for testing.

For more information, see:

- [Set subscription filters](/en-us/azure/azure-portal/set-preferences#subscription-filters)
- [Manage directories and subscriptions](/en-us/azure/azure-portal/set-preferences#directories--subscriptions)

### Register feature

```azurecli
az feature register \
  --subscription <subscription_id> \
  --namespace Microsoft.HybridContainerService \
  --name hiddenPreviewAccess

az feature register \
  --subscription <subscription_id> \
  --namespace Microsoft.HybridConnectivity \
  --name hiddenPreviewAccess
```

### Register resource providers

Ensure Azure CLI is installed and signed in.

```azurecli
az provider register --namespace Microsoft.HybridCompute
az provider register --namespace Microsoft.HybridContainerService
az provider register --namespace Microsoft.Kubernetes
az provider register --namespace Microsoft.ExtendedLocation
```

### Azure CLI extensions

Install the required CLI extensions:

```azurecli
az extension add --name connectedk8s
```

Note

The `connectedk8s` extension is required to connect to your cluster after deployment using `az connectedk8s proxy`.

### Arc-enabled machine

Before deploying an AKS cluster, you must have a small form factor Azure Local device set up by following the [Azure Local documentation](/en-us/azure/azure-local/small-form-factor/small-form-factor-overview).

## Entra ID requirements

To use Azure RBAC for cluster access:

| Requirement | Details |
| --- | --- |
| Entra ID group | A security group containing users who need cluster admin access |
| Group object ID | The object ID of the Entra ID group (found in Azure portal → Entra ID → Groups) |