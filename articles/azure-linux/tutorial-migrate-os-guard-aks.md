---
layout: Conceptual
title: 'Tutorial: Migrate Nodes to Azure Linux with OS Guard (Preview) | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/tutorial-migrate-os-guard-aks
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/133/azure
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/79b1327d-d925-ec11-b6e6-000d3a4f06a4
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
manager: kumud
description: In this Azure Linux tutorial, you learn how to migrate nodes to Azure Linux with OS Guard (Preview) for Azure Kubernetes Service (AKS).
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: tutorial
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: e973a065-e0e2-38d8-c1f2-84be5c60268e
document_version_independent_id: ac8bc957-2276-360c-6443-3e73663a2042
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/tutorial-migrate-os-guard-aks.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/tutorial-migrate-os-guard-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/tutorial-migrate-os-guard-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 5f17fb98-7dca-9350-65dc-32430c978b34
---

# Tutorial: Migrate Nodes to Azure Linux with OS Guard (Preview) | Microsoft Learn

Important

Starting on **December 10, 2026**, Azure Kubernetes Service (AKS) no longer supports Azure Linux with OS Guard for AKS (preview). At that point, AKS no longer produces new Azure Linux with OS Guard node images or provides security patches, and you can no longer create new node pools with Azure Linux with OS Guard. On **March 10, 2027**, AKS removes all existing Azure Linux with OS Guard node images, which causes scaling and remediation (reimage and redeploy) operations to fail. To avoid disruption, migrate to [Azure Container Linux (ACL)](azure-container-linux-overview). For more information about this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/5950) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates/?id=571257). To stay informed about announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Note

Azure Linux with OS Guard (preview) is being replaced by Azure Container Linux (ACL).

Azure Container Linux is the long‑term, immutable, container‑optimized Linux operating system (OS) for Azure Kubernetes Service (AKS). It provides a secure, minimal, and operationally consistent host OS designed to run containerized workloads at scale.

For more information, see the [Azure Container Linux (ACL) overview](azure-container-linux-overview).

In this tutorial, part *three of five*, you migrate your existing nodes to Azure Linux with OS Guard. You can migrate your existing nodes using one of the following methods:

- Remove existing node pools and add new OS Guard node pools.
- Perform an in-place operating system (OS) SKU migration.

If you don't have any existing nodes to migrate, skip to the [next tutorial](tutorial-monitor-os-guard-aks). In later tutorials, you learn how to enable telemetry and monitoring in your clusters and upgrade Azure Linux with OS Guard nodes.

## Azure Linux with OS Guard considerations and limitations

Before you begin, review the following considerations and limitations for Azure Linux with OS Guard (preview):

