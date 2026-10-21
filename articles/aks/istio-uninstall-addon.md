---
layout: Conceptual
title: Uninstall Istio-based service mesh add-on for Azure Kubernetes Service - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/istio-uninstall-addon
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
description: Uninstall Istio-based service mesh add-on for Azure Kubernetes Service
ms.topic: how-to
ms.custom: devx-track-azurecli
ms.date: 2024-03-28T00:00:00.0000000Z
ms.author: kochhars
author: SanyaKochhar
locale: en-us
document_id: 15374b82-a36b-a7a5-dfdf-e98b4487d50b
document_version_independent_id: e7ea3412-9bb5-61ba-886e-75f8d8dd0b4f
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/istio-uninstall-addon.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/istio-uninstall-addon
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/istio-uninstall-addon.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 76d89157-344b-6242-8025-304a0577f359
---

# Uninstall Istio-based service mesh add-on for Azure Kubernetes Service - Azure Kubernetes Service | Microsoft Learn

This article shows you how to uninstall the Istio-based service mesh add-on for Azure Kubernetes Service (AKS) cluster and delete sample resources created in the [Getting Started](istio-deploy-addon) guide.

## Uninstall the add-on

Disabling the service mesh add-on removes all **Istio components** from your cluster. This includes **Istio CRDs and custom resources**, the **Istio control plane**, **ingress and egress gateway configurations**, and the managed namespaces `aks-istio-system` and `aks-istio-ingress` (along with any resources in them). To uninstall the add-on, run the following command:

```azurecli
az aks mesh disable --resource-group ${RESOURCE_GROUP} --name ${CLUSTER}
```

## Clean up sample resources

Use `kubectl delete` to delete the sample application if it was installed:

```bash
kubectl delete -f https://raw.githubusercontent.com/istio/istio/release-1.24/samples/bookinfo/platform/kube/bookinfo.yaml
```