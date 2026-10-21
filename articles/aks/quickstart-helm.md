---
layout: Conceptual
title: Develop on Azure Kubernetes Service (AKS) with Helm - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/quickstart-helm
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
description: Use Helm with AKS and Azure Container Registry to package and run application containers in a cluster.
ms.topic: concept-article
ms.subservice: aks-developer
ms.custom: devx-track-azurecli, devx-track-azurepowershell
ms.date: 2024-01-25T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: fedd9d97-cb50-8b18-8e60-b59e7271ee07
document_version_independent_id: 10b5ef12-f471-1df6-0ef2-f469256cfe53
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/quickstart-helm.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,azurepowershell
toc_rel: toc.json
asset_id: aks/quickstart-helm
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/quickstart-helm.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 51823d6d-d757-2351-dac0-68389656b9b0
---

# Develop on Azure Kubernetes Service (AKS) with Helm - Azure Kubernetes Service | Microsoft Learn

[Helm](https://helm.sh/) is an open-source packaging tool that helps you install and manage the lifecycle of Kubernetes applications. Similar to Linux package managers like *APT* and *Yum*, Helm manages Kubernetes charts, which are packages of pre-configured Kubernetes resources.

In this quickstart, you use Helm to package and run an application on AKS. For information on installing an existing application using Helm, see [Install existing applications with Helm in AKS](kubernetes-helm).

## Prerequisites

- An Azure subscription. If you don't have an Azure subscription, you can create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- [Azure CLI](/en-us/cli/azure/install-azure-cli) or [Azure PowerShell](/en-us/powershell/azure/install-az-ps) installed.
- [Helm v3 installed](https://helm.sh/docs/intro/install/).

## Create an Azure Container Registry

You need to store your container images in an Azure Container Registry (ACR) to run your application in your AKS cluster using Helm. Your registry name must be unique within Azure and contain 5-50 alphanumeric characters. Only lowercase characters are allowed. The *Basic* SKU is a cost-optimized entry point for development purposes that provides a balance of storage and throughput.

# [Azure CLI](#tab/azure-cli)
1. Create an Azure resource group using the [az group create](/en-us/cli/azure/group#az-group-create) command. The following example creates a resource group named *myResourceGroup* in the *eastus* location.

    ```azurecli
    az group create --name myResourceGroup --location eastus
    ```
2. Create an Azure Container Registry with a unique name by calling the [az acr create](/en-us/cli/azure/acr#az-acr-create) command. The following example creates an ACR named *myhelmacr* with the *Basic* SKU.

    ```azurecli
    az acr create --resource-group myResourceGroup --name myhelmacr --sku Basic
    ```

    Your output should look similar to the following condensed example output. Take note of your *loginServer* value for your ACR to use in a later step.

    ```output
    {
      "adminUserEnabled": false,
      "creationDate": "2023-12-26T22:36:23.998425+00:00",
      "id": "/subscriptions/<ID>/resourceGroups/myResourceGroup/providers/Microsoft.ContainerRegistry/registries/myhelmacr",
      "location": "eastus",
      "loginServer": "myhelmacr.azurecr.io",
      "name": "myhelmacr",
      "networkRuleSet": null,
      "provisioningState": "Succeeded",
      "resourceGroup": "myResourceGroup",
      "sku": {
        "name": "Basic",
        "tier": "Basic"
      },
      "status": null,
      "storageAccount": null,
      "tags": {},
      "type": "Microsoft.ContainerRegistry/registries"
    }
    ```

# [Azure PowerShell](#tab/azure-powershell)
1. Create an Azure resource group using the [New-AzResourceGroup](/en-us/powershell/module/az.resources/new-azresourcegroup) cmdlet. The following example creates a resource group named *myResourceGroup* in the *eastus* location.

    ```azurepowershell
    New-AzResourceGroup -Name myResourceGroup -Location eastus
    ```
2. Create an Azure Container Registry with a unique name by calling the [New-AzContainerRegistry](/en-us/powershell/module/az.containerregistry/new-azcontainerregistry) cmdlet. The following example creates an ACR named *myhelmacr* with the *Basic* SKU.

    ```azurepowershell
    New-AzContainerRegistry -ResourceGroupName myResourceGroup -Name myhelmacr -Sku Basic -Location eastus
    ```

    Your output should look similar to the following condensed example output. Take note of your *loginServer* value for your ACR to use in a later step.

    ```output
    Registry Name    Sku        LoginServer              CreationDate               Provisioni AdminUserE StorageAccountName
                                                                                      ngState    nabled
    -------------    ---        -----------              ------------               ---------- ---------- ------------------
    myhelmacr        Basic      myhelmacr.azurecr.io     12/26/2023 9:16:14 PM       Succeeded  False      
    ```

---

## Create an AKS cluster

Your new AKS cluster needs access to your ACR to pull the container images and run them.

# [Azure CLI](#tab/azure-cli)
- Create an AKS cluster using the [az aks create](/en-us/cli/azure/aks#az-aks-create) command with the `--attach-acr` parameter to grant the cluster access to your ACR. The following example creates an AKS cluster named *myAKSCluster* and grants it access to the *myhelmacr* ACR. Make sure you replace `myhelmacr` with the name of your ACR.

    ```azurecli
    az aks create --resource-group myResourceGroup --name myAKSCluster --location eastus --attach-acr myhelmacr --generate-ssh-keys
    ```

# [Azure PowerShell](#tab/azure-powershell)
- Create an AKS cluster using the [New-AzAksCluster](/en-us/powershell/module/az.aks/new-azakscluster) cmdlet with the `-AcrNameToAttach` parameter to grant the cluster access to your ACR. The following example creates an AKS cluster named *myAKSCluster* and grants it access to the *myhelmacr* ACR. Make sure you replace `myhelmacr` with the name of your ACR.

    ```azurepowershell
    New-AzAksCluster -ResourceGroupName myResourceGroup -Name myAKSCluster -Location eastus -AcrNameToAttach myhelmacr -GenerateSshKey 
    ```

---

## Connect to your AKS cluster

To connect a Kubernetes cluster locally, you use the Kubernetes command-line client, [kubectl](https://kubernetes.io/docs/reference/kubectl/). `kubectl` is already installed if you use Azure Cloud Shell.

# [Azure CLI](#tab/azure-cli)
1. Install `kubectl` locally using the [az aks install-cli](/en-us/cli/azure/aks#az-aks-install-cli) command.

    ```azurecli
    az aks install-cli
    ```
2. Configure `kubectl` to connect to your Kubernetes cluster using the [az aks get-credentials](/en-us/cli/azure/aks#az-aks-get-credentials) command. The following command gets credentials for the AKS cluster named *myAKSCluster* in *myResourceGroup*.

    ```azurecli
    az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
    ```

# [Azure PowerShell](#tab/azure-powershell)
1. Install `kubectl` locally using the [Install-AzAksKubectl](/en-us/powershell/module/az.aks/install-azaksclitool) cmdlet.

    ```azurepowershell
    Install-AzAksKubectl
    ```
2. Configure `kubectl` to connect to your Kubernetes cluster using the [Import-AzAksCredential](/en-us/powershell/module/az.aks/import-azakscredential) cmdlet. The following command gets credentials for the AKS cluster named *myAKSCluster* in *myResourceGroup*:

    ```azurepowershell
    Import-AzAksCredential -ResourceGroupName myResourceGroup -Name myAKSCluster
    ```

---

## Download the sample application

This quickstart uses the [Azure Vote application](https://github.com/Azure-Samples/azure-voting-app-redis.git).

1. Clone the application from GitHub using the `git clone` command.

    ```bash
    git clone https://github.com/Azure-Samples/azure-voting-app-redis.git
    ```
2. Navigate to the `azure-vote` directory using the `cd` command.

    ```bash
    cd azure-voting-app-redis/azure-vote/
    ```

## Build and push the sample application to ACR

- Build and push the image to your ACR using the [az acr build](/en-us/cli/azure/acr#az-acr-build) command. The following example builds an image named *azure-vote-front:v1* and pushes it to the *myhelmacr* ACR. Make sure you replace `myhelmacr` with the name of your ACR.

    ```azurecli
    az acr build --image azure-vote-front:v1 --registry myhelmacr --file Dockerfile .
    ```

Note

You can also import Helm charts into your ACR. For more information, see [Push and pull Helm charts to an Azure container registry](/en-us/azure/container-registry/container-registry-helm-repos).

## Create your Helm chart

1. Generate your Helm chart using the `helm create` command.

    ```bash
    helm create azure-vote-front
    ```
2. Update *azure-vote-front/Chart.yaml* to add a dependency for the *redis* chart from the `https://charts.bitnami.com/bitnami` chart repository and update `appVersion` to `v1`, as shown in the following example:

    Note

    The container image versions shown in this guide have been tested to work with this example but may not be the latest version available.

    ```yaml
    apiVersion: v2
    name: azure-vote-front
    description: A Helm chart for Kubernetes
    
    dependencies:
      - name: redis
        version: 17.3.17
        repository: https://charts.bitnami.com/bitnami
    
    ...
    # This is the version number of the application being deployed. This version number should be
    # incremented each time you make changes to the application.
    appVersion: v1
    ```
3. Update your Helm chart dependencies using the `helm dependency update` command.

    ```bash
    helm dependency update azure-vote-front
    ```
4. Update *azure-vote-front/values.yaml* with the following changes.

    - Add a *redis* section to set the image details, container port, and deployment name.
    - Add a *backendName* for connecting the frontend portion to the *redis* deployment.
    - Change *image.repository* to `<loginServer>/azure-vote-front`.
    - Change *image.tag* to `v1`.
    - Change *service.type* to *LoadBalancer*.

    For example:

    ```yaml
    replicaCount: 1
    backendName: azure-vote-backend-master
    redis:
      image:
        registry: mcr.microsoft.com
        repository: oss/bitnami/redis
        tag: 6.0.8
      fullnameOverride: azure-vote-backend
      auth:
        enabled: false
    
    image:
      repository: myhelmacr.azurecr.io/azure-vote-front
      pullPolicy: IfNotPresent
      tag: "v1"
    ...
    service:
      type: LoadBalancer
      port: 80
    ...
    ```
5. Add an `env` section to *azure-vote-front/templates/deployment.yaml* to pass the name of the *redis* deployment.

    ```yaml
    ...
          containers:
            - name: {{ .Chart.Name }}
              securityContext:
                {{- toYaml .Values.securityContext | nindent 12 }}
              image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
              imagePullPolicy: {{ .Values.image.pullPolicy }}
              env:
              - name: REDIS
                value: {{ .Values.backendName }}
    ...
    ```

## Run your Helm chart

1. Install your application using your Helm chart using the `helm install` command.

    ```bash
    helm install azure-vote-front azure-vote-front/
    ```
2. It takes a few minutes for the service to return a public IP address. Monitor progress using the `kubectl get service` command with the `--watch` argument.

    ```bash
    kubectl get service azure-vote-front --watch
    ```

    When the service is ready, the `EXTERNAL-IP` value changes from `<pending>` to an IP address. Press `CTRL+C` to stop the `kubectl` watch process.

    ```output
      NAME               TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)        AGE
      azure-vote-front   LoadBalancer   10.0.18.228   <pending>       80:32021/TCP   6s
      ...
      azure-vote-front   LoadBalancer   10.0.18.228   52.188.140.81   80:32021/TCP   2m6s
    ```
3. Navigate to your application's load balancer in a browser using the `<EXTERNAL-IP>` to see the sample application.

## Delete the cluster

# [Azure CLI](#tab/azure-cli)
- Remove your resource group, AKS cluster, Azure container registry, container images stored in the ACR, and all related resources using the [az group delete](/en-us/cli/azure/group#az-group-delete) command with the `--yes` parameter to confirm deletion and the `--no-wait` parameter to return to the command prompt without waiting for the operation to complete.

    ```azurecli
    az group delete --name myResourceGroup --yes --no-wait
    ```

# [Azure PowerShell](#tab/azure-powershell)
- Remove your resource group, AKS cluster, Azure container registry, container images stored in the ACR, and all related resources using the [Remove-AzResourceGroup](/en-us/powershell/module/az.resources/remove-azresourcegroup) cmdlet with the `--yes` parameter to confirm deletion and the `--no-wait` parameter to return to the command prompt without waiting for the operation to complete.

    ```azurepowershell
    Remove-AzResourceGroup -Name myResourceGroup
    ```

---

Note

If you created your AKS cluster with a system-assigned managed identity (the default identity option in this quickstart), the identity is managed by the platform and doesn't require removal.

If you created your AKS cluster with a service principal, the service principal isn't removed when you delete the cluster. To remove the service principal, see [AKS service principal considerations and deletion](kubernetes-service-principal#considerations-when-using-a-service-principal).