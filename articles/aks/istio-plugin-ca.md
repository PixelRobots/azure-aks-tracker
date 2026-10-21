---
layout: Conceptual
title: Plug-in CA certificates for Istio-based service mesh add-on on Azure Kubernetes Service - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/istio-plugin-ca
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
description: Plug-in CA certificates for Istio-based service mesh add-on on Azure Kubernetes Service
ms.topic: concept-article
ms.custom: devx-track-azurecli
ms.date: 2025-03-17T00:00:00.0000000Z
ms.author: shasb
author: shashankbarsin
ai-usage: ai-assisted
locale: en-us
document_id: 70d408f1-268a-8f58-9e63-ce96635471f9
document_version_independent_id: cf175d08-e928-3446-40f7-3db6aca237c7
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/istio-plugin-ca.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/istio-plugin-ca
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/istio-plugin-ca.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 5a155fd7-8e44-df98-df0f-ea7059f68f06
---

# Plug-in CA certificates for Istio-based service mesh add-on on Azure Kubernetes Service - Azure Kubernetes Service | Microsoft Learn

In the Istio-based service mesh add-on for Azure Kubernetes Service, by default the Istio certificate authority (CA) generates a self-signed root certificate and key and uses them to sign the workload certificates. To protect the root CA key, you should use a root CA, which runs on a secure machine offline. You can use the root CA to issue intermediate certificates to the Istio CAs that run in each cluster. An Istio CA can sign workload certificates using the administrator-specified certificate and key, and distribute an administrator-specified root certificate to the workloads as the root of trust. This article addresses how to bring your own certificates and keys for Istio CA in the Istio-based service mesh add-on for Azure Kubernetes Service.

