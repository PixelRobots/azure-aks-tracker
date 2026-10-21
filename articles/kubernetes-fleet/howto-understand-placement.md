---
layout: Conceptual
title: Understanding the status for Azure Kubernetes Fleet Manager resource placement | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/howto-understand-placement
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
zone_pivot_group_filename: zone-pivots/azure-aks/zone-pivot-groups.json
adobe-target: true
learn_banner_products:
- azure
description: Learn how to interpret the status fields of Azure Kubernetes Fleet Manager resource placement.
ms.topic: how-to
ms.date: 2026-06-19T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
zone_pivot_groups: cluster-namespace-scope
locale: en-us
document_id: 27fb9778-ed6e-b313-30d0-41e4f0165253
document_version_independent_id: 6b61c452-b60c-50fd-daaa-f09053278190
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/howto-understand-placement.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: kubernetes-fleet/howto-understand-placement
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/howto-understand-placement.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
platformId: e179c8a5-0bae-07b8-1e87-b762a5d34779
---

# Understanding the status for Azure Kubernetes Fleet Manager resource placement | Microsoft Learn

**Applies to:** ✔️ Fleet Manager with hub cluster

::: zone pivot="cluster-scope"

When you work with Azure Kubernetes Fleet Manager, understanding the status of your `ClusterResourcePlacement` resources is crucial for monitoring deployment progress and troubleshooting issues.

::: zone-end

::: zone pivot="namespace-scope"

When you work with Azure Kubernetes Fleet Manager, understanding the status of your `ResourcePlacement` resources is crucial for monitoring deployment progress and troubleshooting issues.

::: zone-end

## Prerequisites

- You have a Fleet Manager with a hub cluster and one or more member clusters. If you don't have one, see [Create an Azure Kubernetes Fleet Manager resource and join member clusters](quickstart-create-fleet-and-members).
- You have access to the Fleet Manager hub cluster. For more information, see [Access the Kubernetes API for an Azure Kubernetes Fleet Manager hub cluster](access-fleet-hub-cluster-kubernetes-api).

::: zone pivot="cluster-scope"

- You deployed at least one `ClusterResourcePlacement` to distribute your resources. If you didn't, see [Use cluster resource placement to deploy workloads across multiple clusters](quickstart-resource-propagation).

::: zone-end

::: zone pivot="namespace-scope"

- You deployed at least one ResourcePlacement API object to place your resources into the fleet. If you didn't, see [Use cluster resource placement to deploy workloads across multiple clusters](quickstart-namespace-scoped-resource-propagation).

::: zone-end

## Overview of placement status structure

::: zone pivot="cluster-scope"

The `ClusterResourcePlacement` object contains not only the descriptive spec about the placement, but also the status of the placement operation.

::: zone-end

::: zone pivot="namespace-scope"

The `ResourcePlacement` object contains not only the descriptive spec about the placement, but also the status of the placement operation.

::: zone-end

The status section provides detailed information about:

- Overall placement status expressed through conditions
- Resources selected by the placement
- Per-cluster placement status expressed through conditions
- `Failed`, `drifted`, and `diffed` placements in each cluster

To view the status of a placement, use the following command:

::: zone pivot="cluster-scope"

```bash
kubectl describe clusterresourceplacement <placement-name>
```

::: zone-end

::: zone pivot="namespace-scope"

```bash
kubectl describe resourceplacement <placement-name> -n <namespace-name>
```

::: zone-end

To get the raw YAML output, use the following command:

::: zone pivot="cluster-scope"

```bash
kubectl get clusterresourceplacement <placement-name> -o yaml
```

::: zone-end

::: zone pivot="namespace-scope"

```bash
kubectl get resourceplacement <placement-name> -n <namespace-name> -o yaml
```

::: zone-end

## Top-level status fields

The status section contains the following top-level fields:

- **selectedResources**: List of resources selected by the placement
- **conditions**: Array of overall placement conditions
- **observedResourceIndex**: Index of the current resource snapshot
- **placementStatuses**: Per-cluster placement status information

The following sections examine each field in detail.

## Selected resources

The `selectedResources` field lists all resources that the placement selects. Use this field to check if the expected resources are included in the placement. Here's an example:

::: zone pivot="cluster-scope"

```yaml
selectedResources:
- kind: Namespace
  name: test
  version: v1
- kind: ConfigMap
  name: test-config
  namespace: test
  version: v1
  envelope:
    name: example-envelope
    namespace: test
    type: ResourceEnvelope
- kind: Deployment
  name: web-app
  namespace: test
  group: apps
  version: v1
- kind: Service
  name: web-service
  namespace: test
  version: v1
- kind: Secret
  name: app-secrets
  namespace: test
  version: v1
```

