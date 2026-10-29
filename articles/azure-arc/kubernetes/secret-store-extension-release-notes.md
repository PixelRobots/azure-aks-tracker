---
layout: Conceptual
title: What's new for AKV Secret Store extension - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/secret-store-extension-release-notes
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
description: The release notes identify important updates and improvements in the Azure Key Vault Secret Store extension.
ms.date: 2026-10-29T00:00:00.0000000Z
ms.topic: release-notes
ai-usage: ai-assisted
locale: en-us
document_id: 9ddcd59e-467d-f9c6-0816-7d2e48af509d
document_version_independent_id: 67b9ca66-f31e-eeb6-65b1-0f843e5562d3
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/secret-store-extension-release-notes.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/secret-store-extension-release-notes
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/secret-store-extension-release-notes.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
platformId: 4fa662eb-f4f3-b01a-fc19-537bce9a1d15
---

# What's new for AKV Secret Store extension - Azure Arc | Microsoft Learn

Updates and improvements to the Azure Key Vault Secret Store extension are listed here.

## October 2026

### 1.6.1

- Updated the trusted root certificate authorities.
- Updated internal dependencies to address vulnerabilities and security advisories.

### 1.6.0

- Added an optional `cloudName` field to `AKVSync` resources. The value is passed to generated `SecretProviderClass` resources.
- Improved reconciliation efficiency by indexing `SecretProviderClass` objects only once per reconciliation.
- Fixed a ValidatingAdmissionPolicyBinding that referenced a nonexistent policy. The binding now targets the correct policy, preventing the controller from overwriting a Kubernetes Secret that has no owner.
- Updated internal dependencies to address vulnerabilities and security advisories.

### 1.5.8

- Includes the 1.6.1 updates for the 1.5 release line.

### 1.5.7

- Includes the admission policy fix from 1.6.0 for the 1.5 release line.
- Updated internal dependencies to address vulnerabilities and security advisories.

## September 2026

### 1.5.5

- User-supplied pod labels and annotations now correctly render as strings in all cases.
- Updated dependencies with known vulnerabilities.

## August 2026

### 1.5.3

- Patch release to update dependencies with known vulnerabilities.

## July 2026

### 1.5.2

- Patch release to update dependencies with known vulnerabilities.

## June 2026

### 1.5.1

- Patch release to update dependencies with known vulnerabilities.

## May 2026

### 1.5.0

- Security updates to internal components:
    - Updated Go to 1.26.2.
    - Updated kubectl container image to v1.36.0-3.
    - Updated AKV CSI Provider container image to v1.8.1-1.
    - Bumped `sigs.k8s.io/secrets-store-csi-driver` to v1.6.0.
    - Bumped `sigs.k8s.io/controller-runtime` to v0.24.0.
    - Bumped `github.com/Azure/azure-sdk-for-go/sdk/azidentity` to v1.13.1.

## April 2026

### 1.4.1

- Security updates to internal components:
    - Updated Go to 1.26.1.
    - Updated kubectl container image to v1.35.3-1 to address CVEs in base image.
    - Updated AKV CSI Provider container image to v1.7.2-6 to address CVEs in base image.
    - Bumped `helm.sh/helm/v3` to v3.20.2 to address security advisories.
    - Bumped `go.opentelemetry.io/otel/sdk` to v1.43.0 to address security advisories.
    - Bumped `google.golang.org/grpc` to v1.79.3 to address security advisories.

## March 2026

### 1.4.0

- Added a `kubectl.image.tag` Helm value to configure the kubectl image tag, alongside `repository` and `digest`. Both tag and digest are now provided for provider and kubectl images.
- Further refined ownership checks to prevent `AKVSync` resources from overwriting existing `SecretSync` or `SecretProviderClass` resources when using TLS certificates.
- Reinstated support for Kubernetes versions prior to 1.30, which was unintentionally dropped in 1.3.0, by making the new Validating Admission Policies (VAPs) conditional.
- Security updates to internal components:
    - Updated kubectl container image to v1.35.1-1.
    - Updated AKV CSI Provider container image to v1.7.2-5.
    - Bumped `sigs.k8s.io/secrets-store-csi-driver` to v1.5.6, `helm.sh/helm/v3` to v3.20.0, `golang.org/x/crypto` to v0.48.0, and `google.golang.org/protobuf` to v1.36.11.

### 1.3.0

- Added ownership checks to prevent AKVSync resources from overwriting existing SecretSync or SecretProviderClass resources.
- Security updates to internal components:
    - Bumped Golang version to 1.25.7 which includes CVE patches.
    - Bumped kubectl container image to v1.35.0-2 to address CVEs in base image.
    - Bump AKV CSI Provider container image revision to v1.7.2-4 to address CVEs in base image.

## February 2026

### 1.2.2

- HTTP proxy certificates provided via the --proxy-cert flag during cluster Arc enablement are now correctly handled.

## January 2026

### 1.2.1

- Support for ARM64 architectures.
- The Helm chart now uses SHA-256 digests to identify image versions instead of tags.
- Security updates to internal components:
    - Update Go to 1.25.5
    - Update kubectl container image to v1.35.0-1

### 1.1.6

- The Helm chart now uses SHA-256 digests to identify image versions instead of tags.
- Security updates to internal components:
    - Update Go to 1.25.5
    - Update kubectl container image to v1.35.0-1

## November 2025

### 1.1.5

- (Preview feature) Simplified configurations are supported via `AKVSync` resources. See the getting started and reference guides.
- `jitterSeconds` extension setting (see [configuration reference](secret-store-extension-reference#arc-extension-configuration-settings)) added to help large deployments avoid overwhelming Azure Key Vault.
- Security updates to internal components:

    - Update Go to 1.25.1.
    - Updated kubectl container image to v1.33.5-3.

## August 2025

### 1.0.2

- SSE is generally available.
- Failure to find the SecretSync resource during a SecretSync reconciliation no longer causes an error.
- Security updates to internal components:

    - Update Go to 1.24.4

## May 2025

### 0.10.0 [PREVIEW]

- The controller will now attempt to partially sync any secrets, instead of failing to sync any secret if at least one failed.
- Installation is now possible on OpenShift without need to configure Security Context Constraints.
- A ValidatingAdmissionPolicy has been added to prevent the SecretSync type from being changed.
- Security updates to internal components:

    - Update Go to 1.24.3
    - Update Kubectl to v1.30.12
    - Update provider to v1.7.0
    - Update golang.org/x/net to v0.39.0
    - Azure Linux 3 is now used as the base for the controller image.

### 0.9.6 [PREVIEW]

- Security updates to internal components:

    - Update Go to 1.24.3
    - Update Kubectl to v1.30.12
    - Update provider to v1.7.0
    - Update golang.org/x/net to v0.39.0
    - Azure Linux 3 is now used as the base for the controller image.