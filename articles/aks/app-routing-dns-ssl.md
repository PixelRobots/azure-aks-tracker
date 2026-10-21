---
layout: Conceptual
title: Set up a Custom Domain Name and SSL Certificate with the Application Routing Add-on for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/app-routing-dns-ssl
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
description: Understand the advanced configuration options that are supported with the application routing add-on for Azure Kubernetes Service (AKS).
ms.subservice: aks-networking
ms.author: schaffererin
author: schaffererin
ms.custom: devx-track-azurecli
ms.topic: how-to
ms.date: 2026-01-29T00:00:00.0000000Z
locale: en-us
document_id: 18434ec0-bfe4-e12e-3c6e-d39b5a2eec75
document_version_independent_id: ba104c8f-7e98-2c00-9ee9-6c2197a2db6a
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/app-routing-dns-ssl.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/app-routing-dns-ssl
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/app-routing-dns-ssl.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 227103bb-14f5-1547-422d-cf7bb2ee3e50
---

# Set up a Custom Domain Name and SSL Certificate with the Application Routing Add-on for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Caution

The [Kubernetes SIG Network](https://github.com/kubernetes/community/blob/master/sig-network/README.md) and the Security Response Committee [announced the retirement](https://www.kubernetes.dev/blog/2025/11/12/ingress-nginx-retirement/) of the [Ingress NGINX project](https://github.com/kubernetes/ingress-nginx/), with maintenance that ended in March 2026. Microsoft will provide official support for critical security patches for application routing add-on NGINX Ingress resources through **November 2026**.

AKS aligns with upstream Kubernetes and uses **[Gateway API](https://gateway-api.sigs.k8s.io) as the long-term standard for ingress and L7 traffic management**. Migrate before support ends in November 2026, based on your requirements:

- **Application routing add-on users** and **OSS NGINX users**: Migrate to the [application routing Gateway API implementation](/en-us/azure/aks/app-routing-gateway-api) for a Gateway API-based ingress traffic management experience, or to [Application Gateway for Containers](/en-us/azure/application-gateway/for-containers/overview), which supports both Ingress API and Gateway API.
- **Service mesh or advanced ingress requirements**: Consider [Gateway API ingress with the Istio service mesh add-on](/en-us/azure/aks/istio-gateway-api). You can use it for ingress without injecting sidecars into your workloads. If you need request header and body size limits, Lua scripts, or rate limiting, review the [Gateway API limitations and alternatives](/en-us/azure/aks/app-routing-gateway-api#limitations).

This article shows you how to configure custom domain names and SSL/TLS certificates for AKS ingress using [Azure Key Vault](/en-us/azure/key-vault/general/overview) and [Azure DNS](/en-us/azure/dns/dns-overview) with the [application routing add-on for AKS](app-routing).

## Prerequisites

- An AKS cluster with the [application routing add-on](app-routing).
- Azure Key Vault if you want to configure SSL termination and store certificates in the vault hosted in Azure. If you don't have one, see [Create a key vault using the Azure CLI](/en-us/azure/key-vault/general/quick-create-cli).
- To enable support for HTTPS traffic, you need an SSL certificate. If you don't have one, see create a certificate.
- Azure DNS if you want to configure global and private zone management and host them in Azure. If you don't have an Azure DNS zone, you can create one. To enable support for DNS zones:

    - All global Azure DNS zones need to be in the same resource group, which could be different from the cluster resource group.
    - All private Azure DNS zones need to be in the same resource group, which could be different from the cluster resource group.
    - The resource group doesn't need to be in the same subscription as the cluster.

### Required Azure permissions

**Your user account needs**: [Owner](/en-us/azure/role-based-access-control/built-in-roles#owner), [Azure account administrator](/en-us/azure/role-based-access-control/rbac-and-directory-admin-roles#classic-subscription-administrator-roles), or [Azure co-administrator](/en-us/azure/role-based-access-control/rbac-and-directory-admin-roles#classic-subscription-administrator-roles) role on your Azure subscription.

**What the commands do**: When you run `az aks approuting update --attach-kv` or `az aks approuting zone add --attach-zones`, these commands use your role assignment permissions to automatically grant the application routing add-on's managed identity the following roles:

- **Key Vault Certificate User** role on your Azure Key Vault (for certificate access).
- **DNS Zone Contributor** role on your Azure DNS zones (for DNS record management).

For more information on AKS managed identities, see [Summary of managed identities](managed-identity-overview#summary-of-managed-identities-used-by-aks).

## Connect to your AKS cluster

To connect to the Kubernetes cluster from your local computer, you use `kubectl`, the Kubernetes command-line client. You can install it locally using the [`az aks install-cli`](/en-us/cli/azure/aks#az-aks-install-cli) command. If you use the Azure Cloud Shell, `kubectl` is already installed.

- Configure kubectl to connect to your Kubernetes cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    # Set environment variables for your resource group and cluster name
    export RESOURCE_GROUP=<resource-group-name>
    export CLUSTER_NAME=<cluster-name>
    
    # Get the AKS cluster credentials
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
    ```

## Create and export a self-signed SSL certificate

For testing, you can use a self-signed public certificate instead of a Certificate Authority (CA)-signed certificate. If you already have a certificate, you can skip this step.

Caution

Self-signed certificates are digital certificates that aren't signed by a trusted third-party CA. The company or developer responsible for the website or software creates, issues, and signs these certificates. This is why self-signed certificates are considered unsafe for public-facing websites and applications. Azure Key Vault has a [trusted partnership with the some Certificate Authorities](/en-us/azure/key-vault/certificates/how-to-integrate-certificate-authority).

1. Create a self-signed SSL certificate to use with the ingress using the `openssl req` command. Make sure you replace *`<host-name>`* with the DNS name you're using.

    ```bash
    openssl req -new -x509 -nodes -out aks-ingress-tls.crt -keyout aks-ingress-tls.key -subj "/CN=<host-name>" -addext "subjectAltName=DNS:<host-name>"
    ```
2. Export the SSL certificate and skip the password prompt using the `openssl pkcs12 -export` command.

    ```bash
    openssl pkcs12 -export -in aks-ingress-tls.crt -inkey aks-ingress-tls.key -out aks-ingress-tls.pfx
    ```

## Import a self-signed SSL certificate into Azure Key Vault

- Import the SSL certificate into Azure Key Vault using the [`az keyvault certificate import`](/en-us/cli/azure/keyvault/certificate#az-keyvault-certificate-import) command. If your certificate is password protected, you can pass the password through the `--password` flag.

    ```azurecli
    # Set environment variables for your key vault name and certificate name
    export KEY_VAULT_NAME=<key-vault-name>
    export KEY_VAULT_CERT_NAME=<key-vault-certificate-name>
    
    # Import the SSL certificate into Azure Key Vault
    az keyvault certificate import --vault-name $KEY_VAULT_NAME --name $KEY_VAULT_CERT_NAME --file aks-ingress-tls.pfx [--password <certificate password if specified>]
    ```

Note

To enable the application routing add-on to reload certificates from Azure Key Vault when they change, you should enable the [secret autorotation feature](csi-secrets-store-configuration-options) of the Secrets Store CSI driver. When autorotation is enabled, the driver updates the pod mount and the Kubernetes secret by polling for changes periodically, based on the rotation poll interval you define. The default rotation poll interval is two minutes.

## Enable Azure Key Vault integration

Azure Key Vault offers [two authorization systems](/en-us/azure/key-vault/general/rbac-access-policy): **Azure role-based access control (Azure RBAC)**, which operates on the management plane, and the **access policy model**, which operates on both the management plane and the data plane. The `--attach-kv` operation selects the appropriate access model to use.

1. Get the resource ID for the key vault using the [`az keyvault show`](/en-us/cli/azure/keyvault#az-keyvault-create) command and set the output to an environment variable.

    ```azurecli
    KEY_VAULT_ID=$(az keyvault show --name <KeyVaultName> --query "id" --output tsv)
    ```
2. Update the application routing add-on to enable the Azure Key Vault provider for Secrets Store CSI Driver and apply the required role assignments using the [`az aks approuting update`](/en-us/cli/azure/aks/approuting#az-aks-approuting-update) command with the `--enable-kv` and `--attach-kv` arguments.

    ```azurecli
    az aks approuting update --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --enable-kv --attach-kv ${KEY_VAULT_ID}
    ```

## Create a global Azure DNS zone

If you already have an Azure DNS zone, you can skip this step.

- Create an Azure DNS zone using the [`az network dns zone create`](/en-us/cli/azure/network/dns/zone#az-network-dns-zone-create) command.

    ```azurecli
    # Set environment variables for your resource group and DNS zone name
    export RESOURCE_GROUP=<resource-group-name>
    export ZONE_NAME=<zone-name>
    
    # Create the Azure DNS zone
    az network dns zone create --resource-group $RESOURCE_GROUP --name $ZONE_NAME
    ```

## Enable Azure DNS integration

1. Get the resource ID for the DNS zone using the [`az network dns zone show`](/en-us/cli/azure/network/dns/zone#az-network-dns-zone-show) command and set the output to an environment variable.

    ```azurecli
    ZONE_ID=$(az network dns zone show --resource-group $RESOURCE_GROUP --name $ZONE_NAME --query "id" --output tsv)
    ```
2. Update the application routing add-on to enable Azure DNS integration using the [`az aks approuting zone`](/en-us/cli/azure/aks/approuting/zone) command. You can pass a comma-separated list of DNS zone resource IDs.

    ```azurecli
    az aks approuting zone add --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --ids=${ZONE_ID} --attach-zones
    ```

## Create an Ingress class that uses a host name and a certificate from Azure Key Vault

The application routing add-on creates an Ingress class on the cluster named *webapprouting.kubernetes.azure.com*. When you create an Ingress object with this class, it activates the add-on.

1. Get the certificate URI to use in the ingress from Azure Key Vault using the [`az keyvault certificate show`](/en-us/cli/azure/keyvault/certificate#az-keyvault-certificate-show) command.

    ```azurecli
    az keyvault certificate show --vault-name $KEY_VAULT_NAME --name $KEY_VAULT_CERT_NAME --query "id" --output tsv
    ```

    The following example output shows the certificate URI returned from the command:

    ```output
    https://KeyVaultName.vault.azure.net/certificates/KeyVaultCertificateName/ab12c34567d89e01f2345g6h78ijkl90
    ```
2. Copy the following YAML manifest into a new file named **ingress.yaml** and save the file to your local computer.

    Update *`<host-name>`* with the name of your DNS host and *`<key-vault-certificate-uri>`* with the URI returned from the previous command. The string value for *`<key-vault-certificate-uri>`* should only include `https://yourkeyvault.vault.azure.net/certificates/certname`. Remove the *Certificate Version* at the end of the URI string to get the current version.

    The *`secretName`* key in the `tls` section defines the name of the secret that contains the certificate for this Ingress resource. This certificate is presented in the browser when a client browses to the URL specified in the `<host-name>` key. Make sure that the value of `secretName` is equal to `keyvault-` followed by the value of the Ingress resource name (from `metadata.name`). In the example YAML, `secretName` needs to be equal to `keyvault-<your-ingress-name>`.

    ```yml
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      annotations:
        kubernetes.azure.com/tls-cert-keyvault-uri: <key-vault-certificate-uri>
      name: aks-helloworld
      namespace: hello-web-app-routing
    spec:
      ingressClassName: webapprouting.kubernetes.azure.com
      rules:
      - host: <host-name>
        http:
          paths:
          - backend:
              service:
                name: aks-helloworld
                port:
                  number: 80
            path: /
            pathType: Prefix
      tls:
      - hosts:
        - <host-name>
        secretName: keyvault-<your-ingress-name>
    ```
3. Create the cluster resources using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command.

    ```bash
    kubectl apply -f ingress.yaml -n hello-web-app-routing
    ```

    The following example output shows the created resource:

    ```output
    Ingress.networking.k8s.io/aks-helloworld created
    ```

## Verify the managed ingress was created

- Verify the managed ingress was created using the [`kubectl get ingress`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command.

    ```bash
    kubectl get ingress -n hello-web-app-routing
    ```

    The following example output shows the created managed ingress:

    ```output
    NAME             CLASS                                HOSTS               ADDRESS       PORTS     AGE
    aks-helloworld   webapprouting.kubernetes.azure.com   myapp.contoso.com   20.51.92.19   80, 443   4m
    ```