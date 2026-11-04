---
layout: Conceptual
title: Upgrade or uninstall the Azure Managed Lustre CSI driver - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/azure-managed-lustre-uninstall
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
description: Upgrade or uninstall the Azure Managed Lustre CSI driver installed with Helm or a script. Find the separate lifecycle guide for the preview AKS CLI option.
ms.topic: how-to
ms.subservice: aks-storage
ms.date: 2026-11-02T00:00:00.0000000Z
author: pauljewellmsft
ms.author: akashdubey
ms.reviewer: brianl
ms.custom: sfi-image-nochange
locale: en-us
document_id: fa6695d3-973c-a9a0-40dd-1963df8a8b67
document_version_independent_id: 9ca683d2-e056-88a1-d1f9-5ecb4b3b0e89
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/azure-managed-lustre-uninstall.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/azure-managed-lustre-uninstall
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/azure-managed-lustre-uninstall.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/ae365aa9-5e19-49e1-95cb-6d0af6f19080
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/06cefb7d-f6d5-4371-a867-a6339677d3ad
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 7985b4b8-3160-cda0-c620-154a1aa348cd
---

# Upgrade or uninstall the Azure Managed Lustre CSI driver - Azure Kubernetes Service | Microsoft Learn

This article describes how to upgrade the Azure Managed Lustre CSI driver to v0.6.0 or uninstall it when installed with Helm or a script. For an installation made with the alternative AKS CLI option, use the separate [CLI preview upgrade and uninstall guide](azure-managed-lustre-upgrade-uninstall-cli-preview).

For a new installation, see [Install the Azure Managed Lustre CSI driver](azure-managed-lustre-install).

Important

Use the lifecycle procedure that matches your installation method. Don't run Helm or the cleanup script against an extension-managed driver, or use the AKS disable option to remove a Helm or script installation.

## Choose the matching uninstall method

Use the removal method that matches how you installed the driver:

