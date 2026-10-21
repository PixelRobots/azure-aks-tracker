---
layout: Conceptual
title: Secure Deployment Options for the Connected Registry Extension - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/tutorial-connected-registry-arc
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/62/azure-container-registry/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/180a533d-0d25-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: KumudD
learn_banner_products:
- azure
manager: kumud
ms.reviewer: kumud
ms.author: kumud
ms.service: azure-container-registry
description: Learn to secure the connected registry Arc extension deployment with HTTPS, TLS, optional no TLS, BYOC certificate, and trust distribution.
ms.topic: how-to
ms.date: 2025-05-20T00:00:00.0000000Z
ms.custom: sfi-ropc-nochange
locale: en-us
document_id: c7a6aec5-5146-80b0-892d-2c6e3b1f1247
document_version_independent_id: a8530e80-8f48-1406-88a0-acb5e442accc
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/tutorial-connected-registry-arc.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/tutorial-connected-registry-arc
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/tutorial-connected-registry-arc.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/a3955c7b-f5ee-420d-aff5-d7119738f38b
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/b31948f4-2f38-404b-ac93-c3c8c5b3ae33
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
platformId: 9c17fbea-6ca2-9e3b-17f2-97a3ae000f2f
---

# Secure Deployment Options for the Connected Registry Extension - Azure Container Registry | Microsoft Learn

This article describes various deployment scenarios for the connected registry extension in an Arc-enabled Kubernetes cluster. After you install the connected registry extension, you can synchronize images from your cloud registry to on-premises or remote locations.

Before you dive in, take a moment to learn how [Arc-enabled Kubernetes](/en-us/azure/azure-arc/kubernetes/overview) works conceptually.

You can securely deploy the connected registry by using various encryption methods. To ensure a successful deployment, follow the quickstart guide to review prerequisites and other pertinent information. By default, the connected registry is configured with HTTPS, ReadOnly mode, Trust Distribution, and the Cert Manager service. You can add more customizations and dependencies as needed, depending on your scenario.

### What is Cert Manager service?

The connected registry cert manager is a service that manages TLS certificates for the connected registry extension in an Azure Arc-enabled Kubernetes cluster. It ensures secure communication between the connected registry and other components by handling the creation, renewal, and distribution of certificates. You can install this service as part of the connected registry deployment, or you can use an existing cert manager if it's already installed on your cluster.

