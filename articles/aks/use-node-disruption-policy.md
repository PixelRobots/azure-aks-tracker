---
layout: Conceptual
title: Configure Node Disruption Policy in Azure Kubernetes Service (AKS) (Preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-node-disruption-policy
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
description: Learn how to configure and manage Node Disruption Policy to control when operations that require node reimage are allowed in Azure Kubernetes Service (AKS).
author: yudian
ms.author: yudian
ms.topic: how-to
ms.subservice: aks-upgrade
ms.custom: devx-track-azurecli
ms.date: 2026-03-11T00:00:00.0000000Z
locale: en-us
document_id: e48db9f7-e7de-1ece-4263-0ec35101a177
document_version_independent_id: a369e5ce-79d6-9f34-62ae-96f3e42ee444
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-node-disruption-policy.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/use-node-disruption-policy
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-node-disruption-policy.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
platformId: 6d73ab9e-7b31-7565-0b0a-9e9a171725b2
---

# Configure Node Disruption Policy in Azure Kubernetes Service (AKS) (Preview) - Azure Kubernetes Service | Microsoft Learn

This article shows you how to configure and manage Node Disruption Policy to control when operations that require node reimage and trigger node redeployment are allowed in your Azure Kubernetes Service (AKS) cluster.

## Prerequisites

- Review the [Node Disruption Policy overview](node-disruption-policy) to learn [how Node Disruption Policy works](node-disruption-policy#how-node-disruption-policy-works) and the [operations covered by Node Disruption Policy](node-disruption-policy#operations-covered-by-node-disruption-policy).
- Azure CLI version 2.76.0 or later installed and configured. To find your CLI version, run the `az --version` command. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- An existing AKS cluster, or you can create a new one with Node Disruption Policy configured.
- Install the `aks-preview` Azure CLI extension and register the Node Disruption Policy preview feature.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

### Install the `aks-preview` Azure CLI extension

1. Install the `aks-preview` extension using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command.

    ```azurecli
    az extension add --name aks-preview
    ```
2. Update to the latest version of the extension using the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command.

    ```azurecli
    az extension update --name aks-preview
    ```

### Register the Node Disruption Policy preview feature

Register the Node Disruption Policy preview feature using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

az feature register --namespace "Microsoft.ContainerService" --name "NodeDisruptionProfile"

It takes a few minutes for the status to show as *Registered*.

## Configure Node Disruption Policy on a new cluster

Create a new AKS cluster with Node Disruption Policy configured by using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--node-disruption-policy` parameter set to one of the following policy configurations: [`Allow`](node-disruption-policy#policy-options) (default), [`AllowDuringMaintenanceWindow`](node-disruption-policy#policy-options), or [`Block`](node-disruption-policy#policy-options).

### Allow disruptive operations at any time (default)

```azurecli
az aks create \
    --resource-group myResourceGroup \
    --name myAKSCluster \
    --node-count 3 \
    --node-disruption-policy Allow \
    --generate-ssh-keys
```

### Allow disruptive operations only during maintenance windows

```azurecli
az aks create \
    --resource-group myResourceGroup \
    --name myAKSCluster \
    --node-count 3 \
    --node-disruption-policy AllowDuringMaintenanceWindow \
    --generate-ssh-keys
```

Important

When you use `AllowDuringMaintenanceWindow`, ensure you configure an `aksManagedNodeOSUpgradeSchedule` maintenance window. The maintenance configuration can define the schedule inline or link to a shared maintenance window. Otherwise, disruptive operations are allowed indefinitely. For more information, see [Use planned maintenance to schedule and control upgrades for your Azure Kubernetes Service cluster](planned-maintenance).

### Block all disruptive operations

```azurecli
az aks create \
    --resource-group myResourceGroup \
    --name myAKSCluster \
    --node-count 3 \
    --node-disruption-policy Block \
    --generate-ssh-keys
```

## Update Node Disruption Policy on an existing cluster

Update the Node Disruption Policy on an existing AKS cluster by using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--node-disruption-policy` parameter set to one of the following policy configurations: [`Allow`](node-disruption-policy#policy-options) (default), [`AllowDuringMaintenanceWindow`](node-disruption-policy#policy-options), or [`Block`](node-disruption-policy#policy-options).

### Change policy to allow operations during maintenance windows

```azurecli
az aks update \
    --resource-group myResourceGroup \
    --name myAKSCluster \
    --node-disruption-policy AllowDuringMaintenanceWindow
```

### Change policy to block all disruptive operations

```azurecli
az aks update \
    --resource-group myResourceGroup \
    --name myAKSCluster \
    --node-disruption-policy Block
```

### Change policy back to allow operations at any time

```azurecli
az aks update \
    --resource-group myResourceGroup \
    --name myAKSCluster \
    --node-disruption-policy Allow
```

## Verify Node Disruption Policy configuration

Verify the Node Disruption Policy configuration by using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

```azurecli
az aks show \
    --resource-group myResourceGroup \
    --name myAKSCluster \
    --query "nodeDisruptionProfile.nodeDisruptionPolicy" \
    --output tsv
```

The output shows the current policy setting, such as `Allow`, `AllowDuringMaintenanceWindow`, or `Block`.

## Handle blocked operations

When the Node Disruption Policy blocks a disruptive operation, you can wait for the maintenance window or temporarily change the policy.

### Wait for the maintenance window

If you're using `AllowDuringMaintenanceWindow`, schedule the operation to occur during the next maintenance window. You can view your configured maintenance windows by using the [`az aks maintenanceconfiguration list`](/en-us/cli/azure/aks/maintenanceconfiguration#az-aks-maintenanceconfiguration-list) command.

```azurecli
az aks maintenanceconfiguration list \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster
```

### Temporarily change the policy

1. Update the policy to `Allow` by using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with `--node-disruption-policy` set to `Allow`.

    ```azurecli
    az aks update \
        --resource-group myResourceGroup \
        --name myAKSCluster \
        --node-disruption-policy Allow
    ```
2. Perform your disruptive operation. The following example updates the custom CA certificates by using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command:

    ```azurecli
    az aks update \
        --resource-group myResourceGroup \
        --name myAKSCluster \
        --custom-ca-trust-certificates <path-to-certificate-file>
    ```
3. Restore the original policy by using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command. The following example restores `--node-disruption-policy` to `Block`:

    ```azurecli
    az aks update \
        --resource-group myResourceGroup \
        --name myAKSCluster \
        --node-disruption-policy Block
    ```

## Operations that require manual node pool upgrade on Kubernetes 1.36 and earlier

On Kubernetes 1.37 and later, Node Disruption Policy covers the following configuration changes. On Kubernetes 1.36 and earlier, these changes require a manual node pool upgrade:

- SSH configuration changes, such as changing SSH access methods or updating SSH public keys.
- IMDS restriction changes, such as enabling or disabling IMDS restriction.
- Bootstrap profile ACR name changes for network isolated clusters.
- Outbound type changes, such as changing cluster egress routing.

On Kubernetes 1.36 and earlier, manually run the [`az aks nodepool upgrade`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-upgrade) command after making the configuration change. For example:

```azurecli
az aks nodepool upgrade \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name <nodepool-name> \
    --node-image-only
```

For more information about operations covered by Node Disruption Policy, see the [Node Disruption Policy overview](node-disruption-policy).

## Troubleshoot Node Disruption Policy issues

### Operation blocked unexpectedly

If an operation is blocked unexpectedly, use the following steps to troubleshoot the issue:

1. Check the current policy setting by using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```azurecli
    az aks show \
        --resource-group myResourceGroup \
        --name myAKSCluster \
        --query "nodeDisruptionProfile.nodeDisruptionPolicy" \
        --output tsv
    ```
2. If you're using `AllowDuringMaintenanceWindow`, verify the maintenance window configuration by using the [`az aks maintenanceconfiguration show`](/en-us/cli/azure/aks/maintenanceconfiguration#az-aks-maintenanceconfiguration-show) command.

    ```azurecli
    az aks maintenanceconfiguration show \
        --resource-group myResourceGroup \
        --cluster-name myAKSCluster \
        --name aksManagedNodeOSUpgradeSchedule
    ```
3. Check if the current time falls within the maintenance window.

### No maintenance window configured

If you set the policy to `AllowDuringMaintenanceWindow` but don't configure a maintenance window, all disruptive operations are **allowed**.

Configure a maintenance window by using the [`az aks maintenanceconfiguration add`](/en-us/cli/azure/aks/maintenanceconfiguration#az-aks-maintenanceconfiguration-add) command. To reuse the same schedule across multiple clusters, link `aksManagedNodeOSUpgradeSchedule` to a [shared maintenance window](/en-us/azure/aks/planned-maintenance?pivots=azure-cli#use-a-shared-maintenance-window-preview).

```azurecli
az aks maintenanceconfiguration add \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name aksManagedNodeOSUpgradeSchedule \
    --schedule-type Weekly \
    --day-of-week Sunday \
    --interval-weeks 1 \
    --duration 4 \
    --start-time 02:00
```