---
layout: Conceptual
title: Get Started with Azure Kubernetes Application Network for AKS (Preview) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-network/get-started
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
learn_banner_products:
- azure
description: Learn how to get started with Azure Kubernetes Application Network for AKS, including prerequisites, creating an Application Network resource, connecting an AKS cluster as a member, and managing resources.
author: Kochhars
ms.author: kochhars
ms.service: azure-kubernetes-app-net
ms.topic: get-started
ms.date: 2026-10-30T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: 318bbaff-573d-b5cb-652e-5cfb3e38f9ea
document_version_independent_id: a85372fc-3c4d-1b24-b56a-68a5209b0a13
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/application-network/get-started.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: application-network/get-started
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-network/get-started.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: ef92400b-9699-4f0c-0259-866ee00bbf1e
---

# Get Started with Azure Kubernetes Application Network for AKS (Preview) | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

This article helps you get started with Azure Kubernetes Application Network for AKS. It provides step-by-step instructions to create an Application Network resource and connect an AKS cluster to it as a member cluster.

Note

This quickstart creates a public AKS cluster. For an eligible private AKS cluster, follow [Connect private AKS clusters](private-connectivity) to check availability and choose the subnet and join options. Public clusters can't use the private-connect path.

## Prerequisites

- An Azure subscription. If you don't have one, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- Azure CLI version 2.84.0 or later. Check your version using the `az --version` command. To install or update, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- For both existing and new AKS clusters, make sure they meet the following requirements. These requirements are validated when you join the cluster as a member:

    - [Istio-based service mesh add-on](/en-us/azure/aks/istio-about) (`ServiceMeshProfile`) is **not** enabled. A cluster that already has the Istio add-on enabled can't join an Azure Kubernetes Application Network.
    - [AKS-managed Microsoft Entra integration](/en-us/azure/aks/entra-id-control-plane-authentication) is enabled.
    - [OIDC issuer](/en-us/azure/aks/use-oidc-issuer) is enabled.
    - [Managed Kubernetes Gateway API installation](/en-us/azure/aks/managed-gateway-api) is enabled.
- Verify support for your existing Kubernetes cluster using the [support policy](supported-versions).
- Meet the network access requirements for your cluster's API server and data plane.

## Network access requirements

Application Network needs connectivity in both directions. Allowing one path doesn't enable the other:

| Connection | Required access |
| --- | --- |
| Application Network managed control plane to the member's Kubernetes API server | For a public API server, permit the Application Network source addresses through any API-server access restrictions. For a private API server, follow the [private-connectivity requirements](private-connectivity). |
| Member cluster data plane to its Application Network managed control plane (MCP) | Allow DNS resolution and outbound TLS connections to the member's MCP FQDN on **TCP 443**. These connections carry configuration discovery and workload certificate requests. |

Meet these requirements in addition to the [standard AKS outbound network requirements](../aks/outbound-rules-control-egress).

### Public API-server authorized IP ranges

If a public AKS cluster uses [API-server authorized IP ranges](../aks/api-server-authorized-ip-ranges), the allowed sources must include Application Network's managed control-plane egress addresses. Application Network uses the **`CloudAppLink`** service tag for these addresses.

Important

Using a service-tag name in AKS authorized IP ranges requires separate enablement for `Microsoft.ContainerService/EnableServiceTagAuthorizedIPPreview`. Public API Server VNet Integration configurations can have additional service-tag availability requirements. Confirm the supported configuration with the Application Network and AKS teams before using the tag.

AppNet `PublicPreview` or `PrivatePath` registration doesn't enable AKS service-tag support. Don't assume that `CloudAppLink` is available through the standard public service-tag catalog or that the AKS authorized IP ranges setting accepts tag names without this enablement.

When updating authorized IP ranges, retain the existing approved administrator, automation, and cluster egress ranges. An update replaces the configured list; adding Application Network access must not remove those entries. If service-tag entries aren't available for your subscription, obtain the supported source-address configuration from the service team rather than using a guessed CIDR or opening the API server to all sources.

This requirement applies to a **public** API server. It doesn't use `connectivityProfile.privateConnect` or enable the private-connect path for public AKS clusters.

### Data plane outbound access to the MCP

If the member cluster has a firewall, proxy, network policy, or other egress restriction, allow its data plane to resolve and reach the assigned MCP hostname over TLS on TCP 443. This requirement applies to both public and private member clusters. Private connectivity to the Kubernetes API server doesn't replace the data-plane-to-MCP connection.

Use the member's actual hostname, not a copied example, a fixed IP address, or a metrics URL including its scheme and path. See Get the managed control plane hostname for the current endpoint discovery method.

Plan this access before onboarding. If initial provisioning is blocked before the assigned endpoint is available, coordinate the hostname and bootstrap access requirements with the Application Network team. Don't treat an empty endpoint as permission to use an unrestricted outbound rule.

## Set environment variables

