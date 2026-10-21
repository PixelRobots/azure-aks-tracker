---
layout: Conceptual
title: Create logical networks for Kubernetes clusters on Azure Local | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/aks-networks
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
description: Learn how to create Arc-enabled logical networks for AKS Hybrid and Edge.
ms.topic: how-to
author: davidsmatlak
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2024-04-01T00:00:00.0000000Z
ms.reviewer: srikantsarwa
ms.custom: hyperconverged
locale: en-us
document_id: cd09a6b9-bb45-2b2e-efa1-7a215a21263f
document_version_independent_id: e26faa8e-6429-d165-ecba-ef3c5f756beb
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/aks-networks.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/aks-networks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/aks-networks.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/289b8734-3abd-4162-bc19-e661c3f4c940
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/6a94795e-9024-410d-b38e-b67941440893
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 7a8d6c39-3383-1384-e0cb-e9c012f84afc
---

# Create logical networks for Kubernetes clusters on Azure Local | Microsoft Learn

> 
> Applies to: AKS on Azure Local

After you install and configure Azure Local, you must create Arc VM logical networks. AKS on Azure Local uses static logical networks to provide IP addresses to the underlying VMs of the AKS clusters.

## Before you begin

Before you begin, make sure you have the following prerequisites:

- Install and configure Azure Local. Make sure you have the custom location Azure Resource Manager ID, as this ID is a required parameter for creating a logical network.
- Make sure that the logical network you create contains enough usable IP addresses to avoid IP address exhaustion. IP address exhaustion can lead to Kubernetes cluster deployment failures. For more information, see [Networking concepts in AKS on Azure Local](network-system-requirements).
- Make sure you have an external VM switch that all the machines in your Azure Local cluster can access. By default, an external switch is created during the deployment of your Azure Local cluster that you can use to associate with the logical network you create.

Run the following command to get the name of the external VM switch on your Azure Local cluster:

```powershell
Get-VmSwitch -SwitchType External
```

Make a note of the name of the switch. You use this information when you create a logical network. For example:

```powershell
Get-VmSwitch -SwitchType External
```

```output
Name                                           SwitchType      NetAdapterInterfaceDescription
----                                           ----------      ----------------------------
ConvergedSwitch(management_compute_storage)    External        Teamed-Interface
```

## Create the logical network

You can create a logical network by using either the Azure CLI or the Azure portal.

# [Azure CLI](#tab/azurecli)
To create a logical network on the VM switch in a static IP configuration, use the [`az stack-hci-vm network lnet create`](/en-us/cli/azure/stack-hci-vm/network/lnet#az-stack-hci-vm-network-lnet-create) command:

```azurecli
az stack-hci-vm network lnet create \
  --subscription $subscription \
  --resource-group $resource_group \
  --custom-location $customLocationID \
  --name $lnetName \
  --vm-switch-name $vmSwitchName \
  --ip-allocation-method "Static" \
  --address-prefixes $addressPrefixes \
  --gateway $gateway \
  --dns-servers $dnsServers \
  --ip-pool-start $ipPoolStart \
  --ip-pool-end $ipPoolEnd \
  --vlan 10
```

For static IP, provide the following required parameters:

| Required parameters | Description |
| --- | --- |
| `--name` | Name for the logical network that you create for your Azure Local cluster. Make sure to provide a name that follows the [rules for Azure resources](/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming#example-names-networking). You can't rename a logical network after it's created. |
| `--resource-group` | Name of the resource group where you create the logical network. |
| `--subscription` | Name or ID of the subscription where your Azure Local is deployed. |
| `--custom-location` | Provide the custom location associated with your Azure Local cluster where you're creating the logical network. |
| `--vm-switch-name` | The name of the VM switch. Usage: `--vm-switch-name "vm-switch-01"`. |
| `--address-prefixes` | AddressPrefix for the network. Currently only one address prefix is supported. Usage: `--address-prefixes "10.220.32.16/24"`. |
| `--dns-servers` | Space-separated list of DNS server IP addresses. Usage: `--dns-servers 10.220.32.16 10.220.32.17`. |
| `--gateway` | Gateway. The gateway IP address must be within the scope of the address prefix. Usage: `--gateway 10.220.32.16`. |
| `--ip-allocation-method` | The IP address allocation method. Supported value is `Static`. Usage: `--ip-allocation-method "Static"`. |
| `--ip-pool-start` | The start IP address of your IP pool. The address must be in range of the address prefix. Usage: `--ip-pool-start "10.220.32.18"`. |
| `--ip-pool-end` | The end IP address of your IP pool. The address must be in range of the address prefix. Usage: `--ip-pool-end "10.220.32.38"`. |
| `--vlan` | The VLAN ID. Usage: `--vlan 10`. This parameter is optional. Specifies the VLAN ID (an int32 value) to use when creating the logical network. |

# [Azure portal](#tab/azureportal)
Complete the following steps to create a logical network using the Azure portal:

1. In the left pane, under **Resources**, select **Logical networks**.

    [![Screenshot showing Resources pane in Azure portal.](../../media/aks-networks/select-logical-network.png)](../../media/aks-networks/select-logical-network.png#lightbox)
2. In the right pane, select **Create logical network**.

    [![Screenshot showing logical network creation link.](../../media/aks-networks/create-logical-network.png)](../../media/aks-networks/create-logical-network.png#lightbox)
3. On **Create logical network**, on the **Basics** tab:

    - Select the Azure subscription name.
    - Select the associated resource group name.
    - Enter a logical network name. Make sure to provide a name that follows the [Rules for Azure resources.](/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming#example-names-networking) You can't rename a logical network after it's created.
    - Enter the virtual switch name that you saved earlier.
    - The geographic region is automatically set to the region where you registered your cluster.
    - The custom location is automatically populated from the cluster.

    When complete, select **Next: Network Configuration**.

    [![Screenshot showing Basics tab.](../../media/aks-networks/enter-network-name.png)](../../media/aks-networks/enter-network-name.png#lightbox)
4. On the **Network configuration** tab, select **Static** and then enter the following values:

    - IPv4 address space (previously reserved).
    - IP pools.
    - Default gateway address.
    - DNS server address.
    - VLAN ID (if used).

    When complete, select **Review + Create**.

    [![Screenshot showing Network configuration tab.](../../media/aks-networks/enter-ip-addresses.png)](../../media/aks-networks/enter-ip-addresses.png#lightbox)
5. On the **Review + Create** tab, review network settings and then select **Create**:

    [![Screenshot showing static network properties page.](../../media/aks-networks/review-and-create-static.png)](../../media/aks-networks/review-and-create-static.png#lightbox)

---