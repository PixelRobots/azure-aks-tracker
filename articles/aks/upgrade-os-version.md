---
layout: Conceptual
title: Upgrade Operating System (OS) Version in Azure Kubernetes Service (AKS) Clusters - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/upgrade-os-version
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
description: Learn about support, testing, and rollback for OS versions available on Azure Kubernetes Service (AKS).
ms.topic: overview
ms.date: 2026-08-06T00:00:00.0000000Z
author: allyford
ms.author: allyford
ai-usage: ai-assisted
locale: en-us
document_id: 51d340fb-c324-a30e-66b3-45c9f9bafa6b
document_version_independent_id: bf86977a-5c7b-a35b-f8ec-1cfa1292c6c3
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/upgrade-os-version.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/upgrade-os-version
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/upgrade-os-version.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 64e4f66a-1f38-34ac-dda2-f2cd6dc8a9db
---

# Upgrade Operating System (OS) Version in Azure Kubernetes Service (AKS) Clusters - Azure Kubernetes Service | Microsoft Learn

This article describes OS versions available for Azure Kubernetes Service (AKS) nodes, and best practices for testing and upgrading your OS version.

Important

Starting on **December 10, 2026**, Azure Kubernetes Service (AKS) no longer supports Azure Linux with OS Guard for AKS (preview). At that point, AKS no longer produces new Azure Linux with OS Guard node images or provides security patches, and you can no longer create new node pools with Azure Linux with OS Guard. On **March 10, 2027**, AKS removes all existing Azure Linux with OS Guard node images, which causes scaling and remediation (reimage and redeploy) operations to fail. To avoid disruption, migrate to [Azure Container Linux (ACL)](azure-container-linux-overview). For more information about this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/5950) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates/?id=571257). To stay informed about announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Important

Starting on **March 17, 2027**, Azure Kubernetes Service (AKS) no longer supports or provides security updates for Ubuntu 20.04. Any existing node images will be deleted, and you'll be unable to scale any node pools running Ubuntu 20.04. Migrate to a supported Ubuntu version by [upgrading your node pools](upgrade-aks-cluster) to Kubernetes version 1.35+. For more information on this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4874) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=485795). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Important

Starting on **June 30, 2027**, Azure Kubernetes Service (AKS) no longer supports or provides security updates for Ubuntu 22.04. To avoid disruptions, [transition](upgrade-aks-cluster) to Ubuntu 24.04 or later by that date. Between now and June 30, 2027, you can continue to use Ubuntu 22.04 on AKS without disruption. If you don't migrate by June 30, 2027, you won't be able to create new node pools, AKS won't produce new node images, and you'll no longer receive security patches for existing node pools. If you want to enable long-term support (LTS) with Kubernetes version 1.33 or later, first update your node pools to Ubuntu 24.04. On **April 30, 2028**, AKS will remove Ubuntu 22.04 node images and existing code, causing scaling and remediation operations to fail. To avoid service disruptions such as security vulnerabilities, failed node image upgrades, and scaling failures, [migrate](upgrade-aks-cluster) to Ubuntu 24.04 or later by June 30, 2027. Your migration options include:

- **Default Operating System SKU (OSSku)**: If you're using `Ubuntu`, you'll automatically migrate to Ubuntu 24.04 when you upgrade your Kubernetes version to 1.35 or later.
- **Versioned OSSku**: If you're using `Ubuntu2204`, update your OSSku to `Ubuntu` for Kubernetes 1.35 or later or `Ubuntu2404` for Kubernetes 1.32 or later.