::: zone-end

::: zone pivot="namespace-scope"

```yaml
selectedResources:
- kind: ConfigMap
  name: test-config
  version: v1
  envelope:
    name: example-envelope
    namespace: test
    type: ResourceEnvelope
- kind: Deployment
  name: web-app
  group: apps
  version: v1
- kind: Service
  name: web-service
  version: v1
- kind: Secret
  name: app-secrets
  version: v1
```

::: zone-end

Each resource entry includes:

- **group**: API group (empty for core resources)
- **version**: API version (for example, `v1`, `v1beta1`)
- **kind**: Resource kind
- **name**: Resource name

::: zone pivot="cluster-scope"

- **namespace**: Namespace (for namespaced resources)

::: zone-end

- **envelope**: If a resource is wrapped in an envelope, the envelope metadata is also provided, which includes:
    - **name**: Name of the envelope

::: zone pivot="cluster-scope"

- **namespace**: Namespace of the envelope

::: zone-end

- **type**: Type of the envelope (for example, `ResourceEnvelope`)

## Placement conditions

The `conditions` array provides high-level status information about the entire placement. Each condition follows the Kubernetes common definition, which has the following standard fields:

- **type**: The condition type (described in the following sections).
- **status**: `True`, `False`, or `Unknown`.
- **reason**: Short reason code for the condition.
- **message**: Human-readable description.
- **lastTransitionTime**: When the condition last changed.
- **observedGeneration**: Generation of the placement when the condition was set.

::: zone pivot="cluster-scope"

### ClusterResourcePlacement condition types

The following condition types are available for ClusterResourcePlacement:

#### ClusterResourcePlacementScheduled

::: zone-end

::: zone pivot="namespace-scope"

### ResourcePlacement condition types

The following condition types are available for ResourcePlacement:

#### ResourcePlacementScheduled

::: zone-end

Indicates whether the placement is successfully scheduled to target clusters.

- **True**: All required clusters are selected according to the placement policy.
- **False**: Scheduling failed (for example, insufficient clusters available).
- **Unknown**: Scheduling decision is pending.

::: zone pivot="cluster-scope"

```yaml
conditions:
- type: ClusterResourcePlacementScheduled
  status: "True"
  reason: SchedulingPolicyFulfilled
  message: "found all the clusters needed as specified by the scheduling policy"
  lastTransitionTime: "2023-11-10T08:14:52Z"
  observedGeneration: 5
```

::: zone-end

::: zone pivot="namespace-scope"

```yaml
conditions:
- type: ResourcePlacementScheduled
  status: "True"
  reason: SchedulingPolicyFulfilled
  message: "found all the clusters needed as specified by the scheduling policy"
  lastTransitionTime: "2023-11-10T08:14:52Z"
  observedGeneration: 5
```

::: zone-end

::: zone pivot="cluster-scope"

#### ClusterResourcePlacementRolloutStarted

::: zone-end

::: zone pivot="namespace-scope"

#### ResourcePlacementRolloutStarted

::: zone-end

Indicates whether the rollout is started across the selected clusters.

- **True**: Resources started rolling out to scheduled clusters.
- **False**: Rollout isn't started yet.
- **Unknown**: Rollout decision is pending.

::: zone pivot="cluster-scope"

```yaml
conditions:
- type: ClusterResourcePlacementRolloutStarted
  status: "True"
  reason: RolloutStarted
  message: "All 3 cluster(s) start rolling out the latest resource"
  lastTransitionTime: "2023-11-10T08:15:30Z"
  observedGeneration: 5
```

::: zone-end

::: zone pivot="namespace-scope"

```yaml
conditions:
- type: ResourcePlacementRolloutStarted
  status: "True"
  reason: RolloutStarted
  message: "All 3 cluster(s) start rolling out the latest resource"
  lastTransitionTime: "2023-11-10T08:15:30Z"
  observedGeneration: 5
```

::: zone-end

::: zone pivot="cluster-scope"

#### ClusterResourcePlacementOverridden

::: zone-end

::: zone pivot="namespace-scope"

#### ResourcePlacementOverridden

::: zone-end

Indicates whether resource overrides are successfully applied.

- **True**: All applicable overrides are processed.
- **False**: Some overrides failed to apply.
- **Unknown**: Override processing is pending.

::: zone pivot="cluster-scope"

```yaml
conditions:
- type: ClusterResourcePlacementOverridden
  status: "True"
  reason: NoOverrideSpecified
  message: "No override rules are configured for the selected resources"
  lastTransitionTime: "2023-11-10T08:15:45Z"
  observedGeneration: 5
```

::: zone-end

::: zone pivot="namespace-scope"

