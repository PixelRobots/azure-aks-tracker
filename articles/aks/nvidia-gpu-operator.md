---
layout: Conceptual
title: Use NVIDIA GPU Operator on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/nvidia-gpu-operator
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
description: Learn how to install the NVIDIA GPU Operator for advanced GPU deployments on AKS.
ms.topic: how-to
ms.custom: devx-track-azurecli
ms.subservice: aks-developer
ms.date: 2025-07-02T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 7ac77465-178e-a592-993b-6359aee8a0c3
document_version_independent_id: c159ad78-191d-0a85-77f8-a0f4218463a2
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/nvidia-gpu-operator.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/nvidia-gpu-operator
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/nvidia-gpu-operator.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 0b1db971-3979-dff7-cd32-ec5a863817da
---

# Use NVIDIA GPU Operator on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

The NVIDIA GPU Operator automates the management and deployment of all NVIDIA software components needed to provision GPU including driver installation, the [NVIDIA device plugin for Kubernetes](https://github.com/NVIDIA/k8s-device-plugin?tab=readme-ov-file), the NVIDIA container runtime, and more. Since the NVIDIA GPU Operator handles these components, it's not necessary to separately install the NVIDIA device plugin on your AKS cluster. This also means that the automatic GPU driver installation should be skipped in order to use the NVIDIA GPU Operator on AKS.

Tip

If you don't need the full control of the NVIDIA GPU Operator, [AKS-managed GPU node pools (preview)](aks-managed-gpu-nodes) install and maintain the NVIDIA driver, Kubernetes device plugin, and DCGM metrics exporter for you.

Important

Open-source software is mentioned throughout AKS documentation and samples. Software that you deploy is excluded from AKS service-level agreements, limited warranty, and Azure support. As you use open-source technology alongside AKS, consult the support options available from the respective communities and project maintainers to develop a plan.

Microsoft takes responsibility for building the open-source packages that we deploy on AKS. That responsibility includes having complete ownership of the build, scan, sign, validate, and hotfix process, along with control over the binaries in container images. For more information, see [Vulnerability management for AKS](concepts-vulnerability-management#aks-container-images) and [AKS support coverage](support-policies#aks-support-coverage).

## Before you begin

- This article assumes you have an existing AKS cluster. If you don't have a cluster, create one using the [Azure CLI](learn/quick-kubernetes-deploy-cli), [Azure PowerShell](learn/quick-kubernetes-deploy-powershell), or the [Azure portal](learn/quick-kubernetes-deploy-portal).
- You need the Azure CLI version 2.72.2 or later installed to set the `--gpu-driver` field. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

Note

GPU-enabled VMs contain specialized hardware subject to higher pricing and region availability. For more information, see the [pricing](free-standard-pricing-tiers) tool and [region availability](quotas-skus-regions).

## Limitations

NVIDIA GPU Operator isn't supported for the following OS options: Windows Server versions, [Flatcar Container Linux for AKS (preview)](flatcar-container-linux-for-aks), and [Azure Linux with OS Guard for AKS (preview)](use-azure-linux-os-guard).

## Get the credentials for your cluster

Get the credentials for your AKS cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command. The following example command gets the credentials for the cluster `myAKSCluster` in the `myResourceGroup` resource group:

```azurecli
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
```

Note

The NVIDIA GPU Operator is not compatible with multiple OS versions on the same AKS cluster.

# [Standard node pool](#tab/standard-node-pool)
1. Skip automatic GPU driver installation by creating an NVIDIA GPU-enabled node pool by using the [`az aks nodepool add`](/en-us/cli/azure/aks#az-aks-nodepool-add) command and setting the API field `--gpu-driver` to the value `none`. Setting this API field to `none` during node pool creation skips the default GPU driver installation. For an example, see [Skip GPU driver installation](use-nvidia-gpu#skip-gpu-driver-installation). This setting doesn't change any existing nodes. You can scale the node pool to zero and then back up to make the change take effect.

```azurecli
az aks nodepool add \
--resource-group myResourceGroup \
--cluster-name myAKSCluster \
--name gpunp \
--node-count 1 \
--node-vm-size Standard_NC4as_T4_v3 \
--node-taints sku=gpu:NoSchedule \
--gpu-driver none
```

1. Follow the NVIDIA documentation to [Install the GPU Operator](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html).
2. After you install the GPU Operator, check that your [GPUs are schedulable](use-nvidia-gpu#confirm-that-gpus-are-schedulable) and [run a GPU workload](use-nvidia-gpu#run-a-gpu-enabled-workload).

Note

There might be additional considerations to take when using the NVIDIA GPU Operator and deploying on SPOT instances. Please refer to https://github.com/NVIDIA/gpu-operator/issues/577

# [Node Auto Provisioning node pool](#tab/nap-nodes)
1. Skip automatic GPU driver installation by setting the AKSNodeClass CRD `spec.gpu.mode` field to the value `none`. Setting this AKSNodeClass field to `none` skips the default GPU driver installation, see [this example](node-auto-provisioning-aksnodeclass#gpu-settings). The process replaces any existing nodes that use this AKSNodeClass CRD with a new node that has no GPU driver installed.

```yaml
apiVersion: karpenter.azure.com/v1beta1
kind: AKSNodeClass
metadata:
  name: my-node-class
spec:
  gpu:
    mode: 
      none
```

1. Follow the NVIDIA documentation to [Install the GPU Operator](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html).
2. After you install the GPU Operator, check that your [GPUs are schedulable](use-nvidia-gpu#confirm-that-gpus-are-schedulable) and [run a GPU workload](use-nvidia-gpu#run-a-gpu-enabled-workload).

Note

There might be additional considerations to take when using the NVIDIA GPU Operator and deploying on SPOT instances. For more information, see https://github.com/NVIDIA/gpu-operator/issues/577.

---