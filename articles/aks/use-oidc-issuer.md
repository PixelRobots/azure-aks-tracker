---
layout: Conceptual
title: Use the OpenID Connect (OIDC) Issuer in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-oidc-issuer
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
description: Learn how to use the OpenID Connect (OIDC) issuer in Azure Kubernetes Service (AKS), including AKS Automatic where OIDC issuer is preconfigured and AKS Standard where you can enable it based on cluster version and configuration.
author: schaffererin
ms.author: yuewu2
ms.topic: how-to
ms.subservice: aks-security
ms.custom: devx-track-azurecli
ms.date: 2025-10-16T00:00:00.0000000Z
locale: en-us
document_id: 4c8b64cd-3def-2ed6-d23c-ad1ddf0e3981
document_version_independent_id: c88592dc-18db-ebab-bc51-e152996b5c10
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-oidc-issuer.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/use-oidc-issuer
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-oidc-issuer.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 14b8ec39-bd4a-6d69-a4c6-cbf734bc01a8
---

# Use the OpenID Connect (OIDC) Issuer in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

**Applies to**: ✔️ AKS Automatic ✔️ AKS Standard

This article describes how to create and manage an OpenID Connect (OIDC) issuer for your Azure Kubernetes Service (AKS) cluster. The OIDC issuer enables your AKS cluster to integrate with identity providers like Microsoft Entra ID, so you can securely authenticate and provide single sign-on (SSO) capabilities for applications running within the cluster.

For most production workloads, AKS Automatic is the recommended default AKS experience. AKS Automatic is production ready by default and includes OIDC issuer as a preconfigured security capability. In AKS Standard, OIDC issuer behavior depends on Kubernetes version and cluster state, and you can enable it manually when required.

To learn more about AKS Automatic, see [What is Azure Kubernetes Service (AKS) Automatic?](intro-aks-automatic)

## OIDC issuer in AKS Automatic and AKS Standard

Both AKS cluster modes support OIDC issuer, but setup differs:

- **AKS Automatic**: OIDC issuer is preconfigured.
- **AKS Standard**: You might need to explicitly enable OIDC issuer, depending on version and whether it's already configured.

For most production scenarios, start with AKS Automatic to use production-ready defaults and reduce operational overhead.

## About OpenID Connect (OIDC) on AKS

