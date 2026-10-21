---
layout: Conceptual
title: Get secure resource access to Azure Kubernetes Service (AKS) using Trusted Access - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/trusted-access-feature
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
description: Learn how to use the Trusted Access feature to give Azure resources access to Azure Kubernetes Service (AKS) clusters.
author: schaffererin
ms.topic: how-to
ms.subservice: aks-security
ms.custom: devx-track-azurecli, innovation-engine
ms.date: 2024-11-05T00:00:00.0000000Z
ms.author: schaffererin
locale: en-us
document_id: f304188d-9a6d-65a8-b603-cb4983f2f399
document_version_independent_id: 6dcf362b-c312-4cb5-1f77-5f9a0281bbcd
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/trusted-access-feature.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/trusted-access-feature
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/trusted-access-feature.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/fcc3cd4a-59ea-47a2-9cc1-784142a5a25d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7a55faf-a992-4e27-aa3a-eadc9830e778
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 67fa3862-b906-10aa-e193-05a60ceff392
---

# Get secure resource access to Azure Kubernetes Service (AKS) using Trusted Access - Azure Kubernetes Service | Microsoft Learn

This article shows you how to get secure access for your Azure services to your Kubernetes API server in Azure Kubernetes Service (AKS) using Trusted Access.

The Trusted Access feature gives services secure access to AKS API server by using the Azure back end without requiring a private endpoint. Instead of relying on identities that have [Microsoft Entra](/en-us/azure/active-directory/fundamentals/active-directory-whatis) permissions, this feature can use your system-assigned managed identity to authenticate with the managed services and applications that you want to use with your AKS clusters.

Note

The Trusted Access API is generally available. We provide general availability (GA) support for the Azure CLI, but it's still in preview and requires using the aks-preview extension.

## Trusted Access feature overview

Trusted Access addresses the following scenarios:

- If an authorized IP range is set or in a private cluster, Azure services might not be able to access the Kubernetes API server unless you implement a private endpoint access model.
- Giving an Azure service admin access to the Kubernetes API doesn't follow the least privilege access best practice and can lead to privilege escalations or risk of credentials leakage. For example, you might have to implement high-privileged service-to-service permissions, and they aren't ideal in an audit review.

You can use Trusted Access to give explicit consent to your system-assigned managed identity of allowed resources to access your AKS clusters by using an Azure resource called a *role binding*. Your Azure resources access AKS clusters through the AKS regional gateway via system-assigned managed identity authentication. The appropriate Kubernetes permissions are assigned via an Azure resource called a *role*. Through Trusted Access, you can access AKS clusters with different configurations including but not limited to [private clusters](private-clusters), [clusters that have local accounts turned off](local-accounts#disable-local-accounts), [Microsoft Entra clusters](entra-id-control-plane-authentication), and [authorized IP range clusters](api-server-authorized-ip-ranges).

## Prerequisites

- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- Resource types that support [system-assigned managed identity](/en-us/azure/active-directory/managed-identities-azure-resources/overview).
- Azure CLI version 2.53.0 or later. Run `az --version` to find your version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- To learn what roles to use in different scenarios, see these articles:
    - [Azure Machine Learning access to AKS clusters with special configurations](https://github.com/Azure/AML-Kubernetes/blob/master/docs/azureml-aks-ta-support.md)
    - [What is Azure Kubernetes Service backup?](/en-us/azure/backup/azure-kubernetes-service-backup-overview)
    - [Turn on an agentless container posture](/en-us/azure/defender-for-cloud/concept-agentless-containers)
- In the same subscription as the Azure resource that you want to access the cluster, [create an AKS cluster](tutorial-kubernetes-deploy-cluster).

## Connect to your cluster

Configure `kubectl` to connect to your cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

```azurecli
export RESOURCE_GROUP_NAME="myResourceGroup"
export CLUSTER_NAME="myClusterName"

az aks get-credentials --resource-group ${RESOURCE_GROUP_NAME} --name ${CLUSTER_NAME} --overwrite-existing
```

Verify the connection to your cluster using the `kubectl get` command.

```bash
kubectl get nodes
```

## Select the required Trusted Access roles

The roles that you select depend on the Azure services that you want to access the AKS cluster. Azure services help create roles and role bindings that build the connection from the Azure service to AKS.

To find the roles that you need, see the documentation for the Azure service that you want to connect to AKS. You can also use the Azure CLI to list the roles that are available for the Azure service using the `az aks trustedaccess role list --location <location>` command.

## Create a Trusted Access role binding

After you confirm which role to use, use the Azure CLI to create a Trusted Access role binding in the AKS cluster. The role binding associates your selected role with the Azure service.

```azurecli
export ROLE_BINDING_NAME="myRoleBindingName"
export SOURCE_RESOURCE_ID="mySourceResourceID"
export ROLE_NAME_1="myRoleName1"
export ROLE_NAME_2="myRoleName2"

az aks trustedaccess rolebinding create --resource-group ${RESOURCE_GROUP_NAME} --cluster-name ${CLUSTER_NAME} --name ${ROLE_BINDING_NAME} --source-resource-id ${SOURCE_RESOURCE_ID} --roles ${ROLE_NAME_1},${ROLE_NAME_2}
```

Results:

```json
{
  "id": "/subscriptions/aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e/resourceGroups/${RESOURCE_GROUP_NAME}/providers/Microsoft.ContainerService/managedClusters/${CLUSTER_NAME}/trustedAccessRoleBindings/${ROLE_BINDING_NAME}",
  "name": "${ROLE_BINDING_NAME}",
  "provisioningState": "Succeeded",
  "resourceGroup": "${RESOURCE_GROUP_NAME}",
  "roles": [
    "${ROLE_NAME_1}",
    "${ROLE_NAME_2}"
  ],
  "sourceResourceId": "${SOURCE_RESOURCE_ID}",
  "systemData": null,
  "type": "Microsoft.ContainerService/managedClusters/trustedAccessRoleBindings"
}
```

Note

You can create up to 8 Trusted Access role bindings in an AKS cluster.

## Update an existing Trusted Access role binding

For an existing role binding that has an associated source service, you can update the role binding with new roles using the `az aks trustedaccess rolebinding update --resource-group $RESOURCE_GROUP_NAME --cluster-name $CLUSTER_NAME --name $ROLE_BINDING_NAME --roles $ROLE_NAME_3,$ROLE_NAME_4` command. This command updates the role binding with the new roles that you specify.

Note

The add-on manager updates clusters every five minutes, so the new role binding might take up to five minutes to take effect. Before the new role binding takes effect, the existing role binding still works.

You can use the `az aks trusted access rolebinding list` command to check the current role binding.

## Show a Trusted Access role binding

Show a specific Trusted Access role binding using the `az aks trustedaccess rolebinding show --name $ROLE_BINDING_NAME --resource-group $RESOURCE_GROUP_NAME --cluster-name $CLUSTER_NAME` command.

## List all the Trusted Access role bindings for a cluster

List all the Trusted Access role bindings for a cluster using the `az aks trustedaccess rolebinding list --resource-group $RESOURCE_GROUP_NAME --cluster-name $CLUSTER_NAME` command.