---
layout: Conceptual
title: Create virtual nodes in Azure Kubernetes Service (AKS) using Azure CLI - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/virtual-nodes-cli
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
description: Learn how to use Azure CLI to create an Azure Kubernetes Services (AKS) cluster that uses virtual nodes to run pods.
ms.topic: concept-article
ms.date: 2023-08-28T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: references_regions, devx-track-azurecli
ms.subservice: aks-nodes
ai-usage: ai-assisted
locale: en-us
document_id: 76ad7e7b-18b3-57c0-24a5-53576cc75643
document_version_independent_id: 95bcce24-48db-9b52-afa7-1b06f09c1902
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/virtual-nodes-cli.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/virtual-nodes-cli
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/virtual-nodes-cli.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/20ed8455-bc18-4537-87a4-83784e7b2a39
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/9a7f703b-30bb-4d62-9eb4-97213f571849
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 1e725812-0fb0-6d74-0d58-9389f27938fe
---

# Create virtual nodes in Azure Kubernetes Service (AKS) using Azure CLI - Azure Kubernetes Service | Microsoft Learn

Virtual nodes enable network communication between pods that run in Azure Container Instances (ACI) and AKS clusters. To provide this communication, you create a virtual network subnet and assign delegated permissions. Virtual nodes only work with AKS clusters created using *advanced* networking (Azure CNI). By default, AKS clusters are created with *basic* networking (kubenet). This article shows you how to create a virtual network and subnets, then deploy an AKS cluster that uses advanced networking.

This article shows you how to use the Azure CLI to create and configure virtual network resources and an AKS cluster enabled with virtual nodes.

## Before you begin

Important

Before using virtual nodes with AKS, review both the [limitations of AKS virtual nodes](virtual-nodes) and the [virtual networking limitations of ACI](/en-us/azure/container-instances/container-instances-virtual-network-concepts). These limitations affect the location, networking configuration, and other configuration details of both your AKS cluster and the virtual nodes.

- You need the ACI service provider registered with your subscription. You can check the status of the ACI provider registration using the [`az provider list`](/en-us/cli/azure/provider#az-provider-list) command.

    ```azurecli
    az provider list --query "[?contains(namespace,'Microsoft.ContainerInstance')]" -o table
    ```

    The *Microsoft.ContainerInstance* provider should report as *Registered*, as shown in the following example output:

    ```output
    Namespace                    RegistrationState    RegistrationPolicy
    ---------------------------  -------------------  --------------------
    Microsoft.ContainerInstance  Registered           RegistrationRequired
    ```

    If the provider shows as *NotRegistered*, register the provider using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register).

    ```azurecli
    az provider register --namespace Microsoft.ContainerInstance
    ```
- If using Azure CLI, this article requires Azure CLI version 2.0.49 or later. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli). You can also use Azure Cloud Shell.

### Launch Azure Cloud Shell

The Azure Cloud Shell is a free interactive shell you can use to run the steps in this article. It has common Azure tools preinstalled and configured.

To open the Cloud Shell, select **Try it** from the upper right corner of a code block. You can also launch Cloud Shell in a separate browser tab by going to https://shell.azure.com/bash. Select **Copy** to copy the blocks of code, paste it into the Cloud Shell, and press enter to run it.

## Create a resource group

An Azure resource group is a logical group in which Azure resources are deployed and managed.

