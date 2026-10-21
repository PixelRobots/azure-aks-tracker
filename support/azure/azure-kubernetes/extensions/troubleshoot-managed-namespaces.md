---
layout: Conceptual
title: Troubleshoot Managed Namespaces Errors - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/troubleshoot-managed-namespaces
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
description: Troubleshoot managed namespace errors in AKS when enabling ManagedNamespacePreview. Follow these fixes to restore namespace operations quickly.
ms.date: 2025-08-05T00:00:00.0000000Z
ms.reviewer: jackjiang
ms.service: azure-kubernetes-service
ms.custom: sap:extensions, policies and add-ons
locale: en-us
document_id: e4335c55-e39a-8228-8321-fd5ce5527162
document_version_independent_id: e4335c55-e39a-8228-8321-fd5ce5527162
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/troubleshoot-managed-namespaces.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/troubleshoot-managed-namespaces
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/troubleshoot-managed-namespaces.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/4e834929-0ce1-4c1d-9c81-fcb14721edfb
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/75670257-a3f0-4627-9981-8046f99219e6
platformId: 43eb642f-e8e4-b3c3-1164-0bbc47e5033f
---

# Troubleshoot Managed Namespaces Errors - Azure | Microsoft Learn

## Summary

Use this guide to troubleshoot managed namespace errors in Microsoft Azure Kubernetes Service (AKS) when using the `ManagedNamespacePreview` flag and restore expected namespace behavior.

## Prerequisites

The following tools must be installed and configured:

- [Azure CLI](/en-us/cli/azure/install-azure-cli)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/), the Kubernetes command-line client

## Error 1: Feature not found

### Symptom

When you try to register the `ManagedNamespacePreview` flag, you receive the following error message:

*(FeatureNotFound) The feature '&lt;feature\_name&gt;' could not be found.*

### Resolution

Make sure that the command is entered correctly and uses correct spelling.

To register this preview feature, run the `as feature register` command:

`az feature register --namespace Microsoft.containerService -n ManagedNamespacePreview`

## Error 2 - Can't create a managed namespace

### Symptom

When you try to create a managed namespace, you receive the following error message:

*(BadRequest) Managed namespace requires feature flag Microsoft.ContainerService/ManagedNamespacePreview to be registered.*

### Resolution

This message indicates that the feature flag is not yet registered. If you already ran the command to register the flag, verify the registration status by running the the `az feature show` command:

`az feature show --namespace Microsoft.ContainerService -n ManagedNamespacePreview`

## Error 3: Can't use or change some namespaces

### Symptom

You receive the following error message:

*The namespace name cannot be the same as the name of a system namespace.*

### Resolution

Users are not allowed to change certain namespaces or create managed namespaces that use certain names because the names are used by system components or resources. This list includes the following namespaces:

- default
- kube-system
- kube-node-lease
- kube-public
- gatekeeper-system
- cert-manager
- calico-system
- tigera-system
- app-routing-system
- aks-istio-system
- istio-system
- dapr-system
- flux-system
- prometheus-system
- eraser-system

## Error 4 - Can't update or delete managed namespaces

### Symptom

You can't create, update, or delete managed namespaces.

### Resolution

This behavior is by design. Users are not allowed to create, update, or delete managed namespaces if the managed cluster is not in a running state.

## Error 5: Can't use some kubectl commands

### Symptom

When you try to modify a managed namespace through kubectl, you receive the following error message:

*Updating resource quota defaultresourcequota is not allowed because it is managed by ARM. Please update this resource quota though ARM api.*

### Resolution

Because a managed namespace is managed by Microsoft Azure Resource Manager (ARM), changes to its metadata (labels and annotations) through kubectl commands are restricted. The affected actions include, but are not limited to, edits and deletions to:

- A managed namespace through `kubectl edit ns <namespace-name>` or `kubectl delete ns <namespace name>`
- A namespace through `kubectl delete resourcequota defaultresourcequota --namespace <namespace-name>`
- A defaultresourcequota through `kubectl delete resourcequota defaultresourcequota --namespace <namespace-name>`
- A defaultnetworkpolicy through `kubectl delete networkpolicy defaultnetworkpolicy --namespace <namespace-name>`

Modifications to namespaces must be made through the ARM API to maintain consistency with the managed state. You can manage your managed namespaces in the Azure portal or through [CLI commands](/en-us/cli/azure/aks/namespace).

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.