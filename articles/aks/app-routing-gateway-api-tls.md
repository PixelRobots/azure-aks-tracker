---
layout: Conceptual
title: Secure ingress traffic with the application routing Gateway API implementation - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/app-routing-gateway-api-tls
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
description: Secure ingress traffic with the application routing Gateway API implementation using AKV and the Secrets Store CSI Driver
ms.subservice: aks-networking
ms.custom: devx-track-azurecli, biannual
author: nshankar
ms.topic: how-to
ms.date: 2026-07-10T00:00:00.0000000Z
ms.author: nshankar
locale: en-us
document_id: 5570ea60-e4c3-000e-8b44-c29a149f4e45
document_version_independent_id: 62307dc1-b234-e348-0976-d8ee5701c0e9
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/app-routing-gateway-api-tls.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/app-routing-gateway-api-tls
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/app-routing-gateway-api-tls.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
platformId: 6a0efbc9-10a4-8a3b-d754-5720a80723be
---

# Secure ingress traffic with the application routing Gateway API implementation - Azure Kubernetes Service | Microsoft Learn

Note

This article describes how to **manually** configure TLS termination on a `Gateway` resource by authoring your own `SecretProviderClass`, mounting the Azure Key Vault provider for Secrets Store CSI Driver through a sample pod, and referencing the resulting Kubernetes Secret directly in the `Gateway` listener's `certificateRefs`. This approach is useful if you need full control over the certificate sync workflow or prefer to manage these resources yourself.

For most users, the recommended path is the **automated** Azure DNS and Azure Key Vault integration powered by the Application Routing operator, which provisions and reconciles the `SecretProviderClass`, the synced Kubernetes Secret, and the listener `certificateRefs` for you based on a pair of listener `tls.options`. To use the automated workflow, see [Configure Azure DNS and TLS with the application routing Gateway API implementation](app-routing-gateway-api-dns-tls).

The application routing add-on supports syncing secrets from Azure Key Vault (AKV) for securing Gateway API ingress traffic with TLS termination. Follow the steps below to create certificates and keys to terminate TLS traffic at the Gateway.

## Prerequisites

- Enable the [application routing Gateway API implementation](app-routing-gateway-api)
- Enable the [Managed Gateway API Installation](managed-gateway-api)
- Set environment variables: 

    ```bash
    export CLUSTER=<cluster-name>
    export RESOURCE_GROUP=<resource-group-name>
    export LOCATION=<location>
    ```

## Required client/server certificates and keys

1. Create a root certificate and private key for signing the certificates for sample services:

```bash
mkdir httpbin_certs
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=example Inc./CN=example.com' -keyout httpbin_certs/example.com.key -out httpbin_certs/example.com.crt
```

1. Generate a certificate and a private key for `httpbin.example.com`:

```bash
openssl req -out httpbin_certs/httpbin.example.com.csr -newkey rsa:2048 -nodes -keyout httpbin_certs/httpbin.example.com.key -subj "/CN=httpbin.example.com/O=httpbin organization"
openssl x509 -req -sha256 -days 365 -CA httpbin_certs/example.com.crt -CAkey httpbin_certs/example.com.key -set_serial 0 -in httpbin_certs/httpbin.example.com.csr -out httpbin_certs/httpbin.example.com.crt
```

## Configure a TLS ingress gateway

### Set up Azure Key Vault and sync secrets to the cluster

1. Create Azure Key Vault

    You need an [Azure Key Vault resource](/en-us/azure/key-vault/general/quick-create-cli) to supply the certificate and key inputs to the application routing add-on.

    ```bash
    export AKV_NAME=<azure-key-vault-resource-name>  
    az keyvault create --name $AKV_NAME --resource-group $RESOURCE_GROUP --location $LOCATION
    ```
2. Enable [Azure Key Vault provider for Secret Store CSI Driver](csi-secrets-store-driver) add-on on your cluster.

    ```bash
    az aks enable-addons --addons azure-keyvault-secrets-provider --resource-group $RESOURCE_GROUP --name $CLUSTER
    ```
