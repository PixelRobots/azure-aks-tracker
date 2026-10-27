---
layout: Conceptual
title: Set up identity bindings on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/identity-bindings
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
description: Learn how to enable and configure identity bindings on AKS to map a user-assigned managed identity (UAMI) across multiple clusters while using a single federated identity credential.
ms.topic: how-to
ms.subservice: aks-security
ms.date: 2026-09-02T00:00:00.0000000Z
ai-usage: ai-assisted
author: shashankbarsin
ms.author: shasb
ms.reviewer: schaffererin
locale: en-us
document_id: 1e93e336-e981-a931-7b47-4159a8601f7d
document_version_independent_id: 8d96d760-69e9-ed88-7030-aae8baa01c45
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/identity-bindings.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/identity-bindings
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/identity-bindings.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
- https://authoring-docs-microsoft.poolparty.biz/devrel/fcc3cd4a-59ea-47a2-9cc1-784142a5a25d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7a55faf-a992-4e27-aa3a-eadc9830e778
platformId: 8f8fe7cd-dbce-1fb5-192c-e128b00802f8
---

# Set up identity bindings on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Set up [identity bindings](identity-bindings-concepts) on your Azure Kubernetes Service (AKS) clusters to map a user-assigned managed identity (UAMI) across multiple clusters while using a single federated identity credential (FIC). This setup helps you scale Microsoft Entra authentication for workloads without hitting FIC limits.

## Prerequisites

- Review [Identity bindings concepts](identity-bindings-concepts) to understand how identity bindings work.
- Azure CLI version 2.73.0 or later. To check your version, use the `az version` command. To install or update the Azure CLI, see [Install the Azure CLI](/en-us/cli/azure/install-azure-cli).
- You need the following Azure permissions on the identity and cluster scope: `Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials/write` and `Microsoft.ContainerService/managedClusters/write`.
- You need Kubernetes cluster admin (or equivalent) permissions to create `ClusterRole` and `ClusterRoleBinding` resources.

## Limitations

- Identity bindings aren't yet supported on clusters configured with [API server VNet integration](/en-us/azure/aks/api-server-vnet-integration).

## Create test resources

1. Create an Azure resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    export RESOURCE_GROUP="ib-test"
    export LOCATION="westus2"
    
    az group create --name $RESOURCE_GROUP --location $LOCATION
    ```
2. Create an AKS cluster with workload identity and OIDC issuer enabled using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--enable-workload-identity` and `--enable-oidc-issuer` flags.

    ```azurecli
    export CLUSTER_NAME="ib-test-cluster"
    
    az aks create --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --location $LOCATION --no-ssh-key --enable-workload-identity --enable-oidc-issuer
    ```
