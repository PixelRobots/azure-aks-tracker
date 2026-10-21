---
layout: Conceptual
title: Install existing applications with Helm in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/kubernetes-helm
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
description: Learn how to use the Helm packaging tool to deploy containers in an Azure Kubernetes Service (AKS) cluster
author: schaffererin
ms.subservice: aks-developer
ms.topic: how-to
ms.date: 2023-05-09T00:00:00.0000000Z
ms.author: schaffererin
locale: en-us
document_id: 07496f80-b64c-da83-0701-1ab0f5631523
document_version_independent_id: 948f9833-346a-abe4-866a-3e0d7e49376d
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/kubernetes-helm.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/kubernetes-helm
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/kubernetes-helm.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: dbd4f42c-9d84-fcb3-9352-c9400df0303b
---

# Install existing applications with Helm in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

[Helm](https://github.com/kubernetes/helm/) is an open-source packaging tool that helps you install and manage the lifecycle of Kubernetes applications. Similar to Linux package managers, such as *APT* and *Yum*, you can use Helm to manage Kubernetes charts, which are packages of preconfigured Kubernetes resources.

This article shows you how to configure and use Helm in a Kubernetes cluster on Azure Kubernetes Service (AKS).

## Before you begin

- This article assumes you have an existing AKS cluster. If you need an AKS cluster, create one using [Azure CLI](learn/quick-kubernetes-deploy-cli), [Azure PowerShell](learn/quick-kubernetes-deploy-powershell), or [Azure portal](learn/quick-kubernetes-deploy-portal).
- Your AKS cluster needs to have **an integrated ACR**. For details on creating an AKS cluster with an integrated ACR, see [Authenticate with Azure Container Registry from Azure Kubernetes Service](cluster-container-registry-integration#create-a-new-acr).
- You also need the Helm CLI installed, which is the client that runs on your development system. It allows you to start, stop, and manage applications with Helm. If you use the Azure Cloud Shell, the Helm CLI is already installed. For installation instructions on your local platform, see [Installing Helm](https://helm.sh/docs/intro/install/).

Important

Helm is intended to run on Linux nodes. If you have Windows Server nodes in your cluster, you must ensure that Helm pods are only scheduled to run on Linux nodes. You also need to ensure that any Helm charts you install are also scheduled to run on the correct nodes. The commands in this article use [node-selectors](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector) to make sure pods are scheduled to the correct nodes, but not all Helm charts may expose a node selector. You can also consider using other options on your cluster, such as [taints](operator-best-practices-advanced-scheduler).

## Verify your version of Helm

- Use the `helm version` command to verify you have Helm 3 installed.

    ```console
    helm version
    ```

    The following example output shows Helm version 3.0.0 installed:

    ```output
    version.BuildInfo{Version:"v3.0.0", GitCommit:"e29ce2a54e96cd02ccfce88bee4f58bb6e2a28b6", GitTreeState:"clean", GoVersion:"go1.13.4"}
    ```

## Install an application with Helm v3

### Add Helm repositories

- Add the *ingress-nginx* repository using the [helm repo](https://helm.sh/docs/intro/quickstart/#initialize-a-helm-chart-repository) command.

    ```console
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    ```

### Find Helm charts

1. Search for precreated Helm charts using the [helm search](https://helm.sh/docs/intro/using_helm/#helm-search-finding-charts) command.

    ```console
    helm search repo ingress-nginx
    ```

    The following condensed example output shows some of the Helm charts available for use:

    ```output
    NAME                            CHART VERSION   APP VERSION     DESCRIPTION
    ingress-nginx/ingress-nginx     4.7.0           1.8.0           Ingress controller for Kubernetes using NGINX a...
    ```
2. Update the list of charts using the [helm repo update](https://helm.sh/docs/intro/using_helm/#helm-repo-working-with-repositories) command.

    ```console
    helm repo update
    ```

    The following example output shows a successful repo update:

    ```output
    Hang tight while we grab the latest from your chart repositories...
    ...Successfully got an update from the "ingress-nginx" chart repository
    Update Complete. ⎈ Happy Helming!⎈
    ```

## Import the Helm chart images into your ACR

This article uses the [NGINX ingress controller Helm chart](https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx), which relies on three container images.

- Use `az acr import` to import the NGINX ingress controller images into your ACR.

    ```azurecli
    REGISTRY_NAME=<REGISTRY_NAME>
    CONTROLLER_REGISTRY=registry.k8s.io
    CONTROLLER_IMAGE=ingress-nginx/controller
    CONTROLLER_TAG=v1.8.0
    PATCH_REGISTRY=registry.k8s.io
    PATCH_IMAGE=ingress-nginx/kube-webhook-certgen
    PATCH_TAG=v20230407
    DEFAULTBACKEND_REGISTRY=registry.k8s.io
    DEFAULTBACKEND_IMAGE=defaultbackend-amd64
    DEFAULTBACKEND_TAG=1.5
    
    az acr import --name $REGISTRY_NAME --source $CONTROLLER_REGISTRY/$CONTROLLER_IMAGE:$CONTROLLER_TAG --image $CONTROLLER_IMAGE:$CONTROLLER_TAG
    az acr import --name $REGISTRY_NAME --source $PATCH_REGISTRY/$PATCH_IMAGE:$PATCH_TAG --image $PATCH_IMAGE:$PATCH_TAG
    az acr import --name $REGISTRY_NAME --source $DEFAULTBACKEND_REGISTRY/$DEFAULTBACKEND_IMAGE:$DEFAULTBACKEND_TAG --image $DEFAULTBACKEND_IMAGE:$DEFAULTBACKEND_TAG
    ```

    Note

    In addition to importing container images into your ACR, you can also import Helm charts into your ACR. For more information, see [Push and pull Helm charts to an Azure container registry](/en-us/azure/container-registry/container-registry-helm-repos).

### Run Helm charts

1. Install Helm charts using the [helm install](https://helm.sh/docs/intro/using_helm/#helm-install-installing-a-package) command and specify a release name and the name of the chart to install.

    Tip

    The following example creates a Kubernetes namespace for the ingress resources named *ingress-basic* and is intended to work within that namespace. Specify a namespace for your own environment as needed.

    ```console
    ACR_URL=<REGISTRY_URL>
    
    # Create a namespace for your ingress resources
    kubectl create namespace ingress-basic
    
    # Use Helm to deploy an NGINX ingress controller
    helm install ingress-nginx ingress-nginx/ingress-nginx \
        --version 4.0.13 \
        --namespace ingress-basic \
        --set controller.replicaCount=2 \
        --set controller.nodeSelector."kubernetes\.io/os"=linux \
        --set controller.image.registry=$ACR_URL \
        --set controller.image.image=$CONTROLLER_IMAGE \
        --set controller.image.tag=$CONTROLLER_TAG \
        --set controller.image.digest="" \
        --set controller.admissionWebhooks.patch.nodeSelector."kubernetes\.io/os"=linux \
        --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz \
        --set controller.admissionWebhooks.patch.image.registry=$ACR_URL \
        --set controller.admissionWebhooks.patch.image.image=$PATCH_IMAGE \
        --set controller.admissionWebhooks.patch.image.tag=$PATCH_TAG \
        --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux \
        --set defaultBackend.image.registry=$ACR_URL \
        --set defaultBackend.image.image=$DEFAULTBACKEND_IMAGE \
        --set defaultBackend.image.tag=$DEFAULTBACKEND_TAG \
        --set defaultBackend.image.digest=""
    ```

    The following condensed example output shows the deployment status of the Kubernetes resources created by the Helm chart:

    ```output
    NAME: nginx-ingress
    LAST DEPLOYED: Wed Jul 28 11:35:29 2021
    NAMESPACE: ingress-basic
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    NOTES:
    The ingress-nginx controller has been installed.
    It may take a few minutes for the LoadBalancer IP to be available.
    You can watch the status by running 'kubectl --namespace ingress-basic get services -o wide -w nginx-ingress-ingress-nginx-controller'
    ...
    ```
2. Get the *EXTERNAL-IP* of your service using the `kubectl get services` command.

    ```console
    kubectl --namespace ingress-basic get services -o wide -w ingress-nginx-ingress-nginx-controller
    ```

    The following example output shows the *EXTERNAL-IP* for the *ingress-nginx-ingress-nginx-controller* service:

    ```output
    NAME                                     TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)                      AGE   SELECTOR
    nginx-ingress-ingress-nginx-controller   LoadBalancer   10.0.254.93   <EXTERNAL_IP>   80:30004/TCP,443:30348/TCP   61s   app.kubernetes.io/component=controller,app.kubernetes.io/instance=nginx-ingress,app.kubernetes.io/name=ingress-nginx
    ```

### List releases

- Get a list of releases installed on your cluster using the `helm list` command.

    ```console
    helm list --namespace ingress-basic
    ```

    The following example output shows the *ingress-nginx* release deployed in the previous step:

    ```output
    NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
    ingress-nginx   ingress-basic   1               2021-07-28 11:35:29.9623734 -0500 CDT   deployed        ingress-nginx-3.34.0    0.47.0
    ```

### Clean up resources

Deploying a Helm chart creates Kubernetes resources like pods, deployments, and services.

- Clean up resources using the [helm uninstall](https://helm.sh/docs/intro/using_helm/#helm-uninstall-uninstalling-a-release) command and specify your release name.

    ```console
    helm uninstall --namespace ingress-basic ingress-nginx
    ```

    The following example output shows the release named *ingress-nginx* has been uninstalled:

    ```output
    release "nginx-ingress" uninstalled
    ```
- Delete the entire sample namespace along with the resources using the `kubectl delete` command and specify your namespace name.

    ```console
    kubectl delete namespace ingress-basic
    ```