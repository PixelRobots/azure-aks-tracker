---
layout: Conceptual
title: Create and manage custom locations on Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/custom-locations
breadcrumb_path: ../../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/146/azure-arc/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/5c778dec-0625-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: davidsmatlak
learn_banner_products:
- azure
ms.reviewer: davidsmatlak
ms.author: davidsmatlak
ms.service: azure-arc
ms.subservice: azure-arc-kubernetes
ms.date: 2025-07-21T00:00:00.0000000Z
ms.topic: how-to
ms.custom: references_regions, devx-track-azurecli
description: Use custom locations to deploy Azure PaaS services on Azure Arc-enabled Kubernetes clusters
locale: en-us
document_id: 492acd2f-5d4e-4be2-b1a2-8b2c83a5a2fc
document_version_independent_id: 8e44670d-d75e-1185-b3c3-b46604713a42
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/custom-locations.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/custom-locations
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/custom-locations.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: e2713908-337a-67c8-7a46-7b6c09f501a0
---

# Create and manage custom locations on Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn

The *custom locations* feature provides a way to configure your Azure Arc-enabled Kubernetes clusters as target locations for deploying instances of Azure offerings. Examples of Azure offerings that can be deployed on top of custom locations include databases, such as SQL Managed Instance enabled by Azure Arc, or application instances, such as Container Apps, Logic Apps, Event Grid, Logic Apps, and API Management.

A [custom location](conceptual-custom-locations) has a one-to-one mapping to a namespace within the Azure Arc-enabled Kubernetes cluster. The custom location Azure resource combined with Azure role-based access control (Azure RBAC) can be used to grant granular permissions to application developers or database admins, enabling them to deploy resources such as databases or application instances on top of Arc-enabled Kubernetes clusters in a multitenant environment.

In this article, you learn how to enable custom locations on an Arc-enabled Kubernetes cluster, and how to create a custom location.

## Prerequisites

- [Install or upgrade Azure CLI](/en-us/cli/azure/install-azure-cli) to the latest version.
- Install the latest versions of the following Azure CLI extensions:

    - `connectedk8s`
    - `k8s-extension`
    - `customlocation`

        ```azurecli
        az extension add --name connectedk8s
        az extension add --name k8s-extension
        az extension add --name customlocation
        ```

        If you already installed the `connectedk8s`, `k8s-extension`, and `customlocation` extensions, update to the **latest version** by using the following command:

        ```azurecli
        az extension update --name connectedk8s
        az extension update --name k8s-extension
        az extension update --name customlocation
        ```
- Verify completed provider registration for `Microsoft.ExtendedLocation`.

    1. Enter the following commands:

        ```azurecli
        az provider register --namespace Microsoft.ExtendedLocation
        ```
    2. Monitor the registration process. Registration may take up to 10 minutes.

        ```azurecli
        az provider show -n Microsoft.ExtendedLocation -o table
        ```

        Once registered, the `RegistrationState` state has the value `Registered`.
