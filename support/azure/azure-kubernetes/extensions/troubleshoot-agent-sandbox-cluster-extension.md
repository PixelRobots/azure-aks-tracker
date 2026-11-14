---
layout: Conceptual
title: Troubleshoot Agent Sandbox cluster extension errors in AKS - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/troubleshoot-agent-sandbox-cluster-extension
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
description: Learn how to troubleshoot Agent Sandbox extension errors in AKS, including installation, controller, warm pool, claim, and restore failures. Resolve issues now.
ms.reviewer: wangamanda
ms.date: 2026-11-13T00:00:00.0000000Z
ms.service: azure-kubernetes-service
ms.custom: sap:Extensions, Policies and Add-Ons
ai-usage: ai-assisted
locale: en-us
document_id: 8ee6b059-7570-0782-51d6-534913e66178
document_version_independent_id: 8ee6b059-7570-0782-51d6-534913e66178
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/troubleshoot-agent-sandbox-cluster-extension.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/troubleshoot-agent-sandbox-cluster-extension
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/troubleshoot-agent-sandbox-cluster-extension.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 47e3728b-090b-3cf7-0115-6cfda5972c69
---

# Troubleshoot Agent Sandbox cluster extension errors in AKS - Azure | Microsoft Learn

## Summary

This article helps you troubleshoot Agent Sandbox cluster extension errors (`Microsoft.AgentSandbox`) in Azure Kubernetes Service (AKS) and restore healthy sandbox workloads. It covers installation, controller, API, readiness, suspend and resume, warm pool, claim, restore, and deletion issues.

Important

Use this article for an installation managed through the AKS cluster extension, not a self-managed Helm installation.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

The extension manages its controller, Kubernetes permissions, configuration, and the `agent-sandbox-system` namespace. Don't repair an extension-managed installation by running direct Helm upgrades, granting extra permissions to the controller, editing its ConfigMap, patching custom resource definitions (CRDs), or removing finalizers.

Agent Sandbox doesn't install a container runtime, RuntimeClass, node pool, storage driver, Pod snapshot cluster extension, autoscaler, or monitoring operator. A successful extension installation doesn't verify that these dependencies are available for your workloads.

## Error 1: Extension installation fails or the controller is missing

### Symptoms

- The extension provisioning state isn't `Succeeded`.
- The extension reports success, but the `agent-sandbox-system` namespace or `agent-sandbox-controller` deployment is missing.
- Sandbox resources don't progress after an extension installation or update.

### Cause

Extension registration, package retrieval, policy restrictions, or extension reconciliation can prevent installation from completing. A namespace or CRD left over from an earlier installation doesn't prove that the extension is currently installed.

### Solution

1. Find the installed extension name. Don't assume that its instance name matches its extension type:

    ```bash
    az k8s-extension list \
      --resource-group "$RESOURCE_GROUP" \
      --cluster-name "$CLUSTER_NAME" \
      --cluster-type managedClusters \
      --query "[?extensionType=='Microsoft.AgentSandbox' || extensionType=='microsoft.agentsandbox'].{name:name,type:extensionType,state:provisioningState}" \
      --output table
    ```
2. If an entry exists, set `EXTENSION_NAME` to the returned name and inspect a filtered view of its status:

    ```bash
    EXTENSION_NAME="<installed-extension-name>"
    
    az k8s-extension show \
      --resource-group "$RESOURCE_GROUP" \
      --cluster-name "$CLUSTER_NAME" \
      --cluster-type managedClusters \
      --name "$EXTENSION_NAME" \
      --query '{name:name,extensionType:extensionType,provisioningState:provisioningState,currentVersion:currentVersion,releaseTrain:releaseTrain,extensionState:extensionState,errorInfo:errorInfo,statuses:statuses}' \
      --output json
    ```

    Preserve the error, operation or correlation ID, and time of the failure before retrying. Don't share unfiltered `az k8s-extension show` output because it can contain protected configuration settings.
