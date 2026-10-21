---
layout: Conceptual
title: Istio service mesh add-on plug-in CA certificate troubleshooting - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/istio-add-on-plug-in-ca-certificate
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: deveshdama
ms.author: ddama
ms.topic: troubleshooting
description: Learn how to do plug-in CA certificate troubleshooting on the Istio service mesh add-on for Azure Kubernetes Service (AKS).
ms.date: 2025-04-01T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: fuyuanbie, shasb, kochhars, nshankar, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Extensions, Policies and Add-Ons
locale: en-us
document_id: 6a35ddde-dffc-2ed9-c50e-e8d324176bdc
document_version_independent_id: 6a35ddde-dffc-2ed9-c50e-e8d324176bdc
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/istio-add-on-plug-in-ca-certificate.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
interactive_type: azurecli
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/istio-add-on-plug-in-ca-certificate
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/istio-add-on-plug-in-ca-certificate.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
platformId: 11c00b9f-43f6-aff4-5522-ba34485d4723
---

# Istio service mesh add-on plug-in CA certificate troubleshooting - Azure | Microsoft Learn

## Summary

This article discusses common troubleshooting issues with the Istio add-on plug-in certificate authority (CA) certificates feature, and it offers solutions to fix these issues. The article also reviews the general process of setting up plug-in CA certificates for the service mesh add-on.

Note

This article assumes that Istio revision `asm-1-21` is deployed on the cluster.

## Prerequisites

