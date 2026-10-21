---
layout: Conceptual
title: Trusted Launch with Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-trusted-launch
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
zone_pivot_group_filename: zone-pivots/azure-aks/zone-pivot-groups.json
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn how Trusted Launch protects the Azure Kubernetes Cluster (AKS) nodes against boot kits, rootkits, and kernel-level malware.
ms.topic: how-to
ms.custom: devx-track-azurecli
ms.subservice: aks-security
ms.date: 2026-10-13T00:00:00.0000000Z
ai-usage: ai-assisted
author: allyford
ms.author: allyford
zone_pivot_groups: azure-cli-arm-bicep-terraform-portal
locale: en-us
document_id: d3399c58-2e65-06a0-fe31-2bf43ce87588
document_version_independent_id: 62d7c1ae-b9a5-8555-a2f9-b7a0ef0ca8e9
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-trusted-launch.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/use-trusted-launch
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-trusted-launch.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/4e834929-0ce1-4c1d-9c81-fcb14721edfb
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/75670257-a3f0-4627-9981-8046f99219e6
platformId: 52ac43ef-f87c-4a1f-1e49-89a468b68374
---

# Trusted Launch with Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

[Trusted Launch](/en-us/azure/virtual-machines/trusted-launch) improves the security of generation 2 virtual machines (VMs) by protecting against advanced and persistent attack techniques. It enables administrators to deploy AKS nodes, which contain the underlying virtual machines, with verified and signed bootloaders, OS kernels, and drivers. By using secure and measured boot, administrators gain insights and confidence of the entire boot chain's integrity.

This article helps you understand this new feature, and how to implement it.

Note

