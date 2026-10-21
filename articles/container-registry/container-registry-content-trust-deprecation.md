---
layout: Conceptual
title: Transition from Docker Content Trust to Notary Project - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-content-trust-deprecation
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
author: KumudD
learn_banner_products:
- azure
manager: kumud
ms.reviewer: kumud
ms.author: kumud
ms.service: azure-container-registry
description: Learn how to transition from Docker Content Trust to Notary Project to sign and verify container images.
ms.topic: how-to
ms.date: 2024-02-07T00:00:00.0000000Z
locale: en-us
document_id: cf5e9bf8-b18a-13ae-a21b-671bccbb5939
document_version_independent_id: daa156dd-2d73-f2cb-821c-27564297fcc1
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-content-trust-deprecation.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-content-trust-deprecation
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-content-trust-deprecation.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: 33b6b7b7-8bd2-5c6b-65f0-3cdc872171ba
---

# Transition from Docker Content Trust to Notary Project - Azure Container Registry | Microsoft Learn

Azure Container Registry will retire [Docker Content Trust (DCT)](container-registry-content-trust) on March 31, 2028. To help with this transition, this article provides guidance for how to disable DCT and adopt Notary Project to sign and verify container images.

## DCT deprecation

DCT allows image publishers to sign their images and allows image consumers to verify that the images they pull are signed. With advancements in technology, DCT no longer meets the requirements of modern supply-chain security for containers. As a result, deprecation of DCT started on March 31, 2025. DCT will be completely removed from Azure Container Registry on March 31, 2028.

As an alternative to DCT, Microsoft offers signing and verification solutions based on Notary Project. [Notary Project](https://notaryproject.dev/) is a set of specifications and tools that provide a cross-industry standard for securing software supply chains by using authentic container images and other Open Container Initiative (OCI) artifacts.

[Notation](https://github.com/notaryproject/notation), a tool from Notary Project, implements Notary Project specifications. It includes a command-line interface (CLI) and libraries for signing and verifying container images and artifacts. The benefits of using the Notary Project solutions to ensure the integrity and authenticity of container images include:

- **Portability and interoperability**: [Notary Project signatures](https://github.com/notaryproject/specifications/blob/v1.1.0/specs/signature-specification.md) adhere to [OCI standards](https://github.com/opencontainers/image-spec/tree/v1.1.0) and can be stored in OCI-compliant registries like Container Registry. These capabilities facilitate signature portability and interoperability across cloud environments.
- **Secure key management**: You can use [Azure Key Vault](/en-us/azure/key-vault/general/basic-concepts) to manage your signing keys and certificates.
- **Integration with continuous integration and continuous delivery (CI/CD) pipelines**: Implement signing in your CI/CD pipelines, including Azure DevOps and GitHub workflows.
- **Comprehensive verification**: Verify container images within your CI/CD pipelines (such as Azure DevOps and GitHub workflows) and on [Azure Kubernetes Service (AKS)](/en-us/azure/aks/) to prevent the use and deployment of untrusted images.

## Disable DCT

Before you can transition to the Notation Project solutions, you have to disable DCT. Use any of the following methods:

- Disable DCT from the shell by setting the `DOCKER_CONTENT_TRUST` environment variable to `0`. For example, in the Bash shell, use this command:

    ```bash
    export DOCKER_CONTENT_TRUST=0
    ```

    Alternatively, you can unset the environment variable:

    ```bash
    unset DOCKER_CONTENT_TRUST
    ```
- Disable DCT from the Azure portal. Go to the registry, and then under **Policies**, select **Content Trust** &gt; **Disabled** &gt; **Save**.
- Disable DCT by using the Azure CLI:

    ```
    az acr config content-trust update -r myregistry --status disabled
    ```

## Use Notary Project to sign and verify container images

After you disable DCT, you can sign and verify container images by using Notary Project. Use the following references to get started.

Sign container images:

- To use Key Vault with self-signed certificates, see [Sign container images by using Notation, Azure Key Vault, and a self-signed certificate](container-registry-tutorial-sign-build-push).
- To use Key Vault with certificates issued by a certificate authority (CA), see [Sign container images by using Notation, Azure Key Vault, and a CA-issued certificate](container-registry-tutorial-sign-trusted-ca).
- To sign in Azure DevOps pipelines, see [Sign and verify a container image by using Notation in an Azure pipeline](/en-us/azure/security/container-secure-supply-chain/articles/notation-ado-task-sign).
- To sign in GitHub workflows, see [Sign a container image by using Notation in GitHub Actions](/en-us/azure/security/container-secure-supply-chain/articles/notation-sign-gha).

Verify container images:

- To verify in Azure DevOps pipelines, see [Sign and verify a container image by using Notation in an Azure pipeline](/en-us/azure/security/container-secure-supply-chain/articles/notation-ado-task-sign#verify-the-signed-image).
- To verify in GitHub workflows, see [Verify a container image by using Notation in GitHub Actions](/en-us/azure/security/container-secure-supply-chain/articles/verify-gha).
- To verify on AKS, see [Verify container image signatures by using Ratify and Azure Policy](container-registry-tutorial-verify-with-ratify-aks).