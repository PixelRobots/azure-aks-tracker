---
layout: Conceptual
title: Enable host-based encryption on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/enable-host-encryption
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
description: Learn how to configure a host-based encryption in an Azure Kubernetes Service (AKS) cluster.
ms.topic: how-to
ms.subservice: aks-security
ms.date: 2023-07-17T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: devx-track-azurecli
ms.devlang: azurecli
locale: en-us
document_id: f6b855ec-5997-a0bc-e37b-979140004a72
document_version_independent_id: 94d9293b-48c5-bc77-90eb-fc379b6a272c
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/enable-host-encryption.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/enable-host-encryption
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/enable-host-encryption.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 73ee594f-34f7-a92c-09c1-5c423845a5dc
---

# Enable host-based encryption on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

With host-based encryption, the data stored on the VM host of your AKS agent nodes' VMs is encrypted at rest and flows encrypted to the Storage service. This means the temp disks are encrypted at rest with platform-managed keys. The cache of OS and data disks is encrypted at rest with either platform-managed keys or customer-managed keys depending on the encryption type set on those disks.

By default, when using AKS, OS and data disks use server-side encryption with platform-managed keys. The caches for these disks are encrypted at rest with platform-managed keys. You can specify your own managed keys following [Bring your own keys (BYOK) with Azure disks in Azure Kubernetes Service](azure-disk-customer-managed-keys). The caches for these disks are also encrypted using the key you specify.

Host-based encryption is different than server-side encryption (SSE), which is used by Azure Storage. Azure managed disks use Azure Storage to automatically encrypt data at rest when saving data. Host-based encryption uses the host of the VM to handle encryption before the data flows through Azure Storage.

## Before you begin

Before you begin, review the following prerequisites and limitations.

### Prerequisites

- Ensure you have the CLI extension v2.23 or higher installed.

### Limitations

- This feature can only be set at cluster or node pool creation time.
- This feature can only be enabled in [Azure regions](/en-us/azure/virtual-machines/disk-encryption#supported-regions) that support server-side encryption of Azure managed disks and only with specific [supported VM sizes](/en-us/azure/virtual-machines/disk-encryption#supported-vm-sizes).
- This feature requires an AKS cluster and node pool based on Virtual Machine Scale Sets as *VM set type*.

## Enable Encryption at Host for your AKS cluster

Before adding a node pool with host-based encryption, ensure the EncryptionAtHost feature is enabled for your subscription:

```azurecli
# Register the EncryptionAtHost feature
az feature register --namespace Microsoft.Compute --name EncryptionAtHost

# Wait for registration to complete (this may take several minutes)
az feature show --namespace Microsoft.Compute --name EncryptionAtHost --query "properties.state"

# Refresh the provider registration
az provider register --namespace Microsoft.Compute
```

## Use host-based encryption on new clusters

- Create a new cluster and configure the cluster agent nodes to use host-based encryption using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--enable-encryption-at-host` flag.

    ```shell
    az aks create \
        --name myAKSCluster \
        --resource-group myResourceGroup \
        --node-vm-size Standard_DS2_v2 \
        --location westus2 \
        --enable-encryption-at-host \
        --generate-ssh-keys
    ```

## Use host-based encryption on existing clusters

- Enable host-based encryption on an existing cluster by adding a new node pool using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command with the `--enable-encryption-at-host` flag.

    ```azurecli
    az aks nodepool add --name hostencrypt --cluster-name $MY_AKS_CLUSTER --resource-group $MY_RESOURCE_GROUP -s Standard_DS2_v2 --enable-encryption-at-host
    ```

    Results:

    ```output
    {
        "agentPoolProfile": {
            "enableEncryptionAtHost": true,
            "name": "hostencrypt",
            "nodeCount": 1,
            "osDiskSizeGB": 30,
            "vmSize": "Standard_DS2_v2"
        },
        ...
    }
    ```