| Installation method | Matching uninstall method |
| --- | --- |
| Helm | Follow Uninstall a Helm-managed driver. |
| Script | Follow Uninstall a script-managed driver. |
| AKS CLI options (preview): `az aks create` or `az aks update` with `--enable-azure-managed-lustre` or `--enable-amlfs` | Follow [Uninstall with AKS CLI options (preview)](azure-managed-lustre-upgrade-uninstall-cli-preview#uninstall-with-aks-cli-options-preview) and use `az aks update --disable-azure-managed-lustre` or `--disable-amlfs`. |

For upgrades, follow Upgrade the CSI driver for Helm or script installations. For the alternative installation option, see [Upgrade an AKS CLI installation (preview)](azure-managed-lustre-upgrade-uninstall-cli-preview#upgrade-an-aks-cli-installation-preview).

## Upgrade the CSI driver

For a Helm or script installation, upgrade an earlier release (v0.2.0 or later) to v0.6.0 by uninstalling the existing driver and installing v0.6.0 during a maintenance window. This procedure also supports changing from the script to Helm. If your cluster runs a release earlier than v0.2.0, contact Microsoft Support before you upgrade.

Important

Before upgrading, stop every workload that uses Lustre and confirm that no Lustre mounts remain on the nodes. You can't replace the Lustre client kernel modules while a Lustre mount is active. Only then, uninstall the existing driver. Uninstalling the driver doesn't remove existing mounts. Keep workloads stopped until the replacement driver is installed and verified.

Stopping workloads preserves storage only if their controllers retain the PersistentVolumeClaims. Before scaling down a StatefulSet, complete Protect StatefulSet claims. A StatefulSet with `whenScaled: Delete` can delete its template-created claims during scale-down; with a dynamically provisioned PV using `reclaimPolicy: Delete`, that deletion can also remove the remote Azure Managed Lustre file system and its data. Don't delete PVs, PVCs, or file systems as part of the driver upgrade.

### Prepare for the upgrade

Use your existing driver namespace in every `kube-system` command in this article. For Helm commands, also substitute your existing release name for `azurelustre`.

1. Check the effective OS SKU for every node:

    ```bash
    kubectl get nodes -L kubernetes.azure.com/os-sku-effective
    ```

    All nodes in the node pools where you intend to run Azure Managed Lustre workloads must report `Ubuntu2204`, `Ubuntu2404`, `AzureLinux3`, or, for Confidential VM node pools, `Ubuntu2004`. Confirm that the cluster also meets the [Kubernetes and architecture requirements](azure-managed-lustre-overview#supported-kubernetes-and-aks-versions). Don't continue if a required node has a missing or unsupported value. AKS manages this label. Don't change it manually.
2. Confirm the [installation prerequisites](azure-managed-lustre-install#prerequisites), including `cluster-admin` permissions, network access, and node scheduling.
3. For a Helm installation with custom values, export them before uninstalling and keep the file for the reinstall:

    ```bash
    helm get values azurelustre --namespace kube-system --output yaml > azurelustre-values.yaml
    ```

    Review the exported values for compatibility with the v0.6.0 chart before reusing them. Don't override the released driver image or Lustre client versions unless Microsoft Support directs you to.
4. List the PersistentVolumes that use the Azure Lustre CSI driver:

    ```bash
    printf 'PV\tCLAIM\tSTATUS\tDELETING\n'
    kubectl get pv -o jsonpath='{range .items[?(@.spec.csi.driver=="azurelustre.csi.azure.com")]}{.metadata.name}{"\t"}{.spec.claimRef.namespace}{"/"}{.spec.claimRef.name}{"\t"}{.status.phase}{"\t"}{.metadata.deletionTimestamp}{"\n"}{end}'
    ```

    Use the claim references to account for every bound Azure Lustre claim, even if its StorageClass no longer exists.
5. List the storage classes that use the Azure Lustre CSI driver:

    ```bash
    kubectl get storageclass -o jsonpath='{range .items[?(@.provisioner=="azurelustre.csi.azure.com")]}{.metadata.name}{"\n"}{end}'
    ```
6. List all PersistentVolumeClaims and use the preceding storage class list to identify unbound Azure Lustre claims:

    ```bash
    kubectl get pvc --all-namespaces -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,STORAGECLASS:.spec.storageClassName,STATUS:.status.phase,VOLUME:.spec.volumeName,DELETING:.metadata.deletionTimestamp'
    ```

    Account for every Azure Lustre claim, including claims with `Pending` status. Don't continue if an Azure Lustre PV or PVC has a deletion timestamp, or while an Azure Lustre volume creation or deletion is in progress.
7. List pods and the PersistentVolumeClaims that they reference:

    ```bash
    kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\t"}{range .spec.volumes[?(@.persistentVolumeClaim)]}{.persistentVolumeClaim.claimName}{" "}{end}{"\n"}{end}'
    ```

#### Protect StatefulSet claims

Complete these checks before scaling down or deleting any application workloads. See [StatefulSet PersistentVolumeClaim retention](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#persistentvolumeclaim-retention) for the retention and garbage-collection behavior.

1. Identify StatefulSets that manage any of the Azure Lustre claims from the inventory, including claims created from `volumeClaimTemplates`. Inspect their desired replica counts and claim retention policies:

    ```bash
    kubectl get statefulsets --all-namespaces -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,REPLICAS:.spec.replicas,WHEN-SCALED:.spec.persistentVolumeClaimRetentionPolicy.whenScaled,WHEN-DELETED:.spec.persistentVolumeClaimRetentionPolicy.whenDeleted'
    ```

    Unset retention fields default to `Retain`. `whenScaled: Delete` deletes template-created claims when replicas are removed; `whenDeleted: Delete` deletes them when the StatefulSet is deleted.
2. Record each affected StatefulSet's original replica count and retention policy. Update or pause operators, autoscalers, and GitOps automation so they can't scale down or delete these workloads or revert the retention policy during maintenance. Keep the Kubernetes StatefulSet controller and CSI driver running.
3. For each affected StatefulSet with a `Delete` retention setting, set both `whenScaled` and `whenDeleted` to `Retain` for the maintenance window. Make the change in its source configuration if an operator or GitOps process manages it. For a directly managed StatefulSet, use:

    ```bash
    kubectl patch statefulset <statefulset-name> -n <namespace> \
      --type=merge \
      -p '{"spec":{"persistentVolumeClaimRetentionPolicy":{"whenScaled":"Retain","whenDeleted":"Retain"}}}'
    ```

    Read back the StatefulSet to confirm the effective policy before continuing:

    ```bash
    kubectl get statefulset <statefulset-name> -n <namespace> -o yaml
    ```
4. Wait for the StatefulSet controller to reconcile the policy on every affected template-created PVC. Inspect each claim:

    ```bash
    kubectl get pvc <claim-name> -n <namespace> -o yaml
    ```

    Don't continue until every claim has no deletion timestamp and its `metadata.ownerReferences` no longer contains the StatefulSet or any of its pods. A successful policy patch alone doesn't prove that these references have been reconciled. Don't manually remove owner references or finalizers to bypass this check.
5. Repeat the PV and PVC inventory checks before stopping workloads. Don't continue if a claim is missing, a PV or PVC has a deletion timestamp, the retention policy reverts, or you can't verify that the claims will be retained. Resolve the condition with the workload or cluster administrator first.

#### Stop workloads and inspect mounts

1. Before stopping the workloads, record their nodes with `kubectl get pods --all-namespaces -o wide`.
2. After verifying claim retention, stop every application workload that uses an Azure Managed Lustre claim. Scale its Deployments or protected StatefulSets to zero replicas, suspend its scheduled jobs, and pause any deployment or GitOps process that recreates its pods. Don't delete StatefulSets as a shutdown shortcut. Delete standalone application pods, including the provisioning example pods. Keep the CSI driver running until you confirm that no Lustre mounts remain.
3. Repeat the pod-and-claim inventory query from Prepare for the upgrade. Don't continue while it lists a pod that references an Azure Managed Lustre claim, including a pod in `Terminating` state.
4. List the CSI node pods:

    ```bash
    kubectl get pods -n kube-system -l app=csi-azurelustre-node -o wide
    ```

    Compare the `NODE` column with the nodes used by the workloads you stopped. Don't continue unless every such node has a CSI node pod in `Running` state that you can inspect for remaining mounts.
5. Check every CSI node pod for remaining Lustre mounts:

    ```bash
    (
      set -e
      pods=$(kubectl get pods -n kube-system -l app=csi-azurelustre-node -o name)
      if [ -z "$pods" ]; then
        echo "No Azure Lustre CSI node pods found." >&2
        exit 1
      fi
      for pod in $pods; do
        echo "$pod"
        kubectl exec -n kube-system "$pod" -c azurelustre -- \
          sh -c 'grep " - lustre " /proc/self/mountinfo; status=$?; [ "$status" -eq 1 ]'
      done
      echo "No Lustre mounts remain on the inspected nodes."
    )
    ```

    The command displays each CSI node pod, then prints `No Lustre mounts remain on the inspected nodes.` on success. It exits with an error if it finds a Lustre mount or can't inspect a pod. Don't continue if the command fails.

### Install v0.6.0

Complete the preparation and unmount checks first. Keep Azure Managed Lustre workloads stopped until verification is complete.

1. Remove the existing driver by using the Helm uninstall procedure for a Helm release, or the script uninstall procedure for a script-managed installation. Leave PVs, PVCs, and file systems in place.
2. Confirm that both lists are empty before installing the replacement:

    ```bash
    kubectl get pods -n kube-system -l app=csi-azurelustre-node
    kubectl get pods -n kube-system -l app=csi-azurelustre-controller
    ```
3. Follow the [Helm](azure-managed-lustre-install#install-with-helm) or [script](azure-managed-lustre-install#install-with-the-script) procedure to install v0.6.0. For a Helm reinstall, use the same release name and namespace, and add `--values azurelustre-values.yaml` if you exported custom values.
4. Complete Verify the upgrade before restarting workloads. If installation reports a timeout, use those checks to determine its state before retrying.

### Verify the upgrade

1. Complete the [installation checks](azure-managed-lustre-install#verify-the-installation).
2. Check the loaded Lustre kernel module version on every CSI node pod:

    ```bash
    (
      set -e
      pods=$(kubectl get pods -n kube-system -l app=csi-azurelustre-node -o name)
      if [ -z "$pods" ]; then
        echo "No Azure Lustre CSI node pods found." >&2
        exit 1
      fi
      for pod in $pods; do
        echo "$pod"
        kubectl exec -n kube-system "$pod" -c lustre-loader -- \
          cat /sys/module/lustre/version
      done
    )
    ```

    Compare the loaded version with the expected Lustre client version for the node's OS in the [compatibility table](azure-managed-lustre-overview#azure-lustre-csi-driver-versions).

### Restart workloads

Keep Azure Managed Lustre workloads stopped until verification is complete. Then restart them and confirm that a representative workload's normal file operations succeed. You can inspect its mount with:

```bash
kubectl exec -n <namespace> <pod-name> -- df -h <mount-path>
```

Restore StatefulSets to their intended replica counts and verify that they reuse the original claims and file systems. Only after the workloads are running at those replica counts and their mounts are verified should you restore any recorded retention policies and resume automation. Don't restore a `Delete` policy while the StatefulSet is still scaled down for maintenance.

### Recover from an unsuccessful upgrade

Important

Keep Azure Managed Lustre workloads stopped while recovering from an unsuccessful upgrade. Don't install an arbitrary older driver release, because it might not support the node operating system, kernel, or Lustre client version in the cluster.

Use the [v0.6.0 troubleshooting guide](https://github.com/kubernetes-sigs/azurelustre-csi-driver/blob/v0.6.0/docs/csi-debug.md) and [v0.6.0 error reference](https://github.com/kubernetes-sigs/azurelustre-csi-driver/blob/v0.6.0/docs/errors.md) to correct the failure, then repeat Verify the upgrade. If you can't complete the installation or confirm that existing Lustre mounts are gone, contact Microsoft Support before removing more resources.

## Uninstall the driver

Before scaling down StatefulSets, complete Protect StatefulSet claims. Stop every workload that uses Lustre and confirm that no Lustre mounts remain before uninstalling the driver. Use the workload and mount checks in Prepare for the upgrade. Uninstalling the driver doesn't remove existing mounts.

### Uninstall a Helm-managed driver

Use the release name and namespace from your installation:

```bash
helm uninstall azurelustre --namespace kube-system --wait --timeout 30m
```

Helm removes the resources in the release. It doesn't delete PVs, PVCs, or Azure Managed Lustre file systems.

### Uninstall a script-managed driver

Use the v0.6.0 cleanup script to remove a script-managed v0.2.0 or later installation. Also delete the legacy `csi-azurelustre-node` DaemonSet explicitly because it lacks the label selected by the script:

```bash
git clone --branch v0.6.0 --depth 1 https://github.com/kubernetes-sigs/azurelustre-csi-driver.git
cd azurelustre-csi-driver
./deploy/uninstall-driver.sh
kubectl delete daemonset csi-azurelustre-node -n kube-system --ignore-not-found
```

These commands remove the CSI controller, node DaemonSets, `CSIDriver` object, and RBAC resources. They don't delete PersistentVolumes, PersistentVolumeClaims, or Azure Managed Lustre file systems.

## Upgrade an AKS CLI installation (preview)

See [Upgrade an AKS CLI installation (preview)](azure-managed-lustre-upgrade-uninstall-cli-preview#upgrade-an-aks-cli-installation-preview). Don't apply the Helm or script upgrade procedure to an extension-managed driver.

## Uninstall with AKS CLI options (preview)

For prerequisites, volume cleanup, the matching disable command, and removal verification, see [Uninstall with AKS CLI options (preview)](azure-managed-lustre-upgrade-uninstall-cli-preview#uninstall-with-aks-cli-options-preview).