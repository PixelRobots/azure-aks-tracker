---
layout: Conceptual
title: Enable Microsoft Entra ID Authentication for the Azure Kubernetes Service (AKS) Control Plane - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/entra-id-control-plane-authentication
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
description: Learn how to enable Microsoft Entra ID authentication for the Kubernetes API server (control plane) on an Azure Kubernetes Service (AKS) cluster.
ms.topic: how-to
ms.subservice: aks-security
ms.date: 2026-04-19T00:00:00.0000000Z
ms.custom: devx-track-azurecli
author: shashankbarsin
ms.author: shasb
ai-usage: ai-assisted
locale: en-us
document_id: 8cf839f2-0fdd-80c3-6109-1362d4e4a02c
document_version_independent_id: 46fba067-8ec5-574f-d7d8-b026ea9204a6
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/entra-id-control-plane-authentication.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/entra-id-control-plane-authentication
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/entra-id-control-plane-authentication.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/57eae307-c3a1-4cac-b645-1a899934bac8
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/1433a524-c01f-4b87-beab-670c040dea4f
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/ee561821-1ac7-45a8-9409-6ba5eb7a5b97
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/312f1f05-a431-4193-8a4d-e6245d5966de
platformId: a2d68177-0dda-0c3e-2377-cc6c076780c4
---

# Enable Microsoft Entra ID Authentication for the Azure Kubernetes Service (AKS) Control Plane - Azure Kubernetes Service | Microsoft Learn

