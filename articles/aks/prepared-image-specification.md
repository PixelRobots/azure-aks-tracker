---
layout: Conceptual
title: Create and manage a Prepared Image Specification (PIS) in Azure Kubernetes Service (AKS) (Preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/prepared-image-specification
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
description: Learn how to create, version, update, monitor, and manage a PIS in Azure Kubernetes Service (AKS).
ms.topic: how-to
ms.custom: devx-track-azurecli
ms.date: 2026-06-29T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-nodes
locale: en-us
document_id: 8d77fb66-4554-6473-4b84-b2253cabdbdf
document_version_independent_id: 1d46f6e5-9115-9d61-64a7-ceffc08ffdb5
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/prepared-image-specification.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/prepared-image-specification
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/prepared-image-specification.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 1a956b4e-62bf-0927-f67e-605fcb68ead5
---

# Create and manage a Prepared Image Specification (PIS) in Azure Kubernetes Service (AKS) (Preview) - Azure Kubernetes Service | Microsoft Learn

Prepared Image Specification (PIS) lets you define preconfigured node images that include your required container images and customizations. AKS builds the prepared image once and reuses it during node provisioning, reducing startup time for subsequent scale operations. For more information about how Prepared Image Specification works and when to use it, see [Prepared Image Specification in AKS (Preview)](prepared-image-specification-overview).

This article shows you how to create and manage a PIS in AKS.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Prerequisites

- An existing AKS cluster running a supported Kubernetes version. If you don't have one, see [Create an AKS cluster](learn/quick-kubernetes-deploy-cli).
- Azure CLI version 2.85.0 or later. Run `az --version` to find your version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- You need appropriate Azure RBAC permissions to create and manage AKS resources in your resource group.
- Your container images must be accessible from the AKS cluster. If you use Azure Container Registry (ACR), make sure it's [integrated with your AKS cluster](cluster-container-registry-integration).
- The `aks-preview` CLI extension version 21.0.0b5 or later. If you don't have it, see Install the `aks-preview` CLI extension.
- The `AKSPreparedImageSpecificationPreview` feature flag registered in your subscription. If you haven't registered it, see Register the `AKSPreparedImageSpecificationPreview` feature flag.

## Limitations

The following limitations apply during preview:

- Available in public Azure regions, excluding sovereign clouds and air-gapped environments.
- Supported operating systems include Ubuntu, Azure Linux, and Windows.
- Custom scripts can cause image build or scale-up failures.
- You might need to recreate existing specifications when you modify them.

## Install the `aks-preview` CLI extension

Install the aks-preview CLI extension by using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command.

```azurecli
az extension add --name aks-preview
```

Update the extension to ensure you have the latest version installed by using the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command.

```azurecli
az extension update --name aks-preview
```

## Register the `AKSPreparedImageSpecificationPreview` feature flag

1. Register the `AKSPreparedImageSpecificationPreview` feature flag in your subscription using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

    ```azurecli
    az feature register \
      --namespace Microsoft.ContainerService \
      --name AKSPreparedImageSpecificationPreview
    ```
2. Verify registration status using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command.

    ```azurecli
    az feature show \
      --namespace Microsoft.ContainerService \
      --name AKSPreparedImageSpecificationPreview
    ```
3. Once the feature flag is registered, refresh the registration of the Microsoft.ContainerService resource provider using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace Microsoft.ContainerService
    ```

## Create a Prepared Image Specification (PIS)

### Create a basic Prepared Image Specification

Create a PIS using the [`az aks prepared-image-specification create`](/en-us/cli/azure/aks/prepared-image-specification#az-aks-prepared-image-specification-create) command.

```azurecli
# Set environment variables
RESOURCE_GROUP=<your-resource-group>
CLUSTER_NAME=<your-aks-cluster-name>
PIS_NAME=<your-pis-name>
LOCATION=<location>
PIS_VERSION=v1

# Create a basic Prepared Image Specification
az aks prepared-image-specification create \
    --resource-group $RESOURCE_GROUP \
    --name $PIS_NAME \
    --version $PIS_VERSION \
    --location $LOCATION
```

### Create a Prepared Image Specification with cached images

Create a PIS that pre-caches container images using the [`az aks prepared-image-specification create`](/en-us/cli/azure/aks/prepared-image-specification#az-aks-prepared-image-specification-create) command.

```azurecli
# Set environment variables
RESOURCE_GROUP=<your-resource-group>
CLUSTER_NAME=<your-aks-cluster-name>
PIS_NAME=<your-pis-name>
LOCATION=<location>
PIS_VERSION=v1

# Create a Prepared Image Specification with cached images
az aks prepared-image-specification create \
    --resource-group $RESOURCE_GROUP \
    --name $PIS_NAME \
    --version $PIS_VERSION \
    --container-images \
        myacr.azurecr.io/model-server:v1 \
        myacr.azurecr.io/inference:v1
```

### Create a Prepared Image Specification using custom scripts

Create a PIS that runs customization scripts during image build using the [`az aks prepared-image-specification create`](/en-us/cli/azure/aks/prepared-image-specification#az-aks-prepared-image-specification-create) command.

```azurecli
# Set environment variables
RESOURCE_GROUP=<your-resource-group>
CLUSTER_NAME=<your-aks-cluster-name>
PIS_NAME=<your-pis-name>
LOCATION=<location>
PIS_VERSION=v1

# Create a Prepared Image Specification using custom scripts
az aks prepared-image-specification create \
    --resource-group $RESOURCE_GROUP \
    --name $PIS_NAME \
    --version $PIS_VERSION \
    --customization-scripts @scripts.json
```

## Create a cluster or node pool using a Prepared Image Specification

After you create a PIS, you can reference it when you create or update a cluster or node pool. You need the resource ID of the prepared image version.

### Create a cluster using a PIS

1. Get the PIS version resource ID using the [`az aks prepared-image-specification version show`](/en-us/cli/azure/aks/prepared-image-specification/version#az-aks-prepared-image-specification-version-show) command.

    ```azurecli
    # Set environment variables
    RESOURCE_GROUP=<your-resource-group>
    PIS_NAME=<your-pis-name>
    PIS_VERSION=v1
    
    # Get the PIS version resource ID
    PIS_VERSION_ID=$(az aks prepared-image-specification version show \
        --resource-group $RESOURCE_GROUP \
        --pis-name $PIS_NAME \
        --name $PIS_VERSION \
        --query id -o tsv)
    ```
2. Create a new AKS cluster that references the prepared image using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--prepared-image-specification-id` parameter.

    ```azurecli
    # Set environment variables
    CLUSTER_NAME=<your-aks-cluster-name>
    
    # Create a new AKS cluster using the prepared image
    az aks create \
        --resource-group $RESOURCE_GROUP \
        --name $CLUSTER_NAME \
        --prepared-image-specification-id $PIS_VERSION_ID \
        --generate-ssh-keys
    ```

### Create a node pool using a PIS

1. Get the PIS version resource ID using the [`az aks prepared-image-specification version show`](/en-us/cli/azure/aks/prepared-image-specification/version#az-aks-prepared-image-specification-version-show) command.

    ```azurecli
    # Set environment variables
    RESOURCE_GROUP=<your-resource-group>
    PIS_NAME=<your-pis-name>
    PIS_VERSION=v1
    
    # Get the PIS version resource ID
    PIS_VERSION_ID=$(az aks prepared-image-specification version show \
        --resource-group $RESOURCE_GROUP \
        --pis-name $PIS_NAME \
        --name $PIS_VERSION \
        --query id -o tsv)
    ```
2. Create a new node pool that references the prepared image using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command with the `--prepared-image-specification-id` parameter.

    ```azurecli
    # Set environment variables
    CLUSTER_NAME=<your-aks-cluster-name>
    
    # Create a new node pool using the prepared image
    az aks nodepool add \
        --resource-group $RESOURCE_GROUP \
        --cluster-name $CLUSTER_NAME \
        --name userpool \
        --prepared-image-specification-id $PIS_VERSION_ID
    ```
3. Verify the node pool is using the PIS using the [`az aks nodepool show`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-show) command.

    ```azurecli
    az aks nodepool show \
        --resource-group $RESOURCE_GROUP \
        --cluster-name $CLUSTER_NAME \
        --name userpool \
        --query "{state:provisioningState, pisId:preparedImageSpecificationId}"
    ```

## Manage Prepared Image Specifications

### List Prepared Image Specifications

List all Prepared Image Specifications in a resource group using the [`az aks prepared-image-specification list`](/en-us/cli/azure/aks/prepared-image-specification#az-aks-prepared-image-specification-list) command.

```azurecli
# Set environment variables
RESOURCE_GROUP=<your-resource-group>

# List all Prepared Image Specifications in the resource group
az aks prepared-image-specification list --resource-group $RESOURCE_GROUP
```

### Show a specific Prepared Image Specification

Get the details of a specific Prepared Image Specification using the [`az aks prepared-image-specification show`](/en-us/cli/azure/aks/prepared-image-specification#az-aks-prepared-image-specification-show) command.

```azurecli
# Set environment variables
RESOURCE_GROUP=<your-resource-group>
PIS_NAME=<your-pis-name>

# Show the details of the Prepared Image Specification
az aks prepared-image-specification show \
    --resource-group $RESOURCE_GROUP \
    --name $PIS_NAME
```

### Update Prepared Image Specification metadata

There are two resource concepts: the **PIS resource** and **PIS versions**. Updating PIS metadata, such as tags, updates the PIS resource and doesn't change the referenced version's image or scripts. To change container images or scripts, create a new PIS version and update the node pool to reference that PIS version ID.

You can update metadata, such as tags, on an existing Prepared Image Specification using the [`az aks prepared-image-specification update`](/en-us/cli/azure/aks/prepared-image-specification#az-aks-prepared-image-specification-update) command. To change the container images or scripts, create a new version instead.

```azurecli
# Set environment variables
RESOURCE_GROUP=<your-resource-group>
PIS_NAME=<your-pis-name>

# Update the Prepared Image Specification metadata
az aks prepared-image-specification update \
    --resource-group $RESOURCE_GROUP \
    --name $PIS_NAME \
    --tags environment=prod
```

### List all versions of a Prepared Image Specification

List all versions of a Prepared Image Specification using the [`az aks prepared-image-specification version list`](/en-us/cli/azure/aks/prepared-image-specification/version#az-aks-prepared-image-specification-version-list) command.

```azurecli
# Set environment variables
RESOURCE_GROUP=<your-resource-group>
PIS_NAME=<your-pis-name>

# List all versions of the Prepared Image Specification
az aks prepared-image-specification version list \
    --resource-group $RESOURCE_GROUP \
    --pis-name $PIS_NAME
```

### Show a specific version of a Prepared Image Specification

Get the details of a specific version using the [`az aks prepared-image-specification version show`](/en-us/cli/azure/aks/prepared-image-specification/version#az-aks-prepared-image-specification-version-list) command with the `--name` parameter set to the PIS version.

```azurecli
# Set environment variables
RESOURCE_GROUP=<your-resource-group>
PIS_NAME=<your-pis-name>
PIS_VERSION=v1

# Show the details of the specific version of the Prepared Image Specification
az aks prepared-image-specification version show \
    --resource-group $RESOURCE_GROUP \
    --pis-name $PIS_NAME \
    --name $PIS_VERSION
```

### List node pools that use a specific Prepared Image Specification

To find all node pools in a cluster that reference a Prepared Image Specification, use the [`az aks nodepool list`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-list) command with a JMESPath filter.

```azurecli
# Set environment variables
RESOURCE_GROUP=<your-resource-group>
CLUSTER_NAME=<your-aks-cluster-name>

# List all node pools in the cluster that reference a Prepared Image Specification
az aks nodepool list \
    --resource-group $RESOURCE_GROUP \
    --cluster-name $CLUSTER_NAME \
    --query "[?preparedImageSpecificationId != null]"
```

## Upgrade a Prepared Image Specification version

When your base images, dependencies, or customizations change, create a new version and update your node pools to reference it. The recommended workflow is:

1. Create a new version with updated container images or scripts.
2. Validate the new version in a nonproduction node pool.
3. Update production node pools to reference the new version.

    ```azurecli
    # Set environment variables
    RESOURCE_GROUP=<your-resource-group>
    CLUSTER_NAME=<your-aks-cluster-name>
    NEW_PIS_VERSION_ID=<new-pis-version-resource-id>
    
    # Update a node pool to reference a new PIS version using the `az aks nodepool update` command
    az aks nodepool update \
        --resource-group $RESOURCE_GROUP \
        --cluster-name $CLUSTER_NAME \
        --name userpool \
        --prepared-image-specification-id $NEW_PIS_VERSION_ID
    ```
4. Clean unused images for cost optimization.

### AKS version upgrades

When you upgrade the Kubernetes version, AKS automatically rebuilds the prepared VHD for the referenced PIS version. You don't need to create a new PIS version for a Kubernetes version upgrade. You should create a new PIS version when the PIS content, such as container images or scripts, changes.

Check for available upgrades using the [`az aks get-upgrades`](/en-us/cli/azure/aks#az-aks-get-upgrades) command.

```azurecli
# Set environment variables
RESOURCE_GROUP=<your-resource-group>
CLUSTER_NAME=<your-aks-cluster-name>

# Check for available upgrades
az aks get-upgrades \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME
```

Upgrade the cluster using the [`az aks upgrade`](/en-us/cli/azure/aks#az-aks-upgrade) command.

```azurecli
# Set environment variables
RESOURCE_GROUP=<your-resource-group>
CLUSTER_NAME=<your-aks-cluster-name>
KUBERNETES_VERSION=<new-kubernetes-version>

# Upgrade the cluster to the new Kubernetes version
az aks upgrade \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --kubernetes-version $KUBERNETES_VERSION
```

Important

Create and validate a new Prepared Image Specification version that targets the new Kubernetes and node image versions before upgrading production node pools.

Upgrade a specific node pool using the [`az aks nodepool upgrade`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-upgrade) command.

```azurecli
# Set environment variables
RESOURCE_GROUP=<your-resource-group>
CLUSTER_NAME=<your-aks-cluster-name>
NODE_POOL_NAME=<your-node-pool-name>

# Upgrade the node pool to the new Kubernetes version
az aks nodepool upgrade \
    --resource-group $RESOURCE_GROUP \
    --cluster-name $CLUSTER_NAME \
    --name $NODE_POOL_NAME
```

## Remove a Prepared Image Specification from a node pool

To stop using a Prepared Image Specification on a node pool, update the node pool using the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command with an empty string for the `--prepared-image-specification-id` parameter.

```azurecli
# Set environment variables
RESOURCE_GROUP=<your-resource-group>
CLUSTER_NAME=<your-aks-cluster-name>

# Remove the Prepared Image Specification from the node pool
az aks nodepool update \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name userpool \
  --prepared-image-specification-id ""
```

## Delete a Prepared Image Specification version

Delete a specific version using the [`az aks prepared-image-specification version delete`](/en-us/cli/azure/aks/prepared-image-specification/version#az-aks-prepared-image-specification-version-delete) command.

Important

Don't delete a PIS version that's referenced by a node pool. Instead, you should update the node pool to remove PIS or reference another PIS version. Deleting a referenced version can prevent AKS from successfully rebuilding or rolling the prepared image.

```azurecli
# Set environment variables
RESOURCE_GROUP=<your-resource-group>
PIS_NAME=<your-pis-name>
PIS_VERSION=<your-pis-version>

# Delete the specific version of the Prepared Image Specification
az aks prepared-image-specification version delete \
    --resource-group $RESOURCE_GROUP \
    --pis-name $PIS_NAME \
    --name $PIS_VERSION
```

## Delete a Prepared Image Specification

Delete an entire Prepared Image Specification resource using the [`az aks prepared-image-specification delete`](/en-us/cli/azure/aks/prepared-image-specification#az-aks-prepared-image-specification-delete) command.

Important

Before deleting a PIS resource, make sure no node pools reference any of its versions. If you find any references, remove or update them before deleting the PIS resource. Deleting a referenced PIS can prevent AKS from successfully rebuilding or rolling the prepared image.

```azurecli
# Set environment variables
RESOURCE_GROUP=<your-resource-group>
PIS_NAME=<your-pis-name>

# Delete the Prepared Image Specification
az aks prepared-image-specification delete \
    --resource-group $RESOURCE_GROUP \
    --name $PIS_NAME
```

## Monitor Prepared Image Specification performance

To evaluate whether PIS is reducing provisioning latency in your environment, monitor the following metrics:

- **Node provisioning duration and time to ready**: Compare against nodes that don't use a prepared image.
- **Scale-out completion time**: Time from autoscaler trigger to nodes in the Ready state.
- **Image build duration and build success rate**: Track the health of the image preparation pipeline.
- **Pod startup time and container image pull duration**: Verify that image pre-caching is being used effectively.

## Troubleshoot Prepared Image Specification

PIS-related errors should include the failure reason, and many failures are likely to come from custom scripts. If node pool create or scale-up fails after adding PIS, you should inspect the image build/custom script logs and validate the script before creating a new version or updating the node pool reference.

### Image creation fails

Note

When a customization script fails during image build, AKS deallocates the build VM instead of deleting it so the customer can start it and debug. On later PIS rebakes, AKS deletes and recreates the virtual machine scale set/build resources.

If the PIS fails to build the prepared image, check for:

- Invalid or malformed customization scripts.
- Container registry authentication failures - verify the AKS cluster has pull access to the specified registries.
- Missing Azure RBAC permissions on the resource group or registry.
- Unsupported customization types for the target OS.

### Node pool creation fails

If a node pool that references a PIS fails to create, verify:

- The PIS version ID is valid and the version exists in the same region.
- Your subscription has sufficient quota for the requested VM SKU.
- The requested VM SKU is supported by the prepared image.
- The region supports the PIS feature during preview.

### Scale operations aren't faster

If you don't see reduced provisioning time, verify:

- The container images you want to accelerate are included in the PIS version.
- The node pool references the correct version.
- New nodes are booting from the prepared image, not the base AKS node image.
- The bottleneck is container image pull time, not workload startup or other initialization.

## Clean up resources

If you created resources in this article for testing purposes, delete them when you're done to avoid ongoing charges. This includes PIS versions, PIS resources, test node pools, and test AKS clusters.

To delete the resource group and all resources in it, use the [`az group delete`](/en-us/cli/azure/group#az-group-delete) command.

```azurecli
# Set environment variables
RESOURCE_GROUP=<your-resource-group>

# Delete the resource group and all resources in it
az group delete \
    --name $RESOURCE_GROUP \
    --yes \
    --no-wait
```