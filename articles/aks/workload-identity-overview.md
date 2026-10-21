---
layout: Conceptual
title: Use a Microsoft Entra Workload ID on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview
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
description: Learn about Microsoft Entra Workload ID for Azure Kubernetes Service (AKS), how workload identity is preconfigured on AKS Automatic clusters, and how to migrate your application to authenticate using this identity.
author: shashankbarsin
ms.author: shasb
ms.topic: overview
ms.subservice: aks-security
ms.custom: build-2023
ms.date: 2026-10-06T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: 4a9fd9ca-de52-17a5-18a1-6e7dcb1cb1d4
document_version_independent_id: f1e18be4-3bb1-89fb-42d7-0735744ee734
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/workload-identity-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/workload-identity-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/workload-identity-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f233afb4-f511-4877-ab18-c53e36c47c54
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/57eae307-c3a1-4cac-b645-1a899934bac8
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/aa758f63-7086-440d-afba-dcb5819f0b6f
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/ee561821-1ac7-45a8-9409-6ba5eb7a5b97
platformId: f9d0bce0-b86a-ef0a-ac3a-5e91c0abfccb
---

# Use a Microsoft Entra Workload ID on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Workloads deployed on an AKS cluster require Microsoft Entra application credentials or managed identities to access Microsoft Entra protected resources, such as Azure Key Vault and Microsoft Graph. Microsoft Entra Workload ID integrates with the capabilities native to Kubernetes to federate with external identity providers, allowing you to assign workload identities to your workloads to authenticate and access other services and resources.

Note

Workload ID covers the **pod-to-Azure** identity scenario in AKS - how applications running in pods authenticate to Microsoft Entra-protected services. On **AKS Automatic**, workload identity with Microsoft Entra Workload ID and the OIDC cluster issuer are preconfigured by default - no cluster-level setup is required. On **AKS Standard**, you enable and configure workload identity separately. For the other identity scenarios (control-plane authentication and authorization, and cluster-to-Azure managed identities), see [Access and identity options for AKS](concepts-identity).

Tip

If you're using an **AKS Automatic** cluster, workload identity with Microsoft Entra Workload ID and the OIDC cluster issuer are **preconfigured by default**. You can skip cluster-level setup and go directly to configuring your application to use a workload identity. For more information about AKS Automatic's security defaults, see [What is Azure Kubernetes Service Automatic?](intro-aks-automatic)

