---
layout: Conceptual
title: Create an AKS-managed GPU node pool on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/aks-managed-gpu-nodes
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
description: Learn how to provision a fully managed GPU node pool on your new or existing cluster on Azure Kubernetes Service (AKS).
ms.topic: how-to
ms.custom: devx-track-azurecli
ms.subservice: aks-developer
ms.date: 2026-07-02T00:00:00.0000000Z
author: sdesai345
ms.author: sachidesai
ai-usage: ai-assisted
locale: en-us
document_id: d5af5dcc-13c0-ecd9-80b0-efe2aaab6a83
document_version_independent_id: 349c6441-22ef-706f-5b96-7760ea82ef5b
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/aks-managed-gpu-nodes.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/aks-managed-gpu-nodes
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/aks-managed-gpu-nodes.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: d72641ca-0174-3da9-1a07-82b0ce907212
---

# Create an AKS-managed GPU node pool on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Running NVIDIA GPU workloads on Azure Kubernetes Service (AKS) traditionally requires you to install and maintain the NVIDIA GPU driver, Kubernetes device plugin, and a GPU metrics exporter on each GPU node. These components enable GPU scheduling, container-level GPU access, and telemetry, but installing them manually or through the [NVIDIA GPU Operator](nvidia-gpu-operator) adds operational overhead.

