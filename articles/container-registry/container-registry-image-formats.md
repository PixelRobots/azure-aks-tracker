---
layout: Conceptual
title: Supported Content Formats by ACR, Docker, OCI, and Helm - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-image-formats
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
description: Learn about content formats supported by Azure Container Registry, including Docker-compatible container images, Helm charts, OCI images, and OCI artifacts.
ms.topic: concept-article
ms.date: 2023-10-31T00:00:00.0000000Z
locale: en-us
document_id: 32a75d3b-994c-4b4f-5d93-876e6761055a
document_version_independent_id: 265cbac4-687e-66c9-a36b-b1af198f186c
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-image-formats.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-image-formats
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-image-formats.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: b5dfde24-8ae3-7d67-055d-011a8dcc3057
---

# Supported Content Formats by ACR, Docker, OCI, and Helm - Azure Container Registry | Microsoft Learn

Use a private repository in Azure Container Registry to manage one of the following content formats.

## Docker-compatible container images

The following Docker container image formats are supported:

- [Docker Image Manifest V2, Schema 1](https://docs.docker.com/registry/spec/manifest-v2-1/)
- [Docker Image Manifest V2, Schema 2](https://docs.docker.com/registry/spec/manifest-v2-2/) - includes Manifest Lists which allow registries to store [multi-architecture images](push-multi-architecture-images) under a single `image:tag` reference

## OCI images

Azure Container Registry supports images that meet the [Open Container Initiative (OCI) Image Format Specification](https://github.com/opencontainers/image-spec/blob/master/spec.md), including the optional [image index](https://github.com/opencontainers/image-spec/blob/master/image-index.md) specification. Packaging formats include [Singularity Image Format (SIF)](https://github.com/sylabs/sif).

## OCI artifacts

Azure Container Registry supports the [OCI Distribution Specification](https://github.com/opencontainers/distribution-spec), a vendor-neutral, cloud-agnostic spec to store, share, secure, and deploy container images and other content types (artifacts). The specification allows a registry to store a wide range of artifacts in addition to container images. You use tooling appropriate to the artifact to push and pull artifacts. For examples, see:

- [Push and pull an OCI artifact using an Azure container registry](container-registry-manage-artifact)
- [Push and pull Helm charts to an Azure container registry](container-registry-helm-repos)

To learn more about OCI artifacts, see the [OCI Registry as Storage (ORAS)](https://github.com/deislabs/oras) repo and the [OCI Artifacts](https://github.com/opencontainers/artifacts) repo on GitHub.

## Helm charts

Azure Container Registry can host repositories for [Helm charts](https://helm.sh/), a packaging format used to quickly manage and deploy applications for Kubernetes. [Helm client](https://docs.helm.sh/using_helm/#installing-helm) version 3 is recommended. See [Push and pull Helm charts to an Azure container registry](container-registry-helm-repos).