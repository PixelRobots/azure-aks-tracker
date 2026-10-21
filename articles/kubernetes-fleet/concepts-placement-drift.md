---
layout: Conceptual
title: Detecting and managing workload drift with Azure Kubernetes Fleet Manager resource placement | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/concepts-placement-drift
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
description: This article describes how to use the applyStrategy property to control how Fleet Manager identifies and handles drift in workloads managed by resource placement.
ms.date: 2026-07-28T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
ms.topic: concept-article
locale: en-us
document_id: f93aaa4e-21f1-3ba8-1cd1-55cd084789d9
document_version_independent_id: 22d18721-2360-fd1b-db77-bbad1e0374f2
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/concepts-placement-drift.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: kubernetes-fleet/concepts-placement-drift
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/concepts-placement-drift.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 77996f39-ec86-3938-590c-a69fd3b093a2
---

# Detecting and managing workload drift with Azure Kubernetes Fleet Manager resource placement | Microsoft Learn

**Applies to**: ✔️ Fleet Manager with hub cluster

Authorized users can make direct changes to fields on workloads placed onto member clusters. These changes cause a *drift* between the Fleet Manager workload definition and the placed workload. These drifts can result in issues when new deployments occur, potentially leading to application outages.

In this article, we look at how you can use an `applyStrategy` property in a resource placement (cluster-scoped `ClusterResourcePlacement` or namespace-scoped `ResourcePlacement`) to determine how Fleet Manager detects and handles these drifts.

Note

If you aren't already familiar with Fleet Manager's resource placement concepts, read the [cluster-scoped resource placement overview](concepts-resource-placement) and the [namespace-scoped resource placement overview](concepts-namespace-scoped-resource-propagation) before reading this article.

Important

Azure Kubernetes Fleet Manager preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. Azure Kubernetes Fleet Manager previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use.

Our data plane previews are released via our v1beta1 API. If you don't see preview objects, check that you're requesting the v1beta1 API when you interact with the Fleet Manager hub cluster.

## Detect differences across a fleet

This section provides an overview of the `ReportDiff` apply mode, which can be used to evaluate configuration state of placed workload across a fleet at any time.

Using the `ReportDiff` mode, Fleet Manager checks for configuration differences between the [hub cluster](access-fleet-hub-cluster-kubernetes-api) workload definition and corresponding placed workloads on the member clusters, reporting the results in the resource placement status.

### ClusterResourcePlacement example

In the following sample, Fleet Manager reports differences for the namespace `web` for any member cluster with the placed namespace.

```yml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ClusterResourcePlacement
metadata:
  name: crp-reportdiff-sample
spec:
  resourceSelectors:
    - group: ""
      kind: Namespace
      version: v1
      labelSelector:
        matchLabels:
          app: web
  policy:
    placementType: PickAll
  strategy:
    applyStrategy:
      type: ReportDiff 
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 100%
      unavailablePeriodSeconds: 1
```

Apply the `ClusterResourcePlacement` to your Fleet Manager hub cluster.

```bash
kubectl apply -f crp-reportdiff-sample.yaml
```

### ResourcePlacement example

In the following sample, Fleet Manager reports differences for a deployment in the `web` namespace.

```yml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ResourcePlacement
metadata:
  name: rp-reportdiff-sample
  namespace: web
spec:
  resourceSelectors:
    - group: "apps"
      kind: Deployment
      name: web-app
      version: v1
  policy:
    placementType: PickAll
  strategy:
    applyStrategy:
      type: ReportDiff 
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 100%
      unavailablePeriodSeconds: 1
```

Apply the `ResourcePlacement` to your Fleet Manager hub cluster.

```bash
kubectl apply -f rp-reportdiff-sample.yaml
```

### Report on drifted clusters

