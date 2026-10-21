---
layout: Conceptual
title: Create virtual nodes in Azure Kubernetes Service (AKS) using the Azure portal - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/virtual-nodes-portal
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
description: Learn how to use the Azure portal to create an Azure Kubernetes Services (AKS) cluster that uses virtual nodes to run pods.
ms.topic: concept-article
ms.date: 2023-05-09T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: references_regions
ms.subservice: aks-nodes
locale: en-us
document_id: ba4873d2-3132-070b-dc7b-7f29ac7d3b57
document_version_independent_id: cd4d9bc5-9dfc-9fae-df36-a1343baef697
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/virtual-nodes-portal.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/virtual-nodes-portal
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/virtual-nodes-portal.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 5c6b74b6-63d3-322b-8275-81d04a5a5722
---

# Create virtual nodes in Azure Kubernetes Service (AKS) using the Azure portal - Azure Kubernetes Service | Microsoft Learn

Virtual nodes enable network communication between pods that run in Azure Container Instances (ACI) and Azure Kubernetes Service (AKS) clusters. To provide this communication, a virtual network subnet is created and delegated permissions are assigned. Virtual nodes only work with AKS clusters created using *advanced* networking (Azure CNI). AKS clusters are created with *basic* networking (kubenet) by default.

This article shows you how to create a virtual network and subnets, and then deploy an AKS cluster that uses advanced networking using the Azure portal.

Note

For an overview of virtual node region availability and limitations, see [Use virtual nodes in AKS](virtual-nodes).

## Before you begin

You need the ACI service provider registered on your subscription.

- Check the status of the ACI provider registration using the [`az provider list`](/en-us/cli/azure/provider#az-provider-list) command.

    ```azurecli
    az provider list --query "[?contains(namespace,'Microsoft.ContainerInstance')]" -o table
    ```

    The following example output shows the *Microsoft.ContainerInstance* provider is *Registered*:

    ```output
    Namespace                    RegistrationState    RegistrationPolicy
    ---------------------------  -------------------  --------------------
    Microsoft.ContainerInstance  Registered           RegistrationRequired
    ```
- If the provider is *NotRegistered*, register it using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace Microsoft.ContainerInstance
    ```

## Create an AKS cluster

1. Navigate to the Azure portal home page.
2. Select **Create a resource** &gt; **Containers**.
3. On the **Azure Kubernetes Service (AKS)** resource, select **Create**.
4. On the **Basics**page, configure the following options:
    - *Project details*: Select an Azure subscription, then select or create an Azure resource group, such as *myResourceGroup*.
    - *Cluster details*: Enter a **Kubernetes cluster name**, such as *myAKSCluster*. Select a region and Kubernetes version for the AKS cluster.
5. Select **Next: Node pools** and check \**Enable virtual nodes*. ![Screenshot that shows creating a cluster with virtual nodes enabled on the Azure portal. The option 'Enable virtual nodes' is highlighted.](media/virtual-nodes-portal/enable-virtual-nodes.png)
6. Select **Review + create**.
7. After the validation completes, select **Create**.

By default, this process creates a managed cluster identity, which is used for cluster communication and integration with other Azure services. For more information, see [Use managed identities](use-managed-identity). You can also use a service principal as your cluster identity.

This process configures the cluster for advanced networking and the virtual nodes to use their own Azure virtual network subnet. The subnet has delegated permissions to connect Azure resources between the AKS cluster. If you don't already have a delegated subnet, the Azure portal creates and configures an Azure virtual network and subnet with the virtual nodes.

## Connect to the cluster

The Azure Cloud Shell is a free interactive shell you can use to run the steps in this article. It has common Azure tools preinstalled and configured to use with your account. To manage a Kubernetes cluster, use [kubectl](https://kubernetes.io/docs/reference/kubectl/), the Kubernetes command-line client. The `kubectl` client is pre-installed in the Azure Cloud Shell.

1. Configure `kubectl` to connect to your Kubernetes cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command. The following example gets credentials for the cluster name *myAKSCluster* in the resource group named *myResourceGroup*:

    ```azurecli
    az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
    ```
2. Verify the connection to your cluster using the [`kubectl get nodes`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get).

    ```azurecli
    kubectl get nodes
    ```

    The following example output shows the single VM node created and the virtual Linux node named *virtual-node-aci-linux*:

    ```output
    NAME                           STATUS    ROLES     AGE       VERSION
    virtual-node-aci-linux         Ready     agent     28m       v1.11.2
    aks-agentpool-14693408-0       Ready     agent     32m       v1.11.2
    ```

## Deploy a sample app

1. In the Azure Cloud Shell, create a file named `virtual-node.yaml` and copy in the following YAML:

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
            beta.kubernetes.io/os: linux
            type: virtual-kubelet
          tolerations:
          - key: virtual-kubelet.io/provider
            operator: Exists
    ```

    The YAML defines a [nodeSelector](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) and [toleration](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/), which allows the pod to be scheduled on the virtual node. The pod is assigned an internal IP address from the Azure virtual network subnet delegated for use with virtual nodes.
2. Run the application using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command.

    ```azurecli
    kubectl apply -f virtual-node.yaml
    ```
3. View the pods scheduled on the node using the [`kubectl get pods`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command with the `-o wide` argument.

    ```azurecli
    kubectl get pods -o wide
    ```

    The following example output shows the `virtual-node-helloworld` pod scheduled on the `virtual-node-linux` node.

    ```output
    NAME                                     READY     STATUS    RESTARTS   AGE       IP           NODE
    virtual-node-helloworld-9b55975f-bnmfl   1/1       Running   0          4m        10.241.0.4   virtual-node-aci-linux
    ```

Note

If you use images stored in Azure Container Registry, [configure and use a Kubernetes secret](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/). A limitation of virtual nodes is you can't use integrated Microsoft Entra service principal authentication. If you don't use a secret, pods scheduled on virtual nodes fail to start and report the error `HTTP response status code 400 error code "InaccessibleImage"`.

## Test the virtual node pod

To test the pod running on the virtual node, browse to the demo application with a web client. The pod is assigned an internal IP address, so you can easily test the connectivity from another pod on the AKS cluster.

1. Create a test pod and attach a terminal session to it using the following `kubectl run` command.

    ```console
    kubectl run -it --rm virtual-node-test --image=mcr.microsoft.com/dotnet/runtime-deps:6.0
    ```
2. Install `curl` in the pod using the following `apt-get` command.

    ```console
    apt-get update && apt-get install -y curl
    ```
3. Access the address of your pod using the following `curl` command and provide your internal IP address.

    ```console
    curl -L http://10.241.0.4
    ```

    The following condensed example output shows the demo application.

    ```output
    <html>
    <head>
      <title>Welcome to Azure Container Instances!</title>
    </head>
    [...]
    ```
4. Close the terminal session to your test pod with `exit`, which also deletes the pod.

    ```console
    exit
    ```