- Kubernetes version 1.32.0 or higher is required for Azure Linux with OS Guard.
- All Azure Linux with OS Guard images have [Federal Information Process Standard (FIPS)](/en-us/azure/aks/enable-fips-nodes) and [Trusted Launch](/en-us/azure/aks/use-trusted-launch) enabled.
- Azure CLI and ARM templates are the only supported deployment methods for Azure Linux with OS Guard on AKS in preview. PowerShell and Terraform aren't supported.
- [Arm64](/en-us/azure/aks/use-arm64-vms) images aren't supported with Azure Linux with OS Guard on AKS in preview.
- `NodeImage` and `None` are the only supported [operating system (OS) upgrade channels](/en-us/azure/aks/auto-upgrade-node-os-image) for Azure Linux with OS Guard on AKS. `Unmanaged` and `SecurityPatch` are incompatible with Azure Linux with OS Guard due to the immutable /usr directory.
- [Artifact Streaming](/en-us/azure/aks/artifact-streaming) isn't supported.
- [Pod Sandboxing](/en-us/azure/aks/use-pod-sandboxing) isn't supported.
- [Confidential Virtual Machines (CVMs)](/en-us/azure/aks/confidential-containers-overview) aren't supported.
- [Gen 1 virtual machines (VMs)](/en-us/azure/aks/aks-virtual-machine-sizes#vm-support-on-aks) aren't supported.

## Prerequisites

- In the previous tutorial, you created and deployed an Azure Linux with OS Guard cluster. If you haven't completed these steps and want to follow along, see [Tutorial 1: Create a cluster with Azure Linux with OS Guard for AKS](tutorial-create-cluster-os-guard-aks).
- You need the latest version of Azure CLI. Use the [`az version`](/en-us/cli/azure/reference-index?#az-version) command to find the version. To upgrade to the latest version, use the [`az upgrade`](/en-us/cli/azure/reference-index?#az-upgrade) command.

### Install the `aks-preview` Azure CLI extension

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

Install the `aks-preview` extension using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command.

```azurecli
az extension add --name aks-preview
```

Update to the latest version of the extension using the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command.

```azurecli
az extension update --name aks-preview
```

### Register the `AzureLinuxOSGuardPreview` feature flag

1. Register the `AzureLinuxOSGuardPreview` feature flag using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

    ```azurecli
    az feature register --namespace "Microsoft.ContainerService" --name "AzureLinuxOSGuardPreview"
    ```

    It takes a few minutes for the status to show *Registered*.
2. Verify the registration status using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command.

    ```azurecli
    az feature show --namespace "Microsoft.ContainerService" --name "AzureLinuxOSGuardPreview"
    ``
    
    ```
3. When the status reflects *Registered*, refresh the registration of the `Microsoft.ContainerService` resource provider using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace "Microsoft.ContainerService"
    ```

## Add Azure Linux with OS Guard node pools and remove existing node pools

1. Add a new Azure Linux with OS Guard node pool using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command. This command adds a new node pool to your cluster with the `--mode System` flag, which makes it a system node pool. System node pools are required for Azure Linux with OS Guard clusters.

    ```azurecli
    # Declare environment variables with a random suffix for uniqueness
    export RANDOM_SUFFIX=$(openssl rand -hex 3)
    export NODE_POOL_NAME="np$RANDOM_SUFFIX"
    
    # Add a new Azure Linux with OS Guard node pool
    az aks nodepool add --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --name $NODE_POOL_NAME --mode System --os-sku AzureLinuxOSGuard --node-osdisk-type Managed --enable-fips-image --enable-secure-boot --enable-vtpm
    ```

    Example output:

    ```JSON
    {
      "id": "/subscriptions/xxxxx/resourceGroups/myResourceGroupxxx/providers/Microsoft.ContainerService/managedClusters/myAKSCluster/nodePools/systempool",
      "name": "systempool",
      "provisioningState": "Succeeded"
    }
    ```
2. Remove your existing nodes using the [`az aks nodepool delete`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-delete) command.

    ```azurecli
    az aks nodepool delete --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --name $NODE_POOL_NAME 
    ```

## In-place OS SKU migration

### Limitations for in-place OS SKU migration

There are several settings that can block the OS SKU migration request. To ensure a successful migration, review the following guidelines and limitations:

- The OS SKU migration feature isn't available through PowerShell or the Azure portal. When using the OS SKU migration feature with Azure Linux with OS Guard pPreview) it isn't available through Terraform, PowerShell, or the Azure portal.
- The OS SKU migration feature doesn't support renaming existing node pools.
- Ubuntu, Azure Linux, and Azure Linux with OS Guard are the only supported Linux OS SKU migration targets.
- Trusted Launch is required by default for Azure Linux with OS Guard. You need to have Trusted Launch enabled to migrate to Azure Linux with OS Guard. This might require creating new node pools.
- FIPS is required when enabling Azure Linux with OS Guard. If you're not currently using a FIPS image, you can include `--enable-fips` in your node pool update command.
- [Gen 1 virtual machines (VMs)](/en-us/azure/aks/aks-virtual-machine-sizes#vm-support-on-aks) aren't supported.
- An Ubuntu OS SKU with `UseGPUDedicatedVHD` enabled can't perform an OS SKU migration.
- [Confidential Virtual Machines (CVMs)](/en-us/azure/aks/confidential-containers-overview) aren't supported.
- [Pod Sandboxing](/en-us/azure/aks/use-pod-sandboxing) isn't supported.
- Windows OS SKU migration isn't supported.

### Prerequisites for in-place OS SKU migration

- An existing AKS cluster with at least one Azure Linux node pool.
- We recommend that you ensure your workloads configure and run successfully on the Azure Linux with OS Guard container host before attempting to use the OS SKU migration feature by [deploying an Azure Linux with OS Guard cluster](quick-deploy-os-guard-cli) in dev/prod and verifying your service remains healthy.
- Ensure the migration feature is working for you in test/dev before using the process on a production cluster.
- Ensure that your pods have enough [Pod Disruption Budget (PDB)](/en-us/azure/aks/operator-best-practices-scheduler#plan-for-availability-using-pod-disruption-budgets) to allow AKS to move pods between VMs during the upgrade.
- You need Azure CLI version [2.61.0](/en-us/cli/azure/release-notes-azure-cli#may-21-2024) or higher. Use the [`az version`](/en-us/cli/azure/reference-index?#az-version) command to find the version. To upgrade to the latest version, use the [`az upgrade`](/en-us/cli/azure/reference-index?#az-upgrade) command.

### Migrate the OS SKU of your Azure Linux Container Host node pool to Azure Linux with OS Guard

You can migrate your existing Ubuntu or Azure Linux node pools to Azure Linux with OS Guard by changing the OS SKU of the node pool, which rolls the cluster through the standard node image upgrade process. This new feature doesn't require the creation of new node pools; instead, your existing node pools automatically reimage.

# [Azure CLI](#tab/azure-cli)
Migrate the OS SKU of your node pool to Azure Linux with OS Guard using the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command. This command triggers a reimage of your node pool, updating the OS SKU of your node pool from Azure Linux to Azure Linux with OS Guard. The OS SKU change triggers an immediate upgrade operation, which takes several minutes to complete.

```azurecli
az aks nodepool update --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --name $NODE_POOL_NAME --os-sku AzureLinuxOSGuard --node-osdisk-type Managed --enable-fips-image --enable-secure-boot --enable-vtpm
```

Example output:

```JSON
{
  "id": "/subscriptions/xxxxx/resourceGroups/myResourceGroupxxx/providers/Microsoft.ContainerService/managedClusters/myAKSCluster/nodePools/nodepool1",
  "name": "nodepool1",
  "osSku": "AzureLinuxOSGuard",
  "provisioningState": "Succeeded"
}
```

Note

If you experience issues during the OS SKU migration, you can roll back to your previous OS SKU.

# [ARM template](#tab/arm-template)
##### Example ARM templates

###### 0base.json

```json
 {
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
      "type": "Microsoft.ContainerService/managedClusters",
      "apiVersion": "2023-07-01",
      "name": "akstestcluster",
      "location": "[resourceGroup().location]",
      "tags": {
        "displayname": "Demo of AKS Nodepool Migration"
      },
      "identity": {
        "type": "SystemAssigned"
      },
      "properties": {
        "enableRBAC": true,
        "dnsPrefix": "testcluster",
        "agentPoolProfiles": [
          {
            "name": "testnp",
            "count": 3,
            "vmSize": "Standard_D4a_v4",
            "osType": "Linux",
            "osSku": "AzureLinux",
            "mode": "System"
          }
        ]
      }
    }
  ]
}
```

###### 1mcupdate.json

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
      "type": "Microsoft.ContainerService/managedClusters",
      "apiVersion": "2023-07-01",
      "name": "akstestcluster",
      "location": "[resourceGroup().location]",
      "tags": {
        "displayname": "Demo of AKS Nodepool Migration"
      },
      "identity": {
        "type": "SystemAssigned"
      },
      "properties": {
        "enableRBAC": true,
        "dnsPrefix": "testcluster",
        "agentPoolProfiles": [
          {
            "name": "testnp",
            "osType": "Linux",
            "osSku": "AzureLinuxOSGuard",
            "mode": "System"
          }
        ]
      }
    }
  ]
} 
```