- Create a resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    az group create --name myResourceGroup --location eastus
    ```

## Create a virtual network

Important

Virtual node requires a custom virtual network and associated subnet. It can't be associated with the same virtual network as the AKS cluster.

1. Create a virtual network using the [`az network vnet create`](/en-us/cli/azure/network/vnet#az-network-vnet-create) command. The following example creates a virtual network named *myVnet* with an address prefix of *10.0.0.0/8* and a subnet named *myAKSSubnet*. The address prefix of this subnet defaults to *10.240.0.0/16*.

    ```azurecli
    az network vnet create \
        --resource-group myResourceGroup \
        --name myVnet \
        --address-prefixes 10.0.0.0/8 \
        --subnet-name myAKSSubnet \
        --subnet-prefix 10.240.0.0/16
    ```
2. Create an extra subnet for the virtual nodes using the [`az network vnet subnet create`](/en-us/cli/azure/network/vnet/subnet#az-network-vnet-subnet-create) command. The following example creates a subnet named *myVirtualNodeSubnet* with an address prefix of *10.241.0.0/16*.

    ```azurecli
    az network vnet subnet create \
        --resource-group myResourceGroup \
        --vnet-name myVnet \
        --name myVirtualNodeSubnet \
        --address-prefixes 10.241.0.0/16
    ```

## Create an AKS cluster with managed identity

1. Get the subnet ID using the [`az network vnet subnet show`](/en-us/cli/azure/network/vnet/subnet#az-network-vnet-subnet-show) command.

    ```azurecli
    az network vnet subnet show --resource-group myResourceGroup --vnet-name myVnet --name myAKSSubnet --query id -o tsv
    ```
2. Create an AKS cluster using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command and replace `<subnetId>` with the ID obtained in the previous step. The following example creates a cluster named *myAKSCluster* with five nodes.

    ```azurecli
    az aks create \
        --resource-group myResourceGroup \
        --name myAKSCluster \
        --node-count 5 \
        --network-plugin azure \
        --vnet-subnet-id <subnetId> \
        --generate-ssh-keys
    ```

    After several minutes, the command completes and returns JSON-formatted information about the cluster.

For more information on managed identities, see [Use managed identities](use-managed-identity).

## Enable the virtual nodes add-on

Note

If you have an existing Azure Kubernetes Service Cluster created that uses Azure CNI for the Advanced Networking you should be able to enable virtual nodes as an add-on using the CLI.

- Enable virtual nodes using the [`az aks enable-addons`](/en-us/cli/azure/aks#az-aks-enable-addons) command. The following example uses the subnet named *myVirtualNodeSubnet* created in a previous step.

    ```azurecli
    az aks enable-addons \
        --resource-group myResourceGroup \
        --name myAKSCluster \
        --addons virtual-node \
        --subnet-name myVirtualNodeSubnet
    ```

## Grant permission to the managed identity

Grant the *Network Contributor* role on the subnet used by virtual nodes to the managed identity for the virtual node add-on named *aciconnectorlinux-&lt;aks-cluster-name&gt;*.

```azurecli
NODE_RG=$(az aks show --resource-group myResourceGroup --name myAKSCluster --query nodeResourceGroup -o tsv)
PRINCIPAL_ID=$(az identity show --resource-group $NODE_RG --name aciconnectorlinux-myAKSCluster --query principalId -o tsv)
VIRTUAL_NODE_SUBNET_ID=$(az network vnet subnet show --resource-group myResourceGroup --vnet-name <VNET_NAME> --name myVirtualNodeSubnet --query id -o tsv)
az role assignment create --assignee $PRINCIPAL_ID --role "Network Contributor" --scope $VIRTUAL_NODE_SUBNET_ID
```

## Connect to the cluster

1. Configure `kubectl` to connect to your Kubernetes cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command. This step downloads credentials and configures the Kubernetes CLI to use them.

    ```azurecli
    az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
    ```
2. Verify the connection to your cluster using the [`kubectl get`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command, which returns a list of the cluster nodes.

    ```console
    kubectl get nodes
    ```

    The following example output shows the single VM node created and the virtual node for Linux, *virtual-node-aci-linux*:

    ```output
    NAME                          STATUS    ROLES     AGE       VERSION
    virtual-node-aci-linux        Ready     agent     28m       v1.11.2
    aks-agentpool-14693408-0      Ready     agent     32m       v1.11.2
    ```

## Deploy a sample app

1. Create a file named `virtual-node.yaml` and copy in the following YAML. The YAML schedules the container on the node by defining a [nodeSelector](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) and [toleration](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/).

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: aci-helloworld
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: aci-helloworld
      template:
        metadata:
          labels:
            app: aci-helloworld
        spec:
          containers:
          - name: aci-helloworld
            image: mcr.microsoft.com/azuredocs/aci-helloworld
            ports:
            - containerPort: 80
          nodeSelector:
            kubernetes.io/role: agent
            kubernetes.io/os: linux
            type: virtual-kubelet
          tolerations:
          - key: virtual-kubelet.io/provider
            operator: Exists
          - key: azure.com/aci
            effect: NoSchedule
    ```
