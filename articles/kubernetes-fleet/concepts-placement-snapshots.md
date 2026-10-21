---
layout: Conceptual
title: Understanding snapshots for Azure Kubernetes Fleet Manager resource placement | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/concepts-placement-snapshots
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
description: This article describes how Fleet Manager's cluster resource placement and resource placement manage snapshots.
ms.date: 2026-07-24T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
ms.topic: concept-article
locale: en-us
document_id: 34169e00-d6c3-a203-2bad-e72b39286da4
document_version_independent_id: 30fcfc9f-88fd-455b-bd3e-f7229f361e85
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/concepts-placement-snapshots.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: kubernetes-fleet/concepts-placement-snapshots
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/concepts-placement-snapshots.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 5752b180-e9a5-266f-f429-1bff286560e1
---

# Understanding snapshots for Azure Kubernetes Fleet Manager resource placement | Microsoft Learn

**Applies to**: ✔️ Fleet Manager with hub cluster

Fleet Manager keeps a history of the 10 most recently used placement scheduling policies, along with resource versions the placement selected. These policy and resource versions are held as snapshot objects:

- For **ClusterResourcePlacement** (CRP): `ClusterSchedulingPolicySnapshot` and `ClusterResourceSnapshot` (cluster-scoped)
- For **ResourcePlacement** (RP): `SchedulingPolicySnapshot` and `ResourceSnapshot` (namespace-scoped)

In this article, we explore these objects so you can understand them should you wish to work with them.

Note

If you aren't already familiar with Fleet Manager's resource placement:

- For cluster-scoped resources, read the [conceptual overview of ClusterResourcePlacement (CRP)](concepts-resource-placement).
- For namespace-scoped resources, read the [conceptual overview of ResourcePlacement (RP)](concepts-namespace-scoped-resource-propagation).

## How resource snapshots are created

Any change to resources covered by the scope of CRP or RP resource selector will automatically trigger the creation of a new resource snapshot within 60 seconds.

## Viewing resource snapshots

You can view the resource snapshots held by Fleet Manager using the following steps when connected to the [Fleet Manager hub cluster](access-fleet-hub-cluster-kubernetes-api).

### Viewing ClusterResourceSnapshot (for ClusterResourcePlacement)

For cluster-scoped placements using `ClusterResourcePlacement`, view `ClusterResourceSnapshot` objects.

In this sample, we use an updated ConfigMap, leading to two snapshots.

```bash
kubectl get clusterresourcesnapshots --show-labels
```

We see two snapshots, with the most recent one marked as the latest (`kubernetes-fleet.io/is-latest-snapshot=true`), with a resource-index of 1 (`kubernetes-fleet.io/resource-index=1`).

```output
NAME                           GEN   AGE    LABELS
example-placement-0-snapshot   1     17m    kubernetes-fleet.io/is-latest-snapshot=false,kubernetes-fleet.io/parent-CRP=example-placement,kubernetes-fleet.io/resource-index=0
example-placement-1-snapshot   1     2m2s   kubernetes-fleet.io/is-latest-snapshot=true,kubernetes-fleet.io/parent-CRP=example-placement,kubernetes-fleet.io/resource-index=1
```

We can inspect the contents of the `example-placement-1-snapshot` object as follows.

```bash
kubectl get clusterresourcesnapshots example-placement-1-snapshot -o yaml
```

```yaml
apiVersion: placement.kubernetes-fleet.io/v1
kind: ClusterResourceSnapshot
metadata:
  ...
  labels:
    kubernetes-fleet.io/is-latest-snapshot: "true"
    kubernetes-fleet.io/parent-CRP: example-placement
    kubernetes-fleet.io/resource-index: "1"
  name: example-placement-1-snapshot
  ...
spec:
  selectedResources:
  - apiVersion: v1
    kind: Namespace
    metadata:
      labels:
        kubernetes.io/metadata.name: test-namespace
      name: test-namespace
    spec:
      finalizers:
      - kubernetes
  - apiVersion: v1
    data:
      key: value2
    kind: ConfigMap
    metadata:
      name: test-cm
      namespace: test-namespace
```

### Viewing ResourceSnapshot (for ResourcePlacement)

For namespace-scoped placements using `ResourcePlacement`, view `ResourceSnapshot` objects within the namespace.

In this sample, we have a `ResourcePlacement` in the `my-app` namespace with updated ConfigMaps, leading to two snapshots.

```bash
kubectl get resourcesnapshots -n my-app --show-labels
```

We see two snapshots, with the most recent one marked as the latest (`kubernetes-fleet.io/is-latest-snapshot=true`), with a resource-index of 1 (`kubernetes-fleet.io/resource-index=1`).

```output
NAME                               GEN   AGE    LABELS
app-configs-rp-0-snapshot          1     15m    kubernetes-fleet.io/is-latest-snapshot=false,kubernetes-fleet.io/parent-CRP=app-configs-rp,kubernetes-fleet.io/resource-index=0
app-configs-rp-1-snapshot          1     1m3s   kubernetes-fleet.io/is-latest-snapshot=true,kubernetes-fleet.io/parent-CRP=app-configs-rp,kubernetes-fleet.io/resource-index=1
```

We can inspect the contents of the `app-configs-rp-1-snapshot` object as follows.

```bash
kubectl get resourcesnapshots app-configs-rp-1-snapshot -n my-app -o yaml
```

```yaml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ResourceSnapshot
metadata:
  ...
  labels:
    kubernetes-fleet.io/is-latest-snapshot: "true"
    kubernetes-fleet.io/parent-CRP: app-configs-rp
    kubernetes-fleet.io/resource-index: "1"
  name: app-configs-rp-1-snapshot
  namespace: my-app
  ...
spec:
  selectedResources:
  - apiVersion: v1
    data:
      config: updated-value
    kind: ConfigMap
    metadata:
      name: app-config
      namespace: my-app
      labels:
        app: my-application
```

## Using resource snapshots

Snapshots can be used as part of staged rollouts managed via update runs as a rollback mechanism. Both `ClusterResourcePlacement` and `ResourcePlacement` support staged rollouts with their respective snapshot types:

- For `ClusterResourcePlacement`: Uses `ClusterResourceSnapshot` objects with `ClusterStagedUpdateRun`
- For `ResourcePlacement`: Uses `ResourceSnapshot` objects with `StagedUpdateRun`

See [Staged rollout strategy](concepts-rollout-strategy#staged-update-strategy) for details on how to implement staged rollouts for both resource placement types.

## Modifying the snapshot history limit

To change the number of items held in history, add a `revisionHistoryLimit` field to your placement and provide an integer value. The default value is 10.

### For ClusterResourcePlacement

```yaml
apiVersion: placement.kubernetes-fleet.io/v1
kind: ClusterResourcePlacement
metadata:
  name: crp-example
spec:
  revisionHistoryLimit: 20   # keep 20 items in history
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
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 50%
```

### For ResourcePlacement

```yaml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ResourcePlacement
metadata:
  name: rp-example
  namespace: my-app
spec:
  revisionHistoryLimit: 20   # keep 20 items in history
  resourceSelectors:
    - group: ""
      kind: ConfigMap
      version: v1
      labelSelector:
        matchLabels:
          app: my-application
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
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 50%
```