---
layout: Conceptual
title: Troubleshoot managed KubeRay extension errors in AKS (preview) - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/troubleshoot-kuberay-extension-errors
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
description: Troubleshoot managed KubeRay extension errors on AKS. Diagnose installation, update, removal, and readiness failures.
ms.date: 2026-10-22T00:00:00.0000000Z
ms.reviewer: alyssavu, lichen5
ms.service: azure-kubernetes-service
ms.custom: sap:Extensions, Policies and Add-Ons
ai-usage: ai-generated
locale: en-us
document_id: 841673d3-72ab-ffef-07f5-9183691803ba
document_version_independent_id: 841673d3-72ab-ffef-07f5-9183691803ba
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/troubleshoot-kuberay-extension-errors.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/troubleshoot-kuberay-extension-errors
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/troubleshoot-kuberay-extension-errors.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 3bba8474-d230-c4f7-e7fa-7ce2e84bb7fe
---

# Troubleshoot managed KubeRay extension errors in AKS (preview) - Azure | Microsoft Learn

## Summary

This article helps you troubleshoot the managed KubeRay extension on Azure Kubernetes Service (AKS). It covers extension status, installation, updates, removal, and readiness during preview.

For installation and management instructions, see [Install the managed KubeRay extension on AKS](/en-us/azure/aks/kuberay-overview).

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

