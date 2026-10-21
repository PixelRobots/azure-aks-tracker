---
layout: Conceptual
title: Azure Kubernetes Service (AKS) Diagnose and Solve Problems overview - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/aks-diagnostics
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
description: Learn about self-diagnosing clusters in Azure Kubernetes Service.
services: azure-kubernetes-service
author: rzhang628
ms.topic: how-to
ms.subservice: aks-monitoring
ms.date: 2023-03-10T00:00:00.0000000Z
ms.author: rongzhang
locale: en-us
document_id: 5d9ddcb9-d641-2dae-fa99-2394037878af
document_version_independent_id: d0b8987f-b5e0-9fae-f0e2-ec59443fd439
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/aks-diagnostics.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/aks-diagnostics
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/aks-diagnostics.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 2854d53e-ab05-639f-8078-3614727123ce
---

# Azure Kubernetes Service (AKS) Diagnose and Solve Problems overview - Azure Kubernetes Service | Microsoft Learn

Troubleshooting Azure Kubernetes Service (AKS) cluster issues plays an important role in maintaining your cluster, especially if your cluster is running mission-critical workloads. AKS Diagnose and Solve Problems is an intelligent, self-diagnostic experience that:

- Helps you identify and resolve problems in your cluster.
- Requires no extra configuration or billing cost.

## Open AKS Diagnose and Solve Problems

You can access AKS Diagnose and Solve Problems using the following steps:

1. In the [Azure portal](https://portal.azure.com), navigate to your AKS cluster resource.
2. From the service menu, select **Diagnose and solve problems**.
3. Select a troubleshooting category tile that best describes the issue of your cluster by referring the keywords in each tile description on the homepage or typing a keyword that best describes your issue in the search bar.

    [![Screenshot of the AKS Diagnose and Solve Problems home page in the Azure portal.](media/concepts-diagnostics/aks-diagnostics-home-page.png)](media/concepts-diagnostics/aks-diagnostics-home-page.png#lightbox)

## View a diagnostic report

After selecting a category, you can view various diagnostic reports that provide detailed information about the issue. The *Overview* option from the navigation menu runs all the diagnostics in that particular category and displays any issues that are found with the cluster. Select **View details** under each tile to view a detailed description of the issue, including:

- An issue summary
- Error details
- Recommended actions
- Links to helpful docs
- Related-metrics
- Logging data

### Example scenario: Diagnose connectivity issues

I observed that my application is getting disconnected or experiencing intermittent connection issues. In response, I navigate to the AKS Diagnose and Solve Problems home page and select the **Connectivity Issues** tile to investigate the potential causes.

[![Screenshot of the connectivity issues troubleshooting category tile in the Azure portal.](media/concepts-diagnostics/aks-diagnostics-connectivity-issues.png)](media/concepts-diagnostics/aks-diagnostics-connectivity-issues.png#lightbox)

I received a diagnostic alert indicating that the disconnection might be related to my *Cluster DNS*. To gather more information, I select **View details**.

[![Screenshot of cluster DNS connectivity issues in the Azure portal.](media/concepts-diagnostics/aks-diagnostics-results.png)](media/concepts-diagnostics/aks-diagnostics-results.png#lightbox)

Based on the diagnostic result, it appears that the issue might be related to known DNS issues or the VNet configuration. I can use the documentation links provided to address the issue and resolve the problem.

[![Screenshot of the troubleshooting links for cluster DNS connectivity issues in the Azure portal.](media/concepts-diagnostics/aks-diagnostics-network.png)](media/concepts-diagnostics/aks-diagnostics-network.png#lightbox)

If the recommended documentation based on the diagnostic results doesn't resolve the issue, I can return to the previous step in Diagnostics and refer to additional documentation.

[![Screenshot of the additional troubleshooting links for cluster DNS connectivity issues in the Azure portal.](media/concepts-diagnostics/aks-diagnostics-doc.png)](media/concepts-diagnostics/aks-diagnostics-doc.png#lightbox)

## Use AKS Diagnose and Solve Problems for best practices

Deploying applications on AKS requires adherence to best practices to guarantee optimal performance, availability, and security. The AKS Diagnose and Solve Problems **Best Practices** tile provides an array of best practices that can assist in managing various aspects, such as VM resource provisioning, cluster upgrades, scaling operations, subnet configuration, and other essential aspects of a cluster's configuration.

Leveraging the AKS Diagnose and Solve Problems can be vital in ensuring that your cluster adheres to best practices and that any potential issues are identified and resolved in a timely and effective manner. By incorporating AKS Diagnose and Solve Problems into your operational practices, you can be confident in the reliability and security of your application in production.

### Example scenario: View best practices

I'm curious about the best practices I can follow to prevent potential problems. In response, I navigate to the AKS Diagnose and Solve Problems home page and select the **Best Practices** tile.

[![Screenshot of the AKS Diagnose and Solve Problems best practices.](media/concepts-diagnostics/aks-diagnostics-best.png)](media/concepts-diagnostics/aks-diagnostics-best.png#lightbox)

From here, I can view the best practices that are recommended for my cluster and select **View details** to see the results.

[![Screenshot of the details of AKS Diagnose and Solve Problems best practices.](media/concepts-diagnostics/aks-diagnostics-practice.png)](media/concepts-diagnostics/aks-diagnostics-practice.png#lightbox)