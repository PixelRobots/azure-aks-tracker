---
layout: Conceptual
title: Use Azure Kubernetes Fleet Manager cluster resource placement to deploy workloads across multiple clusters | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/quickstart-resource-propagation
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
description: This article describes how to use Azure Kubernetes Fleet Manager cluster resource placement to deploy workloads across clusters in a fleet.
ms.date: 2026-07-28T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
ms.topic: how-to
zone_pivot_groups: azure-portal-azure-cli
locale: en-us
document_id: 84009d69-dace-17f2-d003-9ce79bd07c71
document_version_independent_id: 0b146157-3bca-3e96-f046-abf99331f985
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/quickstart-resource-propagation.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: kubernetes-fleet/quickstart-resource-propagation
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/quickstart-resource-propagation.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 7baae6f1-f42f-14c1-0f1d-d45ad63e6a0f
---

# Use Azure Kubernetes Fleet Manager cluster resource placement to deploy workloads across multiple clusters | Microsoft Learn

**Applies to:** ✔️ Fleet Manager with hub cluster

Azure Kubernetes Fleet Manager resource placement enables you to distribute and synchronize cluster-scoped resources - including namespaces and their child resources - across multiple clusters in your fleet. This feature simplifies multicluster deployments by ensuring consistent resource configuration across your infrastructure, reducing manual overhead, and enabling you to manage complex workloads at scale with a single source of truth. This article walks through using `ClusterResourcePlacement` to distribute a namespace and its workloads to member clusters.

To distribute individual resources inside a namespace, see the [documentation on namespace-scoped resource placement](quickstart-namespace-scoped-resource-propagation).

You can complete the steps in this article using either the Azure portal or the Azure CLI.

Note

You can use Fleet Manager's resource placement with AKS and Azure Arc-enabled Kubernetes clusters.

## Before you begin

- If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- Read the [conceptual overview of resource placement](concepts-resource-placement) to understand the concepts and terminology used in this article.
- You need a Fleet Manager with a hub cluster and member clusters. If you don't have one, see [Create an Azure Kubernetes Fleet Manager resource and join member clusters by using the Azure CLI](quickstart-create-fleet-and-members).
- You need access to the Kubernetes API of the hub cluster. If you don't have access, see [Access the Kubernetes API for an Azure Kubernetes Fleet Manager hub cluster](access-fleet-hub-cluster-kubernetes-api).

## Distribute a namespace and its resources onto member clusters

Use the simple scenario of having a `Deployment` and `Service` to deploy across all clusters in the fleet. Create a namespace on your Fleet Manager hub cluster, add the workloads to it, and then use a `ClusterResourcePlacement` to distribute the namespace and all its contents to all member clusters by using the `PickAll` placement policy.

::: zone pivot="azure-cli"

1. Set the following environment variables for your subscription ID, resource group, and Kubernetes Fleet resource:

    ```bash
    export SUBSCRIPTION_ID=<subscription-id>
    export GROUP=<resource-group-name>
    export FLEET=<fleet-name>
    ```
2. Set the default Azure subscription by using the [`az account set`][az-account-set] command:

    ```azurecli
    az account set \
        --subscription ${SUBSCRIPTION_ID}
    ```
3. Get the kubeconfig file of the Kubernetes Fleet hub cluster by using the [`az fleet get-credentials`][az-fleet-get-credentials] command:

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
4. Create a namespace on the hub cluster.

    ```bash
    kubectl create namespace test-app
    ```
5. Save the following YAML as `test-workload.yaml`.

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
6. Stage the test workload onto the Fleet Manager hub cluster by using `kubectl`.

    ```bash
    kubectl apply -f test-workload.yaml
    ```
7. Save the following YAML as `crp-distribute-workload.yaml`.

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
    ```
8. Apply the placement manifest to the Fleet Manager hub cluster.

    ```bash
    kubectl apply -f crp-distribute-workload.yaml
    ```

    Note

    The resource rollout begins immediately the manifest is applied. An implicit `RollingUpdate` strategy is used. To learn how to have additional control over the rollout, see [defining a rollout strategy for resource placement](concepts-rollout-strategy).
9. Check the progress of the resource placement.

```bash
kubectl get clusterresourceplacement distribute-test-app
```

Your output should look similar to the following example:

```output
NAME                   GEN   SCHEDULED   SCHEDULEDGEN   APPLIED   APPLIEDGEN   AGE
distribute-test-app    2     True        2              True      2            10s
```

1. View the details of the placement.

```bash
kubectl describe clusterresourceplacement distribute-test-app
```

Your output should look similar to the following example:

```output
Name:         distribute-test-app
Namespace:    
Labels:       <none>
Annotations:  <none>
API Version:  placement.kubernetes-fleet.io/v1
Kind:         ClusterResourcePlacement
Metadata:
  Creation Timestamp:  2024-04-01T18:55:31Z
  Finalizers:
    kubernetes-fleet.io/crp-cleanup
    kubernetes-fleet.io/scheduler-cleanup
  Generation:        2
  Resource Version:  6949
  UID:               815b1d81-61ae-4fb1-a2b1-06794be3f986