For more information on this retirement, see the [Retirement GitHub issue](https://aka.ms/aks/ubuntu2204-retirement-github) and [Azure Updates post](https://azure.microsoft.com/updates/?id=557928). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Important

Starting on **November 30, 2025**, Azure Kubernetes Service (AKS) no longer supports or provides security updates for Azure Linux 2.0. The Azure Linux 2.0 node image is frozen at the `202512.06.0` release. Beginning on **October 31, 2026**, node images will be removed, and you'll be unable to scale your node pools. Migrate to a supported Azure Linux version by [upgrading your node pools](/en-us/azure/aks/upgrade-aks-cluster) to a supported Kubernetes version or migrating to [osSku AzureLinux3](/en-us/azure/aks/upgrade-os-version). For more information, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4988) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=500645). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

## Supported OS versions

Each [node image](node-images) corresponds to an OS version, which you can specify using OS SKU. You can specify the following parameters when creating clusters and node pools:

- **--os-type**: OS type, including Linux or Windows. *You can't specify the Windows OS type during cluster-level creation or update.*
- **--os-sku**: Used to specify OS version or OS variant. *You can't specify the Windows OS SKU during cluster-level creation or update.* For Windows node pools, specify the OS SKU when you add a node pool. For more information about supported OS SKU options, see [Azure AKS CLI](/en-us/cli/azure/aks#az-aks-create) or [API](/en-us/rest/api/aks/agent-pools/create-or-update#ossku).
- **--kubernetes-version**: Version of Kubernetes to use for creating the node pool or cluster.

> 
> **Best practice guidance**
> 
> The default OS version is the most recent validated version.
> 
> - For Ubuntu, we recommend creating clusters and node pools while specifying `--os-type Linux` and `--os-sku Ubuntu`. This will automatically update you to the latest default Ubuntu version based on your Kubernetes version.
> - For Azure Linux, we recommend creating clusters and node pools while specifying `--os-type Linux` and `--os-sku AzureLinux`. This will automatically update you to the latest default Azure Linux version based on your Kubernetes version.
> - For Azure Container Linux (ACL), we recommend creating clusters and node pools while specifying `--os-type Linux` and `--os-sku AzureContainerLinux`. This will automatically update you to the latest default ACL version based on your Kubernetes version.
> - For Windows, create node pools while specifying `--os-type Windows`, `--os-sku Windows2025`, and `--enable-fips-image` (Windows Server 2025 requires a FIPS-enabled image). You need to manually update node pools to the next OS version when it's released.
> 

| OS type | OS SKU | Supported Kubernetes versions | Default versioning |
| --- | --- | --- | --- |
| Linux | Ubuntu | This OS SKU is supported in all Kubernetes versions. | OS version for this OS SKU changes based on your Kubernetes version. Ubuntu 22.04 is default for Kubernetes versions 1.25 to 1.34. Ubuntu 24.04 is default for Kubernetes versions 1.35+. |
| Linux | Ubuntu2604 | This OS SKU is supported in preview in Kubernetes version 1.36 and later. | We recommend this versioned OS SKU if you want to migrate to the new OS version without upgrading your Kubernetes version. Requires the `Ubuntu2604Preview` feature flag. |
| Linux | Ubuntu2404 | This OS SKU will only be supported in Kubernetes 1.32 to 1.38. | We recommend this versioned OS SKU if you want to migrate to the new OS version without upgrading your Kubernetes version. Ubuntu 24.04 is default when using `--os-sku Ubuntu` in Kubernetes versions 1.35+. |
| Linux | Ubuntu2204 | This OS SKU is supported in Kubernetes versions 1.25 to 1.36. | We recommend this versioned OS SKU if you need to roll back to Ubuntu 22.04. Ubuntu 22.04 is default when using `--os-sku Ubuntu` in Kubernetes versions 1.25 to 1.35. |
| Linux | AzureLinux | This OS SKU is supported in all Kubernetes versions. | OS version for this OS SKU changes based on your Kubernetes version. Azure Linux 2.0 is default for Kubernetes version 1.27 to 1.31. Azure Linux 3.0 is default for Kubernetes version 1.32+. When the `AzureLinuxV3Preview` feature flag is enabled on AKS 1.31, `--os-sku AzureLinux` defaults to 3.0. |
| Linux | AzureLinux3 | This OS SKU is supported in Kubernetes 1.28 to 1.36. | We recommend this OS SKU if you want to test out the new OS version without upgrading your Kubernetes version. You can also use this OS SKU to migrate from Azure Linux 2.0 to Azure Linux 3.0. |
| Linux | AzureLinuxOSGuard | This OS SKU is supported in Kubernetes versions 1.32 and above. | Azure Linux with OS Guard versions are upgraded through node image upgrades. For more information, see [Azure Linux with OS Guard for AKS](use-azure-linux-os-guard). |
| Linux | Flatcar | This OS SKU is supported in all Kubernetes versions. | Flatcar versions are upgraded through node image upgrades. For more information, see [Flatcar Container Linux for AKS](flatcar-container-linux-for-aks). |
| Linux | AzureContainerLinux | This OS SKU is supported in Kubernetes versions 1.34 and above. | Azure Container Linux versions are upgraded through node image upgrades. |
| Windows | Windows2022 | 1.23 to 1.36 | Default for Windows OS Type in Kubernetes version 1.25 to 1.35. |
| Windows | Windows2025 | 1.32 and above | Default for Windows OS Type in Kubernetes version 1.36 and later. Requires a FIPS-enabled image (`--enable-fips-image`). |

## Migrate to a new OS version

When a new OS version releases on AKS, it's initially supported in preview. After testing in preview for a few months, AKS makes the new OS version generally available (GA) and then updates the default OS SKU (`Ubuntu` or `AzureLinux`) to the latest GA OS version. This default update occurs with a new Kubernetes version release.

We recommend testing your nonproduction workloads with the new OS version when it becomes available in preview. In order to access preview functions, make sure you have the preview extension installed. You can install the extension using the `az extension add --name aks-preview` command.

There are two ways to migrate to a new OS version:

- **Default OS SKU**: If you're using a default OS SKU such as `Ubuntu` or `AzureLinux`, you automatically get the latest GA version when you [upgrade your Kubernetes version](manage-node-pools). There are no manual changes required to migrate to a new OS version. Clusters and node pools using the `Ubuntu` OS SKU automatically migrate to Ubuntu 24.04 when upgrading the Kubernetes version to 1.35 or higher.
- **Versioned OS SKU**: If you're using a versioned OS SKU such as `Ubuntu2604`, `Ubuntu2404`, `AzureLinux3`, or `Windows2025`, you need to manually migrate to a new OS version to avoid blocked Kubernetes upgrades. If you're using a Linux OS, you can update the OS SKU on an existing node pool to migrate in place. For Windows, in-place migration is supported only from Windows Server 2022 to Windows Server 2025.

### Update OS SKU on an existing node pool

Update the `os-sku` on an existing node pool using the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command. In cases where there's a new OS version available in preview, this functionality allows you to migrate your node pool to the new OS version without needing to upgrade your Kubernetes version.

Note

The following Windows values aren't supported for the node pool update command. Migrations from Windows Server 2022 to Windows Server 2025 are supported.

- `--os-sku Windows2022`

Instead, you need to add node pools to your cluster with the corresponding `--os-sku` you intend to use.

```azurecli
az aks nodepool update \
    --resource-group $RESOURCE_GROUP \
    --cluster-name $CLUSTER_NAME \
    --os-sku Ubuntu \
    --name $NODE_POOL_NAME
```

You can use the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command to migrate between any supported Linux `os-sku`. The command might fail if the target OS doesn't have a supported node image for your Kubernetes version, VM size, or FIPS enablement.

#### Migrate to Ubuntu 26.04 (preview)

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

Ubuntu 26.04 is available in preview in Kubernetes version 1.36 and later. Use Ubuntu 26.04 by specifying `--os-sku Ubuntu2604`.

Note

Keep the following information in mind when migrating to `--os-sku Ubuntu2604`:

- Register the `Ubuntu2604Preview` feature flag before you create or update a node pool to Ubuntu 26.04.
- Ubuntu 26.04 requires a VM size that supports Generation 2 VMs.
- Ubuntu 26.04 uses minimal node images for AMD64 and Arm64.
- [FIPS](enable-fips-nodes), [Confidential VM](use-cvm), and [Trusted Launch](use-trusted-launch) aren't supported.
- You need the preview Azure CLI version 21.0.0b14 or later installed and configured. To find your CLI version, run `az --version`. To install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

#### Install the `aks-preview` Azure CLI extension

1. Install the `aks-preview` Azure CLI extension by using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command.

    ```azurecli
    az extension add --name aks-preview
    ```
2. Update the extension to ensure you have the latest version installed by using the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command.

    ```azurecli
    az extension update --name aks-preview
    ```

Register the `Ubuntu2604Preview` feature flag in your Azure subscription before you create or update a node pool to Ubuntu 26.04.

#### Register the `Ubuntu2604Preview` feature flag

1. Register the `Ubuntu2604Preview` feature flag by using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

    ```azurecli
    az feature register \
        --namespace Microsoft.ContainerService \
        --name Ubuntu2604Preview
    ```

    It takes a few minutes for the status to show *Registered*.
2. Verify the registration status by using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command.

    ```azurecli
    az feature show \
        --namespace Microsoft.ContainerService \
        --name Ubuntu2604Preview \
        --query properties.state
    ```
3. When the status shows *Registered*, refresh the registration of the *Microsoft.ContainerService* resource provider by using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace Microsoft.ContainerService
    ```

#### Update an existing node pool to Ubuntu 26.04

Update to `--os-sku Ubuntu2604` on an existing node pool by using the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command.

```azurecli
az aks nodepool update \
    --resource-group $RESOURCE_GROUP \
    --cluster-name $CLUSTER_NAME \
    --os-sku Ubuntu2604 \
    --name $NODE_POOL_NAME
```

## Roll back your OS version

In Kubernetes versions where multiple OS versions are supported, you can use the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command to roll back to a previous OS version.

You might want to roll back your OS version in the following scenarios:

- If you're testing a new OS version and you run into any issues.
- Once you upgrade to a Kubernetes version that supports the new OS version as default, you might want to roll back to the default `Ubuntu` or `AzureLinux` OS SKU. This allows you to get future OS versions as a part of your Kubernetes upgrades instead of requiring a node pool update.

### Roll back your OS version to the default OS SKU

You can use the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command to update the `os-sku` on an existing node pool. In cases where there's a previous OS version supported in your Kubernetes version, this functionality can allow you to roll back your OS version.

Note

The following values aren't supported for node pool update command:

- `--os-sku Windows2022`
- `--os-sku Windows2025`

Instead, add node pools to your cluster by using the corresponding `--os-sku` you want to use. To learn more about upgrading your OS version for your Windows FIPS node pools, see [Upgrade Windows OS version](upgrade-windows-os).

| OS SKU | Default OS version |
| --- | --- |
| Ubuntu | When you have OS SKU `Ubuntu`, Ubuntu 22.04 is the default OS version if your Kubernetes version is 1.25 to 1.34. Ubuntu 24.04 is the default for Ubuntu in Kubernetes 1.35 to 1.37. |
| AzureLinux | When you have OS SKU `AzureLinux`, Azure Linux 2.0 is the default for AzureLinux in Kubernetes 1.26 to 1.31. Azure Linux 3.0 is the default for AzureLinux in Kubernetes 1.32 to 1.36. |

#### Update your OS SKU to Ubuntu on an existing node pool

When updating your node pool to use OS SKU `Ubuntu`, you'll get the default OS version based on your Kubernetes version. This might trigger an automatic reimage if the OS version changes during the node pool update command.

Update to `--os-sku Ubuntu` on an existing node pool using the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command.

```azurecli
az aks nodepool update \
    --resource-group $RESOURCE_GROUP \
    --cluster-name $CLUSTER_NAME \
    --os-sku Ubuntu \
    --name $NODE_POOL_NAME
```

You can use the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command to migrate between any supported Linux `os-sku`. The command might fail if the target OS doesn't have a supported node image for your Kubernetes version, VM size, or FIPS enablement.

#### Update your OS SKU to Azure Linux on an existing node pool

When updating your node pool to use OS SKU `AzureLinux`, you'll get the default OS version based on your Kubernetes version. This might trigger an automatic reimage if the OS version changes during the node pool update command.

Update to `--os-sku AzureLinux` on an existing node pool using the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command.

```azurecli
az aks nodepool update \
    --resource-group $RESOURCE_GROUP \
    --cluster-name $CLUSTER_NAME \
    --os-sku AzureLinux \
    --name $NODE_POOL_NAME
```