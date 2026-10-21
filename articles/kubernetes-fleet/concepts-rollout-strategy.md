---
layout: Conceptual
title: Defining a rollout strategy for Azure Kubernetes Fleet Manager resource placement | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/concepts-rollout-strategy
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
description: This article describes how to define a rollout strategy for Fleet Manager's resource placement.
ms.date: 2026-07-28T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
ms.topic: concept-article
ai-usage: ai-assisted
zone_pivot_groups: cluster-namespace-scope
locale: en-us
document_id: e877eb5c-8b2b-c90e-b432-957a4e3c4c87
document_version_independent_id: 011ed9be-466c-40ef-ad76-53fdb1ec3d88
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/concepts-rollout-strategy.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: kubernetes-fleet/concepts-rollout-strategy
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/concepts-rollout-strategy.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: d04c7231-802c-cfc4-2256-0a123f6b88ee
---

# Defining a rollout strategy for Azure Kubernetes Fleet Manager resource placement | Microsoft Learn

**Applies to:** ✔️ Fleet Manager with hub cluster

During the lifetime of a resource placement (cluster-scoped `ClusterResourcePlacement` or namespace-scoped `ResourcePlacement`), changes might be made which can result in one of the following scenarios:

- New workloads might need to be placed on all picked clusters
- Workloads already placed on a picked cluster might get updated or deleted
- Some clusters picked previously are now unpicked, and workloads must be removed from such clusters
- Some clusters are newly picked, and workloads must be added to them.

Most scenarios can lead to service interruptions as workloads running on member clusters might temporarily become unavailable as Fleet Manager dispatches updated resources. Clusters that are no longer selected lose all placed resources, resulting in lost traffic. If too many new clusters are selected and Fleet Manager places resources on them simultaneously, clusters might become overloaded. The exact interruption pattern might vary depending on the resources placed.

To minimize interruption, Fleet Manager's resource placement APIs allow users to configure a rollout strategy, similar to native Kubernetes deployment, to transition between changes as smoothly as possible.

In this article, we cover the rollout strategy options available for both `ClusterResourcePlacement` and `ResourcePlacement`.

Note

If you aren't already familiar with Fleet Manager's resource placement concepts, read the [conceptual overview of resource placement](concepts-resource-placement) before reading this article.

## Default behavior with no explicit strategy

Both `ClusterResourcePlacement` and `ResourcePlacement` don't require you to define a rollout strategy. If you don't specify one, the default behavior is to use a `RollingUpdate` strategy with a `maxSurge` of 25%, `maxUnavailable` of 25%, and `unavailablePeriodSeconds` of 10 seconds.

## Rolling update strategy

An explicit rolling update strategy can be used by adding a `strategy` specification to a `ClusterResourcePlacement` or `ResourcePlacement` as shown. You can define parameters, which control how disruptive the Fleet Manager resource placement is.

::: zone pivot="cluster-scope"

### ClusterResourcePlacement example

```yaml
apiVersion: placement.kubernetes-fleet.io/v1
kind: ClusterResourcePlacement
metadata:
  name: crp-example
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
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 50%
```

::: zone-end

::: zone pivot="namespace-scope"

### ResourcePlacement example

```yaml
apiVersion: placement.kubernetes-fleet.io/v1
kind: ResourcePlacement
metadata:
  name: rp-example
  namespace: test-namespace
spec:
  resourceSelectors:
    - group: "apps"
      kind: Deployment
      name: my-app
      version: v1
  policy:
    placementType: PickN
    numberOfClusters: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 50%
```

::: zone-end

### Configuration parameters

Rolling update strategies can be configured with the following parameters:

- **maxUnavailable:** considers a cluster as unavailable if resources aren't successfully applied to the cluster and makes sure that at any time, there are **at least** (N - `maxUnavailable`) number of clusters available. You can set as an absolute number or a percentage. The default is 25% and zero shouldn't be used. Setting this parameter to a lower value results in less interruption during a change but lead to slower rollouts.
- **maxSurge:** ensures that at any time, there are **at most** (N + `maxSurge`) number of clusters available. You can set as an absolute number or a percentage. The default is 25% and zero shouldn't be used. Setting this parameter to a lower value results in fewer resource placements on more clusters by Fleet Manager, which slows down the rollout process.
- **unavailablePeriodSeconds** allows you to define a time period before resources should be assessed as "ready". The default value is 60 seconds. Fleet Manager only considers newly applied resources on a cluster as "ready" `unavailablePeriodSeconds` seconds after the resources are successfully applied to that cluster. Setting a lower value for this parameter results in faster rollouts. However, we strongly recommend that users set a value that allows the initialization/preparation tasks to be completed.

