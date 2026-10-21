---
layout: Conceptual
title: Deployment Safeguards in AKS - Troubleshoot issues - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/deployment-safeguards-in-azure-kubernetes-service
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
description: Learn how to troubleshoot Deployment Safeguards in Azure Kubernetes Service (AKS). Fix blocked workloads, configuration errors, and enforcement issues. Get started now.
ms.date: 2025-07-18T00:00:00.0000000Z
ms.reviewer: v-liuamson; v-gsitser
ms.service: azure-kubernetes-service
ms.custom: sap:Extensions, Policies and Add-Ons
locale: en-us
document_id: 202e0785-2d57-a12c-2bab-0db9bfb898d4
document_version_independent_id: 202e0785-2d57-a12c-2bab-0db9bfb898d4
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/deployment-safeguards-in-azure-kubernetes-service.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/deployment-safeguards-in-azure-kubernetes-service
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/deployment-safeguards-in-azure-kubernetes-service.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/eea02214-631d-404a-92d1-5a3357c32a26
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/f42c31d7-eed9-43b7-9757-54caffb53cdc
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 10cd6588-7df0-b49f-008f-e04e56fa3d1a
---

# Deployment Safeguards in AKS - Troubleshoot issues - Azure | Microsoft Learn

## Summary

Deployment Safeguards in Azure Kubernetes Service (AKS) help enforce Kubernetes best practices by using Azure Policy and Gatekeeper. While they offer valuable protection, a misconfiguration or misunderstanding of their behavior can cause blocked or mutated workloads. This guide helps you troubleshoot common issues when you use Deployment Safeguards in **Warn** or **Enforce** mode.

## Frequently asked questions

### Why aren't Deployment Safeguards taking effect?

**Symptoms:**

- You deploy noncompliant resources, but you see no warnings or signs of enforcement.
- The Azure Policy dashboard shows a **Not started** value or an empty compliance status.

**Recommended actions:**

- Verify that the Azure Policy add-on is enabled on the cluster:

```bash
    az aks show \--resource-group \<rg-name\> \--name \<cluster-name\>
    \--query addonProfiles.azurepolicy
```

- Check whether the namespace is excluded:

```bash
    az aks safeguards show \--resource-group \<rg-name\> \--name
    \<cluster-name\>
```

### How can I disable Deployment Safeguards?

To disable deployment safeguards entirely, run the following command:

```bash
    az aks safeguards delete \--resource-group \<rg-name\> \--name
    \<cluster-name\>
```

### Why can I turn on Deployment Safeguards without Azure Policy permissions?

Deployment Safeguards uses Azure Policy as an implementation detail. To turn on Deployment Safeguards on an AKS cluster, you don't have to have the correct permissions to assign or delete Azure Policies. All that is required are permissions to the AKS Contributor role.

### Why does my deployment resource get admitted even though it doesn't follow best practices?

Deployment safeguards enforce best practice standards through Azure Policy controls. It has policies that validate against Kubernetes resources. To evaluate and enforce cluster components, Azure Policy extends [Gatekeeper](https://open-policy-agent.github.io/gatekeeper/website/). Gatekeeper enforcement also currently operates in a [fail-open model](https://open-policy-agent.github.io/gatekeeper/website/docs/failing-closed/#considerations). There are no guarantees that Gatekeeper will respond to our networking call. Therefore, we make sure that the validation doesn't run in such cases so that the denial doesn't block your deployments.

## Common error scenarios

When configuring or using Deployment Safeguards, you may encounter error messages in the following situations:

### Configuration-related errors

- **Resource group locked**: The managed cluster's resource group has a resource lock that prevents modifications required for Deployment Safeguards.
- **Suspended subscription**: The Azure subscription containing the AKS cluster is in a suspended state.
- **Cluster in deleting state**: You cannot configure Deployment Safeguards on a cluster that is currently being deleted.
- **Unsupported Kubernetes version**: The managed cluster is running a Kubernetes version earlier than 1.25, which is not supported by Deployment Safeguards.

### Input validation errors

- **Invalid namespace exclusion format**: Excluded namespaces must follow Kubernetes naming conventions. Values like `ns1,ns2` are not valid - use proper Kubernetes regex patterns.
- **Invalid enforcement level**: The enforcement level must be either `Warn` or `Enforce`. Other values will result in a validation error.
- **Malformed configuration parameters**: Other invalid input parameters will trigger specific validation warnings based on the configuration being applied.

**Recommended action**: Review the specific warning message and correct the configuration issue before retrying the operation.

## Additional tips

- All safeguard policies are bundled. They can't be individually toggled.
- Use the [AKS GitHub repo](https://github.com/Azure/AKS/issues) to request new safeguard features.

## Contact us for help

If you have questions or need help, [create a support request](https://ms.portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade/overview?DMC=troubleshoot), or ask [Azure community support](/en-us/answers/products/azure?product=all). You can also submit product feedback to [Azure feedback community](https://feedback.azure.com/d365community).