The Microsoft Entra integration simplifies the process of enabling Entra-based authentication for AKS. Previously, you were required to create a client and server app, and the Microsoft Entra tenant had to assign [Directory Readers](/en-us/entra/identity/role-based-access-control/permissions-reference#directory-readers) role permissions. Now, the Azure Kubernetes Service (AKS) resource provider manages the client and server apps for you.

Cluster administrators can configure Kubernetes role-based access control (Kubernetes RBAC) based on a user's identity or directory group membership.

Learn more about the Microsoft Entra integration flow in the [Microsoft Entra documentation](concepts-cluster-authentication).

## Limitations

Microsoft Entra integration can't be disabled after it's enabled on a cluster.

## Before you begin

To install the AKS add-on, verify you have the following items:

- You have Azure CLI version 2.29.0 or later installed and configured. To find the version, run the `az --version` command. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- You need `kubectl` with a minimum version of [1.18.1](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.18.md#v1181) or [`kubelogin`](https://github.com/Azure/kubelogin). With the Azure CLI and the Azure PowerShell module, `kubectl` and `kubelogin` are included and automatically managed. Meaning, they're upgraded by default and running [`az aks install-cli`](/en-us/cli/azure/aks#az-aks-install-cli) isn't required or recommended. If you're using an automated pipeline, you need to manage upgrades for the correct or latest version. The difference between the minor versions of Kubernetes and `kubectl` shouldn't be more than *one* version. Otherwise, authentication issues occur on the wrong version.
- This configuration requires you have a Microsoft Entra group for your cluster. This group is registered as an admin group on the cluster to grant admin permissions. If you don't have an existing Microsoft Entra group, you can create one using the [`az ad group create`](/en-us/cli/azure/ad/group#az-ad-group-create) command.

## Enable the integration on your AKS cluster

First, set environment variables for the resource group, cluster name, Microsoft Entra admin group object IDs, and tenant ID. Reuse these variables in the commands that follow.

```azurecli
export RESOURCE_GROUP="myResourceGroup"
export CLUSTER_NAME="myManagedCluster"
export AAD_ADMIN_GROUP_OBJECT_IDS="<group-object-id>"  # comma-separated for multiple groups
export AAD_TENANT_ID="<tenant-id>"
export LOCATION="centralus"
```

### Create a new cluster

1. Create an Azure resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    az group create --name $RESOURCE_GROUP --location $LOCATION
    ```
2. Create an AKS cluster and enable administration access for your Microsoft Entra group using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command.

    ```azurecli
    az aks create \
      --resource-group $RESOURCE_GROUP \
      --name $CLUSTER_NAME \
      --enable-aad \
      --aad-admin-group-object-ids $AAD_ADMIN_GROUP_OBJECT_IDS \
      --aad-tenant-id $AAD_TENANT_ID \
      --generate-ssh-keys
    ```

    A successful creation of a Microsoft Entra ID cluster has the following section in the response body.

    ```output
    "AADProfile": {
      "adminGroupObjectIds": [
      "aaaaaaaa-0000-1111-2222-bbbbbbbbbbbb"
      ],
      "clientAppId": null,
      "managed": true,
      "serverAppId": null,
      "serverAppSecret": null,
      "tenantId": "aaaabbbb-0000-cccc-1111-dddd2222eeee"
    }
    ```

### Use an existing cluster

Enable Microsoft Entra integration on your existing Kubernetes RBAC enabled cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command. Make sure to set your admin group to keep access on your cluster.

```azurecli
az aks update \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --enable-aad \
  --aad-admin-group-object-ids $AAD_ADMIN_GROUP_OBJECT_IDS \
  --aad-tenant-id $AAD_TENANT_ID
```

A successful activation of a Microsoft Entra ID cluster has the following section in the response body:

```output
"AADProfile": {
  "adminGroupObjectIds": [
      "aaaaaaaa-0000-1111-2222-bbbbbbbbbbbb"
  ],
  "clientAppId": null,
  "managed": true,
  "serverAppId": null,
  "serverAppSecret": null,
  "tenantId": "aaaabbbb-0000-cccc-1111-dddd2222eeee"
}
```

### Migrate legacy cluster to integration

If your cluster uses legacy Microsoft Entra integration, you can upgrade to Microsoft Entra integration through the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command.

Warning

Free tier clusters might experience API server downtime during the upgrade. We recommend upgrading during your nonbusiness hours. After the upgrade, the `kubeconfig` content changes. You need to run `az aks get-credentials --resource-group <AKS resource group name> --name <AKS cluster name>` to merge the new credentials into the `kubeconfig` file.

```azurecli
az aks update \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --enable-aad \
  --aad-admin-group-object-ids $AAD_ADMIN_GROUP_OBJECT_IDS \
  --aad-tenant-id $AAD_TENANT_ID
```

A successful migration of a Microsoft Entra ID cluster has the following section in the response body:

```output
"AADProfile": {
  "adminGroupObjectIds": [
      "aaaaaaaa-0000-1111-2222-bbbbbbbbbbbb"
  ],
  "clientAppId": null,
  "managed": true,
  "serverAppId": null,
  "serverAppSecret": null,
  "tenantId": "aaaabbbb-0000-cccc-1111-dddd2222eeee"
}
```

## Access your enabled cluster

1. Get the user credentials to access your cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
    ```
2. Follow your sign in instructions.
3. View the nodes in the cluster with the `kubectl get nodes` command.

    ```azurecli
    kubectl get nodes
    ```

Clusters running Kubernetes 1.24 or later automatically use the `kubelogin` exec-plugin format, so no manual `kubeconfig` conversion is needed for interactive Azure CLI sign-in. For non-interactive scenarios such as CI pipelines, or to use a different authentication method (service principal, managed identity, workload identity, or device code), see [Use kubelogin to authenticate users in AKS](kubelogin-authentication).

## Break-glass access

In the rare event that Microsoft Entra ID sign-in to your cluster's Kubernetes API server isn't working — for example, during a wider Microsoft Entra service incident — you can fall back to the cluster's local admin account to keep operating the cluster until Entra-based sign-in is restored.

Note

This fallback is only needed when Entra-based sign-in itself is unavailable. If your problem is a misconfigured admin group (for example, the group was deleted or the wrong object ID was set), you don't need it — update the admin group directly with `az aks update --aad-admin-group-object-ids` using an account that has the `Microsoft.ContainerService/managedClusters/write` permission.

Important

This workflow bypasses Microsoft Entra authentication. Use it only as a temporary fallback, and disable local accounts again once Microsoft Entra sign-in is restored.

To use the break-glass path, you need the [Azure Kubernetes Service Contributor](/en-us/azure/role-based-access-control/built-in-roles#azure-kubernetes-service-contributor-role) role on the cluster resource. This role grants the `Microsoft.ContainerService/managedClusters/write` permission required to re-enable local accounts, plus access to the local cluster-admin credential. It's evaluated by Azure Resource Manager, so it works independently of the Microsoft Entra sign-in path to the Kubernetes API server.

1. If [local accounts](local-accounts) are disabled on the cluster, re-enable them temporarily.

    ```azurecli
    az aks update --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --enable-local-accounts
    ```
2. Retrieve the local cluster-admin credential using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command with the `--admin` flag. This credential is a certificate-based kubeconfig that bypasses Microsoft Entra.

    ```azurecli
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --admin
    ```
3. Use `kubectl` to operate the cluster while Microsoft Entra is unavailable. Once Microsoft Entra sign-in is working again, [disable local accounts](local-accounts#disable-local-accounts) to return the cluster to its secure baseline.

    ```azurecli
    az aks update --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --disable-local-accounts
    ```