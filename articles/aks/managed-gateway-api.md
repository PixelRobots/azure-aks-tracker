---
layout: Conceptual
title: Azure Kubernetes Service (AKS) Managed Gateway API Installation - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/managed-gateway-api
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
description: Learn how to install the Kubernetes Gateway API Custom Resource Definitions (CRDs) on your Azure Kubernetes Service (AKS) cluster using the Managed Gateway API installation.
ms.topic: how-to
author: nshankar
ms.author: nshankar
ms.reviewer: schaffererin
ms.date: 2026-09-10T00:00:00.0000000Z
locale: en-us
document_id: 0cf64f3e-e639-a23a-1703-9832b8c8e087
document_version_independent_id: a7414bc3-378d-c1fd-3880-678276421c78
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/managed-gateway-api.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/managed-gateway-api
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/managed-gateway-api.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: ef6d797d-6067-c7ed-ada7-40cb0e0f4e60
---

# Azure Kubernetes Service (AKS) Managed Gateway API Installation - Azure Kubernetes Service | Microsoft Learn

The [Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/) is a specification for traffic management on Kubernetes clusters. The specification enhances [Ingress API](https://kubernetes.io/docs/concepts/services-networking/ingress/), which lacks a unified and provider-agnostic approach for advanced traffic routing.

The Managed Gateway API Installation for Azure Kubernetes Service (AKS) installs the Custom Resource Definitions (CRDs) for the Kubernetes Gateway API. You can install these CRDs independently of any specific Gateway API implementation.

Note

The Managed Gateway API installation only installs and manages the Gateway API CRDs. You can use these CRDs with your own Gateway API implementation, but AKS support only applies when you use the Managed Gateway API installation with a supported AKS add-on or extension that implements the Gateway API. BYO proxies or other self-managed Gateway API implementations aren't supported by AKS.

## Prerequisites

- If you already have an existing installation of the Gateway API CRDs on your cluster, you must meet the following requirements:

    - Only `standard` channel CRDs can be installed on your cluster. `Experimental` channel CRDs are disallowed, and you must uninstall them before enabling the Managed Gateway API.
    - The Gateway API bundle version must be compatible with your cluster's Kubernetes version. For more information, see the Supported Kubernetes versions for Gateway API bundle versions section.
- Optionally, you could deploy an AKS add-on or extension that implements the Gateway API, such as the [Istio add-on](istio-gateway-api). If you use the Istio add-on, you must be on minor revision `asm-1-26` or later to ensure compatibility with the Managed Gateway API installation. To deploy the Istio add-on, see [Deploy Istio-based service mesh add-on for Azure Kubernetes Service (AKS)](istio-deploy-addon).

### Update Azure CLI version

You must use `azure-cli` version `2.86.0` or higher. Run `az --version` to find your `azure-cli` version, and run `az upgrade` to upgrade.

## Supported Kubernetes versions for Gateway API bundle versions

The following table outlines the supported Kubernetes versions for your AKS cluster for each Gateway API bundle version for the `standard` channel:

| Gateway API bundle version | Supported Kubernetes versions |
| --- | --- |
| v1.2.1 | v1.26.0 - v1.33.x |
| v1.3.0 | v1.34.x |
| v1.4.1 | v1.35.x |
| v1.5.1 | v1.36.x |
| v1.6.1 | v1.37.0+ |

Note

If you upgrade your AKS cluster to a new minor version after installing the Managed Gateway API CRDs, the CRDs automatically upgrade to the new supported Gateway API bundle version for that Kubernetes version. For instance, if you upgrade from AKS `v1.33.0` to `v1.34.0` and previously had the Managed Gateway API installed for bundle version `v1.2.1`, the CRDs automatically upgrade to bundle version `v1.3.0`.

## Create a new AKS cluster with Managed Gateway API CRDs installed

- Create a new AKS cluster with Managed Gateway API CRDs installed using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--enable-gateway-api` flag. You can also optionally enable a supported add-on, such as the Istio service mesh add-on, in the same command. The following example command creates a new AKS cluster with the Managed Gateway API installation and the Istio service mesh add-on enabled:

    ```azurecli
    az aks create --resource-group myResourceGroup --name myAKSCluster --enable-gateway-api --enable-azure-service-mesh
    ```

## Install Managed Gateway API CRDs on an existing AKS cluster

- Install Managed Gateway API CRDs on an existing cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--enable-gateway-api` flag.

    ```azurecli
    az aks update --resource-group myResourceGroup --name myAKSCluster --enable-gateway-api
    ```

## Verify Managed Gateway API CRD installation

1. View the CRDs installed on your cluster using the following `kubectl get crds` command:

    ```bash
    kubectl get crds | grep "gateway.networking.k8s.io"
    ```

    The output should show the installed CRDs, which are part of the Kubernetes Gateway API specification. For example:

    ```output
    gatewayclasses.gateway.networking.k8s.io                           2025-08-29T17:52:36Z
    gateways.gateway.networking.k8s.io                                 2025-08-29T17:52:36Z
    grpcroutes.gateway.networking.k8s.io                               2025-08-29T17:52:36Z
    httproutes.gateway.networking.k8s.io                               2025-08-29T17:52:37Z
    referencegrants.gateway.networking.k8s.io                          2025-08-29T17:52:37Z
    ```
2. Verify the CRDs have the expected annotations and the bundle version matches the expected Kubernetes version for your cluster using the following `kubectl get crds` command:

    ```bash
    kubectl get crd gateways.gateway.networking.k8s.io -ojsonpath={.metadata.annotations} | jq
    ```

    The output should show the expected annotations, including the `gateway.networking.k8s.io/bundle-version` annotation with the expected bundle version for your cluster's Kubernetes version. For example, if your cluster is running Kubernetes `v1.33.0`, the expected bundle version is `v1.2.1`, and the output should be similar to the following:

    ```output
    {
    "api-approved.kubernetes.io": "https://github.com/kubernetes-sigs/gateway-api/pull/3328",
    "app.kubernetes.io/managed-by": "aks",
    "app.kubernetes.io/part-of": <hash>,
    "gateway.networking.k8s.io/bundle-version": "v1.2.1",
    "gateway.networking.k8s.io/channel": "standard"
    }
    ```

## Uninstall Managed Gateway API CRDs on an AKS cluster

- Uninstall Managed Gateway API CRDs on an existing cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--disable-gateway-api` flag.

    ```azurecli
    az aks update --resource-group myResourceGroup --name myAKSCluster --disable-gateway-api
    ```