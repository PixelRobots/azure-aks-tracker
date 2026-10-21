---
layout: Conceptual
title: Enable cost optimized add-on scaling on your Azure Kubernetes Service (AKS) cluster (Preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/optimized-addon-scaling
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
description: This article provides an overview of the add-on scaling feature in Azure Kubernetes Service (AKS).
ms.author: schaffererin
author: schaffererin
ms.topic: how-to
ms.custom: aks-scaling
ms.date: 2025-05-20T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: 23d47d7d-a4df-eac1-eac4-68dc213cc025
document_version_independent_id: c85aa539-99e4-0646-7222-94d21db5f278
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/optimized-addon-scaling.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/optimized-addon-scaling
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/optimized-addon-scaling.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 46484280-2be1-f9c7-d2d0-ba0457e3bac6
---

# Enable cost optimized add-on scaling on your Azure Kubernetes Service (AKS) cluster (Preview) - Azure Kubernetes Service | Microsoft Learn

This article provides an overview of cost optimized add-on scaling in Azure Kubernetes Service (AKS). With cost-optimized add-on scaling, you can manage add-ons that require custom CPU and memory by overriding default configurations or enabling autoscaling. This feature ensures that resources aren't overly allocated to add-on pods, improving cost savings and cluster efficiency.

## Overview

Enabling cost optimized add-on scaling installs the [Vertical Pod Autoscaler (VPA) add-on](vertical-pod-autoscaler), allowing supported add-ons to autoscale based on usage.

This feature also allows you to customize the resource's default CPU/ memory requests and limits in Deployments and DaemonSets, the maximum and minimum allowed CPU/ memory, and the VPA update mode within VPA custom resources. For more information, see [customize the resource configuration for AKS add-ons](customize-resource-configuration).

### Supported AKS add-ons

The following AKS managed add-ons support the cost optimized add-on scaling feature:

| Add-on | Enablement behavior | VPA custom resource name | Command to check VPA custom resource |
| --- | --- | --- | --- |
| [CoreDNS](coredns-custom) | Enabled by default on new AKS clusters. | `coredns` | `kubectl get vpa coredns --namespace kube-system` |
| [Workload identity](workload-identity-deploy-cluster) | Optional add-on that requires manual enablement. | `azure-wi-webhook-controller-manager` | `kubectl get vpa azure-wi-webhook-controller-manager --namespace kube-system` |
| [Image Integrity](image-integrity) | Optional add-on that requires manual enablement. | `ratify` | `kubectl get vpa ratify --namespace gatekeeper-system` |
| [Network Observability (Retina)](container-network-observability-how-to) | Optional add-on that requires manual enablement. | `retina-agent` and `retina-operator` | `kubectl get vpa retina-agent --namespace kube-system` and `kubectl get vpa retina-operator --namespace kube-system` |

### Supported VPA modes for cost optimized add-on scaling

VPA currently supports the following modes for cost optimized add-on scaling:

- *Off*: The VPA provides resource recommendation data but doesn't apply it to the target pod.
- *Initial* (default mode): The VPA automatically applies CPU and memory recommendations to the target pod when it restarts, but it doesn't initiate the restart itself.
- *Auto*: The VPA automatically updates CPU and memory requests for pods based on recommendations.

Note

When enabling cost optimized add-on scaling, consider the following information:

- If you delete the Deployment, DaemonSet, or VPA custom resource, the changes revert back to the AKS add-on's initial configuration.
- The cost optimized add-on scaling feature enables the [VPA add-on](vertical-pod-autoscaler) to autoscale the supported AKS add-ons. It doesn't work with self-hosted VPA.
- AKS restarts the add-on pods when enabling cost optimized add-on scaling. CoreDNS is currently the only exception to avoid potential disruptions during the restart. For more information, see [CoreDNS autoscaling behavior](coredns-autoscale).

Warning

Make sure you have enough compute resources on the system node pool for your add-ons when you enable cost optimized add-on scaling. AKS recommends turning on the [cluster autoscaler](cluster-autoscaler-overview) or [node autoprovision](node-auto-provisioning) to ensure right-sizing of your compute resources automatically. Monitor for pending add-on pods when using the cost-optimized add-on scaling feature. VPA might recommend resource requests that exceed available node capacity, potentially leading to unschedulable pods. You can control this behavior by [customizing min/max values](customize-resource-configuration) for requests and limits of supported add-ons.

## Prerequisites

- An AKS cluster running Kubernetes version 1.25 or later.
- The Azure CLI version 2.60.0 or later installed and configured. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- Install the `aks-preview` Azure CLI extension and register the cost optimized add-on scaling preview feature.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

### Install the `aks-preview` Azure CLI extension

1. Install the `aks-preview` extension using the `az extension add` command.

    ```azurecli
    az extension add --name aks-preview
    ```
2. Update to the latest version of the extension using the `az extension update` command.

    ```azurecli
    az extension update --name aks-preview
    ```

### Register the cost optimized add-on scaling preview feature

1. Register the cost optimized add-on scaling preview feature using the `az feature register` command.

    ```azurecli
    az feature register --namespace "Microsoft.ContainerService" --name "AKS-AddonAutoscalingPreview"
    ```

    It takes a few minutes for the status to show as *Registered*.
2. Verify the registration status using the `az feature show` command.

    ```azurecli
    az feature show --namespace "Microsoft.ContainerService" --name "AKS-AddonAutoscalingPreview"
    ```
3. When the status shows as *Registered*, refresh the registration of the Microsoft.ContainerService provider using the `az provider register` command.

    ```azurecli
    az provider register --namespace Microsoft.ContainerService
    ```

## Enable cost optimized add-on scaling on an AKS cluster

When enabling the add-on, the AKS cluster automatically installs the [VPA add-on](vertical-pod-autoscaler). The AKS add-ons that support the cost optimized add-on scaling feature have different enablement behavior.

Note

If you're using Bicep, ARM templates, or Terraform, set `VerticalPodAutoscaler` to `"True"` and `AddonAutoscaling` to `"enabled"`.

### Enable cost optimized add-on scaling on a new cluster

- Enable cost optimized add-on scaling on a new AKS cluster using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--enable-optimized-addon-scaling` flag.

    ```azurecli
    az aks create --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME --enable-optimized-addon-scaling
    ```

### Enable cost optimized add-on scaling on an existing cluster

- Enable cost optimized add-on scaling on an existing AKS cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-) command with the `--enable-optimized-addon-scaling` flag.

    ```azurecli
    az aks update --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME --enable-optimized-addon-scaling
    ```

## Disable cost optimized add-on scaling on an AKS cluster

- Disable cost optimized add-on scaling on an AKS cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-) command with the `--disable-optimized-addon-scaling` flag.

    ```azurecli
    az aks update --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME --disable-optimized-addon-scaling
    ```

Note

Disabling the cost optimized add-on scaling feature doesn't disable the VPA add-on by default. To disable VPA, see [Disable VPA on an AKS cluster](use-vertical-pod-autoscaler#disable-the-vertical-pod-autoscaler-on-an-existing-cluster).

## Customize default resource configuration

With the cost optimized add-on scaling feature enabled on your cluster, you can customize the default CPU/memory settings for the add-on resources as well as the default VPA configuration for supported AKS add-ons. For more information, see [customize the resource configuration for AKS add-ons](customize-resource-configuration).

## Applying the VPA recommended values manually

Note

With *Initial* mode, the VPA applies the recommended CPU and memory requests only when a pod is created or updated. If you want the recommendations to take effect immediately, please update the pods manually. Before manually applying the recommended values, [make sure the VPA update mode is set to *Initial* or *Auto* in the VPA custom resource](customize-resource-configuration#customize-resource-update-mode).

1. Check the pod status and CPU/memory utilization to verify that the pod is running as expected.

    The following example uses the `kubectl get pod` command to check a CoreDNS pod status:

    ```bash
    kubectl get pod <coredns-pod-name> --namespace kube-system -o yaml
    ```

    The following output shows an example status of a CoreDNS pod:

    ```output
    apiVersion: v1
    kind: Pod
    metadata:
      name: <coredns-pod-name>
      namespace: kube-system
    spec:
      ...
      containers:
      - name: coredns
        resources:
          limits:
            cpu: "3"
            memory: "500Mi"
          requests:
            cpu: "100m"
            memory: "70Mi"
    ```
2. Get the VPA recommended value using the `kubectl get vpa` command.

    ```bash
    kubectl get vpa coredns --namespace kube-system
    ```

    The following output shows an example of the VPA recommended value for a CoreDNS pod:

    ```output
    NAME      MODE      CPU   MEM        PROVIDED   AGE
    coredns   Initial   11m   23574998   True       44m
    ```
3. If you want to use the values recommended by VPA, manually delete the pod using the `kubectl delete pod` command to restart the pod with the VPA recommended values.

    ```bash
    kubectl delete pod <coredns-pod-name> --namespace kube-system
    ```
4. After the pod restarts, verify the pod status and CPU/memory updates using the `kubectl get pod` command.

    ```bash
    kubectl get pod <coredns-pod-name> --namespace kube-system -o yaml
    ```

    The following output shows an example status of a CoreDNS pod after applying the VPA recommended values:

    ```output
    apiVersion: v1
    kind: Pod
    metadata:
      name: <coredns-pod-name>
      namespace: kube-system
    spec:
      ...
      containers:
      - name: coredns
        resources:
          limits:
            cpu: "330m"
            memory: "168392842"
          requests:
            cpu: "11m"
            memory: "23574998"
    ```

## Troubleshooting

With the cost optimized add-on scaling feature enabled on your cluster, you can customize the default CPU and memory settings for add-on resources, as well as modify the default VPA configuration for supported AKS managed add-ons

If your autoscaling enabled add-on pods are in a pending state, or you don't see any VPA recommendations for autoscaling enabled add-ons, follow these steps to troubleshoot the issue.

### Check AKS-managed VPA add-on status

1. Check if all VPA system components are running using the `kubectl get pods` command.

    ```bash
    kubectl get pods --namespace kube-system | grep vpa
    ```

    The output should show three pods (vpa-admission-controller, vpa-recommender, and vpa-updater) running in the `kube-system` namespace, similar to the following example:

    ```output
    vpa-admission-controller   2/2     2            2           4m11s
    vpa-recommender            1/1     1            1           4m11s
    vpa-updater                1/1     1            1           4m11s
    ```
2. For each of the three VPA pods, check the logs for any errors using the `kubectl logs` command. Make sure to replace `<pod-name>` with the names of the VPA pods.

    ```bash
    kubectl logs <pod-name> --namespace kube-system | grep -e '^E[0-9]\{4\}'
    ```
3. Confirm the custom resource definition (CRD) was creating using the `kubectl get` command.

    ```bash
    kubectl get customresourcedefinition | grep verticalpodautoscalers
    ```

### Check pod status and CPU/memory utilization

1. Check the pod's status using the `kubectl get pod` command.

    ```bash
    kubectl get pod <pod-name> --namespace=kube-system
    ```
2. If the pod has a status of `Pending`, check the pod's status property to determine the reason the pod isn't running.

    ```bash
    kubectl describe pod <pod-name> --namespace kube-system -o yaml
    ```

    The following output shows an example status of a pod with a status of `Pending`:

    ```output
    apiVersion: v1
    kind: Pod
    ...
    status:
      conditions:
      - lastProbeTime: null
        lastTransitionTime: "2023-05-03T17:05:26Z"
        message: '0/1 nodes are available: 1 Insufficient cpu, 1 Insufficient memory.
          preemption: 0/1 nodes are available: 1 Insufficient cpu, 1 Insufficient memory..'
        reason: Unschedulable
        status: "False"
        type: PodScheduled
      phase: Pending
      qosClass: Guaranteed
    ```
3. If the output shows that the pod is `Pending` due to insufficient CPU or memory, consider the following actions:

    - Add more nodes so that pods can be scheduled in nodes with lower resource usage.
    - Disable VPA for the target add-on pod by changing the update mode to *Off*, and then [manually update the requests/limits](customize-resource-configuration) to the available resource values on the node. Be cautious when setting resource limits to extremely low values, as this may result in the pod encountering OOM kills or CPU throttling if it attempts to use more resources than are available on the node.