```yaml
conditions:
- type: ResourcePlacementOverridden
  status: "True"
  reason: NoOverrideSpecified
  message: "No override rules are configured for the selected resources"
  lastTransitionTime: "2023-11-10T08:15:45Z"
  observedGeneration: 5
```

::: zone-end

::: zone pivot="cluster-scope"

#### ClusterResourcePlacementWorkSynchronized

::: zone-end

::: zone pivot="namespace-scope"

#### ResourcePlacementWorkSynchronized

::: zone-end

Indicates whether the process creates work objects in the hub cluster's per-cluster namespaces.

- **True**: All work objects are synchronized.
- **False**: Work synchronization fails or is incomplete.
- **Unknown**: Work synchronization is pending.

::: zone pivot="cluster-scope"

```yaml
conditions:
- type: ClusterResourcePlacementWorkSynchronized  
  status: "True"
  reason: SynchronizeSucceeded
  message: "All 2 cluster(s) are synchronized to the latest resources on the hub cluster"
  lastTransitionTime: "2023-11-10T08:23:43Z"
  observedGeneration: 5
```

::: zone-end

::: zone pivot="namespace-scope"

```yaml
conditions:
- type: ResourcePlacementWorkSynchronized  
  status: "True"
  reason: SynchronizeSucceeded
  message: "All 2 cluster(s) are synchronized to the latest resources on the hub cluster"
  lastTransitionTime: "2023-11-10T08:23:43Z"
  observedGeneration: 5
```

::: zone-end

::: zone pivot="cluster-scope"

#### ClusterResourcePlacementApplied

::: zone-end

::: zone pivot="namespace-scope"

#### ResourcePlacementApplied

::: zone-end

Indicates whether all resources are successfully applied to member clusters.

- **True**: All resources applied successfully to all target clusters.
- **False**: Some resources failed to apply (check `failedPlacements`).
- **Unknown**: Apply operation is pending.

::: zone pivot="cluster-scope"

```yaml
conditions:
- type: ClusterResourcePlacementApplied
  status: "True"
  reason: ApplySucceeded
  message: "The selected resources are successfully applied to 3 clusters"
  lastTransitionTime: "2023-11-10T08:16:15Z"
  observedGeneration: 5
```

::: zone-end

::: zone pivot="namespace-scope"

```yaml
conditions:
- type: ResourcePlacementApplied
  status: "True"
  reason: ApplySucceeded
  message: "The selected resources are successfully applied to 3 clusters"
  lastTransitionTime: "2023-11-10T08:16:15Z"
  observedGeneration: 5
```

::: zone-end

::: zone pivot="cluster-scope"

#### ClusterResourcePlacementAvailable

::: zone-end

::: zone pivot="namespace-scope"

#### ResourcePlacementAvailable

::: zone-end

Indicates whether the placed resources are all available and ready on member clusters.

- **True**: All resources are available on all target clusters.
- **False**: Some resources aren't yet available.
- **Unknown**: Availability check is pending.

::: zone pivot="cluster-scope"

```yaml
conditions:
- type: ClusterResourcePlacementAvailable
  status: "True"
  reason: ResourceAvailable
  message: "The selected resources in 3 clusters are available now"
  lastTransitionTime: "2023-11-10T08:16:30Z"
  observedGeneration: 5
```

::: zone-end

::: zone pivot="namespace-scope"

```yaml
conditions:
- type: ResourcePlacementAvailable
  status: "True"
  reason: ResourceAvailable
  message: "The selected resources in 3 clusters are available now"
  lastTransitionTime: "2023-11-10T08:16:30Z"
  observedGeneration: 5
```

::: zone-end

::: zone pivot="cluster-scope"

#### ClusterResourcePlacementDiffReported

::: zone-end

::: zone pivot="namespace-scope"

#### ResourcePlacementDiffReported

::: zone-end

Indicates whether configuration differences are reported (when using ReportDiff strategy).

- **True**: Complete diff report is available.
- **False**: Diff reporting failed or is incomplete.
- **Unknown**: Diff reporting is pending.

::: zone pivot="cluster-scope"

```yaml
conditions:
- type: ClusterResourcePlacementDiffReported
  status: "True"
  reason: DiffReportComplete
  message: "Configuration differences are reported for all target clusters"
  lastTransitionTime: "2023-11-10T08:16:45Z"
  observedGeneration: 5
```

::: zone-end

::: zone pivot="namespace-scope"

```yaml
conditions:
- type: ResourcePlacementDiffReported
  status: "True"
  reason: DiffReportComplete
  message: "Configuration differences are reported for all target clusters"
  lastTransitionTime: "2023-11-10T08:16:45Z"
  observedGeneration: 5
```

::: zone-end

