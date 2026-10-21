---
layout: Conceptual
title: Use GPUs on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-nvidia-gpu
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
description: Learn how to use GPUs for high performance compute or graphics-intensive workloads on Azure Kubernetes Service (AKS).
ms.topic: how-to
ms.custom: devx-track-azurecli
ms.subservice: aks-developer
ms.date: 2026-07-02T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 2c442dd2-de8f-4a41-465b-6f803b3290e5
document_version_independent_id: 7305e1d6-c1f9-8303-a089-b0b8c33cf361
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-nvidia-gpu.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/use-nvidia-gpu
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-nvidia-gpu.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 341a627d-73eb-3740-5295-1552eb5d9e21
---

# Use GPUs on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Graphical processing units (GPUs) are often used for compute-intensive workloads, such as graphics and visualization workloads. AKS supports GPU-enabled Linux node pools to run compute-intensive Kubernetes workloads.

This article helps you provision nodes with schedulable GPUs on new and existing AKS clusters.

Important

Starting on **November 30, 2025**, Azure Kubernetes Service (AKS) no longer supports or provides security updates for Azure Linux 2.0. The Azure Linux 2.0 node image is frozen at the `202512.06.0` release. Beginning on **October 31, 2026**, node images will be removed, and you'll be unable to scale your node pools. Migrate to a supported Azure Linux version by [upgrading your node pools](/en-us/azure/aks/upgrade-aks-cluster) to a supported Kubernetes version or migrating to [osSku AzureLinux3](/en-us/azure/aks/upgrade-os-version). For more information, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4988) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=500645). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

## Choose an approach to run GPUs on AKS

AKS provides two approaches to run NVIDIA GPU workloads. Select the approach that aligns with the level of control you require over the GPU software stack and the amount of management you want AKS to perform on your behalf.

| Approach | Recommended for | Components AKS manages | Components you manage |
| --- | --- | --- | --- |
| **AKS-managed GPU node pools** (recommended) | Most scenarios that require GPU capacity to operate consistently with other AKS node pools. | NVIDIA GPU driver, Kubernetes device plugin, GPU metrics exporter, and GPU health signals. | Your GPU workloads. |
| **Self-managed GPU setup** | Scenarios that require granular control over GPU driver and device plugin versions, or that standardize on the [NVIDIA GPU Operator](nvidia-gpu-operator). | The NVIDIA GPU driver only, by default. | Kubernetes device plugin, GPU metrics exporter, and GPU health tooling. |

Tip

Microsoft recommends **[AKS-managed GPU node pools](aks-managed-gpu-nodes)** for most scenarios. AKS installs and maintains the NVIDIA driver, device plugin, and DCGM metrics exporter on your behalf, which reduces operational overhead and simplifies GPU node pool creation to a single step. Use the self-managed approach described in this article only when you require direct control over the device plugin or other GPU software components.

The remainder of this article describes the **self-managed** GPU setup. For the recommended managed experience, see [Create an AKS-managed GPU node pool](aks-managed-gpu-nodes).

## Supported GPU-enabled VMs

To view the available GPU-enabled VMs, see [GPU-optimized VM sizes in Azure](/en-us/azure/virtual-machines/sizes-gpu). If a GPU VM size is not in our list of supported VM sizes, AKS does not install the necessary GPU software components or provide support. AKS allows the use of unsupported GPU VM sizes after skipping the automatic GPU driver installation.

Check available and supported VM sizes using the [`az vm list-skus`](/en-us/cli/azure/vm) command.

```azurecli
az vm list-skus --location <your-location> --output table
```

For AKS node pools, use a minimum size of `Standard_NC4as_T4_v3`. The NVv4 series (based on AMD GPUs) isn't supported on AKS.

Note

