---
layout: Conceptual
title: Autoscale GPU Workloads using KEDA and NVIDIA DCGM Exporter metrics on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/autoscale-gpu-workloads-with-keda
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
description: Learn how to autoscale GPU-based workloads using KEDA and NVIDIA DCGM Exporter metrics on Azure Kubernetes Service (AKS).
author: dcasati
ms.author: sachidesai
ms.date: 2026-07-02T00:00:00.0000000Z
ms.topic: how-to
locale: en-us
document_id: 553abb47-2d0f-f723-a67f-1321238d2848
document_version_independent_id: 648e05eb-03fe-5b4a-ca47-e13496ee960b
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/autoscale-gpu-workloads-with-keda.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/autoscale-gpu-workloads-with-keda
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/autoscale-gpu-workloads-with-keda.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: b45b91a0-6d6d-0f2b-a463-8ec517e47549
---

# Autoscale GPU Workloads using KEDA and NVIDIA DCGM Exporter metrics on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to autoscale GPU workloads on Azure Kubernetes Service (AKS) by using GPU metrics collected by the NVIDIA Data Center GPU Manager (DCGM) exporter. These metrics are exposed through Azure Managed Prometheus and consumed by Kubernetes Event-Driven Autoscaling (KEDA) to automatically scale workloads based on real-time GPU utilization. This solution helps optimize GPU resource usage and control operational costs by dynamically adjusting application scale in response to workload demand.

## Prerequisites

