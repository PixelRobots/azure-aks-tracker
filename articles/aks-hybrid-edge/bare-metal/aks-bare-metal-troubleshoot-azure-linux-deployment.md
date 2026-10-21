---
layout: Conceptual
title: Troubleshoot AKS on Bare Metal on Azure Linux | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/bare-metal/aks-bare-metal-troubleshoot-azure-linux-deployment
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
learn_banner_products:
- azure
ms.service: azure-kubernetes-service-hybrid
description: Resolve common deployment, upgrade, and deletion issues for AKS on bare metal on Azure Linux and validated Azure Local hardware.
ms.topic: troubleshooting-general
ms.date: 2026-09-14T00:00:00.0000000Z
ai-usage: ai-assisted
author: rishimody
ms.author: rmody
ms.custom: bare-metal
locale: en-us
document_id: a134c80b-b629-74ce-6278-cb9fbaf08892
document_version_independent_id: da79056d-7b31-a1dc-e662-ee59be1dbc02
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/bare-metal/aks-bare-metal-troubleshoot-azure-linux-deployment.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/bare-metal/aks-bare-metal-troubleshoot-azure-linux-deployment
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/bare-metal/aks-bare-metal-troubleshoot-azure-linux-deployment.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/289b8734-3abd-4162-bc19-e661c3f4c940
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/6a94795e-9024-410d-b38e-b67941440893
platformId: fa1a6478-29ee-0b01-69e1-3ccfc7d16996
---

# Troubleshoot AKS on Bare Metal on Azure Linux | Microsoft Learn

Use this guidance for Azure Kubernetes Service (AKS) on bare metal on Azure Linux and validated Azure Local small form factor hardware.

## Deployment doesn't complete

1. Confirm that all required Azure resource providers and preview features are registered.
2. Verify that the Azure Local host and Azure Arc resources are connected.
3. Confirm that the host can reach the required outbound endpoints.
4. Open the resource group **Deployments** page and review the failed deployment operation.

## Upgrade remains in progress

Wait up to 30 minutes, then confirm that the host remains connected to Azure Arc. Because the preview uses a single-node cluster, workloads are unavailable while the node is cordoned, drained, and upgraded.

## Resource deletion fails

Delete resources in the order documented in [Delete AKS on bare metal cluster resources on Azure Linux](aks-bare-metal-delete-cluster-resources). Wait for cluster deletion to finish before deleting dependent resources.