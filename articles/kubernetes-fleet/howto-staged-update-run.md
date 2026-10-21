---
layout: Conceptual
title: Use staged rollout runs to control Azure Kubernetes Fleet Manager resource placements | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/howto-staged-update-run
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
description: Learn how to use placement staged update runs to deploy Kubernetes resources to member clusters in stages and roll back to previous versions in Azure Kubernetes Fleet Manager.
ms.topic: how-to
ms.date: 2026-07-28T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
zone_pivot_groups: azure-portal-azure-cli
locale: en-us
document_id: 7b58e24c-9b07-cada-52e7-6df902f5bed5
document_version_independent_id: 0c1eb826-e724-44bd-d6fa-f108a402a266
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/howto-staged-update-run.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: kubernetes-fleet/howto-staged-update-run
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/howto-staged-update-run.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 1baa0686-56ea-d107-c1b4-91cf8d3cdbe3
---

# Use staged rollout runs to control Azure Kubernetes Fleet Manager resource placements | Microsoft Learn

**Applies to:** ✔️ Fleet Manager with hub cluster

Azure Kubernetes Fleet Manager placement staged rollout runs provide a controlled approach to deploying Kubernetes workloads across multiple member clusters using a stage-by-stage process. To minimize risk, this approach deploys to targeted clusters sequentially, with optional wait times and approval gates between stages.

This article shows you how to create and execute staged update runs to deploy workloads progressively and roll back to previous versions when needed.

Azure Kubernetes Fleet Manager supports two scopes for staged updates:

- **Cluster-scoped**: Use `ClusterStagedUpdateRun` with `ClusterResourcePlacement` for fleet administrators managing infrastructure-level changes.
- **Namespace-scoped**: Use `StagedUpdateRun` with `ResourcePlacement` for application teams managing rollouts within their specific namespaces.

The example in this article demonstrates using a rollout run with cluster-scoped resources. Namespace-scoped behaves exactly the same with intra-namespace resources.

## Before you begin

