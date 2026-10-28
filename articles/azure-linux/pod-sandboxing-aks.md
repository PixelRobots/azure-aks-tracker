---
layout: Conceptual
title: Pod Sandboxing with Azure Kubernetes Service (AKS) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/pod-sandboxing-aks
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/133/azure
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/79b1327d-d925-ec11-b6e6-000d3a4f06a4
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
learn_banner_products:
- azure
manager: kumud
description: Learn about and deploy Pod Sandboxing on an Azure Kubernetes Service (AKS) cluster.
ms.topic: how-to
ms.service: microsoft-linux
ms.date: 2026-04-28T00:00:00.0000000Z
author: kavyamsft
ms.author: schaffererin
locale: en-us
document_id: 23059405-e5a2-017e-18e2-aab820cc61f8
document_version_independent_id: cd9e315b-33e2-3000-ec14-3805f617f0ed
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/pod-sandboxing-aks.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/pod-sandboxing-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/pod-sandboxing-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 011290e7-2243-367e-0493-23b603163f60
---

# Pod Sandboxing with Azure Kubernetes Service (AKS) | Microsoft Learn

Pod Sandboxing on AKS provides an isolation boundary between the container application and the shared kernel and compute resources of the container host such as CPU, memory, and networking. Applications are spun up in isolated, lightweight pod virtual machines (VMs). In this article, you learn about Pod Sandboxing, its limitations, how it works, and how to deploy it on a new or existing AKS cluster.

## Prerequisites

