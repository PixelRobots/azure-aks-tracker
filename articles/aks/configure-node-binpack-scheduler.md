---
layout: Conceptual
title: Bin Pack Nodes with Scheduler Profiles on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/configure-node-binpack-scheduler
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
description: Learn how to configure scheduler profiles to reduce idle costs and improve node utilization on Azure Kubernetes Service (AKS).
ms.topic: how-to
ms.date: 2026-03-12T00:00:00.0000000Z
ms.author: colinmixon
author: colinmixon
locale: en-us
document_id: 790e62ce-3f31-1cda-487e-fe7538671186
document_version_independent_id: 2e32372f-1aba-af98-6bc4-f570eec4843c
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/configure-node-binpack-scheduler.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/configure-node-binpack-scheduler
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/configure-node-binpack-scheduler.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 44307588-2b17-e8db-4e92-aecfea71f811
---

# Bin Pack Nodes with Scheduler Profiles on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to bin pack your nodes to improve node utilization for Azure Kubernetes Service (AKS) clusters using in-tree scheduling plugin, `NodeResourcesFit`. The default AKS scheduler operates in a `NodeResourcesFit:LeastAllocated` mode, which prioritizes nodes with lower utilization with scheduling pods. Configurable Scheduler Profiles on AKS allows you to change this default behavior and fine-tune the configuration to prioritize nodes with higher utilization. This documentation covers three different custom scheduler profiles while highlighting the best practice recommendation to improve utilization while reducing node hot spots.

Node bin-packing is a scheduling strategy that maximizes resource utilization by increasing pod density on nodes rather than spreading pods across a node pool or autoscaling nodes prematurely. Bin packing helps minimize wasted resources and can reduce the operational cost of maintaining idle or underutilized nodes. Improving node utilization is critical as data shows that CPU and memory are commonly over-requested resources. Additionally, as GPU adoption grows, efficient utilization of accelerators becomes equally critical due to their relative scarcity and cost.

## Limitations

- AKS currently doesn't manage the deployment of third-party schedulers or out-of-tree scheduling plugins.
- AKS doesn't support in-tree scheduling plugins targeting the `aks-system` scheduler. This restriction is in place to help prevent unexpected changes to AKS add-ons enabled on your cluster. Additionally, you can't define a `profile` called `aks-system`.

## Prerequisites

