---
layout: Conceptual
title: Configure Node Pools for Node Auto-Provisioning (NAP) in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/node-auto-provisioning-node-pools
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
description: This article shows you how to configure node pools for Node Auto-Provisioning (NAP) in Azure Kubernetes Service (AKS), including SKU selectors, limits, and weights.
ms.topic: how-to
ms.custom: devx-track-azurecli, aks-scaling
ms.date: 2026-09-09T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
ai-usage: ai-assisted
locale: en-us
document_id: b83fb3b4-2873-1acd-4024-54e63f8f2385
document_version_independent_id: e0ad4c28-d14f-a2a5-92c0-6064b616cd95
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/node-auto-provisioning-node-pools.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/node-auto-provisioning-node-pools
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/node-auto-provisioning-node-pools.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: ff35437f-b739-7952-2715-a43fc33d568b
---

# Configure Node Pools for Node Auto-Provisioning (NAP) in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article explains how to configure node pools for node auto-provisioning (NAP) in Azure Kubernetes Service (AKS), including SKU selectors, resource limits, and priority weights. It also provides examples to help you get started.

AKS Automatic includes NAP by default. For AKS Standard clusters, you must enable NAP before you configure its node pools.

## How NAP selects VMs for node pools

NAP uses virtual machine (VM) SKU requirements to decide the best VMs for pending workloads. You can configure:

- SKU families and specific instance types.
- Resource limits and priorities.
- Spot or On-demand instances.
- Architecture, GPU, and other capabilities requirements.

The `NodePool` resource sets constraints on the nodes that NAP creates and the pods that run on those nodes. When you enable NAP with the default node pool configuration set to `Auto`, it creates default `NodePool` resources. You can modify these node pools or create extra node pools to suit your workload requirements.

## How NAP evaluates and selects node pools

When configuring `NodePools` for NAP, keep the following behaviors in mind:

- NAP requires at least one `NodePool` to function.
- NAP evaluates each configured `NodePool`.
- NAP skips `NodePools` with taints not tolerated by a pod.
- NAP applies startup taints to provisioned nodes but doesn't require pod toleration.
- NAP works best with mutually exclusive `NodePools`, whose requirements don't overlap so that each pod matches only one pool. When multiple `NodePools` match, NAP uses the one with the highest weight.

## Review default node pool configuration

