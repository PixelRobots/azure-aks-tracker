---
layout: Conceptual
title: Workload identity federation in Azure Arc-enabled Kubernetes (preview) - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/conceptual-workload-identity
breadcrumb_path: ../../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/146/azure-arc/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/5c778dec-0625-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: davidsmatlak
learn_banner_products:
- azure
ms.reviewer: davidsmatlak
ms.author: davidsmatlak
ms.service: azure-arc
ms.subservice: azure-arc-kubernetes
ms.date: 2024-11-11T00:00:00.0000000Z
ms.topic: concept-article
ms.custom:
- ignite-2024
description: Learn how workload identity federation can be used with Azure Arc-enabled Kubernetes clusters.
locale: en-us
document_id: 1a7b477c-fa2d-fbf7-6fa0-a3373e8aabd0
document_version_independent_id: c72ef843-33d2-39f3-0326-3094619151c0
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/conceptual-workload-identity.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/conceptual-workload-identity
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/conceptual-workload-identity.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/57eae307-c3a1-4cac-b645-1a899934bac8
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/ee561821-1ac7-45a8-9409-6ba5eb7a5b97
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: e51fed50-d8a4-76e8-b133-5baf21d356cd
---

# Workload identity federation in Azure Arc-enabled Kubernetes (preview) - Azure Arc | Microsoft Learn

Software workloads running on Kubernetes clusters need an identity in order to authenticate and access resources or communicate with other services. For a software workload running outside of Azure, you need to use application credentials, such as a secret or certificate, to access resources that are protected by Microsoft Entra (such as Azure Key Vault or Azure Blob storage). These credentials pose a security risk and have to be stored securely and rotated regularly. You also run the risk of service downtime if the credentials expire.

Workload identity federation lets you configure a [user-assigned managed identity](/en-us/entra/identity/managed-identities-azure-resources/how-manage-user-assigned-managed-identities) or [app registration](/en-us/entra/identity-platform/app-objects-and-service-principals) in Microsoft Entra ID to trust tokens from an external identity provider (IdP), such as Kubernetes. The user-assigned managed identity or app registration in Microsoft Entra ID becomes an identity for software workloads running on Arc-enabled Kubernetes clusters. Once that trust relationship is created, your workload can exchange trusted tokens from the Arc-enabled Kubernetes clusters for access tokens from Microsoft identity platform. Your software workload uses that access token to access the resources protected by Microsoft Entra. With workload identity federation, you can thus eliminate the maintenance burden of manually managing credentials, and eliminate the risk of leaking secrets or having certificates expire.

## How workload identity works with Azure Arc-enabled Kubernetes clusters

Workload identity support for Azure Arc enabled Kubernetes uses [Service Account Token Volume Projection](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#serviceaccount-token-volume-projection) (that is, a service account) so that workload pods can use a Kubernetes identity. A Kubernetes token is issued, and [OpenID Connect (OIDC) federation](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#openid-connect-tokens) lets Kubernetes applications access Azure resources securely with Microsoft Entra ID, based on annotated service accounts.

The Arc-enabled Kubernetes cluster acts as the token issuer. Microsoft Entra ID uses OIDC to discover public signing keys and verify the authenticity of the service account token before exchanging it for a Microsoft Entra token. Your workload can exchange a service account token projected to its volume for a Microsoft Entra token using the Azure Identity client library or the Microsoft Authentication Library (MSAL).

![Diagram showing the process flow for the workload identity feature for Azure Arc-enabled Kubernetes.](media/conceptual-workload-identity/workload-identity-arc-enabled-kubernetes.jpg)

The following table shows the required OIDC issuer endpoints for Microsoft Entra Workload ID.

| Endpoint | Description |
| --- | --- |
| `{IssuerURL}/.well-known/openid-configuration` | Also known as the OIDC discovery document. Contains the metadata about the issuer's configurations. |
| `{IssuerURL}/openid/v1/jwks` | Contains the public signing key(s) that Microsoft Entra ID uses to verify the authenticity of the service account token. |

## Service account labels and annotations

[Microsoft Entra Workload ID](/en-us/azure/active-directory/develop/workload-identities-overview) supports the following mappings related to a service account:

- **One-to-one**: A service account references a Microsoft Entra object.
- **Many-to-one**: Multiple service accounts reference the same Microsoft Entra object.
- **One-to-many**: A service account references multiple Microsoft Entra objects by changing the client ID annotation. For more information, see [How to federate multiple identities with a Kubernetes service account](https://azure.github.io/azure-workload-identity/docs/faq.html#how-to-federate-multiple-identities-with-a-kubernetes-service-account).

## Requirements

Azure Arc-enabled Kubernetes clusters support Microsoft Entra Workload Identity [starting with agent version 1.21](release-notes).

To use the workload identity feature, you must have Azure CLI version 2.64 or higher, and `az connectedk8s` version 1.10.0 or higher. Be sure to update your Azure CLI version before updating your `az connectedk8s` version. If you use Azure Cloud Shell, the latest version of Azure CLI will be installed.

Microsoft Entra Workload ID works especially well with the [Azure Identity client libraries](/en-us/azure/aks/workload-identity-overview?tabs=dotnet#azure-identity-client-libraries) or the [Microsoft Authentication Library (MSAL)](/en-us/azure/active-directory/develop/msal-overview) collection, together with application registration. Your workload can use any of these libraries to seamlessly authenticate and access Azure cloud resources.

For more information about integration with popular libraries, see [Use Microsoft Entra Workload ID with AKS](/en-us/azure/aks/workload-identity-overview?bs=dotnet#azure-identity-client-libraries).

## Current limitations

Keep in mind the following current limitations:

- A maximum of 20 federated identity credentials per managed identity can be configured.
- After the federal identity credential is initially added, it takes a few seconds for it to be propagated.
- Creation of federated identity credentials is not supported on user-assigned managed identities in [certain regions](/en-us/entra/workload-id/workload-identity-federation-considerations#unsupported-regions-user-assigned-managed-identities).