## Resource snapshots

The `observedResourceIndex` field indicates which snapshot of resources is currently being deployed.

```yaml
observedResourceIndex: "1"
```

Fleet Manager creates resource snapshots differently depending on the rollout strategy:

**For `RollingUpdate` strategy (default)**: Fleet Manager automatically creates resource snapshots when:

- The resource selectors change
- You modify the selected resources

**For `External` strategy**: Fleet Manager doesn't automatically create resource snapshots. Instead, it creates them when you execute a staged update run and omit the `resourceSnapshotIndex` field. This condition means that when you first create a placement with an `External` rollout strategy, no resource snapshots exist until you run the first staged update run.

Note

If a placement previously used the `RollingUpdate` strategy and you change it to `External`, the existing resource snapshots remain available. You can reference these existing snapshots when creating staged update runs.

Each snapshot has a unique index. You can view snapshots by using:

::: zone pivot="cluster-scope"

```bash
kubectl get clusterresourcesnapshot --selector=kubernetes-fleet.io/resource-index=1
```

::: zone-end

::: zone pivot="namespace-scope"

```bash
kubectl get resourcesnapshot -n <namespace-name> --selector=kubernetes-fleet.io/resource-index=1
```

::: zone-end

## Per-cluster placement status

The `placementStatuses` array contains detailed status for each cluster where resources are placed or attempted to be placed:

```yaml
placementStatuses:
- clusterName: aks-member-1
  observedResourceIndex: "1"
  conditions:
    - type: ResourceScheduled
      status: "True"
      reason: ScheduleSucceeded
      message: "Successfully scheduled resources for placement in aks-member-1"
      lastTransitionTime: "2023-11-10T08:14:52Z"
      observedGeneration: 5
    - type: RolloutStarted
      status: "True"
      reason: RolloutStarted
      message: "Detected the new changes on the resources and started the rollout process"
      lastTransitionTime: "2023-11-10T08:15:30Z"
      observedGeneration: 5
    - type: Overridden
      status: "True"
      reason: NoOverrideSpecified
      message: "No override rules are configured for the selected resources"
      lastTransitionTime: "2023-11-10T08:15:45Z"
      observedGeneration: 5
    - type: WorkSynchronized
      status: "True"
      reason: AllWorkSynced
      message: "All of the works are synchronized to the latest"
      lastTransitionTime: "2023-11-10T08:16:00Z"
      observedGeneration: 5
    - type: Applied
      status: "True"
      reason: AllWorkHaveBeenApplied
      message: "All corresponding work objects are applied"
      lastTransitionTime: "2023-11-10T08:16:15Z"
      observedGeneration: 5
    - type: Available
      status: "True"
      reason: ResourceAvailable
      message: "All resources are available on the target cluster"
      lastTransitionTime: "2023-11-10T08:16:30Z"
      observedGeneration: 5
  failedPlacements: []
  driftedPlacements: []
  diffedPlacements: []
- clusterName: aks-member-2
  observedResourceIndex: "1"
  conditions:
    - type: ResourceScheduled
      status: "True"
      reason: ScheduleSucceeded
      message: "Successfully scheduled resources for placement in aks-member-2"
      lastTransitionTime: "2023-11-10T08:14:52Z"
      observedGeneration: 5
    - type: Applied
      status: "False"
      reason: AppliedManifestFailedReason
      message: "Failed to apply some manifests"
      lastTransitionTime: "2023-11-10T08:16:15Z"
      observedGeneration: 5
  failedPlacements:
    - kind: Deployment
      name: web-app
      namespace: test
      version: apps/v1
      condition:
        type: Applied
        status: "False"
        reason: AppliedManifestFailedReason
        message: "Failed to apply manifest: insufficient resources"
        lastTransitionTime: "2023-11-10T08:16:15Z"
```

### Per-cluster condition types

Each cluster's status includes conditions that track the deployment lifecycle:

#### ResourceScheduled

Indicates whether the cluster is successfully selected for placement.

```yaml
- type: ResourceScheduled
  status: "True"
  reason: ScheduleSucceeded
  message: "Successfully scheduled resources for placement in aks-member-1 (affinity score: 0, topology spread score: 0): picked by scheduling policy"
  lastTransitionTime: "2023-11-10T08:14:52Z"
  observedGeneration: 5
```

#### RolloutStarted

Indicates whether the rollout started on this specific cluster.

```yaml
- type: RolloutStarted
  status: "True"
  reason: RolloutStarted
  message: "Detected new changes on the resources and started the rollout process"
  lastTransitionTime: "2023-11-10T08:15:30Z"
  observedGeneration: 5
```

#### Overridden

Indicates whether resource overrides are applied for this cluster.