Using the following commands you can determine which clusters have configuration drift. The [jq command](https://github.com/jqlang/jq) is used to format the output.

**For ClusterResourcePlacement:**

Replace `crp-reportdiff-sample` with the name of your `ClusterResourcePlacement`.

```bash
kubectl get clusterresourceplacement.v1beta1.placement.kubernetes-fleet.io crp-reportdiff-sample -o jsonpath='{.status.placementStatuses}' \
    | jq '[.[] | select (.diffedPlacements != null)] | map({clusterName, diffedPlacements})'
```

**For ResourcePlacement:**

Replace `rp-reportdiff-sample` with the name of your `ResourcePlacement` and `web` with your namespace.

```bash
kubectl get resourceplacement.v1beta1.placement.kubernetes-fleet.io rp-reportdiff-sample -n web -o jsonpath='{.status.placementStatuses}' \
    | jq '[.[] | select (.diffedPlacements != null)] | map({clusterName, diffedPlacements})'
```

The command results in a response containing JSON similar to the following snippet. In this sample, we can see that someone has directly overwritten the owner label on this cluster.

```json
{
    "clusterName": "member-2",
    "diffedPlacements": [
        {
            "firstDiffedObservedTime": "2025-03-19T06:49:54Z",
            "kind": "Namespace",
            "name": "web",
            "observationTime": "2025-03-19T06:50:25Z",
            "observedDiffs": [
                {
                    "path": "/metadata/labels/owner",
                    "valueInHub": "simon",
                    "valueInMember": "chen"
                }
            ],
            "targetClusterObservedGeneration": 0,
            "version": "v1" 
        }
    ]
}
```

Fleet Manager reports the following information about configuration differences:

- `clusterName`: the member cluster on which the differences were detected.
- `diffedPlacements`: a list of differences detected, with the following details:
    - `group`, `kind`, `version`, `namespace`, and `name`: identifying properties of the resource that has configuration differences (not all are shown in the sample).
    - `observationTime`: when the current difference detail was collected.
    - `firstDiffedObservedTime`: when the difference was first observed (might differ from `observationTime`).
    - `observedDiffs`: the diff details, specifically:
        - `path`: A JSON path ([Request for Comments (RFC) 6901](https://datatracker.ietf.org/doc/html/rfc6901)) that points to the field with a different value;
        - `valueInHub`: the value at the JSON path as seen from the hub cluster workload definition (the desired state). If this value is absent, the field doesn't exist in the hub cluster workload definition.
        - `valueInMember`: the value at the JSON path as seen from the member cluster workload (the current state). If this value is absent, the field doesn't exist on the member cluster.
    - `targetClusterObservedGeneration`: the generation of the member cluster workload.

Important items to note when using `ReportDiff`:

- Fleet Manager only reports differences on resources that have corresponding manifests on the hub cluster. If, for example, a namespace-scoped object exists on the member cluster but not on the hub cluster, Fleet Manager ignores the object, even if its owner namespace is selected for placement.
- No apply operation is run and it's up to you to decide the best way to handle any identified configuration differences.
- Difference reporting is successful and complete as soon as Fleet Manager finishes checking all resources. Whether configuration differences exist or not has no effect on the difference reporting success status.
- When a resource change is applied on the hub cluster, for resource placements of the `ReportDiff` mode, the change is immediately rolled out to all member clusters (when the rollout strategy is set to RollingUpdate, the default type), as soon as diff reporting is complete.

## Handle drifted clusters during deployments

Reporting on drifted state across a fleet using ReportDiff is a point-in-time activity so it's always possible that configurations drift between a check and a deployment.

In this section, we look at how you use a `whenToApply` property of an `applyStrategy` to explicitly control how Fleet Manager handles drifted workloads when performing placements.

The `whenToApply` property features two options:

- `Always`: Fleet Manager periodically applies the workload definition from the hub cluster to matching member clusters, regardless of their drifted status. This behavior is the default for both `ClusterResourcePlacement` and `ResourcePlacement` without an explicit `whenToApply` setting.
- `IfNotDrifted`: Fleet Manager checks for drifts periodically. If drifts are found, Fleet Manager stops applying the hub cluster workload definition and reports in the resource placement status.

Note

The presence of drifts **doesn't stop** Fleet Manager from rolling out newer workload versions. If you edit the workload definition on the hub cluster, Fleet Manager always applies the new workload definition.

### Define which fields are used for comparison

You can use an optional `comparisonOption` property to fine-tune how `whenToApply` determines configuration differences.

- `PartialComparison`: only fields that are present on the hub cluster workload and on the target cluster workload are used for value comparison. Any extra unmanaged fields on the target cluster workload are ignored. This behavior is the default without an explicit `comparisonOption` setting.
- `FullComparison`: all fields on the workload definition on the Fleet hub cluster must be present on the selected member cluster. If the target cluster has any extra unmanaged fields, then it fails comparison.

### ClusterResourcePlacement example

In the following sample, if a change is found in any field (managed or unmanaged), the placement fails.

```yml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ClusterResourcePlacement
metadata:
  name: crp-deploy-drift-sample
spec:
  resourceSelectors:
    - group: ""
      kind: Namespace
      version: v1
      labelSelector:
        matchLabels:
          app: web
  policy:
    placementType: PickAll
  strategy:
    applyStrategy:
      comparisonOption: FullComparison    
      whenToApply: IfNotDrifted
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 100%
      unavailablePeriodSeconds: 1                
```

### ResourcePlacement example

In the following sample, if a change is found in any field (managed or unmanaged), the placement fails.

```yml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ResourcePlacement
metadata:
  name: rp-deploy-drift-sample
  namespace: web
spec:
  resourceSelectors:
    - group: "apps"
      kind: Deployment
      name: web-app
      version: v1
  policy:
    placementType: PickAll
  strategy:
    applyStrategy:
      comparisonOption: FullComparison    
      whenToApply: IfNotDrifted
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 100%
      unavailablePeriodSeconds: 1                
```

### Placement behavior summary

The following table summarizes the placement behavior depending on the `whenToApply` and `comparisonOption` values selected.

| `whenToApply`setting | `comparisonOption`setting | Field type | Outcome |
| --- | --- | --- | --- |
| `IfNotDrifted` | `PartialComparison` | Managed field (hub cluster workload definition) edited on member cluster. | Apply error reported, plus the drift details. |
| `IfNotDrifted` | `PartialComparison` | Unmanaged field (not present in hub cluster workload definition) is edited/added on member cluster. | Change is ignored and left untouched. |
| `IfNotDrifted` | `FullComparison` | Any field is edited/added on member cluster. | Apply error reported, plus the drift details. |
| `Always` | `PartialComparison` | Managed field (hub cluster workload definition) edited on member cluster. | Change is overwritten. |
| `Always` | `PartialComparison` | Unmanaged field (not present in hub cluster workload definition) is edited/added on member cluster. | Change is ignored and left untouched. |
| `Always` | `FullComparison` | Any field is edited/added on member cluster. | Managed fields are overwritten; Drift details reported on unmanaged fields, but not considered as an apply error. |