[OpenID Connect](/en-us/azure/active-directory/fundamentals/auth-oidc) (OIDC) extends the OAuth 2.0 authorization protocol for use as another authentication protocol issued by Microsoft Entra ID. You can use OIDC to enable single sign-on (SSO) between OAuth-enabled applications on your Azure Kubernetes Service (AKS) cluster using a security token called an ID token. You can enable the OIDC issuer on your AKS clusters, which allows Microsoft Entra ID (or another cloud provider's identity and access management platform) to discover the API server's public signing keys.

## Prerequisites

Platform requirements:

- Azure CLI version 2.42.0 or later (`az --version` to check version, [install or upgrade Azure CLI](/en-us/cli/azure/install-azure-cli) if needed).
- Kubernetes version 1.22 or later.

Version-specific behavior (AKS Standard):

- OIDC issuer is enabled by default (no `--enable-oidc-issuer` flag needed) for newly created AKS clusters on Kubernetes version 1.34 or later.
- For existing clusters, OIDC isn't enabled by default regardless of Kubernetes version and requires manual enablement.
- Token auto-extension disabled (`--service-account-extend-token-expiration=false`) for Kubernetes version 1.30.0 or later.
- If OIDC issuer wasn't previously configured, manual enablement is required for Kubernetes versions earlier than 1.34.
- Projected service account tokens are required for Kubernetes version 1.30 or later clusters.

Important considerations:

- You can't disable OIDC issuer once enabled.
- Enabling OIDC issuer on existing clusters requires API server restart (brief downtime).
- Maximum token lifetime is 24 hours (one day).

## Create an AKS cluster with the OIDC issuer

### AKS Automatic (recommended default for production)

In AKS Automatic, the OIDC issuer is preconfigured. You don't need a separate OIDC issuer enablement step.

Create an AKS Automatic cluster by following the quickstart:

- [Create an Azure Kubernetes Service (AKS) Automatic cluster](automatic/quick-automatic-managed-network)

### AKS Standard

Create an AKS Standard cluster using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--enable-oidc-issuer` parameter.

```azurecli
# Set environment variables
RESOURCE_GROUP=<your-resource-group-name>
CLUSTER_NAME=<your-aks-cluster-name>
    
# Create the AKS Standard cluster with OIDC issuer enabled
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --node-count 1 \
    --enable-oidc-issuer \
    --generate-ssh-keys
```

Note

On AKS Standard clusters created with Kubernetes version 1.34 or later, the OIDC issuer is enabled by default for new clusters.

## Enable OIDC issuer on an existing AKS Standard cluster

Enable the OIDC issuer on an existing AKS Standard cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--enable-oidc-issuer` parameter.

```azurecli
# Set environment variables
RESOURCE_GROUP=<your-resource-group-name>
CLUSTER_NAME=<your-aks-cluster-name>

# Enable the OIDC issuer on the existing AKS Standard cluster
az aks update \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --enable-oidc-issuer 
```

## Get the OIDC issuer URL

Get the OIDC issuer URL using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

```azurecli
# Set environment variables
RESOURCE_GROUP=<your-resource-group-name>
CLUSTER_NAME=<your-aks-cluster-name>

# Get the OIDC issuer URL
az aks show \
    --name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --query "oidcIssuerProfile.issuerUrl" \
    -o tsv
```

By default, the issuer uses the base URL `https://{region}.oic.prod-aks.azure.com`, where the value for `{region}` matches the location where you deployed the AKS cluster.

## Rotate the OIDC signing key

Important

Keep the following considerations in mind when rotating OIDC signing keys:

- If you want to invalidate the old key immediately after key rotation, you must rotate the OIDC key twice and restart the pods using projected service account tokens.
- Both old and new keys remain valid for 24 hours after rotation.
- You need to refresh the token manually every 24 hours (unless you're using [Azure Identity client libraries](workload-identity-overview#azure-identity-client-libraries), which refresh automatically).

Rotate the OIDC key using the [`az aks oidc-issuer`](/en-us/cli/azure/aks/oidc-issuer) command.

```azurecli
# Set environment variables
RESOURCE_GROUP=<your-resource-group-name>
CLUSTER_NAME=<your-aks-cluster-name>

# Rotate the OIDC signing keys
az aks oidc-issuer rotate-signing-keys \
    --name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP
```

## Get the discovery document

Go to your OIDC issuer URL in your browser and add `/.well-known/openid-configuration` to the URL.

Example: `https://eastus.oic.prod-aks.azure.com/.well-known/openid-configuration`

Your output should resemble the following example output:

```output
{
  "issuer": "https://eastus.oic.prod-aks.azure.com/ffffffff-eeee-dddd-cccc-bbbbbbbbbbb0/00000000-0000-0000-0000-000000000000/",
  "jwks_uri": "https://eastus.oic.prod-aks.azure.com/00000000-0000-0000-0000-000000000000/00000000-0000-0000-0000-000000000000/openid/v1/jwks",
  "response_types_supported": [
    "id_token"
  ],
  "subject_types_supported": [
    "public"
  ],
  "id_token_signing_alg_values_supported": [
    "RS256"
  ]
}
```

## Get the JWK Set document

In your browser, go to the **jwks\_uri** from the discovery document.

For example: `https://eastus.oic.prod-aks.azure.com/00000000-0000-0000-0000-000000000000/00000000-0000-0000-0000-000000000000/openid/v1/jwks`

Your output should resemble the following example output:

```output
{
  "keys": [
    {
      "use": "sig",
      "kty": "RSA",
      "kid": "xxx",
      "alg": "RS256",
      "n": "xxxx",
      "e": "AQAB"
    },
    {
      "use": "sig",
      "kty": "RSA",
      "kid": "xxx",
      "alg": "RS256",
      "n": "xxxx",
      "e": "AQAB"
    }
  ]
}
```

Note

During key rotation, the discovery document includes one extra key.