For Helm chart [download](cluster-extension-deployment-errors#error-unable-to-download-the-helm-chart-from-the-repo-url) or [rendering](cluster-extension-deployment-errors#error-helm-chart-rendering-failed-with-given-values) errors, use the shared troubleshooting guidance.

## Diagnose the extension

First, examine the Azure extension resource, operator deployment, and Ray custom resource definitions (CRDs). Then, examine Kubernetes events and operator logs.

Set the cluster values for the examples:

```bash
RESOURCE_GROUP="<resource-group>"
CLUSTER_NAME="<aks-cluster>"
EXTENSION_NAME="kuberay"
RELEASE_TRAIN="preview"
```

Use this command to show the extension status without configuration values:

```bash
az k8s-extension show \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --cluster-type managedClusters \
  --name "$EXTENSION_NAME" \
  --query "{requestedVersion:version,currentVersion:currentVersion,releaseTrain:releaseTrain,autoUpgradeMinorVersion:autoUpgradeMinorVersion,provisioningState:provisioningState,extensionState:extensionState,errorInfo:errorInfo,statuses:statuses}" \
  --output json
```

For a healthy extension, `provisioningState` is `Succeeded` and `extensionState` is `Available`.

Examine `currentVersion` to identify the installed extension package. If the extension failed, examine `errorInfo` and `statuses` before you retry or delete the extension.

Examine the operator and recent events:

```bash
kubectl get deployment,pods --namespace kuberay-system --output wide
kubectl describe deployment kuberay-operator --namespace kuberay-system
kubectl get events --namespace kuberay-system --sort-by=.lastTimestamp
```

Collect current operator logs:

```bash
kubectl logs \
  --namespace kuberay-system \
  --selector app.kubernetes.io/name=kuberay-operator \
  --all-containers=true \
  --prefix \
  --tail=1000
```

If the operator container restarted, collect logs from the previous container instance:

```bash
kubectl logs \
  --namespace kuberay-system \
  --selector app.kubernetes.io/name=kuberay-operator \
  --all-containers=true \
  --prefix \
  --previous \
  --tail=1000
```

## The CLI doesn't recognize the auto-upgrade mode

**Symptom:** The create or update command returns `unrecognized arguments: --auto-upgrade-mode`.

**Cause:** The installed `k8s-extension` Azure CLI extension is earlier than version 1.8.0. It doesn't recognize the `--auto-upgrade-mode` option.

**Resolution:** Use `--auto-upgrade-minor-version true` instead of `--auto-upgrade-mode`. Don't specify `--version` with automatic upgrades enabled.

Update the CLI extension. Then, check the installed version:

```bash
az extension add --name k8s-extension --upgrade
az extension show --name k8s-extension --query version --output tsv
```

## Installation or update can't resolve an extension version

**Symptom:** The create or update command can't resolve the extension version. Alternatively, version discovery returns no compatible versions.

**Cause:** Package availability depends on the release train, region, and supported Kubernetes version. Possible causes include:

- The requested version isn't available for the cluster and release train.
- The command combines `--version` with `--auto-upgrade-minor-version true`.

Use an AKS-supported Azure public cloud region and the `preview` release train.

**Resolution:**

1. Verify the resource group, cluster name, and `preview` release train before you list compatible packages.

    ```bash
    az k8s-extension extension-types list-versions-by-cluster \
      --resource-group "$RESOURCE_GROUP" \
      --cluster-name "$CLUSTER_NAME" \
      --cluster-type managedClusters \
      --extension-type microsoft.kuberay \
      --release-train "$RELEASE_TRAIN" \
      --output table
    ```
2. If discovery returns no compatible package, correct any input errors before you repeat discovery.
3. If no compatible package is available, stop new installation or update requests. Contact Azure support with the diagnostic information before further changes.
4. If a compatible package is available, enable automatic upgrades with `--auto-upgrade-minor-version true`. For managed KubeRay, these updates keep the upstream KubeRay version unchanged.
5. Omit `--version` from create and update commands. Preview doesn't support an extension version downgrade or rollback.
6. Correct any version-setting conflict before you retry.
7. Retry the update with automatic upgrades enabled.

    ```bash
    az k8s-extension update \
      --resource-group "$RESOURCE_GROUP" \
      --cluster-name "$CLUSTER_NAME" \
      --cluster-type managedClusters \
      --name "$EXTENSION_NAME" \
      --release-train "$RELEASE_TRAIN" \
      --auto-upgrade-minor-version true \
      --yes
    ```

The extension package version controls the KubeRay operator. It doesn't change the Ray runtime version in your workload images.

## Installation detects an existing self-hosted KubeRay operator

**Symptom:** Installation fails. The error message starts with `managed KubeRay preflight failed: detected existing KubeRay operator`.

**Cause:** Preview doesn't support same-cluster, in-place adoption of a self-hosted KubeRay operator. KubeRay requires a single operator per cluster. The managed extension rejects installation if it detects a self-hosted or otherwise unmanaged operator.

**Resolution:**

1. Stop retries on the affected cluster. Rejection doesn't prove that the existing CRDs are unchanged.
2. Keep required workload data, manifests, Ray CRDs, and user-created resources.
3. Collect the diagnostics in the following section before making further changes.
4. Request guidance from Azure support before you uninstall an operator, delete a failed extension, or change CRD ownership.
5. For a new managed installation, use a clean target cluster with no KubeRay installation. Alternatively, [uninstall the self-hosted operator first](/en-us/azure/aks/kuberay-overview#uninstall-an-existing-oss-kuberay-operator). Removal of the operator is a prerequisite. It's not a supported in-place adoption procedure.
6. On an affected cluster, resolve the CRD state with Azure support before making another managed installation attempt.

Warning

Don't force CRD ownership transfers, rewrite ownership metadata, or delete Ray CRDs or workload namespaces to recover. If you delete a CRD, you also delete its custom resources.

A known safety issue can change Ray CRD schemas, labels, and field ownership before the conflicting-operator check rejects installation. This change is a defect, not a supported migration or ownership-transfer method. These precautions don't fix the defect.

If you delete the failed extension, the previous CRD state doesn't return. If you uninstall the self-hosted operator, the previous CRD state doesn't return.

If the extension rejected installation over a self-hosted operator, collect these diagnostics before making further changes:

- The extension error.
- The Helm version.
- The operator deployment.
- The CRD managed fields.

```bash
helm version
kubectl get deployments --all-namespaces --output wide
kubectl get crd rayclusters.ray.io \
  --show-managed-fields \
  --output json > rayclusters-crd-managed-fields.json
```

[Open an Azure support request](https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade/overview) to plan recovery. Helm 4 can report a server-side apply conflict with `extensionmanager` for `.spec.versions`. Helm 3 can reinstall the older operator. This action doesn't restore the original CRD schemas.

## Extension succeeds but the operator or CRDs aren't ready

**Symptom:** The Azure extension reports `Succeeded`, but one or more of these conditions apply:

- The operator deployment is unavailable.
- The operator pod isn't ready.
- One or more Ray APIs aren't established.

**Cause:** Resource limits, scheduling constraints, or incorrect configuration can prevent pod readiness. For these causes, see [resource readiness troubleshooting](cluster-extension-deployment-errors#error-timed-out-waiting-for-resource-readiness).

Other possible causes include:

- An operator image pull failure.
- A crash or out-of-memory restart.
- Kubernetes API or role-based access control (RBAC) errors.
- An incomplete CRD update.

**Resolution:**

1. Wait for the operator deployment:

    ```bash
    kubectl wait \
      --for=condition=Available \
      deployment/kuberay-operator \
      --namespace kuberay-system \
      --timeout=5m
    ```
2. Wait for all core Ray CRDs to become established:

    ```bash
    kubectl wait \
      --for=condition=Established \
      crd/rayclusters.ray.io \
      crd/raycronjobs.ray.io \
      crd/rayjobs.ray.io \
      crd/rayservices.ray.io \
      --timeout=2m
    ```
3. If either command times out, use Diagnose the extension to identify the first failure. Examine the deployment description, events, and current or previous logs.
4. If the expected deployment or release configuration is missing or changed, follow Helm drift recovery. Don't wait for pod restarts to repair it.
5. Don't create or update Ray workloads until the operator is available and all required CRDs are established.

Existing Ray pods can continue to run while the operator is unavailable. However, reconciliation, healing, scaling, and `RayJob` state transitions pause.

## Update does not reach the requested version

**Symptom:** The update command finishes or times out. However, `currentVersion` does not change as expected, or the extension enters `Failed`.

**Cause:** Possible causes include:

- A compatible update is unavailable for the cluster and release train.
- The extension agents cannot complete the Helm operation.
- Another extension operation is still in progress.

Important

Do not downgrade or roll back the extension version. Preview supports only safe-forward upgrades and recovery. Do not uninstall the extension to reinstall an older package.

Do not use `helm rollback` or replace the operator manually. Do not infer a supported rollback procedure from platform metadata.

**Resolution:**

1. Examine `currentVersion`, `provisioningState`, `extensionState`, `errorInfo`, and `statuses` as shown in Diagnose the extension. A healthy previous version does not prove that the requested update completed.
2. Repeat cluster-specific version discovery.
3. Make sure that discovery returns a compatible package for the cluster and release train.
4. If another Helm operation is in progress, see [Helm operation conflicts](cluster-extension-deployment-errors#error-operation-is-already-in-progress-for-helm). Do not start another update while an operation is active or its result is unknown.
5. Correct the cause of the failure before a retry.
6. Enable automatic upgrades with `--auto-upgrade-minor-version true`.
7. Omit `--version` from the update command.
8. Retry the forward update with automatic upgrades enabled. Do not select an older package to avoid a failure.
9. After the extension reports a healthy state, verify `currentVersion`, the operator deployment, image, CRDs, and logs.
10. If forward recovery fails or the next safe action is unclear, collect diagnostics for Azure support.
11. For either condition, request Azure support before further changes.

Do not upgrade the underlying Helm release or operator deployment manually. The managed extension owns these resources.

## Helm release or operator configuration drifts after installation

**Symptom:** The Azure extension still reports an earlier successful operation. However, the operator deployment, Helm release, or expected cluster configuration is missing or changed.

**Cause:** Kubernetes can restart operator containers and replace lost pods for an existing deployment. It can't reconstruct a deleted deployment or restore Helm release values from pod state.

The extension doesn't guarantee automatic periodic Helm drift repair. Automatic version upgrades and Kubernetes pod recovery don't provide the same recovery as release or configuration reconciliation.

**Resolution:**

1. Before further changes, follow Collect diagnostics and get support. Include the extension status, deployment, pods, CRDs, events, and logs.
2. Use an explicit Azure Resource Manager (ARM) extension update, such as a supported [`az k8s-extension update` operation](/en-us/azure/aks/kuberay-overview#update-the-managed-kuberay-extension). Alternatively, request platform recovery through Azure support.
3. Follow the safe-forward-only instructions.
4. Don't restore the previous configuration through a downgrade, Helm rollback, or manual operator replacement.
5. After the action, examine the extension operation result, operator deployment and pod readiness, and required CRDs. An earlier `Succeeded` status, an ARM read, or a pod restart doesn't prove that drift recovery succeeded.
6. If the update fails to restore the expected state, stop retries.
7. If the supported update target is unclear, stop retries.
8. In either case, request Azure support with the collected diagnostics.
9. Don't wait for periodic extension Helm repair or repeatedly restart pods instead.

## Extension deletion appears incomplete

**Symptom:** The Azure extension resource is gone, but the operator remains in the cluster. Alternatively, the operator is gone while Ray CRDs and resources remain.

**Cause:** These results have different causes:

- If cluster extension agents can't reach Azure, removal from the cluster can remain incomplete. An absent Azure resource doesn't prove that Helm release removal completed.
- The extension removes the operator and release resources. It retains Ray CRDs and user-created Ray resources. These remaining Ray APIs and workloads are expected after successful removal.

**Resolution:**

1. Determine whether the extension still appears on the cluster:

    ```bash
    az k8s-extension list \
      --resource-group "$RESOURCE_GROUP" \
      --cluster-name "$CLUSTER_NAME" \
      --cluster-type managedClusters \
      --output table
    ```
2. Examine the state in the cluster:

    ```bash
    kubectl get deployment,pods --namespace kuberay-system --output wide
    kubectl get rayclusters,raycronjobs,rayjobs,rayservices --all-namespaces
    ```
3. If the extension resource is gone but the operator remains, examine the cluster extension agents' connectivity.
4. Before manual changes to extension-owned resources, collect events.
5. If the operator is gone and the Ray CRDs remain, don't delete the CRDs for cleanup. A compatible operator must be available before reconciliation of existing Ray resources can continue.
6. For managed-extension recovery, follow the safe-forward instructions. An absent extension doesn't make an older package or CRD schema a supported recovery target.

## Retry timing follows upstream defaults

**Symptom:** Controller reconciliation retries or container restart attempts have delays. Alternatively, multiple affected resources retry at similar times.

**Cause:** KubeRay/controller-runtime reconciliation retries use the upstream timing defaults for the component version. Kubelet restart backoff also uses the upstream defaults for its version. Some paths do not add jitter. Do not assume that all retries have random timing.

AKS does not add custom retry, backoff, or jitter behavior to these paths.

**Resolution:**

1. Use operator logs, pod restart counts, Kubernetes events, and timestamps to identify the component that retries.
2. Do not assume one retry interval or recovery deadline for both the controller and kubelet.
3. Correct the scheduling, image, API, or runtime failure.
4. Do not repeatedly restart pods to reset retry timing.
5. With Helm release or configuration drift, use the explicit ARM update or platform/support recovery path. Upstream retries do not guarantee periodic Helm repair.
6. If the operator remains unhealthy after you correct the failure, collect diagnostics for Azure support.
7. In that case, request Azure support with the diagnostics.
8. Do not patch the managed operator to introduce an unsupported retry policy.
9. Do not rely on an AKS-specific jitter or backoff guarantee.

## Collect diagnostics and get support

If the problem continues, collect diagnostics before making another change. Collect diagnostics before you retry, delete the extension, restart pods, or change Helm ownership.

- Extension and cluster state

```bash
az k8s-extension show \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --cluster-type managedClusters \
  --name "$EXTENSION_NAME" \
  --query "{requestedVersion:version,currentVersion:currentVersion,releaseTrain:releaseTrain,autoUpgradeMinorVersion:autoUpgradeMinorVersion,provisioningState:provisioningState,extensionState:extensionState,errorInfo:errorInfo,statuses:statuses}" \
  --output json > kuberay-extension-status.json

az aks show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CLUSTER_NAME" \
  --query "{id:id,location:location,kubernetesVersion:currentKubernetesVersion,provisioningState:provisioningState}" \
  --output json > aks-cluster.json
```

- Operator, CRD, and workload state

```bash
kubectl get deployment,pods --namespace kuberay-system --output yaml > kuberay-operator-resources.yaml
kubectl describe deployment kuberay-operator --namespace kuberay-system > kuberay-operator-deployment.txt
kubectl get events --namespace kuberay-system --sort-by=.lastTimestamp > kuberay-events.txt
kubectl logs \
  --namespace kuberay-system \
  --selector app.kubernetes.io/name=kuberay-operator \
  --all-containers=true \
  --prefix \
  --tail=2000 > kuberay-operator-logs.txt
kubectl get crd \
  rayclusters.ray.io \
  raycronjobs.ray.io \
  rayjobs.ray.io \
  rayservices.ray.io \
  --output yaml > kuberay-crds.yaml
kubectl get rayclusters,raycronjobs,rayjobs,rayservices \
  --all-namespaces \
  --output wide > kuberay-workloads.txt
```

Include the following information in the support request:

- The cluster resource ID, region, Kubernetes version, and extension release train.
- The requested and current extension versions, and the `autoUpgradeMinorVersion` setting.
- The failed command, complete error code and message, and the approximate start time, duration, and time zone.
- The number of customer-initiated attempts, changes between attempts, and command timeouts.
- Whether a self-hosted KubeRay operator was present, how it was installed, and the Helm version.
- The collected extension status, operator events and logs, CRD state, and affected Ray resource names.

Don't include secrets, credentials, tokens, or private workload data in diagnostic files. For an active managed-extension lifecycle or operator deployment problem, [create an Azure support request](https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade/overview).