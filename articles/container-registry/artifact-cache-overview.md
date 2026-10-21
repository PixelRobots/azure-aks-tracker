---
layout: Conceptual
title: Optimize image pulls with artifact cache in Azure Container Registry - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/artifact-cache-overview
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
description: Artifact cache is a feature that allows you to cache container images in Azure Container Registry, improving performance and efficiency.
ms.topic: concept-article
ms.custom: devx-track-azurecli
ms.date: 2025-05-12T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: 872121ca-5b15-b139-4814-b0e6ca5f4960
document_version_independent_id: 088542cc-6463-c899-ed4d-6bbb5ffe83e1
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/artifact-cache-overview.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/artifact-cache-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/artifact-cache-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: d712863a-d7d3-50ad-a9f5-14803f27958c
---

# Optimize image pulls with artifact cache in Azure Container Registry - Azure Container Registry | Microsoft Learn

The artifact cache feature of Azure Container Registry lets you cache container images in both public and private repositories.

Artifact cache enables faster and more *reliable pull operations* through Azure Container Registry (ACR). It uses features like geo-replication and availability zone support for higher availability and faster image pulls. You can access cached registries over private networks to align with your firewall configurations and compliance standards.

Artifact cache addresses the challenge of pull limits imposed by public registries. We recommend authenticating your cache rules with your upstream source credentials. Then, you can pull images from the local ACR, helping to mitigate rate limits.

The artifact cache feature is available in *Basic*, *Standard*, and *Premium*[service tiers](container-registry-skus). You can enable artifact cache rules in the [Azure portal](artifact-cache-portal) or by using [Azure CLI](artifact-cache-cli).

## Terminology

When working with artifact caching, it's helpful to understand the following terminology:

- **Cache Rule**: A rule you create to pull artifacts from a supported repository into your cache. A cache rule contains four parts:

    - **Rule name**: The name of your cache rule. For example, `Hello-World-Cache`.
    - **Source**: The name of the source registry.
    - **Repository path**: The source path of the repository to find and retrieve artifacts you want to cache. For example, `docker.io/library/hello-world`.
    - **New ACR repository namespace**: The name of the new repository path to store artifacts. For example, `hello-world`. The repository can't already exist inside the ACR instance.
- **Credentials**: A username and password set for the source registry. You require credentials to authenticate with a public or private repository. Credentials contain four parts:

    - **Credentials**: The name of your credentials.
    - **Source registry login server**: The login server of your source registry.
    - **Source authentication**: The key vault locations to store credentials.
    - **Username and password secrets**: Secrets containing the username and password.

## Current limitations

When using artifact cache, keep in mind the following limitations:

- Cache only occurs after at least one image pull is complete on the available container image. For every new image available, a new image pull must be complete. Currently, artifact cache doesn't automatically pull new tags of images when a new tag is available.
- Artifact cache supports a maximum of 1,000 cache rules.
- Artifact cache rules can't overlap with other cache rules. In other words, if you have an artifact cache rule for a certain registry path, you can't add another cache rule that overlaps with it.

## Upstream support

Artifact cache currently supports the following upstream registries.

Warning

To source content from Docker Hub, you must generate a credential set by using [Azure CLI](artifact-cache-cli#create-the-credentials) or the [Azure portal](artifact-cache-portal#create-new-credentials).

Some public Docker Hub images are mapped to the publicly accessed namespace `library`. In this case, if you don't include the `library` path, artifact cache will automatically include it for you.

| Upstream registry | Support | Availability |
| --- | --- | --- |
| Docker Hub | Supports authenticated pulls only. | Azure CLI, Azure portal |
| Docker Hardened Images (`dhi.io`) | Supports authenticated pulls only. | Azure CLI |
| Azure Container Registry (`azurecr.io`) | Supports authenticated pulls only. | Azure CLI |
| Microsoft Artifact Registry | Supports unauthenticated pulls only. | Azure CLI, Azure portal |
| AWS Elastic Container Registry (ECR) Public Gallery | Supports unauthenticated pulls only. | Azure CLI, Azure portal |
| GitHub Container Registry | Supports both authenticated and unauthenticated pulls. | Azure CLI, Azure portal |
| Quay | Supports both authenticated and unauthenticated pulls. | Azure CLI, Azure portal |
| Kubernetes Container Image Registry (`registry.k8s.io`) | Supports both authenticated and unauthenticated pulls. | Azure CLI |
| Google Artifact Registry (`*.pkg.dev`) | Supports authenticated pulls only. | Azure CLI |
| Legacy Google Container Registry (`gcr.io`) | Supports both authenticated and unauthenticated pulls. | Azure CLI |
| NVIDIA NGC Container Registry (`nvcr.io`) | Supports both authenticated and unauthenticated pulls. | Azure CLI, Azure portal |
| Red Hat Registry (`registry.redhat.io`) | Supports authenticated pulls only. | Azure CLI |
| Red Hat Public Registry (`registry.access.redhat.com`) | Supports unauthenticated pulls only. | Azure CLI |

### Authentication method for Google Artifact Registry

To set up Artifact Cache from your private Google Artifact Registry (GAR), we recommend using a Service Account Key (created in Google Cloud's Console) to authenticate with GAR. You can define a custom expiry date for the Service Account key (for example, 3 months) and persist the key in Azure Key Vault.

Although you could use an access token (generated from gcloud CLI) to authenticate, it is not recommended for use with Artifact Cache, because the access token expires after 1 hour.

For more information about how to create a Service Account Key, see [Authenticate with Google Artifact Registry](https://docs.cloud.google.com/artifact-registry/docs/docker/authentication#json-key). After you have the Service Account Key, save it as a secret in Azure Key Vault. Then point your credential set's password to this secret. The username should be set to:

- `_json_key` if you are using the service account key in JSON format as it was provided when you created the file.
- `_json_key_base64` if you base64-encoded all of the contents of the account key file.

For more information about how to create a credential set, follow the links in the next section.