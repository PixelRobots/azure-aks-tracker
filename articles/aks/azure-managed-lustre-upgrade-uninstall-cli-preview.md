---
layout: Conceptual
title: Upgrade or uninstall Azure Managed Lustre with AKS CLI options (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/azure-managed-lustre-upgrade-uninstall-cli-preview
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
description: Review upgrade guidance and uninstall the Azure Managed Lustre extension installed with the preview AKS CLI options.
ms.topic: how-to
ms.subservice: aks-storage
ms.date: 2026-11-10T00:00:00.0000000Z
author: wolfgang-desalvador
ms.author: wdesalvador
ai-usage: ai-assisted
locale: en-us
document_id: f9b3073c-9d33-189e-6727-63bfc3a7c84b
document_version_independent_id: 8e5df96a-6981-4cc6-0034-827bffad2d8c
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/azure-managed-lustre-upgrade-uninstall-cli-preview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/azure-managed-lustre-upgrade-uninstall-cli-preview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/azure-managed-lustre-upgrade-uninstall-cli-preview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/ae365aa9-5e19-49e1-95cb-6d0af6f19080
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/06cefb7d-f6d5-4371-a867-a6339677d3ad
platformId: b7d54c68-e627-619c-cc82-59b0fd5e8731
---

# Upgrade or uninstall Azure Managed Lustre with AKS CLI options (preview) - Azure Kubernetes Service | Microsoft Learn

Use this article for the managed extension installed with `az aks create` or `az aks update` and `--enable-azure-managed-lustre` or `--enable-amlfs`. For a driver installed with Helm or a script, use [Upgrade or uninstall the Azure Managed Lustre CSI driver](azure-managed-lustre-uninstall) instead.

Important

Match the removal method to the installation method. Don't use Helm or the cleanup script against an extension-managed driver, or use the AKS disable option to remove a Helm or script installation.

## Upgrade an AKS CLI installation (preview)

Contact Microsoft Support for an update plan for your installed extension version. Don't disable the extension or delete volumes just to install v0.7.0.

Running the preview `enable` command again for a successfully installed extension doesn't upgrade it. Don't use Helm or the cleanup script to update an extension-installed driver.

## Uninstall with AKS CLI options (preview)

Important

The `--disable-azure-managed-lustre` option and its `--disable-amlfs` alias are preview features provided by the `aks-preview` Azure CLI extension. They are the matching removal options for installation with `--enable-azure-managed-lustre` or `--enable-amlfs`.

### Before you begin

- Use the Azure CLI extensions described in [Install with AKS CLI options (preview)](azure-managed-lustre-install-cli-preview#install-with-aks-cli-options-preview).
- Configure `kubectl` for the cluster.
- Stop all workloads that use Lustre and let their volumes unmount.
- Clean up their Kubernetes volumes before removing the extension. Remaining volumes or mounts can prevent driver removal.

Driver v0.7.0 fails removal if any PV uses the installed CSI driver identity, or if it can't query the inventory. This condition includes static and retained PVs. Complete cleanup before disabling the extension. The guard can't restore an Azure extension resource that is deleted before its Helm cleanup finishes.

### Clean up volumes

These cleanup steps are for permanent removal, not for an extension upgrade. Keep your PVs, PVCs, and file systems when upgrading.

Follow the cleanup steps for the provisioning method you used:

| Provisioning method | Cleanup behavior |
| --- | --- |
| [Static provisioning](azure-managed-lustre-static-provisioning#clean-up-the-example) | The example removes the pod, claim, retained PV, and storage class. The existing Lustre file system and its data remain. |
| [Dynamic provisioning](azure-managed-lustre-dynamic-provisioning#clean-up-the-example) | With `Delete`, deleting the claim also deletes the provisioned file system and its data. With `Retain`, the PV and file system remain for manual cleanup. |

Save any data you need before deleting dynamically provisioned storage. Keep the extension installed until volume cleanup completes. Cleaning up the example resources alone isn't sufficient if other workloads still use Lustre.

If you intend to retain a dynamically provisioned file system, set and verify `Retain` on the existing PV before deleting its claim. Save the PV configuration and file system mapping. After all consumers and the claim are gone, delete the remaining PV object; this action doesn't delete the retained file system. Verify that a cluster-wide inventory using the installed driver identity succeeds with no matching PVs. See the [safe uninstall checks](azure-managed-lustre-uninstall#uninstall-the-driver), using your extension's driver identity and namespace.

Don't remove finalizers, force-delete the extension, or bypass Helm hooks to clear a blocked upgrade or uninstall. Retained file systems continue to incur charges; verify their disposition separately.

### Disable the extension

Set the resource group and cluster name:

```azurecli
RESOURCE_GROUP="myResourceGroup"
AKS_CLUSTER="myAKSCluster"
```

Disable Azure Managed Lustre on the cluster:

```azurecli
az aks update \
  --resource-group "$RESOURCE_GROUP" \
  --name "$AKS_CLUSTER" \
  --disable-azure-managed-lustre
```

You can also use the `--disable-amlfs` alias.

### Verify removal

List the cluster extensions:

```azurecli
az k8s-extension list \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$AKS_CLUSTER" \
  --cluster-type managedClusters \
  --output table
```

Confirm that the `azurelustre` extension is no longer listed. Driver removal can continue after the command finishes, so also confirm that the driver is no longer registered in the cluster:

```bash
kubectl get csidriver azurelustre.csi.azure.com
```

After removal, this command returns `NotFound`. If removal doesn't complete, check for workloads or volumes that still use Lustre and contact support if needed. Don't reinstall the extension until removal completes.

Disabling the extension doesn't itself delete Azure Managed Lustre file systems. Any file systems you retained continue to exist and incur charges until you delete them separately.