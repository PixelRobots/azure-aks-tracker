---
layout: Conceptual
title: Restrict Access to Azure Container Registry Using Service Endpoints - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-vnet
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/62/azure-container-registry/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/180a533d-0d25-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: KumudD
learn_banner_products:
- azure
manager: kumud
ms.reviewer: kumud
ms.author: kumud
ms.service: azure-container-registry
description: Restrict access to an Azure container registry using a service endpoint in an Azure virtual network.
ms.topic: how-to
ms.custom: devx-track-azurecli
ms.date: 2023-10-31T00:00:00.0000000Z
locale: en-us
document_id: 5bb583eb-86b2-5383-350c-985f66de2dd6
document_version_independent_id: d08f5439-4db8-f9d0-eeb4-c1f4656fe0fa
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-vnet.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-vnet
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-vnet.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/20ed8455-bc18-4537-87a4-83784e7b2a39
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/9a7f703b-30bb-4d62-9eb4-97213f571849
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 55338a1a-4622-fb6a-4b9f-455ebdee7dfe
---

# Restrict Access to Azure Container Registry Using Service Endpoints - Azure Container Registry | Microsoft Learn

[Azure Virtual Network](/en-us/azure/virtual-network/virtual-networks-overview) provides secure, private networking for your Azure and on-premises resources. By using a [service endpoint](/en-us/azure/virtual-network/virtual-network-service-endpoints-overview), you can secure your container registry's public IP address to only your virtual network. This endpoint gives traffic an optimal route to the resource over the Azure backbone network. The identities of the virtual network and the subnet are also transmitted with each request.

This article shows how to configure a container registry service endpoint (preview) in a virtual network.

Important

Azure Container Registry now supports [Azure Private Link](container-registry-private-endpoints), enabling private endpoints from a virtual network to be placed on a registry. We recommend using private endpoints instead of service endpoints in most network scenarios. Private endpoints are accessible from within the virtual network, using private IP addresses. The container registry doesn't support enabling both private link and service endpoint features configured from a virtual network. Run the list and remove the [network rules](container-registry-vnet#remove-network-rules) as required.

Configuring a registry service endpoint is available in the **Premium** container registry service tier. For information about registry service tiers and limits, see [Azure Container SKU features and limits](container-registry-skus). Each Premium registry supports a maximum of 100 virtual network rules.

## Preview limitations

Keep in mind the following current limitations when using service endpoints to restrict access to a container registry:

- You can't use the Azure portal to configure service endpoints on a registry.
- Only an [Azure Kubernetes Service](/en-us/azure/aks/intro-kubernetes) cluster or Azure [virtual machine](/en-us/azure/virtual-machines/linux/overview) can be used as a host to access a container registry by using a service endpoint. Other Azure services, including Azure Container Instances, aren't supported.
- Service endpoints for Azure Container Registry aren't supported in the Azure US Government cloud or Microsoft Azure operated by 21Vianet cloud.

Important

If your container registry restricts access to private endpoints, selected subnets, or IP addresses, some functionality might be unavailable or require more configuration.

- When you disable public network access to a registry, certain [trusted services](allow-access-trusted-services), including Microsoft Defender for Cloud, can access the registry only if you enable a network setting to bypass the network rules.
- Once you disable the public network access, instances of certain Azure services, including Azure DevOps Services, can't access the container registry.
- Private endpoints aren't currently supported with agents managed by Azure DevOps. You need to use a self-hosted agent with network line of sight to the private endpoint.
- If the registry has an approved private endpoint and you disable public network access, you can't list repositories and tags outside the virtual network by using the Azure portal, Azure CLI, or other tools.

## Prerequisites

- To use the Azure CLI steps in this article, you need Azure CLI version 2.0.58 or later. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- If you don't already have a container registry, create one (Premium tier required) and push a sample image such as `hello-world` from Docker Hub. For example, use the [Azure portal](container-registry-get-started-portal) or the [Azure CLI](container-registry-get-started-azure-cli) to create a registry.
- To restrict registry access by using a service endpoint in a different Azure subscription, register the resource provider for Azure Container Registry in that subscription. For example:

    ```azurecli
    az account set --subscription <Name or ID of subscription of virtual network>
    
    az provider register --namespace Microsoft.ContainerRegistry
    ```

## Create a Docker-enabled virtual machine

For test purposes, use a Docker-enabled Ubuntu VM to access an Azure container registry. To use Microsoft Entra authentication to the registry, also install the [Azure CLI](/en-us/cli/azure/install-azure-cli) on the VM. If you already have an Azure virtual machine, skip this creation step.

You can use the same resource group for your virtual machine and your container registry. This setup simplifies clean-up at the end, but isn't required. If you create a separate resource group for the virtual machine and virtual network, run [az group create](/en-us/cli/azure/group#az-group-create). The following example assumes you've set environment variables for the resource group name and registry location:

```azurecli
az group create --name $RESOURCE_GROUP --location $REGISTRY_LOCATION
```

