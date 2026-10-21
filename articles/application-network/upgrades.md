---
layout: Conceptual
title: Configure Upgrades for Azure Kubernetes Application Network (Preview) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-network/upgrades
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
learn_banner_products:
- azure
description: Learn how to configure minor version upgrades for Azure Kubernetes Application Network members using self-managed and fully-managed upgrade modes, including how to select versions, initiate upgrades, and roll back if needed.
author: Kochhars
ms.author: kochhars
ms.service: azure-kubernetes-app-net
ms.topic: how-to
ms.date: 2025-11-04T00:00:00.0000000Z
locale: en-us
document_id: 4cce8632-aa1b-653a-7209-4b680392d73b
document_version_independent_id: 98610311-9425-20a0-932b-c7f7f07b9785
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/application-network/upgrades.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: application-network/upgrades
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-network/upgrades.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: e13fa71a-dd1d-f2ea-cd6d-af0613ece95b
---

# Configure Upgrades for Azure Kubernetes Application Network (Preview) | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

Azure Kubernetes Application Network provides flexible control over how minor version upgrades are applied to members. Each member cluster enrolled in an Azure Kubernetes Application Network resource can use one of two upgrade modes depending on the level of control you require: **self-managed** (`SelfManaged`) or **fully-managed** (`FullyManaged`). These modes operate at the member level, allowing you to choose whether upgrades are performed manually or automatically for each cluster.

This article explains the differences between these upgrade modes, how to configure them for your Azure Kubernetes Application Network members, and important considerations to keep in mind when managing upgrades.

## General upgrade mode considerations

Keep the following limitations and considerations in mind when configuring upgrade modes for Azure Kubernetes Application Network members:

- Azure Kubernetes Application Network upgrade modes apply **only** to minor versions of Azure Kubernetes Application Network components. They **don't** control or affect cluster-level upgrades such as Kubernetes versions or node image updates.
- Patch updates are always applied automatically, regardless of mode.
- You select the upgrade mode for each member during the join process. Once selected, the mode remains in effect for that member until it's removed from the Azure Kubernetes Application Network resource. You can't change the upgrade mode for a member without first removing and rejoining it to the Azure Kubernetes Application Network resource.
- If you don't specify an upgrade mode during member join, it defaults to `SelfManaged`.

## Self-managed mode

In `SelfManaged` mode, you specify the minor version of Azure Kubernetes Application Network to install and control when upgrades occur. This mode is intended for scenarios where you want to manage the minor upgrade process manually rather than relying on automated updates. In this mode, if `--version` is not specified, it defaults to the `N-1`st available version. This mode is also the default if no upgrade mode is specified during member join.

### Self-managed mode considerations

When using `SelfManaged` mode, keep the following considerations in mind:

- Upgrades are only allowed between consecutive minor versions (for example, from minor version `N` to `N+1`). Skipping versions (for example, upgrading from `1.1` to `1.3`) isn't supported.
- You can roll back only to the immediately preceding version (`N-1`), provided it was previously installed on the same cluster. Rolling back to any other earlier version isn't supported.
- Multiple consecutive rollbacks aren't supported. You can rollback a maximum of one version.

### Enroll in self-managed mode and select version during member join

