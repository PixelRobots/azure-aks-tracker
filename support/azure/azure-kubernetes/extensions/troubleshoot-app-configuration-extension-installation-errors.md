---
layout: Conceptual
title: Troubleshoot Azure App Configuration extension installation errors - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/troubleshoot-app-configuration-extension-installation-errors
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
description: Fix Azure App Configuration extension installation errors in AKS with proven solutions for version, region, and existing resource issues. Start troubleshooting now.
editor: v-jsitser
ms.reviewer: junbchen, v-leedennis, v-weizhu
ms.service: azure-kubernetes-service
ms.date: 2024-10-15T00:00:00.0000000Z
ms.custom: sap:Extensions, Policies and Add-Ons
locale: en-us
document_id: 8a221a24-c4ce-985a-aa47-2bb2244ba43f
document_version_independent_id: 8a221a24-c4ce-985a-aa47-2bb2244ba43f
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/troubleshoot-app-configuration-extension-installation-errors.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/troubleshoot-app-configuration-extension-installation-errors
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/troubleshoot-app-configuration-extension-installation-errors.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/80beb97b-18aa-44f8-9420-8f2a4cd448eb
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/8c09e0ef-0fde-4b6d-bf1b-b517e4db7f80
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 3c67424a-926c-8a09-3302-c253b576855e
---

# Troubleshoot Azure App Configuration extension installation errors - Azure | Microsoft Learn

## Summary

This article discusses some common error scenarios that you might encounter when you install or update the [Azure App Configuration extension](/en-us/azure/aks/azure-app-configuration) for Microsoft Azure Kubernetes Service (AKS).

Note

If the Azure App Configuration extension was successfully installed but you experience issues while using it, see the [Azure App Configuration Kubernetes Provider troubleshooting guide](/en-us/azure/azure-app-configuration/quickstart-azure-kubernetes-service#troubleshooting).

## Scenario 1: Azure App Configuration Kubernetes Provider is already installed

You try to install the Azure App Configuration extension for AKS, but you receive an error message that indicates that the Azure App Configuration Kubernetes Provider is already installed through the `helm install` command. The error message might resemble either of the following error messages.

**Message 1**

> 
> (ExtensionOperationFailed) The extension operation failed with the following error: Error: [ InnerError: [**Helm installation failed : Resource already existing in your cluster** : Recommendation Manually delete the resource(s) that currently exist in your cluster and try installation again. To delete these resources run the following commands: `kubectl delete {resource type} -n {resource namespace} {resource name}` : InnerError [rendered manifests contain a resource that already exists. Unable to continue with install: CustomResourceDefinition "azureappconfigurationproviders.azconfig.io" in namespace "" exists and cannot be imported into the current release: invalid ownership metadata; annotation validation error: key "meta.helm.sh/release-name" must equal "azureappconfig": current value is "azureappconfiguration.kubernetesprovider"; annotation validation error: key "meta.helm.sh/release-namespace" must equal "kube-system": current value is "azappconfig-system"]]] occurred while doing the operation : [Create] on the config, For general troubleshooting visit: https://aka.ms/k8s-extensions-TSG.

**Message 2**

> 
> (ExtensionOperationFailed) The extension operation failed with the following error: Error: [ InnerError: [**Helm installation failed : Resource already existing in your cluster** : Recommendation Manually delete the resource(s) that currently exist in your cluster and try installation again. To delete these resources run the following commands: `kubectl delete {resource type} -n {resource namespace} {resource name}` : InnerError [rendered manifests contain a resource that already exists. Unable to continue with install: ServiceAccount "az-appconfig-k8s-provider" in namespace "azappconfig-system" exists and cannot be imported into the current release: invalid ownership metadata; annotation validation error: key "meta.helm.sh/release-name" must equal "azureappconfig": current value is "azureappconfiguration.kubernetesprovider"]]] occurred while doing the operation : [Create] on the config, For general troubleshooting visit: https://aka.ms/k8s-extensions-TSG.

### Solution 1: Uninstall Azure App Configuration Kubernetes Provider first

Uninstall the Azure App Configuration Kubernetes Provider before you install the Azure App Configuration extension. For more information, see [Clean up resources](/en-us/azure/azure-app-configuration/quickstart-azure-kubernetes-service#clean-up-resources).

## Scenario 2: Targeted Azure App Configuration extension version doesn't exist

When you try to install the Azure App Configuration extension to [target a specific version](/en-us/azure/aks/azure-app-configuration#targeting-a-specific-version), you receive an error message that states that the Azure App Configuration version doesn't exist:

> 
> (ExtensionOperationFailed) The extension operation failed with the following error: **Failed to resolve the extension version from the given values.** Please refer https://aka.ms/k8s-extension-type-versions to find the correct version for your installation, For general troubleshooting visit: https://aka.ms/k8s-extensions-TSG.
> 
> Code: ExtensionOperationFailed
> 
> Message: The extension operation failed with the following error: **Failed to resolve the extension version from the given values.** Please refer https://aka.ms/k8s-extension-type-versions to find the correct version for your installation, For general troubleshooting visit: https://aka.ms/k8s-extensions-TSG.

### Solution 2: Install again for a supported Azure App Configuration extension version

Try again to install the extension. Make sure that you use a [supported version of the Azure App Configuration extension](/en-us/azure/aks/azure-app-configuration#extension-versions).

## Scenario 3: The targeted Azure App Configuration extension version exists but not in the specified region

Because Azure App Configuration extension aren't available in all AKS regions, you might receive the following error message:

> 
> (ExtensionTypeRegistrationGetFailed) Extension type microsoft.appconfiguration is not registered in region &lt;region-name&gt;.
> 
> Code: ExtensionTypeRegistrationGetFailed
> 
> Message: Extension type microsoft.appconfiguration is not registered in region &lt;region-name&gt;

### Solution 3: Install in a different region

Run the installation in a [region](/en-us/azure/aks/cluster-extensions#cluster-extension-requirements) that the cluster extension supports.