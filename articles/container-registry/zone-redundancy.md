---
layout: Conceptual
title: Zone redundancy in Azure Container Registry - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/zone-redundancy
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
description: Learn about zone redundancy in Azure Container Registry and how it protects your registries automatically.
ms.topic: concept-article
ms.date: 2026-03-25T00:00:00.0000000Z
ms.custom: references_regions, devx-track-azurecli
locale: en-us
document_id: 477ec376-8719-7678-dae7-a93f28c27843
document_version_independent_id: 97ba21cf-20f9-00e4-55a5-cd4d71c294e7
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/zone-redundancy.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/zone-redundancy
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/zone-redundancy.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: 249df61b-ae3e-db6f-7b63-e7f18a4d4315
---

# Zone redundancy in Azure Container Registry - Azure Container Registry | Microsoft Learn

Zone redundancy is enabled by default for all Azure container registries in regions that [support availability zones](/en-us/azure/reliability/regions-list). This feature is available for every service tier - Basic, Standard, and Premium - at no extra cost, and requires no action from you.

Zone redundancy distributes your registry's data plane across multiple [availability zones](/en-us/azure/reliability/availability-zones-overview) within a region. As a result, image push and pull operations continue to function during a single-zone outage. If your Premium registry uses [geo-replication](container-registry-geo-replication), all replicas in supported regions are also zone-redundant by default.

For a comprehensive guide to Container Registry reliability - including zone failover behavior, transient fault handling, and multi-region deployment - see [Reliability in Azure Container Registry](/en-us/azure/reliability/reliability-container-registry).

## Default zone redundancy implications

Zone redundancy isn't an opt-in feature. You don't need to create a special registry, select a specific SKU, or change any settings to be protected. The following table summarizes the behavior for common scenarios:

| Scenario | Zone-redundant? | Action required to enable zone redundancy |
| --- | --- | --- |
| New registry in a [supported region](/en-us/azure/reliability/regions-list) | Yes | None |
| Existing registry in a supported region | Yes | None |
| Geo-replica (Premium) in a supported region | Yes | None |
| Registry in a region **without** availability zone support | No | Migrate to a supported region (see below) |

Note

Zone redundancy applies to the registry data plane (image push and pull). Container Registry [tasks](/en-us/azure/container-registry/container-registry-tasks-overview) don't currently support availability zones.

## Understand the `zoneRedundancy` property

Previously, zone redundancy was an opt-in feature available only on the Premium tier. You had to explicitly set `zoneRedundancy: Enabled` when creating a registry or geo-replica, and the property accurately reflected whether zone redundancy was active.

Zone redundancy is now enabled by default for all registries in supported regions, across all service tiers, regardless of what the `zoneRedundancy` property shows. Currently, the portal, CLI, and ARM API might still display `Disabled`, even though your registry is fully zone-redundant.

Important

**Your registry is zone-redundant in any supported region, regardless of what the `zoneRedundancy` property shows.** The property value is a legacy artifact that no longer controls behavior.

The `zoneRedundancy` property on the ARM registry resource (`Microsoft.ContainerRegistry/registries`) will be deprecated in accordance with [Azure’s deprecation policy](/en-us/lifecycle/definitions#deprecation). Until then, setting it to `Enabled` is harmless but unnecessary, and setting it to `Disabled` has no effect in supported regions.

## Geo-replication

If your Premium registry is [geo-replicated](container-registry-geo-replication), each replica in a region that supports availability zones is automatically zone-redundant. You don't need to enable it during replica creation.

For more information on geo-replication reliability, see [Resilience to region-wide failures](/en-us/azure/reliability/reliability-container-registry#resilience-to-region-wide-failures).

## Registries in unsupported regions

If your registry is in a region that doesn't support availability zones, it isn't zone-redundant. To gain zone redundancy, create a new registry in a [supported region](/en-us/azure/reliability/regions-list) and migrate your images by using one of the following approaches:

- [Import container images](/en-us/azure/container-registry/container-registry-import-images) into the new registry.
- [Create a transfer pipeline](/en-us/azure/container-registry/container-registry-transfer-prerequisites) for large-scale or offline migration.

## Infrastructure as code

The `zoneRedundancy` property still exists in the ARM API and Bicep resource definitions for backward compatibility, but it no longer controls behavior and will eventually be deprecated. Setting it explicitly is harmless but no longer required.

| Action | Effect |
| --- | --- |
| Omit `zoneRedundancy` entirely | Registry is zone-redundant in supported regions (default behavior) |
| Set `zoneRedundancy: 'Enabled'` | No change—matches the default. Safe to keep in existing templates |
| Set `zoneRedundancy: 'Disabled'` | Has no effect in supported regions—zone redundancy cannot be disabled |

For Azure CLI, the `--zone-redundancy` flag in the [az acr create](/en-us/cli/azure/acr#az-acr-create) and [az acr replication create](/en-us/cli/azure/acr/replication#az-acr-replication-create) commands still exists for backward compatibility. You don't need to use this flag, since zone redundancy is active by default.

## Frequently asked questions

### Is zone redundancy available on Basic and Standard tiers?

Yes. Zone redundancy applies to all service tiers—Basic, Standard, and Premium—in regions that support availability zones.

### The portal shows `zoneRedundancy` as `Disabled`. Is my registry protected?

Yes. If your registry is in a [region that supports availability zones](/en-us/azure/reliability/regions-list), it is zone-redundant regardless of what the portal or API shows. The display is being updated.

### Can I disable zone redundancy?

No. Zone redundancy cannot be disabled for registries in supported regions.

### Does zone redundancy cost extra?

No. Zone redundancy is included at no additional cost for all service tiers.

### I previously set `zoneRedundancy` to `Enabled` in my templates. Do I need to change anything?

No. The explicit `Enabled` setting is compatible with the new default and your templates continue to work without modification. When the property is deprecated, you can safely remove it, and your registry will remain zone-redundant.

### What about registries I created before zone redundancy became the default?

Existing registries in supported regions have been retroactively upgraded to be zone-redundant. No action is needed.

### What happens during a zone outage?

The service automatically routes traffic to healthy zones. Image push and pull operations continue with minimal impact. For details on failover behavior and expected data loss windows, see [Resilience to availability zone failures](/en-us/azure/reliability/reliability-container-registry#resilience-to-availability-zone-failures).