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
description: Troubleshoot managed KubeRay extension errors on AKS. Diagnose installation, update, removal, and readiness failures, and restore Ray workloads. Learn how.
ms.date: 2026-10-29T00:00:00.0000000Z
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

This article helps you troubleshoot managed KubeRay extension errors on Azure Kubernetes Service (AKS). Use it to diagnose extension status, installation, update, removal, and readiness failures so you can restore Ray workload reconciliation during preview.

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

**Cause:** Preview doesn't support the in-place adoption of a self-hosted KubeRay operator on the same cluster. KubeRay requires a single operator per cluster. The managed extension rejects installation if it detects a self-hosted or otherwise unmanaged operator. The failed installation might update or claim the Ray CRDs before the extension detects the existing operator.

**Resolution:** Use this procedure only if both of the following conditions are true:

- The failed managed extension resource still exists.
- A Helm release installed the self-hosted operator.

This procedure keeps the current CRDs and transfers reconciliation to the managed operator. This migration path isn't supported. If you use this procedure, proceed at your own risk. The procedure minimizes workload disruption, but the operator gap still introduces risk.

1. Stop all repeated extension create, update, and delete requests.
2. Stop new Ray control-plane changes.
3. If possible, wait for active `RayJob` resources to finish.

    Existing Ray pods can continue to run during a short operator gap. During the gap, reconciliation, healing, autoscaling, and `RayJob` status transitions stop.
4. Set values for the existing self-hosted operator release:

    ```bash
    OSS_RELEASE_NAME="<oss-kuberay-operator-release>"
    OSS_RELEASE_NAMESPACE="<oss-kuberay-operator-namespace>"
    OSS_OPERATOR_DEPLOYMENT="<oss-kuberay-operator-deployment>"
    OSS_OPERATOR_POD_SELECTOR="$(
      kubectl get deployment "$OSS_OPERATOR_DEPLOYMENT" \
        --namespace "$OSS_RELEASE_NAMESPACE" \
        --output go-template='{{range $key, $value := .spec.selector.matchLabels}}{{$key}}={{$value}},{{end}}' |
      sed 's/,$//'
    )"
    BACKUP_DIR="kuberay-handoff-$(date -u +%Y%m%dT%H%M%SZ)"
    mkdir "$BACKUP_DIR"
    ```
5. Create backups of the extension status, the Helm release, the operator, and the Ray resources:

    ```bash
    az k8s-extension show \
      --resource-group "$RESOURCE_GROUP" \
      --cluster-name "$CLUSTER_NAME" \
      --cluster-type managedClusters \
      --name "$EXTENSION_NAME" \
      --output json > "$BACKUP_DIR/extension-status.json"
    
    helm version > "$BACKUP_DIR/helm-version.txt"
    helm get values "$OSS_RELEASE_NAME" \
      --namespace "$OSS_RELEASE_NAMESPACE" \
      --all > "$BACKUP_DIR/oss-release-values.yaml"
    helm get manifest "$OSS_RELEASE_NAME" \
      --namespace "$OSS_RELEASE_NAMESPACE" > "$BACKUP_DIR/oss-release-manifest.yaml"
    helm get hooks "$OSS_RELEASE_NAME" \
      --namespace "$OSS_RELEASE_NAMESPACE" > "$BACKUP_DIR/oss-release-hooks.yaml"
    
    kubectl get deployment "$OSS_OPERATOR_DEPLOYMENT" \
      --namespace "$OSS_RELEASE_NAMESPACE" \
      --output yaml > "$BACKUP_DIR/oss-operator-deployment.yaml"
    kubectl logs deployment/"$OSS_OPERATOR_DEPLOYMENT" \
      --namespace "$OSS_RELEASE_NAMESPACE" \
      --all-containers=true \
      --prefix \
      --tail=2000 > "$BACKUP_DIR/oss-operator-logs.txt"
    kubectl get rayclusters,raycronjobs,rayjobs,rayservices \
      --all-namespaces \
      --output yaml > "$BACKUP_DIR/ray-resources.yaml"
    kubectl get services \
      --all-namespaces \
      --selector ray.io/cluster \
      --output yaml > "$BACKUP_DIR/ray-workload-services.yaml"
    kubectl get crd \
      rayclusters.ray.io \
      raycronjobs.ray.io \
      rayjobs.ray.io \
      rayservices.ray.io \
      --show-managed-fields \
      --output yaml > "$BACKUP_DIR/ray-crds-managed-fields.yaml"
    ```
6. Record the workload pod unique identifiers (UIDs). This step is optional. Use the UIDs to verify that the same pods remain after the operator change:

    ```bash
    kubectl get pods \
      --all-namespaces \
      --selector ray.io/cluster \
      --sort-by=.metadata.uid \
      --output custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,UID:.metadata.uid' \
      > "$BACKUP_DIR/ray-pods-before.txt"
    ```