- If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- To understand the concepts and terminology used in this article, read the [conceptual overview of staged rollout strategies](concepts-rollout-strategy#staged-update-strategy).

::: zone pivot="azure-cli"

- Set the following environment variables:

    ```bash
    export SUBSCRIPTION_ID=<subscription>
    export GROUP=<resource-group>
    export FLEET=<fleet-name>
    export MEMBER_CLUSTER_1=aks-member-1
    export MEMBER_CLUSTER_2=aks-member-2
    ```
- You need Azure CLI installed to complete this article. To install or upgrade, see [Install the Azure CLI](/en-us/cli/azure/install-azure-cli).
- You need the `fleet` Azure CLI extension. You can install it by running the following command:

    ```azurecli
    az extension add --name fleet
    ```

    Run the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command to update to the latest version of the extension:

    ```azurecli
    az extension update --name fleet
    ```
- If you don't have the Kubernetes CLI (kubectl) already, you can install it by using this command:

    ```azurecli
    az aks install-cli
    ```

::: zone-end

### Configure the environment

This article uses a Fleet Manager with a hub cluster and two member clusters. If you don't have a Fleet Manager, follow the [quickstart](quickstart-create-fleet-and-members) to create a Fleet Manager with a hub cluster. Then, join Azure Kubernetes Service (AKS) or Azure Arc-enabled Kubernetes clusters as members.

Make sure that the member clusters have the following labels so that there's a cluster in each stage of the rollout.

| member name | labels |
| --- | --- |
| aks-member-1 | environment=canary |
| aks-member-2 | environment=staging |

::: zone pivot="azure-cli"

Apply labels to the member clusters by using the following command.

```azurecli
az fleet member update \
    --resource-group ${GROUP} \
    --fleet-name ${FLEET} \
    --name ${MEMBER_CLUSTER_1} \
    --labels environment=canary
```

```azurecli
az fleet member update \
    --resource-group ${GROUP} \
    --fleet-name ${FLEET} \
    --name ${MEMBER_CLUSTER_2} \
    --labels environment=staging
```

::: zone-end

::: zone pivot="azure-portal"

1. In the Azure portal, go to your Fleet Manager.
2. On the service menu, under **Settings**, select **Member clusters**.
3. In the member cluster list, select a cluster. Then, choose **Edit labels** in the action menu.
4. Add the appropriate label to the member cluster, and then select **Apply**.
5. Repeat for each member cluster.

    [![A screenshot of the Azure portal showing a new label being added to an Azure Kubernetes Fleet Manager member cluster.](media/howto-placement-rollout-runs/fleet-placement-rollout-label-cluster.png)](media/howto-placement-rollout-runs/fleet-placement-rollout-label-cluster.png#lightbox)

::: zone-end

## Prepare Kubernetes workload for placement

In this step, you stage a Kubernetes workload on the Fleet Manager hub cluster so you can distribute it through a staged rollout onto member clusters.

::: zone pivot="azure-cli"

1. Get the kubeconfig file of the Kubernetes Fleet hub cluster by using the [`az fleet get-credentials`](/en-us/cli/azure/fleet#az-fleet-get-credentials) command:

    ```azurecli
    az fleet get-credentials \
        --resource-group ${GROUP} \
        --name ${FLEET}
    ```

    Your output should look similar to the following.

    ```output
    Merged "hub" as current context in /home/fleet/.kube/config
    ```

    Note

    If you receive an error of type `InvalidHubOperation` with the message indicating the fleet is hubless, add a hub cluster. For further information, see [upgrade hub cluster type](upgrade-hub-cluster-type).
2. Create a namespace on the Fleet Manager hub cluster.

    ```bash
    kubectl create namespace test-app
    ```
3. Save the following YAML as `test-workload.yaml`.

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: nginx-deployment
      namespace: test-app
    spec:
      selector:
        matchLabels:
          app: nginx
      replicas: 2
      template:
        metadata:
          labels:
            app: nginx
        spec:
          containers:
          - name: nginx
            image: mcr.microsoft.com/azurelinux/base/nginx:1.28@sha256:3352a36cbcab4708883a3e77b64f64159e11e1aab358c010e1c4e465dbfb4f57
            ports:
            - containerPort: 80
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: nginx-service
      namespace: test-app
    spec:
      selector:
        app: nginx
      ports:
      - protocol: TCP
        port: 80
        targetPort: 80
      type: LoadBalancer
    ```
4. Stage the test workload onto the Fleet Manager hub cluster by using `kubectl`.

    ```bash
    kubectl apply -f test-workload.yaml
    ```

::: zone-end

::: zone pivot="azure-portal"

1. In the Azure portal, go to your Fleet Manager.
2. On the service menu, under **Fleet Resources**, select **Namespaces** &gt; **+ Create**.

    Note

    If you don't see **Fleet Resources**, your Fleet Manager doesn't have a hub cluster. For further information on how to add one, see [upgrade hub cluster type](upgrade-hub-cluster-type).
3. In the menu, select **Namespace**, enter a **Name**, and then select **Create**.

    [![Screenshot of the Azure portal showing a namespace called test-app being created on the Fleet Manager hub cluster.](media/quickstart-resource-propagation/fleet-placement-create-namespace.png)](media/quickstart-resource-propagation/fleet-placement-create-namespace.png#lightbox)

    After a few moments, the page refreshes and the namespace appears in the list of namespaces on the Fleet Manager hub cluster. It's now ready to host any resources you want to distribute across member clusters.
4. At the top of the namespace list, select **+ Create** &gt; **Apply a YAML**, and use the following samples.

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: nginx-deployment
      namespace: test-app
    spec:
      selector:
        matchLabels:
          app: nginx
      replicas: 2
      template:
        metadata:
          labels:
            app: nginx
        spec:
          containers:
          - name: nginx
            image: mcr.microsoft.com/azurelinux/base/nginx:1.28@sha256:3352a36cbcab4708883a3e77b64f64159e11e1aab358c010e1c4e465dbfb4f57
            ports:
            - containerPort: 80
    ```

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: nginx-service
      namespace: test-app
    spec:
      selector:
        app: nginx
      ports:
      - protocol: TCP
        port: 80
        targetPort: 80
      type: LoadBalancer
    ```

    Copy and paste the samples and apply them one at a time as shown in the following image.

    [![Screenshot of the Azure portal showing the Apply with YAML dialog populated with a Deployment ready to be applied to the Fleet Manager hub cluster.](media/quickstart-resource-propagation/fleet-placement-apply-yaml.png)](media/quickstart-resource-propagation/fleet-placement-apply-yaml.png#lightbox)

    The namespace and its workloads are now ready to be distributed to member clusters. The Deployment and Service aren't scheduled on the Fleet Manager hub cluster.

::: zone-end

## Define cluster ordering using a rollout strategy

Create a rollout strategy to define the order in which clusters receive the resources. You can also add more controls such as soak times and approvals before or after each stage. For further information see [Define reusable Azure Kubernetes Fleet Manager resource placement rollout strategies](howto-placement-create-rollout-strategies).

::: zone pivot="azure-cli"

1. Save the following YAML as `crp-two-stages-strategy.yaml`.

    ```yaml
    apiVersion: placement.kubernetes-fleet.io/v1
    kind: ClusterStagedUpdateStrategy
    metadata:
      name: two-stages-strategy
    spec:
      stages:
        - name: staging
          labelSelector:
            matchLabels:
              environment: staging
          afterStageTasks:
            - type: TimedWait
              waitTime: 4m
        - name: canary
          labelSelector:
            matchLabels:
              environment: canary
          beforeStageTasks:
            - type: Approval
    ```
2. Apply the strategy manifest to the Fleet Manager hub cluster.

    ```bash
    kubectl apply -f crp-two-stages-strategy.yaml
    ```
3. Check the status of the strategy resource.

    ```bash
    kubectl get clusterstagedupdatestrategy two-stages-strategy
    ```

    Your output should look similar to the following.

    ```output
    NAME                  AGE
    two-stages-strategy   47m
    ```

::: zone-end

::: zone pivot="azure-portal"

Use the following process to create a strategy containing the two stages `Staging` and `Canary` with a 4 minute wait time and a pre-stage approval for the `Canary` stage.

1. In the Azure portal, go to your Fleet Manager.
2. On the service menu, under **Fleet Resources**, select **Resource placements** &gt; **Staged rollout strategies**, then **Create**.
3. Enter a name for the strategy.
4. Select the **Strategy scope**, choosing either **Cluster-scoped** or **Namespace-scoped**.

    - For **Namespace-scoped**, select the existing **Namespace** on the Fleet Manager hub cluster where the Kubernetes resources to be distributed are staged.
5. Select **Create Stage** and enter:

    - **Stage name** - name the stage - it must be unique across all stage names in the strategy.
    - **(Optional) Stage approvals** - select this option if you would like to wait for an approval before this stage starts or after it completes.
    - **(Optional) Wait after stage** - select this option if you would like to define a pause before moving to the next stage.
    - **(Optional) Wait duration** - select a predefined duration, or enter a custom value in seconds.
    - **Cluster label selector** - choose an existing member cluster label to use to select clusters for this stage.
    - **(Optional) Cluster ordering label** - choose an existing member cluster label to use to order the clusters within the stage.
    - **(Optional) Stage concurrency** - set how many clusters should be updated concurrently in the current stage.

    [![A screenshot of the Azure portal showing a new stage being added to an Azure Kubernetes Fleet Manager placement staged rollout strategy.](media/howto-placement-strategies/fleet-placement-create-strategy-add-stage.png)](media/howto-placement-strategies/fleet-placement-create-strategy-add-stage.png#lightbox)

    Note

    The maximum number of stages in each strategy is **31**.
6. Repeat until all stages are added to the strategy. Select **Create** to create the strategy.

    [![A screenshot of the Azure portal showing an Azure Kubernetes Fleet Manager placement staged rollout strategy with two stages that is pending creation.](media/howto-placement-strategies/fleet-placement-create-strategy-pending-create.png)](media/howto-placement-strategies/fleet-placement-create-strategy-pending-create.png#lightbox)
7. The page refreshes and the list displays the newly created strategy.

    [![A screenshot of the Azure portal showing a list of Azure Kubernetes Fleet Manager placement staged rollout strategies.](media/howto-placement-strategies/fleet-placement-create-strategy-list-view.png)](media/howto-placement-strategies/fleet-placement-create-strategy-list-view.png#lightbox)

::: zone-end

## Pick clusters by using a resource placement

Use a resource placement to select the resources to distribute and define the policy to pick which clusters receive the resources.

To use a staged rollout, set the rollout `strategy` type to `External` so you can control the resource distribution by a staged rollout that you define later.

::: zone pivot="azure-cli"

1. Save the following YAML as `crp-distribute-workload-ext.yaml`.

    ```yaml
    apiVersion: placement.kubernetes-fleet.io/v1
    kind: ClusterResourcePlacement
    metadata:
      name: distribute-test-app
    spec:
      resourceSelectors:
        - group: ""
          kind: Namespace
          version: v1          
          name: test-app
      policy:
        placementType: PickAll
      strategy:
        type: External
    ```

    Important

    If you don't set the `strategy` type to `External`, the resource rollout starts as soon as you apply the manifest by using a `RollingUpdate` strategy.
2. Apply the placement manifest to the Fleet Manager hub cluster.

    ```bash
    kubectl apply -f crp-distribute-workload-ext.yaml
    ```
3. Check the status of the resource placement.

    ```bash
    kubectl get clusterresourceplacement distribute-test-app
    ```

    Your output should look similar to the following.

    ```output
    NAME                  GEN   SCHEDULED   SCHEDULED-GEN   AVAILABLE   AVAILABLE-GEN   AGE
    distribute-test-app   1     True        1                                           60s
    ```

::: zone-end

::: zone pivot="azure-portal"

1. In the Azure portal, go to your Fleet Manager.
2. On the service menu, under **Fleet Resources**, select **Resource placements** &gt; **+ Create**.
3. On the **Basics** tab, configure the following options:

    - In **Placement details**, enter a name for the placement.
    - Under **Resource details**, leave **Scope** as **Cluster-scoped** and enter the Group Version Kind (GVK) and name of the resource to distribute. In this sample, use the following values.

        ```yaml
        group: ""
        kind: Namespace
        version: v1          
        name: test-app
        ```
    - In **Member cluster selection**, for **Placement type** choose **All clusters**.
    - For **Rollout**, select **External**. Use **Staged update strategy** to select the rollout strategy you created earlier.
    - Leave the **Automatically start rollout** box unchecked.

    [![Screenshot of the Azure portal showing the completed Basics tab for cluster-scoped resource placement that uses a staged update strategy for rollout.](media/howto-placement-rollout-runs/fleet-placement-rollout-basics-tab.png)](media/howto-placement-rollout-runs/fleet-placement-rollout-basics-tab.png#lightbox)
4. Select **Next** to review the resulting `ClusterResourcePlacement` manifest. You can modify the manifest if required, validate by using the **Validate (dry run)** option, or select **Review + create** to proceed to final confirmation.

    [![Screenshot of the Azure portal showing the Review YAML tab with a passed dry run validation for cluster-scoped resource placement using an external strategy for a namespace called test-app.](media/howto-placement-rollout-runs/fleet-placement-rollout-review-yaml-tab.png)](media/howto-placement-rollout-runs/fleet-placement-rollout-review-yaml-tab.png#lightbox)
5. Select **Create** to create the rollout run, but not start it.

    [![Screenshot of the Azure portal showing the Review and create tab for a cluster-scoped resource placement using a staged rollout for a namespace called test-app.](media/howto-placement-rollout-runs/fleet-placement-rollout-review-create.png)](media/howto-placement-rollout-runs/fleet-placement-rollout-review-create.png#lightbox)
6. The page refreshes and the **Resource placements** list displays the newly created placement. It shows the number of clusters selected and whether the fleet scheduler can fulfill the placement policy. Notice the **Rollout type** is set to **External**.

    [![Screenshot of the Azure portal showing the resource placements list with a single resource placement called distribute-test-app that has an External rollout type.](media/howto-placement-rollout-runs/fleet-placement-rollout-list-view.png)](media/howto-placement-rollout-runs/fleet-placement-rollout-list-view.png#lightbox)

When you use the Azure portal to create a placement with a rollout strategy, it automatically creates a staged rollout run for you.

::: zone-end

::: zone pivot="azure-cli"

## Use staged rollout to control distribution

In this article, you create the staged rollout with a `state` of `Initialize` so that you can start the rollout when you want, rather than the run starting immediately when the manifest is applied. Set the state to `Run` to start immediately instead.

1. Save the following YAML as `staged-rollout-test-app.yaml`.

    ```yaml
    apiVersion: placement.kubernetes-fleet.io/v1
    kind: ClusterStagedUpdateRun
    metadata:
      name: staged-rollout-test-app
    spec:
      placementName: distribute-test-app
      stagedRolloutStrategyName: two-stages-strategy
      state: Initialize
    ```

    Note

    If you don't set the `strategy` type to `External`, the resource rollout starts as soon as you apply the manifest by using a `RollingUpdate` strategy.
2. Apply the staged rollout manifest to the Fleet Manager hub cluster.

    ```bash
    kubectl apply -f staged-rollout-test-app.yaml
    ```
3. Check the status of the rollout run resource. It's initialized but not progressing.

    ```bash
    kubectl get clusterstagedupdaterun staged-rollout-test-app
    ```

    Your output should look similar to the following.

    ```output
    NAME                      PLACEMENT             RESOURCE-SNAPSHOT-INDEX   POLICY-SNAPSHOT-INDEX   INITIALIZED   PROGRESSING   SUCCEEDED   AGE
    staged-rollout-test-app   distribute-test-app                             0                       True                                    101s
    ```

::: zone-end

## Managing staged rollout progress

Once you have all the resources ready, you can now control the rollout of resources across member clusters.

### Start a staged rollout

::: zone pivot="azure-cli"

To start a staged rollout, patch the `state` field in the spec to `Run`.

```bash
kubectl patch clusterstagedupdaterun staged-rollout-test-app --type merge -p '{"spec":{"state":"Run"}}'
```

Check the status of the rollout run resource. It's initialized but not progressing.

```bash
kubectl get clusterstagedupdaterun staged-rollout-test-app
```

Your output should look similar to the following, noting that progressing is now `True`.

```output
NAME                      PLACEMENT             RESOURCE-SNAPSHOT-INDEX   POLICY-SNAPSHOT-INDEX   INITIALIZED   PROGRESSING   SUCCEEDED   AGE
staged-rollout-test-app   distribute-test-app                             0                       True          True                      36m
```

Note

When the rollout reaches a TimedWait or Approval task, the progress status changes to `False`. Use `describe` to determine the reason for the pause.

View the detailed status of the rollout by describing the `ClusterStagedUpdateRun`.

```bash
kubectl describe clusterstagedupdaterun staged-rollout-test-app
```

In the response, review the `Status`, looking at the `Conditions` and `Stages Status` to understand which stage and cluster is currently being processed, or if a `TimedWait` or `Approval` task is currently active.

```yaml
Name:         staged-rollout-test-app
Namespace:
Labels:       <none>
Annotations:  <none>
API Version:  placement.kubernetes-fleet.io/v1
Kind:         ClusterStagedUpdateRun
Metadata:
  Creation Timestamp:  2026-07-27T04:25:14Z
  Finalizers:
    kubernetes-fleet.io/stagedupdaterun-finalizer
  Generation:        3
  Resource Version:  2684410
  UID:               5e20d0a1-515a-4f1c-b566-89676100a968
Spec:
  Placement Name:                distribute-test-app
  Resource Snapshot Index:
  Staged Rollout Strategy Name:  two-stages-strategy
  State:                         Run
Status:
  Applied Strategy:
    Comparison Option:  PartialComparison
    Type:               ClientSideApply
    When To Apply:      Always
    When To Take Over:  Always
  Conditions:
    Last Transition Time:  2026-07-27T04:25:14Z
    Message:               The UpdateRun initialized successfully
    Observed Generation:   3
    Reason:                UpdateRunInitializedSuccessfully
    Status:                True
    Type:                  Initialized
    Last Transition Time:  2026-07-27T05:01:56Z
    Message:               The update run is making progress
    Observed Generation:   3
    Reason:                UpdateRunProgressing
    Status:                True
    Type:                  Progressing
  Deletion Stage Status:
    Clusters:
    Stage Name:                   kubernetes-fleet.io/deleteStage
  Policy Observed Cluster Count:  2
  Policy Snapshot Index Used:     0
  Resource Snapshot Index Used:   0
  Staged Update Strategy Snapshot:
    Stages:
      After Stage Tasks:
        Type:       TimedWait
        Wait Time:  1h0m0s
      Label Selector:
        Match Labels:
          Environment:  staging
      Max Concurrency:  1
      Name:             staging
      Before Stage Tasks:
        Type:  Approval
      Label Selector:
        Match Labels:
          Environment:  canary
      Max Concurrency:  1
      Name:             canary
  Stages Status:
    After Stage Task Status:
      Type:  TimedWait
    Clusters:
      Cluster Name:  aks-place-member-02-fm
      Conditions:
        Last Transition Time:  2026-07-27T05:01:56Z
        Message:               Cluster update started
        Observed Generation:   3
        Reason:                ClusterUpdatingStarted
        Status:                True
        Type:                  Started
    Conditions:
      Last Transition Time:  2026-07-27T05:01:56Z
      Message:               Clusters in the stage started updating
      Observed Generation:   3
      Reason:                StageUpdatingStarted
      Status:                True
      Type:                  Progressing
    Stage Name:              staging
    Start Time:              2026-07-27T05:01:56Z
    Before Stage Task Status:
      Approval Request Name:  staged-rollout-test-app-before-canary
      Type:                   Approval
    Clusters:
      Cluster Name:  aks-place-member-01-fm
    Stage Name:      canary
Events:              <none>
```

::: zone-end

::: zone pivot="azure-portal"

1. In the Azure portal, go to your Fleet Manager.
2. On the service menu, under **Fleet Resources**, select **Staged rollout runs**.
3. In the list, select the staged rollout run that was created automatically in the previous step, and then select **Start** in the action menu.

    [![Screenshot of the Azure portal showing the staged rollout run list with a single staged rollout run that is selected.](media/howto-placement-rollout-runs/fleet-placement-rollout-list-start-run.png)](media/howto-placement-rollout-runs/fleet-placement-rollout-list-start-run.png#lightbox)
4. The page refreshes and the **Staged rollout runs** list displays the staged rollout run with the state of **Progressing**, with the currently running stage shown.

    [![Screenshot of the Azure portal showing the staged rollout run list with a single staged rollout run that is progressing and is in the stage named staging.](media/howto-placement-rollout-runs/fleet-placement-rollout-list-progressing-run.png)](media/howto-placement-rollout-runs/fleet-placement-rollout-list-progressing-run.png#lightbox)
5. When the rollout reaches a `TimedWait`, the state changes to **Waiting**. You can hover over the information icon to confirm this state is due to a `TimedWait`.

    [![Screenshot of the Azure portal showing the staged rollout run list with a single staged rollout run that is waiting. There is an information popup confirming the run is waiting for a timed wait to expire.](media/howto-placement-rollout-runs/fleet-placement-rollout-list-timed-wait.png)](media/howto-placement-rollout-runs/fleet-placement-rollout-list-timed-wait.png#lightbox)

::: zone-end

### Stop a staged rollout

::: zone pivot="azure-cli"

To stop a running staged rollout, patch the `state` field in the spec to `Stop`. This action gracefully halts the staged rollout run, so in-progress clusters finish their updates before the process stops.

```bash
kubectl patch clusterstagedupdaterun staged-rollout-test-app --type merge -p '{"spec":{"state":"Stop"}}'
```

The staged update run is initialized, but no longer running.

```bash
kubectl get clusterstagedupdaterun staged-rollout-test-app
```

Your output should look similar to the following, noting that `progressing` is now `False`.

```output
NAME                      PLACEMENT             RESOURCE-SNAPSHOT-INDEX   POLICY-SNAPSHOT-INDEX   INITIALIZED   PROGRESSING   SUCCEEDED   AGE
staged-rollout-test-app   distribute-test-app                             0                       True          False                     46m
```

::: zone-end

::: zone pivot="azure-portal"

To stop a running staged rollout, use the following steps. This action gracefully halts the staged rollout, so in-progress clusters finish their updates before the process stops.

1. In the Azure portal, go to your Fleet Manager.
2. On the service menu, under **Fleet Resources**, select **Staged rollout runs**.
3. In the list, select the staged rollout run that you want to stop. Then, choose **Stop** from the action menu.

    [![Screenshot of the Azure portal showing the staged rollout run list with a single staged rollout run that is progressing.](media/howto-placement-rollout-runs/fleet-placement-rollout-list-progressing-to-stop.png)](media/howto-placement-rollout-runs/fleet-placement-rollout-list-progressing-to-stop.png#lightbox)
4. The page refreshes and the **Staged rollout runs** list displays the staged rollout run with the state of **Stopped**.

    [![Screenshot of the Azure portal showing the staged rollout run list with a single staged rollout run that shows a status of stopped.](media/howto-placement-rollout-runs/fleet-placement-rollout-list-stopped.png)](media/howto-placement-rollout-runs/fleet-placement-rollout-list-stopped.png#lightbox)

::: zone-end

You can restart the rollout by following the instructions in Start a staged rollout.

Note

You can stop a rollout at any time. In-progress clusters continue to completion. Pending approvals stay unaffected.

## Clear a pending stage approval

Add approval tasks before or after a stage. These tasks require an explicit action to clear.

::: zone pivot="azure-cli"

When a staged rollout run reaches an approval, it creates an approval request (`ClusterApprovalRequest` or `ApprovalRequest`). You must patch this request. After you patch it, the rollout run continues.

Check for any pending approvals by using the following commands.

```bash
kubectl get clusterapprovalrequest
```

When checking for pending `ApprovalRequest` resources, make sure to provide the namespace in which the resources reside.

```bash
kubectl get clusterapprovalrequest -n test-app
```

If you receive a response of `No resources found`, then there are currently no cluster scoped approvals pending.

If there are pending approvals, the response should look similar to the following example.

```output
NAME                                    UPDATE-RUN                STAGE    APPROVED   AGE
staged-rollout-test-app-before-canary   staged-rollout-test-app   canary              4m13s
```

Note

The system generates approval request resource names by using the format {update-run-name}-{before|after}-{stage-name}.

You can approve the `ClusterApprovalRequest` by creating a JSON patch file and applying it.

```bash
cat << EOF > approval.json
"status": {
    "conditions": [
        {
            "lastTransitionTime": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
            "message": "lgtm",
            "observedGeneration": 1,
            "reason": "testPassed",
            "status": "True",
            "type": "Approved"
        }
    ]
}
EOF
```

Note

Be sure the `observedGeneration` matches the generation of the approval object. This value is typically `1`.

Submit a patch request to approve the request by using the JSON file you created.

```bash
kubectl patch clusterapprovalrequests staged-rollout-test-app-before-canary --type='merge' --subresource=status --patch-file approval.json
```

Verify the approval was applied to the request.

```bash
kubectl get clusterapprovalrequest staged-rollout-test-app-before-canary
```

Your output should look similar to the following. Note that `APPROVED` is set to `True`.

```output
NAME                                    UPDATE-RUN                STAGE    APPROVED   AGE
staged-rollout-test-app-before-canary   staged-rollout-test-app   canary   True       6m
```

The rollout run continues.

```bash
kubectl get clusterstagedupdaterun staged-rollout-test-app
```

Your output should look similar to the following, which shows a completed run with `SUCCEEDED` set to `True`.

```output
NAME                      PLACEMENT             RESOURCE-SNAPSHOT-INDEX   POLICY-SNAPSHOT-INDEX   INITIALIZED   PROGRESSING   SUCCEEDED   AGE
staged-rollout-test-app   distribute-test-app                             0                       True          False         True        9m
```

::: zone-end

::: zone pivot="azure-portal"

When a staged rollout run reaches an approval, use the following process to clear the approval so the run continues.

1. In the Azure portal, go to your Fleet Manager.
2. On the service menu, under **Fleet Resources**, select **Staged rollout runs**.
3. In the list, find the staged rollout run that has a state of **Pending approval**.

    [![Screenshot of the Azure portal showing the staged rollout run list with a single staged rollout run that is pending approval.](media/howto-placement-rollout-runs/fleet-placement-rollout-list-pending-approval.png)](media/howto-placement-rollout-runs/fleet-placement-rollout-list-pending-approval.png#lightbox)
4. You can open the approval dialog from any of three locations:

    - Inline in the staged rollout run list view (shown earlier).
    - From the details view for the staged rollout run:
        - From the **State** field in the Essentials section.
        - Inline in the Stage view.

    [![Screenshot of the Azure portal showing the staged rollout run detail view with two pending approval links.](media/howto-placement-rollout-runs/fleet-placement-rollout-detail-view-pending-approval.png)](media/howto-placement-rollout-runs/fleet-placement-rollout-detail-view-pending-approval.png#lightbox)
5. Select an option to open the **Approval** dialog. Enter an optional **Message** and choose **Approve**.

    [![Screenshot of the Azure portal showing the staged rollout run approval dialog with a completed message field.](media/howto-placement-rollout-runs/fleet-placement-rollout-approval-dialog.png)](media/howto-placement-rollout-runs/fleet-placement-rollout-approval-dialog.png#lightbox)
6. The page refreshes and the **Staged rollout runs** list displays the staged rollout run with the state of **Progressing**.

    [![Screenshot of the Azure portal showing the staged rollout run approval progressing in the canary stage after approval.](media/howto-placement-rollout-runs/fleet-placement-rollout-list-progressing-run-canary.png)](media/howto-placement-rollout-runs/fleet-placement-rollout-list-progressing-run-canary.png#lightbox)
7. The staged rollout run continues until it finishes, with the **Staged rollout runs** list displaying the staged rollout run with the state of **Succeeded**.

    [![Screenshot of the Azure portal showing the staged rollout run that has completed successfully.](media/howto-placement-rollout-runs/fleet-placement-rollout-list-run-succeeded.png)](media/howto-placement-rollout-runs/fleet-placement-rollout-list-run-succeeded.png#lightbox)

::: zone-end

## Delete a rollout run

::: zone pivot="azure-cli"

Remove a staged rollout run by deleting the Kubernetes resource on the Fleet Manager hub cluster.

```bash
kubectl delete clusterstagedupdaterun staged-rollout-test-app
```

::: zone-end

::: zone pivot="azure-portal"

1. In the Azure portal, go to your Fleet Manager.
2. On the service menu, under **Fleet Resources**, select **Staged rollout runs**.
3. In the list, select the staged rollout run to delete, and then choose **Delete** from the action menu.
4. In the **Delete** dialog, confirm the resource is correct, and then select **Confirm delete**. Finally, choose **Delete**.

    [![Screenshot of the Azure portal showing the Delete dialog for a selected staged rollout run.](media/howto-placement-rollout-runs/fleet-placement-rollout-list-delete.png)](media/howto-placement-rollout-runs/fleet-placement-rollout-list-delete.png#lightbox)
5. The page refreshes and the deleted staged rollout run is no longer present.

::: zone-end

Note

Deleting a completed staged rollout run doesn't remove placed resources. To remove the placed resources, you must delete the resource placement.