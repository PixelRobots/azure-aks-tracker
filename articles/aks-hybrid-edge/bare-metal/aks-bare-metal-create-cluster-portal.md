---
layout: Conceptual
title: Create AKS on bare metal on Azure Linux in the Portal | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/bare-metal/aks-bare-metal-create-cluster-portal
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
description: Create an Azure Kubernetes Service on bare metal cluster on Azure Linux and validated Azure Local hardware by using the Azure portal.
ms.topic: how-to
ms.date: 2026-09-14T00:00:00.0000000Z
ai-usage: ai-assisted
author: SummerSmith
ms.author: sumsmith
ms.custom: bare-metal
locale: en-us
document_id: ccf4238f-164b-4bbd-ef9c-8e7147b14408
document_version_independent_id: 948c2a48-4bf6-58dd-5268-d590f3611e74
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/bare-metal/aks-bare-metal-create-cluster-portal.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/bare-metal/aks-bare-metal-create-cluster-portal
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/bare-metal/aks-bare-metal-create-cluster-portal.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: b59e04ca-e89a-b553-4861-fa2394a4f408
---

# Create AKS on bare metal on Azure Linux in the Portal | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

This article shows you how to create an Azure Kubernetes Service (AKS) on bare metal cluster on Azure Linux and validated Azure Local small form factor hardware by using the Azure portal. This procedure doesn't apply to Ubuntu hosts. To use Ubuntu, see [Create an AKS on bare metal cluster on Ubuntu with Azure CLI](aks-bare-metal-create-cluster-ubuntu-cli).

## Prerequisites

Complete all [system requirements and prerequisites](aks-bare-metal-system-requirements) before you begin.

## Step 1: Navigate to AKS on bare metal

1. Sign in to the [Azure portal](https://portal.azure.com).
2. In the search bar, enter **Azure Arc** and select it from the results.
3. In the left menu, expand **Operations** and select **Machine provisioning (preview)**.
4. Under **3. Deploy cluster**, select **Deploy** &gt; **AKS for Azure Local on Linux**.

    [![Screenshot of Azure Arc Machine provisioning to deploy a cluster for AKS for Azure Local on Linux.](../media/aks-bare-metal-create-cluster-portal/create-cluster.png)](../media/aks-bare-metal-create-cluster-portal/create-cluster.png#lightbox)

## Step 2: Configure basics

On the **Basics** tab, configure the following settings:

| Setting | Value |
| --- | --- |
| Site | Select your site. This selection automatically populates your subscription. |
| Resource group | Select or create a resource group in **East US**. |
| Cluster name | Enter a name for your cluster. Name must be 1-27 characters long, start and end with a letter or number, and can only contain letters, numbers, hyphens, or underscores. |
| Kubernetes version | Select **1.34.2** or **1.34.3**. |
| Edge machine | Select **Add machines** to view available machines within your selected site, and then select the machine to deploy on. |

## Step 3: Configure access

On the **Access** tab, configure the following settings:

| Setting | Value |
| --- | --- |
| Admin group object IDs | Enter your Microsoft Entra ID group object ID for cluster admin access. |

## Step 4: Configure networking

On the **Networking** tab, configure the following settings:

| Setting | Value |
| --- | --- |
| Control plane IP | (Optional) If you leave this field blank, the control plane IP defaults to the host machine's IP address. Only specify a custom IP if you need the control plane to be reachable on a different address than the host machine. If provided, it must be in the same subnet as your edge machine. |

Warning

If you specify a custom control plane IP and your machine uses DHCP, you must reserve the control plane IP address so it remains permanently assigned to this machine. If the control plane IP changes, the Kubernetes cluster becomes unreachable and must be redeployed.

## Step 5: Configure integrations (optional)

On the **Integrations** tab, you can enable Azure Monitor and other integrations for your cluster. This step is optional.

## Step 6: Configure tags (optional)

On the **Tags** tab, you can add name/value tags to organize your resources for billing and management. This step is optional.

## Step 7: Review and create

1. Select **Review + create**.
2. Review your configuration settings.
3. Select **Create**.

Deployment typically takes **20 minutes**. You can monitor progress on the deployment page.

## Step 8: Verify deployment

After the deployment completes:

1. Navigate to your resource group.
2. Select the AKS cluster resource.
3. Verify that the status shows **Succeeded**.