- Set the following environment variables for your Azure Kubernetes Application Network resource and cluster. You can use an existing cluster or create one in a later step **before** adding it to your Azure Kubernetes Application Network.

    ```bash
    export SUBSCRIPTION=<subscription-id>
    export LOCATION=<location>
    export APPNET_RG=<resource-group-for-appnet-resource>
    export APPNET_NAME=<appnet-name>
    export APPNET_MEMBER_NAME=<appnet-member-name>
    export AKS_RG=<aks-cluster-resource-group>
    export CLUSTER_NAME=<cluster-name>
    ```

## Register the feature for public preview

1. Register the feature for Azure Kubernetes Application Network using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

    ```azurecli
    az feature register --namespace Microsoft.AppLink --name PublicPreview --subscription $SUBSCRIPTION
    ```
2. Wait for the feature to be registered. You can check the status using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command.

    ```azurecli
    az feature show --namespace Microsoft.AppLink --name PublicPreview --subscription $SUBSCRIPTION
    ```

    The `properties.state` field in the output will show `Registered` when the registration is complete.
3. After the feature is registered, refresh the registration of the Microsoft.AppLink resource provider using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace Microsoft.AppLink --subscription $SUBSCRIPTION
    ```

## Install the AppNet CLI extension

- Install the AppNet CLI extension using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command.

    ```azurecli
    az extension add --name appnet-preview
    ```

## Set active subscription

- Set the active subscription to the one you want to use for Azure Kubernetes Application Network using the [`az account set`](/en-us/cli/azure/account#az-account-set) command.

    ```azurecli
    az account set --subscription $SUBSCRIPTION 
    ```

## Create an AKS cluster

Note

Member clusters **don't** need to be in separate resource groups. They can be in the same resource group as the Azure Kubernetes Application Network resource. However, all member clusters must be in the same tenant.

If you don't have an existing AKS cluster to connect to Azure Kubernetes Application Network, you need to create one. Azure Kubernetes Application Network requires AKS clusters that meet the following requirements:

- [Istio-based service mesh add-on](/en-us/azure/aks/istio-about) (`ServiceMeshProfile`) is **not** enabled.
- [AKS-managed Microsoft Entra integration](/en-us/azure/aks/entra-id-control-plane-authentication) is enabled.
- [OIDC issuer](/en-us/azure/aks/use-oidc-issuer) is enabled.
- [Managed Kubernetes Gateway API installation](/en-us/azure/aks/managed-gateway-api) is enabled.

If you have an existing cluster that already meets these requirements, you can skip this step.

1. Create a resource group for your AKS cluster using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    az group create --name $AKS_RG --location $LOCATION 
    ```
2. Create an AKS cluster with AKS-managed Microsoft Entra integration, OIDC issuer, and the managed Kubernetes Gateway API add-on enabled using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--enable-oidc-issuer`, `--enable-aad`, and `--enable-gateway-api` flags. Do **not** enable the Istio service mesh add-on (`--enable-azure-service-mesh`) on this cluster.

    ```azurecli
    az aks create --name $CLUSTER_NAME --resource-group $AKS_RG --enable-oidc-issuer --enable-aad --enable-gateway-api
    ```

## Create an Azure Kubernetes Application Network resource

1. Create a resource group for your Azure Kubernetes Application Network resource using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    az group create --name $APPNET_RG --location $LOCATION 
    ```
