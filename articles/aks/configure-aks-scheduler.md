---
layout: Conceptual
title: Configure Scheduler Profiles on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/configure-aks-scheduler
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
description: Learn how to set scheduler profiles to achieve advanced scheduling behaviors on Azure Kubernetes Service (AKS).
ms.topic: how-to
ms.date: 2025-12-11T00:00:00.0000000Z
ms.author: sachidesai
author: sachidesai
locale: en-us
document_id: 3c65a7a5-6c0a-95b3-6201-f03291b629a3
document_version_independent_id: 16cf313c-a1ef-2b22-3c2f-b75f5d901493
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/configure-aks-scheduler.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/configure-aks-scheduler
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/configure-aks-scheduler.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 4dcfaa69-aa96-c241-1634-e54ca8a9a73d
---

# Configure Scheduler Profiles on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to deploy example scheduler profiles in Azure Kubernetes Service (AKS) to configure advanced scheduling behavior using in-tree scheduling plugins. This guide also explains how to verify the successful application of custom scheduler profiles targeting specific node pools or the entire AKS cluster.

## Limitations

- AKS currently doesn't manage the deployment of third-party schedulers or out-of-tree scheduling plugins.
- AKS doesn't support in-tree scheduling plugins targeting the `aks-system` scheduler. This restriction is in place to help prevent unexpected changes to AKS add-ons enabled on your cluster. Additionally, you can't define a `profile` called `aks-system`.

## Prerequisites

- The Azure CLI version `2.90.0` or later. Run `az --version` to find the version, and run `az upgrade` to upgrade the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- Kubernetes version `1.33` or later running on your AKS cluster.
- Review the [supported advanced scheduling concepts](concepts-scheduler-configuration) and in-tree scheduling plugins on AKS.

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

## Configure node bin-packing

Node bin-packing is a scheduling strategy that maximizes resource utilization by increasing pod density on nodes, within the set configuration. This strategy helps improve cluster efficiency by minimizing wasted resources and lowering the operational cost of maintaining idle or underutilized nodes.

In this example, the configured scheduler prioritizes scheduling pods on nodes with high CPU usage. Explicitly, this configuration avoids underutilizing nodes that still have free resources and helps to make better use of the resources already allocated to nodes. The CRD must be named `upstream`.

1. Create a file named `bin-pack-cpu-scheduler.yaml`, with the CRD named `upstream`, and paste in the following manifest:

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
        - schedulerName: node-binpacking-cpu-scheduler
          pluginConfig:
              - name: NodeResourcesFit
                args:
                  scoringStrategy:
                    type: MostAllocated
                    resources:
                      - name: cpu
                        weight: 1
    ```

    - `NodeResourcesFit` ensures that the scheduler checks if a node has enough resources to run the pod.
    - `scoringStrategy: MostAllocated` tells the scheduler to prefer nodes with high CPU resource usage. This helps achieve **better resource utilization** by placing new pods on nodes that are already "highly used".
    - `Resources` specifies that `CPU` is the primary resource being considered for scoring, and with a weight of `1`, CPU usage is prioritized with a relatively equal level of importance in the scheduling decision.
2. Apply the scheduling configuration manifest using the `kubectl apply` command.

    ```bash
    kubectl apply -f bin-pack-cpu-scheduler.yaml
    ```
3. To target this scheduling mechanism for specific workloads, update your pod deployments with the following `schedulerName`:

    ```yaml
    ...
    ...
        spec:
          schedulerName: node-binpacking-cpu-scheduler
    ...
    ...
    ```

## Configure pod topology spread

Pod topology spread is a scheduling strategy that seeks to distribute pods evenly across failure domains (such as availability zones or regions) to ensure high availability and fault tolerance in the event of zone or node failures. This strategy helps prevent the risk of all replicas of a pod being placed in the same failure domain. For more configuration guidance, see the [Kubernetes Pod Topology Spread Constraints documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/). The CRD must be named `upstream`.

1. Create a file named `pod-topology-spreader-scheduler.yaml`, with the CRD named `upstream`, and paste in the following manifest:

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
        - schedulerName: pod-distribution-scheduler
          pluginConfig:
              - name: PodTopologySpread
                args:
                  apiVersion: kubescheduler.config.k8s.io/v1
                  kind: PodTopologySpreadArgs
                  defaultingType: List
                  defaultConstraints:
                    - maxSkew: 1
                      topologyKey: topology.kubernetes.io/zone
                      whenUnsatisfiable: ScheduleAnyway
    ```

    - `PodTopologySpread` plugin instructs the scheduler to try and distribute pods as evenly as possible across availability zones.
    - `whenUnsatisfiable: ScheduleAnyway` specifies schedule to schedule pods despite the inability to meet the topology constraints. This avoids pod scheduling failures when exact distribution isn't feasible.
    - `List` type applies the default constraints as a list of rules. The scheduler uses the rules in the order they're defined, and they apply to all pods that don’t specify custom topology spread constraints.
    - `maxSkew: 1` means the number of pods can differ by at most *1* between any two availability zones.
    - `topologyKey: topology.kubernetes.io/zone` indicates that the scheduler should spread pods across availability zones.
