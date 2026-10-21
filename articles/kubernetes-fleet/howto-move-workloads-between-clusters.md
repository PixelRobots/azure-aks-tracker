---
layout: Conceptual
title: How to move a Kubernetes workload between clusters using Azure Kubernetes Fleet Manager resource placement | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/howto-move-workloads-between-clusters
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
description: Learn how to take over a Kubernetes workload on one cluster and move it to another cluster by using Azure Kubernetes Fleet Manager resource placement.
ms.topic: how-to
ms.date: 2026-07-28T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
locale: en-us
document_id: 01e94f5a-8540-7e3d-58e7-e66676df3832
document_version_independent_id: 6b92d20a-ad92-2464-9805-cc403e44387d
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/howto-move-workloads-between-clusters.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: kubernetes-fleet/howto-move-workloads-between-clusters
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/howto-move-workloads-between-clusters.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: c33e7102-d18b-47cc-b5e5-1ce794f48bcb
---

# How to move a Kubernetes workload between clusters using Azure Kubernetes Fleet Manager resource placement | Microsoft Learn

**Applies to:** ✔️ Fleet Manager with hub cluster

This article shows how to move a Kubernetes workload on one cluster to another cluster by using Fleet Manager resource placement. It also explains how [resource placement](intelligent-resource-placement) can safely take over an existing workload already running on a member cluster.

## Prerequisites

If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.

- An Azure Kubernetes Fleet Manager with a hub cluster. If you don't have one, see [Create an Azure Kubernetes Fleet Manager and join member clusters by using the Azure CLI](quickstart-create-fleet-and-members).
- Two member clusters named `aks-member-1` and `aks-member-2`, with the sample workload directly deployed on `aks-member-1`. These member clusters can be AKS or Azure Arc-enabled Kubernetes clusters.
- The user completing the configuration has permissions to perform Azure role assignments and to access the Fleet Manager hub cluster Kubernetes API. For more information, see [Access the Kubernetes API](access-fleet-hub-cluster-kubernetes-api).
- Set the following environment variables:

    ```bash
    export SUBSCRIPTION_ID=<subscription>
    export GROUP=<resource-group>
    export FLEET=<fleet-name>
    export MEMBER_CLUSTER_1=aks-member-1
    export MEMBER_CLUSTER_2=aks-member-2
    ```

## Sample workload

For this article, use [kuard](https://github.com/kubernetes-up-and-running/kuard) as the sample workload.

Start by saving the following manifest to a file named `kuard-workload.yaml`. Deploy the manifest directly to the member cluster `aks-member-1` by using `kubectl`.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: kuard
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kuard
  namespace: kuard
  labels:
    app: kuard
spec:
  replicas: 2
  selector:
    matchLabels:
      app: kuard
  template:
    metadata:
      labels:
        app: kuard
    spec:
      containers:
        - name: kuard
          image: blauwelucht/kuard-amd64:blue
          ports:
            - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: kuard
  namespace: kuard
spec:
  selector:
    app: kuard
  ports:
    - port: 8080
      targetPort: 8080
```

Now that the workload is running on a single cluster, you can migrate the workload to being managed by Fleet Manager and then distribute it to another cluster.

## Stage the workload on Fleet Manager hub cluster

Get the kubeconfig file of the Kubernetes Fleet hub cluster by using the [`az fleet get-credentials`](/en-us/cli/azure/fleet#az-fleet-get-credentials) command:

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

Use the same manifest from the previous step and apply it to the Fleet Manager hub cluster:

```bash
kubectl apply -f kuard-workload.yaml
```

The applied workload isn't scheduled on the hub cluster, but is now ready for Fleet Manager to distribute.

The original workload is still running on `aks-member-1` and isn't yet under Fleet Manager's control.

## Take over workload with Fleet Manager

For this sample, use a `PickFixed` placement policy to explicitly target clusters by name.

By defining an `applyStrategy`, you control how Fleet Manager treats matching workloads on member clusters. In this example, you take over the existing workload when there are no differences between the properties of the target workload and those properties on the Fleet Manager hub cluster.

To understand take over behavior, see [Taking over existing workloads with Azure Kubernetes Fleet Manager resource placement](concepts-placement-takeover).

Save the following content to the file `deploy-kuard-fleet.yaml`.

```yaml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ClusterResourcePlacement
metadata:
    name: deploy-kuard-fleet
spec:
    resourceSelectors:
        - group: ""
          kind: Namespace
          version: v1
          name: "kuard"
    policy:
        placementType: PickFixed
        clusterNames:
        - aks-member-1
    strategy:
        applyStrategy:
            whenToTakeOver: IfNoDiff
            comparisonOption: PartialComparison
```

Apply the manifest on the Fleet Manager hub cluster to start the placement process and take over the existing cluster workload.

```bash
kubectl apply -f deploy-kuard-fleet.yaml
```

Monitor the placement by using the following command.

```bash
kubectl get clusterresourceplacement deploy-kuard-fleet
```

When the placement finishes, Fleet Manager is now responsible for the workload on the `aks-member-1` cluster.

## Move workload to a new cluster

Modify the `deploy-kuard-fleet.yaml` file by adding `aks-member-2` to the `clusterNames` array.

```yaml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ClusterResourcePlacement
metadata:
    name: deploy-kuard-fleet
spec:
    resourceSelectors:
        - group: ""
          kind: Namespace
          version: v1
          name: "kuard"
    policy:
        placementType: PickFixed
        clusterNames:
        - aks-member-1
        - aks-member-2
    strategy:
        applyStrategy:
            whenToTakeOver: IfNoDiff
            comparisonOption: PartialComparison
```

Reapply the manifest to the hub cluster, and watch as the workload rolls out to the newly added member cluster.

```bash
kubectl apply -f deploy-kuard-fleet.yaml
```

At this stage, you can manage the distribution of the workload across member clusters entirely through Fleet Manager, making it substantially easier to deal with outages and problematic clusters.

By using the `applyStrategy` available with Fleet Manager's resource placement, you don't have to disrupt your existing running workload to arrive at this setup.