2. Create an Azure Kubernetes Application Network resource using the [`az appnet create`](/en-us/cli/azure/appnet#az-appnet-create) command.

    Note

    You can't change an Application Network resource's location, subscription, or resource group after you create it.

    ```azurecli
    az appnet create --resource-group $APPNET_RG --name $APPNET_NAME --location $LOCATION  --identity-type SystemAssigned
    ```

    The creation process might take a few minutes. The `properties.provisioningState` field of the output shows `Succeeded` for a successfully created Azure Kubernetes Application Network.
3. View your Azure Kubernetes Application Network resource using the [`az appnet show`](/en-us/cli/azure/appnet#az-appnet-show) command.

    ```azurecli
    az appnet show --resource-group $APPNET_RG --name $APPNET_NAME
    ```

## Join an AKS cluster as a member of Azure Kubernetes Application Network

When you join a member cluster to Azure Kubernetes Application Network, you can specify one of the following upgrade modes for that cluster: **fully-managed** or **self-managed**. The upgrade mode determines how minor version upgrades of Azure Kubernetes Application Network are applied to the member cluster. If you don't specify an upgrade mode during member join, it defaults to `SelfManaged`. For more information about upgrade modes, see [Configure upgrades for Azure Kubernetes Application Network members](upgrades).

For multi-cluster deployments, [choose your connectivity topology](multi-cluster-connectivity) before joining members. Network names describe whether members share direct pod-IP connectivity or communicate through east-west gateways.

Note

You can't change a member's parent Application Network, location, subscription, or resource group after you join it. To change any of these, remove the member and rejoin it with the new values.

- Join an AKS cluster as a member of Azure Kubernetes Application Network using the [`az appnet member join`](/en-us/cli/azure/appnet/member#az-appnet-member-join) command with the `--upgrade-mode` parameter set to either `FullyManaged` or `SelfManaged`. The following example shows how to join a member cluster in `SelfManaged` mode:

    ```azurecli
    az appnet member join \
        --resource-group $APPNET_RG \
        --appnet-name $APPNET_NAME \
        --member-name $APPNET_MEMBER_NAME \
        --member-resource-id /subscriptions/$SUBSCRIPTION/resourcegroups/$AKS_RG/providers/Microsoft.ContainerService/managedClusters/$CLUSTER_NAME \
        --upgrade-mode SelfManaged
    ```

## Verify member cluster connectivity

- After joining the cluster, check member provisioning and view its details by using the [`az appnet member show`](/en-us/cli/azure/appnet/member#az-appnet-member-show) command. A successful ARM operation alone doesn't verify application traffic or all network paths.

    ```azurecli
    az appnet member show --resource-group $APPNET_RG --appnet-name $APPNET_NAME --member-name $APPNET_MEMBER_NAME
    ```

    For example, if enrolled in fully-managed mode with `Stable` release channel, the output would look like:

    ```output
    {
      "id": "/subscriptions/$SUBSCRIPTION/resourceGroups/$APPNET_RG/providers/Microsoft.AppLink/appLinks/$APPNET_NAME/appLinkMembers/$APPNET_MEMBER_NAME",
      "location": "myLocation",
      "name": "myMemberName",
      "properties": {
        "clusterType": "AKS",
        "connectivityProfile": {
          "eastWestGateway": {
            "visibility": "Internal"
          }
        },
        "metadata": {
          "resourceId": "/subscriptions/$SUBSCRIPTION/resourcegroups/$AKS_RG/providers/Microsoft.ContainerService/managedClusters/$CLUSTER_NAME"
        },
        "observabilityProfile": {
          "metrics": {
            "metricsEndpoint": "https://myMember-mcp-fqdn.appnet.net"
          }
        },
        "provisioningState": "Succeeded",
        "upgradeProfile": {
          "mode": "FullyManaged",
          "fullyManagedUpgradeProfile": {
            "releaseChannel": "Stable"
          }
        }
      },
      "resourceGroup": "myAppNetRG",
      "type": "microsoft.applink/applinks/applinkmembers"
    }
    ```

### Get the managed control plane hostname

- Read the member's endpoint URL by using the [`az appnet member show`](/en-us/cli/azure/appnet/member#az-appnet-member-show) command:

    ```azurecli
    az appnet member show \
        --resource-group $APPNET_RG \
        --appnet-name $APPNET_NAME \
        --member-name $APPNET_MEMBER_NAME \
        --query properties.observabilityProfile.metrics.metricsEndpoint \
        -o tsv
    ```

    `metricsEndpoint` is a read-only metrics URL. Its hostname currently identifies the same MCP endpoint used for configuration discovery and certificate requests. For an FQDN-based egress rule, use only that hostname, without `https://`, a path, or a port suffix, and permit TCP 443.

    Don't set this property in a join or update request. If the returned value is empty during initial or failed provisioning, the endpoint isn't exposed yet. Follow the bootstrap access guidance rather than inventing a destination.

## List Azure Kubernetes Application Network members

Multiple clusters can join an Azure Kubernetes Application Network.

- List all members of an Azure Kubernetes Application Network using the [`az appnet member list`](/en-us/cli/azure/appnet/member#az-appnet-member-list) command.

    ```azurecli
    az appnet member list --resource-group $APPNET_RG --appnet-name $APPNET_NAME --output table
    ```

## Delete Azure Kubernetes Application Network resources

Deleting an Azure Kubernetes Application Network resource automatically removes all of its members, so you don't need to remove members first. Removing a member, whether individually or through this cascade, doesn't delete the corresponding AKS cluster.

### Remove an Azure Kubernetes Application Network member

Note

Before removing a member, you must remove your workloads from the ambient data plane by removing Istio labels you previously applied, such as `istio.io/use-waypoint`, `istio.io/use-waypoint-namespace`, and `istio.io/dataplane-mode`, from resources.

1. Remove a member from Azure Kubernetes Application Network using the [`az appnet member remove`](/en-us/cli/azure/appnet/member#az-appnet-member-remove) command.

    ```azurecli
    az appnet member remove --resource-group $APPNET_RG --appnet-name $APPNET_NAME --member-name $APPNET_MEMBER_NAME
    ```
2. Verify the member has been removed using the [`az appnet member list`](/en-us/cli/azure/appnet/member#az-appnet-member-list) command.

    ```azurecli
    az appnet member list --resource-group $APPNET_RG --appnet-name $APPNET_NAME 
    ```

### Delete an Azure Kubernetes Application Network resource

- Delete the Azure Kubernetes Application Network resource using the [`az appnet delete`](/en-us/cli/azure/appnet#az-appnet-delete) command.

    ```azurecli
    az appnet delete --resource-group $APPNET_RG --appnet-name $APPNET_NAME
    ```