---
layout: Conceptual
title: Create and manage an AKS cluster with disconnected operations | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/disconnected-operations/create-manage-cluster
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
description: Learn how to create and manage an Azure Kubernetes Service (AKS) cluster enabled by Azure Arc for Azure Local with disconnected operations.
ms.topic: how-to
author: davidsmatlak
ms.author: davidsmatlak
ms.date: 2026-10-06T00:00:00.0000000Z
ms.custom: disconnected-operations
ai-usage: ai-assisted
locale: en-us
document_id: 45203981-a756-09ae-aa38-619a9df23eb8
document_version_independent_id: bd502551-094a-a45d-b276-e47eaf481b17
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/disconnected-operations/create-manage-cluster.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/disconnected-operations/create-manage-cluster
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/disconnected-operations/create-manage-cluster.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 46821926-ad09-aa8b-f9ea-f80b5c501a44
---

# Create and manage an AKS cluster with disconnected operations | Microsoft Learn

This article shows you how to install the required Azure CLI extensions, create logical networks, and create, access, and delete an Azure Kubernetes Service (AKS) cluster enabled by Azure Arc for Azure Local with disconnected operations.

Before you continue, review the [prerequisites and limitations](overview) for AKS with disconnected operations.

## Create an AKS cluster

To create an AKS cluster that supports disconnected operations, see [Create an AKS cluster through CLI](../aks-create-clusters-cli#create-a-kubernetes-cluster) and [Create a Kubernetes cluster using the Azure portal](../aks-create-clusters-portal#create-a-kubernetes-cluster).

### Install the Azure CLI extension

Before you install the Azure CLI extension, make sure you have the following installed:

- [Azure CLI](/en-us/azure/azure-local/manage/disconnected-operations-cli?view=azloc-2602&amp;preserve-view=true)
- Extension version:
    - customlocation: 0.1.4
    - aksarc: 1.2.23
    - stack-hci-vm: 1.11.1

Install the CLI extension by using the following commands:

```azurecli
az extension add --name aksarc --version 1.2.23 
az extension add --name stack-hci-vm --version 1.11.1 
az config set core.instance_discovery=false --only-show-errors
```

For more information, see [Install the Azure CLI extension](../aks-create-clusters-cli).

### Sign in with Azure CLI

Use the `az login` command to sign in to your Azure account. For more information, see [Sign in with credentials on the command line](/en-us/cli/azure/authenticate-azure-cli-interactively#sign-in-with-credentials-on-the-command-line).

### Create logical networks

Use the [`az stack-hci-vm network lnet create`](/en-us/cli/azure/stack-hci-vm/network/lnet#az-stack-hci-vm-network-lnet-create) command to create a logical network on the virtual machine (VM) switch in Static IP configuration. For information on limitations, see [Limitations](overview#limitations).

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
  --ip-pool-end $ipPoolEnd
```

For more information, see [Create logical networks](../hyperconverged/aks-networks).

Note

You can create logical networks only through CLI. The portal isn't supported. For more information, see [Azure Local VM limitations](/en-us/azure/azure-local/manage/disconnected-operations-arc-vm#limitations).

### Create the cluster

Use CLI to create the AKS cluster. For more information, see [Create an AKS cluster through CLI](../aks-create-clusters-cli#create-a-kubernetes-cluster).

To use the Azure portal, see [Create a Kubernetes cluster using the Azure portal](../aks-create-clusters-portal#create-a-kubernetes-cluster). To create the SSH keys, see [Generate and store SSH keys with the Azure CLI](/en-us/azure/virtual-machines/ssh-keys-azure-cli).

Use the [`az aksarc create`](/en-us/cli/azure/aksarc#az-aksarc-create) command to create a Kubernetes cluster.

```azurecli
az aksarc create \
  --name $aksclustername \
  --resource-group $resource_group \
  --custom-location $customlocationID \
  --vnet-ids $logicnetId \
  --generate-ssh-keys
```

Note

You receive JSON-formatted information about the cluster when the creation finishes.

Here's a sample script to create logical networks and an AKS cluster.

```azurecli
# Check and update variables according to your environment.

$subscriptionId = " "  # Update the Starter Subscription Id of your environment
$location = "autonomous"
$resourceGroupName = " " # Update the resource group name
$customLocationResourceName = " "   # This name would be referenced in resource group
$customLocationResourceId = "/subscriptions/$SubscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.ExtendedLocation/customLocations/$customLocationResourceName"
  
# IP config detail.
 
$aszhost = <Host Machine> # update with host machine name
# YAML file would be information on the following:  
$vmSwitchName= # The value of vswitchname
$addressPrefixes= # The value of ipaddressprefix
$gateway= # The value of gateway
$dnsservers= # The value of dnsservers
$ipPoolStart= # Set this according to $addressPrefixes, don't overlap k8snodeippoolstart and k8snodeippoolend
$ipPoolEnd= # Set this according to $addressPrefixes, don't overlap k8snodeippoolstart and k8snodeippoolend
  
# Create Logical Network for AKS cluster.

$lNetName = "aksarc-lnet-static"
az stack-hci-vm network lnet create `
--resource-group $resourceGroupName `
--custom-location $customLocationResourceId `
--location $location `
--name $lNetName `
--ip-allocation-method "Static" `
--address-prefixes $addressPrefixes `
--ip-pool-start $ipPoolStart `
--ip-pool-end $ipPoolEnd `
--gateway $gateway `
--dns-servers $dnsservers `
--vm-switch-name $vmSwitchName
  
# Create AKS cluster using az cli.
 
$logicNetId = (az stack-hci-vm network lnet show --resource-group $resourceGroupName --name $lNetName --query id -o tsv)
$aksClusterName = " " # please enter the clustername
$controlPlaneIp = # Set this according to $addressPrefixes, please don't overlap $ipPoolStart and $ipPoolEnd
az aksarc create -n $aksClusterName `
--resource-group $resourceGroupName `
--custom-location $customLocationResourceId `
--node-count 2 `
--vnet-ids $logicNetId `
--generate-ssh-keys `
--control-plane-ip $controlPlaneIp `
--only-show-errors
# --node-vm-size 'Standard_D8s_v3' `
```

### Retrieve `kubeconfig`

To retrieve the `kubeconfig` file for the AKS cluster, use the [`az aksarc get-credentials`](/en-us/cli/azure/aksarc#az-aksarc-get-credentials) command. Use your admin credentials.

Here's an example:

```azurecli
az aksarc get-credentials --resource-group myResourceGroup --name myAKSCluster --admin
```

To retrieve the certificate-based admin kubeconfig for an AKS cluster Hybrid and Edge.

Here's an example:

```azurecli
az aksarc get-credentials \
  --name "sample-aksarccluster" \
  --resource-group "sample-rg" \
  --file C:\AksArc\config-admin \
  --adminkubectl \
  --kubeconfig C:\AksArc\config-admin get ns  
```

For more information, see [Retrieve kubeconfig](../hyperconverged/retrieve-admin-kubeconfig#retrieve-the-certificate-based-admin-kubeconfig-using-az-cli).

### Delete an AKS cluster

Use the [`az aksarc delete`](/en-us/cli/azure/aksarc#az-aksarc-delete) command to delete the AKS cluster you created.

```azurecli
az aksarc delete --name $aksclustername --resource-group $resource_group
```