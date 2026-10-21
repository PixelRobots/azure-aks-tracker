---
layout: Conceptual
title: Use GPUs for Windows node pools on Azure Kubernetes Service (AKS) (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-windows-gpu
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
description: Learn how to use Windows GPUs for high performance compute or graphics-intensive workloads on Azure Kubernetes Service (AKS).
ms.topic: how-to
ms.custom: devx-track-azurecli, aks-windows
ms.date: 2024-03-18T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: e22cb563-b68c-9bb4-6c50-ebbb08f217c9
document_version_independent_id: d2117333-4a70-b009-72cd-ca091770b680
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-windows-gpu.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/use-windows-gpu
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-windows-gpu.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
platformId: 263ca03d-237a-1787-3dc1-93a9253f2415
---

# Use GPUs for Windows node pools on Azure Kubernetes Service (AKS) (preview) - Azure Kubernetes Service | Microsoft Learn

Graphical processing units (GPUs) are often used for compute-intensive workloads, such as graphics and visualization workloads. AKS supports GPU-enabled Windows and [Linux](gpu-cluster) node pools to run compute-intensive Kubernetes workloads.

This article helps you provision Windows nodes with schedulable GPUs on new and existing AKS clusters (preview).

## Supported GPU-enabled virtual machines (VMs)

To view supported GPU-enabled VMs, see [GPU-optimized VM sizes in Azure](/en-us/azure/virtual-machines/sizes-gpu). For AKS node pools, we recommend a minimum size of *Standard\_NC6s\_v3*. The NVv4 series (based on AMD GPUs) aren't supported on AKS.

Note

GPU-enabled VMs contain specialized hardware subject to higher pricing and region availability. For more information, see the [pricing](https://azure.microsoft.com/pricing/) tool and [region availability](https://azure.microsoft.com/global-infrastructure/services/).

## Limitations

- Updating an existing Windows node pool to add GPU isn't supported.
- Not supported on Kubernetes version 1.28 and below.

## Before you begin

- This article assumes you have an existing AKS cluster. If you don't have a cluster, create one using the [Azure CLI](learn/quick-windows-container-deploy-cli), [Azure PowerShell](learn/quick-windows-container-deploy-powershell), or the [Azure portal](learn/quick-windows-container-deploy-portal).
- You need the Azure CLI version 2.72.2 or later installed and configured to use the `--gpu-driver` field with the `az aks nodepool add` command. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- If you have the `aks-preview` Azure CLI extension installed, please update the version to 18.0.0b2 or later.

## Get the credentials for your cluster

- Get the credentials for your AKS cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command. The following example command gets the credentials for the *myAKSCluster* in the *myResourceGroup* resource group:

    ```azurecli
    az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
    ```

## Using Windows GPU with automatic driver installation

Using NVIDIA GPUs involves the installation of various NVIDIA software components such as the [DirectX device plugin for Kubernetes](https://github.com/aarnaud/k8s-directx-device-plugin), GPU driver installation, and more. When you create a Windows node pool with a supported GPU-enabled VM, these components and the appropriate NVIDIA CUDA or GRID drivers are installed. For NC and ND series VM sizes, the CUDA driver is installed. For NV series VM sizes, the GRID driver is installed.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

### Install the `aks-preview` Azure CLI extension

- Register or update the aks-preview extension using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) or [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command.

    ```azurecli
    # Register the aks-preview extension
    az extension add --name aks-preview
    
    # Update the aks-preview extension
    az extension update --name aks-preview
    ```

### Register the `WindowsGPUPreview` feature flag

1. Register the `WindowsGPUPreview` feature flag using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

    ```azurecli
    az feature register --namespace "Microsoft.ContainerService" --name "WindowsGPUPreview"
    ```

    It takes a few minutes for the status to show *Registered*.
2. Verify the registration status using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command.

    ```azurecli
    az feature show --namespace "Microsoft.ContainerService" --name "WindowsGPUPreview"
    ```
3. When the status reflects *Registered*, refresh the registration of the *Microsoft.ContainerService* resource provider using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace Microsoft.ContainerService
    ```

### Create a Windows GPU-enabled node pool (preview)

To create a Windows GPU-enabled node pool, you need to use a supported GPU-enabled VM size and specify the `os-type` as `Windows`. The default Windows `os-sku` is `Windows2022`, but all Windows `os-sku` options are supported.

1. Create a Windows GPU-enabled node pool using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command.

    ```azurecli
    az aks nodepool add \
       --resource-group myResourceGroup \
       --cluster-name myAKSCluster \
       --name gpunp \
       --node-count 1 \
       --os-type Windows \
       --kubernetes-version 1.29.0 \
       --node-vm-size Standard_NC6s_v3
    ```
2. Check that your GPUs are schedulable.
3. Once you confirm that your GPUs are schedulable, you can run your GPU workload.

#### Specify GPU Driver Type (preview)

By default, AKS specifies a default GPU driver type for each supported GPU-enabled VM. Because workload and driver compatibility are important for functioning GPU workloads, you can specify the driver type for your Windows GPU node. This feature is not supported for Linux GPU node pools.

When creating a Windows agent pool with GPU support, you have the option to specify the type of GPU driver using the `--driver-type` flag.

The available options are:

- GRID: For applications requiring virtualization support.
- CUDA: Optimized for computational tasks in scientific computing and data-intensive applications.

Note

When you set the `--driver-type` flag, you assume responsibility for ensuring that the selected driver type is compatible with the specific VM size and configuration of your node pool. While AKS attempts to validate compatibility, there are scenarios where the node pool creation might fail due to incompatibilities between the specified driver type and the underlying VM or hardware.

To create a Windows GPU-enabled node pool with a specific GPU Driver type, use the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command.

```azurecli
az aks nodepool add \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name gpunp \
    --node-count 1 \
    --os-type Windows \
    --kubernetes-version 1.29.0 \
    --node-vm-size Standard_NC6s_v3 \
    --driver-type GRID
```

For example, the above command creates a GPU-enabled node pool using the `GRID` GPU driver type. Selecting this driver type overrides the default of `CUDA` driver type for NC series VM skus.

## Using Windows GPU with manual driver installation

When creating a Windows node pool with N-series (NVIDIA GPU) VM sizes in AKS, the GPU driver and Kubernetes DirectX device plugin are installed automatically. To bypass this automatic installation, use the following steps:

1. Skip GPU driver installation by setting the configuration `--gpu-driver none` at node pool create time.
2. Manual installation of the Kubernetes DirectX device plugin.

### Skip GPU driver installation

AKS has automatic GPU driver installation enabled by default. In some cases, such as installing your own drivers, you may want to skip GPU driver installation.

Important

Starting on **August 14, 2025**, Azure Kubernetes Service (AKS) no longer supports the `--skip-gpu-driver-install` node pool tag. After this date, you'll be unable to provision GPU-enabled node pools using this tag to bypass automatic GPU driver installation. You can achieve the same behavior by setting the `--gpu-driver` field to `none`. For more information on this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4925) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=496440). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

1. Create a node pool using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command and setting the API field `--gpu-driver` to `none` to skip automatic GPU driver installation.

    ```azurecli
    az aks nodepool add \
        --resource-group myResourceGroup \
        --cluster-name myAKSCluster \
        --name gpunp \
        --node-count 1 \
        --os-type windows \
        --os-sku windows2022 \
        --gpu-driver none
    ```

Note

If the `--node-vm-size` that you're using isn't yet onboarded on AKS, you can't use GPUs and the `--gpu-driver` field doesn't work.

### Manually install the Kubernetes DirectX device plugin

You can deploy a DaemonSet for the Kubernetes DirectX device plugin, which runs a pod on each node to provide the required drivers for the GPUs.

- Add a node pool to your cluster using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command.

    ```azurecli
    az aks nodepool add \
        --resource-group myResourceGroup \
        --cluster-name myAKSCluster \
        --name gpunp \
        --node-count 1 \
        --os-type windows \
        --os-sku windows2022
    ```

## Create a namespace and deploy the Kubernetes DirectX device plugin

1. Create a namespace using the [`kubectl create namespace`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#create) command.

    ```bash
    kubectl create namespace gpu-resources
    ```
2. Create a file named *k8s-directx-device-plugin.yaml* and paste the following YAML manifest provided as part of the [NVIDIA device plugin for Kubernetes project](https://github.com/NVIDIA/k8s-device-plugin):

    ```yaml
    apiVersion: apps/v1
    kind: DaemonSet
    metadata:
      name: nvidia-device-plugin-daemonset
      namespace: gpu-resources
    spec:
      selector:
        matchLabels:
          name: nvidia-device-plugin-ds
      updateStrategy:
        type: RollingUpdate
      template:
        metadata:
          # Mark this pod as a critical add-on; when enabled, the critical add-on scheduler
          # reserves resources for critical add-on pods so that they can be rescheduled after
          # a failure.  This annotation works in tandem with the toleration below.
          annotations:
            scheduler.alpha.kubernetes.io/critical-pod: ""
          labels:
            name: nvidia-device-plugin-ds
        spec:
          tolerations:
          # Allow this pod to be rescheduled while the node is in "critical add-ons only" mode.
          # This, along with the annotation above marks this pod as a critical add-on.
          - key: CriticalAddonsOnly
            operator: Exists
          - key: nvidia.com/gpu
            operator: Exists
            effect: NoSchedule
          - key: "sku"
            operator: "Equal"
            value: "gpu"
            effect: "NoSchedule"
          containers:
          - image: mcr.microsoft.com/aks/aks-windows-gpu-device-plugin:0.0.17
            name: nvidia-device-plugin-ctr
            securityContext:
              allowPrivilegeEscalation: false
              capabilities:
                drop: ["ALL"]
            volumeMounts:
              - name: device-plugin
                mountPath: /var/lib/kubelet/device-plugins
          volumes:
            - name: device-plugin
              hostPath:
                path: /var/lib/kubelet/device-plugins
    ```
3. Create the DaemonSet and confirm the NVIDIA device plugin is created successfully using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command.

    ```bash
    kubectl apply -f nvidia-device-plugin-ds.yaml
    ```
4. Now that you successfully installed the NVIDIA device plugin, you can check that your GPUs are schedulable.

## Confirm that GPUs are schedulable

After creating your cluster, confirm that GPUs are schedulable in Kubernetes.

1. List the nodes in your cluster using the [`kubectl get nodes`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command.

    ```console
    kubectl get nodes
    ```

    Your output should look similar to the following example output:

    ```console
    NAME                   STATUS   ROLES   AGE   VERSION
    aks-gpunp-28993262-0   Ready    agent   13m   v1.20.7
    ```
2. Confirm the GPUs are schedulable using the [`kubectl describe node`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#describe) command.

    ```console
    kubectl describe node aks-gpunp-28993262-0
    ```

    Under the *Capacity* section, the GPU should list as `microsoft.com/directx: 1`. Your output should look similar to the following condensed example output:

    ```output
    Capacity:
    [...]
     microsoft.com.directx/gpu:                 1
    [...]
    ```

## Clean up resources

- Remove the associated Kubernetes objects you created in this article using the [`kubectl delete job`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#delete) command.

    ```console
    kubectl delete jobs windows-gpu-workload
    ```