[Microsoft Entra Workload ID](/en-us/azure/active-directory/develop/workload-identities-overview) uses [Service Account Token Volume Projection](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#serviceaccount-token-volume-projection) to enable pods to use a Kubernetes identity. A Kubernetes token is issued and [OpenID Connect (OIDC) federation](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#openid-connect-tokens) enables Kubernetes applications to access Azure resources securely with Microsoft Entra ID, based on annotated service accounts.

You can use Microsoft Entra Workload ID with Azure Identity client libraries or the [Microsoft Authentication Library](/en-us/azure/active-directory/develop/msal-overview) (MSAL) collection, together with [application registration](/en-us/azure/active-directory/develop/application-model#register-an-application), to seamlessly authenticate and access Azure cloud resources.

Note

You can use *Service Connector* to help you configure some steps automatically. For more information, see [What is Service Connector?](/en-us/azure/service-connector/overview)

## Prerequisites

### AKS Automatic clusters

On AKS Automatic clusters, workload identity and the OIDC cluster issuer are preconfigured as part of the cluster's security defaults. No cluster-level configuration is required before using workload identity in your pods. Proceed directly to setting up your application.

### AKS Standard clusters

- AKS supports Microsoft Entra Workload ID on version 1.22 and higher.
- The Azure CLI version 2.47.0 or later. Run `az --version` to find the version, and run `az upgrade` to upgrade the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- You must enable workload identity and the OIDC issuer on your cluster before your pods can use workload identity. See [Deploy and configure workload identity on an AKS cluster](workload-identity-deploy-cluster).

## Limitations

- You can have a maximum of [20 federated identity credentials](/en-us/azure/active-directory/workload-identities/workload-identity-federation-considerations#general-federated-identity-credential-considerations) per managed identity.
- It takes a few seconds for the federated identity credential to propagate after being initially added.
- The [virtual nodes](virtual-nodes) add-on, based on the open source project [Virtual Kubelet](https://virtual-kubelet.io/docs/), isn't supported.
- Creation of federated identity credentials isn't supported on user-assigned managed identities in [these regions](/en-us/azure/active-directory/workload-identities/workload-identity-federation-considerations#unsupported-regions-user-assigned-managed-identities).

## Azure Identity client libraries

In the Azure Identity client libraries, choose one of the following approaches:

- Use `DefaultAzureCredential`, which attempts to use the `WorkloadIdentityCredential`.
- Create a `ChainedTokenCredential` instance that includes `WorkloadIdentityCredential`.
- Use `WorkloadIdentityCredential` directly.

When requesting tokens with `WorkloadIdentityCredential`, pass scopes using the Microsoft Entra ID v2 format `<resource>/.default`, such as `https://management.azure.com/.default`. A raw resource URI, such as `https://management.azure.com/`, can fail because workload identity uses the Microsoft Entra v2 token endpoint rather than the IMDS `resource` flow used by managed identity. For more information about how scopes work in the v2 token endpoint, see [Get a token](/en-us/entra/identity-platform/v2-oauth2-client-creds-grant-flow#get-a-token).

The following table provides the **minimum** package version required for each language ecosystem's client library:

| Ecosystem | Library | Minimum version |
| --- | --- | --- |
| .NET | [Azure.Identity](/en-us/dotnet/api/overview/azure/identity-readme) | 1.9.0 |
| C++ | [azure-identity-cpp](https://github.com/Azure/azure-sdk-for-cpp/blob/main/sdk/identity/azure-identity/README.md) | 1.6.0 |
| Go | [azidentity](https://pkg.go.dev/github.com/Azure/azure-sdk-for-go/sdk/azidentity) | 1.3.0 |
| Java | [azure-identity](/en-us/java/api/overview/azure/identity-readme) | 1.9.0 |
| Node.js | [@azure/identity](/en-us/javascript/api/overview/azure/identity-readme) | 3.2.0 |
| Python | [azure-identity](/en-us/python/api/overview/azure/identity-readme) | 1.13.0 |

## Azure Identity client library code samples

The following code samples use the `DefaultAzureCredential`. This credential type uses the environment variables injected by the workload identity mutating webhook to authenticate with Azure Key Vault. To see samples using one of the other approaches, refer to the ecosystem-specific client libraries.

Replace `<key-vault-url>` and `<secret-name>` with the appropriate values for your Key Vault and secret.

# [.NET](#tab/dotnet)
```csharp
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;

string keyVaultUrl = Environment.GetEnvironmentVariable("<key-vault-url>");
string secretName = Environment.GetEnvironmentVariable("<secret-name>");

var client = new SecretClient(
    new Uri(keyVaultUrl),
    new DefaultAzureCredential());

KeyVaultSecret secret = await client.GetSecretAsync(secretName);
```

# [C++](#tab/cpp)
```cpp
#include <cstdlib>
#include <azure/identity.hpp>
#include <azure/keyvault/secrets/secret_client.hpp>

using namespace Azure::Identity;
using namespace Azure::Security::KeyVault::Secrets;

int main()
{
  const char* keyVaultUrl = std::getenv("<key-vault-url>");
  const char* secretName = std::getenv("<secret-name>");
  auto credential = std::make_shared<DefaultAzureCredential>();

  SecretClient client(keyVaultUrl, credential);
  Secret secret = client.GetSecret(secretName).Value;

  return 0;
}
```

# [Go](#tab/go)
```go
package main

import (
   "context"
   "os"

   "github.com/Azure/azure-sdk-for-go/sdk/azidentity"
   "github.com/Azure/azure-sdk-for-go/sdk/security/keyvault/azsecrets"
    "k8s.io/klog/v2"
)

func main() {
   keyVaultUrl := os.Getenv("<key-vault-url>")
   secretName := os.Getenv("<secret-name>")

   credential, err := azidentity.NewDefaultAzureCredential(nil)
   if err != nil {
      klog.Fatal(err)
   }

   client, err := azsecrets.NewClient(keyVaultUrl, credential, nil)
   if err != nil {
      klog.Fatal(err)
   }

   secret, err := client.GetSecret(context.Background(), secretName, "", nil)
   if err != nil {
      klog.ErrorS(err, "failed to get secret", "keyvault", keyVaultUrl, "secretName", secretName)
      os.Exit(1)
   }
}
```

# [Java](#tab/java)
```java
import java.util.Map;

import com.azure.security.keyvault.secrets.SecretClient;
import com.azure.security.keyvault.secrets.SecretClientBuilder;
import com.azure.security.keyvault.secrets.models.KeyVaultSecret;
import com.azure.identity.DefaultAzureCredentialBuilder;
import com.azure.identity.DefaultAzureCredential;

public class App {
    public static void main(String[] args) {
        Map<String, String> env = System.getenv();
        String keyVaultUrl = env.get("<key-vault-url>");
        String secretName = env.get("<secret-name>");

        SecretClient client = new SecretClientBuilder()
                .vaultUrl(keyVaultUrl)
                .credential(new DefaultAzureCredentialBuilder().build())
                .buildClient();
        KeyVaultSecret secret = client.getSecret(secretName);
    }
}
```

# [Node.js](#tab/javascript)
```nodejs
import { DefaultAzureCredential } from "@azure/identity";
import { SecretClient } from "@azure/keyvault-secrets";

const main = async () => {
    const keyVaultUrl = process.env["<key-vault-url>"];
    const secretName = process.env["<secret-name>"];

    const credential = new DefaultAzureCredential();
    const client = new SecretClient(keyVaultUrl, credential);

    const secret = await client.getSecret(secretName);
}

main().catch((error) => {
    console.error("An error occurred:", error);
    process.exit(1);
});
```

# [Python](#tab/python)
```python
import os

from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential

def main():
    keyvault_url = os.getenv('<key-vault-url>', '')
    secret_name = os.getenv('<secret-name>', '')

    client = SecretClient(vault_url=keyvault_url, credential=DefaultAzureCredential())
    secret = client.get_secret(secret_name)

if __name__ == '__main__':
    main()
```

---

## Microsoft Authentication Library (MSAL)

The following client libraries are the **minimum** version required:

| Ecosystem | Library | Image | Example | Has Windows |
| --- | --- | --- | --- | --- |
| .NET | [Microsoft Authentication Library-for-dotnet](https://github.com/AzureAD/microsoft-authentication-library-for-dotnet) | `ghcr.io/azure/azure-workload-identity/msal-net:latest` | [Link](https://github.com/Azure/azure-workload-identity/tree/main/examples/msal-net/akvdotnet) | Yes |
| Go | [Microsoft Authentication Library-for-go](https://github.com/AzureAD/microsoft-authentication-library-for-go) | `ghcr.io/azure/azure-workload-identity/msal-go:latest` | [Link](https://github.com/Azure/azure-workload-identity/tree/main/examples/msal-go) | Yes |
| Java | [Microsoft Authentication Library-for-java](https://github.com/AzureAD/microsoft-authentication-library-for-java) | `ghcr.io/azure/azure-workload-identity/msal-java:latest` | [Link](https://github.com/Azure/azure-workload-identity/tree/main/examples/msal-java) | No |
| JavaScript | [Microsoft Authentication Library-for-js](https://github.com/AzureAD/microsoft-authentication-library-for-js) | `ghcr.io/azure/azure-workload-identity/msal-node:latest` | [Link](https://github.com/Azure/azure-workload-identity/tree/main/examples/msal-node) | No |
| Python | [Microsoft Authentication Library-for-python](https://github.com/AzureAD/microsoft-authentication-library-for-python) | `ghcr.io/azure/azure-workload-identity/msal-python:latest` | [Link](https://github.com/Azure/azure-workload-identity/tree/main/examples/msal-python) | No |

## Locate the projected service account token

When the mutating admission webhook injects the projected service account token volume into your pod, it also sets the `AZURE_FEDERATED_TOKEN_FILE` environment variable to the path of the token file.

Important

Read the token path from the `AZURE_FEDERATED_TOKEN_FILE` environment variable. Don't hard-code a path such as `/var/run/secrets/azure/tokens/azure-identity-token` in your application, container image, or deployment manifests. The mount path is an implementation detail of the webhook and can change. A hard-coded path also breaks when a pod projects more than one token, such as when a workload combines identity bindings with direct federation.

The Azure Identity client libraries and MSAL read `AZURE_FEDERATED_TOKEN_FILE` for you, so applications that use `DefaultAzureCredential` or `WorkloadIdentityCredential` don't need to handle the file directly. If your application reads the token itself, for example when it builds a custom client assertion, resolve the path from the environment variable at runtime.

Kubernetes refreshes the projected token in place before it expires. Read the file again each time you exchange the token for a Microsoft Entra token rather than caching its contents for the lifetime of the process.

## How it works

In this security model, the AKS cluster acts as the token issuer. Microsoft Entra ID uses OIDC to discover public signing keys and verify the authenticity of the service account token before exchanging it for a Microsoft Entra token. Your workload can exchange a service account token projected to its volume for a Microsoft Entra token using the Azure Identity client library or the MSAL.

[![Diagram of the AKS Microsoft Entra Workload ID security model.](media/workload-identity-overview/workload-id-model.png)](media/workload-identity-overview/workload-id-model.png#lightbox)

The following table describes the required OIDC issuer endpoints for Microsoft Entra Workload ID:

| Endpoint | Description |
| --- | --- |
| `{IssuerURL}/.well-known/openid-configuration` | Also known as the OIDC discovery document. This contains the metadata about the issuer's configurations. |
| `{IssuerURL}/openid/v1/jwks` | This contains the public signing key(s) that Microsoft Entra ID uses to verify the authenticity of the service account token. |

The following diagram summarizes the authentication sequence using OIDC:

[![Diagram of the AKS Microsoft Entra Workload ID OIDC authentication sequence.](media/workload-identity-overview/workload-id-oidc-authentication-model.png)](media/workload-identity-overview/workload-id-oidc-authentication-model.png#lightbox)

## Webhook certificate auto-rotation

Similar to other webhook add-ons, the [cluster certificate auto-rotation](certificate-rotation#certificate-autorotation-in-aks) operation rotates the workload identity webhook certificate.

## Service account labels and annotations

Microsoft Entra Workload ID supports the following mappings related to a service account:

- **One-to-one**, where a service account references a Microsoft Entra object.
- **Many-to-one**, where multiple service accounts reference the same Microsoft Entra object.
- **One-to-many**, where a service account references multiple Microsoft Entra objects by changing the client ID annotation. For more information, see [How to federate multiple identities with a Kubernetes service account](https://azure.github.io/azure-workload-identity/docs/faq.html#how-to-federate-multiple-identities-with-a-kubernetes-service-account).

Note

If you update the service account annotations, you must restart the pod for the changes to take effect.

If you've used [Microsoft Entra pod-managed identity](use-azure-ad-pod-identity), think of a service account as an Azure security principal, except that a service account is part of the core Kubernetes API, rather than a [Custom Resource Definition](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/) (CRD). The following sections describe a list of available labels and annotations that you can use to configure the behavior when exchanging the service account token for a Microsoft Entra access token.

### Service account annotations

All annotations are optional. If the annotation isn't specified, the default value is used.

| Annotation | Description | Default |
| --- | --- | --- |
| `azure.workload.identity/client-id` | Represents the Microsoft Entra application client ID to be used with the pod. |  |
| `azure.workload.identity/tenant-id` | Represents the Azure tenant ID where the Microsoft Entra application is registered. | AZURE\_TENANT\_ID environment variable extracted from `azure-wi-webhook-config` ConfigMap. |
| `azure.workload.identity/service-account-token-expiration` | Represents the `expirationSeconds` field for the projected service account token. It's an optional field that you configure to prevent any downtime caused by errors during service account token refresh. Kubernetes service account token expiry isn't correlated with Microsoft Entra tokens. Microsoft Entra tokens expire in 24 hours after they're issued. | 3600 Supported range is 3600-86400. |

### Pod labels

Note

For applications using Microsoft Entra Workload ID, it's required to add the label `azure.workload.identity/use: "true"` to the pod spec for AKS to move the workload identity to a *Fail Close* scenario to provide a consistent and reliable behavior for pods that need to use workload identity. Otherwise, the pods fail after they're restarted.

| Label | Description | Recommended value | Required |
| --- | --- | --- | --- |
| `azure.workload.identity/use` | This label is required in the pod template spec. Only pods with this label are mutated by the azure-workload-identity mutating admission webhook to inject the Azure specific environment variables and the projected service account token volume. | true | Yes |

### Pod annotations

All annotations are optional. If the annotation isn't specified, the default value is used.

| Annotation | Description | Default |
| --- | --- | --- |
| `azure.workload.identity/service-account-token-expiration` | See Service account annotations for details. **Pod annotations take precedence over service account annotations**. | 3600 Supported range is 3600-86400. |
| `azure.workload.identity/skip-containers` | Represents a semi-colon-separated list of containers to skip adding projected service account token volume. For example, `container1;container2`. | By default, the projected service account token volume is added to all containers if the pod is labeled with `azure.workload.identity/use: true`. |
| `azure.workload.identity/inject-proxy-sidecar` | Injects a proxy init container and proxy sidecar into the pod. The proxy sidecar is used to intercept token requests to IMDS and acquire a Microsoft Entra token on behalf of the user with federated identity credential. | false |
| `azure.workload.identity/proxy-sidecar-port` | Represents the port of the proxy sidecar. | 8000 |

## Use identity bindings and direct federation in the same workload

[Identity bindings](identity-bindings-concepts) extend workload identity to support large-scale AKS environments. Instead of creating a federated identity credential (FIC) for each cluster, identity bindings let multiple clusters share a single user-assigned managed identity through one FIC. When enabled, AKS routes pod token requests through an identity binding proxy webhook that handles token exchange on behalf of the workload.

A projected service account token has a single audience. When identity bindings are enabled, the identity binding webhook sets the default token referenced by `AZURE_FEDERATED_TOKEN_FILE` to the audience `api://AKSIdentityBinding`, which the identity binding proxy uses.

Direct Microsoft Entra Workload ID federation (without identity bindings) requires a token with the audience `api://AzureADTokenExchange`. Reusing the identity binding token file for direct federation fails with `AADSTS700212` because the federated identity credential audience doesn't match the token audience.

To use identity bindings for one managed identity and direct federation for another in the same workload, project a second service account token with the `api://AzureADTokenExchange` audience and point the direct federation code at that file:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: workload-with-ib-and-direct-fic
  labels:
    azure.workload.identity/use: "true"
spec:
  serviceAccountName: workload-sa
  containers:
  - name: app
    image: <image>
    volumeMounts:
    - name: direct-fic-token
      mountPath: /var/run/secrets/direct-fic
      readOnly: true
    env:
    - name: DIRECT_FIC_TOKEN_FILE
      value: /var/run/secrets/direct-fic/token
  volumes:
  - name: direct-fic-token
    projected:
      sources:
      - serviceAccountToken:
          path: token
          audience: api://AzureADTokenExchange
          expirationSeconds: 3600
```

Use `AZURE_FEDERATED_TOKEN_FILE` for the identity binding flow and the custom token file, such as `DIRECT_FIC_TOKEN_FILE`, for the direct federated identity credential flow.

## Migrate to Microsoft Entra Workload ID

You can configure clusters already running a pod-managed identity to use Microsoft Entra Workload ID using one of two ways:

- Use the same configuration you implemented for pod-managed identity. You can annotate the service account within the namespace with the identity to enable Microsoft Entra Workload ID and inject the annotations into the pods.
- Rewrite your application to use the latest version of the Azure Identity client library.

To help streamline and ease the migration process, we developed a migration sidecar that converts the Instance Metadata Service (IMDS) transactions your application makes over to [OIDC](/en-us/azure/active-directory/develop/v2-protocols-oidc). The migration sidecar isn't intended to be a long-term solution, but a way to get up and running quickly on Microsoft Entra Workload ID. Running the migration sidecar within your application proxies the application IMDS transactions over to OIDC. The alternative approach is to upgrade to a supported version of the [Azure Identity](/en-us/azure/active-directory/develop/reference-v2-libraries) client library, which supports OIDC authentication.

The following table summarizes our migration or deployment recommendations for your AKS cluster:

| Scenario | Description |
| --- | --- |
| New AKS Automatic cluster | Workload identity and the OIDC issuer are preconfigured. No cluster-level migration or configuration steps are required. Configure your application's service account and federated credential, then use the Azure Identity client library. |
| New or existing AKS Standard cluster running a [supported version](/en-us/azure/active-directory/develop/reference-v2-libraries) of the Azure Identity client library | No migration steps are required. Sample deployment resources: [Deploy and configure Microsoft Entra Workload ID on a new cluster](workload-identity-deploy-cluster) |
| New or existing cluster deployment runs an unsupported version of Azure Identity client library | Update container image to use a supported version of the Azure Identity client library, or use the [migration sidecar](workload-identity-migrate-from-pod-identity). |