```yaml
- type: Overridden
  status: "True"
  reason: NoOverrideSpecified
  message: "No override rules are configured for the selected resources"
  lastTransitionTime: "2023-11-10T08:15:45Z"
  observedGeneration: 5
```

#### WorkSynchronized

Indicates whether work objects are created for this cluster.

```yaml
- type: WorkSynchronized
  status: "True"
  reason: AllWorkSynced
  message: "All of the works are synchronized to the latest"
  lastTransitionTime: "2023-11-10T08:16:00Z"
  observedGeneration: 5
```

#### Applied

Indicates whether all the resources are successfully applied to this cluster.

```yaml
- type: Applied
  status: "True"
  reason: AllWorkHaveBeenApplied
  message: "All corresponding work objects are applied"
  lastTransitionTime: "2023-11-10T08:16:15Z"
  observedGeneration: 5
```

#### Available

Indicates whether all the resources are available and ready on this cluster.

```yaml
- type: Available
  status: "True"
  reason: ResourceAvailable
  message: "All resources are available on the target cluster"
  lastTransitionTime: "2023-11-10T08:16:30Z"
  observedGeneration: 5
```

#### DiffReported

Indicates whether configuration differences are reported for this cluster.

```yaml
- type: DiffReported
  status: "True"
  reason: DiffReportComplete
  message: "Configuration differences are reported for this cluster"
  lastTransitionTime: "2023-11-10T08:16:45Z"
  observedGeneration: 5
```

## Failed placements

When resources fail to apply to a cluster, the system records the details in the `failedPlacements` array:

```yaml
failedPlacements:
- kind: Deployment
  name: my-app
  namespace: default
  version: apps/v1
  condition:
    type: Applied
    status: "False"
    reason: AppliedManifestFailedReason
    message: "Failed to apply manifest: namespaces 'app' not found"
    lastTransitionTime: "2023-12-06T00:09:53Z"
  envelope:
    name: example
    namespace: app
    type: ResourceEnvelope
- kind: Service
  name: my-service
  namespace: default
  version: v1
  condition:
    type: Applied
    status: "False"
    reason: AppliedManifestFailedReason
    message: "Failed to apply manifest: Service 'my-service' is forbidden: User 'system:serviceaccount:fleet-system:fleet-agent' cannot create resource 'services' in API group '' in the namespace 'default'"
    lastTransitionTime: "2023-12-06T00:10:15Z"
- kind: ConfigMap
  name: app-config
  namespace: production
  version: v1
  condition:
    type: Applied
    status: "False"
    reason: AppliedManifestFailedReason
    message: "Failed to apply manifest: configmaps 'app-config' already exists"
    lastTransitionTime: "2023-12-06T00:10:30Z"
```

Each failed placement includes:

- **Resource identification**: group, version, kind, name, namespace
- **condition**: The specific failure condition
- **envelope**: Envelope information, if applicable

## Drifted placements

Fleet Manager always reports resources that drift from their desired state:

```yaml
driftedPlacements:
- kind: Namespace
  name: web
  version: v1
  observationTime: "2025-03-19T06:50:25Z"
  firstDriftedObservedTime: "2025-03-19T06:49:54Z"
  targetClusterObservedGeneration: 12
  observedDrifts:
  - path: "/metadata/labels/owner"
    valueInHub: "simon"
    valueInMember: "chen"
  - path: "/metadata/annotations/purpose"
    valueInHub: "production"
    valueInMember: "testing"
- kind: Deployment
  name: web-app
  namespace: web
  group: apps
  version: v1
  observationTime: "2025-03-19T06:50:25Z"
  firstDriftedObservedTime: "2025-03-19T06:49:54Z"
  targetClusterObservedGeneration: 8
  observedDrifts:
  - path: "/spec/replicas"
    valueInHub: "3"
    valueInMember: "5"
  - path: "/spec/template/spec/containers/0/image"
    valueInHub: "nginx:1.20"
    valueInMember: "nginx:1.21"
- kind: ConfigMap
  name: app-config
  namespace: web
  version: v1
  observationTime: "2025-03-19T06:50:25Z"
  firstDriftedObservedTime: "2025-03-19T06:49:54Z"
  targetClusterObservedGeneration: 5
  observedDrifts:
  - path: "/data/environment"
    valueInHub: "production"
    valueInMember: "staging"
```

Each drifted placement includes:

- **Resource identification**: group, version, kind, name, namespace
- **observationTime**: When the drift was last observed
- **firstDriftedObservedTime**: When drift was first detected
- **targetClusterObservedGeneration**: Generation of the resource on the member cluster
- **observedDrifts**: Detailed list of configuration differences

## Diffed placements

