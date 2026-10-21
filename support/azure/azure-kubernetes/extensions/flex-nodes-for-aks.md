---
layout: Conceptual
title: Troubleshoot AKS flex node Machine API and node pool changes - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/flex-nodes-for-aks
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: sachidesai
ms.author: sachidesai
ms.topic: troubleshooting-general
description: Learn how to troubleshoot AKS flex node Machine API and node pool changes, including attachment, configuration, upgrades, and removal.
ms.date: 2026-09-22T00:00:00.0000000Z
ms.service: azure-kubernetes-service
ai-usage: ai-assisted
locale: en-us
document_id: 7e47b883-3055-4b32-6688-455202396de4
document_version_independent_id: 7e47b883-3055-4b32-6688-455202396de4
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/flex-nodes-for-aks.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/flex-nodes-for-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/flex-nodes-for-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 79807100-263c-e201-efe7-ed27c5532866
---

# Troubleshoot AKS flex node Machine API and node pool changes - Azure | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Summary

This article helps you troubleshoot Azure Kubernetes Service (AKS) Machine API and node pool behavior that's specific to flex nodes. For host preparation, networking, and initial attachment, see [Overview of flex nodes for AKS](/en-us/azure/aks/flex-nodes-for-aks-overview) and [Attach a flex node to an AKS cluster](/en-us/azure/aks/attach-flex-node-to-aks).

A flex node has three related states:

- The flex node pool stores defaults for hosts that attach later and the target Kubernetes version for pool operations.
- The Azure Machine resource stores the desired and observed configuration for one attached host. It doesn't provision or own the host.
- The node represents the running worker that registers with the cluster.

A successful change at one layer doesn't always update the other layers immediately. Compare all three states before you retry an operation or change the host.

## Verify the flex nodes prerequisites

Before you troubleshoot a specific symptom, verify the preview features, Azure CLI extension, pool type, and resource states.

| Prerequisite | How to verify |
| --- | --- |
| **Flex nodes preview** | `az feature show --namespace Microsoft.ContainerService --name AKSFlexNodePreview --query properties.state --output tsv` returns `Registered`. |
| **Machine API preview** | `az feature show --namespace Microsoft.ContainerService --name PutMachinePreview --query properties.state --output tsv` returns `Registered` if your AKS version is earlier than `v20260904`. |
| **Azure CLI extension** | `az extension show --name aks-preview --query version --output tsv` returns the minimum preview version `22.0.0b8` or later. |
| **Flex node pool** | `az aks nodepool show` reports `type: FlexNodes` and `provisioningState: Succeeded`. |
| **Machine resource** | `az aks machine list` returns one Machine resource for each attached host. |
| **Kubernetes node** | `kubectl get nodes --selector kubernetes.azure.com/nodepool-type=FlexNodes` returns the registered flex nodes. |

Set the values that the commands in this article use:

```bash
export RESOURCE_GROUP="<resource-group>"
export CLUSTER_NAME="<cluster-name>"
export FLEX_POOL_NAME="<flex-pool-name>"
export FLEX_NODE_NAME="<machine-and-node-name>"
```

Show the pool, Machine resources, and Kubernetes nodes:

```azurecli
az aks nodepool show \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --name "$FLEX_POOL_NAME" \
  --query '{type:(typePropertiesType || type),state:provisioningState,version:orchestratorVersion,labels:nodeLabels,taints:nodeTaints}' \
  --output yaml

az aks machine list \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --nodepool-name "$FLEX_POOL_NAME" \
  --query '[].{machine:name,node:properties.kubernetes.nodeName,state:properties.provisioningState,requestedVersion:properties.kubernetes.orchestratorVersion,currentVersion:properties.kubernetes.currentOrchestratorVersion}' \
  --output table
```

```bash
kubectl get nodes \
  --selector kubernetes.azure.com/nodepool-type=FlexNodes \
  --output 'custom-columns=NAME:.metadata.name,READY:.status.conditions[?(@.type=="Ready")].status,KUBELET:.status.nodeInfo.kubeletVersion,UID:.metadata.uid'
```

## The flex node pool can't be created or updated

Flex node pools are empty user pools. AKS doesn't create or manage the underlying hosts for these pools.

Confirm the following conditions:

- The pool uses `--vm-set-type FlexNodes` and `--mode User`.
- The requested Kubernetes version is supported by the cluster and isn't later than the control-plane version.
- The operation doesn't include settings that apply only to AKS-managed virtual machine scale set nodes.
- No other operation is running on the cluster or node pool.

