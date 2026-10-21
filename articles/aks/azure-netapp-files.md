---
layout: Conceptual
title: Configure Azure NetApp Files for Azure Kubernetes Service - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/azure-netapp-files
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
description: Learn how to configure Azure NetApp Files for an Azure Kubernetes Service cluster.
ms.topic: concept-article
ms.custom: devx-track-azurecli
ms.subservice: aks-storage
ms.date: 2023-05-08T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 40b89071-b0fa-c9c6-a1ac-403ee2b6f54a
document_version_independent_id: 7702a423-a6df-20ba-11be-0fd2caa8a622
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/azure-netapp-files.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/azure-netapp-files
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/azure-netapp-files.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/817763f1-a87f-4500-8c55-f33726ccb985
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/96abba6e-173c-4fc4-bcc8-79d583b4fe9f
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 67c61a2e-fca9-a085-5dcd-041eab4d1ce6
---

# Configure Azure NetApp Files for Azure Kubernetes Service - Azure Kubernetes Service | Microsoft Learn

A persistent volume represents a piece of storage that has been provisioned for use with Kubernetes pods. A persistent volume can be used by one or many pods, and it can be statically or dynamically provisioned. This article shows you how to configure [Azure NetApp Files](/en-us/azure/azure-netapp-files/azure-netapp-files-introduction) to be used by pods on an Azure Kubernetes Service (AKS) cluster.

[Azure NetApp Files](/en-us/azure/azure-netapp-files/azure-netapp-files-introduction) is an enterprise-class, high-performance, metered file storage service running on Azure and supports volumes using [NFS](azure-netapp-files-nfs) (NFSv3 or NFSv4.1), [SMB](azure-netapp-files-smb), and [dual-protocol](azure-netapp-files-dual-protocol) (NFSv3 and SMB, or NFSv4.1 and SMB). Kubernetes users have two options for using Azure NetApp Files volumes for Kubernetes workloads:

- Create Azure NetApp Files volumes **statically**. In this scenario, the creation of volumes is external to AKS. Volumes are created using the Azure CLI or from the Azure portal, and are then exposed to Kubernetes by the creation of a `PersistentVolume`. Statically created Azure NetApp Files volumes have many limitations (for example, inability to be expanded, needing to be over-provisioned, and so on). Statically created volumes aren't recommended for most use cases.
- Create Azure NetApp Files volumes **dynamically**, orchestrating through Kubernetes. This method is the **preferred** way to create multiple volumes directly through Kubernetes, and is achieved using [Trident](https://docs.netapp.com/us-en/trident/index.html). Trident is a CSI-compliant dynamic storage orchestrator that helps provision volumes natively through Kubernetes.

Note

Dual-protocol volumes can only be created **statically**. For more information on using dual-protocol volumes with Azure Kubernetes Service, see [Provision Azure NetApp Files dual-protocol volumes for Azure Kubernetes Service](azure-netapp-files-dual-protocol).

Using a CSI driver to directly consume Azure NetApp Files volumes from AKS workloads is the recommended configuration for most use cases. This requirement is accomplished using Trident, an open-source dynamic storage orchestrator for Kubernetes. Trident is an enterprise-grade storage orchestrator purpose-built for Kubernetes, and fully supported by NetApp. It simplifies access to storage from Kubernetes clusters by automating storage provisioning.

You can take advantage of Trident's Container Storage Interface (CSI) driver for Azure NetApp Files to abstract underlying details and create, expand, and snapshot volumes on-demand.

Important

Open-source software is mentioned throughout AKS documentation and samples. Software that you deploy is excluded from AKS service-level agreements, limited warranty, and Azure support. As you use open-source technology alongside AKS, consult the support options available from the respective communities and project maintainers to develop a plan.

Microsoft takes responsibility for building the open-source packages that we deploy on AKS. That responsibility includes having complete ownership of the build, scan, sign, validate, and hotfix process, along with control over the binaries in container images. For more information, see [Vulnerability management for AKS](concepts-vulnerability-management#aks-container-images) and [AKS support coverage](support-policies#aks-support-coverage).

## Before you begin

The following considerations apply when you use Azure NetApp Files:

- Your AKS cluster must be [in a region that supports Azure NetApp Files](https://azure.microsoft.com/global-infrastructure/services/?products=netapp&amp;regions=all).
- The Azure CLI version 2.0.59 or higher installed and configured. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- After the initial deployment of an AKS cluster, you can choose to provision Azure NetApp Files volumes statically or dynamically.
- To use dynamic provisioning with Azure NetApp Files with Network File System (NFS), install and configure [Trident](https://docs.netapp.com/us-en/trident/index.html) version 19.07 or higher. To use dynamic provisioning with Azure NetApp Files with Secure Message Block (SMB), install and configure Trident version 22.10 or higher. Dynamic provisioning for SMB shares is only supported on windows worker nodes.
- Before you deploy Azure NetApp Files SMB volumes, you must identify the AD DS integration requirements for Azure NetApp Files to ensure that Azure NetApp Files is well connected to AD DS. For more information, see [Understand guidelines for Active Directory Domain Services site design and planning](/en-us/azure/azure-netapp-files/understand-guidelines-active-directory-domain-service-site). Both the AKS cluster and Azure NetApp Files must have connectivity to the same AD.

## Configure Azure NetApp Files for AKS workloads

This section describes how to set up Azure NetApp Files for AKS workloads. It's applicable for all scenarios within this article.

1. Define variables for later usage. Replace *myresourcegroup*, *mylocation*, *myaccountname*, *mypool1*, *poolsize*, *premium*, *myvnet*, *myANFSubnet*, and *myprefix* with appropriate values for your environment.

    ```azurecli
    RESOURCE_GROUP="myresourcegroup"
    LOCATION="mylocation"
    ANF_ACCOUNT_NAME="myaccountname"
    POOL_NAME="mypool1"
    SIZE="poolsize" # size in TiB
    SERVICE_LEVEL="Premium" # valid values are Standard, Premium and Ultra
    VNET_NAME="myvnet"
    SUBNET_NAME="myANFSubnet"
    ADDRESS_PREFIX="myprefix"
    ```
2. Register the *Microsoft.NetApp* resource provider by running the following command:

    ```azurecli
    az provider register --namespace Microsoft.NetApp --wait
    ```

    Note

    This operation can take several minutes to complete.
3. Create a new account by using the command [`az netappfiles account create`](/en-us/cli/azure/netappfiles/account#az-netappfiles-account-create). When you create an Azure NetApp account for use with AKS, you can create the account in an existing resource group or create a new one in the same region as the AKS cluster.

    ```azurecli
    az netappfiles account create \
        --resource-group $RESOURCE_GROUP \
        --location $LOCATION \
        --account-name $ANF_ACCOUNT_NAME
    ```
4. Create a new capacity pool by using the command [`az netappfiles pool create`](/en-us/cli/azure/netappfiles/pool#az-netappfiles-pool-create). Replace the variables shown in the command with your Azure NetApp Files information. The `account_name` should be the same as created in Step 3.

    ```azurecli
    az netappfiles pool create \
        --resource-group $RESOURCE_GROUP \
        --location $LOCATION \
        --account-name $ANF_ACCOUNT_NAME \
        --pool-name $POOL_NAME \
        --size $SIZE \
        --service-level $SERVICE_LEVEL
    ```
5. Create a subnet to [delegate to Azure NetApp Files](/en-us/azure/azure-netapp-files/azure-netapp-files-delegate-subnet) using the command [`az network vnet subnet create`](/en-us/cli/azure/network/vnet/subnet#az-network-vnet-subnet-create). Specify the resource group hosting the existing virtual network for your AKS cluster. Replace the variables shown in the command with your Azure NetApp Files information.

    Note

    This subnet must be in the same virtual network as your AKS cluster.

    ```azurecli
    az network vnet subnet create \
        --resource-group $RESOURCE_GROUP \
        --vnet-name $VNET_NAME \
        --name $SUBNET_NAME \
        --delegations "Microsoft.Netapp/volumes" \
        --address-prefixes $ADDRESS_PREFIX
    ```

## Statically or dynamically provision Azure NetApp Files volumes for NFS or SMB

After you configure Azure NetApp Files for AKS workloads, you can statically or dynamically provision Azure NetApp Files using NFS, SMB, or dual-protocol volumes within the capacity pool. Follow instructions in:

- [Provision Azure NetApp Files NFS volumes for Azure Kubernetes Service](azure-netapp-files-nfs)
- [Provision Azure NetApp Files SMB volumes for Azure Kubernetes Service](azure-netapp-files-smb)
- [Provision Azure NetApp Files dual-protocol volumes for Azure Kubernetes Service](azure-netapp-files-dual-protocol)