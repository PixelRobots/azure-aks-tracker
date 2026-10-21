---
layout: Conceptual
title: AKS container CPU and memory limits not enforced - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/enforce-container-cpu-memory-limits
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: kaushika-msft
ms.author: kaushika
ms.topic: troubleshooting
description: Fix AKS container CPU and memory limits not being enforced with Azure Policy Add-on. Learn how to configure resource limits and resolve deployment errors.
ms.date: 2024-04-12T00:00:00.0000000Z
ms.reviewer: momajed, cssakscic
ms.service: azure-kubernetes-service
ms.custom: sap:Extensions, Policies and Add-Ons
locale: en-us
document_id: b57a1134-1e49-a1e4-54a2-a762ec2f2c28
document_version_independent_id: b57a1134-1e49-a1e4-54a2-a762ec2f2c28
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/enforce-container-cpu-memory-limits.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/enforce-container-cpu-memory-limits
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/enforce-container-cpu-memory-limits.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/eea02214-631d-404a-92d1-5a3357c32a26
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/f42c31d7-eed9-43b7-9757-54caffb53cdc
platformId: 5d5b3c4a-3ac6-ec61-2fa0-a21fbd1c5317
---

# AKS container CPU and memory limits not enforced - Azure | Microsoft Learn

## Summary

This article provides a solution to an issue where CPU and memory limits aren't enforced for AKS containers when you use the Azure Policy Add-on for Azure Kubernetes Service (AKS). Follow the steps below to configure resource limits and resolve deployment errors in your AKS cluster.

## Symptoms

When you deploy an application to an AKS cluster, you receive an error like the following sample:

> 
> "validation.gatekeeper.sh" denied the request: [container-must-have-limits] container &lt;name&gt; has no resource/memory limit

## Cause

CPU and memory limits aren't configured in the container specification.

## Resolution

To resolve this issue, ensure that container CPU and memory limits are enforced by following these steps:

1. Run the following command to check the compliance of your cluster:

    ```console
    kubectl describe k8sazurecontainerlimits 
    ```

    This command provides information about the current CPU and memory limits that are configured for your containers.
2. Configure the CPU and memory limits for all your existing deployments in the container specification.

    Here's an example:

    ```yaml
    spec: 
      containers: 
      - name: cache-service 
        image: xasag94215/flask-cache 
        ports: 
        - containerPort: 5000 
          name: rest 
        resources: 
          requests: 
            cpu: 25m 
            memory: 64Mi 
          limits: 
            cpu: 410m 
            memory: 512Mi 
    ```

    Note

    Adjust the CPU and memory values based on your specific requirements.
3. After updating the container specification, trigger a rescan or on-demand scan to evaluate the compliance status. You can use the Azure CLI to perform an on-demand evaluation scan. For more information about starting an on-demand scan, see [On-demand evaluation scan - Azure CLI](/en-us/azure/governance/policy/how-to/get-compliance-data#on-demand-evaluation-scan---azure-cli).