---
layout: Conceptual
title: Configure Azure CNI Networking in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni
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
description: Learn how to configure Azure CNI (advanced) networking in Azure Kubernetes Service (AKS).
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-networking
ms.topic: how-to
ms.date: 2026-01-29T00:00:00.0000000Z
ms.custom: references_regions, devx-track-azurecli
locale: en-us
document_id: 467b2f96-03fa-33d2-16b1-0e25c5fa7a91
document_version_independent_id: e53d93df-6f08-89da-3482-5da53e6e005e
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/configure-azure-cni.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurepowershell,azurecli
toc_rel: toc.json
asset_id: aks/configure-azure-cni
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/configure-azure-cni.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/cdc80360-921e-4b45-947f-2719acf06f23
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/539badf0-028a-4e3e-bda6-770b2552b4d8
platformId: 4cd32257-99c3-295d-cdbd-dec23f75aa76
---

# Configure Azure CNI Networking in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article shows you how to use Container Networking Interface (CNI) networking in Azure to create and use a virtual network subnet for an Azure Kubernetes Service (AKS) cluster. For more information on network options and considerations, see [Networking concepts for applications in Azure Kubernetes Service](/en-us/azure/aks/concepts-network).

## Prerequisites

# [Azure portal](#tab/configure-networking-portal)
- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).

# [Azure PowerShell](#tab/configure-networking-powershell)
- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- Azure Cloud Shell or Azure PowerShell.

    The steps in this article run the Azure PowerShell cmdlets interactively in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). To run the commands in Cloud Shell, select **Open Cloud Shell** at the upper-right corner of a code block. Select **Copy** to copy the code, and then paste it into Cloud Shell to run it. You can also run Cloud Shell from within the Azure portal.

    You can also [install Azure PowerShell locally](/en-us/powershell/azure/install-azure-powershell) to run the cmdlets. The steps in this article require Azure PowerShell module version 5.4.1 or later. Run `Get-Module -ListAvailable Az` to find your installed version. If you need to upgrade for a specific operating system, see the installation instructions for [macOS](/en-us/powershell/azure/install-azps-macos#update-the-azure-powershell-module), [Windows](/en-us/powershell/azure/install-azps-windows#update-the-az-powershell-module), or [Linux](/en-us/powershell/azure/install-azps-linux#update-the-az-powershell-module).

    If you run PowerShell locally, run `Connect-AzAccount` to connect to Azure.

# [Azure CLI](#tab/configure-networking-cli)
- You need an Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

---

## Configure networking

For information on planning IP addresses, see [IP address planning for your Azure Kubernetes Service clusters](concepts-network-ip-address-planning). If you bring your own virtual network, review the [virtual network prerequisites](concepts-network-cni-overview#aks-cni-networking-prerequisites).

# [Azure portal](#tab/configure-networking-portal)
1. Sign in to the [Azure portal](https://portal.azure.com/).
2. On the Azure portal home page, select **Create a resource**.
3. Under **Categories**, select **Containers** &gt; **Azure Kubernetes Service (AKS)**.
4. On the **Basics** tab, configure the following settings:

    - Under **Project details**:
        - **Subscription**: Select your Azure subscription.
        - **Resource group**: Select **Create new**, enter a resource group name (such as **test-rg**), and then select **Ok**.
    - Under **Cluster details**:
        - **Kubernetes cluster name**: Enter a cluster name, such as **aks-cluster**.
        - **Region**: Select **East US 2**.
5. Select **Next** &gt; **Next** to get to the **Networking** tab.
6. For **Container networking**, select **Azure CNI Node Subnet**.
7. Select **Review + create** &gt; **Create**.

# [Azure PowerShell](#tab/configure-networking-powershell)
When you create an AKS cluster by using Azure PowerShell, you can also configure Azure CNI networking.

Use [New-AzAksCluster](/en-us/powershell/module/az.aks/new-azakscluster) to create an AKS cluster with default settings and Azure CNI networking:

```azurepowershell
## Create a resource group for the AKS cluster. ##
$rg = @{
    Name = "test-rg"
    Location = "eastus2"
}
New-AzResourceGroup @rg

$net = @{
      NetworkPlugin = "azure"
      ResourceGroupName = "test-rg"
      Name = "aks-cluster"
}
New-AzAksCluster @net
```

# [Azure CLI](#tab/configure-networking-cli)
When you create an AKS cluster by using the Azure CLI, you can also configure Azure CNI networking.

Use [`az aks create`](/en-us/cli/azure/aks#az-aks-create) with the `--network-plugin azure` argument to create a cluster with [Azure CNI Node Subnet](concepts-network-cni-overview):

```azurecli
az group create \
    --name test-rg \
    --location eastus2

az aks create \
    --resource-group test-rg \
    --name aks-cluster \
    --network-plugin azure \
    --generate-ssh-keys
```

---