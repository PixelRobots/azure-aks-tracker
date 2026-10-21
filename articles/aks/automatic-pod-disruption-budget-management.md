---
layout: Conceptual
title: Automatic Pod Disruption Budget management in AKS (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/automatic-pod-disruption-budget-management
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
description: Learn how to use automatic Pod Disruption Budget management (preview) to manage Pod Disruption Budgets and unblock node drain operations in AKS clusters.
ms.topic: how-to
ms.subservice: aks-upgrade
ms.date: 2026-03-16T00:00:00.0000000Z
author: kaarthis
ms.author: kaarthis
ai-usage: ai-assisted
locale: en-us
document_id: db2fd20c-56e8-6ca7-93ff-cb82bef662df
document_version_independent_id: 50e8f832-7a46-2df4-1799-124f61c6aa86
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/automatic-pod-disruption-budget-management.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/automatic-pod-disruption-budget-management
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/automatic-pod-disruption-budget-management.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 91046ae9-5e3b-6a58-1174-4fe2bdaf37e9
---

# Automatic Pod Disruption Budget management in AKS (preview) - Azure Kubernetes Service | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

During [AKS cluster upgrades](upgrade-conceptual), the upgrade process drains nodes by evicting pods so it can reimage or replace the nodes. [Pod Disruption Budgets (PDBs)](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/#pod-disruption-budgets) protect application availability during this process by limiting how many pods can be unavailable at once. However, misconfigured PDBs can also [block eviction entirely](upgrade-conceptual#restrictive-pod-disruption-budget-pdb-behavior) or deployments might not have enough replicas to satisfy the budget. Deployments without any PDB at all have the opposite problem: nothing protects their pods from being evicted simultaneously, which risks downtime during upgrades.

Automatic PDB management is an AKS extension, based on the [open-source project](https://github.com/Azure/eviction-autoscaler), that automates PDB management during upgrades. It:

- **Creates PDBs automatically** for deployments that don't have one, so your workloads are protected during voluntary disruptions.
- **Temporarily scales up replicas** when a PDB blocks pod eviction on a cordoned node, so the disruption budget is satisfied and the drain can proceed.
- **Scales replicas back down** after evictions complete, so you don't pay for extra capacity beyond what the upgrade requires.

The result is that upgrades complete reliably without you having to force-bypass PDB protections or manually resolve quarantined nodes. For background on how AKS upgrades drain nodes and how PDBs affect that process, see [How AKS cluster upgrades work](upgrade-conceptual).

## When to use automatic PDB management

Consider enabling automatic PDB management when:

- **Deployments lack PDBs.** Pods are evicted without availability guarantees during upgrades, leading to potential downtime.
- **PDBs block node drain.** A PDB with `minAvailable` equal to the replica count (or `maxUnavailable: 0`) prevents any pod from being evicted, causing the upgrade to fail with an error like `Cannot evict pod as it would violate the pod's disruption budget`.
- **Replicas are insufficient for the disruption budget.** The PDB exists and is configured correctly, but the deployment doesn't have enough replicas to absorb even one eviction.
- **You experience frequent upgrade drain failures** and want automated, proactive resolution rather than manual cleanup.

### Identify PDB-related drain failures

Before you enable automatic PDB management, check whether your cluster is experiencing PDB-related drain failures:

- **Azure Activity Log.** In the Azure portal, open your AKS cluster resource and select **Activity log**. Look for failed upgrade operations with status `Failed` and messages referencing pod disruption budgets or eviction errors.
- **Kubernetes events.** Run the following command to find recent eviction and drain events:

    ```bash
    kubectl get events --sort-by='.lastTimestamp' -A | grep -i "disruption\|evict\|drain"
    ```

    For a full guide on working with Kubernetes events, see [Kubernetes events](events).

### How it compares to other options

| Approach | Behavior | Trade-off |
| --- | --- | --- |
| **Force upgrade** | Bypasses PDB protections entirely | Risk of simultaneous pod eviction and service disruption |
| **Undrainable node behavior** | Cordons and quarantines blocked nodes; upgrade continues on other nodes | Requires manual cleanup of quarantined nodes after upgrade |
| **Overprovisioning** | Permanently run extra deployment replicas (more pods than the workload needs) so a PDB always has headroom to allow eviction | Ongoing cost for application pod capacity that's only needed during upgrades |
| **Automatic PDB management** (preview) | Creates PDBs for unprotected deployments and temporarily scales up replicas to satisfy PDB constraints, then scales back down | Requires the extension; adds transient capacity only during drain |

## How it works

Automatic PDB management has two complementary behaviors: **automatic PDB creation** (proactive) and **replica scaling during drain** (reactive).

### Automatic PDB creation

When you enable PDB auto-creation (`controllerConfig.pdb.create=true`), the extension continuously watches for deployments that don't have a PDB. The extension determines a match by comparing the PDB's label selector with the deployment's pod template labels. This comparison ensures each deployment is protected only once and avoids duplicate PDBs. When it finds an unprotected deployment in an enabled namespace, it creates a PDB. For deployments without HPA or KEDA, `minAvailable` is set to the deployment's current replica count. For deployments with HPA or KEDA, `minAvailable` tracks the autoscaler's minimum replica floor so PDB behavior remains aligned with autoscaler constraints. The extension continuously reconciles auto-created PDBs, so if the deployment's replica count changes (for example, through a manual update or an external scaler), the PDB's `minAvailable` value is updated to match. This protection ensures that pods aren't evicted simultaneously during voluntary disruptions.

Auto-created PDBs are managed by the extension throughout their lifecycle. For details on ownership, cleanup, and how to take manual control, see PDB ownership and cleanup.

Note

Automatic PDB management coordinates safely with HPA and KEDA when each deployment is managed by only one autoscaler. For details on how the extension interacts with each, including an unsupported configuration, see Coordination with autoscalers (HPA and KEDA).

### Replica scaling during drain

The extension monitors your cluster for situations where PDB-protected pods can't be evicted during node drain operations. Here's what happens during a typical upgrade:

1. **AKS cordons a node** as part of the upgrade process, marking it as unschedulable.
2. **The extension detects the cordon** and checks whether any PDB-protected pods on that node have zero allowed disruptions.
3. **If the PDB blocks eviction**, the extension temporarily scales up the deployment's replica count by the number of PDB-protected pods on cordoned nodes (up to the deployment's configured `maxSurge` limit), ensuring the surge is right-sized and you don't over-provision. The extra replicas are scheduled on other available nodes.
4. **The PDB's allowed disruptions rise above zero**, because the total number of healthy pods now exceeds the PDB's `minAvailable` threshold.
5. **Node drain proceeds normally.** The eviction API can now remove pods from the cordoned node without violating the PDB.
6. **After eviction signals stop and allowed disruptions rise above zero**, the extension scales the deployment back to its original replica count. Scale-down won't proceed if more nodes are still cordoned or if the drain is in progress. This condition prevents unnecessary churn during multi-node drains. The scale-down happens automatically after a cooldown period (default 60 seconds) with no manual intervention needed.

Note

Automatic PDB management only acts on *voluntary disruptions* such as upgrade drains and manual cordon/drain operations. It doesn't respond to node failures, pod crashes, or other involuntary disruptions.

### Coordination with autoscalers (HPA and KEDA)

Deployments are often managed by an autoscaler. To avoid race conditions where the autoscaler scales the deployment back down before evictions finish, the extension adjusts the autoscaler's *minimum* (not just the replica count) and reverts the change when the drain is complete.

| Configuration | How the extension surges | How the extension reverts | Notes |
| --- | --- | --- | --- |
| **Deployment only** | Increases the deployment's `replicas` directly. | Restores the original replica count after the cooldown. | Default behavior when no autoscaler is attached. |
| **Deployment + HPA** | Raises the HPA's `minReplicas` floor and adds a replica immediately, so the HPA doesn't scale back down mid-drain and doesn't wait for its metrics cycle. | Restores the original `minReplicas`; the HPA handles scale-down naturally. | Safe coordination with a single HPA. |
| **Deployment + KEDA** | Raises the `minReplicaCount` on the `ScaledObject` and adds a replica immediately, because KEDA has an extra latency hop (KEDA syncs to its HPA, then the HPA syncs to the deployment). | Restores the original `minReplicaCount`; KEDA and its HPA handle scale-down. | Safe coordination with a single KEDA `ScaledObject`. |
| **Deployment + KEDA + a separate HPA** | Not supported. KEDA already creates its own HPA, so a second HPA produces conflicting writes to the same deployment. | The extension marks itself `Degraded` on the `EvictionAutoScaler` status and doesn't surge, because it can't safely coordinate two autoscalers writing to the same target. | Inspect the `EvictionAutoScaler` resource status and remove the extra HPA to fix. |

To check the extension's view of a deployment, including any `Degraded` status from an unsupported autoscaler configuration:

```bash
kubectl get evictionautoscalers -A -o yaml
```

## Prerequisites

Before you install the automatic PDB management extension, make sure you have the following:

- An AKS cluster running a [supported Kubernetes version](supported-kubernetes-versions).
- Workloads that use **Deployments**. StatefulSets aren't supported, and using automatic PDB management with StatefulSets isn't recommended.
- Azure CLI version 2.64.0 or later. Run `az --version` to check. To install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- The `Microsoft.KubernetesConfiguration` provider registered in your subscription.
- Your AKS cluster must use a **managed identity** (not a service principal). Cluster extensions don't work with service-principal-based clusters. For more information, see [AKS cluster extensions](cluster-extensions).

Note

Automatic PDB management acts only on Pod Disruption Budgets and deployment replica counts. It's orthogonal to node-pool upgrade settings such as `max-surge`, node drain timeout, node soak time, and the upgrade strategy (rolling versus blue-green). Any node-pool configuration that works for your cluster continues to work with this extension enabled.

### Extension permissions

The automatic PDB management extension requires permissions to read and write Deployments, Pod Disruption Budgets, and Events in the namespaces it manages. The extension installs its own service account and RBAC roles during setup. For the full list of roles and permissions, see the [project repository on GitHub](https://github.com/Azure/eviction-autoscaler).

### Register the configuration provider

If you haven't used Azure Kubernetes extensions before, register the required provider:

```azurecli
az feature register --namespace Microsoft.KubernetesConfiguration --name Extensions

# Verify registration status
az feature show --namespace Microsoft.KubernetesConfiguration --name Extensions

# After the feature shows "Registered", refresh the provider
az provider register -n Microsoft.KubernetesConfiguration
```

## Install automatic PDB management

Automatic PDB management is installed as an extension on your AKS cluster. Choose an installation option based on your needs.

### Basic installation

Install the extension with default settings. In this mode, the extension watches for PDB-blocked evictions in the `kube-system` namespace but doesn't automatically create PDBs for unprotected deployments. The `kube-system` namespace is included by default because AKS-managed system components also use PDBs that can block node drains during upgrades:

```azurecli
az k8s-extension create \
    --cluster-name <cluster-name> \
    --cluster-type managedClusters \
    --extension-type microsoft.evictionautoscaler \
    --name eviction-autoscaler \
    --resource-group <resource-group-name> \
    --release-train stable \
    --auto-upgrade-minor-version true
```

### Install with automatic PDB creation for specific namespaces

Enable automatic PDB creation and specify which namespaces the extension should protect. This is the **recommended** configuration for most clusters:

```azurecli
az k8s-extension create \
    --cluster-name <cluster-name> \
    --cluster-type managedClusters \
    --extension-type microsoft.evictionautoscaler \
    --name eviction-autoscaler \
    --resource-group <resource-group-name> \
    --release-train stable \
    --configuration-settings controllerConfig.pdb.create=true controllerConfig.namespaces.actionedNamespaces="{kube-system,production}" \
    --auto-upgrade-minor-version true
```

### Install with cluster-wide protection

Enable automatic PDB creation across all namespaces:

```azurecli
az k8s-extension create \
    --cluster-name <cluster-name> \
    --cluster-type managedClusters \
    --extension-type microsoft.evictionautoscaler \
    --name eviction-autoscaler \
    --resource-group <resource-group-name> \
    --release-train stable \
    --configuration-settings controllerConfig.pdb.create=true controllerConfig.namespaces.enabledByDefault=true \
    --auto-upgrade-minor-version true
```

## Configuration options

The following settings control how automatic PDB management behaves:

| Setting | Description | Default |
| --- | --- | --- |
| `controllerConfig.pdb.create` | Automatically create PDBs for deployments that don't have one. | `false` |
| `controllerConfig.namespaces.enabledByDefault` | Enable automatic PDB management in all namespaces, including namespaces that already exist and any namespaces created later. | `false` |
| `controllerConfig.namespaces.actionedNamespaces` | Comma-separated list of namespaces to enable when `enabledByDefault` is `false`. There's no hard limit on the number of namespaces, but the Kubernetes API object size limit (~1 MiB per object) applies. | `{kube-system}` |

### Common configuration patterns

| Pattern | Settings | Use case |
| --- | --- | --- |
| **Conservative** | `pdb.create=false`, `enabledByDefault=false`, `actionedNamespaces={kube-system}` | You manage PDBs manually and want autoscaling only for system workloads. |
| **Targeted auto-protection** (recommended) | `pdb.create=true`, `enabledByDefault=false`, `actionedNamespaces={production,staging}` | You want automatic PDB creation and autoscaling in specific namespaces. |
| **Cluster-wide protection** | `pdb.create=true`, `enabledByDefault=true` | You want every namespace protected automatically. |
| **Monitoring only** | `pdb.create=false`, `enabledByDefault=true` | You want autoscaling across all namespaces but manage PDBs yourself. |

## Namespace control

The extension operates in one of two modes depending on the `enabledByDefault` setting.

Two complementary controls govern which namespaces the extension acts on:

- `controllerConfig.namespaces.actionedNamespaces` sets the baseline list at install time and is the easiest way to enable a known set of namespaces.
- The `eviction-autoscaler.azure.com/enable` (or `disable`) namespace annotation lets cluster operators opt namespaces in or out at runtime without reinstalling the extension.

### Opt-in mode (default)

When `enabledByDefault` is `false`, only namespaces listed in `actionedNamespaces` are enabled. You can enable additional namespaces individually by adding an annotation:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: my-namespace
  annotations:
    eviction-autoscaler.azure.com/enable: "true"
```

### Opt-out mode

When `enabledByDefault` is `true`, all namespaces are enabled. You can exclude specific namespaces by adding an annotation:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: my-excluded-namespace
  annotations:
    eviction-autoscaler.azure.com/enable: "false"
```

### Exclude specific deployments

To prevent the extension from creating a PDB for a specific deployment, add the following annotation to the deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
  annotations:
    eviction-autoscaler.azure.com/pdb-create: "false"
```

Note

Automatic PDB management automatically skips PDB creation for deployments that have `maxUnavailable` (other than 0) in their rolling update strategy, because such deployments already tolerate some level of downtime.

## Automatic PDB creation

When `controllerConfig.pdb.create` is set to `true`, the extension creates PDBs for deployments that meet all of the following criteria:

- The deployment doesn't already have a matching PDB.
- The deployment is in an enabled namespace.
- The deployment isn't excluded via the `eviction-autoscaler.azure.com/pdb-create: "false"` annotation.

Auto-created PDBs set `minAvailable` based on the workload's scaling source. For deployments without HPA or KEDA, `minAvailable` matches the deployment's current replica count (excluding any surge replicas added by the extension). For deployments with HPA or KEDA, `minAvailable` aligns to the autoscaler's minimum replicas floor. This means eviction is blocked until the extension scales up the deployment, at which point the extra replicas satisfy the budget and allow drain to proceed.

### PDB ownership and cleanup

PDBs created by the extension are marked with an `ownedBy: EvictionAutoScaler` annotation. These controller-owned PDBs are automatically deleted when:

- The parent deployment is deleted.
- The namespace is removed from the extension's scope.
- The extension is removed from the cluster. PDBs with the `ownedBy: EvictionAutoScaler` annotation are cleaned up through Kubernetes garbage collection.

PDBs that you create manually are never modified or deleted by the extension.

To take manual control of a PDB that was created by the extension, remove the ownership annotation. After you remove this annotation, the extension no longer manages that PDB, and you're responsible for updating or deleting it:

```bash
kubectl annotate pdb <pdb-name> -n <namespace> ownedBy-
```

## Verify the installation

After installing the extension, verify that automatic PDB management is working correctly.

1. **Check that PDBs were created** for deployments in enabled namespaces. Filter for PDBs created by the extension:

    ```bash
    kubectl get pdb -A -o custom-columns=NAME:.metadata.name,NAMESPACE:.metadata.namespace,MIN-AVAILABLE:.spec.minAvailable,OWNER:.metadata.annotations.ownedBy | grep EvictionAutoScaler
    ```
2. **Check the automatic PDB management custom resources**:

    ```bash
    kubectl get evictionautoscalers --all-namespaces
    ```
3. **Test with a node cordon** (optional). In a test or staging environment, cordon a node and verify that the extension scales up the deployment and the PDB's allowed disruptions rise above zero:

    ```bash
    # Cordon a node
    NODE=$(kubectl get pods -n <namespace> -l app=<app-label> -o=jsonpath='{.items[0].spec.nodeName}')
    kubectl cordon $NODE
    
    # Watch for automatic PDB management events
    kubectl get events -n <namespace> --sort-by='.lastTimestamp'
    
    # Check that the deployment scaled up
    kubectl get pods -n <namespace>
    
    # Verify PDB allowed disruptions
    kubectl get poddisruptionbudget <pdb-name> -n <namespace> -o yaml
    
    # After verification, uncordon the node
    kubectl uncordon $NODE
    ```

## Update or remove the extension

### Update configuration

To change configuration settings, delete and recreate the extension with the new settings:

```azurecli
# Delete the existing extension
az k8s-extension delete \
    --resource-group <resource-group-name> \
    --cluster-name <cluster-name> \
    --cluster-type managedClusters \
    --name eviction-autoscaler \
    --yes

# Recreate with new configuration
az k8s-extension create \
    --cluster-name <cluster-name> \
    --cluster-type managedClusters \
    --extension-type microsoft.evictionautoscaler \
    --name eviction-autoscaler \
    --resource-group <resource-group-name> \
    --release-train stable \
    --configuration-settings controllerConfig.pdb.create=true controllerConfig.namespaces.enabledByDefault=true \
    --auto-upgrade-minor-version true
```

### Remove the extension

To uninstall automatic PDB management:

```azurecli
az k8s-extension delete \
    --resource-group <resource-group-name> \
    --cluster-name <cluster-name> \
    --cluster-type managedClusters \
    --name eviction-autoscaler \
    --yes
```

Note

When you remove the extension, auto-created PDBs (marked with the `ownedBy: EvictionAutoScaler` annotation) are cleaned up automatically. For more details, see PDB ownership and cleanup.

## Limitations and considerations

- Configuration updates require deleting and recreating the extension.
- Automatic PDB management works with **Deployments** only. **StatefulSets aren't supported**, and using this extension with StatefulSets isn't recommended.
- Automatic PDB management doesn't override or modify existing PDBs. It works alongside them by adjusting replica counts.
- Automatic PDB management coordinates with a single autoscaler per deployment (HPA *or* KEDA). A deployment managed by KEDA *and* a separate HPA is unsupported; the extension marks itself `Degraded` and skips surging. See Coordination with autoscalers (HPA and KEDA).
- Automatic PDB management is independent of node-pool upgrade settings. Settings such as `max-surge`, node drain timeout, node soak time, and upgrade strategy (rolling versus blue-green) don't need to be changed for this extension to work, and the extension doesn't change how those settings behave.
- The temporary replica scale-up requires available capacity in the cluster. If no nodes have room for the extra pods, consider enabling the [cluster autoscaler](cluster-autoscaler) or [node auto-provisioning (NAP)](node-auto-provisioning) so that new nodes can be provisioned.

## Troubleshooting

For symptoms, causes, and resolutions, see the AKS troubleshooting hub: [Troubleshoot Azure Kubernetes Service](/en-us/troubleshoot/azure/azure-kubernetes/welcome-azure-kubernetes).

To inspect extension activity directly on the cluster, run:

```bash
kubectl get evictionautoscalers -A -o yaml
kubectl get events -A --sort-by='.lastTimestamp'
```