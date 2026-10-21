---
layout: Conceptual
title: 'AKS Upgrade Scenarios: Choose Your Path - Azure Kubernetes Service | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/upgrade-scenarios-hub
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
description: Quick decision tree and scenario-based guidance for Azure Kubernetes Service cluster upgrades based on your specific business needs and constraints.
ms.topic: concept-article
ms.subservice: aks-upgrade
ms.date: 2025-07-09T00:00:00.0000000Z
author: kaarthis
ms.author: kaarthis
ms.custom: scenarios, decision-tree
locale: en-us
document_id: 51e9fe16-e55c-7bf4-218b-c2f3568fbea1
document_version_independent_id: 5d83966a-020d-9143-c715-7b37568a5656
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/upgrade-scenarios-hub.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/upgrade-scenarios-hub
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/upgrade-scenarios-hub.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 36dba85a-ab38-2a82-8870-1173d870980b
---

# AKS Upgrade Scenarios: Choose Your Path - Azure Kubernetes Service | Microsoft Learn

Upgrading Azure Kubernetes Service (AKS) clusters safely requires the right strategy for your specific situation. Use this hub to quickly identify your scenario and get targeted guidance.

## What this article covers

This decision hub helps you choose the right AKS upgrade approach based on:

- A quick scenario finder with time constraints and priorities.
- Emergency upgrade paths for critical security responses.
- A strategy matrix that compares downtime tolerance and complexity.
- Role-based guidance for site reliability engineers, database administrators, developers, and security teams.
- Decision trees for complex multi-environment setups.

This hub is best for first-time upgraders, teams that need to evaluate options, and complex environments that require tailored approaches.

For more information, see these related articles:

- To upgrade your production AKS clusters, see [AKS production upgrade strategies](aks-production-upgrade-strategies).
- To get upgrade patterns for AKS clusters with stateful workloads, see [Stateful workload upgrade patterns](stateful-workload-upgrades).
- To check for and apply basic upgrades to your AKS cluster, see [Upgrade an Azure Kubernetes Service (AKS) cluster](tutorial-kubernetes-upgrade-cluster).

## Quick scenario finder

What's your primary concern? Select your answer from the following table.

| My priority | Time constraint | Go to |
| --- | --- | --- |
| Zero production downtime | Upgrade needed within hours | [Production upgrade strategies](aks-production-upgrade-strategies#scenario-1-minimal-downtime-production-upgrades) |
| Multi-environment safety | Planned windows | [Staged fleet upgrades](aks-production-upgrade-strategies#scenario-2-stage-upgrades-across-environments) |
| New Kubernetes version risk | Safety-first approach | [Safe version intake](aks-production-upgrade-strategies#scenario-3-safe-kubernetes-version-intake) |
| Security compliance | Response required for common vulnerabilities and exposures | [Fast security patching](aks-production-upgrade-strategies#scenario-4-fastest-security-patch-deployment) |
| Database/stateful apps | Running databases | [Stateful workload patterns](stateful-workload-upgrades) |
| Architecture planning | Design for upgrades | [Resilient architecture](aks-production-upgrade-strategies#scenario-5-application-architecture-for-resilient-upgrades) |

## Emergency upgrade (30-90 minutes)

If you need a critical security patch now, select a link for instructions:

- **Immediate action:**[Automated security patching](aks-production-upgrade-strategies#scenario-4-fastest-security-patch-deployment)
- **With stateful workloads:**[Database safety patterns](stateful-workload-upgrades#emergency-upgrade-checklist)
- **Rollback ready:**[Quick recovery guide](aks-production-upgrade-strategies#emergency-rollback-procedures)

## Upgrade strategy matrix

Find your ideal approach based on business constraints.

| Downtime tolerance | Environment | Best strategy | Time investment |
| --- | --- | --- | --- |
| &lt;2 minutes | Production | Blue-green deployment | 45-60 min |
| &lt;30 seconds | Stateful apps | Ferris wheel pattern | 60-90 min |
| Planned window | Multi-environment | Staged fleet upgrade | 2-4 hours |
| Zero tolerance | Mission-critical | Application architecture | Ongoing |

## Key upgrade topics

### Core upgrade mechanics

- [Basic cluster upgrade process](tutorial-kubernetes-upgrade-cluster)
- [Node pool upgrade strategies](upgrade-aks-node-pools-rolling)
- [Auto-upgrade configuration](auto-upgrade-cluster)

### Production-ready strategies

- [Scenario-based production upgrades](aks-production-upgrade-strategies)
- [Stateful workload upgrade patterns](stateful-workload-upgrades)
- [Cross-environment upgrade staging](aks-production-upgrade-strategies#scenario-2-stage-upgrades-across-environments)

### Advanced topics

- [Long-term support strategies](long-term-support)
- [Maintenance window planning](planned-maintenance)
- [Upgrade monitoring and alerts](aks-communication-manager)

## Quick wins (5-15 minutes)

Immediate actions that you can take:

- **Pre-upgrade health check:** Run [cluster diagnostics](aks-diagnostics).
- **Backup validation:** Verify your [disaster recovery](reliability-multi-region-deployment-models) setup.
- **Monitoring setup:** Enable [upgrade notifications](aks-communication-manager).
- **Team preparation:** Review [support policies](support-policies).

## Learning path

If you're new to AKS upgrades, follow this learning sequence:

1. **Learn:** Learn about [Kubernetes concepts](core-aks-concepts) and read the [Upgrade overview](upgrade-conceptual).
2. **Practice:** Take the tutorial on how to [upgrade an AKS cluster](tutorial-kubernetes-upgrade-cluster).
3. **Production:** Use the [production strategies](aks-production-upgrade-strategies).
4. **Optimize:** Find out about [stateful patterns](stateful-workload-upgrades).

## Pro tips

- **Always test in nonproduction first:** Perform tests even for emergency patches.
- **Monitor during upgrades:** Set up [real-time alerts](aks-communication-manager).
- **Plan for rollback:** Have a tested recovery procedure.
- **Communicate with teams:** Coordinate with app owners during upgrades.