- Verify you have an existing [Azure Arc-enabled Kubernetes connected cluster](quickstart-connect-cluster), and [upgrade your agents](agent-upgrade#manually-upgrade-agents) to the latest version. Confirm that the machine on which you'll run the commands described in this article has a `kubeconfig` file that points to this cluster.

## Enable custom locations on your cluster

Important

The custom locations feature is dependent on the [cluster connect](cluster-connect) feature. Both features must be enabled in the cluster for custom locations to function.

The Custom Location Object ID (OID) is needed to enable custom location. If your user account has the required permissions, the OID is automatically retrieved during feature enablement. If you don't have a valid user account, then the manually passed OID is used but the OID can't be validated. If the OID is invalid, then custom location may not be properly enabled.

The custom locations feature must be enabled before creating custom locations, because the enablement provides the required permissions to create the custom locations namespace on the Kubernetes cluster.

### Enable custom locations as a Microsoft Entra user

Sign into Azure CLI as a Microsoft Entra user and run the following command:

```azurecli
az connectedk8s enable-features -n <clusterName> -g <resourceGroupName> --features cluster-connect custom-locations
```

### Enable custom locations with a service principal

Manually retrieve the custom location OID by following these steps.

Important

Copy and run the command in step 2 exactly as shown. Don't replace the value passed to the `--id` parameter with a different value.

1. Sign in to Azure CLI as a Microsoft Entra user.
2. Run the following command to fetch the custom location `oid` (object ID), where `--id` refers to the Custom Location service app itself, and is predefined and set to `bc313c14-388c-4e7d-a58e-70017303ee3b`:

    ```azurecli
    az ad sp show --id bc313c14-388c-4e7d-a58e-70017303ee3b --query id -o tsv
    ```
3. Sign in to Azure CLI using the service principal. Run the following command to enable the custom locations feature on the cluster, using the `oid` (object ID) value from the previous step for the `--custom-locations-oid` parameter:

    ```azurecli
    az connectedk8s enable-features -n <cluster-name> -g <resource-group-name> --custom-locations-oid <cl-oid> --features cluster-connect custom-locations
    ```

## Create custom location

1. Deploy the Azure service cluster extension of the Azure service instance you want to install on your cluster:

    - [Azure Arc-enabled data services](../data/create-data-controller-direct-prerequisites)

        Note

        Outbound proxy without authentication and outbound proxy with basic authentication are supported by the Azure Arc-enabled data services cluster extension. Outbound proxy that expects trusted certificates is currently not supported.
    - [Azure Container Apps on Azure Arc](/en-us/azure/container-apps/azure-arc-enable-cluster?tabs=azure-cli#install-the-container-apps-extension)
    - [Event Grid on Kubernetes](/en-us/azure/event-grid/kubernetes/install-k8s-extension)
2. Get the Azure Resource Manager identifier of the Azure Arc-enabled Kubernetes cluster, referenced in later steps as `connectedClusterId`:

    ```azurecli
    az connectedk8s show -n <clusterName> -g <resourceGroupName>  --query id -o tsv
    ```
3. Get the Azure Resource Manager identifier of the cluster extension you deployed to the Azure Arc-enabled Kubernetes cluster, referenced in later steps as `extensionId`:

    ```azurecli
    az k8s-extension show --name <extensionInstanceName> --cluster-type connectedClusters -c <clusterName> -g <resourceGroupName>  --query id -o tsv
    ```
4. Create the custom location by referencing the Azure Arc-enabled Kubernetes cluster and the extension:

    ```azurecli
    az customlocation create -n <customLocationName> -g <resourceGroupName> --namespace <name of namespace> --host-resource-id <connectedClusterId> --cluster-extension-ids <extensionId> 
    ```

    - Required parameters:

        | Parameter name | Description |
        | --- | --- |
        | `--name, --n` | Name of the custom location. |
        | `--resource-group, --g` | Resource group of the custom location. |
        | `--namespace` | Namespace in the cluster bound to the custom location being created. |
        | `--host-resource-id` | Azure Resource Manager identifier of the Azure Arc-enabled Kubernetes cluster (connected cluster). |
        | `--cluster-extension-ids` | Azure Resource Manager identifier of a cluster extension instance installed on the connected cluster. For multiple extensions, provide a space-separated list of cluster extension IDs |
    - Optional parameters:

        | Parameter name | Description |
        | --- | --- |
        | `--location, --l` | Location of the custom location Azure Resource Manager resource in Azure. If not specified, the location of the connected cluster is used. |
        | `--tags` | Space-separated list of tags in the format `key[=value]`. Use '' to clear existing tags. |
        | `--kubeconfig` | Admin `kubeconfig` of cluster. |
5. Confirm that custom location was successfully enabled by running the following command and checking that `ProvisioningState` is `Succeeded`:

```azurecli
az customlocation show -n <customLocationName> -g <resourceGroupName>
```

## Check usage of a custom location

To determine whether a custom location is actively being used by other Azure resources, you can list the resource types that are enabled for it using the Azure CLI.

```azurecli
az customlocation list-enabled-resource-types -n <customLocationName> -g <resourceGroupName>                                              
```

This command returns a list of Azure resource types that are configured to use the specified custom location. If the list is not empty, it indicates that the custom location is currently being used by those resource types.

**Example output:**

```
[
  {
    "resourceType": "Microsoft.App/containerApps"
  },
  {
    "resourceType": "Microsoft.Data/sqlManagedInstances"
  }
]
```

## Show details of a custom location

To show the details of a custom location, use the following command:

```azurecli
az customlocation show -n <customLocationName> -g <resourceGroupName> 
```

## List custom locations

To list all custom locations in a resource group, use the following command:

```azurecli
az customlocation list -g <resourceGroupName> 
```

## Update a custom location

Use the `update` command to add new values for `--tags` or associate new `--cluster-extension-ids` to the custom location, while retaining existing values for tags and associated cluster extensions.

```azurecli
az customlocation update -n <customLocationName> -g <resourceGroupName> --namespace <name of namespace> --host-resource-id <connectedClusterId> --cluster-extension-ids <extensionIds> 
```

## Patch a custom location

Use the `patch` command to replace existing values for `--cluster-extension-ids` or `--tags`. Previous values aren't retained.

```azurecli
az customlocation patch -n <customLocationName> -g <resourceGroupName> --namespace <name of namespace> --host-resource-id <connectedClusterId> --cluster-extension-ids <extensionIds> 
```

## Delete a custom location

To delete a custom location, use the following command:

```azurecli
az customlocation delete -n <customLocationName> -g <resourceGroupName> 
```

## Troubleshooting

### Get login credentials error on Azure CLI v2.70.0

You may encounter an error that contains: `TypeError: get_login_credentials() got an unexpected keyword argument 'resource'`. Azure CLI v2.70.0 released a breaking change that triggers this error. A fix is available in `az customlocation` v0.1.4 for compatibility with Azure CLI v2.70.0 and higher.

To use a lower version of `az customlocation`, you must also use Azure CLI version 2.69.0 or earlier. If you used the Azure CLI installer, you can uninstall the current version and install Azure CLI v2.69.0 from the [`Azure CLI installation page`](/en-us/cli/azure/install-azure-cli). If you used the pip installer, you can run the following command to downgrade: `pip install azure-cli==2.69.0`. However, we generally recommend using the latest version of `az customlocation` and Azure CLI.

### Unknown proxy error

If custom location creation fails with the error `Unknown proxy error occurred`, modify your network policy to allow pod-to-pod internal communication within the `azure-arc` namespace. Be sure to also add the `azure-arc` namespace as part of the no-proxy exclusion list for your configured policy.

### Service principal warning

If you try to enable custom location while signed into Azure CLI using a service principal, you may observe the following warning:

```console
Unable to fetch oid of 'custom-locations' app. Proceeding without enabling the feature. Insufficient privileges to complete the operation.
```

This warning occurs because the service principal lacks the necessary permissions to retrieve the `oid` (object ID) of the custom location used by the Azure Arc service. Follow the instructions provided to enable the custom location feature using a service principal.

### Resource provider doesn't have required permissions

If you try to create the custom location before the custom location feature is enabled on the Kubernetes cluster, you may receive the following error message:

```console
Deployment failed. Correlation ID: ... "Microsoft.ExtendedLocation" resource provider does not have the required permissions to create a namespace on the cluster. Refer to https://aka.ms/ArcK8sCustomLocationsDocsEnableFeature to provide the required permissions to the resource provider.
```

First, enable the custom location feature on your cluster. After the feature is enabled, you can follow the steps to create the custom location.