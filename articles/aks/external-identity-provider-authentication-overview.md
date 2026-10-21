---
layout: Conceptual
title: Use External Identity Providers with AKS Structured Authentication (Preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/external-identity-provider-authentication-overview
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
description: Learn how to use external identity providers for Azure Kubernetes Service (AKS) control plane authentication using structured authentication, enabling integration with your organization's existing identity infrastructure.
author: shashankbarsin
ms.author: shasb
ms.topic: overview
ms.subservice: aks-security
ms.custom: preview
ms.date: 2026-01-26T00:00:00.0000000Z
locale: en-us
document_id: e320eea3-ca4c-4c04-5587-eab632b7a366
document_version_independent_id: 3696a33c-ace1-070b-b777-e5c34bafabab
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/external-identity-provider-authentication-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/external-identity-provider-authentication-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/external-identity-provider-authentication-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/c77bc83e-f0b0-4b63-836e-6630e606bf7c
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/b98eda1f-6af8-444f-bbfb-7f2366948cbc
platformId: bf72d89b-6b04-c269-3970-abd644700d0a
---

# Use External Identity Providers with AKS Structured Authentication (Preview) - Azure Kubernetes Service | Microsoft Learn

Azure Kubernetes Service (AKS) supports structured authentication, which allows you to configure external identity providers for authenticating users to the Kubernetes API server. This feature is based on the upstream [Kubernetes structured authentication configuration](https://kubernetes.io/blog/2024/04/25/structured-authentication-moves-to-beta/). AKS implements this functionality through JSON Web Token (JWT) authenticators that validate tokens from external identity providers according to your configuration. With structured authentication, organizations can integrate AKS with their existing identity infrastructure beyond Microsoft Entra ID.

This article provides an overview of how to use external identity providers with AKS structured authentication, including key concepts, security considerations, and next steps for configuration.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Benefits of external identity provider authentication

Structured authentication extends AKS beyond traditional Microsoft Entra ID integration by supporting industry-standard OpenID Connect (OIDC) identity providers. This feature allows you to:

- Authenticate users with external identity providers like Google, GitHub, or any OIDC-compliant provider.
- Maintain centralized identity management across your organization.
- Implement custom claim validation and user mapping rules.
- Support multiple identity providers simultaneously on a single cluster.

## External identity provider authentication flow

When a user attempts to access the Kubernetes API server using structured authentication with an external identity provider, the authentication and authorization flow is as follows:

- **Authentication**: The following steps validate the user's identity:
    - **Token presentation**: The user presents a JWT token from their configured identity provider.
    - **Token validation**: The API server validates the token's signature, issuer, audience, and expiration.
    - **Claim processing**: Custom claim validation rules are applied to ensure the token meets your requirements.
    - **User mapping**: Claims are mapped to Kubernetes user identity (username, groups, and extra attributes).
- **Authorization**: Standard Kubernetes Role-Based Access Control (RBAC) determines what actions the authenticated user can perform.

[![Conceptual diagram showing how external identity provider-based authentication works with AKS clusters.](media/external-identity-provider-authentication/external-identity-provider-authentication-overview.png)](media/external-identity-provider-authentication/external-identity-provider-authentication-overview.png#lightbox)

## Supported identity providers

While AKS structured authentication allows any OIDC-compliant identity provider, common providers include:

- **GitHub**: Authenticate using GitHub identities or GitHub Actions.
- **Google OAuth 2.0**: Use Google accounts for authentication.
- **Generic OIDC providers**: Any provider implementing OIDC standards.
- **Custom identity solutions**: Organization-specific OIDC implementations.

Note

Microsoft Entra ID isn't supported as an external identity provider through structured authentication. Use the existing [Microsoft Entra integration](entra-id-control-plane-authentication) for Microsoft Entra ID authentication.

### Requirements for external identity providers

External identity providers must meet the following requirements to work with AKS structured authentication:

- Support OIDC standards.
- Provide publicly accessible OIDC discovery endpoints.
- Issue JWT tokens with appropriate claims.
- Be accessible from AKS cluster nodes for token validation.

## JWT authenticators for AKS structured authentication

A JWT authenticator is a configuration object that defines how AKS validates and processes tokens from an external identity provider. For example, AKS expects an ID token (JWT) whose `aud` (audience) claim matches the audience value you configure for the authenticator, such as `"my-api"`, or an OAuth client ID. Each JWT authenticator includes the following components:

- **Issuer configuration**: Specifies the OIDC issuer URL and the expected audience values for tokens.
- **Claim validation rules**: Uses CEL (Common Expression Language) expressions to enforce custom validation logic on token claims.
- **Claim mappings**: Defines how JWT claims are mapped to Kubernetes user attributes such as username, groups, and extra fields.
- **User validation rules**: Applies extra validation logic after claim mapping to further restrict or allow access.

## CEL expressions for claim validation and mapping

Structured authentication uses [CEL](https://kubernetes.io/docs/reference/using-api/cel/) expressions for flexible claim validation and mapping. CEL provides a secure sandbox environment for evaluating custom logic against JWT claims.

Example CEL expressions:

```cel
// Validate that the 'sub' claim exists
has(claims.sub)

// Map username with AKS prefix
'aks:jwt:' + claims.sub

// Map groups from comma-separated string
claims.groups.split(',').map(g, 'aks:jwt:' + g)

// Conditional mapping based on claim verification
'aks:jwt:' + (claims.email_verified ? claims.email : claims.sub)
```

## Security best practices

Keep the following security best practices in mind when using external identity providers with AKS structured authentication:

- **Use strong claim validation**: Implement comprehensive validation rules to ensure only authorized tokens are accepted.
- **Limit token scope**: Configure your identity provider to issue tokens with minimal necessary claims.
- **Regular rotation**: Rotate client secrets and certificates regularly.
- **Monitor access**: Enable [resource logs](monitor-aks-reference#resource-logs) and turn on `kube-apiserver` logs to inspect any potential issues with the configured JWT authenticators and track authentication events.
- **Test configurations**: Validate your JWT authenticator configuration in a nonproduction environment first.

## Security considerations

Keep the following security considerations in mind when using external identity providers with AKS structured authentication:

- **Prefix requirements**: All usernames and groups mapped through structured authentication must be prefixed with `aks:jwt:` to prevent conflicts with other authentication methods and system accounts.
- **Network access**: Identity provider endpoints must be accessible from:
    - AKS cluster nodes for token validation.
    - Client systems for token acquisition.
    - Any network paths involved in the authentication flow.
- **Validation layers**: Structured authentication provides multiple validation layers:
    - **Token signature validation** ensures token authenticity.
    - **Standard claim validation** verifies issuer, audience, and expiration.
    - **Custom claim validation** applies your organization's specific requirements.
    - **User validation** final checks after claim mapping.