Spec:
  Policy:
    Placement Type:  PickAll
  Resource Selectors:
    Group:                 
    Kind:                  Namespace
    Name:                  test-app
    Version:               v1
  Revision History Limit:  10
  Strategy:
    Type:  RollingUpdate
Status:
  Conditions:
    Last Transition Time:   2024-04-01T18:55:31Z
    Message:                found all the clusters needed as specified by the scheduling policy
    Observed Generation:    2
    Reason:                 SchedulingPolicyFulfilled
    Status:                 True
    Type:                   ClusterResourcePlacementScheduled
    Last Transition Time:   2024-04-01T18:55:36Z
    Message:                All 3 cluster(s) are synchronized to the latest resources on the hub cluster
    Observed Generation:    2
    Reason:                 SynchronizeSucceeded
    Status:                 True
    Type:                   ClusterResourcePlacementSynchronized
    Last Transition Time:   2024-04-01T18:55:36Z
    Message:                Successfully applied resources to 3 member clusters
    Observed Generation:    2
    Reason:                 ApplySucceeded
    Status:                 True
    Type:                   ClusterResourcePlacementApplied
  Observed Resource Index:  0
  Placement Statuses:
    Cluster Name:  membercluster1
    Conditions:
      Last Transition Time:  2024-04-01T18:55:31Z
      Message:               Successfully scheduled resources for placement in membercluster1 (affinity score: 0, topology spread score: 0): picked by scheduling policy
      Observed Generation:   2
      Reason:                ScheduleSucceeded
      Status:                True
      Type:                  ResourceScheduled
      Last Transition Time:  2024-04-01T18:55:36Z
      Message:               Successfully Synchronized work(s) for placement
      Observed Generation:   2
      Reason:                WorkSynchronizeSucceeded
      Status:                True
      Type:                  WorkSynchronized
      Last Transition Time:  2024-04-01T18:55:36Z
      Message:               Successfully applied resources
      Observed Generation:   2
      Reason:                ApplySucceeded
      Status:                True
      Type:                  ResourceApplied
    Cluster Name:            membercluster2
    Conditions:
      Last Transition Time:  2024-04-01T18:55:31Z
      Message:               Successfully scheduled resources for placement in membercluster2 (affinity score: 0, topology spread score: 0): picked by scheduling policy
      Observed Generation:   2
      Reason:                ScheduleSucceeded
      Status:                True
      Type:                  ResourceScheduled
      Last Transition Time:  2024-04-01T18:55:36Z
      Message:               Successfully Synchronized work(s) for placement
      Observed Generation:   2
      Reason:                WorkSynchronizeSucceeded
      Status:                True
      Type:                  WorkSynchronized
      Last Transition Time:  2024-04-01T18:55:36Z
      Message:               Successfully applied resources
      Observed Generation:   2
      Reason:                ApplySucceeded
      Status:                True
      Type:                  ResourceApplied
    Cluster Name:            membercluster3
    Conditions:
      Last Transition Time:  2024-04-01T18:55:31Z
      Message:               Successfully scheduled resources for placement in membercluster3 (affinity score: 0, topology spread score: 0): picked by scheduling policy
      Observed Generation:   2
      Reason:                ScheduleSucceeded
      Status:                True
      Type:                  ResourceScheduled
      Last Transition Time:  2024-04-01T18:55:36Z
      Message:               Successfully Synchronized work(s) for placement
      Observed Generation:   2
      Reason:                WorkSynchronizeSucceeded
      Status:                True
      Type:                  WorkSynchronized
      Last Transition Time:  2024-04-01T18:55:36Z
      Message:               Successfully applied resources
      Observed Generation:   2
      Reason:                ApplySucceeded
      Status:                True
      Type:                  ResourceApplied
  Selected Resources:
    Kind:     Namespace
    Name:     my-namespace
    Version:  v1
