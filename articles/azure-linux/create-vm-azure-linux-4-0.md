---
layout: Conceptual
title: Create an Azure Virtual Machine (VM) using Azure Linux 4.0 | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/create-vm-azure-linux-4-0
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/133/azure
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/79b1327d-d925-ec11-b6e6-000d3a4f06a4
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
manager: kumud
description: This article shows you how to create an Azure Linux 4.0 virtual machine (VM) on Azure using the Azure portal, Azure CLI, an ARM template, or Terraform.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: how-to
ms.date: 2026-04-27T00:00:00.0000000Z
locale: en-us
document_id: 088c9cc0-58a4-2526-19e5-83db068574e9
document_version_independent_id: 13e01ae2-a1ce-cee6-d1c6-0e9f9a8623cd
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/create-vm-azure-linux-4-0.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/create-vm-azure-linux-4-0
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/create-vm-azure-linux-4-0.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 78a3f51d-da80-e85c-fa23-354d46c66b1d
---

# Create an Azure Virtual Machine (VM) using Azure Linux 4.0 | Microsoft Learn

This article shows you how to create an Azure Linux 4.0 virtual machine (VM) on Azure using the Azure portal, the Azure CLI, an ARM template, or Terraform.

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## Prerequisites

- An Azure subscription. If you don't have one, [create a free account](https://azure.microsoft.com/free/).
- For CLI-based methods:
    - Install the [Azure CLI](/en-us/cli/azure/install-azure-cli).
    - Sign in using the [`az login`](/en-us/cli/azure/authenticate-azure-cli) command.
- For Terraform:
    - [Terraform](https://www.terraform.io/) and the [Azure provider](/en-us/azure/developer/terraform/get-started-cloud-shell-bash?tabs=bash) configured for your subscription.

## Create an Azure Linux 4.0 VM

# [Azure portal](#tab/azure-portal)
For a guided, UI-driven walkthrough, go to the [Launch an Azure Linux VM](create-vm-azure-linux-4-0) quickstart.

# [Azure CLI](#tab/azure-cli)
1. Create an Azure resource group using the [`az group create`](/en-us/cli/azure/group#az_group_create) command. Replace the placeholder values with your own values.

    ```azurecli
    az group create --name <resource-group-name> --location <location>
    ```
2. Create an Azure VM using an Azure Linux 4.0 Marketplace image using the [`az vm create`](/en-us/cli/azure/vm#az_vm_create) command. Replace the placeholder values with your own values.

    ```azurecli
    az vm create \
      --resource-group <resource-group-name> \
      --name <vm-name> \
      --image microsoftazurelinux:azurelinux-4:4:latest \
      --admin-username azureuser \
      --generate-ssh-keys
    ```

# [ARM template](#tab/arm-template)
Deploy an Azure Linux 4.0 VM with an ARM template by setting the `storageProfile` of your `Microsoft.Compute/virtualMachines` resource to reference an Azure Linux 4.0 Marketplace image. For example:

```json
"storageProfile": {
  "imageReference": {
    "publisher": "microsoftazurelinux",
    "offer": "azurelinux-4",
    "sku": "4",
    "version": "latest"
  },
  "osDisk": {
    "createOption": "fromImage"
  }
}
```

For a complete ARM Template example and step-by-step deployment instructions, see the [Create and deploy your first ARM template](/en-us/azure/azure-resource-manager/templates/template-tutorial-create-first-template?tabs=azure-powershell) tutorial.

# [Terraform](#tab/terraform)
Deploy an Azure Linux 4.0 VM with Terraform by setting the `source_image_reference` to reference an Azure Linux 4.0 Marketplace image. For example:

```hcl
  source_image_reference {
    publisher = "microsoftazurelinux"
    offer     = "azurelinux-4"
    sku       = "4"
    version   = "latest"
  }
```

For a complete `main.tf` example and step-by-step deployment instructions, see the [Create a Linux VM with Terraform](/en-us/azure/developer/terraform/create-linux-virtual-machine-with-infrastructure) quickstart.

---

## Connect to your Azure Linux 4.0 VM

Connect to your Azure Linux VM over SSH using the guidance in [Connect to a Linux VM in Azure](/en-us/azure/virtual-machines/linux-vm-connect).