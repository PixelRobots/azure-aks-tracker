---
layout: Conceptual
title: ALB Service Mesh Helm Chart | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/service-mesh-helm-chart
breadcrumb_path: /azure/bread/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/148/azure-application-gateway/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/8ae9bf04-8326-ec11-b6e6-000d3a4f0789?c=8d429912-8326-ec11-b6e6-000d3a4f0789
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
adobe-target: true
learn_banner_products:
- azure
manager: kumud
ms.reviewer: mbender
description: This article documents the latest Helm chart for Application Gateway for Containers' ALB Service Mesh Extension.
services: application-gateway
author: mbender-ms
ms.service: azure-application-gateway-containers
ms.topic: release-notes
ms.date: 2026-06-24T00:00:00.0000000Z
ms.author: mbender
locale: en-us
document_id: 323e8b91-2f8b-4655-b729-fed7e88d028f
document_version_independent_id: 8009b8df-6a8f-7ae0-f453-27d4d485dbaf
original_content_git_url: https://github.com/MicrosoftDocs/azure-docs-pr/blob/live/articles/application-gateway/for-containers/service-mesh-helm-chart.md
site_name: Docs
depot_name: Azure.azure-documents
page_type: conceptual
toc_rel: toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/Azure.azure-documents/{branchName}{pdfName}
asset_id: application-gateway/for-containers/service-mesh-helm-chart
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-gateway/for-containers/service-mesh-helm-chart.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f98c9a19-e481-4f15-8047-76b641e6ed57
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f5685781-a4fd-40f1-8126-59abde4643bf
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
platformId: 16ff11a5-8c98-3491-de0e-7030fd81b0d1
---

# ALB Service Mesh Helm Chart | Microsoft Learn

A Helm chart to install ALB Controller Service Mesh Extension on Kubernetes. This chart should only be installed after installation of ALB Controller ([Add-on](quickstart-deploy-application-gateway-for-containers-alb-controller-addon) or [Helm](quickstart-deploy-application-gateway-for-containers-alb-controller-helm)).

## Values

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| albServiceMeshExtension.image | object | `{"name":{"istioExtension":"application-lb/images/alb-controller-istio-extension","istioExtensionJob":"application-lb/images/alb-controller-base-image"},"pullPolicy":"IfNotPresent","registry":"mcr.microsoft.com"}` | alb-controller-servicemesh-extension image parameters |
| albServiceMeshExtension.image.name | object | `{"istioExtension":"application-lb/images/alb-controller-istio-extension","istioExtensionJob":"application-lb/images/alb-controller-base-image"}` | Image name defaults |
| albServiceMeshExtension.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for alb-controller-servicemesh-extension containers |
| albServiceMeshExtension.image.registry | string | `"mcr.microsoft.com"` | Image registry for alb-controller-servicemesh-extension containers |
| albServiceMeshExtension.imagePullSecrets | list | `[]` |  |
| albServiceMeshExtension.istioExtension | object | `{"replicaCount":2,"resource":{"limits":{"cpu":"50m","memory":"64Mi"},"requests":{"cpu":"25m","memory":"32Mi"}},"revision":""}` | alb-controller-istio-extension's parameters |
| albServiceMeshExtension.istioExtension.replicaCount | int | `2` | alb-controller-istio-extension pods' replica count |
| albServiceMeshExtension.istioExtension.resource | object | `{"limits":{"cpu":"50m","memory":"64Mi"},"requests":{"cpu":"25m","memory":"32Mi"}}` | alb-controller-istio-extension container resource parameters |
| albServiceMeshExtension.istioExtension.revision | string | `""` | istio's revision the alb-controller-istio-extension needs to connect to |
| albServiceMeshExtension.logLevel | string | `"info"` | Log level of alb-controller-servicemesh-extension containers |
| albServiceMeshExtension.provider | string | `"istio"` | Provider is the name of the service mesh provider |