The configuration of the default [Karpenter `NodePool`](https://karpenter.sh/docs/concepts/nodepools/) named `default` created by NAP is as follows:

```yaml
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: default
spec:
  disruption:
    consolidationPolicy: WhenEmptyOrUnderutilized
  template:
    spec:
      nodeClassRef:
        group: karpenter.azure.com
        kind: AKSNodeClass
        name: default
      expireAfter: Never
      # Requirements that constrain the parameters of provisioned nodes.
      # These requirements are combined with pod.spec.affinity.nodeAffinity rules.
      # Operators { In, NotIn, Exists, DoesNotExist, Gt, and Lt } are supported.
      # https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#operators
      requirements:
      - key: kubernetes.io/arch
        operator: In
        values:
        - amd64
      - key: kubernetes.io/os
        operator: In
        values:
        - linux
      - key: karpenter.sh/capacity-type
        operator: In
        values:
        - on-demand
      - key: karpenter.azure.com/sku-family
        operator: In
        values:
        - D
```

NAP also creates a `system-surge` node pool that provides on-demand Linux AMD64 capacity for critical system add-ons. When a pending pod tolerates the `CriticalAddonsOnly=true:NoSchedule` taint and matches the pool requirements, NAP can provision a node from this pool. Nodes created by the pool have the `kubernetes.azure.com/mode: system` label.

## Control the default node pools

When you [create a new AKS cluster enabled with NAP using the Azure CLI](use-node-auto-provisioning#enable-nap-on-a-new-cluster), include the `--node-provisioning-default-pools` flag to control whether AKS creates the default NAP `NodePools`. You can also use this flag with [`az aks update`](/en-us/cli/azure/aks#az-aks-update) when you enable NAP on an existing cluster.

The `--node-provisioning-default-pools` flag accepts the following values:

- **`Auto`** (default): Creates two standard `NodePools` for immediate use.
- **`None`**: Doesn't create any `NodePools`. You must define your own.

Warning

**Changing from `Auto` to `None`**: If you change the setting from `Auto` to `None` on an existing cluster, the default `NodePools` aren't deleted automatically. Before you delete them, define suitable replacement capacity for critical system add-ons. You must delete the default `NodePools` manually if you no longer need them.

## Node pool configuration options

The following sections outline various configuration options for `NodePools` in NAP, including well-known labels and SKU selectors, node pool limits, and node pool weights.

### Well-known labels and SKU selectors

Kubernetes defines [well-known labels](https://kubernetes.io/docs/reference/labels-annotations-taints/) that Azure implements. You can define these labels in the `spec.requirements` section of the `NodePool` API. NAP also supports Azure-specific labels for more advanced scheduling.

The following table lists the labels you can use in the `spec.requirements` section of your `NodePool` API to define VM characteristics for your nodes:

| Selector | Description | Example |
| --- | --- | --- |
| `karpenter.sh/capacity-type` | VM allocation type (Spot / On-demand) | Spot |
| `karpenter.azure.com/sku-family` | VM SKU family | D, F, L, etc. |
| `karpenter.azure.com/sku-series` | VM SKU series | Dpls\_v6 |
| `karpenter.azure.com/sku-name` | Explicit SKU name | Standard\_A1\_v2 |
| `karpenter.azure.com/sku-version` | SKU version (without "v", can use 1) | 1, 2 |
| `karpenter.azure.com/sku-cpu` | Number of CPUs in VM | 16 |
| `karpenter.azure.com/sku-memory` | Memory in VM in MiB | 131072 |
| `karpenter.azure.com/sku-gpu-name` | GPU name | A100 |
| `karpenter.azure.com/sku-gpu-manufacturer` | GPU manufacturer | nvidia |
| `karpenter.azure.com/sku-gpu-count` | GPU count per VM | 2 |
| `karpenter.azure.com/sku-networking-accelerated` | Whether the VM has accelerated networking | [true, false] |
| `karpenter.azure.com/sku-storage-premium-capable` | Whether the VM supports Premium IO storage | [true, false] |
| `karpenter.azure.com/sku-storage-ephemeralos-maxsize` | Size limit for the ephemeral operating system (OS) disk in GB | 92 |
| `kubernetes.azure.com/sku-cpu` | Number of CPUs in VM | 16 |
| `kubernetes.azure.com/sku-memory` | Memory in VM in MiB | 131072 |
| `kubernetes.azure.com/cluster` | AKS cluster name | my-cluster |
| `kubernetes.azure.com/mode` | Node pool mode | [system, user] |
| `kubernetes.azure.com/priority` | Priority | [spot, regular] |
| `kubernetes.azure.com/os-sku` | Operating system SKU | [Ubuntu, AzureLinux] |
| `kubernetes.azure.com/fips_enabled` | Whether FIPS is enabled | true |
| `topology.kubernetes.io/zone` | Availability zone(s) | [uksouth-1,uksouth-2,uksouth-3] |
| `kubernetes.io/os` | Operating system | linux |
| `kubernetes.io/arch` | CPU architecture (AMD64 or ARM64) | [amd64, arm64] |

The memory selector values in this table are the MiB values reported on NAP-created nodes. Before you add a selector, inspect the labels on your nodes to confirm the value used by your cluster.

#### SKU family examples

The `karpenter.azure.com/sku-family` selector allows you to target specific VM families.

| Family | Description |
| --- | --- |
| D-series | General-purpose VMs with balanced CPU-to-memory ratio |
| F-series | Compute-optimized VMs with high CPU-to-memory ratio |
| E-series | Memory-optimized VMs for memory-intensive applications |
| L-series | Storage-optimized VMs with high disk throughput |
| N-series | GPU-enabled VMs for compute-intensive workloads |

Example configuration using SKU family:

```yaml
requirements:
- key: karpenter.azure.com/sku-family
  operator: In
  values:
  - D
  - F
```

#### GPU SKU example

To provision NVIDIA GPU nodes with NAP, create a `NodePool` that selects GPU-enabled VM sizes. The following example allows NAP to select N-series NVIDIA GPU SKUs:

```yaml
requirements:
- key: karpenter.azure.com/sku-family
  operator: In
  values:
  - N
- key: karpenter.azure.com/sku-gpu-manufacturer
  operator: In
  values:
  - nvidia
```

If you want AKS to install and manage the NVIDIA GPU driver, device plugin, Data Center GPU Manager (DCGM) metrics exporter, and GPU health signals on NAP-provisioned GPU nodes, configure managed GPU in the referenced `AKSNodeClass`. For more information, see [Create an AKS-managed GPU node pool](aks-managed-gpu-nodes#create-an-aks-managed-gpu-node-pool-preview).

#### SKU name examples

The `karpenter.azure.com/sku-name` selector allows you to specify the exact VM instance type.

```yaml
requirements:
- key: karpenter.azure.com/sku-name
  operator: In
  values:
  - Standard_D4s_v3
  - Standard_F8s_v2
```

#### SKU version examples

The `karpenter.azure.com/sku-version` selector targets specific generations of VM SKUs.

```yaml
requirements:
- key: karpenter.azure.com/sku-version
  operator: In
  values:
  - "3"  # v3 generation
  - "5"  # v5 generation
```

#### Availability zone example

The `topology.kubernetes.io/zone` selector allows you to specify the availability zones for your nodes.

```yaml
requirements:
- key: topology.kubernetes.io/zone
  operator: In
  values:
  - eastus-1
  - eastus-2
```

Note

To list VM sizes that support availability zones in a region, use the [`az vm list-skus`](/en-us/cli/azure/vm#az-vm-list-skus) command with the `--location <region> --zone --output table` parameters. Confirm that your selected VM size supports the zones in the `NodePool` requirement.

#### Architecture example

The `kubernetes.io/arch` selector allows you to specify the CPU architecture for your nodes. NAP supports both `amd64` and `arm64` nodes.

```yaml
requirements:
- key: kubernetes.io/arch
  operator: In
  values:
  - amd64
  - arm64
```

#### OS example

The `kubernetes.io/os` selector allows you to specify the operating system for your nodes.

```yaml
requirements:
- key: kubernetes.io/os
  operator: In
  values:
  - linux
```

#### Capacity type example

The `karpenter.sh/capacity-type` selector allows you to specify whether to use Spot or On-demand instances.

Note

NAP prioritizes Spot instances when both Spot and On-demand are specified.

```yaml
requirements:
- key: karpenter.sh/capacity-type
  operator: In
  values:
  - spot
  - on-demand
```

### Node pool limits

By default, NAP attempts to schedule your workloads within the Azure quota you have available. For a dynamic node pool, you can specify aggregate resource limits across all nodes provisioned by that pool. In the following example, `cpu: "1000"` limits the pool to 1,000 vCPU cores, and `memory: 1000Gi` limits it to 1,000 gibibytes of memory:

```yaml
spec:
  # Resource limits constrain the total size of the node pool.
  # Limits prevent Node Auto Provisioning from creating new instances once the limit is exceeded.
  limits:
    cpu: "1000"
    memory: 1000Gi
```

### Node pool weights

When you have multiple node pools defined, you can set a preference for where a workload should be scheduled by defining the relative weight in your node pool definitions. The `weight` field accepts an integer from 1 through 100, and higher values give a node pool higher priority. If you omit `weight`, its value is effectively 0. For example:

```yaml
spec:
  # Priority given to the node pool when the scheduler considers which to select. 
  # Higher weights indicate higher priority when comparing node pools.
  # Specifying no weight is equivalent to specifying a weight of 0.
  weight: 10
```

### Static node pools

Static node pools maintain the fixed number of NAP-provisioned nodes specified in the `replicas` field, regardless of pod demand. To change the node count, explicitly scale the `NodePool`, for example by using [`kubectl scale`](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_scale/) with `nodepool static-node-pool --replicas=7`. The optional `limits.nodes` value constrains explicit scaling and temporary capacity created during node replacement. For static node pools, `nodes` is the only supported field under `limits`; you can't set CPU or memory limits.

```yaml
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: static-node-pool
spec:
  replicas: 5
  template:
    spec:
      requirements:
      - key: karpenter.azure.com/sku-name
        operator: In
        values:
          - Standard_D4s_v3
          - Standard_F8s_v2
      - key: topology.kubernetes.io/zone
        operator: In
        values:
          - eastus-1
          - eastus-2
          - eastus-3
  limits:
    nodes: 10
```

Note

For static node pools, you can set only `nodes` in the `limits` field. You can't set resource limits or `weight`, and disruption consolidation doesn't apply. After you create a `NodePool`, you can't switch it between static and dynamic modes by adding or removing the `replicas` field.