7. Keep the current CRDs and existing resources.
8. Don't downgrade or delete a Ray CRD.
9. Don't delete a workload namespace.
10. Don't change labels or managed fields.
11. Don't force resource ownership.
12. Inspect `$BACKUP_DIR/oss-release-manifest.yaml`.
13. Confirm that the manifest doesn't contain a Ray `CustomResourceDefinition` resource.
14. Inspect `$BACKUP_DIR/oss-release-hooks.yaml`.
15. Inspect each script and ConfigMap that the hooks use.
16. Confirm that no uninstall hook deletes a Ray CRD or Ray resource.

    If the release owns a Ray CRD, stop this procedure. If a hook can delete a Ray CRD or Ray resource, stop this procedure. If the hook behavior isn't clear, stop this procedure. Don't continue the migration.
17. Uninstall only the self-hosted operator Helm release.

    ```bash
    helm uninstall "$OSS_RELEASE_NAME" \
      --namespace "$OSS_RELEASE_NAMESPACE" \
      --wait \
      --timeout 5m
    ```

    Don't delete the namespace, Ray CRDs, Ray resources, Ray workload services, or workload pods.
18. Wait for the self-hosted operator pods to be deleted:

    ```bash
    kubectl wait \
      --for=delete \
      pod \
      --selector "$OSS_OPERATOR_POD_SELECTOR" \
      --namespace "$OSS_RELEASE_NAMESPACE" \
      --timeout=5m
    ```

    If the command times out, stop this procedure.
19. Verify the resources after the uninstall:

    ```bash
    kubectl get deployment "$OSS_OPERATOR_DEPLOYMENT" \
      --namespace "$OSS_RELEASE_NAMESPACE"
    kubectl get namespace "$OSS_RELEASE_NAMESPACE" \
      --output custom-columns='NAME:.metadata.name,STATUS:.status.phase'
    kubectl get pods \
      --namespace "$OSS_RELEASE_NAMESPACE" \
      --selector "$OSS_OPERATOR_POD_SELECTOR"
    kubectl wait \
      --for=condition=Established \
      crd/rayclusters.ray.io \
      crd/raycronjobs.ray.io \
      crd/rayjobs.ray.io \
      crd/rayservices.ray.io \
      --timeout=2m
    kubectl get pods \
      --all-namespaces \
      --selector ray.io/cluster \
      --output wide
    kubectl get services \
      --all-namespaces \
      --selector ray.io/cluster \
      --output wide
    ```

    The deployment command should return `NotFound`. The operator pod command should return `No resources found`. The namespace status must be `Active`. Each Ray CRD must be `Established`. Each existing workload pod must be `Running`. The Ray resources and workload services must remain.

    If an expected resource is missing, stop this procedure.
20. Update the existing failed managed extension resource. Don't run a second `create` command. Don't specify a package version.

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
21. Verify the managed extension and operator:

    ```bash
    az k8s-extension show \
      --resource-group "$RESOURCE_GROUP" \
      --cluster-name "$CLUSTER_NAME" \
      --cluster-type managedClusters \
      --name "$EXTENSION_NAME" \
      --query "{provisioningState:provisioningState,extensionState:extensionState,currentVersion:currentVersion,errorInfo:errorInfo}" \
      --output json
    kubectl wait \
      --for=condition=Available \
      deployment/kuberay-operator \
      --namespace kuberay-system \
      --timeout=5m
    kubectl wait \
      --for=condition=Established \
      crd/rayclusters.ray.io \
      crd/raycronjobs.ray.io \
      crd/rayjobs.ray.io \
      crd/rayservices.ray.io \
      --timeout=2m
    kubectl get rayclusters,raycronjobs,rayjobs,rayservices \
      --all-namespaces \
      --output wide
    ```

    Confirm that `provisioningState` is `Succeeded`. Confirm that `extensionState` is `Available` or `Ready`. Confirm that the managed operator deployment is `Available`. Confirm that each Ray CRD is `Established`. Confirm that the existing Ray resources resume reconciliation.
22. If you recorded pod UIDs, record the UIDs again:

    ```bash
    kubectl get pods \
      --all-namespaces \
      --selector ray.io/cluster \
      --sort-by=.metadata.uid \
      --output custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,UID:.metadata.uid' \
      > "$BACKUP_DIR/ray-pods-after.txt"
    diff -u "$BACKUP_DIR/ray-pods-before.txt" "$BACKUP_DIR/ray-pods-after.txt"
    ```

    Confirm that the workload pod UIDs didn't change.

Warning

If the managed update fails after you remove the open-source operator, stop all changes. Existing Ray pods might continue to run. However, no operator reconciles the Ray resources. Don't reinstall the self-hosted operator with Helm 4. Don't downgrade the Ray CRDs. Don't force resource ownership. Don't delete the failed extension. Keep the collected diagnostics.

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

## Update doesn't reach the requested extension version

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