Inspect the pool provisioning state:

```azurecli
az aks nodepool show \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --name "$FLEX_POOL_NAME" \
  --query '{type:(typePropertiesType || type),state:provisioningState,version:orchestratorVersion}' \
  --output yaml
```

If the state is `Failed`, review the failed deployment operation and the Azure activity log before you retry the update. Confirm that the request targets the intended cluster and flex node pool.

## The host registers as a node but no Machine resource appears

A healthy attachment creates both a Kubernetes node and an Azure Machine resource in the selected flex node pool. If the Node exists but `az aks machine list` doesn't return a matching Machine, confirm the following conditions:

- The host was bootstrapped with data from the intended cluster and flex node pool.
- The bootstrap data was fetched less than one hour before use.
- The host identity has the required AKS permissions at the target cluster scope.
- The flex node agent is running and can reach Azure Resource Manager, Microsoft Entra ID, and the AKS API server.
- The Machine name and `properties.kubernetes.nodeName` match the host's lowercase Kubernetes node name.

List the Machine resources in the selected pool:

```azurecli
az aks machine list \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --nodepool-name "$FLEX_POOL_NAME" \
  --query '[].{machine:name,node:properties.kubernetes.nodeName,state:properties.provisioningState}' \
  --output table
```

Don't create a Machine resource manually to repair a failed bootstrap. Correct the identity, bootstrap data, or connectivity issue. Then clean up the host by following the Remove a flex node steps in [Manage and remove flex nodes in AKS](/en-us/azure/aks/manage-and-remove-flex-nodes), and reattach it by following [Attach a flex node to an AKS cluster](/en-us/azure/aks/attach-flex-node-to-aks).

## The Machine resource succeeds but the Kubernetes node is missing or not ready

A `Succeeded` Machine provisioning state confirms the Azure resource operation. It doesn't prove that the host agent, kubelet, networking, or Kubernetes node is healthy.

Confirm the following conditions:

- `properties.kubernetes.nodeName` contains the expected node name.
- The `aks-flex-node-agent` service is active on the host. Check it with `systemctl is-active aks-flex-node-agent`, and review recent entries with `journalctl -u aks-flex-node-agent -n 100 --no-pager`.
- The host can reach the AKS API server and required identity and artifact endpoints.
- The kubelet is running, and the container runtime and pod networking are healthy.
- The host name hasn't changed since bootstrap.

Compare the Machine mapping with the live node:

```azurecli
az aks machine show \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --nodepool-name "$FLEX_POOL_NAME" \
  --machine-name "$FLEX_NODE_NAME" \
  --query '{state:properties.provisioningState,nodeName:properties.kubernetes.nodeName,currentVersion:properties.kubernetes.currentOrchestratorVersion}' \
  --output yaml
```

```bash
kubectl get node "$FLEX_NODE_NAME" -o wide
kubectl describe node "$FLEX_NODE_NAME"
```

If the Node is `NotReady`, troubleshoot the condition and events reported by `kubectl describe` before you retry a Machine API operation.

## A node pool label or taint change doesn't appear on existing flex nodes

This behavior is expected. For flex nodes, `az aks nodepool update` changes the defaults for hosts that join the pool later. It doesn't modify Machines that are already attached.

Compare the pool defaults with an existing node:

```azurecli
az aks nodepool show \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --name "$FLEX_POOL_NAME" \
  --query '{labels:nodeLabels,taints:nodeTaints,state:provisioningState}' \
  --output yaml
```

```bash
kubectl get node "$FLEX_NODE_NAME" \
  --output jsonpath='{.metadata.labels}{"\n"}{.spec.taints}{"\n"}'
```

To change an existing flex node, update its Machine resource:

```azurecli
az aks machine update \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --nodepool-name "$FLEX_POOL_NAME" \
  --machine-name "$FLEX_NODE_NAME" \
  --labels <key>=<value> \
  --node-taints <key>=<value>:<effect> \
  --output none
```

The Machine update replaces the managed labels and taints. Include every managed value that you want to retain. A successful label or taint update doesn't recreate the node.

## Only one existing flex node received a configuration change

A Machine update applies only to the named Machine. It doesn't update other Machines in the pool or change the defaults for hosts that attach later.

Confirm the target Machine name and list all Machines in the pool:

```azurecli
az aks machine list \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --nodepool-name "$FLEX_POOL_NAME" \
  --query '[].name' \
  --output tsv
```

