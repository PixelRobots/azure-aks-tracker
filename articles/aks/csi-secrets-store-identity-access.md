---
layout: Conceptual
title: Access Azure Key Vault with the CSI Driver Identity Provider - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-identity-access
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
zone_pivot_group_filename: zone-pivots/azure-aks/zone-pivot-groups.json
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn how to integrate the Azure Key Vault Provider for Secrets Store CSI Driver with your Azure credentials and user identities.
author: schaffererin
ms.author: schaffererin
ms.topic: how-to
ms.subservice: aks-security
ms.date: 2026-09-02T00:00:00.0000000Z
ms.custom: devx-track-azurecli
zone_pivot_groups: csi-secrets-store-identity-access
ai-usage: ai-assisted
locale: en-us
document_id: 2f6ef837-f693-3365-4d31-a7b466b26957
document_version_independent_id: 4a0a5d8a-60cb-2521-37ee-4255cbc891eb
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/csi-secrets-store-identity-access.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/csi-secrets-store-identity-access
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/csi-secrets-store-identity-access.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/fcc3cd4a-59ea-47a2-9cc1-784142a5a25d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7a55faf-a992-4e27-aa3a-eadc9830e778
platformId: 4315482d-119e-9ad2-e993-75ba4c2b1246
---

# Access Azure Key Vault with the CSI Driver Identity Provider - Azure Kubernetes Service | Microsoft Learn

The Secrets Store Container Storage Interface (CSI) Driver on Azure Kubernetes Service (AKS) provides various methods of identity-based access to your Azure Key Vault. This article outlines these methods and best practices for when to use Azure role-based access control (Azure RBAC) or OpenID Connect (OIDC) security models to access your key vault and AKS cluster.

You can use one of the following access methods:

- Service Connector with managed identity
- Workload ID
- Workload ID with identity bindings
- User-assigned managed identity

::: zone pivot="access-with-service-connector"

Learn how to connect to Azure Key Vault with the Secrets Store CSI Driver in an Azure Kubernetes Service (AKS) cluster using Service Connector. In this article, you complete the following tasks:

- Register the required Azure resource providers.
- Create a connection between the AKS cluster and the Azure Key Vault with Service Connector.
- Create a `SecretProviderClass` CRD and a `Pod` that consumes the CSI provider to test the connection.
- Verify that the pod can access the key vault secret.

## Prerequisites

- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- The [Azure CLI](/en-us/cli/azure/install-azure-cli). Sign in using the [`az login`](/en-us/cli/azure/reference-index#az-login) command.
- [Docker](https://docs.docker.com/get-docker/) and [kubectl](https://kubernetes.io/docs/tasks/tools/). To install kubectl locally, use the [`az aks install-cli`](/en-us/cli/azure/aks#az-aks-install-cli) command.
- A basic understanding of containers and AKS. Get started by [preparing an application for AKS](/en-us/azure/aks/tutorial-kubernetes-prepare-app).
- Before you begin, make sure you finish the steps in [Use the Azure Key Vault provider for Secrets Store CSI Driver in an Azure Kubernetes Service (AKS) cluster](csi-secrets-store-driver) to enable the Azure Key Vault Secrets Store CSI Driver in your AKS cluster.

## Initial set-up

1. If you're using Service Connector for the first time, start by running the command [az provider register](/en-us/cli/azure/provider#az-provider-register) to register the Service Connector and Kubernetes Configuration resource providers.

    ```azurecli
    az provider register -n Microsoft.ServiceLinker
    ```

    ```azurecli
    az provider register -n Microsoft.KubernetesConfiguration
    ```

    Tip

    You can check if these resource providers have already been registered by running the commands `az provider show -n "Microsoft.ServiceLinker" --query registrationState` and `az provider show -n "Microsoft.KubernetesConfiguration" --query registrationState`.
2. Optionally, use the Azure CLI command to get a list of supported target services for AKS cluster.

    ```azurecli
    az aks connection list-support-types --output table
    ```

## Create a service connection in AKS with Service Connector

You can create a service connection to Azure Key Vault using the Azure portal or Azure CLI.

# [Azure portal](#tab/azure-portal)
1. In the Azure portal, navigate to your AKS cluster resource.
2. From the service menu, under **Settings**, select **Service Connector** &gt; **Create**.
3. On the **Create connection** page, configure the following settings in the **Basics** tab:

    - **Kubernetes namespace**: Select **default**.
    - **Service type**: Select **Key Vault** and select the checkbox to enable the Azure Key Vault CSI Provider.
    - **Connection name**: Enter a name for the connection.
    - **Subscription**: Select the subscription that contains the key vault.
    - **Key vault**: Select the key vault you created.
    - **Client type**: Select **None**.
4. Select **Review + create**, and then select **Create** to create the connection.

# [Azure CLI](#tab/azure-cli)
- Create a connection to your key vault using the [`az aks connection create keyvault`](/en-us/cli/azure/aks/connection/create#az-aks-connection-create-keyvault) command.

    ```azurecli
    az aks connection create keyvault \
        --connection <connection-name> \
        --resource-group <resource-group-of-cluster> \
        --name <cluster-name> \
        --target-resource-group <resource-group-of-key-vault> \
        --vault <key-vault-name> \
        --enable-csi \
        --client-type none
    ```

---

## Test the connection

### Clone the sample repo and deploy manifest files

1. Clone the sample repository using the `git clone` command.

    ```bash
    git clone https://github.com/Azure-Samples/serviceconnector-aks-samples.git
    ```
2. Change directories to the Azure Key Vault CSI provider sample.

    ```bash
    cd serviceconnector-aks-samples/azure-keyvault-csi-provider
    ```
3. In the `secret_provider_class.yaml` file, replace the following placeholders with your Azure Key Vault information:

    - Replace `<AZURE_KEYVAULT_NAME>` with the name of the key vault you created and connected.
    - Replace `<AZURE_KEYVAULT_TENANTID>` with the tenant ID of the key vault.
    - Replace `<AZURE_KEYVAULT_CLIENTID>` with identity client ID of the `azureKeyvaultSecretsProvider` add-on.
    - Replace `<KEYVAULT_SECRET_NAME>` with the key vault secret you created. For example, `ExampleSecret`.
4. Deploy the `SecretProviderClass` CRD using the `kubectl apply` command.

    ```bash
    kubectl apply -f secret_provider_class.yaml
    ```
5. Deploy the `Pod` manifest file using the `kubectl apply` command.

    The command creates a pod named `sc-demo-keyvault-csi` in the default namespace of your AKS cluster.

    ```bash
    kubectl apply -f pod.yaml
    ```

### Verify the connection

1. Verify the pod was created successfully using the `kubectl get` command.

    ```bash
    kubectl get pod/sc-demo-keyvault-csi
    ```

    After the pod starts, the mounted content at the volume path specified in your deployment YAML is available.
2. Show the secrets held in the secrets store using the `kubectl exec` command.

    ```bash
    kubectl exec sc-demo-keyvault-csi -- ls /mnt/secrets-store/
    ```
3. Display a secret using the `kubectl exec` command.

    This example command shows a test secret named `ExampleSecret`.

    ```bash
    kubectl exec sc-demo-keyvault-csi -- cat /mnt/secrets-store/ExampleSecret
    ```

::: zone-end

::: zone pivot="access-with-a-microsoft-entra-workload-identity"

## Prerequisites for CSI Driver with workload identity

- Before you begin, make sure you finish the steps in [Use the Azure Key Vault provider for Secrets Store CSI Driver in an Azure Kubernetes Service (AKS) cluster](csi-secrets-store-driver) to enable the Azure Key Vault Secrets Store CSI Driver in your AKS cluster.
- Microsoft Entra Workload ID supports both Windows and Linux clusters.

## Access with a Microsoft Entra Workload ID

A [Microsoft Entra Workload ID](workload-identity-overview) is an identity that an application or service uses to authenticate itself against other Azure services, such as workloads in software. The Secrets Store CSI Driver integrates with native Kubernetes capabilities to federate with external identity providers.

In this security model, the AKS cluster acts as the token issuer. When the Secrets Store CSI Driver mounts the volume, it requests a Kubernetes service account token, and the Azure Key Vault provider exchanges that token for a Microsoft Entra token. The application reads the mounted files and doesn't need the Azure Identity client library or the Microsoft Authentication Library (MSAL) for this volume-mount flow. If the application independently requests Microsoft Entra tokens to call protected APIs, use Azure Identity or MSAL in the application.

The Azure Key Vault provider for Secrets Store CSI Driver add-on also supports [identity bindings](identity-bindings-concepts). Identity bindings let multiple AKS clusters use the same user-assigned managed identity (UAMI) with a single federated identity credential. This support helps you scale Key Vault access across clusters without reaching the federated identity credential limit. To configure this access method, [set up an identity binding](identity-bindings) between the UAMI and each AKS cluster.

Note

- This authentication method replaces Microsoft Entra pod-managed identity (preview). The open source Microsoft Entra pod-managed identity (preview) in Azure Kubernetes Service was deprecated as of October 24, 2022.
- Microsoft Entra Workload ID supports both Windows and Linux clusters.

### Configure workload identity

1. Set your subscription using the [`az account set`](/en-us/cli/azure/account#az-account-set) command.

    ```azurecli
    export SUBSCRIPTION_ID=<subscription id>
    export RESOURCE_GROUP=<resource group name>
    export UAMI=<name for user assigned identity>
    export KEYVAULT_NAME=<existing keyvault name>
    export CLUSTER_NAME=<aks cluster name>
    
    az account set --subscription $SUBSCRIPTION_ID
    ```
2. Create a managed identity using the [`az identity create`](/en-us/cli/azure/identity#az-identity-create) command.

    Note

    This step assumes you have an existing AKS cluster with workload identity enabled. If workload identity isn't enabled, see [Enable workload identity on an existing AKS cluster](workload-identity-deploy-cluster#enable-oidc-issuer-and-microsoft-entra-workload-id-on-an-aks-cluster) to enable it.

    ```azurecli
    az identity create --name $UAMI --resource-group $RESOURCE_GROUP
    
    export USER_ASSIGNED_CLIENT_ID="$(az identity show --resource-group $RESOURCE_GROUP --name $UAMI --query 'clientId' -o tsv)"
    export KEYVAULT_TENANT_ID="$(az keyvault show --name $KEYVAULT_NAME --query properties.tenantId -o tsv)"
    ```
3. Create a role assignment that grants the workload identity permission to access the key vault secrets, access keys, and certificates using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command.

    Important

    - If you set your key vault with `--enable-rbac-authorization` and you're using `key` or `cert` type, assign the [`Key Vault Certificate User`](/en-us/azure/key-vault/general/rbac-guide#azure-built-in-roles-for-key-vault-data-plane-operations) role to give permissions.
    - If your key vault is set with `--enable-rbac-authorization` and you're using `secret` type, assign the [`Key Vault Secrets User`](/en-us/azure/key-vault/general/rbac-guide#azure-built-in-roles-for-key-vault-data-plane-operations) role.
    - If your key vault isn't set with `--enable-rbac-authorization`, you can use the [`az keyvault set-policy`](/en-us/cli/azure/keyvault#az-keyvault-set-policy) command with the `--key-permissions get`, `--certificate-permissions get`, or `--secret-permissions get` parameter to create a key vault policy to grant access for keys, certificates, or secrets. For example:

    ```azurecli
    az keyvault set-policy --name $KEYVAULT_NAME --key-permissions get --secret-permissions get --object-id <identity-object-id>
    ```

    ```azurecli
    export KEYVAULT_SCOPE=$(az keyvault show --name $KEYVAULT_NAME --query id -o tsv)
    
    # Example commands for a key vault with Azure RBAC enabled using `key` and `secret` types
    az role assignment create --role "Key Vault Certificate User" --assignee $USER_ASSIGNED_CLIENT_ID --scope $KEYVAULT_SCOPE
    az role assignment create --role "Key Vault Secrets User" --assignee $USER_ASSIGNED_CLIENT_ID --scope $KEYVAULT_SCOPE
    ```
4. Get the AKS cluster OIDC Issuer URL using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    Note

    This step assumes you have an existing AKS cluster with the OIDC Issuer URL enabled. If the OIDC Issuer URL isn't enabled, see [Update an AKS cluster with OIDC Issuer](use-oidc-issuer#enable-oidc-issuer-on-an-existing-aks-standard-cluster) to enable it.

    ```bash
    export AKS_OIDC_ISSUER="$(az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --query "oidcIssuerProfile.issuerUrl" -o tsv)"
    echo $AKS_OIDC_ISSUER
    ```
5. Create a Kubernetes service account for the workload. Update the values for `SERVICE_ACCOUNT_NAME` and `SERVICE_ACCOUNT_NAMESPACE` with the Kubernetes service account name and its namespace.

    ```bash
    export SERVICE_ACCOUNT_NAME="workload-identity-sa"  # sample name; can be changed
    export SERVICE_ACCOUNT_NAMESPACE="default" # can be changed to namespace of your workload
    
    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      annotations:
        azure.workload.identity/client-id: ${USER_ASSIGNED_CLIENT_ID}
      name: ${SERVICE_ACCOUNT_NAME}
      namespace: ${SERVICE_ACCOUNT_NAMESPACE}
    EOF
    ```
6. Create the federated identity credential between the managed identity, service account issuer, and subject using the [`az identity federated-credential create`](/en-us/cli/azure/identity/federated-credential#az-identity-federated-credential-create) command.

    ```bash
    export FEDERATED_IDENTITY_NAME="aksfederatedidentity" # can be changed as needed
    
    az identity federated-credential create --name $FEDERATED_IDENTITY_NAME --identity-name $UAMI --resource-group $RESOURCE_GROUP --issuer ${AKS_OIDC_ISSUER} --subject system:serviceaccount:${SERVICE_ACCOUNT_NAMESPACE}:${SERVICE_ACCOUNT_NAME}
    ```
7. Deploy a `SecretProviderClass` using the `kubectl apply` command and the following YAML script.

    The following parameters configure workload identity access:

    - `usePodIdentity`: Set to `"false"` when using workload identity.
    - `clientID`: Set to `${USER_ASSIGNED_CLIENT_ID}`, the client ID of the user-assigned managed identity used for workload identity.
    - `cloudName`: Optional. Leave empty to use the default `AzurePublicCloud` environment.
    - `objectType`: Set to the type of Key Vault object to mount. Valid values are `secret`, `key`, and `cert`.
    - `tenantId`: Set to the tenant ID that contains the key vault.

    ```bash
    cat <<EOF | kubectl apply -f -
    # This is a SecretProviderClass example using workload identity to access your key vault
    apiVersion: secrets-store.csi.x-k8s.io/v1
    kind: SecretProviderClass
    metadata:
      name: azure-kvname-wi # needs to be unique per namespace
      namespace: ${SERVICE_ACCOUNT_NAMESPACE}
    spec:
      provider: azure
      parameters:
        usePodIdentity: "false"
        clientID: "${USER_ASSIGNED_CLIENT_ID}" # Setting this to use workload identity
        keyvaultName: ${KEYVAULT_NAME}       # Set to the name of your key vault
        cloudName: ""                         # [OPTIONAL for Azure] if not provided, the Azure environment defaults to AzurePublicCloud
        objects:  |
          array:
            - |
              objectName: secret1             # Set to the name of your secret
              objectType: secret              # object types: secret, key, or cert
              objectVersion: ""               # [OPTIONAL] object versions, default to latest if empty
            - |
              objectName: key1                # Set to the name of your key
              objectType: key
              objectVersion: ""
        tenantId: "${KEYVAULT_TENANT_ID}"     # The tenant ID of the key vault
    EOF
    ```

    Note

    If you use `objectAlias` instead of `objectName`, update the YAML script to account for it.

    Note

    In order for the `SecretProviderClass` to function properly, make sure to populate your Azure Key Vault with secrets, keys, or certificates before referencing them in the `objects` section.
8. Deploy a sample pod using the `kubectl apply` command and the following YAML script.

    ```bash
    cat <<EOF | kubectl apply -f -
    # This is a sample pod definition for using SecretProviderClass and workload identity to access your key vault
    kind: Pod
    apiVersion: v1
    metadata:
      name: busybox-secrets-store-inline-wi
      namespace: ${SERVICE_ACCOUNT_NAMESPACE}
      labels:
        azure.workload.identity/use: "true"
    spec:
      serviceAccountName: ${SERVICE_ACCOUNT_NAME}
      containers:
        - name: busybox
          image: registry.k8s.io/e2e-test-images/busybox:1.29-4
          command:
            - "/bin/sleep"
            - "10000"
          volumeMounts:
          - name: secrets-store01-inline
            mountPath: "/mnt/secrets-store"
            readOnly: true
      volumes:
        - name: secrets-store01-inline
          csi:
            driver: secrets-store.csi.k8s.io
            readOnly: true
            volumeAttributes:
              secretProviderClass: "azure-kvname-wi"
    EOF
    ```

## Validate Key Vault secrets with workload identity

After the pod starts, the mounted content at `/mnt/secrets-store` is available. Use the following commands to validate your secrets and print a test secret.

1. Show secrets held in the secrets store using the following command.

    ```bash
    kubectl exec --namespace $SERVICE_ACCOUNT_NAMESPACE busybox-secrets-store-inline-wi -- ls /mnt/secrets-store/
    ```
2. Display a secret in the store using the following command. This example command shows the test secret `secret1`.

    ```bash
    kubectl exec --namespace $SERVICE_ACCOUNT_NAMESPACE busybox-secrets-store-inline-wi -- cat /mnt/secrets-store/secret1
    ```

::: zone-end

::: zone pivot="access-with-a-user-assigned-managed-identity"

## Prerequisites for CSI Driver with managed identity

- Before you begin, make sure you finish the steps in [Use the Azure Key Vault provider for Secrets Store CSI Driver in an Azure Kubernetes Service (AKS) cluster](csi-secrets-store-driver) to enable the Azure Key Vault Secrets Store CSI Driver in your AKS cluster.

## Access with managed identity

This method uses the user-assigned managed identity that AKS automatically creates when you enable the Azure Key Vault provider for Secrets Store CSI Driver. The identity is named `azurekeyvaultsecretsprovider-xxxxx`, is stored in the node resource group, and is assigned to the virtual machine scale set.

A [Microsoft Entra managed identity](/en-us/entra/identity/managed-identities-azure-resources/overview) enables an Azure resource or workload to authenticate to services that support Microsoft Entra authentication without storing credentials in code. Grant this identity the appropriate Key Vault data-plane permissions through Azure RBAC or access policies, and then use it in the following steps.

Choose the tab that matches how you created your AKS cluster and key vault in [Use the Azure Key Vault provider for Secrets Store CSI Driver in an Azure Kubernetes Service (AKS) cluster](csi-secrets-store-driver). If you deployed the tested Terraform sample, it already grants the add-on identity the `Key Vault Secrets User` role, so skip the manual role assignment step.

# [Azure CLI](#tab/azure-cli)
#### Configure managed identity

1. Access your key vault using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command and the user-assigned managed identity created by the add-on. You should also retrieve the identity's `clientId`, which you use in later steps when creating a `SecretProviderClass`.

    ```azurecli
    export RESOURCE_GROUP=<resource-group>
    export CLUSTER_NAME=<cluster-name>
    export KEYVAULT_NAME=<key-vault-name>
    
    export IDENTITY_OBJECT_ID=$(az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --query addonProfiles.azureKeyvaultSecretsProvider.identity.objectId -o tsv)
    export USER_ASSIGNED_CLIENT_ID=$(az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId -o tsv)
    ```

    Alternatively, you can create a new managed identity and assign it to your virtual machine (VM) scale set or to each VM instance in your availability set.

    ```azurecli
    export USER_ASSIGNED_IDENTITY_NAME=<identity-name>
    
    az identity create --resource-group $RESOURCE_GROUP --name $USER_ASSIGNED_IDENTITY_NAME
    
    export IDENTITY_RESOURCE_ID=$(az identity show --resource-group $RESOURCE_GROUP --name $USER_ASSIGNED_IDENTITY_NAME --query id -o tsv)
    export IDENTITY_OBJECT_ID=$(az identity show --resource-group $RESOURCE_GROUP --name $USER_ASSIGNED_IDENTITY_NAME --query principalId -o tsv)
    export USER_ASSIGNED_CLIENT_ID=$(az identity show --resource-group $RESOURCE_GROUP --name $USER_ASSIGNED_IDENTITY_NAME --query clientId -o tsv)
    ```

    For a VM scale set-based cluster, assign the identity to the VM scale set.

    ```azurecli
    az vmss identity assign --resource-group <node-resource-group> --name <agent-pool-vmss> --identities $IDENTITY_RESOURCE_ID
    ```

    For an availability set-based cluster, assign the identity to each VM instance in the availability set.

    ```azurecli
    az vm identity assign --resource-group <node-resource-group> --name <agent-pool-vm> --identities $IDENTITY_RESOURCE_ID
    ```
2. Create a role assignment that grants the identity permission to access the key vault secrets, access keys, and certificates using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command.

    Important

    - If you set your key vault with `--enable-rbac-authorization` and you're using `key` or `cert` type, assign the [`Key Vault Certificate User`](/en-us/azure/key-vault/general/rbac-guide#azure-built-in-roles-for-key-vault-data-plane-operations) role.
    - If your key vault is set with `--enable-rbac-authorization` and you're using `secret` type, assign the [`Key Vault Secrets User`](/en-us/azure/key-vault/general/rbac-guide#azure-built-in-roles-for-key-vault-data-plane-operations) role.
    - If your key vault isn't set with `--enable-rbac-authorization`, you can use the [`az keyvault set-policy`](/en-us/cli/azure/keyvault#az-keyvault-set-policy) command with the `--key-permissions get`, `--certificate-permissions get`, or `--secret-permissions get` parameter to create a key vault policy to grant access for keys, certificates, or secrets. For example:

    ```azurecli
    az keyvault set-policy --name $KEYVAULT_NAME --key-permissions get --secret-permissions get --object-id $IDENTITY_OBJECT_ID
    ```

    ```azurecli
    export KEYVAULT_SCOPE=$(az keyvault show --name $KEYVAULT_NAME --query id -o tsv)
    
    # Example commands for a key vault with Azure RBAC enabled using `key` and `secret` types
    az role assignment create --role "Key Vault Certificate User" --assignee-object-id $IDENTITY_OBJECT_ID --assignee-principal-type ServicePrincipal --scope $KEYVAULT_SCOPE
    az role assignment create --role "Key Vault Secrets User" --assignee-object-id $IDENTITY_OBJECT_ID --assignee-principal-type ServicePrincipal --scope $KEYVAULT_SCOPE
    ```
3. Create a `SecretProviderClass` using the identity client ID. Make sure to use your own values for the objects to retrieve from your key vault.

    The following parameters configure user-assigned managed identity access:

    - `usePodIdentity`: Set to `"false"` when using managed identity.
    - `useVMManagedIdentity`: Set to `"true"` to enable managed identity mode.
    - `userAssignedIdentityID`: Set to the client ID of the user-assigned managed identity.
    - `tenantId`: Set to the tenant ID that contains the key vault.

    ```bash
    export KEYVAULT_TENANT_ID=$(az keyvault show --name $KEYVAULT_NAME --query properties.tenantId -o tsv)
    
    cat <<EOF > secretproviderclass.yaml
    # This is a SecretProviderClass example using user-assigned identity to access your key vault
    apiVersion: secrets-store.csi.x-k8s.io/v1
    kind: SecretProviderClass
    metadata:
      name: azure-kvname-user-msi
    spec:
      provider: azure
      parameters:
        usePodIdentity: "false"
        useVMManagedIdentity: "true"          # Set to true for using managed identity
        userAssignedIdentityID: ${USER_ASSIGNED_CLIENT_ID} # Set the client ID of the user-assigned managed identity to use
        keyvaultName: ${KEYVAULT_NAME}         # Set to the name of your key vault
        cloudName: ""                         # [OPTIONAL for Azure] if not provided, the Azure environment defaults to AzurePublicCloud
        objects:  |
          array:
            - |
              objectName: secret1
              objectType: secret              # object types: secret, key, or cert
              objectVersion: ""               # [OPTIONAL] object versions, default to latest if empty
            - |
              objectName: key1
              objectType: key
              objectVersion: ""
        tenantId: ${KEYVAULT_TENANT_ID}       # The tenant ID of the key vault
    EOF
    ```

    Note

    If you use `objectAlias` instead of `objectName`, make sure to update the YAML script.

    Note

    In order for the `SecretProviderClass` to function properly, make sure to populate your Azure Key Vault with secrets, keys, or certificates before referencing them in the `objects` section.
4. Apply the `SecretProviderClass` to your cluster using the `kubectl apply` command.

    ```bash
    kubectl apply -f secretproviderclass.yaml
    ```
5. Create a pod manifest named `pod.yaml` using the following command.

    ```bash
    cat <<EOF > pod.yaml
    # This is a sample pod definition for using SecretProviderClass and the user-assigned identity to access your key vault
    kind: Pod
    apiVersion: v1
    metadata:
      name: busybox-secrets-store-inline-user-msi
    spec:
      containers:
        - name: busybox
          image: registry.k8s.io/e2e-test-images/busybox:1.29-4
          command:
            - "/bin/sleep"
            - "10000"
          volumeMounts:
          - name: secrets-store01-inline
            mountPath: "/mnt/secrets-store"
            readOnly: true
      volumes:
        - name: secrets-store01-inline
          csi:
            driver: secrets-store.csi.k8s.io
            readOnly: true
            volumeAttributes:
              secretProviderClass: "azure-kvname-user-msi"
    EOF
    ```
6. Apply the pod to your cluster using the `kubectl apply` command.

    ```bash
    kubectl apply -f pod.yaml
    ```

#### Validate Key Vault secrets with managed identity

After the pod starts, the mounted content at `/mnt/secrets-store` is available. Use the following commands to validate your secrets and print a test secret.

1. Show secrets held in the secrets store using the following command.

    ```bash
    kubectl exec busybox-secrets-store-inline-user-msi -- ls /mnt/secrets-store/
    ```
2. Display a secret in the store using the following command. This example command shows the test secret `secret1`.

    ```bash
    kubectl exec busybox-secrets-store-inline-user-msi -- cat /mnt/secrets-store/secret1
    ```

# [Terraform](#tab/terraform)
#### Prerequisites

- Terraform 1.6 or later.
- Azure CLI, installed and signed in. [Install the latest version](/en-us/cli/azure/install-azure-cli).
- `kubectl`, connected to your cluster with the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

#### Configure managed identity

The tested Terraform sample creates the resource group, AKS cluster with the Azure Key Vault provider for Secrets Store CSI Driver enabled, Azure Key Vault, `ExampleSecret`, and a role assignment that grants the add-on's managed identity the `Key Vault Secrets User` role on the key vault. If you already deployed the sample from [Use the Azure Key Vault provider for Secrets Store CSI Driver in an Azure Kubernetes Service (AKS) cluster](csi-secrets-store-driver), reuse that working directory and skip ahead to setting the variables.

1. Create a `main.tf` file and copy the following tested sample configuration into it. The [Azure Terraform GitHub repository](https://github.com/Azure/terraform/tree/master/quickstart/101-aks-access-keyvault) maintains the sample.

    ```terraform
    terraform {
      required_version = ">= 1.5.0"
    
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~> 3.116"
        }
        random = {
          source  = "hashicorp/random"
          version = "~> 3.6"
        }
      }
    }
    
    provider "azurerm" {
      features {
        resource_group {
          prevent_deletion_if_contains_resources = false
        }
      }
    }
    
    data "azurerm_client_config" "current" {}
    
    resource "random_string" "suffix" {
      length  = 6
      upper   = false
      special = false
    }
    
    locals {
      location            = "eastus"
      resource_group_name = "rg-aks-kv-csi-demo-${random_string.suffix.result}"
      aks_name            = "aks-kv-csi-demo"
      key_vault_name      = "kvcsidemo${random_string.suffix.result}"
      secret_name         = "ExampleSecret"
    }
    
    resource "azurerm_resource_group" "this" {
      name     = local.resource_group_name
      location = local.location
    }
    
    resource "azurerm_log_analytics_workspace" "this" {
      name                = "law-aks-kv-csi-demo"
      location            = azurerm_resource_group.this.location
      resource_group_name = azurerm_resource_group.this.name
      sku                 = "PerGB2018"
      retention_in_days   = 30
    }
    
    resource "azurerm_kubernetes_cluster" "this" {
      name                      = local.aks_name
      location                  = azurerm_resource_group.this.location
      resource_group_name       = azurerm_resource_group.this.name
      dns_prefix                = "akskvcsidemo"
      kubernetes_version        = null
      oidc_issuer_enabled       = true
      workload_identity_enabled = true
    
      default_node_pool {
        name       = "system"
        node_count = 1
        vm_size    = "Standard_D2s_v3"
    
        upgrade_settings {
          drain_timeout_in_minutes      = 0
          max_surge                     = "10%"
          node_soak_duration_in_minutes = 0
        }
      }
    
      identity {
        type = "SystemAssigned"
      }
    
      key_vault_secrets_provider {
        secret_rotation_enabled = false
      }
    
      oms_agent {
        log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
      }
    
      network_profile {
        network_plugin    = "azure"
        load_balancer_sku = "standard"
      }
    
      tags = {
        scenario = "aks-keyvault-csi"
      }
    }
    
    resource "azurerm_key_vault" "this" {
      name                          = local.key_vault_name
      location                      = azurerm_resource_group.this.location
      resource_group_name           = azurerm_resource_group.this.name
      tenant_id                     = data.azurerm_client_config.current.tenant_id
      sku_name                      = "standard"
      purge_protection_enabled      = false
      soft_delete_retention_days    = 7
      enable_rbac_authorization     = true
      public_network_access_enabled = true
    }
    
    resource "azurerm_role_assignment" "current_user_kv_admin" {
      scope                = azurerm_key_vault.this.id
      role_definition_name = "Key Vault Administrator"
      principal_id         = data.azurerm_client_config.current.object_id
    }
    
    resource "azurerm_key_vault_secret" "example" {
      name         = local.secret_name
      value        = "HelloFromKeyVault"
      key_vault_id = azurerm_key_vault.this.id
    
      depends_on = [
        azurerm_role_assignment.current_user_kv_admin
      ]
    }
    
    resource "azurerm_role_assignment" "aks_csi_secrets_user" {
      scope                = azurerm_key_vault.this.id
      role_definition_name = "Key Vault Secrets User"
      # This is the managed identity automatically created by the AKS Key Vault CSI addon.
      principal_id = azurerm_kubernetes_cluster.this.key_vault_secrets_provider[0].secret_identity[0].object_id
    }
    
    output "resource_group_name" {
      value = azurerm_resource_group.this.name
    }
    
    output "aks_cluster_name" {
      value = azurerm_kubernetes_cluster.this.name
    }
    
    output "key_vault_name" {
      value = azurerm_key_vault.this.name
    }
    
    output "key_vault_secret_name" {
      value = azurerm_key_vault_secret.example.name
    }
    
    output "tenant_id" {
      value = data.azurerm_client_config.current.tenant_id
    }
    
    output "aks_csi_client_id" {
      value = azurerm_kubernetes_cluster.this.key_vault_secrets_provider[0].secret_identity[0].client_id
    }
    
    output "aks_csi_object_id" {
      value = azurerm_kubernetes_cluster.this.key_vault_secrets_provider[0].secret_identity[0].object_id
    }
    ```
2. Initialize, validate, and apply the configuration.

    ```bash
    terraform init
    terraform fmt
    terraform validate
    terraform plan
    terraform apply
    ```
3. Set the variables used in the remaining commands from the Terraform outputs.

    ```bash
    export RESOURCE_GROUP=$(terraform output -raw resource_group_name)
    export CLUSTER_NAME=$(terraform output -raw aks_cluster_name)
    export KEYVAULT_NAME=$(terraform output -raw key_vault_name)
    export KEYVAULT_SECRET_NAME=$(terraform output -raw key_vault_secret_name)
    export USER_ASSIGNED_CLIENT_ID=$(terraform output -raw aks_csi_client_id)
    export IDENTITY_OBJECT_ID=$(terraform output -raw aks_csi_object_id)
    export KEYVAULT_TENANT_ID=$(terraform output -raw tenant_id)
    ```

    Note

    The sample already creates the role assignment that grants `$IDENTITY_OBJECT_ID` the `Key Vault Secrets User` role on the key vault. Don't repeat the `az role assignment create` step from the Azure CLI tab for this identity and key vault—the sample already did it for you.
4. Create a `SecretProviderClass` using the identity client ID and secret name from the Terraform outputs.

    The following parameters configure user-assigned managed identity access:

    - `usePodIdentity`: Set to `"false"` when using managed identity.
    - `useVMManagedIdentity`: Set to `"true"` to enable managed identity mode.
    - `userAssignedIdentityID`: Set to the client ID of the user-assigned managed identity.
    - `tenantId`: Set to the tenant ID that contains the key vault.

    ```bash
    cat <<EOF > secretproviderclass.yaml
    # This is a SecretProviderClass example using the add-on's managed identity, created by the Terraform sample, to access your key vault
    apiVersion: secrets-store.csi.x-k8s.io/v1
    kind: SecretProviderClass
    metadata:
      name: azure-kvname-user-msi
    spec:
      provider: azure
      parameters:
        usePodIdentity: "false"
        useVMManagedIdentity: "true"          # Set to true for using managed identity
        userAssignedIdentityID: ${USER_ASSIGNED_CLIENT_ID} # Set to the client ID of the user-assigned managed identity to use
        keyvaultName: ${KEYVAULT_NAME}         # Set to the name of your key vault
        cloudName: ""                         # [OPTIONAL for Azure] if not provided, the Azure environment defaults to AzurePublicCloud
        objects:  |
          array:
            - |
              objectName: ${KEYVAULT_SECRET_NAME}
              objectType: secret              # object types: secret, key, or cert
              objectVersion: ""               # [OPTIONAL] object versions, default to latest if empty
        tenantId: ${KEYVAULT_TENANT_ID}       # The tenant ID of the key vault
    EOF
    ```

    Note

    The sample only creates a `secret` type object. For `key` or `cert` type coverage, see Obtain certificates and keys.
5. Apply the `SecretProviderClass` to your cluster by using the `kubectl apply` command.

    ```bash
    kubectl apply -f secretproviderclass.yaml
    ```
6. Create a pod manifest named `pod.yaml` by using the following command.

    ```bash
    cat <<EOF > pod.yaml
    # This is a sample pod definition for using SecretProviderClass and the user-assigned identity to access your key vault
    kind: Pod
    apiVersion: v1
    metadata:
      name: busybox-secrets-store-inline-user-msi
    spec:
      containers:
        - name: busybox
          image: registry.k8s.io/e2e-test-images/busybox:1.29-4
          command:
            - "/bin/sleep"
            - "10000"
          volumeMounts:
          - name: secrets-store01-inline
            mountPath: "/mnt/secrets-store"
            readOnly: true
      volumes:
        - name: secrets-store01-inline
          csi:
            driver: secrets-store.csi.k8s.io
            readOnly: true
            volumeAttributes:
              secretProviderClass: "azure-kvname-user-msi"
    EOF
    ```
7. Apply the pod to your cluster by using the `kubectl apply` command.

    ```bash
    kubectl apply -f pod.yaml
    ```

#### Validate Key Vault secrets with managed identity

After the pod starts, the mounted content at `/mnt/secrets-store` is available. Use the following commands to validate your secret.

1. Show secrets held in the secrets store by using the following command.

    ```bash
    kubectl exec busybox-secrets-store-inline-user-msi -- ls /mnt/secrets-store/
    ```
2. Display the secret in the store using the following command. `$KEYVAULT_SECRET_NAME` resolves to the sample's `ExampleSecret`.

    ```bash
    kubectl exec busybox-secrets-store-inline-user-msi -- cat /mnt/secrets-store/$KEYVAULT_SECRET_NAME
    ```

#### Clean up Terraform resources

If you deployed the sample only to complete this article and don't need the resources for anything else, remove them from the same working directory you used to apply the configuration.

Warning

Only run `terraform destroy` from the working directory used for this sample, and confirm the plan before you apply it. Avoid running `terraform destroy` against a configuration pointed at existing, shared, or imported infrastructure.

```bash
KUBE_CONTEXT=$(kubectl config current-context)
kubectl config delete-context $KUBE_CONTEXT
terraform destroy
```

---

::: zone-end

::: zone pivot="access-with-a-microsoft-entra-workload-identity,access-with-a-user-assigned-managed-identity"

## Obtain certificates and keys

The Azure Key Vault design makes sharp distinctions between keys, secrets, and certificates. The certificate features of the Key Vault service are designed to make use of key and secret capabilities. When you create a key vault certificate, it creates an addressable key and secret with the same name. This key allows authentication operations, and the secret allows the retrieval of the certificate value as a secret.

A key vault certificate also contains public x509 certificate metadata. The key vault stores both the public and private components of your certificate in a secret. You can obtain each individual component by specifying the `objectType` in `SecretProviderClass`. The following table shows the `objectType` values you can specify in `SecretProviderClass` to retrieve different components of a key vault certificate and what each value returns:

| `objectType`value | Return value | Returns entire certificate chain |
| --- | --- | --- |
| `key` | The public key, in Privacy Enhanced Mail (PEM) format. | N/A |
| `cert` | The certificate, in PEM format. | No |
| `secret` | The private key and certificate, in PEM format. | Yes |

## Disable the add-on on existing clusters

Note

Before you disable the add-on, ensure that *no*`SecretProviderClass` is in use. Trying to disable the add-on while a `SecretProviderClass` exists results in an error.

Disable the Azure Key Vault provider for Secrets Store CSI Driver capability in an existing cluster using the [`az aks disable-addons`](/en-us/cli/azure/aks#az-aks-disable-addons) command with the `azure-keyvault-secrets-provider` add-on.

```azurecli
az aks disable-addons --addons azure-keyvault-secrets-provider --resource-group myResourceGroup --name myAKSCluster
```

Note

When you disable the add-on, existing workloads should have no issues or see any updates in the mounted secrets. If the pod restarts or a new pod is created as part of scale-up event, the pod fails to start because the driver is no longer running.

::: zone-end