2. Apply the scheduling configuration manifest using the `kubectl apply` command.

    ```bash
    kubectl apply -f pod-topology-spreader-scheduler.yaml
    ```
3. To target this scheduling mechanism for specific workloads, update your pod deployments with the following `schedulerName`:

    ```yaml
    ...
    ...
        spec:
          schedulerName: pod-distribution-scheduler
    ...
    ...
    ```

## Assign a scheduler profile to an entire AKS cluster

1. In your scheduler profile configuration, update the `schedulerName` field as follows:

    ```yaml
    ...
    ...
        - schedulerName: default-scheduler
    ...
    ...
    ```
2. Reapply the manifest using the `kubectl apply` command.

    ```bash
    kubectl apply -f aks-scheduler-customization.yaml
    ```

    Now, this configuration will become the **default** scheduling operation for your entire AKS cluster.

## Configure multiple scheduler profiles

You can customize the upstream scheduler with multiple profiles and customize each profile with multiple plugins while using the same configuration file. As a reminder, the CRD must be named `upstream` and user-configured fields include `percentageOfNodesToScore`, `podInitialBackoffSeconds`, `podMaxBackoffSeconds`, and `profiles`.

In the following example, we create two scheduling profiles called **scheduler-one** and **scheduler-two**. The fields `percentageOfNodesToScore`, `podInitialBackoffSeconds`, `podMaxBackoffSeconds`, apply globally to all profiles defined.

**global parameters**

- `percentageOfNodesToScore` specifies the percentage of cluster nodes the scheduler evaluates during scoring to balance scheduling accuracy and speed. So **percentageOfNodesToScore: 40** means the scheduler will sample 40% of nodes instead of the entire cluster.
- `podInitialBackoffSeconds` defines the initial delay before retrying a failed scheduling attempt to prevent rapid, repeated retries. So **podInitialBackoffSeconds: 1** means the scheduler waits 1 second before the first retry.
- `podMaxBackoffSeconds` sets the maximum delay the scheduler will wait between exponential backoff retries for unschedulable pods. So **podMaxBackoffSeconds: 8** means the retry delay will never exceed 8 seconds even as backoff increases.

**scheduler-one** prioritizes placing pods across zones and nodes for balanced distribution with the following settings:

- Enforces strict zonal distribution and *preferred* node distribution using `PodTopologySpread`.
- Honors hard pod affinity rules and considers the soft affinity rules with `InterPodAffinity`.
- *Prefers* nodes in specific zones to reduce cross-zone networking using `NodeAffinity`.

**scheduler-two** prioritizes placing pods on nodes with available storage, CPU, and memory resources for timely resource-efficient resource usage with the following settings:

- Ensures pods are placed on nodes where PVCs can bind to PVs using `VolumeBinding`.
- Validates that nodes and volumes satisfy zonal requirements using `VolumeZone` to avoid cross-zone storage access.
- Prioritizes nodes based on CPU, memory, and ephemeral storage utilization, with `NodeResourcesFit`.
- Favors nodes that already have the required container images using `ImageLocality`.

Note

You might need to adjust zones and other parameters based on your workload type.