Events:
  Type    Reason                     Age   From                                   Message
  ----    ------                     ----  ----                                   -------
  Normal  PlacementScheduleSuccess   108s  cluster-resource-placement-controller  Successfully scheduled the placement
  Normal  PlacementSyncSuccess       103s  cluster-resource-placement-controller  Successfully synchronized the placement
  Normal  PlacementRolloutCompleted  103s  cluster-resource-placement-controller  Resources have been applied to the selected clusters
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
5. On the service menu, under **Fleet Resources**, select **Resource placements** &gt; **+ Create**.
6. On the **Basics** tab, configure the following options:

    - In **Placement details**, enter a name for the placement.
    - Under **Resource details**, leave **Scope** as **Cluster-scoped** and enter the Group Version Kind (GVK) and name of the resource to distribute. In this sample, use the following values.

        ```yaml
        group: ""
        kind: Namespace
        version: v1          
        name: test-app
        ```
    - In **Member cluster selection**, for **Placement type** choose **All clusters**.
    - For **Rollout**, leave the **Rolling update** strategy selected.

    [![Screenshot of the Azure portal showing the completed Basics tab for cluster-scoped resource placement for a namespace called test-app.](media/quickstart-resource-propagation/fleet-placement-create-placement-basics-tab.png)](media/quickstart-resource-propagation/fleet-placement-create-placement-basics-tab.png#lightbox)
7. Select **Next** to review the resulting `ClusterResourcePlacement` manifest. You can modify the manifest if required, validate by using the **Validate (dry run)** option, or select **Review + create** to proceed to final confirmation.

    [![Screenshot of the Azure portal showing the Review YAML tab with a passed dry run validation for cluster-scoped resource placement for a namespace called test-app.](media/quickstart-resource-propagation/fleet-placement-create-placement-review-yaml-tab.png)](media/quickstart-resource-propagation/fleet-placement-create-placement-review-yaml-tab.png#lightbox)
8. Select **Create** to start the distribution of the namespace immediately.

    [![Screenshot of the Azure portal showing the Review and create tab for a cluster-scoped resource placement for a namespace called test-app.](media/quickstart-resource-propagation/fleet-placement-create-placement-review-create.png)](media/quickstart-resource-propagation/fleet-placement-create-placement-review-create.png#lightbox)

    Note

    The resource rollout begins immediately when you apply the resource placement by using the selected `RollingUpdate` strategy. To learn how to have additional controls over the rollout, see [defining a rollout strategy for resource placement](concepts-rollout-strategy).
9. The page refreshes and the **Resource placements** list displays the newly created placement. It shows the number of clusters selected and whether the fleet scheduler can fulfill the placement policy.

    [![Screenshot of the Azure portal showing the resource placements list with a single resource placement called distribute-test-app.](media/quickstart-resource-propagation/fleet-placement-create-placement-list-view.png)](media/quickstart-resource-propagation/fleet-placement-create-placement-list-view.png#lightbox)
10. View the rollout status of the placement by selecting the placement name in the list. Select individual clusters to view the resource rollout on that cluster.

    [![Screenshot of the Azure portal showing the detailed rollout information of a resource placement called distribute-test-app.](media/quickstart-resource-propagation/fleet-placement-create-placement-rollout-details.png)](media/quickstart-resource-propagation/fleet-placement-create-placement-rollout-details.png#lightbox)

On the selected Kubernetes clusters, you find the namespace, Deployment, and Service deployed and operational.

::: zone-end

## Delete the placement to remove resources

When you delete the resource placement on the Fleet Manager hub cluster, you remove the distributed resources from selected member clusters.

::: zone pivot="azure-cli"

```bash
kubectl delete clusterresourceplacement distribute-test-app
```

::: zone-end

::: zone pivot="azure-portal"

1. On the service menu, under **Fleet Resources**, select **Resource placements**.
2. In the resource placements list, select the placement and select **Delete**.
3. On **Delete**, verify that you chose the correct placement. When you're ready, select **Confirm delete** &gt; **Delete**.

    [![Screenshot of the Azure portal showing a resource placement called distribute-test-app being deleted.](media/quickstart-resource-propagation/fleet-placement-delete-placement.png)](media/quickstart-resource-propagation/fleet-placement-delete-placement.png#lightbox)
4. The page refreshes and the placement no longer appears in the list. The resources are removed from member clusters.

::: zone-end