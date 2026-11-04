---
layout: Conceptual
title: Dynamic provisioning reference for Azure Managed Lustre on AKS - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/azure-managed-lustre-dynamic-provisioning-reference
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
description: Review identity permissions and file system settings for dynamic provisioning, and find the Azure Managed Lustre walkthrough for AKS.
ms.topic: reference
ms.subservice: aks-storage
ms.date: 2026-10-30T00:00:00.0000000Z
author: pauljewellmsft
ms.author: akashdubey
ms.reviewer: brianl
ms.custom: sfi-image-nochange
locale: en-us
document_id: 90fb8fbe-afa9-268a-dea7-931577754d99
document_version_independent_id: 144735f5-bf94-23e3-04e7-323d16014992
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/azure-managed-lustre-dynamic-provisioning-reference.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/azure-managed-lustre-dynamic-provisioning-reference
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/azure-managed-lustre-dynamic-provisioning-reference.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/ae365aa9-5e19-49e1-95cb-6d0af6f19080
- https://authoring-docs-microsoft.poolparty.biz/devrel/68cb9039-df60-49b0-8ef8-89ad96497f63
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/06cefb7d-f6d5-4371-a867-a6339677d3ad
- https://authoring-docs-microsoft.poolparty.biz/devrel/725b6df3-93e8-472d-834e-e7e0d2953d35
platformId: da648430-1d22-94fe-ae18-1e4f83f82fc1
---

# Dynamic provisioning reference for Azure Managed Lustre on AKS - Azure Kubernetes Service | Microsoft Learn

Dynamic provisioning creates an Azure Managed Lustre file system when you create a persistent volume claim. Follow [Dynamically provision Azure Managed Lustre volumes for AKS](azure-managed-lustre-dynamic-provisioning) for the complete walkthrough. This page provides the identity permissions, configuration reference, and troubleshooting information used by that guide.

Note

