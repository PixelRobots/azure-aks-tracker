---
layout: Conceptual
title: Review AKS upgrade readiness in Kubernetes Center using the Azure portal - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/kubernetes-center-upgrade-readiness
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
description: Learn how to review AKS version support, upgrade failures, upcoming upgrades, recommendations, and Fleet update runs in Kubernetes Center.
author: schaffererin
ms.author: schaffererin
ms.topic: how-to
ms.subservice: aks-upgrade
ms.date: 2026-11-06T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: 3c5997fe-c254-4f70-6232-4068300000f0
document_version_independent_id: ae473295-67ce-2b0f-b3b3-dabda91271f0
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/kubernetes-center-upgrade-readiness.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/kubernetes-center-upgrade-readiness
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/kubernetes-center-upgrade-readiness.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 66dab260-0c73-97bc-c0cc-444897b91641
---

# Review AKS upgrade readiness in Kubernetes Center using the Azure portal - Azure Kubernetes Service | Microsoft Learn

Use **Multicluster update and insights** in Kubernetes Center (preview) to identify clusters that need upgrade attention without opening each Azure Kubernetes Service (AKS) resource individually. You can review Kubernetes version support, investigate recent upgrade failures, see upcoming upgrades, and choose a remediation path.

This article explains how to use the Azure portal experience. Reviewing insights doesn't initiate an upgrade or change a cluster's configuration.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Prerequisites

- An Azure subscription with one or more AKS clusters.
- Read access to the clusters you want to inspect. To inspect Fleet information, you also need access to the relevant Azure Kubernetes Fleet Manager resources.
- Appropriate write permissions if you choose to change upgrade settings, enroll a cluster in long-term support (LTS), or configure Fleet upgrades. Read access alone doesn't authorize these changes.

Fleet membership isn't required to review standalone clusters.

## Open upgrade insights and set the scope

