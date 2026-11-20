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
ms.date: 2026-11-17T00:00:00.0000000Z
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
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
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

::: zone pivot="bicep"

- Bicep CLI version 0.42.1 or later for the Windows node pool example. Run `az bicep version` to check your version. For installation instructions, see [Install Bicep tools](/en-us/azure/azure-resource-manager/bicep/install).

::: zone-end

- Secure Boot requires signed boot loaders, OS kernels, and drivers.

## Limitations

- AKS supports Trusted Launch on Kubernetes version 1.25.2 and higher.
- ACL node pools with Trusted Launch require AKS version 1.34 or later.
- Trusted Launch only supports [Azure Generation 2 VMs](/en-us/azure/virtual-machines/generation-2).
- Windows Trusted Launch is in preview and requires the `WindowsTrustedLaunchPreview` feature flag, Kubernetes version 1.32 or later, `osType: Windows`, `osSKU: Windows2025`, Virtual Machine Scale Sets, an x64 VM size that supports generation 2 and Trusted Launch, and FIPS enablement when creating the node pool.
- For Ubuntu and Azure Linux node pools, you can't enable Trusted Launch in the same node pool as [Arm64](use-arm64-vms), [Pod Sandboxing](use-pod-sandboxing), or [Confidential VM](use-cvm). Azure Container Linux (ACL) supports Trusted Launch on supported AMD64 VM sizes and supported Arm64 VM sizes. For more information, see [node images documentation](node-images).
- You can enable Trusted Launch in the same node pool as [FIPS](enable-fips-nodes) with Ubuntu 22.04, ACL, or Windows Server 2025. Windows Server 2025 enables FIPS by default.
- Trusted Launch doesn't support virtual node.
- Availability sets aren't supported, only Virtual Machine Scale Sets.
- To enable Secure Boot on GPU node pools using the Ubuntu operating system, you need to skip installing the GPU driver (`--gpu-driver None`). For more information, see [Skip GPU driver installation](gpu-cluster#skip-gpu-driver-installation) and [Use NVIDIA GPUs on Azure Kubernetes Service (AKS)](use-nvidia-gpu). This limitation doesn't apply for running GPU workloads with Azure Linux or Azure Container Linux operating systems.
- Ephemeral OS disks can be created with Trusted Launch and all regions are supported. However, not all virtual machines sizes are supported. For more information, see [Trusted Launch ephemeral OS sizes](/en-us/azure/virtual-machines/ephemeral-os-disks#trusted-launch-for-ephemeral-os-disks).
- [Flatcar Container Linux for AKS](flatcar-container-linux-for-aks) doesn't support Trusted Launch on AKS.
- Trusted Launch with Terraform requires AzureRM (`azurerm`) provider version 5.14.0 or later.

## Supported OS versions

The following table includes the supported OS versions for Trusted Launch-enabled node pools:

| OS type | OS SKU | Trusted Launch support | Default | Constraints |
| --- | --- | --- | --- | --- |
| Linux | Ubuntu | Supported | Disabled by default | Requires [Azure Generation 2 VMs](/en-us/azure/virtual-machines/generation-2). You can't combine Trusted Launch with [Arm64](use-arm64-vms), [Pod Sandboxing](use-pod-sandboxing), or [Confidential VM](use-cvm) in the same node pool. Trusted Launch and [FIPS](enable-fips-nodes) together are supported only with Ubuntu 22.04. |
| Linux | Azure Linux | Supported | Disabled by default | Requires [Azure Generation 2 VMs](/en-us/azure/virtual-machines/generation-2). You can't combine Trusted Launch with [Arm64](use-arm64-vms), [Pod Sandboxing](use-pod-sandboxing), or [Confidential VM](use-cvm) in the same node pool. |
| Linux | Azure Container Linux | Supported | Required | ACL requires Trusted Launch with Secure Boot and vTPM and always uses [Azure Generation 2 VMs](/en-us/azure/virtual-machines/generation-2). |
| Windows | Windows Server 2025 | Supported (preview) | Opt-in preview | Requires [Azure Generation 2 VMs](/en-us/azure/virtual-machines/generation-2), Kubernetes version 1.32 or later, and registration of the `WindowsTrustedLaunchPreview` feature flag. |

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

1. Create a Terraform configuration with Trusted Launch settings by using the [`azurerm_kubernetes_cluster`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) resource. Before creating the configuration, review the following parameters in the `default_node_pool.security` block:

    - `secure_boot_enabled`: Enables Secure Boot to authenticate an image signed by a trusted publisher.
    - `vtpm_enabled`: Enables vTPM and performs attestation by measuring the entire boot chain of your VM.

    The following example creates a cluster named *myAKSCluster* with one node in *myResourceGroup*, and enables Secure Boot and vTPM on the default node pool:

    ```terraform
    resource "azurerm_kubernetes_cluster" "example" {
      name                = "myAKSCluster"
      location            = azurerm_resource_group.example.location
      resource_group_name = azurerm_resource_group.example.name
      dns_prefix          = "myakscluster"
    
      default_node_pool {
        name       = "nodepool1"
        node_count = 1
        vm_size    = "Standard_D2s_v3"
    
        security {
          secure_boot_enabled = true
          vtpm_enabled        = true
        }
      }
    
      node_provisioning_profile {
        mode = "Manual"
      }
    
      identity {
        type = "SystemAssigned"
      }
    }
    ```
2. Apply your Terraform configuration by using the `terraform init`, `terraform plan`, and `terraform apply` commands. For detailed instructions, see [Deploy an AKS cluster using Terraform](/en-us/azure/aks/learn/quick-kubernetes-deploy-terraform).

::: zone-end

::: zone pivot="azure-portal"

The Azure portal **doesn't support** creating an AKS cluster with Trusted Launch enabled. To create an AKS cluster with Trusted Launch enabled, use the Azure CLI, ARM template, Bicep, or Terraform instructions in this article.

::: zone-end

## Add a Linux node pool with Trusted Launch enabled

When you create a node pool, enabling vTPM or Secure Boot automatically sets up your node pools to use the customized Trusted Launch image. This image is specifically configured to support the security features enabled by Trusted Launch.

::: zone pivot="azure-cli"

1. Add a Linux node pool with Trusted Launch enabled by using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command. Before running the command, review the following parameters:

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
    - The `kubernetes.azure.com/security-type` label is `TrustedLaunch`.

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

1. Create a Terraform configuration with Trusted Launch settings by using the [`azurerm_kubernetes_cluster_node_pool`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) resource. Before creating the configuration, review the following parameters in the `security` block:

    - `secure_boot_enabled`: Enables Secure Boot to authenticate an image signed by a trusted publisher.
    - `vtpm_enabled`: Enables vTPM and performs attestation by measuring the entire boot chain of your VM.

    The following example adds a node pool named *mynodepool* with three nodes, and enables vTPM and Secure Boot:

    ```terraform
    resource "azurerm_kubernetes_cluster_node_pool" "example" {
      name                  = "mynodepool"
      kubernetes_cluster_id = azurerm_kubernetes_cluster.example.id
      vm_size               = "Standard_D2s_v3"
      node_count            = 3
    
      security {
        secure_boot_enabled = true
        vtpm_enabled        = true
      }
    }
    ```
2. Apply your Terraform configuration by using the `terraform plan` and `terraform apply` commands.
3. Check that your node pool uses a Trusted Launch image.

    Trusted Launch nodes have the following output:

    - Node image version containing `"TL"`, such as `"AKSUbuntu-2204-gen2TLcontainerd"`.
    - `"Security-type"` is `"Trusted Launch"`.

    ```bash
    kubectl get nodes
    kubectl describe node {node-name} | grep -e node-image-version -e security-type
    ```

::: zone-end

::: zone pivot="azure-portal"

The Azure portal **doesn't support** adding a Linux node pool with Trusted Launch enabled. To add a Linux node pool with Trusted Launch enabled, use the Azure CLI, ARM template, Bicep, or Terraform instructions in this article.

::: zone-end

## Add a Windows Server node pool with Trusted Launch and FIPS enabled

Windows Server node pools with Trusted Launch enabled are currently in preview.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

Use an existing cluster configured for Windows node pools, including a Windows profile and Azure CNI networking. For the Windows profile requirement, see [Node pool limitations](create-node-pools#limitations).

Before you add a Windows node pool with Trusted Launch enabled, register the `WindowsTrustedLaunchPreview` feature flag on your subscription.

1. Register the `WindowsTrustedLaunchPreview` feature flag by using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command. Registration can take several minutes.

    ```azurecli
    az feature register \
        --namespace "Microsoft.ContainerService" \
        --name "WindowsTrustedLaunchPreview"
    ```
2. Verify the registration status by using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command.

    ```azurecli
    az feature show \
        --namespace "Microsoft.ContainerService" \
        --name "WindowsTrustedLaunchPreview" \
        --query "properties.state"
    ```
3. When the status is `Registered`, refresh the registration of the `Microsoft.ContainerService` resource provider by using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace "Microsoft.ContainerService"
    ```

::: zone pivot="azure-cli"

Use Azure CLI version 2.87.0 or later for this Windows Server 2025 procedure. Run `az --version` to check your version and `az upgrade` to upgrade.

1. Add a Windows Server 2025 node pool with Trusted Launch enabled using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command. Before running the command, review the following parameters:

    - `--cluster-name`: Enter the name of the AKS cluster.
    - `--resource-group`: Enter the name of an existing resource group to host the AKS cluster resource.
    - `--name`: Enter a unique name for the node pool. For Windows node pools, the length must be between 1 and 6 characters.
    - `--node-count`: The number of nodes in the Kubernetes agent pool. Default is 3.
    - `--os-type`: Set to `Windows`.
    - `--os-sku`: Set to `Windows2025`.
    - `--enable-secure-boot`: Enables Secure Boot to authenticate image signed by a trusted publisher.
    - `--enable-vtpm`: Enables vTPM and performs attestation by measuring the entire boot chain of your VM.
    - `--enable-fips-image`: Required for Windows Server 2025 node pools.

    The following example deploys a Windows Server 2025 node pool named *npwin* with vTPM, Secure Boot, and FIPS enabled on a cluster named *myAKSCluster*:

    ```azurecli
    az aks nodepool add \
        --resource-group myResourceGroup \
        --cluster-name myAKSCluster \
        --name npwin \
        --node-count 3 \
        --os-type Windows \
        --os-sku Windows2025 \
        --enable-fips-image \
        --enable-vtpm \
        --enable-secure-boot
    ```
2. Check that your node pool is using a Trusted Launch image.

    Trusted Launch Windows nodes have the following output:

    - Node image version containing `"tl"`, such as `"AKSWindows-2025-gen2-tl-26100.<build>.<YYMMDD>"`.
    - The `kubernetes.azure.com/security-type` label is `TrustedLaunch`.

    ```bash
    kubectl get nodes
    kubectl describe node {node-name} | grep -e node-image-version -e security-type
    ```

::: zone-end

::: zone pivot="arm"

1. Create a template with Trusted Launch and FIPS parameters. Before creating the template, review the following parameters:

    - `osType`: Set to `Windows`.
    - `osSKU`: Set to `Windows2025`.
    - `enableFIPS`: Enables the FIPS-compliant node image. Required for Windows Server 2025.
    - `enableSecureBoot`: Enables secure boot to authenticate an image signed by a trusted publisher.
    - `enableVTPM`: Enables vTPM and performs attestation by measuring the entire boot chain of your VM.

    In your template, configure the `properties` of the `Microsoft.ContainerService/managedClusters/agentPools` resource as shown in the following example. Use a generation 2 VM size that supports Trusted Launch:

    ```json
    {
        "properties": {
            "count": 3,
            "mode": "User",
            "osType": "Windows",
            "osSKU": "Windows2025",
            "vmSize": "Standard_D4s_v5",
            "type": "VirtualMachineScaleSets",
            "enableFIPS": true,
            "securityProfile": {
                "enableVTPM": true,
                "enableSecureBoot": true
            }
        }
    }
    ```
2. Deploy your template to add the Windows node pool to your cluster. See [Deploy an AKS cluster using an ARM template](/en-us/azure/aks/learn/quick-kubernetes-deploy-rm-template) for detailed deployment instructions.

::: zone-end

::: zone pivot="bicep"

Use an existing cluster configured for Windows node pools, including a Windows profile and Azure CNI networking. For the Windows profile requirement, see [Node pool limitations](create-node-pools#limitations).

1. Create a file named `windows-trusted-launch.bicep` with the following content. The example uses API version `2026-08-01` and adds a Windows Server 2025 user node pool to an existing cluster:

    ```bicep
    param clusterName string
    param nodePoolName string = 'npwin'
    param vmSize string = 'Standard_D4s_v5'
    
    resource aksCluster 'Microsoft.ContainerService/managedClusters@2026-08-01' existing = {
      name: clusterName
    }
    
    resource windowsNodePool 'Microsoft.ContainerService/managedClusters/agentPools@2026-08-01' = {
      parent: aksCluster
      name: nodePoolName
      properties: {
        count: 3
        mode: 'User'
        osType: 'Windows'
        osSKU: 'Windows2025'
        vmSize: vmSize
        type: 'VirtualMachineScaleSets'
        enableFIPS: true
        securityProfile: {
          enableVTPM: true
          enableSecureBoot: true
        }
      }
    }
    ```

    During preview, Bicep might report warning `BCP081` if its type catalog doesn't include API version `2026-08-01`. This warning means Bicep can't validate the resource properties against its type catalog; it doesn't prevent compiling or deploying the template.

    Use a generation 2 VM size that supports Trusted Launch and is available in your subscription and region. To use a different size, pass `vmSize=<vm-size>` to the deployment command.
2. Deploy the Bicep file to the resource group that contains your cluster. Replace `myResourceGroup` and `myAKSCluster` with your resource group and cluster names.

    ```azurecli
    az deployment group create \
        --resource-group myResourceGroup \
        --template-file windows-trusted-launch.bicep \
        --parameters clusterName=myAKSCluster
    ```
3. Verify that FIPS, Secure Boot, and vTPM are enabled on the node pool. Confirm that all three values are `true`. If you changed the `nodePoolName` parameter, replace `npwin` with that name.

    ```azurecli
    az aks nodepool show \
        --resource-group myResourceGroup \
        --cluster-name myAKSCluster \
        --name npwin \
        --query "{fips:enableFips,secureBoot:securityProfile.enableSecureBoot,vtpm:securityProfile.enableVtpm}" \
        --output table
    ```

::: zone-end

::: zone pivot="terraform"

This article doesn't include Terraform instructions for Windows Server node pools with Trusted Launch (preview). To add a Windows node pool with Trusted Launch enabled, use the Azure CLI, ARM template, or Bicep instructions in this article.

::: zone-end

::: zone pivot="azure-portal"

The Azure portal **doesn't support** adding a Windows node pool with Trusted Launch enabled. To add a Windows node pool with Trusted Launch enabled, use the Azure CLI, ARM template, or Bicep instructions in this article.

::: zone-end

## Add a Linux node pool with Trusted Launch and FIPS enabled

For Linux node pools, you can enable Trusted Launch and FIPS together for Ubuntu 22.04 and Azure Container Linux (ACL) node pools on Generation 2 VM sizes.

For Windows Server 2025 node pools, FIPS is enabled by default. To add a Windows Server 2025 node pool with Trusted Launch enabled, see Add a Windows Server node pool with Trusted Launch and FIPS enabled.

For FIPS-specific operations, such as disabling FIPS on an existing node pool, see [Enable Federal Information Processing Standard (FIPS) for Azure Kubernetes Service (AKS) node pools](enable-fips-nodes).

::: zone pivot="azure-cli"

1. Add a Linux node pool with Trusted Launch and FIPS enabled by using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command. Before running the command, review the following parameters:

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
    - The `kubernetes.azure.com/security-type` label is `TrustedLaunch`.

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

1. Create a Terraform configuration with Trusted Launch and FIPS settings by using the [`azurerm_kubernetes_cluster_node_pool`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) resource. Before creating the configuration, review the following parameters:

    - `secure_boot_enabled`: Enables Secure Boot to authenticate an image signed by a trusted publisher.
    - `vtpm_enabled`: Enables vTPM and performs attestation by measuring the entire boot chain of your VM.
    - `fips_enabled`: Enables the FIPS-compliant node image for the node pool.
    - `os_sku`: Set to `Ubuntu2204` to create an Ubuntu 22.04 node pool.

    The following example adds a node pool named *mynodepool* with three nodes, and enables vTPM, Secure Boot, and FIPS:

    ```terraform
    resource "azurerm_kubernetes_cluster_node_pool" "example" {
      name                  = "mynodepool"
      kubernetes_cluster_id = azurerm_kubernetes_cluster.example.id
      vm_size               = "Standard_D2s_v3"
      node_count            = 3
      os_sku                = "Ubuntu2204"
      fips_enabled          = true
    
      security {
        secure_boot_enabled = true
        vtpm_enabled        = true
      }
    }
    ```

    Note

    The AzureRM Terraform provider doesn't support the `AzureContainerLinux` OS SKU. To add an ACL node pool with Trusted Launch and FIPS enabled, use the Azure CLI, ARM template, or Bicep instructions in this article.
2. Apply your Terraform configuration by using the `terraform plan` and `terraform apply` commands.
3. Check that your node pool uses a Trusted Launch image.

    Trusted Launch nodes have the following output:

    - Node image version containing both `"TL"` and `"FIPS"`.
    - `"Security-type"` is `"Trusted Launch"`.

    ```bash
    kubectl get nodes
    kubectl describe node {node-name} | grep -e node-image-version -e security-type
    ```

::: zone-end

::: zone pivot="azure-portal"

The Azure portal **doesn't support** adding a node pool with Trusted Launch and FIPS enabled. To add a node pool with Trusted Launch and FIPS enabled, use the Azure CLI, ARM template, Bicep, or Terraform instructions in this article.

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
    - The `kubernetes.azure.com/security-type` label is `TrustedLaunch`.

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
    - The `kubernetes.azure.com/security-type` label is `TrustedLaunch`.

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
    - The `kubernetes.azure.com/security-type` label is `TrustedLaunch`.

    ```bash
    kubectl get nodes
    kubectl describe node {node-name} | grep -e node-image-version -e security-type
    ```

::: zone-end

::: zone pivot="terraform"

1. Update your Terraform configuration with Trusted Launch settings. Before updating the configuration, review the following parameters in the `security` block of your `azurerm_kubernetes_cluster_node_pool` resource, or the `default_node_pool.security` block of your `azurerm_kubernetes_cluster` resource:

    - `secure_boot_enabled`: Enables Secure Boot to authenticate an image signed by a trusted publisher.
    - `vtpm_enabled`: Enables vTPM and performs attestation by measuring the entire boot chain of your VM.

    Set `vtpm_enabled`, `secure_boot_enabled`, or both. The following example enables both vTPM and Secure Boot on an existing node pool:

    ```terraform
    resource "azurerm_kubernetes_cluster_node_pool" "example" {
      # ...
    
      security {
        secure_boot_enabled = true
        vtpm_enabled        = true
      }
    }
    ```
2. Apply your updated Terraform configuration by using the `terraform plan` and `terraform apply` commands. Terraform updates the node pool in place, and AKS reimages the nodes.
3. After the update completes, verify that your node pool uses a Trusted Launch image.

    Trusted Launch nodes have the following output:

    - Node image version containing `"TL"`, such as `"AKSUbuntu-2204-gen2TLcontainerd"`.
    - `"Security-type"` is `"Trusted Launch"`.

    ```bash
    kubectl get nodes
    kubectl describe node {node-name} | grep -e node-image-version -e security-type
    ```

::: zone-end

::: zone pivot="azure-portal"

The Azure portal **doesn't support** enabling vTPM or secure boot on an existing node pool. To enable vTPM or secure boot on an existing node pool, use the Azure CLI, ARM template, Bicep, or Terraform instructions in this article.

::: zone-end

## Assign pods to nodes with Trusted Launch enabled

You can constrain a pod and restrict it to run on a specific node or nodes, or preference to nodes with Trusted Launch enabled. You can control this using the following node pool selector in your pod manifest.

```yml
spec:
  nodeSelector:
    kubernetes.azure.com/security-type: TrustedLaunch
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
    - The `kubernetes.azure.com/security-type` label is `TrustedLaunch`.

    If you disable both vTPM and secure boot, the node image version shouldn't contain `"TL"`, and the `kubernetes.azure.com/security-type` label shouldn't be `TrustedLaunch`.

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
    - The `kubernetes.azure.com/security-type` label is `TrustedLaunch`.

    If you disable both vTPM and secure boot, the node image version shouldn't contain `"TL"`, and the `kubernetes.azure.com/security-type` label shouldn't be `TrustedLaunch`.

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
    - The `kubernetes.azure.com/security-type` label is `TrustedLaunch`.

    If you disable both vTPM and secure boot, the node image version shouldn't contain `"TL"`, and the `kubernetes.azure.com/security-type` label shouldn't be `TrustedLaunch`.

    ```bash
    kubectl get nodes
    kubectl describe node {node-name} | grep -e node-image-version -e security-type
    ```

::: zone-end

::: zone pivot="terraform"

1. Update your Terraform configuration with Trusted Launch settings. Before updating the configuration, review the following parameters in the `security` block of your `azurerm_kubernetes_cluster_node_pool` resource, or the `default_node_pool.security` block of your `azurerm_kubernetes_cluster` resource:

    - `secure_boot_enabled`: Set to `false` to disable Secure Boot.
    - `vtpm_enabled`: Set to `false` to disable vTPM.

    The following example disables both vTPM and Secure Boot. Removing the `security` block also disables both features.

    ```terraform
    resource "azurerm_kubernetes_cluster_node_pool" "example" {
      # ...
    
      security {
        secure_boot_enabled = false
        vtpm_enabled        = false
      }
    }
    ```
2. Apply your updated Terraform configuration by using the `terraform plan` and `terraform apply` commands.
3. After the update completes, verify that your node pool uses the expected image.

    If either vTPM or secure boot remains enabled, Trusted Launch nodes have the following output:

    - Node image version containing `"TL"`, such as `"AKSUbuntu-2204-gen2TLcontainerd"`.
    - `"Security-type"` is `"Trusted Launch"`.

    If you disable both vTPM and secure boot, the node image version shouldn't contain `"TL"`, and `"Security-type"` shouldn't be `"Trusted Launch"`.

    ```bash
    kubectl get nodes
    kubectl describe node {node-name} | grep -e node-image-version -e security-type
    ```

::: zone-end

::: zone pivot="azure-portal"

The Azure portal **doesn't support** disabling vTPM or secure boot on an existing node pool. To disable vTPM or secure boot on an existing node pool, use the Azure CLI, ARM template, Bicep, or Terraform instructions in this article.

::: zone-end

## Clean up resources

Remove test workloads before deleting their node pool. If you added a test node pool to an existing cluster, delete only that test node pool by using the [`az aks nodepool delete`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-delete) command. Replace `<node-pool-name>` with the name of the test node pool you created, such as `npwin` or `mynodepool`. Don't delete node pools that host workloads you need to keep.

```azurecli
az aks nodepool delete \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name <node-pool-name>
```

If you created a cluster and resource group solely for this article, delete the test resource group by using the [`az group delete`](/en-us/cli/azure/group#az-group-delete) command. **This command deletes every resource in the resource group. Don't run it against a shared or pre-existing resource group.**

```azurecli
az group delete --name myResourceGroup --yes --no-wait
```