[![Diagram that shows root and intermediate CA with Istio.](media/istio/istio-byo-ca.png)](media/istio/istio-byo-ca.png#lightbox)

This article addresses how you can configure the Istio certificate authority with a root certificate, signing certificate and key provided as inputs using Azure Key Vault to the Istio-based service mesh add-on.

## Before you begin

### Verify Azure CLI version

The add-on requires Azure CLI version 2.57.0 or later installed. You can run `az --version` to verify version. To install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

### Set up Azure Key Vault

1. You need an [Azure Key Vault resource](/en-us/azure/key-vault/general/quick-create-cli) to supply the certificate and key inputs to the Istio add-on.
2. You need to generate root certificate, intermediate certificates, intermediate key, and the certificate chain offline. Steps 1-3 from [here](https://istio.io/latest/docs/tasks/security/cert-management/plugin-ca-cert/#plug-in-certificates-and-key-into-the-cluster) has an example of how to generate these files.
3. Create secrets in Azure Key Vault using the certificates and key:

    ```bash
    az keyvault secret set --vault-name $AKV_NAME --name root-cert --file <path-to-folder/root-cert.pem>
    az keyvault secret set --vault-name $AKV_NAME --name ca-cert --file <path-to-folder/ca-cert.pem>
    az keyvault secret set --vault-name $AKV_NAME --name ca-key --file <path-to-folder/ca-key.pem>
    az keyvault secret set --vault-name $AKV_NAME --name cert-chain --file <path-to-folder/cert-chain.pem>
    ```
4. Enable [Azure Key Vault provider for Secret Store CSI Driver for your cluster](csi-secrets-store-driver):

    ```bash
    az aks enable-addons --addons azure-keyvault-secrets-provider --resource-group $RESOURCE_GROUP --name $CLUSTER
    ```

    Note

    When rotating certificates, to control how quickly the secrets are synced down to the cluster you can use the `--rotation-poll-interval` parameter of the Azure Key Vault Secrets Provider add-on. For example: `az aks addon update --resource-group $RESOURCE_GROUP --name $CLUSTER --addon azure-keyvault-secrets-provider --enable-secret-rotation --rotation-poll-interval 20s`
5. If your Key Vault is using Azure RBAC for the permissions model, follow the instructions [here](/en-us/azure/key-vault/general/rbac-guide) to assign an Azure role of Key Vault Secrets User for the add-on's user-assigned managed identity. Alternatively, if your key vault is using the vault access policy permissions model, authorize the user-assigned managed identity of the add-on to access Azure Key Vault resource using access policy:

    ```bash
    OBJECT_ID=$(az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER --query 'addonProfiles.azureKeyvaultSecretsProvider.identity.objectId' -o tsv)
    
    az keyvault set-policy --name $AKV_NAME --object-id $OBJECT_ID --secret-permissions get
    ```

## Set up Istio-based service mesh add-on with plug-in CA certificates

1. Enable the Istio service mesh add-on for your existing AKS cluster while referencing the Azure Key Vault secrets that were created earlier:

    ```bash
    az aks mesh enable --resource-group $RESOURCE_GROUP --name $CLUSTER \
    --root-cert-object-name root-cert \
    --ca-cert-object-name ca-cert \
    --ca-key-object-name ca-key \
    --cert-chain-object-name cert-chain \
    --key-vault-id /subscriptions/$SUBSCRIPTION/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$AKV_NAME
    ```

    Note

    For existing clusters with the Istio add-on using self-signed root certificate generated by Istio CA, switching to plugin CA is not supported. You need to [disable the mesh](/en-us/cli/azure/aks/mesh#az-aks-mesh-disable) on these clusters first and then enable it again using the above command to pass through the plugin CA inputs.
2. Verify that the Istio control plane picked up the custom certificate authority:

    ```bash
    kubectl logs deploy/istiod-asm-1-17 -c discovery -n aks-istio-system | grep -v validationController | grep x509
    ```

    Expected output should be similar to:

    ```bash
    2023-11-06T15:49:15.493732Z     info    x509 cert - Issuer: "CN=Intermediate CA - A1,O=Istio,L=cluster-A1", Subject: "", SN: e191d220af347c7e164ec418d75ed19e, NotBefore: "2023-11-06T15:47:15Z", NotAfter: "2033-11-03T15:49:15Z"
    2023-11-06T15:49:15.493764Z     info    x509 cert - Issuer: "CN=Root A,O=Istio", Subject: "CN=Intermediate CA - A1,O=Istio,L=cluster-A1", SN: 885034cba2894f61036f2956fd9d0ed337dc636, NotBefore: "2023-11-04T01:40:02Z", NotAfter: "2033-11-01T01:40:02Z"
    2023-11-06T15:49:15.493795Z     info    x509 cert - Issuer: "CN=Root A,O=Istio", Subject: "CN=Root A,O=Istio", SN: 18e2ee4089c5a7363ec306627d21d9bb212bed3e, NotBefore: "2023-11-04T01:38:27Z", NotAfter: "2033-11-01T01:38:27Z"
    ```

## Certificate authority rotation

You may need to periodically rotate the certificate authorities for security or policy reasons. This section walks you through how to handle intermediate CA and root CA rotation scenarios.

### Intermediate certificate authority rotation

1. You can rotate the intermediate CA while keeping the root CA the same. Update the secrets in Azure Key Vault resource with the new certificate and key files:

    ```bash
    az keyvault secret set --vault-name $AKV_NAME --name root-cert --file <path-to-folder/root-cert.pem>
    az keyvault secret set --vault-name $AKV_NAME --name ca-cert --file <path-to-folder/ca-cert.pem>
    az keyvault secret set --vault-name $AKV_NAME --name ca-key --file <path-to-folder/ca-key.pem>
    az keyvault secret set --vault-name $AKV_NAME --name cert-chain --file <path/cert-chain.pem>
    ```
2. Wait for the time duration of `--rotation-poll-interval`. Check if the certificates were refreshed on the cluster based on the new intermediate CA that was updated on the Azure Key Vault resource:

    ```bash
    kubectl logs deploy/istiod-asm-1-17 -c discovery -n aks-istio-system | grep -v validationController
    ```

    Expected output should be similar to:

    ```bash
    2023-11-07T06:16:21.091844Z     info    Update Istiod cacerts
    2023-11-07T06:16:21.091901Z     info    Using istiod file format for signing ca files
    2023-11-07T06:16:21.354423Z     info    Istiod has detected the newly added intermediate CA and updated its key and certs accordingly
    2023-11-07T06:16:21.354910Z     info    x509 cert - Issuer: "CN=Intermediate CA - A2,O=Istio,L=cluster-A2", Subject: "", SN: b2753c6a23b54d8364e780bf664672ce, NotBefore: "2023-11-07T06:14:21Z", NotAfter: "2033-11-04T06:16:21Z"
    2023-11-07T06:16:21.354967Z     info    x509 cert - Issuer: "CN=Root A,O=Istio", Subject: "CN=Intermediate CA - A2,O=Istio,L=cluster-A2", SN: 17f36ace6496ac2df88e15878610a0725bcf8ae9, NotBefore: "2023-11-04T01:40:22Z", NotAfter: "2033-11-01T01:40:22Z"
    2023-11-07T06:16:21.355007Z     info    x509 cert - Issuer: "CN=Root A,O=Istio", Subject: "CN=Root A,O=Istio", SN: 18e2ee4089c5a7363ec306627d21d9bb212bed3e, NotBefore: "2023-11-04T01:38:27Z", NotAfter: "2033-11-01T01:38:27Z"
    2023-11-07T06:16:21.355012Z     info    Istiod certificates are reloaded
    ```
3. The workloads receive certificates from the Istio control plane that are valid for 24 hours by default. If you don't restart the pods, all the workloads obtain new leaf certificates based on the new intermediate CA in 24 hours. If you want to force all these workloads to obtain new leaf certificates right away from the new intermediate CA, then you need to restart the workloads.

    ```bash
    kubectl rollout restart deployment <deployment name> -n <deployment namespace>
    ```

### Root certificate authority rotation

1. You need to update Azure Key Vault secrets with the root certificate file having the concatenation of the old and the new root certificates:

    ```bash
    az keyvault secret set --vault-name $AKV_NAME --name root-cert --file <path-to-folder/root-cert.pem>
    az keyvault secret set --vault-name $AKV_NAME --name ca-cert --file <path-to-folder/ca-cert.pem>
    az keyvault secret set --vault-name $AKV_NAME --name ca-key --file <path-to-folder/ca-key.pem>
    az keyvault secret set --vault-name $AKV_NAME --name cert-chain --file <path/cert-chain.pem>
    ```

    Contents of `root-cert.pem` follow this format:

    ```
    -----BEGIN CERTIFICATE-----
    <contents of old root certificate>
    -----END CERTIFICATE-----
    -----BEGIN CERTIFICATE-----
    <contents of new root certificate>
    -----END CERTIFICATE-----
    ```

    Check `istiod` logs, once the certificates have been synchronized to the cluster.

    ```bash
    kubectl logs deploy/istiod-asm-1-17 -c discovery -n aks-istio-system 
    ```

    Expected output:

    ```bash
    2023-11-07T06:42:00.287916Z     info    Updating new ROOT-CA
    2023-11-07T06:42:00.287928Z     info    update root cert and generate new dns certs
    2023-11-07T06:42:00.288254Z     info    Update trust anchor with new root cert
    2023-11-07T06:42:00.288279Z     info    trustBundle     updating Source IstioCA with certs
    2023-11-07T06:42:00.288298Z     info    Istiod has detected the newly added intermediate CA and updated its key and certs accordingly
    2023-11-07T06:42:00.288303Z     info    Istiod certificates are reloaded
    ```
2. You need to either wait for 24 hours (the default time for leaf certificate validity) or force a restart of all the workloads. This way, all workloads recognize both the old and the new certificate authorities for [mTLS verification](https://istio.io/latest/docs/concepts/security/#mutual-tls-authentication).

    ```bash
    kubectl rollout restart deployment <deployment name> -n <deployment namespace>
    ```
3. You can now update Azure Key Vault secrets with only the new CA (without the old CA):

    ```bash
    az keyvault secret set --vault-name $AKV_NAME --name root-cert --file <path-to-folder/root-cert.pem>
    az keyvault secret set --vault-name $AKV_NAME --name ca-cert --file <path-to-folder/ca-cert.pem>
    az keyvault secret set --vault-name $AKV_NAME --name ca-key --file <path-to-folder/ca-key.pem>
    az keyvault secret set --vault-name $AKV_NAME --name cert-chain --file <path/cert-chain.pem>
    ```

    Check `istiod` logs, once the certificates have been synchronized to the cluster.

    ```bash
    kubectl logs deploy/istiod-asm-1-17 -c discovery -n aks-istio-system | grep -v validationController
    ```

    Expected output:

    ```bash
    2023-11-07T08:01:17.780299Z     info    x509 cert - Issuer: "CN=Intermediate CA - B1,O=Istio,L=cluster-B1", Subject: "", SN: 1159747c72cc7ac7a54880cd49b8df0a, NotBefore: "2023-11-07T07:59:17Z", NotAfter: "2033-11-04T08:01:17Z"
    2023-11-07T08:01:17.780330Z     info    x509 cert - Issuer: "CN=Root B,O=Istio", Subject: "CN=Intermediate CA - B1,O=Istio,L=cluster-B1", SN: 2aba0c438652a1f9beae4249457023013948c7e2, NotBefore: "2023-11-04T01:42:12Z", NotAfter: "2033-11-01T01:42:12Z"
    2023-11-07T08:01:17.780345Z     info    x509 cert - Issuer: "CN=Root B,O=Istio", Subject: "CN=Root B,O=Istio", SN: 3f9da6ddc4cb03749c3f43243a4b701ce5eb4e96, NotBefore: "2023-11-04T01:41:54Z", NotAfter: "2033-11-01T01:41:54Z"
    ```

    From the example outputs shown in this article, you can observe that we moved from Root A (used when enabling the add-on) to Root B.