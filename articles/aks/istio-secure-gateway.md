---
layout: Conceptual
title: Secure ingress gateway for Istio service mesh add-on for Azure Kubernetes Service - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/istio-secure-gateway
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
description: Deploy secure ingress gateway for Istio service mesh add-on for Azure Kubernetes Service.
ms.topic: how-to
ms.custom: devx-track-azurecli
author: deveshdama
ms.date: 2024-04-30T00:00:00.0000000Z
ms.author: ddama
locale: en-us
document_id: 80c1a593-41b6-af09-a9d6-6e53d6ce1480
document_version_independent_id: 71845395-d208-2c49-ac6d-8376713f2607
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/istio-secure-gateway.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/istio-secure-gateway
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/istio-secure-gateway.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 1743ed91-94b3-3f27-84da-fdbaaa397f8e
---

# Secure ingress gateway for Istio service mesh add-on for Azure Kubernetes Service - Azure Kubernetes Service | Microsoft Learn

The [Deploy external or internal Istio Ingress](istio-deploy-ingress) article describes how to configure an ingress gateway to expose an HTTP service to external/internal traffic. This article shows how to expose a secure HTTPS service using either simple or mutual TLS.

## Prerequisites

- Enable the Istio add-on on the cluster as per [documentation](istio-deploy-addon)

    - [Set environment variables](istio-deploy-addon#set-environment-variables)
    - [Install Istio add-on](istio-deploy-addon#install-mesh-for-existing-cluster)
    - [Enable sidecar injection](istio-deploy-addon#enable-sidecar-injection)
    - [Deploy sample application](istio-deploy-addon#deploy-sample-application)
- Deploy an external Istio ingress gateway as per [documentation](istio-deploy-ingress)

    - [Enable external ingress gateway](istio-deploy-ingress#enable-external-ingress-gateway)

Note

This article refers to the external ingress gateway for demonstration, same steps would apply for configuring mutual TLS for internal ingress gateway.

## Required client/server certificates and keys

This article requires several certificates and keys. You can use your favorite tool to create them or you can use the following [openssl](https://man.openbsd.org/openssl.1) commands.

1. Create a root certificate and private key for signing the certificates for sample services:

    ```bash
    mkdir bookinfo_certs
    openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=bookinfo Inc./CN=bookinfo.com' -keyout bookinfo_certs/bookinfo.com.key -out bookinfo_certs/bookinfo.com.crt
    ```
2. Generate a certificate and private key for `productpage.bookinfo.com`:

    ```bash
    openssl req -out bookinfo_certs/productpage.bookinfo.com.csr -newkey rsa:2048 -nodes -keyout bookinfo_certs/productpage.bookinfo.com.key -subj "/CN=productpage.bookinfo.com/O=product organization"
    openssl x509 -req -sha256 -days 365 -CA bookinfo_certs/bookinfo.com.crt -CAkey bookinfo_certs/bookinfo.com.key -set_serial 0 -in bookinfo_certs/productpage.bookinfo.com.csr -out bookinfo_certs/productpage.bookinfo.com.crt
    ```
3. Generate a client certificate and private key:

    ```bash
    openssl req -out bookinfo_certs/client.bookinfo.com.csr -newkey rsa:2048 -nodes -keyout bookinfo_certs/client.bookinfo.com.key -subj "/CN=client.bookinfo.com/O=client organization"
    openssl x509 -req -sha256 -days 365 -CA bookinfo_certs/bookinfo.com.crt -CAkey bookinfo_certs/bookinfo.com.key -set_serial 1 -in bookinfo_certs/client.bookinfo.com.csr -out bookinfo_certs/client.bookinfo.com.crt
    ```

## Configure a TLS ingress gateway

Create a Kubernetes TLS secret for the ingress gateway; use [Azure Key Vault](/en-us/azure/key-vault/general/basic-concepts) to host certificates/keys and [Azure Key Vault Secrets Provider add-on](csi-secrets-store-driver) to sync secrets to the cluster.

### Set up Azure Key Vault and sync secrets to the cluster

1. Create Azure Key Vault

    You need an [Azure Key Vault resource](/en-us/azure/key-vault/general/quick-create-cli) to supply the certificate and key inputs to the Istio add-on.

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
4. Create secrets in Azure Key Vault using the certificates and keys.

    ```bash
    az keyvault secret set --vault-name $AKV_NAME --name test-productpage-bookinfo-key --file bookinfo_certs/productpage.bookinfo.com.key
    az keyvault secret set --vault-name $AKV_NAME --name test-productpage-bookinfo-crt --file bookinfo_certs/productpage.bookinfo.com.crt
    az keyvault secret set --vault-name $AKV_NAME --name test-bookinfo-crt --file bookinfo_certs/bookinfo.com.crt
    ```
5. Use the following manifest to deploy SecretProviderClass to provide Azure Key Vault specific parameters to the CSI driver.

    ```bash
    cat <<EOF | kubectl apply -f -
    apiVersion: secrets-store.csi.x-k8s.io/v1
    kind: SecretProviderClass
    metadata:
      name: productpage-credential-spc
      namespace: aks-istio-ingress
    spec:
      provider: azure
      secretObjects:
      - secretName: productpage-credential
        type: kubernetes.io/tls
        data:
        - objectName: test-productpage-bookinfo-key
          key: tls.key
        - objectName: test-productpage-bookinfo-crt
          key: tls.crt
      parameters:
        useVMManagedIdentity: "true"
        userAssignedIdentityID: $CLIENT_ID 
        keyvaultName: $AKV_NAME
        cloudName: ""
        objects:  |
          array:
            - |
              objectName: test-productpage-bookinfo-key
              objectType: secret
              objectAlias: "test-productpage-bookinfo-key"
            - |
              objectName: test-productpage-bookinfo-crt
              objectType: secret
              objectAlias: "test-productpage-bookinfo-crt"
        tenantId: $TENANT_ID
    EOF
    ```

    Alternatively, to reference a certificate object type directly from Azure Key Vault, use the following manifest to deploy SecretProviderClass. In this example, `test-productpage-bookinfo-cert-pxf` is the name of the certificate object in Azure Key Vault. Refer to [obtain certificates and keys](csi-secrets-store-identity-access?pivots=access-with-a-user-assigned-managed-identity#obtain-certificates-and-keys) section for more information.

    ```bash
    cat <<EOF | kubectl apply -f -
    apiVersion: secrets-store.csi.x-k8s.io/v1
    kind: SecretProviderClass
    metadata:
      name: productpage-credential-spc
      namespace: aks-istio-ingress
    spec:
      provider: azure
      secretObjects:
      - secretName: productpage-credential
        type: kubernetes.io/tls
        data:
        - objectName: test-productpage-bookinfo-key
          key: tls.key
        - objectName: test-productpage-bookinfo-crt
          key: tls.crt
      parameters:
        useVMManagedIdentity: "true"
        userAssignedIdentityID: $CLIENT_ID 
        keyvaultName: $AKV_NAME
        cloudName: ""
        objects:  |
          array:
            - |
              objectName: test-productpage-bookinfo-cert-pfx  #certificate object name from keyvault
              objectType: secret
              objectAlias: "test-productpage-bookinfo-key"
            - |
              objectName: test-productpage-bookinfo-cert-pfx #certificate object name from keyvault
              objectType: cert
              objectAlias: "test-productpage-bookinfo-crt"
        tenantId: $TENANT_ID
    EOF
    ```
6. Use the following manifest to deploy a sample pod. The secret store CSI driver requires a pod to reference the SecretProviderClass resource to ensure secrets sync from Azure Key Vault to the cluster.

    ```bash
    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: Pod
    metadata:
      name: secrets-store-sync-productpage
      namespace: aks-istio-ingress
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
              secretProviderClass: "productpage-credential-spc"
    EOF
    ```

    - Verify `productpage-credential` secret created on the cluster namespace `aks-istio-ingress` as defined in the SecretProviderClass resource.

        ```bash
        kubectl describe secret/productpage-credential -n aks-istio-ingress
        ```

        Example output:

        ```bash
        Name:         productpage-credential
        Namespace:    aks-istio-ingress
        Labels:       secrets-store.csi.k8s.io/managed=true
        Annotations:  <none>
        
        Type:  tls
        
        Data
        ====
        cert:  1066 bytes
        key:   1704 bytes
        ```

### Configure ingress gateway and virtual service

Route HTTPS traffic via the Istio ingress gateway to the sample applications. Use the following manifest to deploy gateway and virtual service resources.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: bookinfo-gateway
spec:
  selector:
    istio: aks-istio-ingressgateway-external
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: productpage-credential
    hosts:
    - productpage.bookinfo.com
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: productpage-vs
spec:
  hosts:
  - productpage.bookinfo.com
  gateways:
  - bookinfo-gateway
  http:
  - match:
    - uri:
        exact: /productpage
    - uri:
        prefix: /static
    - uri:
        exact: /login
    - uri:
        exact: /logout
    - uri:
        prefix: /api/v1/products
    route:
    - destination:
        port:
          number: 9080
        host: productpage
EOF
```

Note

In the gateway definition, `credentialName` must match the `secretName` in SecretProviderClass resource and `selector` must refer to the external ingress gateway by its label, in which the key of the label is `istio` and the value is `aks-istio-ingressgateway-external`. For internal ingress gateway label is `istio` and the value is `aks-istio-ingressgateway-internal`.

Set environment variables for external ingress host and ports:

```bash
export INGRESS_HOST_EXTERNAL=$(kubectl -n aks-istio-ingress get service aks-istio-ingressgateway-external -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export SECURE_INGRESS_PORT_EXTERNAL=$(kubectl -n aks-istio-ingress get service aks-istio-ingressgateway-external -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
export SECURE_GATEWAY_URL_EXTERNAL=$INGRESS_HOST_EXTERNAL:$SECURE_INGRESS_PORT_EXTERNAL

echo "https://$SECURE_GATEWAY_URL_EXTERNAL/productpage"
```

### Verification

Send an HTTPS request to access the productpage service through HTTPS:

```bash
curl -s -HHost:productpage.bookinfo.com --resolve "productpage.bookinfo.com:$SECURE_INGRESS_PORT_EXTERNAL:$INGRESS_HOST_EXTERNAL" --cacert bookinfo_certs/bookinfo.com.crt "https://productpage.bookinfo.com:$SECURE_INGRESS_PORT_EXTERNAL/productpage" | grep -o "<title>.*</title>"
```

Confirm that the sample application's product page is accessible. The expected output is:

```html
<title>Simple Bookstore App</title>
```

Note

To configure HTTPS ingress access to an HTTPS service, i.e., configure an ingress gateway to perform SNI passthrough instead of TLS termination on incoming requests, update the tls mode in the gateway definition to `PASSTHROUGH`. This instructs the gateway to pass the ingress traffic “as is”, without terminating TLS.

## Configure a mutual TLS ingress gateway

Extend your gateway definition to support mutual TLS.

1. Update the ingress gateway credential by deleting the current secret and creating a new one. The server uses the CA certificate to verify its clients, and we must use the key ca.crt to hold the CA certificate.

    ```bash
    kubectl delete secretproviderclass productpage-credential-spc -n aks-istio-ingress
    kubectl delete secret/productpage-credential -n aks-istio-ingress
    kubectl delete pod/secrets-store-sync-productpage -n aks-istio-ingress
    ```

    Use the following manifest to recreate SecretProviderClass with CA certificate.

    ```bash
    cat <<EOF | kubectl apply -f -
    apiVersion: secrets-store.csi.x-k8s.io/v1
    kind: SecretProviderClass
    metadata:
      name: productpage-credential-spc
      namespace: aks-istio-ingress
    spec:
      provider: azure
      secretObjects:
      - secretName: productpage-credential
        type: opaque
        data:
        - objectName: test-productpage-bookinfo-key
          key: tls.key
        - objectName: test-productpage-bookinfo-crt
          key: tls.crt
        - objectName: test-bookinfo-crt
          key: ca.crt
      parameters:
        useVMManagedIdentity: "true"
        userAssignedIdentityID: $CLIENT_ID 
        keyvaultName: $AKV_NAME
        cloudName: ""
        objects:  |
          array:
            - |
              objectName: test-productpage-bookinfo-key
              objectType: secret
              objectAlias: "test-productpage-bookinfo-key"
            - |
              objectName: test-productpage-bookinfo-crt
              objectType: secret
              objectAlias: "test-productpage-bookinfo-crt"
            - |
              objectName: test-bookinfo-crt
              objectType: secret
              objectAlias: "test-bookinfo-crt"
        tenantId: $TENANT_ID
    EOF
    ```

    Use the following manifest to redeploy sample pod to sync secrets from Azure Key Vault to the cluster.

    ```bash
    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: Pod
    metadata:
      name: secrets-store-sync-productpage
      namespace: aks-istio-ingress
    spec:
      containers:
        - name: busybox
          image: registry.k8s.io/e2e-test-images/busybox:1.29-4
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
              secretProviderClass: "productpage-credential-spc"
    EOF
    ```

    - Verify `productpage-credential` secret created on the cluster namespace `aks-istio-ingress`.

        ```bash
        kubectl describe secret/productpage-credential -n aks-istio-ingress
        ```

        Example output:

        ```bash
        Name:         productpage-credential
        Namespace:    aks-istio-ingress
        Labels:       secrets-store.csi.k8s.io/managed=true
        Annotations:  <none>
        
        Type:  opaque
        
        Data
        ====
        ca.crt:   1188 bytes
        tls.crt:  1066 bytes
        tls.key:  1704 bytes
        ```
2. Use the following manifest to update the gateway definition to set the TLS mode to MUTUAL.

    ```bash
    cat <<EOF | kubectl apply -f -
    apiVersion: networking.istio.io/v1beta1
    kind: Gateway
    metadata:
      name: bookinfo-gateway
    spec:
      selector:
        istio: aks-istio-ingressgateway-external # use istio default ingress gateway
      servers:
      - port:
          number: 443
          name: https
          protocol: HTTPS
        tls:
          mode: MUTUAL
          credentialName: productpage-credential # must be the same as secret
        hosts:
        - productpage.bookinfo.com
    EOF
    ```

### Verification

Attempt to send HTTPS request using the prior approach - without passing the client certificate - and see it fail.

```bash
curl -v -HHost:productpage.bookinfo.com --resolve "productpage.bookinfo.com:$SECURE_INGRESS_PORT_EXTERNAL:$INGRESS_HOST_EXTERNAL" --cacert bookinfo_certs/bookinfo.com.crt "https://productpage.bookinfo.com:$SECURE_INGRESS_PORT_EXTERNAL/productpage" 
```

Example output:

```bash

...
* TLSv1.2 (IN), TLS header, Supplemental data (23):
* TLSv1.3 (IN), TLS alert, unknown (628):
* OpenSSL SSL_read: error:0A00045C:SSL routines::tlsv13 alert certificate required, errno 0
* Failed receiving HTTP2 data
* OpenSSL SSL_write: SSL_ERROR_ZERO_RETURN, errno 0
* Failed sending HTTP2 data
* Connection #0 to host productpage.bookinfo.com left intact
curl: (56) OpenSSL SSL_read: error:0A00045C:SSL routines::tlsv13 alert certificate required, errno 0
```

Pass your client’s certificate with the `--cert` flag and private key with the `--key` flag to curl.

```bash
curl -s -HHost:productpage.bookinfo.com --resolve "productpage.bookinfo.com:$SECURE_INGRESS_PORT_EXTERNAL:$INGRESS_HOST_EXTERNAL" --cacert bookinfo_certs/bookinfo.com.crt --cert bookinfo_certs/client.bookinfo.com.crt --key bookinfo_certs/client.bookinfo.com.key "https://productpage.bookinfo.com:$SECURE_INGRESS_PORT_EXTERNAL/productpage" | grep -o "<title>.*</title>"
```

Confirm that the sample application's product page is accessible. The expected output is:

```html
<title>Simple Bookstore App</title>
```

## Delete resources

If you want to clean up the Istio service mesh and the ingresses (leaving behind the cluster), run the following command:

```azurecli
az aks mesh disable --resource-group ${RESOURCE_GROUP} --name ${CLUSTER}
```

If you want to clean up all the resources created from the Istio how-to guidance documents, run the following command:

```azurecli
az group delete --name ${RESOURCE_GROUP} --yes --no-wait
```