Dynamic provisioning is available starting with Azure Lustre CSI Driver version 0.3.0. For more information, see the [v0.3.0 release notes](https://github.com/kubernetes-sigs/azurelustre-csi-driver/releases/tag/v0.3.0).

## Prerequisites for dynamic provisioning

- An AKS cluster with a supported Linux node pool. See the [compatibility reference](azure-managed-lustre-overview#supported-kubernetes-and-aks-versions) for driver-version-specific requirements.
- A ready CSI driver. Follow [Install the Azure Managed Lustre CSI driver](azure-managed-lustre-install) and complete verification for your chosen installation method.

### Permissions

Important

Before dynamically creating file systems, grant permissions to the identity used by the installed CSI controller, not the user running the Azure CLI. Confirm that identity before assigning access.

The controller identity requires permissions to read and join the existing subnet, validate Azure Managed Lustre subnet requirements, and read, create, update, and delete file systems. See the [v0.6.0 permission requirements](https://github.com/kubernetes-sigs/azurelustre-csi-driver/blob/v0.6.0/docs/driver-parameters.md#permissions-for-kubelet-identity).

For Helm installations, use the [identity configuration in the installation guide](azure-managed-lustre-install#install-with-helm). If you chose the preview AKS CLI option, use only the identity configuration supported by your installed extension; don't apply Helm settings to it.

### Network requirements

- An existing virtual network and subnet for the Azure Managed Lustre cluster
- Sufficient IP addresses available in the subnet for the cluster
- Proper network security group rules to allow Lustre traffic

For network architecture planning, see [Plan network architecture for AKS with Azure Managed Lustre](azure-managed-lustre-network-planning).

## Install the driver for dynamic provisioning

Complete the shared [driver installation](azure-managed-lustre-install) once for either provisioning method, using Helm, the script, or the alternative AKS CLI option in preview. Don't combine installation methods or install a second copy of the driver. Create the claim and workload in the same namespace.

## Create a Storage Class for dynamic provisioning

Use the complete storage class in [Create a storage class](azure-managed-lustre-dynamic-provisioning#create-a-storage-class). The following settings describe the Azure file system.

| Setting | Purpose |
| --- | --- |
| `sku-name` | Select the file system throughput configuration available in the target region. |
| `zone` | Select a supported availability zone, or omit this setting if the chosen region and configuration don't support zones. |
| `maintenance-day-of-week` | Set the maintenance day. |
| `maintenance-time-of-day-utc` | Set the maintenance start time in UTC, using the 24-hour `HH:MM` format. |
| `location` | Set the region where the file system is created. |
| `resource-group-name` | Identify the existing resource group where the file system is created. |
| `vnet-resource-group` | Identify the resource group containing the existing virtual network. |
| `vnet-name` and `subnet-name` | Identify the prepared network and Lustre subnet. Use a subnet separate from AKS. |
| `reclaimPolicy` | Set `Delete` to remove provisioned storage with its claim, or `Retain` to keep it for manual cleanup. |

Set the resource group and network values explicitly, as the AKS example does, rather than relying on defaults that might select the AKS infrastructure resource group or subnet. The driver creates the file system, not these prerequisite resources.

For reference, the upstream v0.6.0 driver uses these defaults when optional settings are omitted:

| Optional setting | Default |
| --- | --- |
| `location` | AKS cluster location. |
| `resource-group-name` | AKS infrastructure resource group. |
| `vnet-resource-group` | Resource group of the AKS virtual network. |
| `vnet-name` | AKS virtual network. |
| `subnet-name` | AKS subnet. Specify a separate Lustre subnet instead of relying on this default. |

Choose the file system configuration, region, zone, and capacity together. See [File system configuration](/en-us/azure/azure-managed-lustre/create-file-system-portal#basics-tab) and [capacity increments](/en-us/azure/azure-managed-lustre/create-file-system-portal#throughput-configurations). For the underlying driver parameters, see the [v0.6.0 reference](https://github.com/kubernetes-sigs/azurelustre-csi-driver/blob/v0.6.0/docs/driver-parameters.md).

Creating claims provisions billable Azure resources. Consider namespace-level storage-class quotas when testing to avoid unintentionally creating multiple file systems.

### Limit claims with a resource quota

To limit the AKS example's `azurelustre-dynamic` storage class to one claim in the current workload namespace, save the following as `azure-managed-lustre-quota.yaml`:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: azurelustre-dynamic-quota
spec:
  hard:
    azurelustre-dynamic.storageclass.storage.k8s.io/persistentvolumeclaims: "1"
```

Apply the quota in the same namespace as the claim:

```bash
kubectl apply -f azure-managed-lustre-quota.yaml
```

This quota limits claim count for this storage class in that namespace; it isn't a subscription-wide file system quota.

## Create a Persistent Volume Claim for dynamic provisioning

Follow [Create a persistent volume claim](azure-managed-lustre-dynamic-provisioning#create-a-persistent-volume-claim). The claim references the storage class and requests capacity suitable for the selected file system configuration.

## Monitor file system creation

File system provisioning can take 10 minutes or more. Wait until the claim is `Bound` before starting the workload. Use the status and event commands in the [AKS walkthrough](azure-managed-lustre-dynamic-provisioning#create-a-persistent-volume-claim).

## Create a pod for dynamic provisioning

Use the Ubuntu-based pod in [Mount and verify the volume](azure-managed-lustre-dynamic-provisioning#mount-and-verify-the-volume). Run it on a supported node pool with the driver installed.

## Verify dynamic provisioning

Verify that the pod is ready, the file system is mounted, and the example writes succeed. The [AKS walkthrough](azure-managed-lustre-dynamic-provisioning#mount-and-verify-the-volume) includes the commands.

## Clean up dynamic resources

Follow [Clean up the dynamic example](azure-managed-lustre-dynamic-provisioning#clean-up-the-example). With `Delete`, deleting the claim also deletes its persistent volume (PV) and Azure Managed Lustre file system, including data. Save data you need before deleting the claim.

With `Retain`, the PV and file system remain for manual cleanup. Keep the driver installed until volume cleanup completes. Removing the driver isn't a substitute for deleting a retained file system when it's no longer needed.

If you created the optional resource quota and no longer need it, delete it from the same workload namespace:

```bash
kubectl delete resourcequota azurelustre-dynamic-quota
```

## Troubleshooting

To troubleshoot issues with the Azure Lustre CSI Driver, see the [v0.6.0 CSI driver troubleshooting guide](https://github.com/kubernetes-sigs/azurelustre-csi-driver/blob/v0.6.0/docs/csi-debug.md) in the GitHub repository.

For common driver installation, node scheduling, and upgrade issues, see [CSI driver troubleshooting](azure-managed-lustre-overview#troubleshooting).

Common issues for dynamic provisioning include:

- **Authentication or authorization errors** - verify the configured controller identity's permissions for creating Azure Managed Lustre clusters. For workload identity, also check OIDC, federation, and the controller ServiceAccount configuration.
- **SKU and zone validation errors** - check the available region, zone, and throughput options in the [file system configuration](/en-us/azure/azure-managed-lustre/create-file-system-portal#basics-tab), then update `location`, `sku-name`, and `zone` in your StorageClass. For a SKU and region without availability zones, remove `zone`.
- **Network IP address availability** - confirm sufficient IP addresses are available in the target subnet.
- **Quota limitations** - check both Kubernetes resource quotas and Azure subscription quotas for Azure Managed Lustre clusters.
- **Network connectivity problems** between AKS and Azure Managed Lustre - verify virtual network peering or subnet configuration.

For additional troubleshooting resources, see:

- [Troubleshoot Azure Managed Lustre CSI driver extension errors](/en-us/troubleshoot/azure/azure-kubernetes/extensions/troubleshoot-azurelustre-csi-extension-errors)
- [Azure Managed Lustre troubleshooting](/en-us/azure/azure-managed-lustre/troubleshoot-deployment)
- [Azure Lustre CSI Driver GitHub repository](https://github.com/kubernetes-sigs/azurelustre-csi-driver)