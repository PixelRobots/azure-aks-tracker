---
layout: Conceptual
title: Use the Azure Kubernetes Service (AKS) extension for Visual Studio Code - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/aks-extension-vs-code
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
description: Learn how to the Azure Kubernetes Service (AKS) extension for Visual Studio Code to manage your Kubernetes clusters.
author: schaffererin
ms.topic: concept-article
ms.date: 2024-04-08T00:00:00.0000000Z
ms.author: schaffererin
ms.subservice: aks-developer
locale: en-us
document_id: 70f29107-049e-9a79-bd31-a0406584a1a9
document_version_independent_id: e7e15fd4-ff3b-f760-fbfe-39ffa37a02f4
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/aks-extension-vs-code.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/aks-extension-vs-code
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/aks-extension-vs-code.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/911a44a7-2f6c-477c-810f-dc8b7d425cce
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/14f2b9d5-6f06-45a8-ac5f-313eaa351153
platformId: ba7bd28d-788a-f8d3-ab26-7540b950b4f9
---

# Use the Azure Kubernetes Service (AKS) extension for Visual Studio Code - Azure Kubernetes Service | Microsoft Learn

The Azure Kubernetes Service (AKS) extension for Visual Studio Code allows you to easily view and manage your AKS clusters from your development environment.

## Features

The Azure Kubernetes Service (AKS) extension for Visual Studio Code provides a rich set of features to help you manage your AKS clusters, including:

- **Merge into Kubeconfig**: Merge your AKS cluster into your `kubeconfig` file to manage your cluster from the command line.
- **Save Kubeconfig**: Save your AKS cluster configuration to a file.
- **AKS Diagnostics**: View diagnostics information based on your cluster's backend telemetry for identity, security, networking, node health, and create, upgrade, delete, and scale issues.
- **AKS Periscope**: Extract detailed diagnostic information and export it to an Azure storage account for further analysis.
- **Install Azure Service Operator (ASO)**: Deploy the latest version of ASO and provision Azure resources within Kubernetes.
- **Start or stop a cluster**: Start or stop your AKS cluster to save costs when you're not using it.

For more information, see [AKS extension for Visual Studio Code features](https://code.visualstudio.com/docs/azure/aksextensions#_features).

## Installation

1. Open Visual Studio Code.
2. In the **Extensions** view, search for **Azure Kubernetes Service**.
3. Select the **Azure Kubernetes Service** extension and then select **Install**.

For more information, see [Install the AKS extension for Visual Studio Code](https://code.visualstudio.com/docs/azure/aksextensions#_install-the-azure-kubernetes-services-extension).