### How cluster count is determined

Fleet Manager uses the placement type to determine the baseline number of clusters (`N`) to use when calculating `maxUnavailable` or `maxSurge`:

- **PickFixed**: the number of `clusterNames` specified
- **PickAll**: the number of clusters picked
- **PickN**: the `numberOfClusters` value.

If you use a percentage for the parameter, Fleet Manager calculates it against `N` as well.

## Staged update strategy

The staged update strategy provides fine-grained control over resource rollouts by organizing clusters into sequential stages with configurable progression rules. Unlike the rolling update strategy, staged updates are defined externally using separate custom resources that work together to orchestrate deployments.

### Example deployment pattern

The following diagram illustrates a typical three-stage deployment pattern:

[![Three-stage deployment pattern with staging, canary, and production stages with wait times and approval gates.](media/concepts-resource-placement/conceptual-rollout-staged-update-strategy.png)](media/concepts-resource-placement/conceptual-rollout-staged-update-strategy.png#lightbox)

This pattern allows you to:

- Deploy to staging clusters first for initial validation
- Wait a specified time before proceeding to canary clusters
- Require manual approval before rolling out to production
- Control the order of updates within canary and production stages

### When to use staged updates

Staged update strategies are ideal when you need:

- **Environment-based rollouts** (dev → staging → production)
- **Validation Delays** and **Approval gates** between stages
- **Deterministic ordering** of cluster updates within stages
- **Reusable deployment patterns** across multiple resource placements

For simpler scenarios where percentage-based rollouts suffice, consider using the inline rolling update strategy instead.

Note

The staged update strategy works identically for both `ClusterResourcePlacement` and `ResourcePlacement`, with the only difference being the scope of the custom resources (cluster-scoped vs namespace-scoped).

To learn how to implement staged update runs step-by-step, see [How to use ClusterStagedUpdateRun to orchestrate staged rollouts](howto-staged-update-run).

### How staged updates work

Both cluster and namespace-scope placements offer their own resource types.

::: zone pivot="cluster-scope"

#### Cluster-scoped (ClusterResourcePlacement)

- **ClusterResourcePlacement** - Configured with `strategy.type: External` to indicate external strategy management.
- **ClusterStagedUpdateStrategy** - Defines the stages, cluster selection, and progression rules.
- **ClusterStagedUpdateRun** - Executes the **ClusterStagedUpdateStrategy** against a specific `ClusterResourcePlacement` and cluster resource snapshot.

#### ClusterResourcePlacement with external strategy

```yaml
apiVersion: placement.kubernetes-fleet.io/v1
kind: ClusterResourcePlacement
metadata:
  name: my-app-placement
spec:
  resourceSelectors:
    - group: ""
      kind: Namespace
      name: my-app
      version: v1
  policy:
    placementType: PickAll
  strategy:
    type: External  # Rollout is controlled by ClusterStagedUpdateRun, ClusterStagedUpdateStrategy.
```

#### ClusterStagedUpdateStrategy

```yaml
apiVersion: placement.kubernetes-fleet.io/v1
kind: ClusterStagedUpdateStrategy
metadata:
  name: three-stage-strategy
spec:
  stages:
    - name: staging
      labelSelector:
        matchLabels:
          environment: staging
      afterStageTasks:
        - type: TimedWait
          waitTime: 1h
      maxConcurrency: 50%  # Update 50% of staging clusters at once
    - name: canary
      labelSelector:
        matchLabels:
          environment: canary
      sortingLabelKey: name
      afterStageTasks:
        - type: Approval
      maxConcurrency: 2  # Update 2 clusters concurrently
    - name: production
      labelSelector:
        matchLabels:
          environment: production
      sortingLabelKey: order
      beforeStageTasks:
        - type: Approval
      maxConcurrency: 1  # Sequential updates (default)
```

::: zone-end

::: zone pivot="namespace-scope"

#### Namespace-scoped (ResourcePlacement)

- **ResourcePlacement** - Configured with `strategy.type: External` to indicate external strategy management.
- **StagedUpdateStrategy** - Defines the stages, cluster selection, and progression rules.
- **StagedUpdateRun** - Executes the **StagedUpdateStrategy** against a specific `ResourcePlacement` and resource snapshot.

#### ResourcePlacement with external strategy

```yaml
apiVersion: placement.kubernetes-fleet.io/v1
kind: ResourcePlacement
metadata:
  name: my-app-placement
  namespace: my-app
spec:
  resourceSelectors:
    - group: "apps"
      kind: Deployment
      name: my-deployment
      version: v1
  policy:
    placementType: PickAll
  strategy:
    type: External  # Rollout is controlled by StagedUpdateRun, StagedUpdateStrategy.
```

#### StagedUpdateStrategy

```yaml
apiVersion: placement.kubernetes-fleet.io/v1
kind: StagedUpdateStrategy
metadata:
  name: three-stage-strategy
  namespace: my-app
spec:
  stages:
    - name: staging
      labelSelector:
        matchLabels:
          environment: staging
      afterStageTasks:
        - type: TimedWait
          waitTime: 1h
      maxConcurrency: 50%  # Update 50% of staging clusters at once
    - name: canary
      labelSelector:
        matchLabels:
          environment: canary
      sortingLabelKey: name
      afterStageTasks:
        - type: Approval
      maxConcurrency: 2  # Update 2 clusters concurrently
    - name: production
      labelSelector:
        matchLabels:
          environment: production
      sortingLabelKey: order
      beforeStageTasks:
        - type: Approval
      maxConcurrency: 1  # Sequential updates (default)
```

::: zone-end

### Stage configuration

Each stage in the strategy can specify:

- **Label selector** (`labelSelector`) to determine which clusters belong to the stage
- **Sorting order** (`sortingLabelKey`) for clusters within the stage using `sortingLabelKey` (optional - clusters are sorted alphabetically by name if not specified)
- **Before-stage tasks** (`beforeStageTasks`) approval requirement (optional - up to 1 task per stage)
- **After-stage tasks** (`afterStageTasks`) either timed wait or approval requirement (optional - up to 2 tasks per stage, maximum one of each type)
- **Max concurrency** (`maxConcurrency`) to determine the maximum number of clusters to update concurrently within the stage (optional - can be an absolute number from 1 to the number of clusters in the stage, or a percentage from 1 to 100, fractional results are rounded down with a minimum of 1)

Note

**Strategy Limits:** Each strategy can define a maximum of 31 stages to ensure reasonable execution times.

::: zone pivot="cluster-scope"

#### ClusterStagedUpdateRun

```yaml
apiVersion: placement.kubernetes-fleet.io/v1
kind: ClusterStagedUpdateRun
metadata:
  name: my-app-rollout
spec:
  placementName: my-app-placement # Required - ClusterResourcePlacement name the update run is applied to.
  # resourceSnapshotIndex: "0" # Optional - ClusterResourceSnapshot index of the selected resources to be updated across clusters. 
                               # Omit to use the latest snapshot, creating one if it doesn't already exist.
  stagedRolloutStrategyName: three-stage-strategy # Required - The name of the update strategy to use.
  state: Run # Optional - Controls the execution state of the update run.
```

::: zone-end

::: zone pivot="namespace-scope"

#### StagedUpdateRun

```yaml
apiVersion: placement.kubernetes-fleet.io/v1
kind: StagedUpdateRun
metadata:
  name: my-app-rollout
  namespace: my-app
spec:
  placementName: my-app-placement # Required - ResourcePlacement name the update run is applied to.
  # resourceSnapshotIndex: "0" # Optional - ResourceSnapshot index of the selected resources to be updated across clusters.
                               # Omit or leave empty to use the latest snapshot, creating one if it doesn't already exist.
  stagedRolloutStrategyName: three-stage-strategy # Required - The name of the update strategy to use.
  state: Run # Optional - Controls the execution state of the update run. 
```

::: zone-end

### Specifying rollout

The `resourceSnapshotIndex` field controls which resource snapshot version to deploy. You have several options:

- Omit the field to use the latest snapshot, creating a new one if it doesn't already exist (shown in the example).
- Specify an existing resource snapshot index (for example, `"2"`) to explicitly target that version.
- Specify an older resource snapshot index (for example, `"0"`) to deploy or roll back to a previous version.

Important

When a placement uses the `External` rollout strategy, resource snapshots aren't created automatically. They're only created when you execute a staged update run with the `resourceSnapshotIndex` field omitted. This means that when you first create a placement with an `External` rollout strategy, no resource snapshots exist until you run the first staged update run.

If a placement was previously using the `RollingUpdate` strategy and is changed to `External`, any existing resource snapshots remain available and can be referenced when creating staged update runs.

For more information on resource snapshots, see [Understanding snapshots for Azure Kubernetes Fleet Manager resource snapshots](concepts-placement-snapshots).

### Understanding update run states

Staged update runs use a `state` field to control their execution behavior. Understanding these states and their transitions is essential for managing rollouts effectively.

### Available states

- **Initialize**: Sets up the update run without executing the rollout. Use this state to prepare and validate the update run configuration before starting deployment.
- **Run**: Executes the staged rollout. If starting fresh, this state both initializes and executes the update run. If the update run is already initialized, it only executes the rollout. Use this state to start or resume update runs.
- **Stop**: Gracefully halts the update run. This state allows in progress clusters to complete their updates before stopping the entire rollout process.

### State transition rules

The following state transitions are supported:

- **Initialize → Run**: Start execution after initialization
- **Run → Stop**: Stop a running update run
- **Stop → Run**: Resume a stopped update run

Once an update run finishes, the update run can't be restarted.

::: zone pivot="cluster-scope"

Note

Always verify the current state of your update runs before attempting state changes. Use `kubectl get clusterstagedupdaterun <update-run-name>` to check the current state and status.

::: zone-end

::: zone pivot="namespace-scope"

Note

Always verify the current state of your update runs before attempting state changes. Use `kubectl get stagedupdaterun <update-run-name> -n <namespace>` to check the current state and status.

::: zone-end

### Stage progression

Fleet Manager processes stages sequentially:

1. Any configured before-stage tasks execute
2. All clusters in a stage receive updates according to their sort order
3. After all clusters in a stage are successfully updated, any configured after-stage tasks execute
4. The next stage begins only after all previous after stage tasks complete

Note

An update run can stop for multiple reasons, including but not limited to:

- The binding spec doesn't match the update run configuration. This situation typically happens when another update run preempts the current one.
- Validation failures occur, such as when a cluster joins or leaves the fleet.
- Labels change on clusters.

When a resource update fails on a cluster, Fleet Manager continues retrying and marks the cluster status as "stuck" (after retrying for about 5 minutes) rather than stopping the entire update run.

### Approval Requests

For approval-based progression, Fleet Manager creates a `ClusterApprovalRequest` (for cluster-scoped placements) or `ApprovalRequest` (for namespace-scoped placements) resource that must be approved before continuing to the next stage.

A stage can have a before stage task of type approval and an after stage task type of approval. To help differentiate which approval request is for what stage tasks, the approval request name will contain `-before-` for before stage tasks or `-after-` for after stage tasks.

**Example approval request names:**

- `my-update-run-before-canary` - Before-stage approval task for the "canary" stage of update run "my-update-run"
- `my-update-run-after-staging` - After-stage approval task for the "staging" stage of update run "my-update-run"

## Key differences between cluster and namespace-scoped strategies

| Aspect | Cluster-Scoped | Namespace-Scoped |
| --- | --- | --- |
| **Strategy Resource** | `ClusterStagedUpdateStrategy` (short name: `csus`) | `StagedUpdateStrategy` (short name: `sus`) |
| **Update Run Resource** | `ClusterStagedUpdateRun` (short name: `csur`) | `StagedUpdateRun` (short name: `sur`) |
| **Target Placement** | `ClusterResourcePlacement` (short name: `crp`) | `ResourcePlacement` (short name: `rp`) |
| **Approval Resource** | `ClusterApprovalRequest` (short name: `careq`) | `ApprovalRequest` (short name: `areq`) |
| **Snapshot Resource** | `ClusterResourceSnapshot` | `ResourceSnapshot` |
| **Scope** | Cluster-wide | Namespace-bound |
| **Use Case** | Infrastructure rollouts | Application rollouts |
| **Permissions** | Cluster-admin level | Namespace-level |