Trusted Launch is supported with Node Auto Provisioning (NAP). For more information, see [Enable trusted launch in NAP clusters](node-auto-provisioning-aksnodeclass#enable-trusted-launch-in-nap-clusters).

Important

Starting on **November 30, 2025**, Azure Kubernetes Service (AKS) no longer supports or provides security updates for Azure Linux 2.0. The Azure Linux 2.0 node image is frozen at the `202512.06.0` release. Beginning on **October 31, 2026**, node images will be removed, and you'll be unable to scale your node pools. Migrate to a supported Azure Linux version by [upgrading your node pools](/en-us/azure/aks/upgrade-aks-cluster) to a supported Kubernetes version or migrating to [osSku AzureLinux3](/en-us/azure/aks/upgrade-os-version). For more information, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4988) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=500645). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

## Overview

Trusted Launch is composed of several, coordinated infrastructure technologies that can be enabled independently. Each technology provides another layer of defense against sophisticated threats.

- **vTPM** - Trusted Launch introduces a virtualized version of a hardware [Trusted Platform Module](/en-us/windows/security/information-protection/tpm/trusted-platform-module-overview) (TPM), compliant with the TPM 2.0 specification. It serves as a dedicated secure vault for keys and measurements. Trusted Launch provides your VM with its own dedicated TPM instance, running in a secure environment outside the reach of any VM. The vTPM enables [attestation](/en-us/windows/security/information-protection/tpm/tpm-fundamentals#measured-boot-with-support-for-attestation) by measuring the entire boot chain of your VM (UEFI, OS, system, and drivers). Trusted Launch uses the vTPM to perform remote attestation by the cloud. It's used for platform health checks and for making trust-based decisions. As a health check, Trusted Launch can cryptographically certify that your VM booted correctly. If the process fails, possibly because your VM is running an unauthorized component, [Microsoft Defender for Cloud](/en-us/azure/defender-for-cloud/defender-for-cloud-introduction) issues integrity alerts. The alerts include details on which components failed to pass integrity checks.
- **Secure Boot** - At the root of Trusted Launch is Secure Boot for your VM. This mode, which is implemented in platform firmware, protects against the installation of malware-based rootkits and boot kits. Secure Boot works to ensure that only signed operating systems and drivers can boot. It establishes a "root of trust" for the software stack on your VM. With Secure Boot enabled, all OS boot components (boot loader, kernel, kernel drivers) must be signed by trusted publishers. Both Windows and select Linux distributions support Secure Boot. If Secure Boot fails to authenticate an image signed by a trusted publisher, the VM isn't allowed to boot. For more information, see [Secure Boot](/en-us/windows-hardware/design/device-experiences/oem-secure-boot).

## Before you begin

::: zone pivot="azure-cli"

- The Azure CLI version 2.66.0 or later. Run `az --version` to find the version, and run `az upgrade` to upgrade the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- To use Trusted Launch with Azure Container Linux (ACL), install Azure CLI version 2.86.0 or later.

::: zone-end

- Secure Boot requires signed boot loaders, OS kernels, and drivers.

## Limitations

- AKS supports Trusted Launch on Kubernetes version 1.25.2 and higher.
- ACL node pools with Trusted Launch require AKS version 1.34 or later.
- Trusted Launch only supports [Azure Generation 2 VMs](/en-us/azure/virtual-machines/generation-2).
- Node pools with Windows Server operating system aren't supported.
- For Ubuntu and Azure Linux node pools, you can't enable Trusted Launch in the same node pool as [Arm64](use-arm64-vms), [Pod Sandboxing](use-pod-sandboxing), or [Confidential VM](use-cvm). Azure Container Linux (ACL) supports Trusted Launch on supported AMD64 VM sizes and supported Arm64 VM sizes. For more information, see [node images documentation](node-images).
- You can enable Trusted Launch in the same node pool as [FIPS](enable-fips-nodes) with Ubuntu 22.04 or ACL.
- Trusted Launch doesn't support virtual node.
- Availability sets aren't supported, only Virtual Machine Scale Sets.
- To enable Secure Boot on GPU node pools using the Ubuntu operating system, you need to skip installing the GPU driver (`--gpu-driver None`). For more information, see [Skip GPU driver installation](gpu-cluster#skip-gpu-driver-installation) and [Use NVIDIA GPUs on Azure Kubernetes Service (AKS)](use-nvidia-gpu). This limitation doesn't apply for running GPU workloads with Azure Linux or Azure Container Linux operating systems.
- Ephemeral OS disks can be created with Trusted Launch and all regions are supported. However, not all virtual machines sizes are supported. For more information, see [Trusted Launch ephemeral OS sizes](/en-us/azure/virtual-machines/ephemeral-os-disks#trusted-launch-for-ephemeral-os-disks).
- [Flatcar Container Linux for AKS](flatcar-container-linux-for-aks) doesn't support Trusted Launch on AKS.
- Trusted Launch isn't supported through the AzureRM (`azurerm`) Terraform provider. To deploy Trusted Launch node pools, use the Azure CLI, ARM template, or Bicep instructions in this article.

## Create an AKS cluster with Trusted Launch enabled

When creating a cluster, enabling vTPM or Secure Boot automatically sets up your node pools to use the customized Trusted Launch image. This image is specifically configured to support the security features enabled by Trusted Launch.

::: zone pivot="azure-cli"

1. Create an AKS cluster using the [az aks create](/en-us/cli/azure/aks#az-aks-create) command. Before running the command, review the following parameters:

    - `--name`: Enter a unique name for the AKS cluster, such as *myAKSCluster*.
    - `--resource-group`: Enter the name of an existing resource group to host the AKS cluster resource.
    - `--enable-secure-boot`: Enables Secure Boot to authenticate an image signed by a trusted publisher.
    - `--enable-vtpm`: Enables vTPM and performs attestation by measuring the entire boot chain of your VM.

    Note

    Secure Boot requires signed boot loaders, OS kernels, and drivers. If after enabling Secure Boot your nodes don't start, you can verify which boot components are responsible for Secure Boot failures within an Azure Linux Virtual Machine. See [verify Secure Boot failures](/en-us/azure/virtual-machines/trusted-launch-faq#verify-secure-boot-failures).

    The following example creates a cluster named *myAKSCluster* with one node in the *myResourceGroup*, and enables Secure Boot and vTPM:

    ```azurecli
    az aks create \
        --name myAKSCluster \
        --resource-group myResourceGroup \
        --node-count 1 \
        --enable-secure-boot \
        --enable-vtpm \
        --generate-ssh-keys
    ```
2. Run the following command to get access credentials for the Kubernetes cluster. Use the [az aks get-credentials](/en-us/cli/azure/aks#az-aks-get-credentials) command and replace the values for the cluster name and the resource group name.

    ```azurecli
    az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
    ```

::: zone-end

::: zone pivot="arm"

1. Create a template with Trusted Launch parameters. Before creating the template, review the following parameters:

    - `enableSecureBoot`: Enables secure boot to authenticate an image signed by a trusted publisher.
    - `enableVTPM`: Enables vTPM and performs attestation by measuring the entire boot chain of your VM.

    In your template, provide values for `enableVTPM` and `enableSecureBoot`. The same schema used for CLI deployment exists in the `Microsoft.ContainerService/managedClusters/agentPools` definition under `"properties"`, as shown in the following example:

    ```json
    "properties": {
        ...,
        "securityProfile": {
            "enableVTPM": true,
            "enableSecureBoot": true,
        }
    }
    ```
2. Deploy your template with vTPM and secure boot enabled on your cluster. See [Deploy an AKS cluster using an ARM template](/en-us/azure/aks/learn/quick-kubernetes-deploy-rm-template) for detailed instructions.

::: zone-end

::: zone pivot="bicep"

1. Create a Bicep file with Trusted Launch parameters. Before creating the file, review the following parameters:

    - `enableSecureBoot`: Enables secure boot to authenticate an image signed by a trusted publisher.
    - `enableVTPM`: Enables vTPM and performs attestation by measuring the entire boot chain of your VM.

    In your Bicep file, provide values for `enableVTPM` and `enableSecureBoot`. The same schema used for CLI deployment exists in the `Microsoft.ContainerService/managedClusters/agentPools` definition under `properties`, as shown in the following example:

    ```bicep
    properties: {
      // ...
      securityProfile: {
        enableVTPM: true
        enableSecureBoot: true
      }
    }
    ```
2. Deploy your Bicep file with vTPM and secure boot enabled on your cluster. See [Deploy an AKS cluster using a Bicep file](/en-us/azure/aks/learn/quick-kubernetes-deploy-bicep) for detailed instructions.

::: zone-end

::: zone pivot="terraform"

The AzureRM (`azurerm`) Terraform provider doesn't support Trusted Launch because it doesn't expose Trusted Launch node pool settings. To create an AKS cluster with Trusted Launch enabled, use the Azure CLI, ARM template, or Bicep instructions in this article.

::: zone-end

::: zone pivot="azure-portal"

The Azure portal **doesn't support** creating an AKS cluster with Trusted Launch enabled. To create an AKS cluster with Trusted Launch enabled, use the Azure CLI, ARM template, or Bicep instructions in this article.

::: zone-end

## Add a node pool with Trusted Launch enabled

When you create a node pool, enabling vTPM or Secure Boot automatically sets up your node pools to use the customized Trusted Launch image. This image is specifically configured to support the security features enabled by Trusted Launch.

::: zone pivot="azure-cli"

1. Add a node pool with Trusted Launch enabled using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command. Before running the command, review the following parameters:

    - `--cluster-name`: Enter the name of the AKS cluster.
    - `--resource-group`: Enter the name of an existing resource group to host the AKS cluster resource.
    - `--name`: Enter a unique name for the node pool. The name of a node pool can only contain lowercase alphanumeric characters and must begin with a lowercase letter. For Linux node pools, the length must be between 1 and 11 characters.
    - `--node-count`: The number of nodes in the Kubernetes agent pool. Default is 3.
    - `--enable-secure-boot`: Enables Secure Boot to authenticate image signed by a trusted publisher.
    - `--enable-vtpm`: Enables vTPM and performs attestation by measuring the entire boot chain of your VM.

    Note

    Secure Boot requires signed boot loaders, OS kernels, and drivers. If after enabling Secure Boot your nodes don't start, you can verify which boot components are responsible for Secure Boot failures within an Azure Linux Virtual Machine. See [verify Secure Boot failures](/en-us/azure/virtual-machines/trusted-launch-faq#verify-secure-boot-failures).

    The following example deploys a node pool with vTPM and Secure Boot enabled on a cluster named *myAKSCluster* with three nodes:

    ```azurecli
    az aks nodepool add --resource-group myResourceGroup --cluster-name myAKSCluster --name mynodepool --node-count 3 --enable-vtpm --enable-secure-boot
    ```
2. Check that your node pool is using a Trusted Launch image.

    Trusted Launch nodes have the following output:

    - Node image version containing `"TL"`, such as `"AKSUbuntu-2204-gen2TLcontainerd"`.
    - `"Security-type"` should be `"Trusted Launch"`.

    ```bash
    kubectl get nodes
    kubectl describe node {node-name} | grep -e node-image-version -e security-type
    ```

::: zone-end

::: zone pivot="arm"

1. Create a template with Trusted Launch parameters. Before creating the template, review the following parameters:

    - `enableSecureBoot`: Enables secure boot to authenticate an image signed by a trusted publisher.
    - `enableVTPM`: Enables vTPM and performs attestation by measuring the entire boot chain of your VM.

    In your template, provide values for `enableVTPM` and `enableSecureBoot`. The same schema used for CLI deployment exists in the `Microsoft.ContainerService/managedClusters/agentPools` definition under `"properties"`, as shown in the following example:

    ```json
    "properties": {
        ...,
        "securityProfile": {
            "enableVTPM": true,
            "enableSecureBoot": true,
        }
    }
    ```
2. Deploy your template with vTPM and secure boot enabled on your cluster. See [Deploy an AKS cluster using an ARM template](/en-us/azure/aks/learn/quick-kubernetes-deploy-rm-template) for detailed instructions.

::: zone-end

::: zone pivot="bicep"

1. Create a Bicep file with Trusted Launch parameters. Before creating the file, review the following parameters:

    - `enableSecureBoot`: Enables secure boot to authenticate an image signed by a trusted publisher.
    - `enableVTPM`: Enables vTPM and performs attestation by measuring the entire boot chain of your VM.

    In your Bicep file, provide values for `enableVTPM` and `enableSecureBoot`. The same schema used for CLI deployment exists in the `Microsoft.ContainerService/managedClusters/agentPools` definition under `properties`, as shown in the following example:

    ```bicep
    properties: {
      // ...
      securityProfile: {
        enableVTPM: true
        enableSecureBoot: true
      }
    }
    ```
2. Deploy your Bicep file with vTPM and secure boot enabled on your cluster. See [Deploy an AKS cluster using a Bicep file](/en-us/azure/aks/learn/quick-kubernetes-deploy-bicep) for detailed instructions.

::: zone-end

::: zone pivot="terraform"

The AzureRM (`azurerm`) Terraform provider doesn't support Trusted Launch because it doesn't expose Trusted Launch node pool settings. To add a node pool with Trusted Launch enabled, use the Azure CLI, ARM template, or Bicep instructions in this article.

::: zone-end

::: zone pivot="azure-portal"

The Azure portal **doesn't support** adding a node pool with Trusted Launch enabled. To add a node pool with Trusted Launch enabled, use the Azure CLI, ARM template, or Bicep instructions in this article.

::: zone-end

## Add a node pool with Trusted Launch and FIPS enabled

You can enable Trusted Launch and FIPS together for Ubuntu 22.04 and Azure Container Linux (ACL) node pools on Generation 2 VM sizes.

For FIPS-specific operations, such as disabling FIPS on an existing node pool, see [Enable Federal Information Processing Standard (FIPS) for Azure Kubernetes Service (AKS) node pools](enable-fips-nodes).

::: zone pivot="azure-cli"

1. Add a node pool with Trusted Launch and FIPS enabled by using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command. Before running the command, review the following parameters:

    - `--cluster-name`: Enter the name of the AKS cluster.
    - `--resource-group`: Enter the name of an existing resource group to host the AKS cluster resource.
    - `--name`: Enter a unique name for the node pool. The name of a node pool can only contain lowercase alphanumeric characters and must begin with a lowercase letter. For Linux node pools, the length must be between 1 and 11 characters.
    - `--node-count`: The number of nodes in the Kubernetes agent pool. Default is 3.
    - `--enable-secure-boot`: Enables Secure Boot to authenticate image signed by a trusted publisher.
    - `--enable-vtpm`: Enables vTPM and performs attestation by measuring the entire boot chain of your VM.
    - `--enable-fips-image`: Enables the FIPS-compliant node image for the node pool.
    - `--os-sku`: Optional. Set to `AzureContainerLinux` to create an ACL node pool with Trusted Launch and FIPS enabled.

    Note

    Secure Boot requires signed boot loaders, OS kernels, and drivers. If after enabling Secure Boot your nodes don't start, you can verify which boot components are responsible for Secure Boot failures within an Azure Linux Virtual Machine. See [verify Secure Boot failures](/en-us/azure/virtual-machines/trusted-launch-faq#verify-secure-boot-failures).

    The following example deploys a node pool with vTPM, Secure Boot, and FIPS enabled on a cluster named *myAKSCluster* with three nodes:

    ```azurecli
    az aks nodepool add --resource-group myResourceGroup --cluster-name myAKSCluster --name mynodepool --node-count 3 --enable-vtpm --enable-secure-boot --enable-fips-image
    ```

    To create the node pool with ACL, add `--os-sku AzureContainerLinux`.
2. Check that your node pool uses a Trusted Launch image.

    Trusted Launch nodes have the following output:

    - Node image version containing both `"TL"` and `"FIPS"`.
    - `"Security-type"` is `"Trusted Launch"`.

    ```bash
    kubectl get nodes
    kubectl describe node {node-name} | grep -e node-image-version -e security-type
    ```

::: zone-end

::: zone pivot="arm"

1. Create a template with Trusted Launch and FIPS parameters. Before creating the template, review the following parameters:

    - `enableSecureBoot`: Enables secure boot to authenticate an image signed by a trusted publisher.
    - `enableVTPM`: Enables vTPM and performs attestation by measuring the entire boot chain of your VM.
    - `enableFips`: Enables the FIPS-compliant node image for the node pool.
    - `osSKU`: Optional. Set to `AzureContainerLinux` to create an ACL node pool with Trusted Launch and FIPS enabled.

    In your template, provide values for `enableVTPM`, `enableSecureBoot`, and `enableFips`. The same schema used for CLI deployment exists in the `Microsoft.ContainerService/managedClusters/agentPools` definition under `"properties"`, as shown in the following example:

    ```json
    "properties": {
        ...,
        "osSKU": "Ubuntu",
        "enableFips": true,
        "securityProfile": {
            "enableVTPM": true,
            "enableSecureBoot": true,
        }
    }
    ```
2. Deploy your template with vTPM, secure boot, and FIPS enabled on your cluster. To create the node pool with ACL, set `"osSKU": "AzureContainerLinux"`. See [Deploy an AKS cluster using an ARM template](/en-us/azure/aks/learn/quick-kubernetes-deploy-rm-template) for detailed instructions.

::: zone-end

::: zone pivot="bicep"

1. Create a Bicep file with Trusted Launch and FIPS parameters. Before creating the file, review the following parameters:

    - `enableSecureBoot`: Enables secure boot to authenticate an image signed by a trusted publisher.
    - `enableVTPM`: Enables vTPM and performs attestation by measuring the entire boot chain of your VM.
    - `enableFips`: Enables the FIPS-compliant node image for the node pool.
    - `osSKU`: Optional. Set to `AzureContainerLinux` to create an ACL node pool with Trusted Launch and FIPS enabled.

    In your Bicep file, provide values for `enableVTPM`, `enableSecureBoot`, and `enableFips`. The same schema used for CLI deployment exists in the `Microsoft.ContainerService/managedClusters/agentPools` definition under `properties`, as shown in the following example:

    ```bicep
    properties: {
      // ...
      osSKU: 'Ubuntu'
      enableFips: true
      securityProfile: {
        enableVTPM: true
        enableSecureBoot: true
      }
    }
    ```
2. Deploy your Bicep file with vTPM, secure boot, and FIPS enabled on your cluster. To create the node pool with ACL, set `osSKU: 'AzureContainerLinux'`. See [Deploy an AKS cluster using a Bicep file](/en-us/azure/aks/learn/quick-kubernetes-deploy-bicep) for detailed instructions.

::: zone-end

::: zone pivot="terraform"

The AzureRM (`azurerm`) Terraform provider doesn't support Trusted Launch because it doesn't expose Trusted Launch node pool settings. To add a node pool with Trusted Launch and FIPS enabled, use the Azure CLI, ARM template, or Bicep instructions in this article.

::: zone-end

::: zone pivot="azure-portal"

The Azure portal **doesn't support** adding a node pool with Trusted Launch and FIPS enabled. To add a node pool with Trusted Launch and FIPS enabled, use the Azure CLI, ARM template, or Bicep instructions in this article.

::: zone-end

## Enable vTPM or secure boot on an existing Linux node pool

You can enable vTPM, secure boot, or both on an existing standard Linux node pool that uses a Trusted Launch-capable Ubuntu or Azure Linux image. The node pool doesn't need to already use a Trusted Launch image, but it must meet the existing Trusted Launch requirements and limitations.

AKS reimages the node pool to a Trusted Launch image, which recreates the nodes and disrupts workloads. Perform the update during a maintenance window, and make sure your workloads tolerate node reimaging.

::: zone pivot="azure-cli"

1. Update a node pool to enable vTPM or secure boot using the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command. Before running the command, review the following parameters:

    - `--resource-group`: Enter the name of an existing resource group hosting your existing AKS cluster.
    - `--cluster-name`: Enter a unique name for the AKS cluster, such as *myAKSCluster*.
    - `--name`: Enter the name of your node pool, such as *mynodepool*.
    - `--enable-secure-boot`: Enables secure boot to authenticate that the image was signed by a trusted publisher.
    - `--enable-vtpm`: Enables vTPM and performs attestation by measuring the entire boot chain of your VM.

    Note

    Secure Boot requires signed boot loaders, OS kernels, and drivers. If after enabling secure boot your nodes don't start, you can verify which boot components are responsible for Secure Boot failures within an Azure Linux Virtual Machine. See [verify Secure Boot failures](/en-us/azure/virtual-machines/trusted-launch-faq#verify-secure-boot-failures).

    The following example updates the node pool *mynodepool* on *myAKSCluster* in *myResourceGroup* and enables vTPM:

    ```azurecli
    az aks nodepool update --cluster-name myAKSCluster --resource-group myResourceGroup --name mynodepool --enable-vtpm
    ```

    The following example updates the node pool *mynodepool* on *myAKSCluster* in *myResourceGroup* and enables secure boot:

    ```azurecli
    az aks nodepool update --cluster-name myAKSCluster --resource-group myResourceGroup --name mynodepool --enable-secure-boot
    ```

    The following example updates the node pool *mynodepool* on *myAKSCluster* in *myResourceGroup* and enables both vTPM and secure boot:

    ```azurecli
    az aks nodepool update \
        --cluster-name myAKSCluster \
        --resource-group myResourceGroup \
        --name mynodepool \
        --enable-vtpm \
        --enable-secure-boot
    ```
2. After the update completes, verify that your node pool uses a Trusted Launch image.

    Trusted Launch nodes have the following output:

    - Node image version containing `"TL"`, such as `"AKSUbuntu-2204-gen2TLcontainerd"`.
    - `"Security-type"` is `"Trusted Launch"`.

    ```bash
    kubectl get nodes
    kubectl describe node {node-name} | grep -e node-image-version -e security-type
    ```

::: zone-end

::: zone pivot="arm"

1. Update your ARM template with Trusted Launch parameters. Before updating the template, review the following parameters:

    - `enableSecureBoot`: Enables secure boot to authenticate an image signed by a trusted publisher.
    - `enableVTPM`: Enables vTPM and performs attestation by measuring the entire boot chain of your VM.

    In your template, set `enableVTPM`, `enableSecureBoot`, or both in the node pool `securityProfile`. The following example enables both vTPM and secure boot:

    ```json
    "properties": {
        ...,
        "securityProfile": {
            "enableVTPM": true,
            "enableSecureBoot": true,
        }
    }
    ```
2. Deploy your updated template with vTPM and secure boot enabled on your node pool. For detailed instructions, see [Deploy an AKS cluster using an ARM template](/en-us/azure/aks/learn/quick-kubernetes-deploy-rm-template).
3. After the deployment completes, verify that your node pool uses a Trusted Launch image.

    Trusted Launch nodes have the following output:

    - Node image version containing `"TL"`, such as `"AKSUbuntu-2204-gen2TLcontainerd"`.
    - `"Security-type"` is `"Trusted Launch"`.

    ```bash
    kubectl get nodes
    kubectl describe node {node-name} | grep -e node-image-version -e security-type
    ```

::: zone-end

::: zone pivot="bicep"

1. Update your Bicep file with Trusted Launch parameters. Before updating the file, review the following parameters:

    - `enableSecureBoot`: Enables secure boot to authenticate an image signed by a trusted publisher.
    - `enableVTPM`: Enables vTPM and performs attestation by measuring the entire boot chain of your VM.

    In your Bicep file, set `enableVTPM`, `enableSecureBoot`, or both in the node pool `securityProfile`. The following example enables both vTPM and secure boot:

    ```bicep
    properties: {
      // ...
      securityProfile: {
        enableVTPM: true
        enableSecureBoot: true
      }
    }
    ```
2. Deploy your updated Bicep file with vTPM and secure boot enabled on your node pool. For detailed instructions, see [Deploy an AKS cluster using a Bicep file](/en-us/azure/aks/learn/quick-kubernetes-deploy-bicep).
3. After the deployment completes, verify that your node pool uses a Trusted Launch image.

    Trusted Launch nodes have the following output:

    - Node image version containing `"TL"`, such as `"AKSUbuntu-2204-gen2TLcontainerd"`.
    - `"Security-type"` is `"Trusted Launch"`.

    ```bash
    kubectl get nodes
    kubectl describe node {node-name} | grep -e node-image-version -e security-type
    ```

::: zone-end

::: zone pivot="terraform"

The AzureRM (`azurerm`) Terraform provider doesn't support Trusted Launch because it doesn't expose Trusted Launch node pool settings. To enable vTPM or secure boot on an existing node pool, use the Azure CLI, ARM template, or Bicep instructions in this article.

::: zone-end

::: zone pivot="azure-portal"

The Azure portal **doesn't support** enabling vTPM or secure boot on an existing node pool. To enable vTPM or secure boot on an existing node pool, use the Azure CLI, ARM template, or Bicep instructions in this article.

::: zone-end

## Assign pods to nodes with Trusted Launch enabled

You can constrain a pod and restrict it to run on a specific node or nodes, or preference to nodes with Trusted Launch enabled. You can control this using the following node pool selector in your pod manifest.

```yml
spec:
  nodeSelector:
        kubernetes.azure.com/security-type = "TrustedLaunch"
```

## Disable vTPM or secure boot on an existing Linux node pool

You can disable vTPM, secure boot, or both on an existing Linux node pool. If either feature remains enabled, the node pool keeps using the Trusted Launch image path. If you disable both features on a regular Ubuntu or Azure Linux node pool, AKS reimages the node pool to the corresponding non-Trusted Launch image and changes the underlying Virtual Machine Scale Set security type back to Standard.

::: zone pivot="azure-cli"

1. Update a node pool to disable secure boot or vTPM by using the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command. Before running the command, review the following parameters:

    - `--resource-group`: Enter the name of an existing resource group hosting your existing AKS cluster.
    - `--cluster-name`: Enter a unique name for the AKS cluster, such as *myAKSCluster*.
    - `--name`: Enter the name of your node pool, such as *mynodepool*.
    - `--disable-secure-boot`: Disables secure boot.
    - `--disable-vtpm`: Disables vTPM.

    The following example updates the node pool *mynodepool* on *myAKSCluster* in *myResourceGroup* and disables vTPM:

    ```azurecli
    az aks nodepool update --cluster-name myAKSCluster --resource-group myResourceGroup --name mynodepool --disable-vtpm
    ```

    The following example updates the node pool *mynodepool* on *myAKSCluster* in *myResourceGroup* and disables secure boot:

    ```azurecli
    az aks nodepool update --cluster-name myAKSCluster --resource-group myResourceGroup --name mynodepool --disable-secure-boot
    ```

    The following example updates the node pool *mynodepool* on *myAKSCluster* in *myResourceGroup* and disables both vTPM and secure boot:

    ```azurecli
    az aks nodepool update \
        --cluster-name myAKSCluster \
        --resource-group myResourceGroup \
        --name mynodepool \
        --disable-vtpm \
        --disable-secure-boot
    ```
2. After the update completes, verify that your node pool uses the expected image.

    If either vTPM or secure boot remains enabled, Trusted Launch nodes have the following output:

    - Node image version containing `"TL"`, such as `"AKSUbuntu-2204-gen2TLcontainerd"`.
    - `"Security-type"` is `"Trusted Launch"`.

    If you disable both vTPM and secure boot, the node image version shouldn't contain `"TL"`, and `"Security-type"` shouldn't be `"Trusted Launch"`.

    ```bash
    kubectl get nodes
    kubectl describe node {node-name} | grep -e node-image-version -e security-type
    ```

::: zone-end

::: zone pivot="arm"

1. Update your ARM template with Trusted Launch parameters. Before updating the template, review the following parameters:

    - `enableSecureBoot`: Enables secure boot to authenticate an image signed by a trusted publisher.
    - `enableVTPM`: Enables vTPM and performs attestation by measuring the entire boot chain of your VM.

    In your template, set `enableVTPM`, `enableSecureBoot`, or both in the node pool `securityProfile`. The following example disables both vTPM and secure boot:

    ```json
    "properties": {
        ...,
        "securityProfile": {
            "enableVTPM": false,
            "enableSecureBoot": false,
        }
    }
    ```
2. Deploy your updated template with vTPM and secure boot disabled on your node pool. For detailed instructions, see [Deploy an AKS cluster using an ARM template](/en-us/azure/aks/learn/quick-kubernetes-deploy-rm-template).
3. After the deployment completes, verify that your node pool uses the expected image.

    If either vTPM or secure boot remains enabled, Trusted Launch nodes have the following output:

    - Node image version containing `"TL"`, such as `"AKSUbuntu-2204-gen2TLcontainerd"`.
    - `"Security-type"` is `"Trusted Launch"`.

    If you disable both vTPM and secure boot, the node image version shouldn't contain `"TL"`, and `"Security-type"` shouldn't be `"Trusted Launch"`.

    ```bash
    kubectl get nodes
    kubectl describe node {node-name} | grep -e node-image-version -e security-type
    ```

::: zone-end

::: zone pivot="bicep"

1. Update your Bicep file with Trusted Launch parameters. Before updating the file, review the following parameters:

    - `enableSecureBoot`: Enables secure boot to authenticate an image signed by a trusted publisher.
    - `enableVTPM`: Enables vTPM and performs attestation by measuring the entire boot chain of your VM.

    In your Bicep file, set `enableVTPM`, `enableSecureBoot`, or both in the node pool `securityProfile`. The following example disables both vTPM and secure boot:

    ```bicep
    properties: {
      // ...
      securityProfile: {
        enableVTPM: false
        enableSecureBoot: false
      }
    }
    ```
2. Deploy your updated Bicep file with vTPM and secure boot disabled on your node pool. For detailed instructions, see [Deploy an AKS cluster using a Bicep file](/en-us/azure/aks/learn/quick-kubernetes-deploy-bicep).
3. After the deployment completes, verify that your node pool uses the expected image.

    If either vTPM or secure boot remains enabled, Trusted Launch nodes have the following output:

    - Node image version containing `"TL"`, such as `"AKSUbuntu-2204-gen2TLcontainerd"`.
    - `"Security-type"` is `"Trusted Launch"`.

    If you disable both vTPM and secure boot, the node image version shouldn't contain `"TL"`, and `"Security-type"` shouldn't be `"Trusted Launch"`.

    ```bash
    kubectl get nodes
    kubectl describe node {node-name} | grep -e node-image-version -e security-type
    ```

::: zone-end

::: zone pivot="terraform"

The AzureRM (`azurerm`) Terraform provider doesn't support Trusted Launch because it doesn't expose Trusted Launch node pool settings. To disable vTPM or secure boot on an existing node pool, use the Azure CLI, ARM template, or Bicep instructions in this article.

::: zone-end

::: zone pivot="azure-portal"

The Azure portal **doesn't support** disabling vTPM or secure boot on an existing node pool. To disable vTPM or secure boot on an existing node pool, use the Azure CLI, ARM template, or Bicep instructions in this article.

::: zone-end