---
layout: Conceptual
title: Troubleshoot SubnetIsFull error during AKS cluster upgrade - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/subnetisfull-error
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: kaushika-msft
ms.author: kaushika
ms.topic: troubleshooting
description: Resolve the SubnetIsFull error during an AKS cluster upgrade. Learn how to fix IP address capacity issues and complete your upgrade successfully.
ms.date: 2026-07-10T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: chiragpa, albarqaw, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: 1ee007df-37f3-1657-c3b1-44d644322b5a
document_version_independent_id: 1ee007df-37f3-1657-c3b1-44d644322b5a
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/subnetisfull-error.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/subnetisfull-error
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/subnetisfull-error.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 1ed20ec3-9df5-1c06-9fd2-3674de937e65
---

# Troubleshoot SubnetIsFull error during AKS cluster upgrade - Azure | Microsoft Learn

## Summary

This article explains how to identify and resolve the SubnetIsFull error that occurs when you upgrade an Azure Kubernetes Service (AKS) cluster. It helps you complete the upgrade successfully.

Here's an example of the error message:

> 
> Failed to scale node pool &lt;AGENT POOL NAME&gt;' in Kubernetes service '&lt;NAME&gt;'. Error: VMSSAgentPoolReconciler retry failed: Code='SubnetIsFull' Message='&lt;SUBNET NAME&gt;\ with address prefix &lt;PREFIX&gt;\ doesn't have enough capacity for IP addresses.' Details=[]

## Prerequisites

This article requires Azure CLI version 2.0.65 or a later version. To find the version number, run `az --version`. If you need to install or upgrade Azure CLI, see [How to install the Azure CLI](/en-us/cli/azure/install-azure-cli).

