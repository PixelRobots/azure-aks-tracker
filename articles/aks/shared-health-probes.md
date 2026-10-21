---
layout: Conceptual
title: Use Shared Health Probes for externalTrafficPolicy Cluster Services in Azure Kubernetes Service (AKS) (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/shared-health-probes
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
description: Learn how to use shared health probes for Services with externalTrafficPolicy set to Cluster in Azure Kubernetes Service (AKS) to improve load balancer efficiency and reduce configuration complexity.
ms.subservice: aks-networking
ms.custom: devx-track-azurecli
ms.topic: how-to
ms.date: 2024-01-23T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
locale: en-us
document_id: 7eb86336-92cf-9b1f-3ed4-072f908d8b0e
document_version_independent_id: b6b9c566-cf9b-9a6e-3fd9-b13633f3dfe3
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/shared-health-probes.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/shared-health-probes
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/shared-health-probes.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 821f9c0d-174b-62dd-84bd-7abc7f4dd1a4
---

# Use Shared Health Probes for externalTrafficPolicy Cluster Services in Azure Kubernetes Service (AKS) (preview) - Azure Kubernetes Service | Microsoft Learn

This article describes how to enable **shared health probe mode** (preview) for Services with `externalTrafficPolicy: Cluster` in Azure Kubernetes Service (AKS). Shared probe mode improves load balancer efficiency, reduces configuration complexity, and provides more accurate node health monitoring.

## About shared health probe mode

In clusters that use `externalTrafficPolicy: Cluster`, Azure Standard Load Balancer (SLB) currently creates a *separate probe per Service* and targets each Service's `nodePort`.

This design means SLB infers node health from whichever **application pod** answers the probe. As clusters grow, this approach leads to several issues, including:

- **Configuration drift and blind spots**: SLB can't detect a failed or misconfigured `kube‑proxy` if iptables rules are still present.
- **Duplicate health logic**: Readiness must be defined twice. Once in each pod's `readinessProbe`, and again through SLB annotations.
- **Operational overhead**: Each Service on each node is probed every *five seconds*, consuming connections, SNAT ports, and SLB rule space.
- **Feature friction**: Customers can't set `allocateLoadBalancerNodePorts=false`, and workloads like Istio or ingress‑nginx require extra annotations to keep probes working.
- **Troubleshooting confusion**: An unhealthy app, Network Policy rule, or scale‑to‑zero event can make an *entire node* appear down.

**Shared probe mode** solves these problems by moving to a *single HTTP probe* for all `externalTrafficPolicy: Cluster` Services. In shared probe mode:

- SLB probes `http://<node‑ip>:10356/healthz`, the standard `kube‑proxy` health endpoint.
- A lightweight sidecar runs next to `kube‑proxy` to relay the probe and handle PROXY protocol when Private Link Service is enabled.

## Benefits of shared probe mode

The following table outlines **key benefits** of using shared probe mode:

| Benefit | Why it matters |
| --- | --- |
| Accurate node health | SLB now measures `kube‑proxy` directly, not an arbitrary backend pod. |
| Simpler configuration | No per‑Service probe annotations; readiness lives solely in the pod spec. |
| Lower traffic overhead | One probe per node instead of *Services × (nodes – 1)* probes. |

Note

Keep the following information in mind when using shared probe mode:

- Services that use `externalTrafficPolicy: Local` are **unchanged**.
- This feature does **not** address container‑native load balancing.

## Before you begin

- Install or update the `aks-preview` Azure CLI extension.
- Register the `EnableSLBSharedHealthProbePreview` feature flag in your Azure subscription.

### Install or update the `aks-preview` Azure CLI extension

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

- Install the `aks-preview` extension using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command.

    ```azurecli
    az extension add --name aks-preview
    ```
- Update to the latest version of the `aks-preview` extension using the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command.

    ```azurecli
    az extension update --name aks-preview
    ```

### Register the `EnableSLBSharedHealthProbePreview` feature flag

1. Register the `EnableSLBSharedHealthProbePreview` feature flag using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

    ```azurecli
    az feature register --namespace "Microsoft.ContainerService" --name "EnableSLBSharedHealthProbePreview"
    ```

    It takes a few minutes for the status to show *Registered*.
2. Verify the registration status using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command:

    ```azurecli
    az feature show --namespace "Microsoft.ContainerService" --name "EnableSLBSharedHealthProbePreview"
    ```
3. When the status reflects *Registered*, refresh the registration of the *Microsoft.ContainerService* resource provider using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace Microsoft.ContainerService
    ```

## Enable shared probe mode on an AKS cluster

# [Create a new cluster with shared probe mode](#tab/new-cluster-shared-probe-mode)
- Create a new cluster with shared probe mode using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--cluster-service-load-balancer-health-probe-mode` parameter set to `shared`.

    ```azurecli
    az aks create \
      --resource-group $RESOURCE_GROUP \
      --name $CLUSTER_NAME \
      --cluster-service-load-balancer-health-probe-mode shared
    ```

# [Update an existing cluster to use shared probe mode](#tab/existing-cluster-shared-probe-mode)
- Update an existing cluster to use shared probe mode using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--cluster-service-load-balancer-health-probe-mode` parameter set to `shared`.

    ```azurecli
    az aks update \
      --resource-group $RESOURCE_GROUP \
      --name $CLUSTER_NAME \
      --cluster-service-load-balancer-health-probe-mode shared
    ```

---