1. Create a file named `aks-scheduler-customization.yaml`, with the CRD named `upstream`, and paste in the following manifest:

    ```yaml
    apiVersion: aks.azure.com/v1alpha1
    kind: SchedulerConfiguration
    metadata:
      name: upstream
    spec:
      rawConfig: |
        apiVersion: kubescheduler.config.k8s.io/v1
        kind: KubeSchedulerConfiguration
        percentageOfNodesToScore: 40
        podInitialBackoffSeconds: 1
        podMaxBackoffSeconds: 8
        profiles:
          - schedulerName: scheduler-one
            plugins:
              multiPoint:
                enabled:
                  - name: PodTopologySpread
                  - name: InterPodAffinity
                  - name: NodeAffinity
            pluginConfig:
              # PodTopologySpread with strict zonal distribution        
              - name: PodTopologySpread
                args:
                  defaultingType: List
                  defaultConstraints:
                    - maxSkew: 2
                      topologyKey: topology.kubernetes.io/zone
                      whenUnsatisfiable: DoNotSchedule
                    - maxSkew: 1
                      topologyKey: kubernetes.io/hostname
                      whenUnsatisfiable: ScheduleAnyway                  
              - name: InterPodAffinity
                args:
                  hardPodAffinityWeight: 1
                  ignorePreferredTermsOfExistingPods: false
              - name: NodeAffinity
                args:
                  addedAffinity:
                    preferredDuringSchedulingIgnoredDuringExecution:
                      - weight: 100
                        preference:
                          matchExpressions:
                            - key: topology.kubernetes.io/zone
                              operator: In
                              values: [westus3-1, westus3-2, westus3-3]
          - schedulerName: scheduler-two
            plugins:
              multiPoint:
                enabled:
                  - name: VolumeBinding
                  - name: VolumeZone
                  - name: NodeAffinity
                  - name: NodeResourcesFit
                  - name: PodTopologySpread
                  - name: ImageLocality
            pluginConfig:
              - name: PodTopologySpread
                args:
                  defaultingType: List
                  defaultConstraints:
                    - maxSkew: 1
                      topologyKey: kubernetes.io/hostname
                      whenUnsatisfiable: DoNotSchedule 
              - name: VolumeBinding
                args:
                  apiVersion: kubescheduler.config.k8s.io/v1
                  kind: VolumeBindingArgs
                  bindTimeoutSeconds: 300
              - name: NodeAffinity
                args:
                  apiVersion: kubescheduler.config.k8s.io/v1
                  kind: NodeAffinityArgs
                  addedAffinity:
                    preferredDuringSchedulingIgnoredDuringExecution:
                      - weight: 100
                        preference:
                          matchExpressions:
                            - key: topology.kubernetes.io/zone
                              operator: In
                              values: [westus3-1, westus3-2]
              - name: NodeResourcesFit
                args:
                  apiVersion: kubescheduler.config.k8s.io/v1
                  kind: NodeResourcesFitArgs
                  scoringStrategy:
                    type: MostAllocated
                    resources:
                      - name: cpu
                        weight: 3
                      - name: memory
                        weight: 1
                      - name: ephemeral-storage
                        weight: 2
    ```
2. Apply the manifest using the `kubectl apply` command.

    ```bash
    kubectl apply -f aks-scheduler-customization.yaml
    ```

## Disable an AKS scheduler profile configuration

1. Disable the feature using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--disable-upstream-kubescheduler-user-configuration` flag.

    ```azurecli
    az aks update --subscription="${SUBSCRIPTION_ID}" \
    --resource-group="${RESOURCE_GROUP}" \
    --name="${CLUSTER_NAME}" \
    --disable-upstream-kubescheduler-user-configuration
    ```
2. Verify the feature is disabled by running the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```azurecli
    az aks show --resource-group="${RESOURCE_GROUP}" \
    --name="${CLUSTER_NAME}" \
    --query='properties.schedulerProfile'
    ```

    Your output should indicate that the feature is no longer enabled on your AKS cluster.

## Frequently asked questions (FAQ)

### What happens if I apply misconfigured scheduler profile to my AKS cluster?

Once you apply a scheduler profile, AKS checks if it contains a valid configuration of plugins and arguments. If the configuration targets a disallowed scheduler or sets the in-tree scheduling plugins improperly, AKS rejects the configuration and reverts to the last known "accepted" scheduler configuration. This check aims to limit impact on new and existing AKS clusters due to scheduler misconfiguration.

### How can I monitor and validate that the scheduler honored my configuration?

There are *three* recommended methods for observing the results of your applied scheduler profile:

- View the AKS `kube-scheduler` control plane logs to ensure that the scheduler received the configuration from the CRD.
- Run the `kubectl get schedulerconfiguration` command. The output displays the status of the `configuration: pending` during the rollout and `Succeeded` or `Failed` after the configuration is accepted or rejected by the scheduler.
- Run the `kubectl describe schedulerconfiguration` command. The output displays a more detailed state of the scheduler, including any error during the reconciliation, and the current scheduler configuration in effect.