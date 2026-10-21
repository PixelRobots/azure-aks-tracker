---
layout: Conceptual
title: Overview of Signing and Verifying OCI Artifacts - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/overview-sign-verify-artifacts
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
author: yizha1
learn_banner_products:
- azure
manager: kumud
ms.reviewer: kumud
ms.author: yizha1
ms.service: azure-container-registry
description: Learn how to sign and verify container images and other OCI artifacts to help ensure integrity and authenticity across the software supply chain.
ms.topic: overview
ms.date: 2025-09-05T00:00:00.0000000Z
locale: en-us
document_id: a96554ed-6df4-3461-8ea0-9b85475065c5
document_version_independent_id: a7c98b34-18e4-dbb9-85de-bb3cc6961650
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/overview-sign-verify-artifacts.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/overview-sign-verify-artifacts
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/overview-sign-verify-artifacts.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/54918a83-0404-4863-9c91-715186c1f582
- https://authoring-docs-microsoft.poolparty.biz/devrel/9bdc1705-9b40-49d6-8377-caa0b71fda66
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/b26f5f7a-0913-4a95-8337-ed7543902f2d
- https://authoring-docs-microsoft.poolparty.biz/devrel/686ed158-d915-41e9-9760-efa46ba88f6d
platformId: 9e100e42-c0ec-6ddc-7065-2ddd36935b83
---

# Overview of Signing and Verifying OCI Artifacts - Azure Container Registry | Microsoft Learn

Container images and other Open Container Initiative (OCI) artifacts are key components of modern cloud-native applications. These artifacts can include software bills of materials (SBOMs), Helm charts, configuration bundles, and AI models. They flow through the software supply chain from creation to deployment. They're built by publishers, stored in registries, and consumed in continuous integration and continuous delivery (CI/CD) pipelines or production environments.

Without safeguards, attackers could:

- Alter artifacts while they're stored or transferred.
- Swap trusted images or charts with malicious ones.
- Insert unverified base images or dependencies into builds.

Adding safeguards helps ensure:

- **Integrity**: The artifact that you use is exactly the same as the one that was published.
- **Authenticity**: The artifact truly came from the expected publisher.

Together, integrity and authenticity are critical for protecting the supply chain and preventing attacks.

## Signing and verification

These processes help provide integrity and authenticity:

- **Signing**: Produces cryptographic signatures that bind a publisher's identity to an artifact descriptor, including the digest. OCI artifacts like container images can be signed after they're built.
- **Verification**: Checks that a signature is valid, the publisher's identity is trusted, and the artifact isn't altered. Signatures can be verified before artifacts are consumed.

If verification fails, consumers can block the artifact from being pulled, used in builds, or deployed.

## Notary Project and Notation

[Notary Project](https://notaryproject.dev/) is an open-source project that provides signing and verification for OCI artifacts.

*Notation* is the Notary Project tooling for signing and verifying OCI artifacts. Notation integrates with multiple key providers, including:

- **Azure Key Vault**: Users manage their own certificate lifecycle, including issuance, rotation, and expiration. This choice provides strong control and flexibility for organizations that want to maintain direct management of their certificates.
- **Artifact Signing**: Provides *zero-touch certificate management* and issues *short-lived certificates* automatically. These features simplify the signing experience while maintaining strong security guarantees.

Organizations can choose Key Vault for full control or adopt Artifact Signing for a streamlined experience.

## Scenarios for signing and verifying

### Image publisher signs images in CI/CD pipelines such as GitHub Actions

A container image publisher builds an image and signs it as part of the GitHub Actions workflow before pushing it to Azure Container Registry. This process:

- Helps ensure that downstream consumers can verify the image origin.
- Adds trust metadata into the supply chain at build time.

### Image consumer verifies images during deployment on AKS

When an organization deploys workloads to Azure Kubernetes Service (AKS), a cluster policy can enforce that only signed and verified images are allowed to run. This process:

- Helps prevent the deployment of unauthorized or tampered-with images.
- Helps ensure that runtime workloads originate from trusted publishers.

### Image consumer verifies base images in CI/CD pipelines

Before developers build an application image, they can configure pipelines (for example, GitHub Actions) to verify the signatures of base images. This process:

- Helps protect builds from inheriting vulnerabilities or malicious code.
- Enforces the use of only trusted upstream components in application builds.

### Consumer verifies other OCI artifacts

Beyond container images, consumers can verify these artifacts stored in an OCI registry:

- **SBOMs**: Verify the signed SBOM of an image before using it for security analysis.
- **Helm charts**: Verify charts before installing them in Kubernetes clusters.
- **Configuration bundles or AI models**: Verify that these bundles or models originate from the intended publisher before integrating them into systems.