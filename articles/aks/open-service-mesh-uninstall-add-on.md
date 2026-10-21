---
layout: Conceptual
title: Uninstall the Open Service Mesh (OSM) add-on from your Azure Kubernetes Service (AKS) cluster - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/open-service-mesh-uninstall-add-on
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
description: How to uninstall the Open Service Mesh on Azure Kubernetes Service (AKS) using Azure CLI.
ms.topic: how-to
ms.subservice: aks-networking
ms.custom: devx-track-azurecli
ms.date: 2024-09-25T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 94eb7f00-ba82-24fc-3a48-c2b6de4e3e33
document_version_independent_id: e45b0837-56b0-b9ab-25ff-6cc2f204ea64
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/open-service-mesh-uninstall-add-on.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/open-service-mesh-uninstall-add-on
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/open-service-mesh-uninstall-add-on.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 8ba4c347-0b36-832c-1429-df6644657730
---

# Uninstall the Open Service Mesh (OSM) add-on from your Azure Kubernetes Service (AKS) cluster - Azure Kubernetes Service | Microsoft Learn

This article shows you how to uninstall the OMS add-on and related resources from your AKS cluster.

Important

Starting on **September 30, 2027**, Azure Kubernetes Service (AKS) no longer supports the Open Service Mesh (OSM) add-on. The upstream [Open Service Mesh project](https://www.cncf.io/projects/open-service-mesh/) has been retired.

If your cluster uses the OSM add-on, migrate to the Istio add-on before the end-of-support date. This retirement notice applies only to the managed OSM add-on and doesn't address open-source or self-managed service mesh installations. For migration steps, see [Migration guidance from the OSM add-on to the Istio add-on](open-service-mesh-istio-migration-guidance). To stay informed about AKS announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

## Disable the OSM add-on from your cluster

- Disable the OSM add-on from your cluster using the [`az aks disable-addon`](/en-us/cli/azure/aks#az-aks-disable-addons) command and the `--addons` parameter.

    ```azurecli
    az aks disable-addons \
      --resource-group myResourceGroup \
      --name myAKSCluster \
      --addons open-service-mesh
    ```

## Remove OSM resources

- Uninstall the remaining resources on the cluster using the `osm uninstall cluster-wide-resources` command.

    ```console
    osm uninstall cluster-wide-resources
    ```

    Note

    For version 1.1, the command is `osm uninstall mesh --delete-cluster-wide-resources`

    Important

    You must remove these additional resources after you disable the OSM add-on. Leaving these resources on your cluster may cause issues if you enable the OSM add-on again in the future.