- The Azure CLI version 2.80.0 or later. Run `az --version` to find the version of your Azure CLI, and run `az upgrade` to upgrade. For more details, see the steps at [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- AKS supports Pod Sandboxing on Kubernetes version 1.27.0 and higher.
- To manage a Kubernetes cluster, use the Kubernetes command-line client [kubectl](https://kubernetes.io/docs/reference/kubectl/). Azure Cloud Shell comes with `kubectl`. You can install kubectl locally using the [az aks install-cli](/en-us/cli/azure/aks#az-aks-install-cli) command.

## Limitations

The following are constraints applicable to Pod Sandboxing:

- Kata containers might not reach the IOPS performance limits that traditional containers can reach on Azure Files and high-performance local SSD.
- [Microsoft Defender for Containers](/en-us/azure/defender-for-cloud/defender-for-containers-introduction) doesn't support assessing Kata runtime pods.
- [Kata](https://github.com/kata-containers/kata-containers/blob/main/docs/Limitations.md#host-network) host-network access isn't supported. It isn't possible to directly access the host networking configuration from within the VM.
- CPU and memory allocation with Pod Sandboxing has other considerations compared to `runc`. Reference the memory management sections in the [considerations page](/en-us/azure/aks/considerations-pod-sandboxing).

## How it works

Pod Sandboxing on AKS builds on top of the open-source [Kata Containers](https://katacontainers.io/) project. Kata Containers running on the Azure Linux container host for AKS provides VM based isolation and a separate kernel for each pod. Pod Sandboxing allows users to allocate resources for each pod and doesn't share them with other Kata Containers or namespace containers running on the same host.

The solution architecture is based on the following main components:

- The [Azure Linux container host for AKS](azure-linux-aks-overview)
- Microsoft Hyper-V Hypervisor
- Open-source [Cloud-Hypervisor](https://www.cloudhypervisor.org) Virtual Machine Monitor (VMM)
- Integration with [Kata Container](https://katacontainers.io) for the runtime

Deploying Pod Sandboxing using Kata Containers is similar to the standard `containerd` workflow to deploy containers. Clusters with Pod Sandboxing enabled come with a specific runtime class that can be referenced in a pod manifest (`runtimeClassName: kata-vm-isolation`).

To use this feature with a pod, the only difference is to add the **runtimeClassName**, `kata-vm-isolation` to the pod spec. When a pod uses the `kata-vm-isolation` runtimeClass, the hypervisor spins up a lightweight virtual machine with its own kernel, for the workload to operate in.

## Deploy new cluster

Perform the following steps to deploy an Azure Linux AKS cluster using the Azure CLI.

1. Create an AKS cluster using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command and specify the following parameters:

    - `--workload-runtime`: Specify *KataVmIsolation* to enable the Pod Sandboxing feature on the node pool. With this parameter, these other parameters should satisfy the following requirements. Otherwise, the command fails and reports an issue with the corresponding parameters.
    - `--os-sku*`: *AzureLinux*. Only the Azure Linux os-sku supports this feature.
    - `--node-vm-size`: Any Azure VM size that is a generation 2 VM and supports nested virtualization works. For example, [Dsv3](/en-us/azure/virtual-machines/dv3-dsv3-series#dsv3-series) VMs.

    The following example creates a cluster named *myAKSCluster* with one node in the *myResourceGroup*:

    ```azurecli
    az aks create \
        --name myAKSCluster \
        --resource-group myResourceGroup \
        --os-sku AzureLinux \
        --workload-runtime KataVmIsolation \
        --node-vm-size Standard_D4s_v3 \
        --node-count 3 \
        --generate-ssh-keys
    ```
2. Get access credentials for the Kubernetes cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command. The following example gets credentials for the *myAKSCluster* cluster in the *myResourceGroup* resource group:

    ```azurecli
    az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
    ```
3. List all pods in all namespaces using the [`kubectl get pods`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command.

    ```bash
    kubectl get pods --all-namespaces
    ```

## Deploy to an existing cluster

Note

To use this feature with an existing AKS cluster, first verify the cluster is running Kubernetes version 1.27.0 or higher.

1. Add a node pool to your AKS cluster using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command and specify the following parameters:

    - `--resource-group`: Enter the name of an existing resource group to create the AKS cluster in.
    - `--cluster-name`: Enter a unique name for the AKS cluster, such as *myAKSCluster*.
    - `--name`: Enter a unique name for your clusters node pool, such as *nodepool2*.
    - `--workload-runtime`: Specify *KataVmIsolation* to enable the Pod Sandboxing feature on the node pool. Along with the `--workload-runtime` parameter, these other parameters satisfy the requirements. Otherwise, the command fails and reports an issue with the corresponding parameter.
    - `--os-sku`: *AzureLinux*. Only the Azure Linux os-sku supports this feature.
    - `--node-vm-size`: Any Azure VM size that is a generation 2 VM and supports nested virtualization works. For example, [Dsv3](/en-us/azure/virtual-machines/dv3-dsv3-series#dsv3-series) VMs.

    The following example adds a node pool to *myAKSCluster* with one node in *nodepool2* in the *myResourceGroup*:

    ```azurecli
    az aks nodepool add \
        --cluster-name myAKSCluster \
        --resource-group myResourceGroup \
        --name nodepool2 \
        --os-sku AzureLinux \
        --workload-runtime KataVmIsolation \
        --node-vm-size Standard_D4s_v3
    ```
2. Enable pod sandboxing on the cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command.

    ```azurecli
    az aks update --name myAKSCluster --resource-group myResourceGroup
    ```

## Deploy your applications

With Pod Sandboxing, you can deploy a mix of "normal" pods that don't utilize the Kata runtime alongside Kata pods that do utilize the runtime. The main difference between the two, when deploying, is that a Kata pod has the line `runtimeClassName: kata-vm-isolation` in its spec.

### Deploy an application with the Kata runtime

1. Create a file named *kata-app.yaml* to describe your kata pod and paste the following manifest:

    ```yaml
    kind: Pod
    apiVersion: v1
    metadata:
      name: isolated-pod
    spec:
      runtimeClassName: kata-vm-isolation
      containers:
      - name: kata
        image: mcr.microsoft.com/aks/fundamental/base-ubuntu:v0.0.11
        command: ["/bin/sh", "-ec", "while :; do echo '.'; sleep 5 ; done"]
    ```

    The value for **runtimeClassNameSpec** is `kata-vm-isolation`.
2. Deploy the Kubernetes pod using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command and specify your *kata-app.yaml* file:

    ```bash
    kubectl apply -f kata-app.yaml
    ```

    The output of the command resembles the following example:

    ```output
    pod/isolated-pod created
    ```

## Verify Kernel isolation configuration (optional)

1. If you want to verify the difference between the kernel of a Kata and non-Kata pod, you can spin up another workload that doesn't have the Kata runtime. For example:

    ```yaml
    kind: Pod
    apiVersion: v1
    metadata:
      name: normal-pod
    spec:
      containers:
      - name: non-kata
        image: mcr.microsoft.com/aks/fundamental/base-ubuntu:v0.0.11
        command: ["/bin/sh", "-ec", "while :; do echo '.'; sleep 5 ; done"]
    ```
2. To access a container inside the AKS cluster, start a shell session using the [`kubectl exec`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#exec) command. In this example, you access the container inside *kata-pod*:

    ```bash
    kubectl exec -it isolated-pod -- /bin/sh
    ```

    kubectl connects to your cluster, runs `/bin/sh` inside the first container within `isolated-pod`, and forwards your terminal's input and output streams to the container's process. You can also start a shell session to the container hosting the non-Kata pod to see the differences.
3. After starting a shell session to the container from *kata-pod*, you can run commands to verify that the *kata* container is running in a pod sandbox. Notice that it has a different kernel version compared to the non-Kata container outside the sandbox. To see the kernel version, run the following command:

    ```bash
    uname -r
    ```

    The following example resembles output from the pod sandbox kernel:

    ```output
    [user]/# uname -r
    6.6.96.mshv1
    ```
4. Start a shell session to the container from *normal-pod* to verify the kernel output:

    ```bash
    kubectl exec -it normal-pod -- /bin/bash
    ```
5. To see the kernel version run the following command:

    ```bash
    uname -r
    ```

    The following example resembles output from the VM that's running *normal-pod*, which is a different kernel than the Kata pod running within the pod sandbox:

    ```output
    6.6.100.mshv1-1.azl3
    ```

## Clean up resources

When you're finished evaluating this feature, to avoid Azure charges, clean up your unnecessary resources. If you deployed a new cluster as part of your evaluation or testing, you can delete the cluster using the [`az aks delete`](/en-us/cli/azure/aks#az-aks-delete) command.

```azurecli
az aks delete --resource-group myResourceGroup --name myAKSCluster
```

If you deployed Pod Sandboxing on an existing cluster, you can remove the pods using the [`kubectl delete pod`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#delete) command.

```bash
kubectl get pods
kubectl delete pod <kata-pod-name>
```