GPU-enabled VMs contain specialized hardware subject to higher pricing and region availability. For more information, see the [pricing](https://azure.microsoft.com/pricing/) tool and [region availability](https://azure.microsoft.com/global-infrastructure/services/).

## Limitations

- If you're using an Azure Linux GPU-enabled node pool, automatic security patches aren't applied. Refer to your current AKS API version for the default behavior of node OS upgrade channel.
- [Flatcar Container Linux for AKS](flatcar-container-linux-for-aks) isn't supported with NVIDIA GPU on AKS.
- [Azure Linux with OS Guard for AKS](use-azure-linux-os-guard) isn't supported with NVIDIA GPU on AKS.

Note

For AKS API version 2023-06-01 or later, the default channel for node OS upgrade is *NodeImage*. For previous versions, the default channel is *None*. To learn more, see [auto-upgrade](auto-upgrade-node-image).

- Updating an existing node pool to add GPU VM size is not supported on AKS.

## Before you begin

- This article assumes you have an existing AKS cluster. If you don't have a cluster, create one using the [Azure CLI](learn/quick-kubernetes-deploy-cli), [Azure PowerShell](learn/quick-kubernetes-deploy-powershell), or the [Azure portal](learn/quick-kubernetes-deploy-portal).
- You need the Azure CLI version 2.72.2 or later installed to set the `--gpu-driver` field. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- If you have the `aks-preview` Azure CLI extension installed, please update the version to 18.0.0b2 or later.

## Get the credentials for your cluster

Get the credentials for your AKS cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command. The following example command gets the credentials for the *myAKSCluster* in the *myResourceGroup* resource group:

```azurecli
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
```

## Self-managed GPU setup

Tip

For the recommended managed experience, see [Create an AKS-managed GPU node pool](aks-managed-gpu-nodes). AKS installs and maintains the driver, device plugin, and DCGM metrics exporter on your behalf. Proceed with the following steps only when you require direct control over the device plugin or other GPU software components.

The self-managed GPU setup requires you to install several NVIDIA software components, including the [NVIDIA device plugin for Kubernetes](https://github.com/NVIDIA/k8s-device-plugin?tab=readme-ov-file) and the GPU driver.

### NVIDIA device plugin installation

You need to install the NVIDIA device plugin when using GPUs in this self-managed setup. In some cases, the installation is handled automatically, such as when using the [NVIDIA GPU Operator](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html). Alternatively, you can manually install the NVIDIA device plugin.

#### Manually install the NVIDIA device plugin

You can deploy a DaemonSet for the NVIDIA device plugin, which runs a pod on each node to provide the required drivers for the GPUs. This is the recommended approach when using GPU-enabled node pools for Azure Linux.

# [Ubuntu Linux node pool (default SKU)](#tab/add-ubuntu-gpu-node-pool)
To use the default OS SKU, you create the node pool without specifying an OS SKU. The node pool is configured for the default operating system based on the Kubernetes version of the cluster.

Add a node pool to your cluster using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command.

```azurecli
az aks nodepool add \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name gpunp \
    --node-count 1 \
    --node-vm-size Standard_NC4as_T4_v3 \
    --node-taints sku=gpu:NoSchedule \
    --enable-cluster-autoscaler \
    --min-count 1 \
    --max-count 3
```

This command adds a node pool named *gpunp* to *myAKSCluster* in *myResourceGroup* and uses parameters to configure the following node pool settings:

- `--node-vm-size`: Sets the VM size for the node in the node pool to *Standard\_NC4as\_T4\_v3*.
- `--node-taints`: Specifies a *sku=gpu:NoSchedule* taint on the node pool.
- `--enable-cluster-autoscaler`: Enables the cluster autoscaler.
- `--min-count`: Configures the cluster autoscaler to maintain a minimum of one node in the node pool.
- `--max-count`: Configures the cluster autoscaler to maintain a maximum of three nodes in the node pool.

Note

Taints and VM sizes can only be set for node pools during node pool creation, but you can update autoscaler settings at any time.

# [Azure Linux node pool](#tab/add-azure-linux-gpu-node-pool)
To use Azure Linux, you specify the OS SKU by setting `os-sku` to `AzureLinux` during node pool creation. The `os-type` is set to `Linux` by default.

Add a node pool to your cluster using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command with the `--os-sku` flag set to `AzureLinux`.

```azurecli
az aks nodepool add \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name gpunp \
    --node-count 1 \
    --os-sku AzureLinux \
    --node-vm-size Standard_NC4as_T4_v3 \
    --node-taints sku=gpu:NoSchedule \
    --enable-cluster-autoscaler \
    --min-count 1 \
    --max-count 3
```

This command adds a node pool named *gpunp* to *myAKSCluster* in *myResourceGroup* and uses parameters to configure the following node pool settings:

- `--node-vm-size`: Sets the VM size for the node in the node pool to *Standard\_NC4as\_T4\_v3*.
- `--node-taints`: Specifies a *sku=gpu:NoSchedule* taint on the node pool.
- `--enable-cluster-autoscaler`: Enables the cluster autoscaler.
- `--min-count`: Configures the cluster autoscaler to maintain a minimum of one node in the node pool.
- `--max-count`: Configures the cluster autoscaler to maintain a maximum of three nodes in the node pool.

Note

You can set taints and VM sizes only during node pool creation, but you can update autoscaler settings at any time.

---

1. Create a namespace using the [`kubectl create namespace`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#create) command.

    ```bash
    kubectl create namespace gpu-resources
    ```
2. Create a file named *nvidia-device-plugin-ds.yaml* and paste the following YAML manifest provided as part of the [NVIDIA device plugin for Kubernetes project](https://github.com/NVIDIA/k8s-device-plugin/blob/4b3d6b0a6613a3672f71ea4719fd8633eaafb4f3/deployments/static/nvidia-device-plugin.yml):

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
          labels:
            name: nvidia-device-plugin-ds
        spec:
          tolerations:
          - key: "sku"
            operator: "Equal"
            value: "gpu"
            effect: "NoSchedule"
          # Mark this pod as a critical add-on; when enabled, the critical add-on
          # scheduler reserves resources for critical add-on pods so that they can
          # be rescheduled after a failure.
          # See https://kubernetes.io/docs/tasks/administer-cluster/guaranteed-scheduling-critical-addon-pods/
          priorityClassName: "system-node-critical"
          containers:
          - image: nvcr.io/nvidia/k8s-device-plugin:v0.18.0
            name: nvidia-device-plugin-ctr
            env:
              - name: FAIL_ON_INIT_ERROR
                value: "false"
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
4. Now that you successfully installed the NVIDIA device plugin, you can check that your GPUs are schedulable and run a GPU workload.

### Skip GPU driver installation

If you want to control the installation of the NVIDIA drivers or use the [NVIDIA GPU Operator](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html), you can skip the default GPU driver installation. Microsoft **doesn't support or manage** the maintenance and compatibility of the NVIDIA drivers as part of the node image deployment.

Important

Starting on **August 14, 2025**, Azure Kubernetes Service (AKS) no longer supports the `--skip-gpu-driver-install` node pool tag. After this date, you'll be unable to provision GPU-enabled node pools using this tag to bypass automatic GPU driver installation. You can achieve the same behavior by setting the `--gpu-driver` field to `none`. For more information on this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4925) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=496440). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

1. Create a node pool using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command and set `--gpu-driver` field to `none` to skip default GPU driver installation.

    ```azurecli
    az aks nodepool add \
        --resource-group myResourceGroup \
        --cluster-name myAKSCluster \
        --name gpunp \
        --node-count 1 \
        --gpu-driver none \
        --node-vm-size Standard_NC4as_T4_v3 \
        --enable-cluster-autoscaler \
        --min-count 1 \
        --max-count 3
    ```

    Setting the `--gpu-driver` API field to `none` during node pool creation skips the automatic GPU driver installation. Any existing nodes aren't changed. You can scale the node pool to zero and then back up to make the change take effect.

    If you get the error `unrecognized arguments: --gpu-driver none` then [update the Azure CLI version](/en-us/cli/azure/update-azure-cli). For more information, see Before you begin.
2. You can optionally install the NVIDIA GPU Operator following [these steps](nvidia-gpu-operator).

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

    Under the *Capacity* section, the GPU should list as `nvidia.com/gpu:  1`. Your output should look similar to the following condensed example output:

    ```console
    Name:               aks-gpunp-28993262-0
    Roles:              agent
    Labels:             accelerator=nvidia
    
    [...]
    
    Capacity:
    [...]
     nvidia.com/gpu:                 1
    [...]
    ```

## Run a GPU-enabled workload

To see the GPU in action, you can schedule a GPU-enabled workload with the appropriate resource request. In this example, we'll run a [Tensorflow](https://www.tensorflow.org/) job against the [MNIST dataset](http://yann.lecun.com/exdb/mnist/).

1. Create a file named *samples-tf-mnist-demo.yaml* and paste the following YAML manifest, which includes a resource limit of `nvidia.com/gpu: 1`:

    Note

    If you receive a version mismatch error when calling into drivers, such as "CUDA driver version is insufficient for CUDA runtime version", review the [NVIDIA driver matrix compatibility chart](https://docs.nvidia.com/deploy/cuda-compatibility/index.html).

    ```yaml
    apiVersion: batch/v1
    kind: Job
    metadata:
      labels:
        app: samples-tf-mnist-demo
      name: samples-tf-mnist-demo
    spec:
      template:
        metadata:
          labels:
            app: samples-tf-mnist-demo
        spec:
          containers:
          - name: samples-tf-mnist-demo
            image: mcr.microsoft.com/azuredocs/samples-tf-mnist-demo:gpu
            args: ["--max_steps", "500"]
            imagePullPolicy: IfNotPresent
            resources:
              limits:
               nvidia.com/gpu: 1
          restartPolicy: OnFailure
          tolerations:
          - key: "sku"
            operator: "Equal"
            value: "gpu"
            effect: "NoSchedule"
    ```
2. Run the job using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command, which parses the manifest file and creates the defined Kubernetes objects.

    ```console
    kubectl apply -f samples-tf-mnist-demo.yaml
    ```

## View the status of the GPU-enabled workload

1. Monitor the progress of the job using the [`kubectl get jobs`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command with the `--watch` flag. It may take a few minutes to first pull the image and process the dataset.

    ```console
    kubectl get jobs samples-tf-mnist-demo --watch
    ```

    When the *COMPLETIONS* column shows *1/1*, the job has successfully finished, as shown in the following example output:

    ```console
    NAME                    COMPLETIONS   DURATION   AGE
    
    samples-tf-mnist-demo   0/1           3m29s      3m29s
    samples-tf-mnist-demo   1/1   3m10s   3m36s
    ```
2. Exit the `kubectl --watch` process with *Ctrl-C*.
3. Get the name of the pod using the [`kubectl get pods`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command.

    ```console
    kubectl get pods --selector app=samples-tf-mnist-demo
    ```
4. View the output of the GPU-enabled workload using the [`kubectl logs`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#logs) command.

    ```console
    kubectl logs samples-tf-mnist-demo-smnr6
    ```

    The following condensed example output of the pod logs confirms that the appropriate GPU device, `Tesla K80`, has been discovered:

    ```console
    2019-05-16 16:08:31.258328: I tensorflow/core/platform/cpu_feature_guard.cc:137] Your CPU supports instructions that this TensorFlow binary was not compiled to use: SSE4.1 SSE4.2 AVX AVX2 FMA
    2019-05-16 16:08:31.396846: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1030] Found device 0 with properties:
    name: Tesla K80 major: 3 minor: 7 memoryClockRate(GHz): 0.8235
    pciBusID: 2fd7:00:00.0
    totalMemory: 11.17GiB freeMemory: 11.10GiB
    2019-05-16 16:08:31.396886: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1120] Creating TensorFlow device (/device:GPU:0) -> (device: 0, name: Tesla K80, pci bus id: 2fd7:00:00.0, compute capability: 3.7)
    2019-05-16 16:08:36.076962: I tensorflow/stream_executor/dso_loader.cc:139] successfully opened CUDA library libcupti.so.8.0 locally
    Successfully downloaded train-images-idx3-ubyte.gz 9912422 bytes.
    Extracting /tmp/tensorflow/input_data/train-images-idx3-ubyte.gz
    Successfully downloaded train-labels-idx1-ubyte.gz 28881 bytes.
    Extracting /tmp/tensorflow/input_data/train-labels-idx1-ubyte.gz
    Successfully downloaded t10k-images-idx3-ubyte.gz 1648877 bytes.
    Extracting /tmp/tensorflow/input_data/t10k-images-idx3-ubyte.gz
    Successfully downloaded t10k-labels-idx1-ubyte.gz 4542 bytes.
    Extracting /tmp/tensorflow/input_data/t10k-labels-idx1-ubyte.gz
    Accuracy at step 0: 0.1081
    Accuracy at step 10: 0.7457
    Accuracy at step 20: 0.8233
    Accuracy at step 30: 0.8644
    Accuracy at step 40: 0.8848
    Accuracy at step 50: 0.8889
    Accuracy at step 60: 0.8898
    Accuracy at step 70: 0.8979
    Accuracy at step 80: 0.9087
    Accuracy at step 90: 0.9099
    Adding run metadata for 99
    Accuracy at step 100: 0.9125
    Accuracy at step 110: 0.9184
    Accuracy at step 120: 0.922
    Accuracy at step 130: 0.9161
    Accuracy at step 140: 0.9219
    Accuracy at step 150: 0.9151
    Accuracy at step 160: 0.9199
    Accuracy at step 170: 0.9305
    Accuracy at step 180: 0.9251
    Accuracy at step 190: 0.9258
    Adding run metadata for 199
    [...]
    Adding run metadata for 499
    ```

## Upgrading a node pool

Whether you want to [update](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) or [upgrade](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-upgrade) your node pools, you might notice that there is no `--gpu-driver` parameter for either operation. You might run into an error like `unrecognized arguments: --gpu-driver none` if you attempt to pass the parameter. There is no need to call on the parameter, as the value is not affected by any such operations.

When you first create your node pool, whatever parameter you declare for `--gpu-driver` will not be impacted by upgrade/update operations. If you don't want any drivers to be installed, and selected `--gpu-driver None` when creating your node pool, drivers will not be installed in any subsequent updates/upgrades.

## Clean up resources

Remove the associated Kubernetes objects you created in this article using the [`kubectl delete job`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#delete) command.

```console
kubectl delete jobs samples-tf-mnist-demo
```