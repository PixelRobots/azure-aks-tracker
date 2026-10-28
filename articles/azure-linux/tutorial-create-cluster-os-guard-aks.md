---
layout: Conceptual
title: 'Tutorial: Create a Cluster with Azure Linux with OS Guard (preview) for Azure Kubernetes Service (AKS) | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/tutorial-create-cluster-os-guard-aks
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
description: In this Azure Linux tutorial, you learn how to create a cluster with Azure Linux with OS Guard (preview) for Azure Kubernetes Service (AKS).
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: tutorial
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: 61929aca-76f8-7643-8ca7-b346f9ea4e15
document_version_independent_id: 1fbf34c5-cfe2-db55-724e-b814e655e422
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/tutorial-create-cluster-os-guard-aks.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/tutorial-create-cluster-os-guard-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/tutorial-create-cluster-os-guard-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 63c9a69e-d890-4b61-240c-136aaedd9a63
---

# Tutorial: Create a Cluster with Azure Linux with OS Guard (preview) for Azure Kubernetes Service (AKS) | Microsoft Learn

Important

Starting on **December 10, 2026**, Azure Kubernetes Service (AKS) no longer supports Azure Linux with OS Guard for AKS (preview). At that point, AKS no longer produces new Azure Linux with OS Guard node images or provides security patches, and you can no longer create new node pools with Azure Linux with OS Guard. On **March 10, 2027**, AKS removes all existing Azure Linux with OS Guard node images, which causes scaling and remediation (reimage and redeploy) operations to fail. To avoid disruption, migrate to [Azure Container Linux (ACL)](azure-container-linux-overview). For more information about this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/5950) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates/?id=571257). To stay informed about announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Note

Azure Linux with OS Guard (preview) is being replaced by Azure Container Linux (ACL).

Azure Container Linux is the long‑term, immutable, container‑optimized Linux operating system (OS) for Azure Kubernetes Service (AKS). It provides a secure, minimal, and operationally consistent host OS designed to run containerized workloads at scale.

For more information, see the [Azure Container Linux (ACL) overview](azure-container-linux-overview).

In this tutorial, part *one of five*, you learn how to:

- Install the Kubernetes CLI, `kubectl`.
- Install the `aks-preview` Azure CLI extension.
- Register the `AzureLinuxOSGuardPreview` feature flag.
- Create an Azure resource group.
- Create and deploy an Azure Linux with OS Guard cluster.
- Configure `kubectl` to connect to your Azure Linux with OS Guard cluster.

In later tutorials, you learn how to add an Azure Linux with OS Guard node pool to an existing cluster and migrate existing nodes to Azure Linux with OS Guard.

## Prerequisites

- You need the latest version of Azure CLI. Use the [`az version`](/en-us/cli/azure/reference-index?#az-version) command to find the version. To upgrade to the latest version, use the [`az upgrade`](/en-us/cli/azure/reference-index?#az-upgrade) command.
- Install the `aks-preview` Azure CLI extension.
- Register the `AzureLinuxOSGuardPreview` feature flag.

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
    ```
3. When the status reflects *Registered*, refresh the registration of the `Microsoft.ContainerService` resource provider using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace "Microsoft.ContainerService"
    ```

## Set environment variables

Set the following environment variables to create unique resource names for each deployment:

```bash
export RESOURCE_GROUP="<your-resource-group-name>"
export REGION="<your-region>"
export CLUSTER_NAME="<your-cluster-name>"
```

## Create a resource group

When creating a resource group in Azure, you're required to specify a location. This location is the storage location of your resource group metadata and where your resources run in Azure if you don't specify another region when creating a resource.

Create a resource group using the [`az group create`](/en-us/cli/azure/group#az_group_create) command.

```azurecli
az group create --name $RESOURCE_GROUP --location $REGION
```

Example output:

```JSON
{
  "id": "/subscriptions/xxxxx/resourceGroups/testAzureLinuxOSGuardResourceGroupxxxxx",
  "location": "EastUS2",
  "managedBy": null,
  "name": "testAzureLinuxOSGuardResourceGroupxxxxx",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
}
```

## Create an Azure Linux with OS Guard (preview) cluster

Create an AKS cluster using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--os-sku AzureLinuxOSGuard` parameter to provision an Azure Linux with OS Guard cluster. Enabling [FIPS](/en-us/azure/aks/enable-fips-nodes), [secure boot](/en-us/azure/aks/use-trusted-launch), and [vtpm](/en-us/azure/aks/use-trusted-launch) is required to use Azure Linux with OS Guard.

```azurecli
az aks create --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --os-sku AzureLinuxOSGuard --node-osdisk-type Managed --enable-fips-image --enable-secure-boot --enable-vtpm
```

Example output:

```JSON
{
  "id": "/subscriptions/xxxxx/resourceGroups/testAzureLinuxOSGuardResourceGroupxxxxx/providers/Microsoft.ContainerService/managedClusters/testAzureLinuxOSGuardClusterxxxxx",
  "location": "WestUS2",
  "name": "testAzureLinuxOSGuardClusterxxxxx",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "type": "Microsoft.ContainerService/managedClusters"
}
```

After a few minutes, the command completes and returns JSON-formatted information about the cluster.

## Connect to the cluster using kubectl

1. Configure `kubectl` to connect to your Kubernetes cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
    ```
2. Verify the connection to your cluster using the [`kubectl get nodes`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command to return a list of the cluster nodes.

    ```bash
    kubectl get nodes
    ```

    Example output:

    ```text
    NAME                           STATUS   ROLES   AGE     VERSION
    aks-nodepool1-00000000-0       Ready    agent   10m     v1.20.7
    aks-nodepool1-00000000-1       Ready    agent   10m     v1.20.7
    ```