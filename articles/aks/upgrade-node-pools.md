---
layout: Conceptual
title: Upgrade Node Pools in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/upgrade-node-pools
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
description: Learn how to upgrade a single node pool and how to upgrade the cluster control plane for multiple node pools in Azure Kubernetes Service (AKS).
ms.topic: how-to
ms.date: 2023-07-19T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-nodes
locale: en-us
document_id: 10512d8c-dbdb-0ffc-986c-46c0cea8d526
document_version_independent_id: 7cf29bbb-e437-8d0f-bce2-fe7d8e44bdeb
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/upgrade-node-pools.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/upgrade-node-pools
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/upgrade-node-pools.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 3b8ccfe7-01fa-0d99-8cc5-641394ac29cb
---

# Upgrade Node Pools in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to upgrade a single node pool and how to upgrade the cluster control plane for multiple node pools in Azure Kubernetes Service (AKS).

Note

As a best practice, you should upgrade all node pools in an AKS cluster to the same Kubernetes version. The default behavior of [`az aks upgrade`][az-aks-upgrade] is to upgrade all node pools together with the control plane to achieve this alignment. The ability to upgrade individual node pools lets you perform a rolling upgrade and schedule pods between node pools to maintain application uptime.

## Upgrade a single node pool

Note

The node pool operating system (OS) image version is tied to the Kubernetes version of the cluster. You only get OS image upgrades following a cluster upgrade.

1. Check for any available upgrades using the [`az aks get-upgrades`][az-aks-get-upgrades] command.

    ```azurecli
    az aks get-upgrades --resource-group <resource-group-name> --name <cluster-name>
    ```
2. Upgrade a specific node pool using the [`az aks nodepool upgrade`][az-aks-nodepool-upgrade] command.

    ```azurecli
    az aks nodepool upgrade \
        --resource-group <resource-group-name> \
        --cluster-name <cluster-name> \
        --name <node-pool-name> \
        --kubernetes-version <kubernetes-version> \
        --no-wait
    ```
3. Check the status of your node pool using the [`az aks nodepool list`][az-aks-nodepool-list] command.

    ```azurecli
    az aks nodepool list --resource-group <resource-group-name> --cluster-name <cluster-name>
    ```

    The following example output shows the node pool is in the *Upgrading* state:

    ```output
    [
      {
        ...
        "count": 3,
        ...
        "name": "<node-pool-name>",
        "orchestratorVersion": "<kubernetes-version>",
        ...
        "provisioningState": "Upgrading",
        ...
        "vmSize": "Standard_DS2_v2",
        ...
      },
      {
        ...
        "count": 2,
        ...
        "name": "<node-pool-name-2>",
        "orchestratorVersion": "<kubernetes-version-2>",
        ...
        "provisioningState": "Succeeded",
        ...
        "vmSize": "Standard_DS2_v2",
        ...
      }
    ]
    ```

    It takes a few minutes to upgrade the nodes to the specified version. After the upgrade is complete, the node pool's `provisioningState` changes to *Succeeded*.

## Upgrade a cluster control plane with multiple node pools

An AKS cluster has two cluster resource objects with Kubernetes versions associated to them: the cluster control plane Kubernetes version and a node pool with a Kubernetes version.

### Upgrade behavior for the control plane and node pools

The control plane maps to one or many node pools. The behavior of an upgrade operation depends on which Azure CLI command you use and the flags you specify:

- [`az aks upgrade`](/en-us/cli/azure/aks#az-aks-upgrade) upgrades the control plane and all node pools in the cluster to the same Kubernetes version.
- [`az aks upgrade`](/en-us/cli/azure/aks#az-aks-upgrade) with the `--control-plane-only` flag upgrades only the cluster control plane and leaves all node pools unchanged.
- [`az aks nodepool upgrade`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-upgrade) upgrades only the target node pool with the specified Kubernetes version.

### Validation rules for upgrades

Note

Kubernetes uses the standard [Semantic Versioning](https://semver.org/) versioning scheme. The version number is expressed as *x.y.z*, where *x* is the major version, *y* is the minor version, and *z* is the patch version. For example, in version *1.12.6*, *1* is the major version, *12* is the minor version, and *6* is the patch version. The Kubernetes version of the control plane and the initial node pool are set during cluster creation. Other node pools have their Kubernetes version set when they are added to the cluster. The Kubernetes versions may differ between node pools and between a node pool and the control plane.

Kubernetes upgrades for a cluster control plane and node pools are validated using the following sets of rules:

- **Rules for valid versions to upgrade node pools**:

    - The node pool version must have the same *major* version as the control plane.
    - The node pool *minor* version must be within two *minor* versions of the control plane version.
    - The node pool version can't be greater than the control `major.minor.patch` version.
- **Rules for submitting an upgrade operation**:

    - You can't downgrade the control plane or a node pool Kubernetes version.
    - If a node pool Kubernetes version isn't specified, the behavior depends on the client. In Azure Resource Manager (ARM) templates, declaration falls back to the existing version defined for the node pool. If nothing is set, it falls back to the control plane version.
    - You can't simultaneously submit multiple operations on a single control plane or node pool resource. You can either upgrade or scale a control plane or a node pool at a given time.

## Next steps: Manage node pools in AKS

To learn more about managing node pools in AKS, see [Manage node pools in Azure Kubernetes Service (AKS)](manage-node-pools).