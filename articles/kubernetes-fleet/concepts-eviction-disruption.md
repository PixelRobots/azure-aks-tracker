---
layout: Conceptual
title: Controlling eviction and disruption budgets for Azure Kubernetes Fleet Manager cluster resource placement | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/concepts-eviction-disruption
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
learn_banner_products:
- azure
description: This article describes how to manage evictions and voluntary disruption for workloads placed by Fleet Manager's cluster resource placement.
ms.date: 2026-07-28T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
ms.topic: concept-article
locale: en-us
document_id: 8b755124-3ef5-7806-5afd-c01a30ddd2d8
document_version_independent_id: f03bf857-211d-f825-7dda-12265543741c
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/concepts-eviction-disruption.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: kubernetes-fleet/concepts-eviction-disruption
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/concepts-eviction-disruption.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: f925208c-f566-b91f-ee01-5a7fbb2ac8d0
---

# Controlling eviction and disruption budgets for Azure Kubernetes Fleet Manager cluster resource placement | Microsoft Learn

**Applies to:** ✔️ Fleet Manager with hub cluster

Administrators using Fleet Manager's cluster resource placement (CRP) can find they need to remove resources previously placed on member clusters, while ensuring that key resource placements aren't disrupted.

In this article, we explore how you can use Fleet Manager's `ClusterResourcePlacementEviction` and `ClusterResourcePlacementDisruptionBudget` objects to achieve these goals.

Note

If you aren't already familiar with Fleet Manager's cluster resource placement (CRP), read the [conceptual overview of resource placement](concepts-resource-placement) before reading this article.

Important

Azure Kubernetes Fleet Manager preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. Azure Kubernetes Fleet Manager previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use.

Our data plane previews are released via our v1beta1 API. If you don't see preview objects, check that you're requesting the v1beta1 API when you interact with the Fleet Manager hub cluster.

## Evict placed resources (preview)

A `ClusterResourcePlacementEviction` object is used to remove resources from a member cluster once the resources are propagated from the Fleet Manager hub cluster.

To successfully evict resources from a cluster, you need to specify:

- The name of the `ClusterResourcePlacement` object which propagated resources to the target cluster.
- The name of the target cluster from which we need to evict resources.

Eviction can be used with cluster resource placement's `PickAll` and `PickN` policies. `PickedFixed` isn't supported as you can edit the target clusters and reapply the CRP.

Note

Eviction doesn't guarantee that resources aren't propagated to a member cluster again by the Fleet scheduler. You need to apply [taints](use-taints-tolerations) to prevent the Fleet scheduler from picking a specific cluster again.

Consider the following sample CRP.

```yaml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ClusterResourcePlacement
metadata:
  name: crp-app-sample
spec:
  resourceSelectors:
    - group: ""
      kind: Namespace
      name: test-namespace
      version: v1
  policy:
    placementType: PickN
    numberOfClusters: 2
    affinity:
      clusterAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          clusterSelectorTerms:
            - labelSelector:
                matchLabels:
                  fleet.azure.com/location: westus
```

After applying this CRP, we can [inspect the placement status](howto-understand-placement) to determine which clusters the resources are deployed to.

Let's say the placement picked two clusters named `member-cluster-01` and `member-cluster-02`, and we determine we didn't want the resources deployed on `member-cluster-02` and wish to remove it.

1. Create a `NoSchedule` taint to block placement requests for the member cluster. You can read more about using taints on the [taints documentation](use-taints-tolerations).

    ```yaml
    apiVersion: placement.kubernetes-fleet.io/v1beta1
    kind: MemberCluster
    metadata:
      name: member-cluster-02
    spec:
      identity:
        name: fleet-member-agent-cluster-2
        kind: ServiceAccount
        namespace: fleet-system
        apiGroup: ""
      taints:                   
        - key: any-key
          value: any-value
          effect: NoSchedule
    ```
2. Next, create, and apply a `ClusterResourcePlacementEviction`.

    ```yaml
    apiVersion: placement.kubernetes-fleet.io/v1beta1
    kind: ClusterResourcePlacementEviction
    metadata:
      name: eviction-sample
    spec:
      placementName: crp-app-sample
      clusterName: member-cluster-02
    ```
3. Check that the specified resources are removed from the `member-cluster-02` cluster:

    ```bash
    kubectl get crpe eviction-sample
    ```

    Which results in the following output, with `EXECUTED` showing `True`.

    ```output
    NAME            VALID   EXECUTED
    test-eviction   True    True 
    ```

Now that you understand how to force the removal of placed resources from clusters, let's see how you can protect key resources from eviction.

## Protect against eviction (preview)

The `ClusterResourcePlacementDisruptionBudget` object protects against voluntary disruptions which occur when a `ClusterResourcePlacementEviction` object is applied against a placed resource. Involuntary disruptions aren't protected against.

For the sample cluster resource placement shown earlier in this article, you can define a placement disruption budget object as follows.

The name of the disruption budget must match the CRP.

```yaml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ClusterResourcePlacementDisruptionBudget
metadata:
  name: crp-app-sample
spec:
  minAvailable: 1
```

You can specify one of the following two mutually exclusive fields in the spec:

- **maxUnavailable:** the maximum number of clusters in which a placement can be unavailable due to any form of disruptions.
- **minAvailable:** the minimum number of clusters in which placements are available despite any form of disruptions.

Both fields can be either an absolute number of clusters as an integer or as a percentage of the total number of clusters in the fleet.

When specifying a disruption budget for a particular `ClusterResourcePlacement` policy, you can refer to the following support matrix:

| CRP policy | `minAvailable`(integer) | `minAvailable`(%) | `maxUnavailable`(integer) | `MaxUnavailable`(%) |
| --- | --- | --- | --- | --- |
| `PickFixed` | ❌ | ❌ | ❌ | ❌ |
| `PickAll` | ✅ | ❌ | ❌ | ❌ |
| `PickN` | ✅ | ✅ | ✅ | ✅ |

Note

If you create an invalid disruption budget object for a placement, any eviction attempts fail.

### Validate that eviction is blocked

You can check that a configured disruption budget blocked an eviction as follows.

```bash
kubectl get crpe eviction-sample
```

Notice the `EXECUTED` field displays `False`, indicating the eviction wasn't applied.

```output
NAME            VALID   EXECUTED
test-eviction   True    False
```

To confirm the disruption budget blocked the eviction, issue the same `kubectl` command and add `-o yaml`. The `message` value shows the disruption budget blocked the eviction.

```yaml
status:
  conditions:
  - lastTransitionTime: "2025-01-21T15:52:29Z"
    message: Eviction is valid
    observedGeneration: 1
    reason: ClusterResourcePlacementEvictionValid
    status: "True"
    type: Valid
  - lastTransitionTime: "2025-01-21T15:52:29Z"
    message: 'Eviction is blocked by specified ClusterResourcePlacementDisruptionBudget,
      availablePlacements: 1, totalPlacements: 1'
    observedGeneration: 1
    reason: ClusterResourcePlacementEvictionNotExecuted
    status: "False"
    type: Executed
```

### Involuntary disruption

Placement disruption budgets **do not protect against involuntary disruption**. Examples of involuntary disruption include:

- Removal of resources from a member cluster by the Fleet Manager scheduler due to scheduling policy changes.
- Manual deletion of workload resources running on a member cluster (not via eviction or updated CRP).
- Manual deletion of a `ClusterResourceBinding` object which is an internal resource representing the placement of resources on a member cluster.
- Workloads failing to run properly on a member cluster due to misconfiguration or cluster related issues.