1. Sign in to the [Azure portal](https://portal.azure.com/).
2. In the portal search box, search for and select **Kubernetes center**.
3. In the **Kubernetes center** menu, expand **Multicluster management**, and select **Multicluster update and insights**.
4. Review **View by**, **Subscription**, **Resource group**, and **Location** at the top of the page. Select the scope you want to investigate.
5. Select **Refresh** when you need to reload the displayed information.

[![Screenshot of the Kubernetes center menu showing Multicluster update and insights under Multicluster management.](media/kubernetes-center-upgrade-readiness/upgrade-insights-menu.png)](media/kubernetes-center-upgrade-readiness/upgrade-insights-menu.png#lightbox)

The page contains summary cards and a cluster table. Start with the cards to identify a concern, then inspect the affected clusters. Counts and resource names in the screenshots are examples, not expected values for your environment.

[![Screenshot of upgrade insights cards showing version support, upgrade issues, upcoming upgrades, recommendations, and Fleet update runs.](media/kubernetes-center-upgrade-readiness/upgrade-insights-overview.png)](media/kubernetes-center-upgrade-readiness/upgrade-insights-overview.png#lightbox)

## Find clusters that need a supported Kubernetes version

1. Locate **Cluster Version Support Status by Tier**.
2. Select **All**, **Premium**, **Standard**, or **Free** to examine the corresponding cluster tier.
3. Review the support categories:

    | Category | What to investigate |
    | --- | --- |
    | **Out of support** | Prioritize reviewing the cluster's Kubernetes version and available upgrade options. |
    | **Out of support (LTS eligible)** | The version is outside its current support coverage, but the cluster is a candidate for LTS. Eligibility doesn't mean LTS is already enabled. |
    | **Expiring soon** | Plan the next upgrade before the current support coverage ends. |
    | **In support** | The cluster is currently within the support coverage shown by the experience. Continue to review its upgrade policy. |
4. Select a category's linked count to open the corresponding cluster list.
5. Open a cluster to review its version and configuration before choosing an upgrade or support-plan change.

For version-specific support dates, use the [AKS Kubernetes version support policy](supported-kubernetes-versions), rather than dates or version numbers in a screenshot.

The card also provides **Enable LTS for Eligible Clusters**. Treat LTS enrollment as a configuration and billing decision, not a way to clear a warning without review. LTS requires the Premium tier and an explicit LTS support plan. For more information, see [Long-term support for AKS versions](long-term-support).

## Investigate a failed upgrade

1. Locate **Cluster upgrade issues**, and read the time window and checked-cluster count. The card shows recent upgrade issues over the last 14 days.
2. Select **View all Upgrade issues**.
3. In **Upgrade Failure Clusters**, search by cluster name or filter by **Subscription**, **Resource group**, **Location**, or **Error code**.
4. For an affected cluster, compare **Current Kubernetes version** and **Target Kubernetes version**, then read **Error details**.
5. Select **View cluster** to continue investigating the affected resource.

[![Screenshot of an upgrade failure showing current and target Kubernetes versions and an error caused by a restrictive pod disruption budget.](media/kubernetes-center-upgrade-readiness/upgrade-failure-details.png)](media/kubernetes-center-upgrade-readiness/upgrade-failure-details.png#lightbox)

For example, the screenshot shows a node-drain failure because evicting a pod would violate its pod disruption budget (PDB). Use the error to identify the workload and review its availability requirements before retrying. Don't remove disruption protections solely to make an upgrade succeed.

Note

A failed cluster provisioning state isn't necessarily an upgrade failure. **Recommendations** can identify clusters whose state blocks upgrades even when **Cluster upgrade issues** has no matching recent upgrade failure. If the upgrade-issues action is disabled, read the card's status and coverage before drawing conclusions.

## Review upgrades planned for the next 14 days

1. Locate **Upcoming Upgrades** to review active upgrades and the upcoming schedule.
2. Select **View all Upcoming upgrades**.
3. Use the calendar to identify a date with planned upgrades. Select that date to narrow the results.
4. Use **Upgrade type**, **Date**, or the resource filters to focus the list.
5. Review each entry's upgrade type, planned start time, and any target-version or estimated-duration information shown.
6. Select **View cluster** to inspect the cluster before the planned operation.

[![Screenshot of a 14-day upcoming-upgrades calendar showing separate counts for clusters and upgrade operations.](media/kubernetes-center-upgrade-readiness/upcoming-upgrades-calendar.png)](media/kubernetes-center-upgrade-readiness/upcoming-upgrades-calendar.png#lightbox)

A cluster can have more than one upgrade operation, such as a Kubernetes version upgrade and a node OS upgrade. For that reason, a day's upgrade count can exceed its cluster count. Check the time-zone label on planned start times when coordinating a maintenance window, and treat duration estimates as estimates.

In the main table, **Next upgrade** only describes the next 14 days. A blank value doesn't establish that automatic upgrades are disabled.

## Choose a remediation path

1. In **Recommendations**, identify the issue you want to address. Examples include standalone clusters without auto-upgrade, clusters still at risk despite auto-upgrade, blocked cluster states, and fleets without auto-upgrade.
2. Read the affected-resource count and support-status breakdown.
3. Select **Review** or **Remediate** for that recommendation.
4. Where the **Set up multicluster upgrades** chooser is offered, select a path:

    | Path | When to use it |
    | --- | --- |
    | **Staged Fleet runs** | Coordinate upgrades across clusters using staged rollout and Fleet management. |
    | **Individual cluster auto-upgrades** | Configure upgrade policies on selected clusters without requiring Fleet membership. |

[![Screenshot of the remediation chooser offering Staged Fleet runs and Individual cluster auto-upgrades.](media/kubernetes-center-upgrade-readiness/remediation-paths.png)](media/kubernetes-center-upgrade-readiness/remediation-paths.png#lightbox)

For individual cluster auto-upgrades, the workflow provides **Cluster selection**, **Schedule & upgrade options**, and **Review** steps. Review the eligible clusters, intended upgrade channels, and maintenance settings before submitting a configuration change.

Important

The individual-cluster path can create or overwrite existing auto-upgrade profiles across multiple clusters. Review existing settings and the selected resources before submitting. Opening the chooser doesn't apply changes.

A `patch` policy alone doesn't move a cluster to a newer Kubernetes minor version. When a cluster remains at risk, review whether its upgrade policy meets your version-support requirements. For policy details, see [Automatically upgrade an AKS cluster](auto-upgrade-cluster). For staged updates, see [Update clusters using Fleet Manager](../kubernetes-fleet/update-orchestration).

## Review Fleet update runs

1. Locate **Fleet Update runs status**.
2. Review the displayed run states, including **Failed**, **Running**, **Stopped**, **Completed**, **Not started**, and **Pending**.
3. Select **View runs** to continue into the run details.
4. Investigate failed or pending work before starting additional updates.

Fleet update runs describe orchestrated operations. They aren't a substitute for checking each cluster's support status.

## Find a specific cluster and verify the outcome

In the cluster table, use **Search by cluster name** and the **Kubernetes version**, **Next upgrade**, **Support status**, **Auto Upgrade**, and **Node OS AutoUpgrade** filters.

[![Screenshot of the upgrade-insights cluster search and version, schedule, support, and automatic-upgrade filters.](media/kubernetes-center-upgrade-readiness/cluster-filters.png)](media/kubernetes-center-upgrade-readiness/cluster-filters.png#lightbox)

After an approved configuration change or completed upgrade:

1. Return to **Multicluster update and insights**, and select **Refresh**.
2. Find the affected cluster.
3. Verify its displayed Kubernetes version, support status, and upgrade policies against the intended outcome.
4. For an upgrade operation, also verify completion in the cluster or Fleet run details. A configured policy or planned date isn't proof that an upgrade completed.