3. If your Key Vault is using Azure RBAC for the permissions model, follow the instructions [here](/en-us/azure/key-vault/general/rbac-guide#using-azure-rbac-secret-key-and-certificate-permissions-with-key-vault) to assign an Azure role of Key Vault Secrets User for the add-on's user-assigned managed identity. Alternatively, if your key vault is using the vault access policy permissions model, authorize the user-assigned managed identity of the add-on to access Azure Key Vault resource using access policy:

    ```bash
    OBJECT_ID=$(az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER --query 'addonProfiles.azureKeyvaultSecretsProvider.identity.objectId' -o tsv | tr -d '\r')
    CLIENT_ID=$(az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER --query 'addonProfiles.azureKeyvaultSecretsProvider.identity.clientId')
    TENANT_ID=$(az keyvault show --resource-group $RESOURCE_GROUP --name $AKV_NAME --query 'properties.tenantId')
    
    az keyvault set-policy --name $AKV_NAME --object-id $OBJECT_ID --secret-permissions get list
    ```
4. Choose how to supply the TLS certificate.

    Azure Key Vault supports different object types. For this walkthrough, choose **one** of the following end-to-end options, and then continue with the common validation and Gateway steps.

    | Option | Use this option when | Key Vault stores | Kubernetes Secret result |
    | --- | --- | --- | --- |
    | **Option 1**: Store the certificate and key as Key Vault secrets | You have separate PEM certificate (`.crt`) and private key (`.key`) files, such as the files generated earlier in this article. | Two Key Vault secrets. | One synced Kubernetes TLS secret named `httpbin-credential`. |
    | **Option 2**: Reference a Key Vault certificate object directly | Your certificate is already stored in Key Vault as a certificate object, such as an imported `.pfx`. | One Key Vault certificate object. | One synced Kubernetes TLS secret named `httpbin-credential`. |

    Important

    Don't follow both options. If you use Option 1, upload the certificate and key files as Key Vault secrets, and then apply the Option 1 `SecretProviderClass` manifest. If you use Option 2, skip the Key Vault secret upload step and apply the Option 2 `SecretProviderClass` manifest.

#### Option 1: Store the certificate and key as Key Vault secrets

Use this option when you have separate PEM certificate (`.crt`) and private key (`.key`) files, such as the files generated earlier in this article.

1. Upload the certificate and key files as Key Vault secrets:

    ```bash
    az keyvault secret set --vault-name $AKV_NAME --name test-httpbin-key --file httpbin_certs/httpbin.example.com.key
    az keyvault secret set --vault-name $AKV_NAME --name test-httpbin-crt --file httpbin_certs/httpbin.example.com.crt
    ```

    Note

    Each time you rotate (change) the certificate or key, re-run this step to upload the new versions as secrets. To sync the updated values into the cluster automatically, enable autorotation on the Azure Key Vault provider for Secrets Store CSI Driver. For more information, see [Autorotation and secret sync overview](csi-secrets-store-configuration-options#autorotation-and-secret-sync-overview). If you prefer to have Key Vault manage the certificate lifecycle, use **Option 2** instead.
2. Create the `SecretProviderClass` that references the two secrets you created in Key Vault:

    ```bash
    cat <<EOF | kubectl apply -f -
    apiVersion: secrets-store.csi.x-k8s.io/v1
    kind: SecretProviderClass
    metadata:
      name: httpbin-credential-spc
    spec:
      provider: azure
      secretObjects:
      - secretName: httpbin-credential
        type: kubernetes.io/tls
        data:
        - objectName: test-httpbin-key
          key: tls.key
        - objectName: test-httpbin-crt
          key: tls.crt
      parameters:
        useVMManagedIdentity: "true"
        userAssignedIdentityID: $CLIENT_ID 
        keyvaultName: $AKV_NAME
        cloudName: ""
        objects:  |
          array:
            - |
              objectName: test-httpbin-key
              objectType: secret
              objectAlias: "test-httpbin-key"
            - |
              objectName: test-httpbin-crt
              objectType: secret
              objectAlias: "test-httpbin-crt"
        tenantId: $TENANT_ID
    EOF
    ```

#### Option 2: Reference a Key Vault certificate object directly

Use this option when the certificate is already stored in Azure Key Vault as a certificate object. You don't need to upload the `.crt` and `.key` files as separate Key Vault secrets.

In this example, `test-httpbin-cert-pfx` is the name of the certificate object in Azure Key Vault. To import an existing certificate into Key Vault as a certificate object, see [Import a certificate into Key Vault](/en-us/azure/key-vault/certificates/tutorial-import-certificate). For more information about the object parameters, see [obtain certificates and keys](csi-secrets-store-identity-access).

1. Create the `SecretProviderClass` that references the Key Vault certificate object:

    ```bash
    cat <<EOF | kubectl apply -f -
    apiVersion: secrets-store.csi.x-k8s.io/v1
    kind: SecretProviderClass
    metadata:
      name: httpbin-credential-spc
    spec:
      provider: azure
      secretObjects:
      - secretName: httpbin-credential
        type: kubernetes.io/tls
        data:
        - objectName: test-httpbin-key
          key: tls.key
        - objectName: test-httpbin-crt
          key: tls.crt
      parameters:
        useVMManagedIdentity: "true"
        userAssignedIdentityID: $CLIENT_ID 
        keyvaultName: $AKV_NAME
        cloudName: ""
        objects:  |
          array:
            - |
              objectName: test-httpbin-cert-pfx  #certificate object name from keyvault
              objectType: secret
              objectAlias: "test-httpbin-key"
            - |
              objectName: test-httpbin-cert-pfx #certificate object name from keyvault
              objectType: cert
              objectAlias: "test-httpbin-crt"
        tenantId: $TENANT_ID
    EOF
    ```

#### Sync the secret to the cluster

After you complete either Option 1 or Option 2, deploy a sample pod to sync the secret into the cluster. The Secrets Store CSI Driver requires a pod to reference the `SecretProviderClass` resource so that secrets sync from Azure Key Vault to the cluster.

1. Use the following manifest to deploy a sample pod:

    ```bash
    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: Pod
    metadata:
      name: secrets-store-sync-httpbin
    spec:
      containers:
        - name: busybox
          image: mcr.microsoft.com/oss/busybox/busybox:1.33.1
          command:
            - "/bin/sleep"
            - "10"
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
              secretProviderClass: "httpbin-credential-spc"
    EOF
    ```

    - Verify that the `httpbin-credential` secret is created in the `default` namespace as defined in the SecretProviderClass resource.

        ```bash
        kubectl describe secret/httpbin-credential
        ```

        Example output:

        ```output
        Name:         httpbin-credential
        Namespace:    default
        Labels:       secrets-store.csi.k8s.io/managed=true
        Annotations:  <none>
        
        Type:  kubernetes.io/tls
        
        Data
        ====
        tls.crt:  1180 bytes
        tls.key:  1675 bytes
        ```

### Deploy TLS Gateway

1. Create a Kubernetes Gateway that references the `httpbin-credential` secret under the TLS configuration:

    ```bash
    cat <<EOF | kubectl apply -f -
    apiVersion: gateway.networking.k8s.io/v1
    kind: Gateway
    metadata:
      name: httpbin-gateway
    spec:
      gatewayClassName: approuting-istio
      listeners:
      - name: https
        hostname: "httpbin.example.com"
        port: 443
        protocol: HTTPS
        tls:
          mode: Terminate
          certificateRefs:
          - name: httpbin-credential
        allowedRoutes:
          namespaces:
            from: Selector
            selector:
              matchLabels:
                kubernetes.io/metadata.name: default
    EOF
    ```

    Then, create a corresponding `HTTPRoute` to configure the gateway's ingress traffic routes:

    ```bash
    cat <<EOF | kubectl apply -f -
    apiVersion: gateway.networking.k8s.io/v1
    kind: HTTPRoute
    metadata:
      name: httpbin
    spec:
      parentRefs:
      - name: httpbin-gateway
      hostnames: ["httpbin.example.com"]
      rules:
      - matches:
        - path:
            type: PathPrefix
            value: /status
        - path:
            type: PathPrefix
            value: /delay
        backendRefs:
        - name: httpbin
          port: 8000
    EOF
    ```

    Get the gateway address and port:

    ```bash
    kubectl wait --for=condition=programmed gateways.gateway.networking.k8s.io httpbin-gateway
    export INGRESS_HOST=$(kubectl get gateways.gateway.networking.k8s.io httpbin-gateway -o jsonpath='{.status.addresses[0].value}')
    export SECURE_INGRESS_PORT=$(kubectl get gateways.gateway.networking.k8s.io httpbin-gateway -o jsonpath='{.spec.listeners[?(@.name=="https")].port}')
    ```
2. Send an HTTPS request to access the `httpbin` service:

    ```bash
    curl -v -HHost:httpbin.example.com --resolve "httpbin.example.com:$SECURE_INGRESS_PORT:$INGRESS_HOST" \
    --cacert httpbin_certs/example.com.crt "https://httpbin.example.com:$SECURE_INGRESS_PORT/status/418"
    ```

    You should see the httpbin service return the 418 I’m a Teapot code.