3. Create a user-assigned managed identity (UAMI) using the [`az identity create`](/en-us/cli/azure/identity#az-identity-create) command.

    ```azurecli
    export MI_NAME="ib-test-mi"
    az identity create --resource-group $RESOURCE_GROUP --name $MI_NAME
    ```

## Get the UAMI IDs

- Get the resource, principal, client, and tenant IDs of the UAMI and set them as environment variables using the following [`az identity show`](/en-us/cli/azure/identity#az-identity-show) commands:

    ```azurecli
    export MI_RESOURCE_ID=$(az identity show --resource-group $RESOURCE_GROUP --name $MI_NAME --query id --output tsv)
    export MI_PRINCIPAL_ID=$(az identity show --resource-group $RESOURCE_GROUP --name $MI_NAME --query principalId --output tsv)
    export MI_CLIENT_ID=$(az identity show --resource-group $RESOURCE_GROUP --name $MI_NAME --query clientId --output tsv)
    export MI_TENANT_ID=$(az identity show --resource-group $RESOURCE_GROUP --name $MI_NAME --query tenantId --output tsv)
    ```

## Create an identity binding

- Map the UAMI to the AKS cluster with an identity binding using the [`az aks identity-binding create`](/en-us/cli/azure/aks/identity-binding#az-aks-identity-binding-create) command.

    ```azurecli
    az aks identity-binding create --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --name "${MI_NAME}-ib" --managed-identity-resource-id $MI_RESOURCE_ID
    ```

    Note

    When you create an identity binding, AKS automatically creates a federated identity credential (FIC) named `aks-identity-binding` under the UAMI. This credential is managed by AKS. Don't modify or delete it while identity bindings are in use. The FIC created for identity bindings is shared across all identity bindings referencing the same UAMI.

## Get the OIDC issuer URL for the UAMI

- Get the OIDC issuer URL associated with the UAMI by inspecting the identity binding using the [`az aks identity-binding show`](/en-us/cli/azure/aks/identity-binding#az-aks-identity-binding-show) command.

    ```azurecli
    az aks identity-binding show --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --name "${MI_NAME}-ib"
    ```

    Condensed example output:

    ```output
    {
      "oidcIssuer": {
        "oidcIssuerUrl": "https://ib.oic.prod-aks.azure.com/<MI-tenant-id>/<MI-client-id>"
      }
    }
    ```

## Connect to the AKS cluster

1. Get the AKS cluster credentials using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command and save them to a separate kubeconfig file:

    ```azurecli
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME -a -f "${CLUSTER_NAME}.kubeconfig"
    ```
2. Set the `KUBECONFIG` environment variable to point to the new kubeconfig file:

    ```bash
    export KUBECONFIG="$(pwd)/${CLUSTER_NAME}.kubeconfig"
    ```

## Authorize namespaces and service accounts

- Configure role-based access control (RBAC) to grant specific subjects the permission to use the managed identity via identity binding by applying the following manifest using with the following `kubectl apply` command.

    Note

    The following example explicitly refers to the `demo` service account in the `demo` namespace. While explicitly referring to a specific service account is one option, it's also possible to refer to a collection of service accounts under `subjects`. For more information, see [Referring to subjects](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#referring-to-subjects) in the Kubernetes documentation.

    ```bash
    kubectl apply -f - <<EOF
    apiVersion: v1
    kind: Namespace
    metadata:
      name: demo
    ---
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: demo
      namespace: demo
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: use-mi-${MI_CLIENT_ID}
    rules:
      - verbs: ["use-managed-identity"]
        apiGroups: ["cid.wi.aks.azure.com"]
        resources: ["${MI_CLIENT_ID}"]
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: use-mi-${MI_CLIENT_ID}
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: use-mi-${MI_CLIENT_ID}
    subjects:
      - kind: ServiceAccount
        name: demo
        namespace: demo
    EOF
    ```

## Create a key vault with purge protection and Azure RBAC authorization

- Create a key vault with purge protection and Azure RBAC authorization enabled using the [`az keyvault create`](/en-us/cli/azure/keyvault#az-keyvault-create) command with the `--enable-purge-protection` and `--enable-rbac-authorization` flags. You can also use an existing key vault if it's configured for both purge protection and Azure RBAC authorization.

    ```azurecli
    export KEY_VAULT_NAME="ib-test"
    
    az keyvault create \
        --name $KEY_VAULT_NAME \
        --resource-group $RESOURCE_GROUP \
        --location $LOCATION \
        --enable-purge-protection \
        --enable-rbac-authorization
    ```

## Get the key vault resource ID and URL

1. Get the resource ID of the key vault using the [`az keyvault show`](/en-us/cli/azure/keyvault#az-keyvault-show) command and set it as an environment variable:

    ```azurecli
    export KEY_VAULT_RESOURCE_ID=$(az keyvault show --resource-group $RESOURCE_GROUP \
        --name $KEY_VAULT_NAME \
        --query id \
        --output tsv)
    ```
2. Get the key vault URL using the [`az keyvault show`](/en-us/cli/azure/keyvault#az-keyvault-show) command and set it as an environment variable:

    ```azurecli
    export KEYVAULT_URL="$(az keyvault show \
        --resource-group $RESOURCE_GROUP \
        --name $KEY_VAULT_NAME \
        --query properties.vaultUri \
        --output tsv)"
    ```

## Configure key vault access and create secret

The following steps show how to access secrets, keys, or certificates in Azure Key Vault from the pod. The examples in this section configure access to secrets in the key vault for the workload identity, but you can perform similar steps to configure access to keys or certificates.

The following example shows how to use the Azure RBAC permission model to grant the pod access to the key vault. For more information about the Azure RBAC permission model for Azure Key Vault, see [Grant permission to applications to access Azure Key Vault using Azure RBAC](/en-us/azure/key-vault/general/rbac-guide).

1. Get the object ID of the signed-in user using the [`az ad signed-in-user show`](/en-us/cli/azure/ad/signed-in-user#az-ad-signed-in-user-show) command and set it as an environment variable:

    ```azurecli
    export CALLER_OBJECT_ID=$(az ad signed-in-user show --query id --output tsv)
    ```
2. Assign yourself the Azure RBAC [Key Vault Secrets Officer](/en-us/azure/role-based-access-control/built-in-roles/security#key-vault-secrets-officer) role on the key vault using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command.

    ```azurecli
    az role assignment create --assignee $CALLER_OBJECT_ID \
        --role "Key Vault Secrets Officer" \
        --scope $KEY_VAULT_RESOURCE_ID
    ```
3. Create a secret in the key vault using the [`az keyvault secret set`](/en-us/cli/azure/keyvault/secret#az-keyvault-secret-set) command.

    ```azurecli
    export KEY_VAULT_SECRET_NAME="my-secret"
    
    az keyvault secret set \
        --vault-name $KEY_VAULT_NAME \
        --name $KEY_VAULT_SECRET_NAME \
        --value "Hello\!"
    ```
4. Assign the [Key Vault Secrets User](/en-us/azure/role-based-access-control/built-in-roles/security#key-vault-secrets-user) role to the UAMI using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command.

    ```azurecli
    az role assignment create \
        --assignee-object-id $MI_PRINCIPAL_ID \
        --role "Key Vault Secrets User" \
        --scope $KEY_VAULT_RESOURCE_ID \
        --assignee-principal-type ServicePrincipal
    ```

## Annotate service account

1. Annotate the service account with the managed identity tenant ID using the `kubectl annotate` command.

    ```bash
    kubectl annotate sa demo -n demo azure.workload.identity/tenant-id=$MI_TENANT_ID
    ```
2. Annotate the service account with the managed identity client ID using the `kubectl annotate` command.

    ```bash
    kubectl annotate sa demo -n demo azure.workload.identity/client-id=$MI_CLIENT_ID
    ```

## Deploy sample application

- Deploy the sample pod that uses identity binding to obtain an access token for the managed identity to access Azure Key Vault using the following `kubectl apply` command:

    ```bash
    kubectl apply -f - <<EOF
    apiVersion: v1
    kind: Pod
    metadata:
      name: demo
      namespace: demo
      labels:
        azure.workload.identity/use: "true"
      annotations:
        azure.workload.identity/use-identity-binding: "true"
    spec:
      serviceAccount: demo
      containers:
        - name: azure-sdk
          # source code: https://github.com/Azure/azure-workload-identity/blob/feature/custom-token-endpoint/examples/identitybinding-msal-go/main.go
          image: ghcr.io/bahe-msft/azure-workload-identity/identitybinding-msal-go:latest-linux-amd64
          env:
            - name: KEYVAULT_URL
              value: ${KEYVAULT_URL}
            - name: SECRET_NAME
              value: ${KEY_VAULT_SECRET_NAME}
      restartPolicy: Never
    EOF
    ```

## Verify access to key vault from sample application

1. Describe the pod and confirm environment variables and projected token volume mounts are present using the `kubectl describe pod` command.

    ```bash
    kubectl describe pod demo -n demo
    ```

    Expected output should contain values for `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_FEDERATED_TOKEN_FILE`, `AZURE_AUTHORITY_HOST`, `AZURE_KUBERNETES_TOKEN_PROXY`. `AZURE_KUBERNETES_SNI_NAME`, and `AZURE_KUBERNETES_CA_FILE`.
2. Verify the pod can get a token and access the resource using the `kubectl logs` command.

    ```bash
    kubectl logs demo -n demo
    ```

    If successful, the output should be similar to the following example:

    ```output
    I1107 20:03:42.865180       1 main.go:77] "successfully got secret" secret="Hello!"
    ```

## Scale identity bindings across multiple clusters

Identity bindings allow mapping multiple AKS clusters to the same UAMI while still using a single FIC. To scale identity bindings across multiple clusters, you can repeat the steps from Create an identity binding through verify access to key vault from sample application for each extra cluster you want to map to the same UAMI (creating a new identity binding per cluster).

## Clean up resources

If you no longer need the resources you created in this article, you can clean them up to avoid incurring future costs.

1. Delete the pod using the `kubectl delete pod` command.

    ```bash
    kubectl delete pod demo -n demo
    ```
2. Delete the namespace using the `kubectl delete ns` command.

    ```bash
    kubectl delete ns demo
    ```
3. Delete the resource group and all related resources using the [`az group delete`](/en-us/cli/azure/group#az-group-delete) command.

    ```azurecli
    az group delete --name $RESOURCE_GROUP --yes --no-wait
    ```