2. Run the application using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command.

    ```console
    kubectl apply -f virtual-node.yaml
    ```
3. Get a list of pods and the scheduled node using the [`kubectl get pods`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command with the `-o wide` argument.

    ```console
    kubectl get pods -o wide
    ```

    The pod is scheduled on the virtual node *virtual-node-aci-linux*, as shown in the following example output:

    ```output
    NAME                            READY     STATUS    RESTARTS   AGE       IP           NODE
    aci-helloworld-9b55975f-bnmfl   1/1       Running   0          4m        10.241.0.4   virtual-node-aci-linux
    ```

    The pod is assigned an internal IP address from the Azure virtual network subnet delegated for use with virtual nodes.

Note

If you use images stored in Azure Container Registry, [configure and use a Kubernetes secret](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/). A current limitation of virtual nodes is you can't use integrated Microsoft Entra service principal authentication. If you don't use a secret, pods scheduled on virtual nodes fail to start and report the error `HTTP response status code 400 error code "InaccessibleImage"`.

## Test the virtual node pod

1. Test the pod running on the virtual node by browsing to the demo application with a web client. As the pod is assigned an internal IP address, you can quickly test this connectivity from another pod on the AKS cluster.
2. Create a test pod and attach a terminal session to it using the following `kubectl run -it` command.

    ```console
    kubectl run -it --rm testvk --image=mcr.microsoft.com/dotnet/runtime-deps:6.0
    ```
3. Install `curl` in the pod using `apt-get`.

    ```console
    apt-get update && apt-get install -y curl
    ```
4. Access the address of your pod using `curl`, such as *http://10.241.0.4*. Provide your own internal IP address shown in the previous `kubectl get pods` command.

    ```console
    curl -L http://10.241.0.4
    ```

    The demo application is displayed, as shown in the following condensed example output:

    ```output
    <html>
    <head>
      <title>Welcome to Azure Container Instances!</title>
    </head>
    [...]
    ```
5. Close the terminal session to your test pod with `exit`. When your session is ends, the pod is deleted.

## Remove virtual nodes

1. Delete the `aci-helloworld` pod running on the virtual node using the `kubectl delete` command.

    ```console
    kubectl delete -f virtual-node.yaml
    ```
2. Disable the virtual nodes using the [`az aks disable-addons`](/en-us/cli/azure/aks#az-aks-disable-addons) command.

    ```azurecli
    az aks disable-addons --resource-group myResourceGroup --name myAKSCluster --addons virtual-node
    ```
3. Remove the virtual network resources and resource group using the following commands.

    ```azurecli
    # Change the name of your resource group, cluster and network resources as needed
    RES_GROUP=myResourceGroup
    AKS_CLUSTER=myAKScluster
    AKS_VNET=myVnet
    AKS_SUBNET=myVirtualNodeSubnet
    
    # Get AKS node resource group
    NODE_RES_GROUP=$(az aks show --resource-group $RES_GROUP --name $AKS_CLUSTER --query nodeResourceGroup --output tsv)
    
    # Get network profile ID
    NETWORK_PROFILE_ID=$(az network profile list --resource-group $NODE_RES_GROUP --query "[0].id" --output tsv)
    
    # Delete the network profile
    az network profile delete --id $NETWORK_PROFILE_ID -y
    
    # Grab the service association link ID
    SAL_ID=$(az network vnet subnet show --resource-group $RES_GROUP --vnet-name $AKS_VNET --name $AKS_SUBNET --query id --output tsv)/providers/Microsoft.ContainerInstance/serviceAssociationLinks/default
    
    # Delete the service association link for the subnet
    az resource delete --ids $SAL_ID --api-version 2021-10-01
    
    # Delete the subnet delegation to Azure Container Instances
    az network vnet subnet update --resource-group $RES_GROUP --vnet-name $AKS_VNET --name $AKS_SUBNET --remove delegations
    ```