- [Azure CLI](/en-us/cli/azure/install-azure-cli).
- The Kubernetes [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) tool, or a similar tool, to connect to the cluster. To install kubectl by using Azure CLI, run the [az aks install-cli](/en-us/cli/azure/aks#az-aks-install-cli) command.
- The following Linux-style standard shell tools:

    - `grep`
    - `sort`
    - `tail`
    - `awk`
    - `xargs`
- The [jq](https://jqlang.github.io/jq/) tool for querying JSON data.

## General setup process

- Before you enable the Istio add-on to use the plug-in CA certificates feature, you have to enable the [Azure Key Vault provider for Secrets Store add-on](/en-us/azure/aks/csi-secrets-store-driver) on the cluster. Make sure that the Azure Key Vault and the cluster are on the same Azure tenant.
- After the Azure Key Vault secrets provider add-on is enabled, you have to set up access to the Azure Key Vault for the [user-assigned managed identity](/en-us/azure/aks/csi-secrets-store-driver#create-an-aks-cluster-with-azure-key-vault-provider-for-secrets-store-csi-driver-support) that the add-on creates.
- After you grant permission for the user-assigned managed identity to access the Azure Key Vault, you can use the plug-in CA certificates feature together with the Istio add-on. For more information, see the Enable the Istio add-on to use a plug-in CA certificate section.
- For the cluster to auto-detect changes in the Azure Key Vault secrets, you have to enable [auto-rotation](/en-us/azure/aks/csi-secrets-store-configuration-options#enable-and-disable-auto-rotation) for the Azure Key Vault secrets provider add-on.
- Changes to the root and intermediate certificates are applied automatically.

## Enable the Istio add-on to use a plug-in CA certificate

The Istio add-on [plug-in CA certificates](https://istio.io/latest/docs/tasks/security/cert-management/plugin-ca-cert/) feature allows you to configure plug-in root and intermediate certificates for the mesh. To provide plug-in certificate information when you enable the add-on, specify the following parameters for the [az aks mesh enable](/en-us/cli/azure/aks/mesh#az-aks-mesh-enable) command in Azure CLI.

| Parameter | Description |
| --- | --- |
| `--key-vault-id`*&lt;resource-id&gt;* | The Azure Key Vault resource ID. This resource is expected to be in the same tenant as the managed cluster. This resource ID must be in the [Azure Resource Manager template (ARM template) resource ID format](/en-us/azure/azure-resource-manager/templates/template-functions-resource#resourceid). |
| `--root-cert-object-name`*&lt;root-cert-obj-name&gt;* | The root certificate object name in the Azure Key Vault. |
| `--ca-cert-object-name`*&lt;inter-cert-obj-name&gt;* | The intermediate certificate object name in the Azure Key Vault. |
| `--ca-key-object-name`*&lt;inter-key-obj-name&gt;* | The intermediate certificate private key object name in the Azure Key Vault. |
| `--cert-chain-object-name`*&lt;cert-chain-obj-name&gt;* | The certificate chain object name in the Azure Key Vault. |

If you want to use the plug-in CA certificates feature, you must specify all five parameters. All Azure Key Vault objects are expected to be of the type [Secret](/en-us/azure/key-vault/secrets/about-secrets).

For more information, see [Plug in CA certificates for Istio-based service mesh add-on on Azure Kubernetes Service](/en-us/azure/aks/istio-plugin-ca).

## Deployed resources

As part of the add-on deployment for the plug-in certificates feature, the following resources are deployed onto the cluster:

- The `istio-spc-asm-1-21`[SecretProviderClass object](https://azure.github.io/secrets-store-csi-driver-provider-azure/docs/getting-started/usage/#create-your-own-secretproviderclass-object) is created in the `aks-istio-system` namespace at the time of the add-on deployment. This resource contains Azure-specific parameters for the Secrets Store Container Storage Interface (CSI) driver:

    ```bash
    kubectl get secretproviderclass --namespace aks-istio-system
    ```

    ```output
    NAME                 AGE
    istio-spc-asm-1-21   14h
    ```
- The `istio-ca-root-cert` configmap is created in the `aks-istio-system` namespace and all user-managed namespaces. This configmap contains the root certificate that the certificate authority uses, and it's used by workloads in the namespaces to validate workload-to-workload communication, as follows:

    ```bash
    kubectl describe configmap istio-ca-root-cert --namespace aks-istio-system
    ```

    ```output
    Name:         istio-ca-root-cert
    Namespace:    aks-istio-system
    Labels:       istio.io/config=true
    Annotations:  <none>
    
    Data
    ====
    root-cert.pem:
    ----
    -----BEGIN CERTIFICATE-----
    <certificate data>
    -----END CERTIFICATE-----
    ```

## Determine certificate type in deployment logs

You can view the `istiod` deployment logs to determine whether you have a self-signed CA certificate or a plug-in CA certificate. To view the logs, run the following command:

```bash
kubectl logs deploy/istiod-asm-1-21 --container discovery --namespace aks-istio-system | grep -v validationController
```

Immediately before each certificate log entry is another log entry that describes that kind of certificate. For a self-signed CA certificate, the entry states "No plugged-in cert at *etc/cacerts/ca-key.pem*; self-signed cert is used." For a plug-in certificate, the entry states "Use plugged-in cert at *etc/cacerts/ca-key.pem*." Sample log entries that pertain to the certificates are shown in the following tables.

- Log entries for a self-signed CA certificate

    | Timestamp | Log level | Message |
    | --- | --- | --- |
    | 2023-11-20T23:27:36.649019Z | info | Using istiod file format for signing ca files |
    | 2023-11-20T23:27:36.649032Z | info | **No plugged-in cert at etc/cacerts/ca-key.pem; self-signed cert is used** |
    | 2023-11-20T23:27:36.649536Z | info | x509 cert - &lt;certificate-details&gt; |
    | 2023-11-20T23:27:36.649552Z | info | Istiod certificates are reloaded |
    | 2023-11-20T23:27:36.649613Z | info | spiffe Added 1 certs to trust domain cluster.local in peer cert verifier |
- Log entries for a plug-in CA certificate

    | Timestamp | Log level | Message |
    | --- | --- | --- |
    | 2023-11-21T00:20:25.808396Z | info | Using istiod file format for signing ca files |
    | 2023-11-21T00:20:25.808412Z | info | **Use plugged-in cert at etc/cacerts/ca-key.pem** |
    | 2023-11-21T00:20:25.808731Z | info | x509 cert - &lt;certificate-details&gt; |
    | 2023-11-21T00:20:25.808764Z | info | x509 cert - &lt;certificate-details&gt; |
    | 2023-11-21T00:20:25.808799Z | info | x509 cert - &lt;certificate-details&gt; |
    | 2023-11-21T00:20:25.808803Z | info | Istiod certificates are reloaded |
    | 2023-11-21T00:20:25.808873Z | info | spiffe Added 1 certs to trust domain cluster.local in peer cert verifier |

The certificate details in a log entry are shown as comma-separated values for the issuer, subject, serial number (SN—a long hexadecimal string), and the beginning and ending timestamp values that define when the certificate is valid.

For a self-signed CA certificate, there's one detail entry. Sample values for this certificate are shown in the following table.

| Issuer | Subject | SN | NotBefore | NotAfter |
| --- | --- | --- | --- | --- |
| "O=cluster.local" | "" | &lt;32-digit-hex-value&gt; | "2023-11-20T23:25:36Z" | "2033-11-17T23:27:36Z" |

For a plug-in CA certificate, there are three detail entries. The other two entries are for a root certificate update and a change to the intermediate certificate. Sample values for these entries are shown in the following table.

| Issuer | Subject | SN | NotBefore | NotAfter |
| --- | --- | --- | --- | --- |
| CN=Intermediate CA - A1,O=Istio,L=cluster-A1" | "" | &lt;32-digit-hex-value&gt; | "2023-11-21T00:18:25Z" | "2033-11-18T00:20:25Z" |
| CN=Root A,O=Istio" | "CN=Intermediate CA - A1,O=Istio,L=cluster-A1" | &lt;40-digit-hex-value&gt; | "2023-11-04T01:40:22Z" | "2033-11-01T01:40:22Z" |
| CN=Root A,O=Istio" | "CN=Root A,O=Istio" | &lt;40-digit-hex-value&gt; | "2023-11-04T01:38:27Z" | "2033-11-01T01:38:27Z" |

## Troubleshoot common issues

### Issue 1: Access to Azure Key Vault is set up incorrectly

After you enable the Azure Key Vault secrets provider add-on, you have to grant access for the user-assigned managed identity of the add-on to the Azure Key Vault. Setting up access to Azure Key Vault incorrectly causes the add-on installation to stall.

```bash
kubectl get pods --namespace aks-istio-system
```

In the list of pods, you can see that the `istiod-asm-1-21` pods are stuck in an `Init:0/2` state.

| NAME | READY | STATUS | RESTARTS | AGE |
| --- | --- | --- | --- | --- |
| istiod-asm-1-21-6fcfd88478-2x95b | 0/1 | Terminating | 0 | 5m55s |
| istiod-asm-1-21-6fcfd88478-6x5hh | 0/1 | Terminating | 0 | 5m40s |
| istiod-asm-1-21-6fcfd88478-c48f9 | 0/1 | Init:0/2 | 0 | 54s |
| istiod-asm-1-21-6fcfd88478-wl8mw | 0/1 | Init:0/2 | 0 | 39s |

To verify the Azure Key Vault access issue, run the `kubectl get pods` command to locate pods that have the `secrets-store-provider-azure` label in the `kube-system` namespace:

```bash
kubectl get pods --selector app=secrets-store-provider-azure --namespace kube-system --output name | xargs -I {} kubectl logs --namespace kube-system {}
```

The following sample output shows that a "403 Forbidden" error occurred because you don't have "get" permissions for secrets on the Key Vault:

> 
> "failed to process mount request" err="failed to get objectType:secret, objectName:&lt;secret-object-name&gt;, objectVersion:: keyvault.BaseClient#GetSecret: Failure responding to request: StatusCode=403 -- Original Error: autorest/azure: Service returned an error. **Status=403 Code=\"Forbidden\" Message=\"The user, group or application 'appid=&lt;appid&gt;;oid=&lt;oid&gt;;iss=&lt;iss&gt;' does not have secrets get permission on key vault 'MyAzureKeyVault;location=eastus'. For help resolving this issue, please see https://go.microsoft.com/fwlink/?linkid=2125287\" InnerError={\"code\":\"AccessDenied\"}"**

To fix this problem, set up access to the user-assigned managed identity for the Azure Key Vault secrets provider add-on by obtaining Get and List permissions on Azure Key Vault secrets and reinstalling the Istio add-on. First, get the object ID of the user-assigned managed identity for the Azure Key Vault secrets provider add-on by running the [az aks show](/en-us/cli/azure/aks#az-aks-show) command:

```azurecli
OBJECT_ID=$(az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER --query 'addonProfiles.azureKeyvaultSecretsProvider.identity.objectId')
```

To set the access policy, run the following [az keyvault set-policy](/en-us/cli/azure/keyvault#az-keyvault-set-policy) command by specifying the object ID that you obtained:

```azurecli
az keyvault set-policy --name $AKV_NAME --object-id $OBJECT_ID --secret-permissions get list
```

Note

Did you create your Key Vault by using Azure RBAC Authorization for your permission model instead of Vault Access Policy? In this case, see [Provide access to Key Vault keys, certificates, and secrets with an Azure role-based access control](/en-us/azure/key-vault/general/rbac-guide) to create permissions for the managed identity. Add an Azure role assignment for [Key Vault Reader](/en-us/azure/role-based-access-control/built-in-roles/security#key-vault-reader) for the user-assigned managed identity of the add-on.

### Issue 2: Auto-detection of Key Vault secret changes isn't set up

For a cluster to auto-detect changes in the Azure Key Vault secrets, you have to enable auto-rotation for the Azure Key Vault provider add-on. Auto-rotation can detect changes in intermediate and root certificates automatically. For a cluster that enables the Azure Key Vault provider add-on, run the following `az aks show` command to check whether auto-rotation is enabled:

```azurecli
az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER | jq -r '.addonProfiles.azureKeyvaultSecretsProvider.config.enableSecretRotation'
```

If the cluster enabled the Azure Key Vault provider add-on, run the following `az aks show` command to determine the rotation poll interval:

```azurecli
az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER | jq -r '.addonProfiles.azureKeyvaultSecretsProvider.config.rotationPollInterval'
```

Azure Key Vault secrets are synchronized with the cluster when the poll interval time elapses after the previous synchronization. The default interval value is two minutes.

### Issue 3: Certificate values are missing or are configured incorrectly

If secret objects are missing from Azure Key Vault, or if these objects are configured incorrectly, the `istiod-asm-1-21` pods might get stuck in an `Init:0/2` status, delaying the installation of the add-on. To find the underlying cause of this problem, run the following `kubectl describe` command against the `istiod` deployment and view the output:

```bash
kubectl describe deploy/istiod-asm-1-21 --namespace aks-istio-system
```

The command displays events that might resemble the following output table. In this example, a missing secret is the cause of the problem.

| Type | Reason | Age | From | Message |
| --- | --- | --- | --- | --- |
| Normal | Scheduled | 3m9s | default-scheduler | Successfully assigned aks-istio-system/istiod-asm-1-21-6fcfd88478-hqdjj to aks-userpool-24672518-vmss000000 |
| Warning | FailedMount | 66s | kubelet | Unable to attach or mount volumes: unmounted volumes=[cacerts], unattached volumes=[], failed to process volumes=[]: timed out waiting for the condition |
| Warning | FailedMount | 61s (x9 over 3m9s) | kubelet | MountVolume.SetUp failed for volume "cacerts" : rpc error: code = Unknown desc = failed to mount secrets store objects for pod aks-istio-system/istiod-asm-1-21-6fcfd88478-hqdjj, err: rpc error: code = Unknown desc = failed to mount objects, error: failed to get objectType:secret, objectName:test-cert-chain, objectVersion:: keyvault.BaseClient#GetSecret: Failure responding to request: StatusCode=404 -- Original Error: autorest/azure: Service returned an error. **Status=404 Code="SecretNotFound" Message="A secret with (name/id) test-cert-chain was not found in this key vault. If you recently deleted this secret you may be able to recover it using the correct recovery command. For help resolving this issue, please see https://go.microsoft.com/fwlink/?linkid=2125182"** |

## Resources

- [General Istio service mesh add-on troubleshooting](istio-add-on-general-troubleshooting)
- [Istio service mesh add-on MeshConfig troubleshooting](istio-add-on-meshconfig)
- [Istio service mesh add-on ingress gateway troubleshooting](istio-add-on-ingress-gateway)
- [Istio service mesh add-on minor revision upgrade troubleshooting](istio-add-on-minor-revision-upgrade)

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.

**Third-party contact disclaimer**

Microsoft provides third-party contact information to help you find additional information about this topic. This contact information may change without notice. Microsoft does not guarantee the accuracy of third-party contact information.