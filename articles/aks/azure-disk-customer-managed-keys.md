---
layout: Conceptual
title: Use a customer-managed key to encrypt Azure managed disks in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/azure-disk-customer-managed-keys
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
description: Bring your own keys (BYOK) to encrypt managed OS and data disks in AKS.
ms.topic: concept-article
ms.custom: devx-track-azurecli
ms.subservice: aks-storage
ms.date: 2024-02-01T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 649ea5fd-2765-916a-3663-d51fd65c91a7
document_version_independent_id: 11e1c48c-cdff-598e-6b46-b0416cd1ab62
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/azure-disk-customer-managed-keys.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/azure-disk-customer-managed-keys
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/azure-disk-customer-managed-keys.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: ef88ae21-8d86-4568-148f-ff12b3d06ac1
---

# Use a customer-managed key to encrypt Azure managed disks in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Azure encrypts all data in a managed disk at rest. By default, data is encrypted with Microsoft-managed keys. For more control over encryption keys, you can supply customer-managed keys to use for encryption at rest for both the OS and data disks for your AKS clusters.

Learn more about customer-managed keys on [Linux](/en-us/azure/virtual-machines/disk-encryption#customer-managed-keys) and [Windows](/en-us/azure/virtual-machines/disk-encryption#customer-managed-keys).

## Prerequisites

- You must enable soft delete and purge protection for *Azure Key Vault* when using Key Vault to encrypt managed disks.
- You need the Azure CLI version 2.11.1 or later.
- Data disk encryption and customer-managed keys are supported on Kubernetes versions 1.24 and higher.
- If you choose to rotate (change) your keys periodically, see [Customer-managed keys and encryption of Azure managed disk](/en-us/azure/virtual-machines/disk-encryption) for more information.

## Limitations

- Encryption of an OS disk with customer-managed keys can only be enabled when creating an AKS cluster.
- Virtual nodes are not supported.
- When encrypting an ephemeral OS disk-enabled node pool with customer-managed keys, if you want to rotate the key in Azure Key Vault, there are two options to consider:

    - Immediate usage of new CMK

        - Scale down the node pool count to 0.
        - Rotate the key.
        - Scale up the node pool to the original count.
    - Gradual usage of new CMK

        - Allow AKS node image upgrades or version upgrades to naturally adopt the new CMK over time.
        - Until all nodes in the pool are upgraded, the existing CMK will continue to function without disruption.
        - Once the upgrade process is complete across all nodes, the new CMK takes effect seamlessly.

## Create an Azure Key Vault instance

Use an Azure Key Vault instance to store your keys. You can optionally use the Azure portal to [Configure customer-managed keys with Azure Key Vault](/en-us/azure/storage/common/customer-managed-keys-configure-key-vault)

Create a new *resource group*, then create a new *Key Vault* instance and enable soft delete and purge protection. Ensure you use the same region and resource group names for each command.

```azurecli
# Optionally retrieve Azure region short names for use on upcoming commands
az account list-locations
```

```azurecli
# Create new resource group in a supported Azure region
az group create --location myAzureRegionName --name myResourceGroup

# Create an Azure Key Vault resource in a supported Azure region
az keyvault create --name myKeyVaultName --resource-group myResourceGroup --location myAzureRegionName  --enable-purge-protection true
```

## Create an instance of a DiskEncryptionSet

Replace *myKeyVaultName* with the name of your key vault. You also need a *key* stored in Azure Key Vault to complete the following steps. Either store your existing Key in the Key Vault you created on the previous steps, or [generate a new key](/en-us/azure/key-vault/general/manage-with-cli2) and replace *myKeyName* with the name of your key.

Note

For cross-account access support for customer-managed encryption keys, you need to create the DiskEncryptionSet for cross-tenant customer-managed keys as detailed in [this guide](/en-us/azure/virtual-machines/disks-cross-tenant-customer-managed-keys?tabs=azure-cli#create-a-disk-encryption-set). The remaining storage class configuration is the same as normal customer managed keys.

```azurecli
# Retrieve the Key Vault Id and store it in a variable
keyVaultId=$(az keyvault show --name myKeyVaultName --query "[id]" -o tsv)

# Retrieve the Key Vault key URL and store it in a variable
keyVaultKeyUrl=$(az keyvault key show --vault-name myKeyVaultName --name myKeyName --query "[key.kid]" -o tsv)

# Create a DiskEncryptionSet
az disk-encryption-set create --name myDiskEncryptionSetName --location myAzureRegionName --resource-group myResourceGroup --source-vault $keyVaultId --key-url $keyVaultKeyUrl
```

Important

Make sure that the DiskEncryptionSet is located in the same region as your AKS cluster and that the AKS cluster identity has **read** access to the DiskEncryptionSet.

## Grant the DiskEncryptionSet access to key vault

Use the DiskEncryptionSet and resource groups you created on the prior steps, and grant the DiskEncryptionSet resource access to the Azure Key Vault.

```azurecli
# Retrieve the DiskEncryptionSet value and set a variable
desIdentity=$(az disk-encryption-set show --name myDiskEncryptionSetName --resource-group myResourceGroup --query "[identity.principalId]" -o tsv)

# Retrieve the Key Vault resource ID and set a variable
keyVaultId=$(az keyvault show --name myKeyVaultName --resource-group myResourceGroup --query "id" -o tsv)

# Grant the DiskEncryptionSet identity access to Key Vault
az role assignment create --assignee-object-id $desIdentity --assignee-principal-type ServicePrincipal --role "Key Vault Crypto Service Encryption User" --scope $keyVaultId
```

## Create a new AKS cluster and encrypt the OS disk

Either create a new resource group, or select an existing resource group hosting other AKS clusters, then use your key to encrypt either using network-attached OS disks or ephemeral OS disk. By default, a cluster uses ephemeral OS disk when possible in conjunction with VM size and OS disk size.

Run the following command to retrieve the DiskEncryptionSet value and set a variable:

```azurecli
diskEncryptionSetId=$(az disk-encryption-set show --name mydiskEncryptionSetName --resource-group myResourceGroup --query "[id]" -o tsv)
```

If you want to create a new resource group for the cluster, run the following command:

```azurecli
az group create --name myResourceGroup --location myAzureRegionName
```

To create a regular cluster using network-attached OS disks encrypted with your key, you can do so by specifying the `--node-osdisk-type=Managed` argument.

```azurecli
az aks create --name myAKSCluster --resource-group myResourceGroup --node-osdisk-diskencryptionset-id $diskEncryptionSetId --generate-ssh-keys --node-osdisk-type Managed
```

To create a cluster with ephemeral OS disk encrypted with your key, you can do so by specifying the `--node-osdisk-type=Ephemeral` argument. You also need to specify the argument `--node-vm-size` because the default vm size is too small and doesn't support ephemeral OS disk.

```azurecli
az aks create --name myAKSCluster --resource-group myResourceGroup --node-osdisk-diskencryptionset-id $diskEncryptionSetId --generate-ssh-keys --node-osdisk-type Ephemeral --node-vm-size Standard_DS3_v2
```

When new node pools are added to the cluster, the customer-managed key provided during the create process is used to encrypt the OS disk. The following example shows how to deploy a new node pool with an ephemeral OS disk.

```azurecli
az aks nodepool add --cluster-name $CLUSTER_NAME --resource-group $RG_NAME --name $NODEPOOL_NAME --node-osdisk-type Ephemeral
```

Important

The DiskEncryptionSet we previously applied to the storage class only encrypts new PVCs. Encrypting existing PVCs requires detaching first before using the Azure Disks API/CLI to update the underlying disks, as shown in [this related guide](/en-us/azure/virtual-machines/linux/disks-enable-customer-managed-keys-cli#encrypt-existing-managed-disks).

## Encrypt your AKS cluster data disk

If you have already provided a disk encryption set during cluster creation, encrypting data disks with the same disk encryption set is the default option. Therefore, this step is optional. However, if you want to encrypt data disks with a different disk encryption set, you can follow these steps.

Important

Ensure you have the proper AKS credentials. The AKS cluster identity needs **Reader** access to the DiskEncryptionSet. Otherwise, you get an error suggesting that the managed identity doesn't have permissions.

To assign the AKS cluster identity the Reader role on the DiskEncryptionSet, run the following commands:

```azurecli
aksIdentity=$(az aks show --resource-group $RG_NAME --name $CLUSTER_NAME --query "identity.principalId" -o tsv)
az role assignment create --role "Reader" --assignee $aksIdentity --scope $diskEncryptionSetId
```

Create a file called **byok-azure-disk.yaml** that contains the following information. Replace *myAzureSubscriptionId*, *myResourceGroup*, and *myDiskEncrptionSetName* with your values, and apply the yaml. Make sure to use the resource group where your DiskEncryptionSet is deployed.

```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: byok
provisioner: disk.csi.azure.com # replace with "kubernetes.io/azure-disk" if aks version is less than 1.21
parameters:
  skuname: StandardSSD_LRS
  kind: managed
  diskEncryptionSetID: "/subscriptions/{myAzureSubscriptionId}/resourceGroups/{myResourceGroup}/providers/Microsoft.Compute/diskEncryptionSets/{myDiskEncryptionSetName}"
```

Next, run the following commands to update your AKS cluster:

```azurecli
# Get credentials
az aks get-credentials --name myAksCluster --resource-group myResourceGroup --output table

# Update cluster
kubectl apply -f byok-azure-disk.yaml
```