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
ms.date: 2026-11-03T00:00:00.0000000Z
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

There's no direct, in-place upgrade path for the managed extension. To upgrade, you must disable the extension, wait for removal to complete, and then enable it again. Running the enable command while the extension is already installed preserves its configuration but doesn't upgrade or reinstall it. Don't use Helm or the cleanup script to manage an extension-installed driver.

The workload and volume precautions for a Helm upgrade also apply to this procedure. Plan a maintenance window and complete the following steps in order.

Important

Stop every workload that uses Lustre and confirm that no Lustre mounts remain on the nodes before disabling the extension. You can't replace the Lustre client kernel modules while a Lustre mount is active. Disabling the extension doesn't unmount existing volumes. Keep workloads stopped until the replacement driver is installed and verified.

Preserve persistent volumes (PVs), persistent volume claims (PVCs), and Azure Managed Lustre file systems during the upgrade. Don't run the volume-cleanup steps, which are for permanent removal. With `reclaimPolicy: Delete`, deleting a dynamically provisioned claim can also delete the file system and its data.

1. Confirm the [CLI installation prerequisites](azure-managed-lustre-install-cli-preview#install-with-aks-cli-options-preview). Record the installed extension version, configuration, and driver namespace, and back up data you need to preserve. Use the volume, claim, storage class, and pod inventory commands in [Prepare for the upgrade](azure-managed-lustre-uninstall#prepare-for-the-upgrade), but skip the Helm-specific steps. Account for every Lustre claim, including claims with `Pending` status. Don't continue while a PV or PVC has a deletion timestamp or volume creation or deletion is in progress.
2. Before scaling down StatefulSets, complete [Protect StatefulSet claims](azure-managed-lustre-uninstall#protect-statefulset-claims). Set `whenScaled` and `whenDeleted` to `Retain` for affected StatefulSets and verify that the controller has reconciled the claims' owner references. Record the original replica counts and retention policies, and pause operators, autoscalers, and GitOps automation that could delete claims or undo the retention changes. Keep the StatefulSet controller and CSI driver running during these checks.
3. Follow [Stop workloads and inspect mounts](azure-managed-lustre-uninstall#stop-workloads-and-inspect-mounts). Use your extension's driver namespace and pod labels for the inspection commands. Keep the driver running until every workload stops and you verify that no Lustre mounts remain on every affected node. Don't continue if a workload pod is still terminating or a node can't be inspected.
4. Disable the extension with `az aks update --disable-azure-managed-lustre`, and complete Verify removal. Confirm that the old CSI controller and node pods are gone before reinstalling. If retained volumes block removal, stop and contact Microsoft Support. Don't delete those volumes or remove finalizers to force the upgrade.
5. [Enable Azure Managed Lustre on the existing AKS cluster](azure-managed-lustre-install-cli-preview#enable-azure-managed-lustre-on-an-existing-aks-cluster) with `az aks update --enable-azure-managed-lustre`. Follow the extension verification steps in that section and confirm that its provisioning state is `Succeeded`. Verify the installed extension and driver versions, and check that any required configuration is present; don't assume that disabling and re-enabling preserves custom settings.
6. Verify that the CSI controller and node pods are ready and that every intended workload node has a ready CSI node pod. Check the loaded Lustre client version on each node against the requirements for the installed driver release. Keep workloads stopped if installation, readiness, or version checks fail.
7. Follow [Restart workloads](azure-managed-lustre-uninstall#restart-workloads). Confirm that workloads reuse their original claims and file systems and that normal file operations succeed. Restore the original retention policies and resume automation only after StatefulSets are running at their intended replica counts and their mounts are verified. Don't restore a `Delete` policy while a StatefulSet is still scaled down.

## Uninstall with AKS CLI options (preview)

Important

The `--disable-azure-managed-lustre` option and its `--disable-amlfs` alias are preview features provided by the `aks-preview` Azure CLI extension. They are the matching removal options for installation with `--enable-azure-managed-lustre` or `--enable-amlfs`.

### Before you begin

- Use the Azure CLI extensions described in [Install with AKS CLI options (preview)](azure-managed-lustre-install-cli-preview#install-with-aks-cli-options-preview).
- Configure `kubectl` for the cluster.
- Stop all workloads that use Lustre and let their volumes unmount.
- Clean up their Kubernetes volumes before removing the extension. Remaining volumes or mounts can prevent driver removal.

### Clean up volumes

These cleanup steps are for permanent removal, not for an extension upgrade. Keep your PVs, PVCs, and file systems when upgrading.

Follow the cleanup steps for the provisioning method you used:

| Provisioning method | Cleanup behavior |
| --- | --- |
| [Static provisioning](azure-managed-lustre-static-provisioning#clean-up-the-example) | The example removes the pod, claim, retained PV, and storage class. The existing Lustre file system and its data remain. |
| [Dynamic provisioning](azure-managed-lustre-dynamic-provisioning#clean-up-the-example) | With `Delete`, deleting the claim also deletes the provisioned file system and its data. With `Retain`, the PV and file system remain for manual cleanup. |

Save any data you need before deleting dynamically provisioned storage. Keep the extension installed until volume cleanup completes. Cleaning up the example resources alone isn't sufficient if other workloads still use Lustre.

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