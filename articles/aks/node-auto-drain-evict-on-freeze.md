---
layout: Conceptual
title: Configure pod eviction for freeze events in Azure Kubernetes Service (AKS) (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/node-auto-drain-evict-on-freeze
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
description: Learn how to configure AKS node auto-drain to evict specific pods before freeze events occur on underlying virtual machines.
ms.topic: how-to
ms.date: 2026-03-30T00:00:00.0000000Z
author: varora24
ms.author: vaibhavarora
ai-usage: ai-assisted
locale: en-us
document_id: 0c48353e-e7de-6d9b-6b30-0ab4b0634fb0
document_version_independent_id: 79978bbe-2cbb-d4bd-ed8f-14872a08c80a
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/node-auto-drain-evict-on-freeze.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/node-auto-drain-evict-on-freeze
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/node-auto-drain-evict-on-freeze.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: e7347012-4dc4-abef-7fcd-1bc236491342
---

# Configure pod eviction for freeze events in Azure Kubernetes Service (AKS) (preview) - Azure Kubernetes Service | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

[Node auto-drain](node-auto-drain) helps protect your workloads from disruptions when [scheduled events](/en-us/azure/virtual-machines/linux/scheduled-events) occur on the underlying virtual machines (VMs) in your node pools. By default, freeze events don't trigger cordon and drain because they usually pause a node only briefly. If you have workloads that can't tolerate short disruptions, you can opt in to evict labeled pods before the freeze begins.

Evict on freeze has two levels of configuration:

- **Cluster-level configuration**: A `ConfigMap` tells AKS to cordon the affected node when a freeze event is scheduled. Cordoning prevents new pods from being scheduled on the node but doesn't evict any existing pods by itself.
- **Pod-level configuration**: A label on individual pods opts them in for eviction. When the node is cordoned, AKS evicts only the pods that carry this label. Unlabeled pods remain on the node and aren't disrupted.

The `ConfigMap` alone only cordons the node, and the label alone has no effect without the `ConfigMap`. When both are in place, any node that receives a `VMEventScheduled` condition with a `Freeze` message is cordoned and labeled pods are evicted. Eviction respects [Pod Disruption Budgets (PDBs)](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/#pod-disruption-budgets), so pods can only be evicted if the PDB allows it.

## Prerequisites

- An existing AKS cluster. If you don't have one, [create an AKS cluster](/en-us/azure/aks/learn/quick-kubernetes-deploy-cli).
- The `kubectl` command-line tool configured to connect to your cluster.
- Properly configured [Pod Disruption Budgets](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/#pod-disruption-budgets) for the workloads you want to evict.

## Enable node cordoning for freeze events

Publish a `ConfigMap` in the `kube-system` namespace to tell AKS to cordon nodes when freeze events are scheduled. Cordoning marks the node as unschedulable so no new pods land on it, but doesn't remove any existing pods. To evict specific pods during the freeze, you must also label them for eviction.

1. Create a file named `remediator-config.yaml` with the following contents:

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: remediator-config
      namespace: kube-system
    data:
      appConfig: |
        {
          "Cluster": {
            "OnFreeze": {
              "Enabled": true
            }
          }
        }
    ```
2. Apply the `ConfigMap` to your cluster using `kubectl apply`:

    ```bash
    kubectl apply -f remediator-config.yaml
    ```

Note

The configuration is read every 30 minutes, so changes might not be immediately applied to the cluster.

## Label pods for eviction during freeze events

After you enable the cluster-level configuration, mark individual pods for eviction by applying the `remediator.kubernetes.azure.com/onFreeze` label. During the drain phase, only pods with this label are evicted.

You can add the label to your workload manifest or apply it to running pods.

### Add the label in a deployment manifest

For persistent workloads, add the label to the pod template in your deployment manifest so Kubernetes keeps the setting when it recreates the pods:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: some-pod-safe-to-evict
  labels:
    remediator.kubernetes.azure.com/onFreeze: ""
spec:
  containers:
    - name: my-container
      image: mcr.microsoft.com/mcr/hello-world:latest
```

### Apply the label to an existing pod

Use `kubectl label` to add the label to a running pod:

```bash
kubectl label pod <pod-name> remediator.kubernetes.azure.com/onFreeze=""
```

This method is useful for quick validation, but the label is removed if Kubernetes recreates the pod.

When both the `ConfigMap` and pod labels are configured, AKS cordons the node and evicts only the labeled pods about five minutes before the scheduled freeze event time. Unlabeled pods continue running on the cordoned node.

Important

Ensure your [Pod Disruption Budgets](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/#pod-disruption-budgets) are properly configured. If the PDB doesn't allow disruption at the time of the scheduled event, the eviction fails.

## Troubleshoot eviction for freeze events

If you notice freeze events but no cordon or drain events follow, or pods aren't being evicted as expected, use the following steps to investigate.

### Check Kubernetes events

You can use the Kubernetes event log or [Container Insights](/en-us/azure/azure-monitor/containers/container-insights-overview) to monitor the progression of cordon, drain, and eviction for freeze events. For more information, see [Use Kubernetes events for troubleshooting](events).

The following events appear during the drain and eviction process:

| Event | Description |
| --- | --- |
| `VMEventScheduled` | Marks the start of the scheduled VM event lifecycle for the node. |
| `FreezeScheduled` | Indicates a freeze event is scheduled, including the scheduled time. |
| `NodeCordonStart` | The node cordon begins, approximately five minutes before the scheduled event. |
| `NodeCordonEnd` | The node cordon completes. |
| `NodeDrainStart` | The drain begins and labeled pods start being evicted. |
| `Evicted` | A pod event that shows the specific pod that was evicted. |
| `FailedToEvict` | A pod event that indicates a pod failed to evict for any reason. |
| `NodeDrainEnd` | The drain completes when labeled pods are evicted. |
| `NoVMEventScheduled` | When no scheduled events are found for the node. |
| `NodeUncordonStart` | After the freeze event finishes, the node uncordon begins. |
| `NodeUncordonEnd` | The node uncordon completes and the node is schedulable again. |

If failures occur at any step, a separate error event is logged. For example, a `NodeDrainError` event appears with details in the event message.

If you see `FreezeScheduled` events but no `NodeCordonStart` events, the cluster-level `ConfigMap` might not be applied correctly. If you see cordon events but labeled pods aren't being evicted, verify that the pods carry the `remediator.kubernetes.azure.com/onFreeze` label and that the PDB allowed eviction at the time of the event.

### Verify the ConfigMap

Confirm that the cluster-level `ConfigMap` is correctly applied by running the following command:

```bash
kubectl describe configmap remediator-config -n kube-system
```

Compare the output with the configuration described in Enable node cordoning for freeze events.

### Verify pod labels

Confirm that the pods you want evicted have the correct label by running the following command:

```bash
kubectl get pods --show-labels -o wide
```

Verify that the `remediator.kubernetes.azure.com/onFreeze` label appears on the expected pods and that the pods are running on the target nodes. Pods without this label aren't evicted during the drain phase.

### Verify Pod Disruption Budgets

Confirm that your PDBs allow eviction at the time of the scheduled event:

```bash
kubectl get pdb
```

If the PDB doesn't allow disruption, the eviction fails even if the pod is correctly labeled.

## Limitations

- You can't trigger or simulate freeze events directly. However, freeze events are common in canary environments. To evaluate this feature, create clusters in the `eastus2euap` or `centraluseuap` regions.
- The `ConfigMap` is read every 30 minutes, so configuration changes might not be applied immediately.
- Eviction depends on [Pod Disruption Budgets](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/#pod-disruption-budgets). If a PDB doesn't allow disruption, eviction fails.