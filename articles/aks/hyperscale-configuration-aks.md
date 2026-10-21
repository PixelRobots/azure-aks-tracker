---
layout: Conceptual
title: Hyperscale Configuration for Azure Kubernetes Service (AKS) using a Control Plane Scaling Profile (Preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/hyperscale-configuration-aks
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
description: Configure a hyperscale AKS cluster using a control plane scaling profile (preview) to ensure predictable performance for large-scale workloads.
ms.author: schaffererin
author: schaffererin
ms.topic: how-to
ms.date: 2026-08-19T00:00:00.0000000Z
ms.custom: references_regions
locale: en-us
document_id: af3a9c57-8f16-66bb-bf19-37192d4accfb
document_version_independent_id: 36bad9cd-9021-5395-153c-0412376aecf2
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/hyperscale-configuration-aks.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/hyperscale-configuration-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/hyperscale-configuration-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 698ac16c-c239-3f20-3bf3-7733f9b11e6c
---

# Hyperscale Configuration for Azure Kubernetes Service (AKS) using a Control Plane Scaling Profile (Preview) - Azure Kubernetes Service | Microsoft Learn

By default, Azure Kubernetes Service (AKS) uses the standard control plane scaling behavior, which dynamically adjusts capacity based on cluster needs. This default mode is suitable for most workloads. For workloads that require guaranteed control plane capacity, high Kubernetes API request concurrency, high pod scheduling throughput, or consistent performance across large node counts, enable hyperscale configuration.

Hyperscale configuration in AKS lets you preprovision control plane capacity for clusters that require predictable performance at scale. With hyperscale configuration, you choose a control plane scaling size with defined capacity and performance characteristics to provide predictable control plane performance for sustained demand, traffic spikes, and bursty workloads.

This article describes how to configure a hyperscale AKS cluster using a control plane scaling profile (preview).

Note

Hyperscale configuration requires an AKS cluster that uses the **Standard or Premium [pricing tier](free-standard-pricing-tiers)**. It isn't supported on the Free tier.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Control plane scaling sizes

Set the `controlPlaneScalingProfile` property on the managed cluster resource to configure hyperscale. The `scalingSize` parameter determines the scaling size. Choose from three scaling sizes: `H2`, `H4`, and `H8`. Higher scaling sizes provide increased performance and capacity for the control plane.

| Scaling size | Description | Kube API Server flow control executing requests | Pod scheduling rate | Etcd storage |
| --- | --- | --- | --- | --- |
| `H2` | Smallest scaling size with guaranteed capacity and predictable performance beyond standard tier defaults. | 1,750 | 200 pods per second | 6 partitions, 8 GiB per partition |
| `H4` | Provides guaranteed increased performance over `H2`. | 3,500 | 300 pods per second | 6 partitions, 8 GiB per partition |
| `H8` | Provides guaranteed increased performance over `H4`. | 7,000 | 400 pods per second | 6 partitions, 8 GiB per partition |

### Etcd partitions and stored resources

Etcd is partitioned into six separate clusters. Each partition stores a specific category of Kubernetes resources.

| Partition | Stored resources |
| --- | --- |
| Events | Event objects |
| Leases | Coordination leases (`coordination.k8s.io/leases`) |
| Nodes | Node objects (`v1/nodes`) |
| Pods | Pod objects (`v1/pods`) |
| Secrets | Secret objects (`v1/secrets`) |
| Default | All remaining resources (such as Deployments, Services, ConfigMaps, etc.) |

## When to use hyperscale configuration in AKS

Use hyperscale configuration when your cluster requires predictable control plane performance for high Kubernetes API concurrency, high pod scheduling throughput, or large node scale. Hyperscale configuration provides preprovisioned control plane capacity instead of relying only on dynamic control plane scaling.

Hyperscale configuration is intended for mission-critical, large-scale workloads. For most production, development, test, or steady-state workloads, the default AKS control plane mode remains the recommended and cost-optimized option.

Consider hyperscale configuration for the following scenarios:

| Scenario | Description | Example |
| --- | --- | --- |
| AI and machine learning training at scale | Run large numbers of distributed training jobs, batch workloads, or hyperparameter sweeps where scheduler latency or API throttling can delay job completion. | GPU clusters running millions of pods across thousands of nodes. |
| High-throughput SaaS platforms | Support many concurrent deployments, CI/CD triggers, and namespace-level operations while maintaining consistent API responsiveness. | Multitenant platforms with hundreds of namespaces. |
| Anticipated surge events | Preprovision control plane capacity before known demand spikes so the cluster is ready before traffic or workload activity increases. | E-commerce sales, game launches, product launches, or live events. |
| Environment consistency | Match control plane capacity across staging and production clusters to validate workloads against similar control plane performance characteristics. | Staging and production clusters using the same hyperscale tier. |
| Disaster recovery and continuity | Configure failover clusters with comparable control plane capacity so they can support production-scale activity when activated. | Active-passive multi-region disaster recovery clusters. |
| Large enterprise operations | Support clusters with highly variable workload activity, high pod churn, or unpredictable API demand where guaranteed control plane capacity is required. | Large clusters with significant day-to-day usage swings or high peak-to-average demand ratios. |

## Limitations

- **New clusters only**: You can only set a control plane scaling profile during cluster creation. You can't add a control plane scaling profile to an existing cluster.
- **Cluster quota**: Only one hyperscale cluster is supported per subscription per region during preview.
- **No removal after creation**: You can't remove a control plane scaling profile after cluster creation. To revert to a standard control plane, delete the cluster and create a new cluster.
- **Minimum Kubernetes version**: Requires Kubernetes version 1.33.0 or later.
- **Tooling support**: Azure CLI with the `aks-preview` extension, REST API, and ARM templates are supported. SDKs and Terraform aren't supported.
- **Cluster quota**: The number of clusters with hyperscale configuration enabled is subject to [AKS quotas, virtual machine (VM) size restrictions, and region availability](quotas-skus-regions). Currently, only one hyperscale cluster is supported per subscription per region.
- **Feature availability**: Hyperscale Configuration is available only in Azure public cloud regions. The following public cloud regions don't currently support Hyperscale Configuration:
    - australiacentral2
    - francecentral
    - germanywestcentral
    - norwayeast
    - southafricanorth
    - swedencentral
    - switzerlandnorth
    - taiwannorth
    - uaenorth
    - centralus

## Prerequisites

Before you can enable the control plane scaling profile, ensure you have the following prerequisites:

- The Azure CLI `aks-preview` extension installed and updated to version 21.0.0b8 or later.
- The `ControlPlaneScalingProfilePreview` feature flag registered on your subscription.

### Install or update the Azure CLI `aks-preview` extension

Install the latest version of the `aks-preview` extension using the `az extension add` command.

```azurecli
az extension add --name aks-preview --allow-preview true
```

Update the `aks-preview` extension using the `az extension update` command.

```azurecli
az extension update --name aks-preview --allow-preview true
```

Note

If installing the latest version of the `aks-preview` extension fails, try setting a specific version using the `--version` parameter. For example, to install version 21.0.0b8, run the following command:

```azurecli
az extension add --name aks-preview --allow-preview true --version 21.0.0b8
```

### Register the `ControlPlaneScalingProfilePreview` feature flag

1. Register the `ControlPlaneScalingProfilePreview` feature flag on your subscription using the `az feature register` command.

    ```azurecli
    az feature register --namespace "Microsoft.ContainerService" --name "ControlPlaneScalingProfilePreview"
    ```
2. Verify the registration status using the `az feature show` command.

    ```azurecli
    az feature show --namespace "Microsoft.ContainerService" --name "ControlPlaneScalingProfilePreview"
    ```

    It takes a few minutes for the feature flag to register.
3. Once the status shows *Registered*, refresh the registration of the Microsoft.ContainerService resource provider using the `az provider register` command.

    ```azurecli
    az provider register --namespace "Microsoft.ContainerService"
    ```

## Create a cluster with a control plane scaling profile using Azure CLI

Note

Creating a cluster with a control plane scaling profile might take longer than creating a standard cluster. Expect approximately 10 minutes for `H2`, and 20 minutes for `H4` and `H8`.

Create an AKS cluster with a control plane scaling profile using the `az aks create` command with the `--control-plane-scaling-size` parameter set to the desired scaling size: `H2`, `H4`, or `H8`. The following example creates a cluster with the control plane scaling size set to `H2`:

```azurecli
az aks create \
    --resource-group <resource-group-name> \
    --name <cluster-name> \
    --kubernetes-version 1.36.2 \
    --tier Standard \
    --node-count 3 \
    --control-plane-scaling-size H2 \
    --generate-ssh-keys
```

## Resize a control plane scaling profile using Azure CLI

Resize the control plane scaling profile for an existing AKS cluster with the feature enabled by using the `az aks update` command. Set the `--control-plane-scaling-size` parameter to the desired scaling size: `H2`, `H4`, or `H8`. The following example resizes the control plane scaling profile to `H4`:

```azurecli
az aks update \
    --resource-group <resource-group-name> \
    --name <cluster-name> \
    --control-plane-scaling-size H4
```

## Verify the control plane scaling profile using Azure CLI

Verify the control plane scaling profile for the cluster using the `az aks show` command and query the `controlPlaneScalingProfile` property.

```azurecli
az aks show \
    --resource-group <resource-group-name> \
    --name <cluster-name> \
    --query "controlPlaneScalingProfile"
```

Example output:

```json
{
  "scalingSize": "H2"
}
```

## Monitor the control plane scaling profile

AKS provides several metrics to help you monitor your control plane's tier utilization. These metrics are published as [Azure platform metrics](/en-us/azure/azure-monitor/essentials/data-platform-metrics) and are accessible through [Metrics Explorer](/en-us/azure/azure-monitor/essentials/analyze-metrics) in the Azure portal. You can also monitor these metrics via [Azure Managed Prometheus](control-plane-metrics-monitor).

| Title | Description | Unit | Platform metrics | Azure Managed Prometheus metrics |
| --- | --- | --- | --- | --- |
| API request concurrency | Current number of API Priority and Fairness execution seats the API server uses. | Count | `apiserver_flowcontrol_executing_seats`. You can filter by Priority Level. | `apiserver_flowcontrol_current_executing_seats` |
| Pod scheduling rate | Number of scheduler attempts over time, including outcome breakdowns such as scheduled and unschedulable. | Attempts per second | `scheduler_schedule_attempts_rate`. You can filter by Result Type (scheduled or unscheduled). | `scheduler_schedule_attempts_total`, `scheduler_schedule_attempts_SCHEDULED`, `scheduler_schedule_attempts_UNSCHEDULABLE` |
| Cluster database size | Maximum utilization of the Etcd database across instances in the control plane. | Percent | `etcd_database_usage_percentage`. You can filter by Resource type. | `etcd_mvcc_db_total_size_in_bytes` |

Use these metrics to validate that your selected scaling size continues to meet your workload's demand. For example:

- Sustained **API request concurrency** near the guaranteed limit for your scaling size indicates you might benefit from the next higher tier.
- A rising rate of unschedulable pods in the **pod scheduling rate** metric can signal that scheduler throughput isn't keeping pace with pod creation.
- **Cluster database size** approaching 50% for any etcd partition indicates you should review resource counts in that category before you hit storage limits.

## Best practices for hyperscale configuration in AKS

Use the following best practices when you create clusters with a control plane scaling profile:

- **Use Azure CNI Overlay networking**: [Azure CNI Overlay](azure-cni-overlay) is recommended for clusters with a large number of pods because it helps reduce IP address consumption and supports large-scale pod networking. Other CNIs are still supported.
- **Avoid enabling Azure Policy for large clusters**: The [Azure Policy add-on](use-azure-policy) isn't recommended for large clusters because it can increase Kubernetes API Server load and affect control plane performance at scale.
- **Monitor Kubernetes API Server usage**: Hyperscale configuration provides guaranteed control plane capacity, but workloads should still minimize unnecessary Kubernetes API Server traffic. Avoid excessive list and watch operations where possible.
- **Design etcd usage for 2 GB or less per partition**: Each etcd partition has a hard limit of 8 GB. Keeping usage at or below 2 GB per partition helps reduce startup time, lower latency, and avoid reaching the partition limit.
- **Configure proactive alerts**: Set alerts for Kubernetes API concurrency, pod scheduling throughput, and etcd capacity so you can detect capacity pressure before it affects workloads.