For more detailed information about the upgrade process, see the "Upgrade an AKS cluster" section in [Upgrade an Azure Kubernetes Service (AKS) cluster](/en-us/azure/aks/upgrade-cluster#upgrade-an-aks-cluster).

## Symptoms

An AKS cluster upgrade fails, and you receive a "SubnetIsFull" error message.

## Cause

This error occurs if your cluster doesn't have enough IP addresses to create a new node.

When you plan an upgrade or scaling operation, consider the number of required IP addresses. If the IP address range that you configured in the cluster supports only a fixed number of nodes, the upgrade or scaling operation fails. For more information, see [IP address planning for your Azure Kubernetes Service (AKS) clusters](/en-us/azure/aks/concepts-network-ip-address-planning).

## Check the available IPs in the subnet

Before taking corrective action, verify how many IP addresses are available in the subnet that's associated with your AKS cluster.

To check the available IP addresses in the [Azure portal](https://portal.azure.com):

1. Go to the **Virtual networks** service.
2. Select the virtual network that's associated with your AKS cluster.
3. In the menu, select **Subnets**.
4. Review the **Available IPs** column for the subnet that your cluster uses.

Alternatively, you can run the following Azure CLI commands to check available IPs:

```azurecli
# Get the subnet resource ID for the node pool.
# For clusters that use a custom VNet, the subnet ID is stored in the agent pool profile:
SUBNET_ID=$(az aks show \
    --resource-group <RESOURCE_GROUP> \
    --name <CLUSTER_NAME> \
    --query "agentPoolProfiles[0].vnetSubnetId" \
    --output tsv)

# If the cluster uses a managed VNet (SUBNET_ID is empty),
# retrieve the subnet from the node resource group instead:
if [[ -z "$SUBNET_ID" ]]; then
    NODE_RESOURCE_GROUP=$(az aks show \
        --resource-group <RESOURCE_GROUP> \
        --name <CLUSTER_NAME> \
        --query "nodeResourceGroup" \
        --output tsv)

    SUBNET_ID=$(az network vnet list \
        --resource-group "$NODE_RESOURCE_GROUP" \
        --query "[0].subnets[0].id" \
        --output tsv)
fi

# Display the subnet details and calculate available IPs
az network vnet subnet show \
    --ids "$SUBNET_ID" \
    --query "{SubnetName:name, AddressPrefix:addressPrefix, UsedIPs:length(ipConfigurations || \`[]\`)}" \
    --output json | jq -r '
    .AddressPrefix as $prefix |
    ($prefix | split("/")[1] | tonumber) as $prefixLen |
    pow(2; 32 - $prefixLen) as $totalIPs |
    5 as $reserved |
    (.UsedIPs // 0) as $used |
    ($totalIPs - $reserved - $used) as $available |
    ["SubnetName", "AddressPrefix", "TotalIPs", "UsedIPs", "AzureReserved", "AvailableIPs"],
    [.SubnetName, $prefix, ($totalIPs | tostring), ($used | tostring), ($reserved | tostring), ($available | tostring)]
    | @tsv' | column -t
```

The output resembles the following example:

```output
SubnetName  AddressPrefix  TotalIPs  UsedIPs  AzureReserved  AvailableIPs
aks-subnet  xx.xxx.x.x/16  65536     327      5              65204
```

Note

This script requires [jq](https://jqlang.github.io/jq/) to be installed. Azure reserves five (5) IP addresses in each subnet. For more information, see [Are there any restrictions on using IP addresses within these subnets?](/en-us/azure/virtual-network/virtual-networks-faq#are-there-any-restrictions-on-using-ip-addresses-within-these-subnets).

If the number of available IPs is low (for example, fewer than the number of nodes you're adding during the upgrade), proceed with the solution in the next section.

## Solution

Important

The steps in this section are **preventive**. They're effective when applied *before* an upgrade or scale operation that would otherwise exhaust the subnet. If the upgrade has already failed and the affected node pool is in a `Failed` provisioning state, also follow the steps in Recovery when the node pool is in a Failed provisioning state.

Reduce the cluster nodes to reserve IP addresses for the upgrade.

If scaling down isn't an option, and your virtual network CIDR has enough IP addresses, try to add a node pool that has a [unique subnet](/en-us/azure/aks/use-multiple-node-pools#add-a-node-pool-with-a-unique-subnet-preview):

1. Add a new user node pool in the virtual network on a larger subnet.
2. Switch the original node pool to a system node pool type.
3. Scale up the user node pool.
4. Scale down the original node pool.

## Recovery when the node pool is in a Failed provisioning state

When an upgrade fails with `SubnetIsFull`, the affected AKS node pool and its underlying Virtual Machine Scale Set (VMSS) can be left in a `Failed` provisioning state. To check the state, run:

```azurecli
az aks nodepool show \
    --resource-group <RESOURCE_GROUP> \
    --cluster-name <CLUSTER_NAME> \
    --name <NODEPOOL_NAME> \
    --query "provisioningState" \
    --output tsv
```

After the node pool is in this state:

- Subsequent operations against the same node pool (such as `az aks nodepool scale`, `az aks nodepool upgrade`, or retrying the original upgrade) **aren't guaranteed to succeed**, even after IP addresses are freed by scaling down other node pools.
- Freeing IP addresses *after* the failure isn't a reliable recovery mechanism on its own.

The recommended recovery path is to add a new node pool in a subnet with sufficient IP capacity and move workloads off the failed pool:

1. Add a new node pool in a subnet that has enough free IPs for your target node count and `maxPods` setting. See [Add a node pool with a unique subnet](/en-us/azure/aks/use-multiple-node-pools#add-a-node-pool-with-a-unique-subnet-preview).
2. [Cordon and drain](/en-us/azure/aks/upgrade-cluster#optional-settings) workloads from the failed node pool so they're rescheduled to the new node pool.
3. Delete the failed node pool by using `az aks nodepool delete`.
4. Plan future upgrades by using [IP address planning for AKS clusters](/en-us/azure/aks/concepts-network-ip-address-planning) to avoid recurrence.

Note

Don't rely on scaling the failed node pool to zero and back up as a recovery mechanism. This pattern isn't guaranteed to reconcile a VMSS that's already in a `Failed` provisioning state because of `SubnetIsFull`. If the cluster has only one node pool and it's in this state, contact [Azure support](https://azure.microsoft.com/support/create-ticket/) before attempting destructive operations.

## Resources

- [InsufficientSubnetSize error code](../connectivity/insufficientsubnetsize-error-advanced-networking)