- The Azure CLI version `2.76.0` or later. Run `az --version` to find the version, and run `az upgrade` to upgrade the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- Kubernetes version `1.33` or later running on your AKS cluster.
- The [`aks-preview` Azure CLI extension](/en-us/azure/aks/configure-aks-scheduler?tabs=new-cluster#install-the-aks-preview-azure-cli-extension) version `18.0.0b27` or later.
- Register the [`UserDefinedSchedulerConfigurationPreview` feature flag](/en-us/azure/aks/configure-aks-scheduler?tabs=new-cluster#register-the-user-defined-scheduler-configuration-preview-feature-flag) in your Azure subscription.

## Enable scheduler profile configuration on an AKS cluster

You can enable schedule profile configuration on a new or existing AKS cluster.

# [Enable on a new cluster](#tab/new-cluster)
1. Create an AKS cluster with scheduler profile configuration enabled using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--enable-upstream-kubescheduler-user-configuration` flag.

    ```azurecli
    # Set environment variables
    export RESOURCE_GROUP=<resource-group-name>
    export CLUSTER_NAME=<aks-cluster-name>
    
    # Create an AKS cluster with schedule profile configuration enabled
    az aks create \
    --resource-group $RESOURCE_GROUP \ 
    --name $CLUSTER_NAME \
    --enable-upstream-kubescheduler-user-configuration \
    --generate-ssh-keys
    ```
2. Once the creation process completes, connect to the cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
    ```

# [Enable on an existing cluster](#tab/existing-cluster)
- Enable scheduler profile configuration on an existing cluster using the [`az aks update`][az-aks-update] command.

    ```azurecli
    # Set environment variables
    export SUBSCRIPTION_ID=<subscription-id>
    export RESOURCE_GROUP=<resource-group-name>
    export CLUSTER_NAME=<aks-cluster-name>
    
    # Enable schedule profile configuration on an existing AKS cluster
    az aks update --subscription="${SUBSCRIPTION_ID}" \
    --resource-group="${RESOURCE_GROUP}" \
    --name="${CLUSTER_NAME}" \
    --enable-upstream-kubescheduler-user-configuration
    ```

---

## Verify installation of the scheduler controller

- After enabling the feature on your AKS cluster, verify the custom resource definition (CRD) of the scheduler controller was successfully installed using the `kubectl get` command.

    ```bash
    kubectl get crd schedulerconfigurations.aks.azure.com
    ```

    Note

    This command won't succeed if the feature wasn't successfully enabled in the previous section.

## Configure node bin-packing with RequestedtoCapacity Plugin

Of the three profiles, `RequestedToCapacityRatio` provides the most granular user control for mapping nodes to an explicit utilization. **For example, this scheduling profile has been configured to favor nodes within a utilization band of 50-85%, avoid empty nodes, and severely deprioritize nearly full nodes at 90% utilization or more, leaving some headroom.** Given this level of detail, `RequestedtoCapacity` is the recommended scoring strategy for node bin‑packing on AKS for production clusters.

This configuration makes CPU utilization the dominant factor in node selection, packing nodes while still avoiding over saturation for CPU-heavy applications. Lastly, you must disable the `PodTopologySpread` plugin as it can override the weighted score from `NodeResourcesFit` if left enabled by default.

- `NodeResourcesFit` controls how the scheduler evaluates if a node has enough resources to run a pod.
- `scoringStrategy: RequestedToCapacityRatio` scores nodes based on the ratio of requested resources to total node capacity after the pod is hypothetically placed.
- `Resources` specifies that `CPU` and `Memory` are the primary resources being considered for scoring. With a weight of `8`, nodes with CPU usage are scored 8x higher than memory during the pod scheduling cycle. This increases the likelihood that nodes with high utilization are selected.
- `shape:` maps node utilization to the scheduler score. Each point represents a utilization percentage and its corresponding score, with a linear score between points.

```yaml
apiVersion: aks.azure.com/v1alpha1
kind: SchedulerConfiguration
metadata:
  name: upstream
spec:
  rawConfig: |
    apiVersion: kubescheduler.config.k8s.io/v1
    kind: KubeSchedulerConfiguration
    profiles:
      - schedulerName: cpu-binpack-scheduler-RtC
        plugins:
          multiPoint:
            enabled:
              - name: NodeResourcesFit
            disabled:
              - name: PodTopologySpread
        pluginConfig:
          - name: NodeResourcesFit
            args:
              apiVersion: kubescheduler.config.k8s.io/v1
              kind: NodeResourcesFitArgs
              scoringStrategy:
                type: RequestedToCapacityRatio
                resources:
                  - name: cpu
                    weight: 8
                  - name: memory
                    weight: 1
                requestedToCapacityRatio:
                  shape:
                    - utilization: 0
                      score: 0
                    - utilization: 30
                      score: 9
                    - utilization: 50
                      score: 10
                    - utilization: 85
                      score: 10
                    - utilization: 90
                      score: 5
                    - utilization: 100
                      score: 0
```

## Configure node bin-packing with MostAllocated Plugin

Configuring the scheduler with `MostAllocated` exclusively prioritizes nodes based on resource usage. The higher the resource utilization, the higher a node is scored, avoiding unused nodes or scaling until necessary. In isolation, this configuration risks saturating nodes beyond desirable limits, causing throttling or additional bottlenecks.

This configuration makes CPU utilization the dominant factor in node selection. To ensure consistent behavior, you must disable the `PodTopologySpread` plugin as it can override the weighted score from `NodeResourcesFit` if left enabled by default.

- `NodeResourcesFit` controls how the scheduler evaluates if a node has enough resources to run a pod.
- `scoringStrategy: MostAllocated` scores based on pod requests. `MostAllocated` tells the scheduler to prefer nodes with high resource usage. This strategy promotes dense pod placement and helps achieve **better node utilization**.
- `Resources` specifies that `CPU` and `Memory` are the primary resources being considered for scoring. With a weight of `8`, nodes with CPU usage are scored 8x higher than memory during the pod scheduling cycle. This increases the likelihood that nodes with high utilization are selected.

```yaml
apiVersion: aks.azure.com/v1alpha1
kind: SchedulerConfiguration
metadata:
  name: upstream
spec:
  rawConfig: |
    apiVersion: kubescheduler.config.k8s.io/v1
    kind: KubeSchedulerConfiguration
    profiles:
      - schedulerName: cpu-binpack-scheduler-mA
        plugins:
          multiPoint:
            enabled:
              - name: NodeResourcesFit
            disabled:
              - name: PodTopologySpread
        pluginConfig:
          # NodeResourcesFit configuration
          - name: NodeResourcesFit
            args:
              apiVersion: kubescheduler.config.k8s.io/v1
              kind: NodeResourcesFitArgs
              scoringStrategy:
                type: MostAllocated
                resources:
                  - name: cpu
                    weight: 8
                  - name: memory
                    weight: 1
```

## Configure node bin-packing with MostAllocated and NodeResourcesBalancedAllocation Plugins

This configuration looks to add some guardrails to the simple and efficient strategy `MostAllocated` by scoring nodes based on balanced usage of target resources. `NodeResourcesBalancedAllocation` encourages pod placement on nodes with user-defined proportional utilization, increasing overall efficiency while avoiding bottlenecks caused by asymmetric resource pressure. For example, CPU‑bound nodes with abundant unused memory would be scored lower in favor of nodes with a better balance of CPU and memory utilization.

- `NodeResourcesBalancedAllocation` scores nodes based on how balanced resource usage is across multiple resources. Rather than maximizing utilization of a single resource, this plugin prefers nodes where resource consumption is proportional.
- `Resources` specifies which resources are considered during balance evaluation. With CPU and memory weighted equally, nodes are scored higher when both resources are consumed at similar levels.

```yaml
apiVersion: aks.azure.com/v1alpha1
kind: SchedulerConfiguration
metadata:
  name: upstream
spec:
  rawConfig: |
    apiVersion: kubescheduler.config.k8s.io/v1
    kind: KubeSchedulerConfiguration
    profiles:
      - schedulerName: cpu-binpack-scheduler-mA-BalancedAllocation
        plugins:
          multiPoint:
            enabled:
              - name: NodeResourcesFit
              - name: NodeResourcesBalancedAllocation
            disabled:
              - name: PodTopologySpread
        pluginConfig:
          # NodeResourcesFit configuration
          - name: NodeResourcesFit
            args:
              apiVersion: kubescheduler.config.k8s.io/v1
              kind: NodeResourcesFitArgs
              scoringStrategy:
                type: MostAllocated
                resources:
                  - name: cpu
                    weight: 8
                  - name: memory
                    weight: 1
          - name: NodeResourcesBalancedAllocation
            args:
              apiVersion: kubescheduler.config.k8s.io/v1
              kind: NodeResourcesBalancedAllocationArgs
              resources:
                - name: cpu
                  weight: 1
                - name: memory
                  weight: 1
```

## Assign a scheduler profile to an entire AKS cluster

1. Create a file named `cpu-bin-packing-scheduler.yaml`, with the CRD named `upstream`
2. Apply the scheduling configuration manifest using the `kubectl apply` command.

    ```bash
    kubectl apply -f cpu-bin-packing-scheduler.yaml
    ```
3. To target this scheduling mechanism for specific workloads, update your pod deployments with the following `schedulerName`:

    ```yaml
    ...
    ...
        spec:
          schedulerName: binpacking-scheduler
    ...
    ...
    ```