- [Azure CLI](/en-us/cli/azure/install-azure-cli) version 2.60.0 or later. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- [Helm](https://helm.sh/docs/intro/install/) version 3.17.0 or later installed.
- [kubectl](https://kubernetes.io/docs/tasks/tools/) version 1.28.9 or later installed.
- NVIDIA GPU quota in your Azure subscription. This example uses the `Standard_NC40ads_H100_v5` SKU, but other NVIDIA H100 VM SKUs are also supported.

Before proceeding, ensure your AKS cluster is configured with the following:

- [Integrate KEDA with your Azure Kubernetes Service cluster](/en-us/azure/azure-monitor/containers/integrate-keda).
- [Monitor GPU metrics from NVIDIA DCGM exporter with Azure Managed Prometheus and Azure Managed Grafana](monitor-gpu-metrics).

At this point, you should have:

- An AKS cluster with [NVIDIA GPU-enabled node pools](use-nvidia-gpu), and [GPUs confirmed as schedulable](use-nvidia-gpu#confirm-that-gpus-are-schedulable).
- [Azure Managed Prometheus and Grafana enabled on your AKS cluster](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable). [KEDA enabled on your cluster](/en-us/azure/azure-monitor/containers/integrate-keda).
- The User Assigned Managed Identity used by KEDA assigned the `Monitoring Data Reader` role scoped to the Azure Monitor Workspace associated with your AKS cluster.

## Create a new KEDA scaler using the NVIDIA DCGM Exporter metrics

To create a KEDA scaler, you need two components:

1. The Prometheus query endpoint.
2. The User Assigned Managed Identity.

### Retrieve the Azure Managed Prometheus query endpoint

1. You can find this value in the **Overview** section of the Azure Monitor workspace attached to your AKS cluster in the Azure portal.

    ![Screenshot of the Managed Prometheus Query Endpoint.](media/autoscale-gpu/prometheus-query-ep-1.png)
2. Export the Azure Managed Prometheus query endpoint to an environmental variable:

    ```bash
    export PROMETHEUS_QUERY_ENDPOINT="https://example.prometheus.monitor.azure.com"
    ```

### Retrieve the User Assigned Managed Identity

The User Assigned Managed Identity was previously created following the [KEDA integration steps](/en-us/azure/azure-monitor/containers/integrate-keda#set-up-a-workload-identity). If needed, reload this value with the [`az identity show`](/en-us/cli/azure/identity#az-identity-show) command:

```azurecli
export USER_ASSIGNED_CLIENT_ID="$(az identity show --resource-group $RESOURCE_GROUP --name $USER_ASSIGNED_IDENTITY_NAME --query 'clientId' -o tsv)"
```

## Create the KEDA scaler manifest

This manifest creates the `TriggerAuthentication` and `ScaledObject` for autoscaling based on GPU utilization measured by the `DCGM_FI_DEV_GPU_UTIL` metric.

Note

This example uses the `DCGM_FI_DEV_GPU_UTIL` metric, which measures GPU utilization. Other metrics are also available from the DCGM exporter depending on your workload requirements. For a complete list of available metrics, refer to the [NVIDIA DCGM Exporter documentation](https://github.com/NVIDIA/dcgm-exporter#metrics).

| Field | Description |
| --- | --- |
| `metricName` | Specifies the GPU metric to monitor. `DCGM_FI_DEV_GPU_UTIL` reports the percentage of time the GPU is actively processing workloads. This value typically ranges from 0 to 100. |
| `query` | PromQL query that calculates the average GPU utilization across all pods in the deployment `my-gpu-workload`. This ensures scaling decisions are based on overall GPU usage, not a single pod. |
| `threshold` | The target average GPU utilization percentage that triggers scaling. If the average exceeds **5%**, the scaler increases the number of pod replicas. |
| `activationThreshold` | The minimum average GPU utilization required to activate scaling. If the utilization is below **2%**, scaling actions will not occur, preventing unnecessary scaling during low activity periods. |

1. Create the following KEDA manifest:

    ```bash
    cat <<EOF > keda-gpu-scaler-prometheus.yaml
    apiVersion: keda.sh/v1alpha1
    kind: TriggerAuthentication
    metadata:
      name: azure-managed-prometheus-trigger-auth
    spec:
      podIdentity:
        provider: azure-workload
        identityId: ${USER_ASSIGNED_CLIENT_ID}
    ---
    apiVersion: keda.sh/v1alpha1
    kind: ScaledObject
    metadata:
      name: my-gpu-workload
    spec:
      scaleTargetRef:
        name: my-gpu-workload
      minReplicaCount: 1
      maxReplicaCount: 20
      triggers:
        - type: prometheus
          metadata:
            serverAddress: ${PROMETHEUS_QUERY_ENDPOINT}
            metricName: DCGM_FI_DEV_GPU_UTIL
            query: avg(DCGM_FI_DEV_GPU_UTIL{deployment="my-gpu-workload"})
            threshold: '5'
            activationThreshold: '2'
          authenticationRef:
            name: azure-managed-prometheus-trigger-auth
    EOF
    ```
2. Apply this manifest using the `kubectl apply` command:

    ```bash
    kubectl apply -f keda-gpu-scaler-prometheus.yaml
    ```

## Test the new scaling capabilities

1. Create a sample workload that consumes GPU resources in your AKS cluster. You can start with the following example:

    ```bash
    cat <<EOF > my-gpu-workload.yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: my-gpu-workload
      namespace: default
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: my-gpu-workload
      template:
        metadata:
          labels:
            app: my-gpu-workload
        spec:
          tolerations:
            - key: "sku"
              operator: "Equal"
              value: "gpu"
              effect: "NoSchedule"
          containers:
            - name: my-gpu-workload
              image: mcr.microsoft.com/azuredocs/samples-tf-mnist-demo:gpu
              command: ["/bin/sh"]
              args: ["-c", "while true; do python /app/main.py --max_steps=500; done"]
              resources:
                limits:
                  nvidia.com/gpu: 1
    EOF
    ```
2. Apply this deployment manifest using the `kubectl apply` command:

    ```bash
    kubectl apply -f my-gpu-workload.yaml
    ```

    Note

    If no GPU nodes are currently available, the pod will remain in a `Pending` state until a node is provisioned, showing the following message:

    ```bash
    Events:
      Type     Reason            Age    From                Message
      ----     ------            ----   ----                -------
      Warning  FailedScheduling  3m19s  default-scheduler   0/2 nodes are available: 2 Insufficient nvidia.com/gpu. preemption: 0/2 nodes are available: 2 No preemption victims found for incoming pod.
    ```

    The cluster autoscaler will eventually start and provision a new GPU node:

    ```bash
    Normal   TriggeredScaleUp  2m43s  cluster-autoscaler  pod triggered scale-up: [{aks-gpunp-36854149-vmss 0->1 (max: 2)}]
    ```

    Note

    Depending on the size of your provisioned GPU SKU, node provisioning might take several minutes.
3. To verify progress, check the Horizontal Pod Autoscaler (HPA) events using the `kubectl describe` command:

    ```bash
    kubectl describe hpa my-gpu-workload
    ```

    The output should look like the following:

    ```output
    Conditions:
      Type            Status  Reason            Message
      ----            ------  ------            -------
      AbleToScale     True    ReadyForNewScale  recommended size matches current size
      ScalingActive   True    ValidMetricFound  the HPA successfully calculated a replica count from external metric s0-prometheus(&LabelSelector{MatchLabels:map[string]string{scaledobject.keda.sh/name: my-gpu-workload}})
      ScalingLimited  True    TooFewReplicas    the desired replica count is less than the minimum replica count
    ```
4. Confirm that the GPU node has been added and the pod is running with the `kubectl get` command:

    ```bash
    kubectl get nodes
    ```

    The output should look like the following:

    ```output
    NAME                                STATUS   ROLES    AGE     VERSION
    aks-gpunp-36854149-vmss000005       Ready    <none>   4m36s   v1.31.7
    aks-nodepool1-34179260-vmss000002   Ready    <none>   26h     v1.31.7
    aks-nodepool1-34179260-vmss000003   Ready    <none>   26h     v1.31.7
    ```

## Scale down the GPU node pool

To scale down the GPU node pool, delete your workload deployment using the `kubectl delete` command:

```bash
kubectl delete deployment my-gpu-workload
```

Note

You can configure the node pool to scale down to zero by enabling the cluster autoscaler and setting the `min-count` to `0` at node pool creation time. For example:

```azurecli
az aks nodepool add \
 --resource-group myResourceGroup \
 --cluster-name myAKSCluster \
 --name gpunp \
 --node-count 1 \
 --node-vm-size Standard_NC40ads_H100_v5 \
 --node-taints sku=gpu:NoSchedule \
 --enable-cluster-autoscaler \
 --min-count 0 \
 --max-count 3
```