Now deploy a default Ubuntu Azure virtual machine with [az vm create](/en-us/cli/azure/vm#az-vm-create). The following example creates a VM named *myDockerVM*:

```azurecli
VM_NAME=myDockerVM

az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --generate-ssh-keys
```

It takes a few minutes for the VM to be created. After the command completes, take note of the `publicIpAddress` displayed by the Azure CLI. Use this address to make SSH connections to the VM.

### Install Docker on the VM

After the VM is running, make an SSH connection to the VM. Replace *publicIpAddress* with the public IP address of your VM.

```bash
ssh azureuser@publicIpAddress
```

Run the following commands to install Docker on the Ubuntu VM:

```bash
sudo apt-get update
sudo apt install docker.io -y
```

After installation, run the following command to verify that Docker is running properly on the VM:

```bash
sudo docker run -it hello-world
```

You should see output confirming that your installation appears to be working correctly.

### Install the Azure CLI

Follow the steps in [Install Azure CLI with apt](/en-us/cli/azure/install-azure-cli-linux?pivots=apt) to install the Azure CLI on your Ubuntu virtual machine. For example:

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

Exit the SSH connection.

## Configure network access for registry

Follow these steps to configure your container registry to allow access from a subnet in an Azure virtual network by using the Azure CLI.

### Add a service endpoint to a subnet

When you create a VM, Azure creates a virtual network in the same resource group by default. The name of the virtual network is based on the name of the virtual machine. For example, if you name your virtual machine *myDockerVM*, the default virtual network name is *myDockerVMVNET*, with a subnet named *myDockerVMSubnet*. Verify this configuration by using the [az network vnet list](/en-us/cli/azure/network/vnet/#az-network-vnet-list) command:

```azurecli
az network vnet list \
  --resource-group myResourceGroup \
  --query "[].{Name: name, Subnet: subnets[0].name}"
```

Output:

```output
[
  {
    "Name": "myDockerVMVNET",
    "Subnet": "myDockerVMSubnet"
  }
]
```

Use the [az network vnet subnet update](/en-us/cli/azure/network/vnet/subnet/#az-network-vnet-subnet-update) command to add a **Microsoft.ContainerRegistry** service endpoint to your subnet. Substitute the names of your virtual network and subnet in the following command:

```azurecli
az network vnet subnet update \
  --name myDockerVMSubnet \
  --vnet-name myDockerVMVNET \
  --resource-group myResourceGroup \
  --service-endpoints Microsoft.ContainerRegistry
```

Use the [az network vnet subnet show](/en-us/cli/azure/network/vnet/subnet/#az-network-vnet-subnet-show) command to retrieve the resource ID of the subnet. You need this ID to configure a network access rule.

```azurecli
az network vnet subnet show \
  --name myDockerVMSubnet \
  --vnet-name myDockerVMVNET \
  --resource-group myResourceGroup \
  --query "id"
  --output tsv
```

Output:

```output
/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup/providers/Microsoft.Network/virtualNetworks/myDockerVMVNET/subnets/myDockerVMSubnet
```

### Change default network access to registry

By default, an Azure container registry allows connections from hosts on any network. To limit access to a selected network, change the default action to deny access. Substitute the name of your registry in the following [az acr update](/en-us/cli/azure/acr#az-acr-update) command:

```azurecli
az acr update --name myContainerRegistry --default-action Deny
```

### Add network rule to registry

Use the [az acr network-rule add](/en-us/cli/azure/acr/network-rule/#az-acr-network-rule-add) command to add a network rule to your registry that allows access from the VM's subnet. Substitute the container registry's name and the resource ID of the subnet in the following command:

```azurecli
az acr network-rule add \
  --name mycontainerregistry \
  --subnet <subnet-resource-id>
```

## Verify access to the registry

After waiting a few minutes for the configuration to update, verify that the VM can access the container registry. Make an SSH connection to your VM, and run the [az acr login](/en-us/cli/azure/acr#az-acr-login) command to authenticate to your registry.

```azurecli
az acr login --name mycontainerregistry
```

You can perform registry operations such as run `docker pull` to pull a sample image from the registry. Substitute an image and tag value appropriate for your registry, prefixed with the registry login server name (all lowercase):

```bash
docker pull mycontainerregistry.azurecr.io/hello-world:v1
```

Docker successfully pulls the image to the VM.

This example demonstrates that you can access the private container registry through the network access rule. However, the registry can't be accessed from a login host that doesn't have a network access rule configured. If you attempt to authenticate from another host using the `az acr login` command or `docker login` command, you see output similar to the following:

```output
Error response from daemon: login attempt to https://xxxxxxx.azurecr.io/v2/ failed with status: 403 Forbidden
```

## Restore default registry access

To restore the registry to allow access by default, remove any network rules that you configured. Then set the default action to allow access.

### Remove network rules

To see a list of network rules configured for your registry, run the following [az acr network-rule list](/en-us/cli/azure/acr/network-rule/#az-acr-network-rule-list) command:

```azurecli
az acr network-rule list --name mycontainerregistry 
```

For each rule that you configured, run the [az acr network-rule remove](/en-us/cli/azure/acr/network-rule/#az-acr-network-rule-remove) command to remove it. For example:

```azurecli
# Remove a rule that allows access for a subnet. Substitute the subnet resource ID.

az acr network-rule remove \
  --name mycontainerregistry \
  --subnet /subscriptions/ \
  xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup/providers/Microsoft.Network/virtualNetworks/myDockerVMVNET/subnets/myDockerVMSubnet
```

### Allow access

Substitute the name of your registry in the following [az acr update](/en-us/cli/azure/acr#az-acr-update) command: '

```azurecli
az acr update --name myContainerRegistry --default-action Allow
```

## Clean up resources

If you created all the Azure resources in the same resource group and you no longer need them, you can delete the entire resource group by using the [az group delete](/en-us/cli/azure/group) command:

```azurecli
az group delete --name myResourceGroup
```