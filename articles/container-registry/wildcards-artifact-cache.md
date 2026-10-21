---
layout: Conceptual
title: Wildcard support for artifact cache in Azure Container Registry - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/wildcards-artifact-cache
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
description: Use wildcards to match multiple paths within the container image registry. Artifact cache currently supports registry and repository level wildcards.
ms.topic: concept-article
ms.custom: devx-track-azurecli
ms.date: 2025-04-18T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: 9c31100e-622c-34ae-a9a6-11d82d3818e9
document_version_independent_id: 8951d243-2d6e-0caf-5d7e-0e5e00a64e61
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/wildcards-artifact-cache.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/wildcards-artifact-cache
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/wildcards-artifact-cache.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: 01752678-c2c2-050f-c351-f1b4b143c9fe
---

# Wildcard support for artifact cache in Azure Container Registry - Azure Container Registry | Microsoft Learn

Wildcard use asterisks (\*) to match multiple paths within the container image registry. This article lists the wildcards supported by the [artifact cache feature](artifact-cache-overview) for Azure Container Registry (ACR).

Note

Cache rules map from `target repository` =&gt; `source repository`.

## Registry level wildcard

The registry level wildcard lets you cache all repositories from an upstream registry.

| Cache rule | Mapping | Example |
| --- | --- | --- |
| `contoso.azurecr.io/*` =&gt; `mcr.microsoft.com/*` | Mapping for all images under ACR to MCR. | `contoso.azurecr.io/myapp/image1` =&gt; `mcr.microsoft.com/myapp/image1<br>contoso.azurecr.io/myapp/image2` =&gt; `mcr.microsoft.com/myapp/image2` |

## Repository level wildcard

The repository level wildcard lets you cache all repositories from an upstream registry mapping to the repository prefix.

| Cache Rule | Mapping | Example |
| --- | --- | --- |
| `contoso.azurecr.io/dotnet/*` =&gt; `mcr.microsoft.com/dotnet/*` | Mapping specific repositories under ACR to corresponding repositories in MCR. | `contoso.azurecr.io/dotnet/sdk` =&gt; `mcr.microsoft.com/dotnet/sdk``contoso.azurecr.io/dotnet/runtime` =&gt; `mcr.microsoft.com/dotnet/runtime` |
| `contoso.azurecr.io/library/dotnet/*` =&gt; `mcr.microsoft.com/dotnet/*``contoso.azurecr.io/library/python/*` =&gt; `docker.io/library/python/`\* | Mapping specific repositories under ACR to repositories from different upstream registries. | `contoso.azurecr.io/library/dotnet/app1` =&gt; `mcr.microsoft.com/dotnet/app1``contoso.azurecr.io/library/python/app3` =&gt; `docker.io/library/python/app3` |

## Limitations for wildcard-based cache rules

Wildcard cache rules use asterisks (\*) to match multiple paths within the container image registry. These rules can't overlap with other wildcard cache rules by targeting the same repository path, or by targeting multiple paths where one path includes the other. In other words, if you have a wildcard cache rule for a certain registry path, you can't add another wildcard rule that overlaps with it.

Here are some examples of overlapping rules:

**Example 1**:

Existing cache rule: `contoso.azurecr.io/* => mcr.microsoft.com/*` New cache rule: `contoso.azurecr.io/library/* => docker.io/library/*`

The addition of the new cache rule is blocked because the target repository path `contoso.azurecr.io/library/*` overlaps with the existing wildcard rule `contoso.azurecr.io/*`.

**Example 2:**

Existing cache rule: `contoso.azurecr.io/library/*` =&gt; `mcr.microsoft.com/library/*` New cache rule: `contoso.azurecr.io/library/dotnet/*` =&gt; `docker.io/library/dotnet/*`

**Example 3:**

Existing cache rule: `contoso.azurecr.io/* => mcr.microsoft.com/*` New cache rule: `contoso.azurecr.io/* => docker.io/library/*`

The addition of the new cache rule is blocked because two rules use the same target repository path `contoso.azurecr.io/*`.

The addition of the new cache rule is blocked because the target repository path `contoso.azurecr.io/library/dotnet/*` overlaps with the existing wildcard rule `contoso.azurecr.io/library/*`.

## Limitations for static/fixed cache rules

Static or fixed cache rules are more specific and don't use wildcards. They can potentially overlap with wildcard-based cache rules. If a cache rule specifies a fixed repository path, then it allows overlapping with a wildcard-based cache rule. However, you can't create multiple static rules that point to the same exact repository path.

**Example 1**:

Existing cache rule: `contoso.azurecr.io/*` =&gt; `mcr.microsoft.com/*` New cache rule: `contoso.azurecr.io/library/dotnet` =&gt; `docker.io/library/dotnet`

The addition of the new cache rule is allowed because `contoso.azurecr.io/library/dotnet` is a static path and can overlap with the wildcard cache rule `contoso.azurecr.io/*`.

**Example 2:**

Existing cache rule: `contoso.azurecr.io => mcr.microsoft.com/*` New cache rule: `contoso.azurecr.io => docker.io/library/*`

The addition of the new cache rule is blocked because two rules use the same target repository path `contoso.azurecr.io`.