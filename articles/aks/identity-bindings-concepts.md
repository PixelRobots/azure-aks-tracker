---
layout: Conceptual
title: Identity bindings for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/identity-bindings-concepts
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
description: Learn about identity bindings on AKS and how they extend Microsoft Entra workload identity for large scale scenarios that exceed federated identity credential limits.
ms.topic: concept-article
ms.subservice: aks-security
ms.date: 2026-09-02T00:00:00.0000000Z
ai-usage: ai-assisted
author: shashankbarsin
ms.author: shasb
ms.reviewer: schaffererin
locale: en-us
document_id: a4730756-a87a-ce23-b88e-5fc069df2874
document_version_independent_id: 0f41fd06-fa1e-c762-2ae2-8535c6964203
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/identity-bindings-concepts.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/identity-bindings-concepts
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/identity-bindings-concepts.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 2e4fc901-489b-6b93-9f88-a3064fabe4a2
---

# Identity bindings for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Identity binding is a feature for Azure Kubernetes Service (AKS) that extends the existing [workload identity feature](workload-identity-overview) to address scale limitations around federated identity credentials (FICs) on user-assigned managed identities (UAMIs). With [workload identity for AKS](workload-identity-overview), a single UAMI can't have more than **20 FICs**. Large Kubernetes platform deployments might span more than 20 clusters (each cluster has a unique issuer) or have many `<namespace, service-account>` combinations that require mapping to the same UAMI, exhausting the FIC quota.

Identity bindings address this limitation by allowing multiple AKS clusters to share the same UAMI using a single FIC per UAMI. This approach significantly increases scalability and simplifies operations for large-scale AKS environments that require Microsoft Entra authentication.

## What is an identity binding?

An identity binding is a resource mapping between **one UAMI** and **one AKS cluster with workloads that need Microsoft Entra authentication with that identity**.

Let's say you have a UAMI, `MI-1`, needed by workloads running in clusters `AKS-cluster-1`, `AKS-cluster-2`, and `AKS-cluster-3`. You can create three identity bindings to map `MI-1` to each of these clusters:

- **Identity binding `IB-A`** mapping `MI-1` to `AKS-cluster-1`.
- **Identity binding `IB-B`** mapping `MI-1` to `AKS-cluster-2`.
- **Identity binding `IB-C`** mapping `MI-1` to `AKS-cluster-3`.

Even if the same UAMI is needed across multiple clusters, only **one** federated identity credential is created per UAMI, addressing the previous 20 FIC limitation. When you create an identity binding, AKS automatically creates (or reuses) the single FIC for that UAMI. The following diagrams illustrate the differences between the previous workload identity model and the new identity bindings model:

[![Screenshot of two diagrams with one showing identity bindings mapping a UAMI to multiple AKS clusters while using a single FIC and the other showing workload identity mappings.](media/identity-bindings/identity-binding-vs-workload-identity.png)](media/identity-bindings/identity-binding-vs-workload-identity.png#lightbox)

After you create the identity binding and the UAMI is authorized for the cluster, you must define `ClusterRole` and `ClusterRoleBinding` objects that specify the namespaces and service accounts (granularly or collectively) permitted to use that managed identity for Microsoft Entra token acquisition.

## Use identity bindings with Azure Identity client libraries

To use identity bindings with your application workloads, follow these steps:

1. Ensure you're using the minimum required Azure Identity package.
2. Use `WorkloadIdentityCredential` and opt into the feature. This feature isn't supported in `ManagedIdentityCredential` or `DefaultAzureCredential`.

The following table outlines the minimum package versions and how to enable identity bindings for each supported language:

| Language | Package | Minimum Version | How to enable |
| --- | --- | --- | --- |
| .NET | [Azure.Identity](/en-us/dotnet/api/overview/azure/identity-readme)or[Azure.Core](/en-us/dotnet/api/overview/azure/core-readme) | **v1.18.0-beta.3** onlyor**v1.55.0** or later | `WorkloadIdentityCredential` identity binding mode is disabled by default. Set `WorkloadIdentityCredentialOptions.IsAzureProxyEnabled` to `true`. |
| Go | [azidentity](https://pkg.go.dev/github.com/Azure/azure-sdk-for-go/sdk/azidentity) | **v1.14.0-beta.3** or later | Set `WorkloadIdentityCredentialOptions.EnableAzureProxy` to `true`. |
| Java | [azure-identity](/en-us/java/api/overview/azure/identity-readme) | **v1.19.0-beta.2** or later | Call `enableAzureProxy()` on `WorkloadIdentityCredentialBuilder`. |
| JavaScript | [@azure/identity](/en-us/javascript/api/overview/azure/identity-readme) | **4.14.0-beta.2** or later | Set `enableAzureProxy` to `true` in `WorkloadIdentityCredentialOptions`. |
| Python | [azure-identity](/en-us/python/api/overview/azure/identity-readme) | **1.26.0b2** or later | Set `enable_azure_proxy=True` in `WorkloadIdentityCredential`. |

Note

For .NET, identity bindings support is available exclusively in **Azure.Identity v1.18.0-beta.3** or, as an alternative, in **Azure.Core v1.55.0** or later. No other version of Azure.Identity currently includes this feature.

## Frequently asked questions (FAQs)

### Is identity sameness (namespace and service account sameness) required across clusters using the same UAMI?

No. Identity bindings don't require namespace/service account sameness. It's up to the cluster operator to explicitly authorize the namespaces and service accounts inside each cluster that are allowed to use the managed identity through role-based access control (RBAC).

### Can I create multiple identity bindings for the same UAMI?

Yes. The OIDC issuer URL maintained by AKS for that UAMI is the same across all identity bindings referencing the same managed identity.

### What permissions are required to create identity bindings?

**Required Azure Resource Manager (ARM) permissions**:

- `Microsoft.ContainerService/managedClusters/identityBindings/*`
- `Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials/*`

Note

When you create an identity binding, AKS automatically creates a FIC. If the caller lacks permission to create FIC resources, the identity binding creation fails.

**Required Kubernetes permissions**:

- Ability to create `ClusterRole` and `ClusterRoleBinding` objects (cluster admin or equivalent).

### What happens to the auto-created FIC after deleting all identity bindings for a UAMI?

There's no automatic garbage collection of the FIC today when the last identity binding referencing a UAMI is deleted. Operators should manually clean up the FIC only after verifying all identity bindings for that UAMI have been removed to avoid disrupting remaining dependencies.

### What networking prerequisites exist for identity bindings?

Previously, workload identity required egress to `login.microsoftonline.com` so workloads could exchange service account tokens for Microsoft Entra access tokens. With identity bindings, token exchange requests route through a cluster-specific identity binding proxy operated by AKS. Direct egress to `login.microsoftonline.com` for token exchange isn't required.

### What limitations exist for identity bindings?

Identity bindings aren't yet supported on clusters configured with [API server virtual network integration](/en-us/azure/aks/api-server-vnet-integration).