###### 2apupdate.json

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
      "apiVersion": "2023-07-01",
      "type": "Microsoft.ContainerService/managedClusters/agentPools",
      "name": "akstestcluster/testnp",
      "location": "[resourceGroup().location]",
      "properties": {
        "osType": "Linux",
        "osSku": "AzureLinux",
        "mode": "System"
      }
    }
  ]
}
```

##### Deploy a test cluster

1. Create a resource group for the test cluster using the [`az group create`](/en-us/cli/azure/group#az-group-create) command. The following example creates a resource group named *testRG* in the *eastus* region:

    ```azurecli
    az group create --name testRG --location eastus
    ```
2. Deploy a baseline Azure Linux OS SKU cluster with three nodes using the [`az deployment group create`](/en-us/cli/azure/deployment/group#az-deployment-group-create) command and the 0base.json example ARM template.

    ```azurecli
    az deployment group create --resource-group testRG --template-file 0base.json
    ```
3. Migrate the OS SKU of your system node pool to Azure Linux with OS Guard using the [`az deployment group create`](/en-us/cli/azure/deployment/group#az-deployment-group-create) command.

    ```azurecli
    az deployment group create --resource-group testRG --template-file 1mcupdate.json
    ```
4. Migrate the OS SKU of your system node pool back to Azure Linux using the [`az deployment group create`](/en-us/cli/azure/deployment/group#az-deployment-group-create) command.

    ```azurecli
    az deployment group create --resource-group testRG --template-file 2apupdate.json
    ```

### Verify the OS SKU migration

Once the migration is complete on your test clusters, you should verify the following to ensure a successful migration:

- If your migration target is Azure Linux with OS Guard, run the `kubectl get nodes -o wide` command. The output should show `Microsoft Azure Linux 3.0` as your OS image and `.azl3` at the end of your kernel version.
- Run the `kubectl get pods -o wide -A` command to verify all of your pods and daemonsets are running on the new node pool.
- Run the `kubectl get nodes --show-labels` command to verify all of the node labels in your upgraded node pool are what you expect.

Tip

We recommend monitoring the health of your service for a couple weeks before migrating your production clusters.

### Roll back to your previous OS SKU

If you experience issues during the OS SKU migration, you can roll back to your previous OS SKU. To do this, change the OS SKU field back to your previous value and resubmit the deployment, which triggers another upgrade operation and reimages the node pool to its previous OS SKU.

Roll back to your previous OS SKU using the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command. The following command updates the OS SKU node pool from Azure Linux with OS Guard back to Azure Linux:

```azurecli
az aks nodepool update \
    --resource-group $RESOURCE_GROUP \
    --cluster-name $CLUSTER_NAME \
    --name <existing-node-pool-name> \
    --os-sku AzureLinux
```

---