---
layout: Conceptual
title: 'Quickstart: Create an Azure Linux Virtual Machine in the Azure portal | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/quick-create-vm-portal
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
description: Learn how to quickly create an Azure Linux 4.0 virtual machine in the Azure portal and connect to it over SSH.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.topic: quickstart
ms.date: 2026-04-26T00:00:00.0000000Z
locale: en-us
document_id: 27464b2e-cadc-efb1-fe09-9318fe6e9eaa
document_version_independent_id: 0e221ffe-a700-bfd4-3194-384be7ca5e49
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/quick-create-vm-portal.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/quick-create-vm-portal
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/quick-create-vm-portal.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/2ed91286-6cf7-4b83-810d-75d0ee3b09dd
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/6735bd7e-4f7b-457d-b58c-29e6f0198677
platformId: 804a8ffd-a9bd-8420-aa26-659370de0a04
---

# Quickstart: Create an Azure Linux Virtual Machine in the Azure portal | Microsoft Learn

Azure Linux for Virtual Machines provides a Microsoft-supported, Azure-optimized Linux distribution for scalable web apps, infrastructure services, and AI workloads. It integrates natively with Azure services, extensions, and tooling, and includes Microsoft-managed security response and lifecycle support. For more information, see [Azure Linux for Virtual Machines](azure-linux-vm-vmss-overview).

In this quickstart, you learn how to:

- Create an Azure Linux 4.0 VM in the Azure portal.
- Configure SSH access and inbound port rules.
- Connect to the VM over SSH.
- Clean up resources.

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## Prerequisites

- An Azure subscription. If you don't have one, create a [free account](https://azure.microsoft.com/free/) before you begin.

## Create a virtual machine

1. Sign in to the [Azure portal](https://portal.azure.com).
2. Search for **Virtual machines** and select **Create** &gt; **Virtual machine**.

### Configure the Basics tab

1. Under **Project details**, select your **Subscription** and create a new **Resource group** named `myResourceGroup`.
2. Under **Instance details**, configure the following settings:

    | Setting | Value |
    | --- | --- |
    | **VM name** | `myVM` |
    | **Availability options** | No infrastructure redundancy required |
    | **Security type** | Standard |
    | **Image** | Azure Linux 4.0 |
    | **Size** | Use defaults (varies by region) |
3. Under **Administrator account**, configure the following settings:

    | Setting | Value |
    | --- | --- |
    | **Authentication type** | SSH public key |
    | **Username** | `azureuser` |
    | **SSH key source** | Generate new key pair |
    | **Key pair name** | `myKey` |
4. Under **Inbound port rules**, set **Public inbound ports** to **Allow selected ports** and select **SSH (22)** and **HTTP (80)**.
5. Select **Review + create** &gt; **Create**.

### Download the SSH key

When prompted, select **Download private key and create resource** and save the `myKey.pem` file to an accessible location.

### Get the public IP address of the VM

1. After deployment completes, select **Go to resource**.
2. On the VM's **Overview** page, copy the **Public IP address**.

## Connect to the VM

1. Set permissions on the key file (macOS/Linux):

    ```bash
    chmod 400 ~/Downloads/myKey.pem
    ```
2. SSH into the VM. Replace `<PUBLIC_IP>` with the IP address you copied:

    ```bash
    ssh -i ~/Downloads/myKey.pem azureuser@<PUBLIC_IP>
    ```

    Tip

    You can reuse this SSH key for future VMs by selecting **Use a key stored in Azure** when creating a new VM.

## Clean up resources

When you no longer need the VM, delete the resource group to remove all associated resources using the following steps:

1. Open the **Overview** page for the VM in the Azure portal.
2. Select the **Resource group** link.
3. Select **Delete resource group**.
4. Enter the resource group name to confirm, and then select **Delete**.

Tip

To avoid charges without deleting the VM, you can enable **Auto-shutdown** under **Operations** &gt; **Auto-shutdown** on the VM page in the portal.