- Enroll in `SelfManaged` mode and explicitly select a version during member join using the [`az appnet member join`](/en-us/cli/azure/appnet/member#az-appnet-member-join) command with the `--upgrade-mode SelfManaged` parameter and the `--version` parameter set to the desired version.

    ```azurecli
    az appnet member join \
        --resource-group $APPNET_RG \
        --appnet-name $APPNET_NAME \
        --member-name $APPNET_MEMBER_NAME \
        --member-resource-id /subscriptions/$SUBSCRIPTION/resourcegroups/$AKS_RG/providers/Microsoft.ContainerService/managedClusters/$CLUSTER_NAME \
        --upgrade-mode SelfManaged \
        --version $VERSION
    ```

### Check current version

- Check which version is currently installed on a member using the [`az appnet member show`](/en-us/cli/azure/appnet/member#az-appnet-member-show) command and refer to the `Version` property in the output.

    ```azurecli
    az appnet member show --member-name $APPNET_MEMBER_NAME --appnet-name $APPNET_NAME --resource-group $APPNET_RG
    ```

### Check available upgrade versions

- Check which versions are available for each mode and Kubernetes version in your region using the [`az appnet list-versions`](/en-us/cli/azure/appnet#az-appnet-list-versions) command with the `--location` parameter set to the region of interest. In the output, refer to the `AvailableUpgrades` column to see which versions are available.

    ```azurecli
    az appnet list-versions --location $LOCATION -o table
    ```

### Initiate an upgrade

- Initiate an upgrade using the [`az appnet member update`](/en-us/cli/azure/appnet/member#az-appnet-member-update) command with the `--version` parameter set to the desired version to upgrade to.

    ```azurecli
    az appnet member update --resource-group $APPNET_RG --appnet-name $APPNET_NAME --member-name $APPNET_MEMBER_NAME --version $VERSION
    ```

### Roll back to a previous version

- Roll back to a previously installed version using the [`az appnet member update`](/en-us/cli/azure/appnet/member#az-appnet-member-update) command with the `--version` parameter set to the desired version to roll back to. Remember that only rolling back to the immediately preceding version (`N-1`) is supported.

    ```azurecli
    az appnet member update --resource-group $APPNET_RG --appnet-name $APPNET_NAME --member-name $APPNET_MEMBER_NAME --version $VERSION
    ```

## Fully-managed mode

In `FullyManaged` mode, Azure Kubernetes Application Network automatically manages version upgrades for each member based on the selected release channel. We recommend this mode if you prefer Azure Kubernetes Application Network to handle version stability evaluation, rollout timing, and ongoing updates without manual intervention.

When using `FullyManaged` upgrade mode, you choose a release channel that determines how quickly your member clusters adopt new versions. Azure Kubernetes Application Network monitors release readiness and upgrades members according to the channel's stability criteria.

The following release channels are available for `FullyManaged` mode:

- **Rapid**: Delivers the latest Application Network version as soon as it becomes available. This channel is intended for non-production or early validation environments where testing new features and functionality is prioritized over extended validation time.
- **Stable**: Delivers versions that have completed extra validation and testing. This channel is intended for production environments and typically aligns with minor version `N-1`, ensuring higher reliability and addressing any issues identified in earlier releases.

When `FullyManaged` mode is selected, you can specify the release channel to `stable` or `rapid`. If omitted, the default channel is `stable`.

Important

In `FullyManaged` mode, Azure Kubernetes Application Network automatically applies upgrades as new versions are promoted through release channels. Manual control of upgrade timing or version selection isn't supported.

### Check available upgrade versions for fully-managed mode

- Check which version each channel corresponds to for a given region and Kubernetes version using the [`az appnet list-versions`](/en-us/cli/azure/appnet#az-appnet-list-versions) command and grep for `FullyManaged` mode.

    ```azurecli
    az appnet list-versions --location $LOCATION -o table | grep FullyManaged
    ```

### Enroll in fully-managed mode and select release channel during member join

- Enroll in `FullyManaged` mode and select a release channel during member join using the [`az appnet member join`](/en-us/cli/azure/appnet/member#az-appnet-member-join) command with the `--upgrade-mode FullyManaged` parameter and the `--release-channel` parameter set to the desired channel. The following example shows how to select the `Rapid` channel during member join:

    ```azurecli
    az appnet member join \
        --resource-group $APPNET_RG \
        --appnet-name $APPNET_NAME \
        --member-name $APPNET_MEMBER_NAME \
        --member-resource-id /subscriptions/$SUBSCRIPTION/resourcegroups/$AKS_RG/providers/Microsoft.ContainerService/managedClusters/$CLUSTER_NAME \
        --upgrade-mode FullyManaged \
        --release-channel Rapid \
        --member-location $LOCATION
    ```

### Update release channel selection

You can update your selected release at any time. Any changes to the release channel take effect immediately.

- Update the release channel selection for an existing member using the [`az appnet member update`](/en-us/cli/azure/appnet/member#az-appnet-member-update) command with the `--release-channel` parameter set to the desired channel. The following example shows how to switch to the `Stable` channel for an existing member:

    ```azurecli
    az appnet member update --resource-group $APPNET_RG --appnet-name $APPNET_NAME --member-name $APPNET_MEMBER_NAME --release-channel Stable
    ```