[Cert-Manager](https://cert-manager.io/) is an open-source Kubernetes add-on that automates the management and issuance of TLS certificates from various sources. It manages the lifecycle of certificates issued by CA pools created using CA Service, ensuring they are valid and renewed before they expire.

### What is trust distribution?

Connected registry trust distribution refers to the process of securely distributing trust between the connected registry service and Kubernetes clients within a cluster. By using a Certificate Authority (CA), such as cert-manager, to sign TLS certificates, you can distribute these certificates to both the registry service and the clients. This process ensures that all entities can securely authenticate each other, maintaining a secure and trusted environment within the Kubernetes cluster.

## Deploy connected registry extension by using your preinstalled cert-manager

When you use a preinstalled cert-manager service on the cluster, you have control over certificate management. Deploy the connected registry extension with encryption by following the steps provided:

Run the [az-k8s-extension-create](/en-us/cli/azure/k8s-extension#az-k8s-extension-create) command in the [quickstart](quickstart-connected-registry-arc-cli) and set the `cert-manager.enabled=true` and `cert-manager.install=false` parameters to indicate the cert-manager service is installed and enabled:

```azurecli
    az k8s-extension create --cluster-name myarck8scluster \ 
    --cluster-type connectedClusters \ 
    --extension-type Microsoft.ContainerRegistry.ConnectedRegistry \ 
    --name myconnectedregistry \ 
    --resource-group myresourcegroup \ 
    --config service.clusterIP=192.100.100.1 \ 
    --config cert-manager.install=false \ 
    --config-protected-file protected-settings-extension.json
```

## Deploy connected registry extension using bring your own certificate (BYOC)

Bring your own certificate (BYOC) allows you to use your own public certificate and private key pair, giving you control over certificate management. This setup enables you to deploy the connected registry extension with encryption.

Note

BYOC is useful for customers who bring their own certificate that is already trusted by their Kubernetes nodes. Don't manually update nodes to trust certificates.

Add the public certificate and private key string variable and value pair when deploying the extension by following these steps:

1. Create self-signed SSL cert with connected-registry service IP as the SAN:

    ```bash
    mkdir /certs
    ```

    ```bash
    openssl req -newkey rsa:4096 -nodes -sha256 -keyout /certs/mycert.key -x509 -days 365 -out /certs/mycert.crt -addext   "subjectAltName = IP:<service IP>"
    ```
2. Get base64 encoded strings of these cert files:

    ```bash
    export TLS_CRT=$(cat mycert.crt | base64 -w0) 
    export TLS_KEY=$(cat mycert.key | base64 -w0) 
    ```
3. Create a protected settings file with secret in JSON format, similar to the following example:

    Note

    The public certificate and private key pair must be encoded in base64 format and added to the protected settings file.

    ```json
    {
    "connectionString": "[connection string here]",
    "tls.crt": $TLS_CRT,
    "tls.key": $TLS_KEY,
    "tls.cacrt": $TLS_CRT
    } 
    ```
4. Deploy the Connected registry extension with HTTPS (TLS encryption) using the public certificate and private key pair management by configuring variables set to `cert-manager.enabled=false` and `cert-manager.install=false`. By using these parameters, the cert-manager isn't installed or enabled, since the public certificate and private key pair is used instead for encryption.
5. Run the [az-k8s-extension-create](/en-us/cli/azure/k8s-extension#az-k8s-extension-create) command for deployment after editing the protected settings file:

    ```azurecli
    az k8s-extension create --cluster-name myarck8scluster \
    --cluster-type connectedClusters \  
    --extension-type  Microsoft.ContainerRegistry.ConnectedRegistry \ 
    --name myconnectedregistry \ 
    --resource-group myresourcegroup \
    --config service.clusterIP=192.100.100.1 \
    --config cert-manager.enabled=false \
    --config cert-manager.install=false \ 
    --config-protected-file protected-settings-extension.json 
    ```

## Deploy connected registry with Kubernetes secret management

By using a [Kubernetes secret](https://kubernetes.io/docs/concepts/configuration/secret/) on your cluster, you can securely manage authorized access between pods within the cluster. This setup enables you to deploy the connected registry extension with encryption.

Add the Kubernetes TLS secret string variable and value pair by following these steps:

1. Create self-signed SSL cert with connected-registry service IP as the SAN

    ```bash
    mkdir /certs
    ```

    ```bash
    openssl req -newkey rsa:4096 -nodes -sha256 -keyout /certs/mycert.key -x509 -days 365 -out /certs/mycert.crt -addext    "subjectAltName = IP:<service IP>"
    ```
2. Get base64-encoded strings of these cert files:

    ```bash
    export TLS_CRT=$(cat mycert.crt | base64 -w0) 
    export TLS_KEY=$(cat mycert.key | base64 -w0) 
    ```
3. Create the Kubernetes secret:

    ```bash
    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: Secret
    metadata:
      name: k8secret
      type: kubernetes.io/tls
    data:
      ca.crt: $TLS_CRT
      tls.crt: $TLS_CRT
      tls.key: $TLS_KEY
    EOF
    ```
4. Create a protected settings file with secret in JSON format, similar to the following example:

    ```json
        { 
        "connectionString": "[connection string here]",
        "tls.secret": “k8secret” 
        } 
    ```
5. Deploy the Connected registry extension with HTTPS (TLS encryption) by using the Kubernetes secret management. Configure variables set to `cert-manager.enabled=false` and `cert-manager.install=false`. By using these parameters, the cert-manager isn't installed or enabled since the Kubernetes secret is used instead for encryption.
6. Run the [az-k8s-extension-create](/en-us/cli/azure/k8s-extension#az-k8s-extension-create) command for deployment after editing the protected settings file:

    ```azurecli
    az k8s-extension create --cluster-name myarck8scluster \
    --cluster-type connectedClusters \  
    --extension-type  Microsoft.ContainerRegistry.ConnectedRegistry \ 
    --name myconnectedregistry \ 
    --resource-group myresourcegroup \
    --config service.clusterIP=192.100.100.1 \
    --config cert-manager.enabled=false \
    --config cert-manager.install=false \ 
    --config-protected-file protected-settings-extension.json 
    ```

## Deploy the connected registry using your own trust distribution

By using your own Kubernetes secret or public certificate and private key pairs, you can deploy the connected registry extension with TLS encryption, your inherent trust distribution, and reject the connected registry's default trust distribution. This setup enables you to deploy the connected registry extension with encryption. Be sure to add either the Kubernetes secret or public certificate, and private key variable and value pairs in the protected settings file in JSON format.

To use this option, set the `trustDistribution.enabled=false` and `trustDistribution.skipNodeSelector=false` parameters to reject connected registry trust distribution when you deploy the extension:

```azurecli
az k8s-extension create --cluster-name myarck8scluster \ 
--cluster-type connectedClusters \ 
--extension-type Microsoft.ContainerRegistry.ConnectedRegistry \ 
--name myconnectedregistry \ 
--resource-group myresourcegroup \ 
--config service.clusterIP=192.100.100.1 \
--config trustDistribution.enabled=false \ 
--config cert-manager.enabled=false \
--config cert-manager.install=false \ 
--config-protected-file <JSON file path> 
```

By using these parameters, cert-manager isn't installed or enabled, and the connected registry trust distribution isn't enforced. Instead, you use the cluster-provided trust distribution for establishing trust between the connected registry and the client nodes.

## Clean up resources

Follow these steps to remove the connected registry extension, the corresponding Connected registry pods, and the configuration settings.

1. Run [az-k8s-extension-delete](/en-us/cli/azure/k8s-extension#az-k8s-extension-delete) to delete the connected registry extension:

    ```azurecli
    az k8s-extension delete --name myconnectedregistry 
    --cluster-name myarcakscluster \ 
    --resource-group myresourcegroup \ 
    --cluster-type connectedClusters
    ```
2. Run [az acr connected-registry delete](/en-us/cli/azure/acr/connected-registry#az-acr-connected-registry-delete) to delete the connected registry resource:

    ```azurecli
    az acr connected-registry delete --registry myacrregistry \ 
    --name myconnectedregistry \ 
    --resource-group myresourcegroup
    ```