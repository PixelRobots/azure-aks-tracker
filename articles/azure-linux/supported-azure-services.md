---
layout: Conceptual
title: Supported Azure Services in Azure Linux | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/supported-azure-services
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/133/azure
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/79b1327d-d925-ec11-b6e6-000d3a4f06a4
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
learn_banner_products:
- azure
manager: kumud
description: Learn about the Azure services that are supported on the Azure Linux platform, including agents, extensions, and add-ons for AKS.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: overview
ms.date: 2026-05-04T00:00:00.0000000Z
locale: en-us
document_id: 02e36bef-ffc2-ceb5-79ec-a81d521ba0eb
document_version_independent_id: 17bdda69-1b80-3f0d-29f5-1bae6b145473
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/supported-azure-services.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/supported-azure-services
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/supported-azure-services.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 1890c4fe-f307-d3d3-4ac1-21bfc063afeb
---

# Supported Azure Services in Azure Linux | Microsoft Learn

Azure Linux supports a range of Azure agents, extensions, and add-ons. These services are available as RPMs on https://packages.microsoft.com, container images on Azure Container Registry (ACR), virtual machine (VM) extensions, and add-ons for Azure Kubernetes Service (AKS). This article provides an overview of the supported services and their compatibility with the Azure Linux platform.

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## Supported agents and extensions

The following table highlights commonly used agents and extensions in Azure Linux. For the complete list of supported agents and their compatibility status, see the respective documentation for each agent or extension.

| Agent / Extension | Description |
| --- | --- |
| **Azure Monitor** | End-to-end observability for applications and infrastructure |
| **Azure Linux Agent (WALA)** | VM provisioning, networking, and extension management |
| **Azure CLI** | Command-line interface for managing Azure resources |
| **Key Vault** | Secure retrieval of secrets, keys, and certificates from Azure Key Vault |
| **Microsoft Defender for Cloud** | Threat detection, vulnerability management, and security monitoring for cloud workloads |
| **cloud-init** | Industry-standard multi-distribution method for cross-platform cloud instance initialization |
| **Azure Arc** | Management and governance of servers and Kubernetes clusters across on-premises, multicloud, and edge environments |
| **.NET** | Cross-platform runtime for building cloud, web, and microservice applications |
| **Microsoft Build of OpenJDK** | Microsoft's distribution of the Java Development Kit for running Java-based workloads |
| **Azure Resource Manager (ARM) templates** | JSON-based templates for defining and deploying Azure infrastructure as code |

## Add-ons and extensions for AKS

All existing and future AKS extensions and add-ons support Azure Linux. For more information, see the following resources:

- [Available add-ons](/en-us/azure/aks/integrations)
- [Currently available extensions](/en-us/azure/aks/cluster-extensions#currently-available-extensions)