Run `az aks machine update` separately for each existing Machine that needs the change. Update the node pool too when future hosts must receive the same defaults.

## The Machine target version changes but the node still runs the old version

This behavior is expected after `az aks machine update --kubernetes-version`. The command changes the desired version on the Machine resource. The running Kubernetes node keeps its current kubelet version until the node is recreated.

Confirm the control plane, Machine target, Machine current version, and running kubelet version:

```azurecli
az aks show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CLUSTER_NAME" \
  --query '{requestedVersion:kubernetesVersion,currentVersion:currentKubernetesVersion,state:provisioningState}' \
  --output yaml

az aks machine show \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --nodepool-name "$FLEX_POOL_NAME" \
  --machine-name "$FLEX_NODE_NAME" \
  --query '{requestedVersion:properties.kubernetes.orchestratorVersion,currentVersion:properties.kubernetes.currentOrchestratorVersion,state:properties.provisioningState}' \
  --output yaml
```

```bash
kubectl get node "$FLEX_NODE_NAME" \
  --output custom-columns=NAME:.metadata.name,KUBELET:.status.nodeInfo.kubeletVersion,UID:.metadata.uid
```

Before you recreate the node, confirm the following conditions:

- The AKS control plane already runs the target version.
- The target version is supported for flex nodes.
- Workloads are drained or can tolerate disruption. Pods created without a controller aren't recreated automatically.
- The host agent is healthy and retains its bootstrap configuration.

Delete only the AKS node after you meet these conditions. Don't reset or bootstrap the host. The existing flex node agent registers a replacement node at the Machine target version.

To drain the node, delete it, and confirm the replacement, follow the Upgrade one machine first steps in [Manage and remove flex nodes in AKS](/en-us/azure/aks/manage-and-remove-flex-nodes). The replacement node returns with the same name, a new UID, and the target kubelet version.

## A flex node pool upgrade is blocked or doesn't update every Node

A pool upgrade coordinates the Kubernetes version across the flex node pool and its Machines. It can recreate nodes and disrupt workloads.

Confirm the following conditions:

- The target Kubernetes version satisfies AKS upgrade and control-plane version compatibility requirements.
- No conflicting operation is running on the cluster or node pool before the upgrade starts.
- The target version is supported for flex nodes.
- The host agent is active on every host.
- Workloads tolerate eviction and recreation within the configured `maxUnavailable` value.

After the operation, compare pool, Machine, and node versions. Don't treat the pool's `Succeeded` state alone as proof that every kubelet runs the target version.

## A deleted AKS node returns

Deleting a node doesn't detach the flex host or delete its Machine resource. If the host agent remains installed and active, it registers the node again.

Choose the action that matches your intent:

| Intended action | Required operation |
| --- | --- |
| **Recreate the node** | Delete only the AKS node and leave the host agent and Machine resource in place. |
| **Detach one flex host** | Drain the node, reset the host, remove any remaining node, and delete the Machine through the node pool delete-machines operation. |
| **Delete the flex node pool** | Detach every host and remove every Machine first, and then delete the empty pool. |

Don't delete the Machine as the first detachment step. Reset the host first so that local credentials, cluster state, and networking resources are removed in [the documented order](/en-us/azure/aks/manage-and-remove-flex-nodes).

## A Machine resource remains after host detachment

The host reset can remove the node while an Azure Machine resource remains. Confirm that the host reset completed before you delete the remaining Machine.

Check whether the Machine still exists:

```azurecli
az aks machine show \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --nodepool-name "$FLEX_POOL_NAME" \
  --machine-name "$FLEX_NODE_NAME" \
  --output none
```

Delete the remaining Machine through the flex node pool:

```azurecli
az aks nodepool delete-machines \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --nodepool-name "$FLEX_POOL_NAME" \
  --machine-names "$FLEX_NODE_NAME" \
  --output none
```

Confirm that the Machine name is no longer returned:

```azurecli
az aks machine list \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --nodepool-name "$FLEX_POOL_NAME" \
  --query "[?name=='${FLEX_NODE_NAME}'].name" \
  --output tsv
```

## References

- [Overview of flex nodes for AKS](/en-us/azure/aks/flex-nodes-for-aks-overview)
- [Attach a flex node to an AKS cluster](/en-us/azure/aks/attach-flex-node-to-aks)
- [Manage and remove flex nodes in AKS](/en-us/azure/aks/manage-and-remove-flex-nodes)
- [Troubleshoot an AKS cluster](/en-us/azure/aks/troubleshooting)