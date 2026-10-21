---
layout: Conceptual
title: Integrations with Kubernetes Event-driven Autoscaling (KEDA) on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/keda-integrations
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
description: Integrations with Kubernetes Event-driven Autoscaling (KEDA) on Azure Kubernetes Service (AKS).
author: tomkerkhove
ms.topic: concept-article
ms.date: 2023-09-27T00:00:00.0000000Z
ms.author: tomkerkhove
locale: en-us
document_id: 2dd58819-d520-18cc-5b98-92efdc49b797
document_version_independent_id: 52dabf6b-3dd1-cf54-524d-7062d6862875
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/keda-integrations.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/keda-integrations
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/keda-integrations.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: ad01a414-e232-5c90-6a80-7f054fbcbea1
---

# Integrations with Kubernetes Event-driven Autoscaling (KEDA) on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

The Kubernetes Event-driven Autoscaling (KEDA) add-on for AKS integrates with features provided by Azure and open-source projects.

Important

The [AKS support policy](support-policies) doesn't cover integrations with open-source projects.

## Observe your autoscaling with Kubernetes events

KEDA automatically emits Kubernetes events allowing customers to operate their application autoscaling.

To learn about the available metrics, we recommend reading the [KEDA documentation](https://keda.sh/docs/latest/reference/events/).

## Scalers for Azure services

KEDA can integrate with various tools and services through [a rich catalog of Azure KEDA scalers](https://keda.sh/docs/latest/scalers/) and supports leading cloud platforms and open-source technologies.

KEDA leverages the following scalers for Azure services:

- [Azure Application Insights](https://keda.sh/docs/latest/scalers/azure-app-insights/)
- [Azure Blob Storage](https://keda.sh/docs/latest/scalers/azure-storage-blob/)
- [Azure Data Explorer](https://keda.sh/docs/latest/scalers/azure-data-explorer/)
- [Azure Event Hubs](https://keda.sh/docs/latest/scalers/azure-event-hub/)
- [Azure Log Analytics](https://keda.sh/docs/latest/scalers/azure-log-analytics/)
- [Azure Monitor](https://keda.sh/docs/latest/scalers/azure-monitor/)
- [Azure Pipelines](https://keda.sh/docs/latest/scalers/azure-pipelines/)
- [Azure Service Bus](https://keda.sh/docs/latest/scalers/azure-service-bus/)
- [Azure Storage Queue](https://keda.sh/docs/latest/scalers/azure-storage-queue/)

As of KEDA version `2.10`, the [Prometheus scaler](https://keda.sh/docs/2.11/scalers/prometheus/) supports Azure managed service for Prometheus. You can also use self-hosted Prometheus but this falls outside support scope.

You can also install external scalers to autoscale on other Azure services:

- [Azure Cosmos DB (Change feed)](https://github.com/kedacore/external-scaler-azure-cosmos-db)

Important

External scalers *aren't supported as part of the add-on* and rely on community support.

Important

Open-source software is mentioned throughout AKS documentation and samples. Software that you deploy is excluded from AKS service-level agreements, limited warranty, and Azure support. As you use open-source technology alongside AKS, consult the support options available from the respective communities and project maintainers to develop a plan.

Microsoft takes responsibility for building the open-source packages that we deploy on AKS. That responsibility includes having complete ownership of the build, scan, sign, validate, and hotfix process, along with control over the binaries in container images. For more information, see [Vulnerability management for AKS](concepts-vulnerability-management#aks-container-images) and [AKS support coverage](support-policies#aks-support-coverage).