---
layout: Conceptual
title: Security overview for Azure Container Registry - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-security-overview
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
author: msmbaldwin
learn_banner_products:
- azure
manager: kumud
ms.reviewer: kumud
ms.author: mbaldwin
ms.service: azure-container-registry
description: Understand the Azure Container Registry security model, shared responsibility, threat surface, and defense-in-depth layers that protect your registry.
ms.topic: concept-article
ms.date: 2026-09-28T00:00:00.0000000Z
ai-usage: ai-generated
locale: en-us
document_id: b89cb044-b30d-f994-dd07-20da8b39c424
document_version_independent_id: e27e6c24-6409-6895-f2d4-51453a0c36fe
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-security-overview.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-security-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-security-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/062d60c9-ee0f-402e-a046-b4e67c3572d6
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/17d3b3f6-a66e-4c69-9774-14a73c38e669
platformId: db5d4574-8c95-22fe-ba76-5fb881a2b01e
---

# Security overview for Azure Container Registry - Azure Container Registry | Microsoft Learn

Azure Container Registry stores and distributes the container images and related artifacts that run across your compute platforms. Because those platforms treat the registry as a trusted source, the registry is part of your software supply chain: an attacker who tampers with an image, steals a credential, or reaches an unprotected registry can spread a compromise to every workload that pulls from it.

This article explains how registry security works so that you can reason about which controls apply to your environment. It covers the shared responsibility model, the registry threat surface, and the defense-in-depth layers that protect a registry. For the prescriptive checklist of what to configure and where to do it, see [Secure your Azure Container Registry deployment](secure-container-registry).

## Shared responsibility

Registry security is a shared responsibility between Microsoft and you.

Microsoft operates the registry service. Microsoft secures the physical infrastructure, the host platform, and the service software, and encrypts all registry content at rest by default with Microsoft-managed keys.

You control how the registry is exposed and who can reach it. You decide which identities authenticate, whether the registry is reachable from the public internet, whether you supply your own encryption key, how you enforce image integrity, and how you monitor and govern registry activity. Most registry compromises trace back to configuration you own, such as a registry-wide credential left enabled or a registry left open to the internet, rather than to the underlying service.

## The registry threat surface

A registry faces threats at both its access boundary and its content. Understanding these threats clarifies why each defense-in-depth layer exists.

- **Unauthorized access**: An attacker who obtains registry credentials or reaches an unauthenticated registry can pull proprietary images or push malicious ones. Shared, registry-wide credentials such as the admin account widen this risk because their use isn't attributable to an individual identity.
- **Public network exposure**: A registry is reachable over the public internet by default. An internet-exposed registry is discoverable and subject to credential-based attacks from anywhere.
- **Supply-chain tampering**: An attacker who modifies or substitutes an image injects vulnerable or malicious code into every workload that later pulls it. Without image integrity controls, a consumer can't distinguish a trusted image from a tampered one.
- **Data exfiltration**: An identity with export or pull rights can move proprietary images out of a controlled environment to an external registry.
- **Loss of availability or content**: A regional outage can interrupt image pulls, and an accidental or malicious deletion can remove images that running workloads depend on.

## Defense in depth

No single control secures a registry. The registry security model layers independent controls so that a gap in one layer doesn't expose the registry. Each layer below maps to a section of the [security checklist](secure-container-registry), which prescribes the specific settings to apply.

### Identity and access

Azure Container Registry authenticates through Microsoft Entra ID and authorizes through Azure role-based access control. The registry separates control-plane access, which manages the registry resource, from data-plane access, which pulls and pushes images. Entra identities make access attributable and let you apply least-privilege roles, scope permissions to individual repositories, and govern access with Conditional Access. Preferring managed identities and Entra-based authentication over shared credentials such as the admin account is the foundation of registry security. For the concepts behind registry authentication, see [Authentication options for Azure Container Registry](container-registry-authentication).

### Network isolation

Restricting how the registry is reached shrinks its attack surface. A private endpoint gives the registry a private IP address in your virtual network and keeps pull and push traffic off the public internet, and IP network rules limit public access to known address ranges. These controls, available in the Premium service tier, turn an internet-reachable registry into one that only trusted networks can resolve and reach. For the private-connectivity concept, see [Connect privately to a container registry](container-registry-private-endpoints).

### Content integrity and data protection

Protecting registry content spans encryption and image trust. All content is encrypted at rest by default, and a customer-managed key gives you control over the encryption key when your compliance requirements demand it. Signing images and verifying those signatures before deployment protects image integrity, so that consumers accept only images from a trusted source. Locking production images and disabling artifact export further protect content from mutation and exfiltration. For image signing, see [Content trust in Azure Container Registry](container-registry-content-trust).

### Detection and monitoring

Visibility into registry activity lets you detect misuse and investigate incidents. The registry records authentication attempts and repository operations as Azure Monitor resource logs, which you route to a Log Analytics workspace for retention and analysis. Vulnerability scanning through Microsoft Defender for Cloud assesses pushed images so that known vulnerabilities surface before an image is deployed. For registry monitoring concepts, see [Monitor Azure Container Registry](monitor-container-registry).

### Governance and compliance

Consistent security depends on enforcing configuration across every registry, not one at a time. Azure Policy audits and enforces registry settings such as disabled anonymous pull and disabled public network access at scale, and maps those controls to the regulatory standards your organization must meet. For the available controls, see [Azure Policy Regulatory Compliance controls for Azure Container Registry](security-controls-policy).

### Resilience

Availability and recoverability protect against outages and accidental loss. Geo-replication keeps a single logical registry available from multiple regions, and soft delete retains deleted artifacts for a recovery window. Planning these controls together, and understanding how they interact, keeps images reachable and recoverable. For the geo-replication concept, see [Geo-replication in Azure Container Registry](container-registry-geo-replication).