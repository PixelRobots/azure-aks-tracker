---
layout: Conceptual
title: Troubleshoot AKS on Azure Local issues when Kubernetes version image isn't ready | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/aks-arc-image-not-ready
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
description: Learn how to mitigate cluster and node pool issues when a Kubernetes version reports image not ready on AKS Hybrid and Edge on Azure Local.
ms.topic: troubleshooting
author: davidsmatlak
ms.author: davidsmatlak
ms.date: 2026-09-01T00:00:00.0000000Z
ms.reviewer: srikantsarwa
ms.custom: hyperconverged
locale: en-us
document_id: da58931f-be89-eb8e-502d-04996bac1368
document_version_independent_id: 9d0fe516-3231-d905-3e4f-2ac724d7ffc1
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/aks-arc-image-not-ready.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/aks-arc-image-not-ready
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/aks-arc-image-not-ready.md
platformId: b64fc297-a3e8-e506-abff-ed7247cd5a9d
---

# Troubleshoot AKS on Azure Local issues when Kubernetes version image isn't ready | Microsoft Learn

This article describes how to mitigate cluster and node pool issues when a Kubernetes version reports image not ready on AKS Hybrid and Edge on Azure Local.

## Symptoms

You might observe one or more of the following error scenarios when creating or updating an AKS cluster:

### Error 1: Gallery image not found during cluster creation

```output
Provisioning the AKSArc cluster. This operation might take a while...

(ResourceDeploymentFailure) The resource write operation failed to complete successfully, because it reached terminal provisioning state 'Failed'.

(ClusterPrecheckFailed) Error: Aks Arc cluster creation precheck failed. Detailed message: 1 error occurred:
* rpc error: code = NotFound desc = Type[GalleryImage], Location[MocLocation], Name[linux-cblmariner-0.11.26.10605]: Not Found
```

### Error 2: Kubernetes version validation failure

```output
Provisioning the AKSArc cluster. This operation might take a while...

(TemplateDeploymentValidationFailed) Validation failed for 'Microsoft.HybridContainerService/provisionedClusterInstances'.

(PreflightValidationFailed) Preflight validation failed for one or more resources

(PreflightValidationFailed) admission webhook "vhybridakscluster.kb.io" denied the request: {
   "result": "Failed",
   "validationChecks": [
      {
         "name": "K8sVersionValidation",
         "message": "Kubernetes version 1.33.5 isn't ready for use on Linux. Please go to https://aka.ms/aksarccheckk8sversions for details of how to check the readiness of Kubernetes versions.",
         "recommendation": "Please check https://aka.ms/AKSArcValidationErrors/K8sVersionValidation for recommendations"
      }
   ]
}
```

For more information on troubleshooting the K8sVersionValidation error code, see [Troubleshoot K8sVersionValidation error code](cluster-k8s-version).

## Cause

It's possible that the image provisioning is still in progress. AKS on Azure Local depends on image readiness for the selected Kubernetes version and OS SKU. If the required image variant isn't fully provisioned or available, the Kubernetes version remains not ready and dependent operations can fail.

## Workaround

Use the following steps to recover image readiness.

### 1. Verify available Kubernetes versions

Run the following command to check available Kubernetes versions:

```azurecli
az aksarc get-versions --resource-group <resource-group-name> --custom-location <custom-location-name>
```

Confirm that your target version is listed and supported for your intended OS SKU.

### 2. Check storage path health

Run the following command to verify storage path status:

```azurecli
az stack-hci-vm storagepath list --resource-group <resource-group-name> --custom-location <custom-location-resource-id>
```

If the expected storage path is missing or unhealthy, recreate or update it by following the guidance in [Create storage path for Azure Local](/en-us/azure/azure-local/manage/create-storage-path).

### 3. Refresh storage path metadata

Run the following command to refresh the storage path:

```azurecli
az stack-hci-vm storagepath update --resource-group <resource-group-name> --custom-location <custom-location-resource-id> --name <storage-path-name> --location <azure-region>
```

This action can trigger revalidation and image resynchronization.

### 4. Run support module validation

Use the Support.AksArc diagnostic tool to validate that all tests are passing. For installation and usage instructions, see [Support.AksArc diagnostic and remediation tool](support-module).

Ensure all validation checks pass before proceeding with cluster operations.

### 5. Wait and retry the AKS operation

After recovering the storage path and image sync, retry the failed cluster or node pool operation.

### 6. If the issue persists

If the problem continues after following the previous steps, collect diagnostic logs and open a support request.

Include the following information:

- Resource group
- Custom location
- Azure Local resource ID
- Full error message
- Correlation IDs from the error output

## Prevention

To prevent this issue:

- Keep at least one storage path for AKS cluster to work.
- Validate storage path status is healthy (green status).
- Never rename or change the folder path name locally on the Azure Local machine.
- Avoid deleting storage volumes or storage paths used by AKS on Azure Local.
- Validate storage path availability before cluster upgrades.
- Use supported Kubernetes versions and OS SKUs for your target environment.
- Apply platform updates and retry transient image provisioning states after a short interval.