By using fully managed GPU nodes (preview), AKS installs and maintains the NVIDIA GPU driver, device plugin, and Data Center GPU Manager [(DCGM) metrics exporter](https://github.com/NVIDIA/dcgm-exporter/tree/main) for you. GPU node pool creation becomes a single step, and GPU capacity behaves like any other AKS node pool. You can use managed GPU nodes with manually created GPU node pools and with node auto-provisioning (NAP), including AKS Automatic clusters.

You configure a managed GPU node pool through two fields under `gpuProfile.nvidia`:

- `managementMode` (`Managed` or `Unmanaged`) controls whether AKS installs the full managed GPU stack (driver, device plugin, and DCGM metrics exporter) or the driver only. The default is `Unmanaged`.
- `migStrategy` (`None`, `Single`, or `Mixed`) sets the Multi-Instance GPU (MIG) strategy for supported GPU SKUs such as A100 and H100. The default is `None`.

In this article, you provision a managed GPU node pool, optionally enable MIG, verify the stack, and run a sample GPU workload.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Before you begin

- This article assumes you have an existing AKS cluster. If you don't have a cluster, create one using the [Azure CLI](learn/quick-kubernetes-deploy-cli), [Azure PowerShell](learn/quick-kubernetes-deploy-powershell), or the [Azure portal](learn/quick-kubernetes-deploy-portal).
- You need the Azure CLI version 2.85.0 or later installed. To find the version, run `az --version`. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- You need to install and upgrade to latest version of the `aks-preview` extension. Version 19.0.0b29 or later is required.
- Get the credentials for your AKS cluster with [`az aks get-credentials`](/en-us/cli/azure/aks#az_aks_get_credentials) before running the `kubectl` examples in this article.

## Managed GPU components

A managed GPU node pool can include the following components on every node:

| Component | What it does | What AKS manages |
| --- | --- | --- |
| **NVIDIA GPU driver** | Kernel modules and user-space libraries that let the OS and containers talk to the GPU hardware. | Driver version selection, installation at node provisioning, and reinstallation after node image upgrades. |
| **NVIDIA Kubernetes device plugin** | DaemonSet-equivalent that advertises GPU resources (`nvidia.com/gpu`, `nvidia.com/mig-*`) to the kubelet so pods can request them. | Deployment, configuration (including MIG strategy), and lifecycle on each GPU node. |
| **NVIDIA DCGM and DCGM metrics exporter** | [Data Center GPU Manager](https://github.com/NVIDIA/dcgm-exporter/tree/main) collects GPU health and utilization data and exposes Prometheus metrics (for example, `DCGM_FI_DEV_GPU_UTIL`, `DCGM_FI_DEV_GPU_TEMP`) on port `19400`. | Installation, service enablement, and the `kubernetes.azure.com/dcgm-exporter=enabled` node label used to scrape metrics. |
| **GPU health signals** | NPD signals that surface GPU-specific node conditions such as `UnhealthyNvidiaDevicePlugin` and `UnhealthyNvidiaDCGMServices`. | NPD monitoring and condition reporting on GPU nodes. |

### Install profiles

Two `gpuProfile` fields decide which of those components AKS installs:

- `gpuProfile.driver` (`Install` or `None`): whether AKS installs the NVIDIA GPU driver.
- `gpuProfile.nvidia.managementMode` (`Managed` or `Unmanaged`): whether AKS also installs the Kubernetes-facing GPU stack on top of the driver.

Together, they produce three install profiles:

| Install profile | CLI flags | What AKS installs and manages |
| --- | --- | --- |
| **Full managed stack** | `--enable-managed-gpu=true` (or neither flag) | All four components above: driver, device plugin, DCGM metrics exporter, and GPU health monitoring in NPD. |
| **Driver only** (default) | `--enable-managed-gpu=false` | NVIDIA GPU driver only. You install and manage the device plugin, metrics exporter, and health monitoring yourself (for example, with the [NVIDIA GPU Operator](nvidia-gpu-operator)). |
| **None (BYO)** | `--enable-managed-gpu=false --gpu-driver None` | Nothing. AKS doesn't install any of the four components. You own the full stack. See Bring your own GPU driver. |

### Defaults and overrides

- **Defaults**: If you don't pass `--enable-managed-gpu` or `--gpu-driver`, AKS applies the **Driver only** profile on the node pool created with an **NVIDIA** GPU-enabled VM size.
- **Override**: `managementMode: Managed` requires the driver, so `--gpu-driver None` is ignored when `--enable-managed-gpu=true` and the driver is still installed. To skip the driver, set both `--enable-managed-gpu=false` and `--gpu-driver None`.
- **Immutability**: `managementMode`, `migStrategy`, and `driver` are all fixed at creation time. To change profile, create a new node pool.

### Install the `aks-preview` CLI extension

Install the aks-preview CLI extension by using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command.

```azurecli
az extension add --name aks-preview
```

Update the extension to ensure you have the latest version installed by using the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command.

```azurecli
az extension update --name aks-preview
```

### Register the `ManagedGPUExperiencePreview` feature flag

Register the `ManagedGPUExperiencePreview` feature flag in your subscription using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

```azurecli
az feature register --namespace Microsoft.ContainerService --name ManagedGPUExperiencePreview
```

## Limitations

- This feature currently supports [NVIDIA GPU-enabled virtual machine (VM) sizes](/en-us/azure/virtual-machines/sizes-gpu) only.
- Updating a general-purpose node pool to add a GPU VM size isn't supported on AKS.
- Windows node pools aren't supported with this feature, because GPU metrics aren't supported. When you create Windows GPU node pools, AKS automatically installs and manages the drivers and DirectX device plugin. For more information, see the [AKS Windows GPU documentation](use-windows-gpu).
- Migrating your existing [multi-instance GPU](gpu-multi-instance) node pools to use this feature isn't supported.
- In-place upgrades from an existing NVIDIA GPU node pool to a managed GPU node pool aren't supported. To migrate, cordon and drain your existing GPU nodes, then redeploy your workloads to a new GPU node pool created with `--enable-managed-gpu=true`. For more information, see [Resize node pools on AKS](resize-node-pool).
- The `managementMode`, `migStrategy`, and `driver` fields under `gpuProfile` are immutable after node pool creation. To change these values, create a new node pool.

Note

GPU-enabled VMs contain specialized hardware subject to higher pricing and region availability. For more information, see the [pricing](https://azure.microsoft.com/pricing/) tool and [region availability](https://azure.microsoft.com/global-infrastructure/services/).

## Create an AKS-managed GPU node pool (preview)

Add a managed GPU node pool to an existing AKS cluster by passing `--enable-managed-gpu=true` to [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az_aks_nodepool_add). AKS sets `gpuProfile.nvidia.managementMode` to `Managed` and installs the GPU driver, device plugin, and DCGM metrics exporter automatically.

For AKS Automatic or AKS Standard clusters that use NAP, configure the managed GPU stack on the `AKSNodeClass` instead of using `az aks nodepool add`.

# [Ubuntu Linux node pool (default SKU)](#tab/add-ubuntu-gpu-node-pool)
To use the default Ubuntu operating system (OS) SKU, you create the node pool without specifying an OS SKU. The node pool is configured for the default operating system based on the Kubernetes version of the cluster.

1. Add a node pool to your cluster using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az_aks_nodepool_add) command with the `--enable-managed-gpu=true` flag.

    ```azurecli
    az aks nodepool add \
        --resource-group myResourceGroup \
        --cluster-name myAKSCluster \
        --name gpunp \
        --node-count 1 \
        --node-vm-size Standard_NC4as_T4_v3 \
        --node-taints sku=gpu:NoSchedule \
        --enable-managed-gpu=true
    ```
2. Confirm that the managed NVIDIA GPU software components are installed successfully:

    ```azurecli
    az aks nodepool show \
        --resource-group myResourceGroup \
        --cluster-name myAKSCluster \
        --name gpunp
    ```

    Your output should include the following values:

    ```output
    ...
    "gpuProfile": {
        "driver": "Install",
        "driverType": "",
        "nvidia": {
            "managementMode": "Managed",
            "migStrategy": null
        }
    },
    ...
    ```

# [Azure Linux node pool](#tab/add-azure-linux-gpu-node-pool)
To use Azure Linux, you specify the OS SKU by setting `--os-sku` to `AzureLinux` during node pool creation. The `os-type` is set to `Linux` by default.

1. Add a node pool to your cluster using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az_aks_nodepool_add) command with the `--os-sku` flag set to `AzureLinux` and `--enable-managed-gpu=true`.

    ```azurecli
    az aks nodepool add \
        --resource-group myResourceGroup \
        --cluster-name myAKSCluster \
        --name gpunp \
        --node-count 1 \
        --os-sku AzureLinux \
        --node-vm-size Standard_NC4as_T4_v3 \
        --node-taints sku=gpu:NoSchedule \
        --enable-managed-gpu=true
    ```
2. Confirm that the managed NVIDIA GPU software components are installed successfully:

    ```azurecli
    az aks nodepool show \
        --resource-group myResourceGroup \
        --cluster-name myAKSCluster \
        --name gpunp
    ```

    Your output should include the following values:

    ```output
    ...
    "gpuProfile": {
        "driver": "Install",
        "driverType": "",
        "nvidia": {
            "managementMode": "Managed",
            "migStrategy": null
        }
    },
    ...
    ```

# [Node auto-provisioning node pool](#tab/nap-managed-node)
To use managed GPU nodes with node auto-provisioning (NAP), add the `EnableManagedGPUExperience: "true"` tag to your `AKSNodeClass` custom resource definition (CRD). Then create a `NodePool` that selects NVIDIA GPU-enabled VM sizes. This configuration applies to AKS Automatic clusters, where NAP is enabled by default, and to AKS Standard clusters with NAP enabled.

To learn more about configurable Azure-specific settings, see [Configure AKSNodeClass resources for NAP](node-auto-provisioning-aksnodeclass).

1. Create an `AKSNodeClass` CRD and set `mode: Driver` and `nvidia.managementMode: Managed` in the `spec.gpu` field.

    ```yaml
    apiVersion: karpenter.azure.com/v1beta1
    kind: AKSNodeClass
    metadata:
      name: managed-gpu-class
    ```

spec: gpu: mode: Driver nvidia: managementMode: Managed

```

1. Create a `NodePool` CRD that allows NAP to deploy NVIDIA GPU SKUs.

```yaml
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: managed-gpu-np
spec:
  disruption:
    consolidationPolicy: WhenEmptyOrUnderutilized
    consolidateAfter: 30s
  template:
    spec:
      nodeClassRef:
        group: karpenter.azure.com
        kind: AKSNodeClass
        name: managed-gpu-class
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]
        - key: kubernetes.io/os
          operator: In
          values: ["linux"]
        - key: karpenter.azure.com/sku-family
          operator: In
          values: ["N"]
        - key: karpenter.azure.com/sku-gpu-manufacturer
          operator: In
          values: ["nvidia"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot", "on-demand"]
```

1. Deploy the `AKSNodeClass` and `NodePool` CRDs.

    ```bash
    kubectl apply -f managed-gpu-class.yaml
    kubectl apply -f managed-gpu-np.yaml
    ```
2. Deploy a sample workload that requests GPU resources. NAP provisions a matching GPU node when the pod is pending.
3. Confirm that the `AKSNodeClass` and `NodePool` resources are deployed and the managed GPU label is applied to the NAP-provisioned node.

    ```bash
    kubectl get aksnodeclasses.karpenter.azure.com,nodepools.karpenter.sh
    kubectl get nodes -L kubernetes.azure.com/dcgm-exporter
    ```

---

## Create a managed Multi-Instance GPU (MIG) node pool (preview)

For GPU SKUs that support Multi-Instance GPU (such as A100 and H100), configure a MIG strategy at node pool creation with the `--gpu-mig-strategy` flag. The strategy controls how MIG partitions are exposed to Kubernetes:

- `Single`: All MIG instances are aggregated under the standard `nvidia.com/gpu` resource.
- `Mixed`: Each MIG profile is exposed as a separate resource, such as `nvidia.com/mig-1g.10gb`.
- `None` (default): MIG isn't configured.

The `migStrategy` field is immutable after the node pool is created.

For background on MIG partitioning, supported VM sizes, and GPU instance profiles, see [Create a multi-instance GPU node pool in AKS](gpu-multi-instance) and [NVIDIA Multi-Instance GPU](https://docs.nvidia.com/datacenter/tesla/mig-user-guide/).

# [Single strategy](#tab/mig-single)
```azurecli
az aks nodepool add \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name mignp \
    --node-count 1 \
    --node-vm-size Standard_NC24ads_A100_v4 \
    --node-taints sku=gpu:NoSchedule \
    --enable-managed-gpu=true \
    --gpu-instance-profile MIG1g \
    --gpu-mig-strategy Single
```

With this configuration, pods request GPU resources using the standard `nvidia.com/gpu` resource name.

# [Mixed strategy](#tab/mig-mixed)
```azurecli
az aks nodepool add \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name mignp \
    --node-count 1 \
    --node-vm-size Standard_NC24ads_A100_v4 \
    --node-taints sku=gpu:NoSchedule \
    --enable-managed-gpu=true \
    --gpu-instance-profile MIG1g \
    --gpu-mig-strategy Mixed
```

With this configuration, pods request specific MIG partitions, for example `nvidia.com/mig-1g.10gb: 1`.

---

## Verify the managed GPU node pool (preview)

After the node pool is ready, run the following checks to confirm that the full managed stack is installed and healthy.

1. Verify GPU-specific node conditions from Node Problem Detector (NPD):

    ```bash
    GPU_NODE=$(kubectl get nodes -l agentpool=gpunp -o jsonpath='{.items[0].metadata.name}')
    kubectl describe node $GPU_NODE
    ```

    On a managed GPU node, the following conditions should both report `False`:

    | Condition | Status | Reason |
    | --- | --- | --- |
    | `UnhealthyNvidiaDevicePlugin` | `False` | `HealthyNvidiaDevicePlugin` |
    | `UnhealthyNvidiaDCGMServices` | `False` | `HealthyNvidiaDCGMServices` |
2. Verify that the managed GPU label is present on the node:

    ```bash
    kubectl get node $GPU_NODE -o jsonpath='{.metadata.labels.kubernetes\.azure\.com/dcgm-exporter}'
    ```

    Expected output: `enabled`.
3. Verify that GPU resources are advertised in the node's allocatable resources:

    ```bash
    kubectl get node $GPU_NODE -o jsonpath='{.status.allocatable}'
    ```

    For a non-MIG node pool, the output includes `"nvidia.com/gpu": "1"` (or more, depending on the SKU). For a MIG `Mixed` node pool, the output includes MIG-specific resources such as `"nvidia.com/mig-1g.10gb": "7"`.
4. Run a sample workload to confirm GPU access from within a container:

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: managed-gpu-test
    spec:
      restartPolicy: Never
      tolerations:
        - key: "sku"
          operator: "Equal"
          value: "gpu"
          effect: "NoSchedule"
      containers:
      - name: gpu-test
        image: mcr.microsoft.com/azuredocs/samples-tf-mnist-demo:gpu
        command: ["nvidia-smi"]
        resources:
          limits:
            nvidia.com/gpu: 1
    ```

    View the pod logs to see `nvidia-smi` output showing the GPU device, driver version, and CUDA version:

    ```bash
    kubectl logs managed-gpu-test
    ```

## Scale a managed GPU node pool (preview)

Scale a managed GPU node pool manually with [`az aks nodepool scale`](/en-us/cli/azure/aks/nodepool#az_aks_nodepool_scale). New nodes install the full managed GPU stack.

```azurecli
az aks nodepool scale \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name gpunp \
    --node-count 2
```

## Alternative install profiles

If the **Full managed stack** profile isn't the right fit, AKS supports two alternative profiles on GPU node pools.

# [Driver only (preview)](#tab/driver-only)
Use this profile when you want AKS to install and maintain the NVIDIA GPU driver, but you plan to deploy the device plugin and metrics exporter yourself (for example, with the [NVIDIA GPU Operator](nvidia-gpu-operator)). Set `--enable-managed-gpu=false`:

```azurecli
az aks nodepool add \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name gpunp \
    --node-count 1 \
    --node-vm-size Standard_NC4as_T4_v3 \
    --node-taints sku=gpu:NoSchedule \
    --enable-managed-gpu=false
```

With this configuration:

- AKS installs and manages the NVIDIA GPU driver (`gpuProfile.driver` is `Install`).
- AKS doesn't install a device plugin, DCGM metrics exporter, or GPU health rules. `gpuProfile.nvidia` is `null`.
- No `nvidia.com/gpu` resource is advertised until you deploy a device plugin.

# [Bring your own GPU driver](#tab/byo-driver)
Use this profile when you want to install the NVIDIA driver yourself (for example, to run the [NVIDIA GPU Operator](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html)). Create the node pool with `--enable-managed-gpu=false --gpu-driver None`:

```azurecli
az aks nodepool add \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name gpunp \
    --node-count 1 \
    --node-vm-size Standard_NC4as_T4_v3 \
    --node-taints sku=gpu:NoSchedule \
    --enable-managed-gpu=false \
    --gpu-driver None
```

In this configuration, AKS installs no GPU software components: no driver, no device plugin, and no metrics exporter. Microsoft **doesn't support or manage** NVIDIA drivers or any other GPU components on these nodes. For more information, see [Skip GPU driver installation](use-nvidia-gpu#skip-gpu-driver-installation).

---