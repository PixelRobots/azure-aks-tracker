---
layout: Conceptual
title: Flatcar Container Linux for Azure Kubernetes Service (AKS) (preview) Overview - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/flatcar-container-linux-for-aks
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
description: Learn about Flatcar Container Linux for Azure Kubernetes Service (AKS), including limitations, migration information, and resources to get started.
ms.topic: overview
ms.date: 2025-11-10T00:00:00.0000000Z
author: allyford
ms.author: allyford
locale: en-us
document_id: 5564a2d7-cf35-30e1-275f-e5f67dfee564
document_version_independent_id: 743e8989-1f67-8170-f742-36337509fdf1
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/flatcar-container-linux-for-aks.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/flatcar-container-linux-for-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/flatcar-container-linux-for-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 5ea2076a-bef9-cad5-edc8-852b36c7de45
---

# Flatcar Container Linux for Azure Kubernetes Service (AKS) (preview) Overview - Azure Kubernetes Service | Microsoft Learn

Important

Starting on **June 8, 2026**, AKS no longer supports Flatcar Container Linux for Azure Kubernetes Service (AKS) (preview). At that point, AKS will no longer produce new Flatcar Container Linux node images or provide security patches, and you'll be unable to create new node pools with Flatcar Container Linux. On **September 8, 2026**, AKS will remove all existing Flatcar Container Linux node images, causing scaling and remediation (reimage and redeploy) operations to fail.

To avoid disruption, we recommend migrating to a supported Linux OS, such as [Azure Linux](/en-us/azure/azure-linux/intro-azure-linux) or [Ubuntu](/en-us/azure/aks/concepts-clusters-workloads#nodes-and-node-pools). For more information on this retirement, see the [Retirement GitHub issue](https://aka.ms/aks/flatcar-preview-retirement-github) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates/). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Note

There's no in-place migration path from Flatcar Container Linux to another OS. You must create new node pools with a supported Linux OS (Azure Linux or Ubuntu), migrate your workloads to the new node pools, and then delete the old Flatcar Container Linux node pools. For more information about supported node OS options, see the [AKS node OS documentation](core-aks-concepts#node-configuration).

This article provides an overview of Flatcar Container Linux for AKS, a Cloud Native Compute Foundation (CNCF) project that provides security, reliability, and cross-cloud capabilities. Flatcar Container Linux is available in preview as an OS option on AKS. You can deploy Flatcar Container Linux node pools in a new AKS cluster or add Flatcar Container Linux node pools to your existing clusters. To learn more about Flatcar Container Linux, see the [Flatcar documentation](https://www.flatcar.org/).

## Flatcar Container Linux for AKS benefits

Flatcar uses an immutable OS filesystem, and it eliminates configuration drift and prevents unauthorized changes, ensuring robust protection for your workloads across multiple cloud platforms. Designed for versatility, Flatcar enables cross-cloud deployment, empowering businesses to scale effortlessly and securely.

## Limitations

Flatcar Container Linux for AKS has the following limitations:

- [FIPS](enable-fips-nodes) isn't supported with Flatcar Container Linux.
- [Trusted Launch](use-trusted-launch) isn't supported with Flatcar Container Linux.
- [Confidential VM sizes](use-cvm) aren't supported with Flatcar Container Linux.
- The `SecurityPatch`[node OS upgrade channel](auto-upgrade-node-os-image) isn't supported with Flatcar Container Linux.
- During preview, AKS doesn't support in-place updates with Flatcar Container Linux.
- [Artifact Streaming](artifact-streaming) (preview) isn't supported with Flatcar Container Linux.
- [Generation 1 VMs](aks-virtual-machine-sizes) aren't supported with Flatcar Container Linux, which means you can't use VM sizes that only support Generation 1.
- [Pod Sandboxing (preview)](use-pod-sandboxing) isn't supported with Flatcar Container Linux.
- [Node auto-provisioning](node-autoprovision) isn't supported with Flatcar Container Linux.
- [Azure Monitor VM(SS) extension](/en-us/azure/azure-monitor/agents/azure-monitor-agent-manage?tabs=azure-portal#:%7E:text=Virtual%20machine%20%28VM%29%20extension) isn't supported.

Note

If you have an existing cluster with any of the above features enabled, you might not be able to add a node pool using Flatcar Container Linux.

## Get started with Flatcar Container Linux for AKS

To get started using the Flatcar Container Linux for AKS, see the following resources:

- Deploy an Azure Kubernetes Service (AKS) cluster with Flatcar Container Linux for AKS (preview) using [Azure CLI](learn/quick-flatcar-deploy-cli)
- Deploy an Azure Kubernetes Service (AKS) cluster with Flatcar Container Linux for AKS (preview) using an [ARM template](learn/quick-flatcar-deploy-arm-template)
- Create an AKS cluster with a single Flatcar Container Linux for AKS (preview) node pool using [Azure CLI or an ARM template](create-node-pools)
- Add a Flatcar Container Linux for AKS (preview) node pool to an existing cluster using [Azure CLI or an ARM template](create-node-pools)

## OS migrations and upgrades with Flatcar Container Linux

AKS doesn't support in-place migrations from existing Linux clusters or node pools to Flatcar Container Linux clusters or node pools. To migrate existing workloads to Flatcar Container Linux for AKS, you need to recreate your node pools using `--os-sku flatcar`.

Flatcar Container Linux for AKS releases weekly AKS node images. Versioning follows the AKS date-based format (for example: 202506.13.0). You can check the node images in the release notes and by using the [`az aks nodepool list`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-list) command to view the `nodeImageVersion`. For example:

```azurecli
az aks nodepool list --resource-group <resource-group-name> --cluster-name <aks-cluster-name> --query '[].{name: name, nodeImageVersion: nodeImageVersion}'
```

Example output:

```output
[
{
    "name": "nodes",
    "nodeImageVersion": "AKSFlatcar-flatcargen2-202508.06.0"
}
]
```

You can check the Flatcar version number (for example: Flatcar 4372.0.1) in the release notes and by using `kubectl get nodes` command. For example:

```bash
kubectl get nodes -o wide
```

Example output:

```output
NAME                            STATUS   ROLES    AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                                             KERNEL-VERSION    CONTAINER-RUNTIME
aks-nodes-16363508-vmss000000   Ready    <none>   2m33s   v1.32.6   10.224.0.4    <none>        Flatcar Container Linux by Kinvolk 4372.0.1 (Oklo)   6.12.35-flatcar   containerd://2.0.4
```

Flatcar's inbuilt automatic A/B update for the OS partition is disabled and only full node image updates are supported.