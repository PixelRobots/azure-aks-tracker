---
layout: Conceptual
title: Troubleshoot Dapr extension installation errors - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/troubleshoot-dapr-extension-installation-errors
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
description: Fix common Dapr extension installation errors on Azure Kubernetes Service (AKS) or Arc for Kubernetes, and follow these steps to resolve issues faster.
editor: v-jsitser
ms.reviewer: nigreenf, v-leedennis, addobres
ms.service: azure-kubernetes-service
ms.date: 2025-03-11T00:00:00.0000000Z
ms.custom: sap:Extensions, Policies and Add-Ons
locale: en-us
document_id: fa99be09-69ba-71cd-af3c-47236788ea1e
document_version_independent_id: fa99be09-69ba-71cd-af3c-47236788ea1e
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/troubleshoot-dapr-extension-installation-errors.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/troubleshoot-dapr-extension-installation-errors
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/troubleshoot-dapr-extension-installation-errors.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 23cf1d71-d662-18e3-9cf5-933f715e7d04
---

# Troubleshoot Dapr extension installation errors - Azure | Microsoft Learn

## Summary

This article discusses some common error messages that you may receive when you install or update the [Distributed Application Runtime (Dapr)](https://dapr.io/) extension for Microsoft Azure Kubernetes Service (AKS) or Arc for Kubernetes.

Learn more about the level of support provided for the Dapr extension.

## Scenario 1: installation fails but doesn't show an error message

If the extension generates an error message when you create or update it, you can inspect where the creation failed by running the [az k8s-extension list](/en-us/cli/azure/k8s-extension#az-k8s-extension-list) command:

```azurecli
az k8s-extension list --resource-group <my-resource-group-name> \
    --cluster-name <my-cluster-name> \
    --cluster-type managedClusters
```

If a wrong key is used in the configuration settings, such as `global.ha=false` instead of `global.ha.enabled=false`, the following JSON status is returned. The error message is captured in the `message` property.

```json
"statuses": [
  {
    "code": "InstallationFailed",
    "displayStatus": null,
    "level": null,
    "message": "Error: {failed to install chart from path [] for release [dapr-1]: err [template: dapr/charts/dapr_sidecar_injector/templates/dapr_sidecar_injector_poddisruptionbudget.yaml:1:17: executing \"dapr/charts/dapr_sidecar_injector/templates/dapr_sidecar_injector_poddisruptionbudget.yaml\" at <.Values.global.ha.enabled>: can't evaluate field enabled in type interface {}]} occurred while doing the operation : {Installing the extension} on the config",
    "time": null
  }
],
```

Here's another example of a JSON error message:

```json
"statuses": [
  {
    "code": "InstallationFailed",
    "displayStatus": null,
    "level": null,
    "message": "The extension operation failed with the following error: unable to add the configuration with configId {extension:microsoft-dapr} due to error: {error while adding the CRD configuration: error {failed to get the immutable configMap from the elevated namespace with err: configmaps 'extension-immutable-values' not found }}. (Code: ExtensionOperationFailed)",
    "time": null
  }
]
```

### Solution 1: restart the cluster, register the service provider, or delete and reinstall Dapr

To fix this issue, try the following methods:

- [Restart your AKS or Arc for Kubernetes cluster](/en-us/azure/aks/start-stop-cluster).
- [Register the KubernetesConfiguration service provider](/en-us/azure/aks/dapr#register-the-kubernetesconfiguration-service-provider).
- Force delete and [reinstall the Dapr extension](/en-us/azure/aks/dapr).

## Scenario 2: targeted Dapr version doesn't exist

When you try to install the Dapr extension to [target a specific version](/en-us/azure/aks/dapr#targeting-a-specific-dapr-version), you receive an error message that states that the Dapr version doesn't exist:

> 
> (ExtensionOperationFailed) The extension operation failed with the following error: Failed to resolve the extension version from the given values.
> 
> Code: ExtensionOperationFailed
> 
> Message: The extension operation failed with the following error: Failed to resolve the extension version from the given values.

### Solution 2: install again for a supported Dapr version

Try again to install the extension. Make sure that you use a [supported version of Dapr](/en-us/azure/aks/dapr#dapr-versions).

## Scenario 3: the targeted Dapr version exists but not in the specified region

Because some versions of Dapr aren't available in all regions, you might receive the following error message:

> 
> (ExtensionTypeRegistrationGetFailed) Extension type microsoft.dapr is not registered in region &lt;regionname&gt;.
> 
> Code: ExtensionTypeRegistrationGetFailed
> 
> Message: Extension type microsoft.dapr is not registered in region &lt;regionname&gt;

### Solution 3: install in a different region

Install in a [region in which your Dapr version is supported](/en-us/azure/aks/dapr#cloudsregions).

## Scenario 4: Dapr is already installed

You try to install the Dapr extension for AKS or Arc for Kubernetes, but you receive an error message that indicates that the `dapr-system` namespace already exists. This error message resembles the following text:

> 
> (ExtensionOperationFailed) The extension operation failed with the following error: Error: {failed to install chart from path [] for release [dapr-ext]: err [rendered manifests contain a resource that already exists. Unable to continue with install: ServiceAccount "dapr-operator" in namespace "dapr-system" exists and cannot be imported into the current release: invalid ownership metadata; annotation validation error: key "meta.helm.sh/release-name" must equal "dapr-ext": current value is "dapr"]} occurred while doing the operation : {Installing the extension} on the config

### Solution 4: uninstall Dapr OSS first

Uninstall the Dapr OSS before you install the Dapr extension. For more information, see [Migrate from Dapr OSS to the Dapr extension for AKS](/en-us/azure/aks/dapr-migration).

## Scenario 5: the placement server pod is in a bad state

You encounter the following error:

> 
> 0/4 nodes are available: 1 node(s) were unschedulable, 3 node(s) had volume node affinity conflict. preemption: 0/4 nodes are available: 4 Preemption is not helpful for scheduling.

This issue might happen when the placement server pod tries to use the persistent volume that's created in a different zone from the placement server pod itself.

### Solution 5: Install Dapr in multiple availability zones or limit the placement service to a particular availability zone

To resolve this issue, use one of the following methods:

- Follow the recommended approach in [Install Dapr in multiple availability zones while in HA mode](/en-us/azure/aks/dapr-settings#install-dapr-in-multiple-availability-zones-while-in-ha-mode).
- Limit the placement service to a particular availability zone by creating a custom storage class and using it for the placement service, and then run the following command:

    ```azurecli
    az k8s-extension create --cluster-type managedClusters
    --cluster-name <clustername>
    --resource-group <resourcegroup>
    --name <name>
    --extension-type Microsoft.Dapr
    --auto-upgrade-minor-version <minorversion>
    --version <version>
    --configuration-settings "dapr_placement.volumeclaims.storageClassName=zone-restricted"
    ```

    Here's an example of creating a custom storage class:

    ```yaml
    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
     name: zone-restricted
    provisioner: disk.csi.azure.com
    reclaimPolicy: Delete
    allowVolumeExpansion: true
    volumeBindingMode: WaitForFirstConsumer
    allowedTopologies:
    - matchLabelExpressions:
     - key: topology.kubernetes.io/zone
       values:
       - centralus-1
    parameters:
     storageaccounttype: StandardSSD_LRS
    ```