When you use the ReportDiff apply strategy, Fleet Manager reports configuration differences.

```yaml
diffedPlacements:
- kind: Service
  name: my-service
  namespace: default
  version: v1
  observationTime: "2025-03-19T06:50:25Z"
  firstDiffedObservedTime: "2025-03-19T06:49:54Z"
  targetClusterObservedGeneration: 8
  observedDiffs:
  - path: "/spec/ports/0/nodePort"
    valueInHub: ""
    valueInMember: "30080"
  - path: "/spec/clusterIP"
    valueInHub: ""
    valueInMember: "10.96.100.200"
- kind: Deployment
  name: web-app
  namespace: default
  group: apps
  version: v1
  observationTime: "2025-03-19T06:50:25Z"
  firstDiffedObservedTime: "2025-03-19T06:49:54Z"
  targetClusterObservedGeneration: 12
  observedDiffs:
  - path: "/status/replicas"
    valueInHub: ""
    valueInMember: "3"
  - path: "/status/readyReplicas"
    valueInHub: ""
    valueInMember: "3"
  - path: "/metadata/generation"
    valueInHub: "1"
    valueInMember: "2"
```

Diffed placements have a similar structure to drifted placements but are used for different scenarios:

- **Drifted placements**: Use when you apply resources but then change them.
- **Diffed placements**: Use with ReportDiff strategy or when takeover conditions aren't met.

## Monitoring placement progress

To effectively monitor placement progress, check these key indicators:

::: zone pivot="cluster-scope"

1. **Resource placed**: Verify `ClusterResourcePlacementWorkSynchronized` is True
2. **Overall health**: Look at the `ClusterResourcePlacementApplied` condition
3. **Per-cluster status**: Review conditions for each target cluster
4. **Failed placements**: Check for any entries in `failedPlacements` arrays

::: zone-end

::: zone pivot="namespace-scope"

1. **Resource placed**: Verify `ResourcePlacementWorkSynchronized` is True
2. **Overall health**: Look at the `ResourcePlacementApplied` condition
3. **Per-cluster status**: Review conditions for each target cluster
4. **Failed placements**: Check for any entries in `failedPlacements` arrays

::: zone-end

## Complete status example

::: zone pivot="cluster-scope"

Here's a comprehensive example showing the complete status of a ClusterResourcePlacement:

```yaml
apiVersion: placement.kubernetes-fleet.io/v1
kind: ClusterResourcePlacement
metadata:
  name: web-app-placement
  generation: 5
spec:
  resourceSelectors:
  - group: ""
    kind: Namespace
    name: web-app
    version: v1
  - group: apps
    kind: Deployment
    name: web-server
    namespace: web-app
    version: v1
  - group: ""
    kind: Service
    name: web-service
    namespace: web-app
    version: v1
  policy:
    placementType: PickN
    numberOfClusters: 2
    affinity:
      clusterAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          clusterSelectorTerms:
          - matchLabels:
              region: us-west
status:
  conditions:
  - type: ClusterResourcePlacementScheduled
    status: "True"
    reason: SchedulingPolicyFulfilled
    message: "found all the clusters needed as specified by the scheduling policy"
    lastTransitionTime: "2023-11-10T08:14:52Z"
    observedGeneration: 5
  - type: ClusterResourcePlacementRolloutStarted
    status: "True"
    reason: RolloutStarted
    message: "All 2 cluster(s) start rolling out the latest resource"
    lastTransitionTime: "2023-11-10T08:15:30Z"
    observedGeneration: 5
  - type: ClusterResourcePlacementOverridden
    status: "True"
    reason: NoOverrideSpecified
    message: "No override rules are configured for the selected resources"
    lastTransitionTime: "2023-11-10T08:15:45Z"
    observedGeneration: 5
  - type: ClusterResourcePlacementWorkSynchronized
    status: "True"
    reason: SynchronizeSucceeded
    message: "All 2 cluster(s) are synchronized to the latest resources on the hub cluster"
    lastTransitionTime: "2023-11-10T08:16:00Z"
    observedGeneration: 5
  - type: ClusterResourcePlacementApplied
    status: "True"
    reason: ApplySucceeded
    message: "The selected resources are successfully applied to 2 clusters"
    lastTransitionTime: "2023-11-10T08:16:15Z"
    observedGeneration: 5
  - type: ClusterResourcePlacementAvailable
    status: "True"
    reason: ResourceAvailable
    message: "The selected resources in 2 cluster are available now"
    lastTransitionTime: "2023-11-10T08:16:30Z"
    observedGeneration: 5
  observedResourceIndex: "1"
  selectedResources:
  - group: ""
    kind: Namespace
    name: web-app
    version: v1
  - group: apps
    kind: Deployment
    name: web-server
    namespace: web-app
    version: v1
  - group: ""
    kind: Service
    name: web-service
    namespace: web-app
    version: v1
  placementStatuses:
  - clusterName: aks-west-1
    observedResourceIndex: "1"
    conditions:
    - type: ResourceScheduled
      status: "True"
      reason: ScheduleSucceeded
      message: "Successfully scheduled resources for placement in aks-west-1 (affinity score: 0, topology spread score: 0): picked by scheduling policy"
      lastTransitionTime: "2023-11-10T08:14:52Z"
      observedGeneration: 5
    - type: RolloutStarted
      status: "True"
      reason: RolloutStarted
      message: "Detected the new changes on the resources and started the rollout process"
      lastTransitionTime: "2023-11-10T08:15:30Z"
      observedGeneration: 5
    - type: Overridden
      status: "True"
      reason: NoOverrideSpecified
      message: "No override rules are configured for the selected resources"
      lastTransitionTime: "2023-11-10T08:15:45Z"
      observedGeneration: 5
    - type: WorkSynchronized
      status: "True"
      reason: AllWorkSynced
      message: "All of the works are synchronized to the latest"
      lastTransitionTime: "2023-11-10T08:16:00Z"
      observedGeneration: 5
    - type: Applied
      status: "True"
      reason: AllWorkHaveBeenApplied
      message: "All corresponding work objects are applied"
      lastTransitionTime: "2023-11-10T08:16:15Z"
      observedGeneration: 5
    - type: Available
      status: "True"
      reason: ResourceAvailable
      message: "All resources are available on the target cluster"
      lastTransitionTime: "2023-11-10T08:16:30Z"
      observedGeneration: 5
    failedPlacements: []
    driftedPlacements: []
    diffedPlacements: []
  - clusterName: aks-west-2
    observedResourceIndex: "1"
    conditions:
    - type: ResourceScheduled
      status: "True"
      reason: ScheduleSucceeded
      message: "Successfully scheduled resources for placement in aks-west-2 (affinity score: 0, topology spread score: 0): picked by scheduling policy"
      lastTransitionTime: "2023-11-10T08:14:52Z"
      observedGeneration: 5
    - type: RolloutStarted
      status: "True"
      reason: RolloutStarted
      message: "Detected new changes on the resources and started the rollout process"
      lastTransitionTime: "2023-11-10T08:15:30Z"
      observedGeneration: 5
    - type: Overridden
      status: "True"
      reason: NoOverrideSpecified
      message: "No override rules are configured for the selected resources"
      lastTransitionTime: "2023-11-10T08:15:45Z"
      observedGeneration: 5
    - type: WorkSynchronized
      status: "True"
      reason: AllWorkSynced
      message: "All of the works are synchronized to the latest"
      lastTransitionTime: "2023-11-10T08:16:00Z"
      observedGeneration: 5
    - type: Applied
      status: "True"
      reason: AllWorkHaveBeenApplied
      message: "All corresponding work objects are applied"
      lastTransitionTime: "2023-11-10T08:16:15Z"
      observedGeneration: 5
    - type: Available
      status: "True"
      reason: ResourceAvailable
      message: "All resources are available on the target cluster"
      lastTransitionTime: "2023-11-10T08:16:30Z"
      observedGeneration: 5
    failedPlacements: []
    driftedPlacements: []
    diffedPlacements: []
```

::: zone-end

::: zone pivot="namespace-scope"

Here's a comprehensive example showing the complete status of a ResourcePlacement:

```yaml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ResourcePlacement
metadata:
  name: web-app-placement
  namespace: web-app
  generation: 5
spec:
  resourceSelectors:
  - group: apps
    kind: Deployment
    name: web-server
    version: v1
  - group: ""
    kind: Service
    name: web-service
    version: v1
  policy:
    placementType: PickN
    numberOfClusters: 2
    affinity:
      clusterAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          clusterSelectorTerms:
          - matchLabels:
              region: us-west
status:
  conditions:
  - type: ResourcePlacementScheduled
    status: "True"
    reason: SchedulingPolicyFulfilled
    message: "found all the clusters needed as specified by the scheduling policy"
    lastTransitionTime: "2023-11-10T08:14:52Z"
    observedGeneration: 5
  - type: ResourcePlacementRolloutStarted
    status: "True"
    reason: RolloutStarted
    message: "All 2 cluster(s) start rolling out the latest resource"
    lastTransitionTime: "2023-11-10T08:15:30Z"
    observedGeneration: 5
  - type: ResourcePlacementOverridden
    status: "True"
    reason: NoOverrideSpecified
    message: "No override rules are configured for the selected resources"
    lastTransitionTime: "2023-11-10T08:15:45Z"
    observedGeneration: 5
  - type: ResourcePlacementWorkSynchronized
    status: "True"
    reason: SynchronizeSucceeded
    message: "All 2 cluster(s) are synchronized to the latest resources on the hub cluster"
    lastTransitionTime: "2023-11-10T08:16:00Z"
    observedGeneration: 5
  - type: ResourcePlacementApplied
    status: "True"
    reason: ApplySucceeded
    message: "The selected resources are successfully applied to 2 clusters"
    lastTransitionTime: "2023-11-10T08:16:15Z"
    observedGeneration: 5
  - type: ResourcePlacementAvailable
    status: "True"
    reason: ResourceAvailable
    message: "The selected resources in 2 cluster are available now"
    lastTransitionTime: "2023-11-10T08:16:30Z"
    observedGeneration: 5
  observedResourceIndex: "1"
  selectedResources:
  - group: apps
    kind: Deployment
    name: web-server
    version: v1
  - group: ""
    kind: Service
    name: web-service
    version: v1
  placementStatuses:
  - clusterName: aks-west-1
    observedResourceIndex: "1"
    conditions:
    - type: ResourceScheduled
      status: "True"
      reason: ScheduleSucceeded
      message: "Successfully scheduled resources for placement in aks-west-1 (affinity score: 0, topology spread score: 0): picked by scheduling policy"
      lastTransitionTime: "2023-11-10T08:14:52Z"
      observedGeneration: 5
    - type: RolloutStarted
      status: "True"
      reason: RolloutStarted
      message: "Detected the new changes on the resources and started the rollout process"
      lastTransitionTime: "2023-11-10T08:15:30Z"
      observedGeneration: 5
    - type: Overridden
      status: "True"
      reason: NoOverrideSpecified
      message: "No override rules are configured for the selected resources"
      lastTransitionTime: "2023-11-10T08:15:45Z"
      observedGeneration: 5
    - type: WorkSynchronized
      status: "True"
      reason: AllWorkSynced
      message: "All of the works are synchronized to the latest"
      lastTransitionTime: "2023-11-10T08:16:00Z"
      observedGeneration: 5
    - type: Applied
      status: "True"
      reason: AllWorkHaveBeenApplied
      message: "All corresponding work objects are applied"
      lastTransitionTime: "2023-11-10T08:16:15Z"
      observedGeneration: 5
    - type: Available
      status: "True"
      reason: ResourceAvailable
      message: "All resources are available on the target cluster"
      lastTransitionTime: "2023-11-10T08:16:30Z"
      observedGeneration: 5
    failedPlacements: []
    driftedPlacements: []
    diffedPlacements: []
  - clusterName: aks-west-2
    observedResourceIndex: "1"
    conditions:
    - type: ResourceScheduled
      status: "True"
      reason: ScheduleSucceeded
      message: "Successfully scheduled resources for placement in aks-west-2 (affinity score: 0, topology spread score: 0): picked by scheduling policy"
      lastTransitionTime: "2023-11-10T08:14:52Z"
      observedGeneration: 5
    - type: RolloutStarted
      status: "True"
      reason: RolloutStarted
      message: "Detected new changes on the resources and started the rollout process"
      lastTransitionTime: "2023-11-10T08:15:30Z"
      observedGeneration: 5
    - type: Overridden
      status: "True"
      reason: NoOverrideSpecified
      message: "No override rules are configured for the selected resources"
      lastTransitionTime: "2023-11-10T08:15:45Z"
      observedGeneration: 5
    - type: WorkSynchronized
      status: "True"
      reason: AllWorkSynced
      message: "All of the works are synchronized to the latest"
      lastTransitionTime: "2023-11-10T08:16:00Z"
      observedGeneration: 5
    - type: Applied
      status: "True"
      reason: AllWorkHaveBeenApplied
      message: "All corresponding work objects are applied"
      lastTransitionTime: "2023-11-10T08:16:15Z"
      observedGeneration: 5
    - type: Available
      status: "True"
      reason: ResourceAvailable
      message: "All resources are available on the target cluster"
      lastTransitionTime: "2023-11-10T08:16:30Z"
      observedGeneration: 5
    failedPlacements: []
    driftedPlacements: []
    diffedPlacements: []
```

::: zone-end

This example shows:

- **Successful scheduling**: The placement found two clusters that match the placement policy.
- **Successful rollout**: All resources are deployed to both target clusters.
- **No overrides**: No resource overrides are configured or needed.
- **Synchronized work**: Work objects are created and synchronized.
- **Applied resources**: All resources are successfully applied.
- **Available resources**: All resources are running and available.
- **Clean status**: No failed, drifted, or diffed placements.