3. The Agent Sandbox cluster extension is a standard extension. For package, Helm, or extension deployment errors, follow the **Standard extension or Kubernetes application: Helm-based deployment** guidance in [Troubleshoot errors when deploying AKS cluster extensions](cluster-extension-deployment-errors#identifying-the-extension-category).
4. Check the in-cluster resources:

    ```bash
    kubectl get namespace agent-sandbox-system
    kubectl get deployment agent-sandbox-controller \
      --namespace agent-sandbox-system
    ```
5. If no extension entry exists, confirm that Agent Sandbox was installed on the intended cluster through the supported cluster extension installation process. Don't create a separate Helm installation to repair it.
6. If Azure reports success but managed resources remain missing, contact Azure support. Don't manually recreate the controller or its permissions.

## Error 2: The Agent Sandbox controller is unavailable or keeps restarting

### Symptoms

- The controller deployment has fewer ready or available replicas than desired.
- Controller pods are `Pending`, `ImagePullBackOff`, or `CrashLoopBackOff`.
- Sandboxes, warm pools, or claims stop progressing.

### Cause

Possible causes include insufficient cluster resources, scheduling restrictions, image pull failures, failed readiness probes, memory exhaustion, or Kubernetes API access errors. Controller readiness alone doesn't prove that Sandbox workloads are ready.

### Solution

1. Inspect the controller deployment, pods, and events:

    ```bash
    kubectl get deployment agent-sandbox-controller \
      --namespace agent-sandbox-system \
      --output wide
    kubectl get pods --namespace agent-sandbox-system --output wide
    kubectl describe deployment agent-sandbox-controller \
      --namespace agent-sandbox-system
    kubectl get events --namespace agent-sandbox-system \
      --sort-by=.metadata.creationTimestamp
    ```
2. Describe an affected controller pod. Check scheduling events, container waiting messages, termination reasons, and restart counts:

    ```bash
    CONTROLLER_POD="<controller-pod-name>"
    
    kubectl describe pod "$CONTROLLER_POD" \
      --namespace agent-sandbox-system
    kubectl logs "$CONTROLLER_POD" \
      --namespace agent-sandbox-system \
      --all-containers=true \
      --timestamps \
      --since=30m
    ```

    If a container restarted, also collect its previous logs. Set `CONTROLLER_CONTAINER` to that container's name:

    ```bash
    CONTROLLER_CONTAINER="<restarted-container-name>"
    
    kubectl logs "$CONTROLLER_POD" \
      --namespace agent-sandbox-system \
      --container "$CONTROLLER_CONTAINER" \
      --previous \
      --timestamps \
      --tail=1000
    ```
3. Resolve the specific cluster dependency identified by events, such as insufficient node capacity or blocked access to the image registry. Preserve the exact image reference and error for image pull failures.
4. For `OOMKilled`, throttling, or delayed reconciliation, record the controller's resource requests and limits. If resource metrics are available, collect current usage:

    ```bash
    kubectl top pod --namespace agent-sandbox-system --containers
    ```

    An unavailable metrics API doesn't establish whether the controller is healthy. Use pod status, events, and logs for the other checks.
5. If controller logs report forbidden operations or managed configuration errors, contact Azure support. Don't grant `cluster-admin`, edit managed Kubernetes roles, or patch the managed deployment as a workaround.
6. After resolving the reported failure, verify that controller replicas are ready and that the affected Sandbox, pool, or claim progresses.

## Error 3: Kubernetes doesn't recognize an Agent Sandbox resource

### Symptoms

`kubectl` reports that the server doesn't have the requested resource type, or it returns a `no matches for kind` error for a Sandbox, SandboxTemplate, SandboxWarmPool, or SandboxClaim.

### Cause

The required CRD might be missing, not established, or incompatible with the resource manifest. A failed or incomplete extension installation can also prevent API discovery.

### Solution

1. Check all four CRDs:

    ```bash
    kubectl get crd \
      sandboxes.agents.x-k8s.io \
      sandboxtemplates.extensions.agents.x-k8s.io \
      sandboxwarmpools.extensions.agents.x-k8s.io \
      sandboxclaims.extensions.agents.x-k8s.io \
      --output custom-columns='NAME:.metadata.name,ESTABLISHED:.status.conditions[?(@.type=="Established")].status,SERVED:.spec.versions[?(@.served==true)].name,STORAGE:.spec.versions[?(@.storage==true)].name,STORED:.status.storedVersions,CONVERSION:.spec.conversion.strategy'
    
    kubectl api-resources --api-group=agents.x-k8s.io
    kubectl api-resources --api-group=extensions.agents.x-k8s.io
    ```
2. Verify that all four CRDs report `Established=True`. The current extension uses `v1beta1` as the served and storage version. The stored versions should contain only `v1beta1`, and conversion should be unset or `None`.
3. If the APIs are healthy, verify that the manifest uses `agents.x-k8s.io/v1beta1` for Sandbox or `extensions.agents.x-k8s.io/v1beta1` for SandboxTemplate, SandboxWarmPool, and SandboxClaim.
4. If a CRD is missing or incompatible, check the extension status and contact Azure support. Preserve the CRD metadata and error. Don't change stored versions, remove conversion settings, or delete and recreate CRDs.

## Error 4: A Sandbox has no pod or doesn't become ready

### Symptoms

- A Sandbox reports `Ready=False`.
- Sandbox status is absent or doesn't reflect the latest resource generation.
- The Sandbox has no backing pod.
- A generated pod remains pending or fails to start.

### Cause

The controller might not have reconciled the Sandbox, or pod creation might be blocked by scheduling, admission, image, runtime, storage, or network dependencies. A suspended Sandbox is expected to have no backing pod.

### Solution

1. Inspect the affected Sandbox:

    ```bash
    SANDBOX_NAME="<sandbox-name>"
    
    kubectl describe sandbox "$SANDBOX_NAME" \
      --namespace "$WORKLOAD_NAMESPACE"
    kubectl get sandbox "$SANDBOX_NAME" \
      --namespace "$WORKLOAD_NAMESPACE" \
      --output jsonpath='generation={.metadata.generation}{"\n"}observedGeneration={.status.observedGeneration}{"\n"}mode={.spec.operatingMode}{"\n"}selector={.status.selector}{"\n"}conditions={.status.conditions}{"\n"}'
    ```

    Use condition reasons and messages to identify the failure. If observed generation is present, compare it with the current generation.
2. Find the backing pod by using the selector published in Sandbox status:

    ```bash
    SELECTOR="$(kubectl get sandbox "$SANDBOX_NAME" \
      --namespace "$WORKLOAD_NAMESPACE" \
      --output jsonpath='{.status.selector}')"
    
    if [ -n "$SELECTOR" ]; then
      kubectl get pods --namespace "$WORKLOAD_NAMESPACE" \
        --selector "$SELECTOR" --output wide
      kubectl describe pods --namespace "$WORKLOAD_NAMESPACE" \
        --selector "$SELECTOR"
    else
      printf '%s\n' "The Sandbox hasn't published a backing-resource selector. Inspect its conditions and controller logs."
    fi
    ```
3. Inspect namespace events and related resources:

    ```bash
    kubectl get events --namespace "$WORKLOAD_NAMESPACE" \
      --sort-by=.metadata.creationTimestamp
    kubectl get service,pvc,networkpolicy \
      --namespace "$WORKLOAD_NAMESPACE" --show-labels
    ```
4. Follow the evidence:

    | Observation | Action |
    | --- | --- |
    | Status is absent or isn't progressing | Check controller availability and logs for the affected namespace and resource name. |
    | The Sandbox is suspended | Use the suspend and resume checks. |
    | A selector exists, but no pod exists | Check events for pod admission errors or incomplete deletion of the previous pod. |
    | Pod is `Pending` | Check capacity, quotas, taints, affinity, RuntimeClass, and pending PVCs. |
    | Pod has `ErrImagePull` or `ImagePullBackOff` | Check the image reference, registry authorization, connectivity, architecture, and image manifest. |
    | PVC is pending or a mount fails | Check the StorageClass, storage driver, volume topology, quotas, and volume health. |
    | A Service has no ready endpoints | Check pod readiness, the Service selector, and applicable network policies. |
5. Verify that the Sandbox and its backing pod become ready after the dependency is corrected.

## Error 5: A requested runtime or admission policy prevents pod startup

### Symptoms

- A Sandbox pod remains pending or enters `CreateContainerError`.
- Events report a missing RuntimeClass or incompatible nodes.
- Pod creation is denied by a policy or admission webhook.
- A Kata workload reports errors such as `failed to extract layer ... to erofs` or `content digest sha256:... not found`.
- A Sandbox reaches `Ready=True` without the expected VM isolation boundary.

### Cause

Agent Sandbox uses the runtime requested by the Sandbox pod template, or the cluster default runtime when `runtimeClassName` is empty. It doesn't install or repair that runtime.

A Sandbox without `runtimeClassName` can be accepted and become ready as an ordinary container pod. `Ready=True` doesn't confirm a VM isolation boundary for untrusted agent code.

A policy or webhook can reject a generated pod even when the Agent Sandbox controller is healthy. Kata image preparation failures can also occur independently of Agent Sandbox or snapshot restore.

### Solution

1. Inspect the affected pod, RuntimeClass, and node information:

    ```bash
    BACKING_POD="<backing-pod-name>"
    
    kubectl describe pod "$BACKING_POD" --namespace "$WORKLOAD_NAMESPACE"
    kubectl get pod "$BACKING_POD" --namespace "$WORKLOAD_NAMESPACE" \
      --output jsonpath='{.spec.runtimeClassName}{"\n"}'
    kubectl get runtimeclass
    kubectl get nodes --output wide
    ```
2. Check the returned `runtimeClassName`. An empty result means that the pod uses the cluster default runtime, not an explicitly requested VM-isolated runtime. If the workload requires VM isolation, set `spec.podTemplate.spec.runtimeClassName` to the supported VM-isolated RuntimeClass through your normal workload management process. Verify the resulting backing pod before running untrusted agent code.
3. If a RuntimeClass is specified, verify that it exists and that compatible nodes are ready. Check the runtime handler, node labels, taints, and pod scheduling constraints. Confirm that the handler provides the required isolation boundary; a nonempty RuntimeClass name alone doesn't establish VM isolation. Don't switch runtimes just to bypass the error.
4. If admission rejects the pod, identify the policy or webhook named in the error. Work with your cluster administrator to make the workload compliant or approve an appropriately scoped policy change. An audit warning alone isn't proof of a denial. Don't delete or disable a webhook as a troubleshooting shortcut.
5. For image preparation failures, preserve the immutable image digest, requested RuntimeClass, runtime handler, node name, AKS node image and container runtime versions, and complete pod events. A successful image pull on the default runtime doesn't verify image preparation for Kata.
6. Contact Azure support if a managed runtime error persists. Don't modify the managed container content store, restart `containerd`, or change the managed node filesystem as a repair.

## Error 6: Updating a Sandbox returns "volumeClaimTemplates is immutable"

### Symptoms

An update to an existing Sandbox is rejected with a message that includes `volumeClaimTemplates is immutable`.

### Cause

The API doesn't allow changes to the existing Sandbox's volume claim templates. This validation error isn't a controller availability failure.

### Solution

Create a replacement Sandbox with the required volume claim templates. Plan and perform any application data migration explicitly before retiring the original Sandbox. Check volume retention and reclaim policies before deleting resources. Don't delete PVCs or modify CRDs to bypass validation.

## Error 7: Suspension or resumption doesn't complete

### Symptoms

- A Sandbox still has a backing pod after suspension.
- Resuming a Sandbox doesn't create a new pod.
- An application loses in-memory state after resuming.

### Cause

Pod deletion or a dependency might be blocking the transition. Resumption creates a new pod with a new UID. Without the Pod snapshot cluster extension, resumption is a cold start: process memory and ephemeral filesystem state aren't preserved.

### Solution

1. Inspect `spec.operatingMode`, the `Suspended` and `Ready` conditions, and the backing pod by using the Sandbox readiness checks.
2. For a completed suspension, expect `spec.operatingMode: Suspended`, `Suspended=True`, `Ready=False`, and no backing pod.
3. If the pod remains, inspect its deletion timestamp, finalizers, events, and volume detach errors. Check the controller logs. Resolve the blocking dependency rather than removing finalizers.
4. Before resuming, confirm that the previous pod is fully deleted. Set `spec.operatingMode` to `Running` through your normal workload management process, and verify that a new pod becomes ready.
5. Review `spec.shutdownPolicy` and `spec.shutdownTime` if Sandbox retention or deletion differs from your expectations.

An existing PVC or requested Service can remain associated with the logical Sandbox, subject to storage and reclaim policies. Their presence doesn't imply that process memory was preserved.

## Error 8: A warm pool has fewer ready Sandboxes than expected

### Symptoms

- A SandboxWarmPool has fewer ready members than requested.
- Newly created pool members don't become ready.
- A template update doesn't replace existing members.

### Cause

Member creation might be delayed, member pods might be failing, or the pool configuration might not match your expectations. A SandboxTemplate has no status subresource, so API acceptance alone doesn't prove that its generated workloads can run.

A pool with `spec.replicas: 0` intentionally provides no ready capacity. When a claim receives a Sandbox, that Sandbox leaves the pool's ready supply and the pool creates a replacement.

### Solution

1. Inspect the pool and its referenced template:

    ```bash
    POOL_NAME="<warm-pool-name>"
    TEMPLATE_NAME="<referenced-template-name>"
    
    kubectl get sandboxwarmpool "$POOL_NAME" \
      --namespace "$WORKLOAD_NAMESPACE" --output yaml
    kubectl get sandboxtemplate "$TEMPLATE_NAME" \
      --namespace "$WORKLOAD_NAMESPACE" --output yaml
    ```
2. Confirm that `spec.sandboxTemplateRef.name` identifies a template that exists in the same namespace. Check the template's image, runtime, resource requests, scheduling, storage, and network policy configuration.
3. Compare `spec.replicas`, `status.replicas`, and `status.readyReplicas`:

    - Desired replicas exceed current replicas: Check member creation events and controller reconciliation.
    - Current replicas exceed ready replicas: Inspect each member Sandbox and its backing pod.
    - The pool selector remains empty: Check controller logs and whether pool status is progressing.

    Warm pools don't publish a condition list. Use their counts, selector, and member resource status.
4. Use the pool's `status.selector` to identify its members. Check that the selector is nonempty before using it:

    ```bash
    POOL_SELECTOR="$(kubectl get sandboxwarmpool "$POOL_NAME" \
      --namespace "$WORKLOAD_NAMESPACE" \
      --output jsonpath='{.status.selector}')"
    
    if [ -n "$POOL_SELECTOR" ]; then
      kubectl get sandboxes --namespace "$WORKLOAD_NAMESPACE" \
        --selector "$POOL_SELECTOR" --output wide
    else
      printf '%s\n' "The warm pool hasn't published a member selector. Inspect controller logs and pool status."
    fi
    ```
5. Check the pool's update strategy. `OnReplenish` applies template changes to new or replacement members. `Recreate` replaces existing members. Don't change the strategy without considering disruption to existing workloads.
6. If a separately installed autoscaler manages the pool, coordinate with that autoscaler instead of making competing manual replica changes. The extension doesn't install an autoscaler.

## Error 9: A SandboxClaim isn't ready or has no assigned Sandbox

### Symptoms

- A SandboxClaim doesn't report `Ready=True`.
- `status.sandbox.name` is empty.
- The system doesn't apply claim-provided environment values, storage settings, or metadata as expected.

### Cause

The referenced warm pool might be missing, have no ready unclaimed members, or contain unready workloads. Template policies can reject claim-provided customizations. Claim metadata is also filtered through the extension's managed configuration.

### Solution

1. Inspect the claim and identify the referenced pool and assigned Sandbox:

    ```bash
    CLAIM_NAME="<claim-name>"
    
    kubectl describe sandboxclaim "$CLAIM_NAME" \
      --namespace "$WORKLOAD_NAMESPACE"
    kubectl get sandboxclaim "$CLAIM_NAME" \
      --namespace "$WORKLOAD_NAMESPACE" \
      --output jsonpath='pool={.spec.warmPoolRef.name}{"\n"}sandbox={.status.sandbox.name}{"\n"}conditions={.status.conditions}{"\n"}'
    ```
2. Verify that the referenced pool exists in the same namespace and has ready capacity. Use the warm pool checks.
3. If `status.sandbox.name` is populated, inspect that exact Sandbox and its backing pod. Pool replenishment doesn't mean that an already assigned claim is unbound.
4. Check the template's `envVarsInjectionPolicy` and `volumeClaimTemplatesPolicy`. Correct the claim to comply with the template policy, or have the template owner approve the intended customization.
5. For missing metadata, compare the claim's `additionalPodMetadata` with the generated Sandbox and pod metadata. If expected propagation fails, collect controller logs and contact support. Don't broaden the extension-managed ConfigMap as a workaround.
6. For unexpected retention or teardown, review the claim's `spec.lifecycle.shutdownPolicy`, `shutdownTime`, and `ttlSecondsAfterFinished`.
7. After correcting the cause, verify `Ready=True`, an assigned Sandbox name, and a ready backing workload.

## Error 10: A Sandbox restore is denied, doesn't progress, or uses the wrong snapshot

### Symptoms

- A restore-enabled Sandbox doesn't create a ready pod.
- Admission reports that no matching ready PodSnapshot exists or that the referenced snapshot isn't ready.
- Admission reports that the controller isn't authorized to restore.
- A restore selection change is rejected with `suspend Sandbox before enabling or changing a restore selection`.

### Cause

The Pod snapshot cluster extension is a separate, optional extension. Ordinary Sandbox creation, suspension, templates, pools, and claims don't require it.

When you use the Agent Sandbox cluster extension and Pod snapshot cluster extension together, you can suspend and resume the same Sandbox. This preview doesn't support restoring a single snapshot to multiple independent Sandboxes, including those in a snapshot-backed warm pool.

When restore is enabled, snapshot readiness, namespace, selection, and restore permissions must all be valid. The manager component of the Pod snapshot cluster extension detects the Sandbox API even if Agent Sandbox is installed later; a restart isn't required. Existing restore selection can't be changed while the backing pod exists.

### Solution

1. Confirm that the Pod snapshot cluster extension is installed and healthy. Check that the Sandbox CRD is established.
2. Inspect logs from the manager component of the Pod snapshot cluster extension for integration and admission errors:

    ```bash
    kubectl logs deployment/pod-snapshot-manager \
      --namespace pod-snapshot-system \
      --all-containers=true \
      --timestamps \
      --since=30m
    ```

    Look for `SandboxRestoreReconciler enabled` in the manager logs. If the Sandbox API wasn't available at startup, the manager retries discovery every ten seconds. If discovery errors persist after the CRD is established, collect the logs and contact support. Don't patch its managed deployment.
3. Verify restore intent in the Sandbox's `spec.podTemplate`. For explicit selection, use a ready snapshot in the same namespace:

    ```yaml
    spec:
      podTemplate:
        metadata:
          labels:
            podsnapshot.aks.azure.com/restore: "true"
          annotations:
            podsnapshot.aks.azure.com/restore-from: <pod-snapshot-name>
    ```

    This example is a manifest fragment. Don't apply it to an active Sandbox to change its restore selection. Use the suspend and reselect sequence later in this section.
4. Inspect the selected snapshot and workload events:

    ```bash
    SNAPSHOT_NAME="<pod-snapshot-name>"
    
    kubectl get podsnapshot "$SNAPSHOT_NAME" \
      --namespace "$WORKLOAD_NAMESPACE" --output yaml
    kubectl get events --namespace "$WORKLOAD_NAMESPACE" \
      --sort-by=.metadata.creationTimestamp
    ```

    Verify that the snapshot reports `Ready=True`. For implicit Kata restore, when no `restore-from` annotation is specified, selection requires a ready same-namespace snapshot with matching container names, images, commands, and arguments. Init-container order and restart policy must also match. Resource requests and limits aren't part of selection, but must be sufficient to run the restored workload.
5. If admission reports an authorization failure, have the cluster administrator verify the intended restore authorization for `system:serviceaccount:agent-sandbox-system:agent-sandbox-controller`. If the administrator has impersonation permission, they can check access to the affected snapshot:

    ```bash
    kubectl auth can-i restore \
      "podsnapshots.podsnapshot.aks.azure.com/$SNAPSHOT_NAME" \
      --namespace "$WORKLOAD_NAMESPACE" \
      --as=system:serviceaccount:agent-sandbox-system:agent-sandbox-controller
    ```

    An impersonation permission error doesn't establish whether restore access is granted. The Pod snapshot cluster extension doesn't create a restore binding by default. Use its supported authorization configuration rather than granting `cluster-admin`.

    The Agent Sandbox controller is shared across namespaces. Authorizing it delegates restore capability to workloads that can cause it to create restore pods. Review Sandbox write permissions and snapshot isolation before granting access. Propagating the `podsnapshot.aks.azure.com` label domain doesn't grant restore permission.
6. To change or reselect a snapshot safely, use your normal manifest management process to perform these steps in order:

    1. Set `spec.operatingMode` to `Suspended` without changing the existing restore label or annotation.
    2. Wait for `Suspended=True` and for the backing pod to be deleted.
    3. To clear an implicit selection, remove the restore opt-in label and wait for the Pod snapshot cluster extension to remove `restore-from`.
    4. While still suspended, update the pod template. Set `restore=true` and an explicit `restore-from`, or omit `restore-from` for implicit selection.
    5. Wait for the Pod snapshot cluster extension to select the intended snapshot before resuming.
    6. Set `spec.operatingMode` to `Running`.

    Don't set generated snapshot provenance or runtime restore annotations manually.
7. Verify that both the Sandbox and its pod become ready and that restore events include `AKSPodRestored`. Also verify application-level state continuity. Pod readiness alone doesn't prove that the expected in-memory state was restored.

If admission explicitly requires a named snapshot, provide a valid explicit reference instead of relying on implicit selection. For persistent snapshot preparation, scheduling gate, or restore errors, collect logs from the manager component of the Pod snapshot cluster extension and contact Azure support.

## Error 11: Resource deletion or extension removal is stuck

### Symptoms

- A Sandbox, SandboxClaim, or SandboxWarmPool remains in a terminating state.
- Extension removal doesn't complete.
- CRDs or an empty system namespace remain after extension removal.

### Cause

The owning controller or a dependent pod, volume, Service, or network policy might not have completed cleanup. Removing the controller before custom resources finish finalizing can leave deletion blocked.

CRDs and the empty `agent-sandbox-system` namespace can remain after extension removal. Their presence alone doesn't prove that the extension is still installed.

### Solution

1. Before removing the extension, inventory customer resources across namespaces:

    ```bash
    kubectl get \
      sandboxes.agents.x-k8s.io,sandboxtemplates.extensions.agents.x-k8s.io,sandboxwarmpools.extensions.agents.x-k8s.io,sandboxclaims.extensions.agents.x-k8s.io \
      --all-namespaces
    ```
2. Plan workload cleanup and data retention before deleting resources. Don't remove the extension's controller while resources still require it to finalize.
3. For a stuck resource, record its deletion timestamp, finalizers, owner references, status, and events. Check the controller's readiness and logs for that resource name and namespace.
4. Identify and resolve the blocking dependency. Let its owning controller complete normal cleanup. Don't remove finalizers, delete CRDs while custom resources remain, or delete PVCs as a generic recovery step.
5. If the controller was already removed, contact Azure support for help restoring it through the same AKS extension management path with a package compatible with the retained CRDs. Don't create a second manual Helm release.
6. For restored workloads, delete the restored Sandbox and wait for its backing pod to be removed before expecting snapshot finalizers to release associated artifacts.
7. Verify removal by checking the Azure extension resource, not just the presence or absence of the namespace.

## Collect diagnostics and contact support

If the issue persists, [create an Azure support request](/en-us/azure/azure-portal/supportability/how-to-create-azure-support-request).

Provide the smallest relevant, sanitized evidence set:

- The cluster resource ID, region, installed extension name and version, and failure time range in UTC.
- Filtered extension status, error messages, and operation or correlation IDs.
- Controller deployment and pod status, relevant events, and current logs. Include previous container logs only for containers that restarted.
- The affected resource kind, namespace, name, generation, conditions, and owner references.
- The relevant SandboxTemplate, SandboxWarmPool, and SandboxClaim configuration and status.
- Backing pod, Service, PVC, network policy, RuntimeClass, and node information relevant to the failure.
- For restore issues, the selected snapshot's readiness, logs from the manager component of the Pod snapshot cluster extension, and restore events.

Don't include Secrets, access tokens, private keys, kubeconfig files, registry credentials, protected extension settings, or snapshot contents. Review environment values, commands, arguments, labels, annotations, logs, event messages, DNS names, and storage identifiers for sensitive data before sharing. Preserve the timestamps, condition reasons, image digests, runtime details, and correlation data needed to diagnose the failure.