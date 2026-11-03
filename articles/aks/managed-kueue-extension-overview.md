---
layout: Conceptual
title: Managed Kueue extension overview - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/managed-kueue-extension-overview
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
description: Learn the basic concepts for the AKS managed Kueue extension.
ms.topic: overview
ms.date: 2026-10-22T00:00:00.0000000Z
author: colinmixonn
ms.author: colinmixon
ai-usage: ai-assisted
locale: en-us
document_id: b9b83cb2-fb48-423b-6238-df3deac1d479
document_version_independent_id: ecc29b48-21da-2236-2b75-108194e17fa0
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/managed-kueue-extension-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/managed-kueue-extension-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/managed-kueue-extension-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 9c609430-9efe-48c9-05b4-0fa32b084224
---

# Managed Kueue extension overview - Azure Kubernetes Service | Microsoft Learn

[Kueue](https://kueue.sigs.k8s.io/docs/overview/) provides Kubernetes-native job queueing and resource admission for batch and AI workloads. It decides when a workload can start based on available queue quota and configured policies. After admission, the Kubernetes scheduler places the workload's pods on nodes.

On Azure Kubernetes Service (AKS), prefer the **managed Kueue extension (preview)** to install and manage the supported Kueue controller and generate managed resources for your cluster. See [Install the managed Kueue extension on AKS](install-the-managed-kueue-extension-on-aks).

This article explains the basic concepts of Kueue and the managed Kueue extension.

Important

Open-source software is mentioned throughout AKS documentation and samples. Software that you deploy is excluded from AKS service-level agreements, limited warranty, and Azure support. As you use open-source technology alongside AKS, consult the support options available from the respective communities and project maintainers to develop a plan.

Microsoft takes responsibility for building the open-source packages that we deploy on AKS. That responsibility includes having complete ownership of the build, scan, sign, validate, and hotfix process, along with control over the binaries in container images. For more information, see [Vulnerability management for AKS](concepts-vulnerability-management#aks-container-images) and [AKS support coverage](support-policies#aks-support-coverage).

## When to use Kueue

Use Kueue for workloads that can wait for sufficient quota and resources before they run, such as:

- AI and machine learning training.
- GPU-intensive batch jobs.
- Data processing and analytics.
- Hyperparameter tuning and batch inference.
- Media encoding and other finite processing jobs.

Kueue integrates with Kubernetes Jobs and supported workload APIs such as RayJob. The integrations supported by the managed extension are listed in the [managed installation guide](install-the-managed-kueue-extension-on-aks#limitations).

Kueue admission isn't the same as pod scheduling or Azure capacity allocation. Available queue quota doesn't guarantee that a pod can be scheduled immediately. For capacity provisioning before admission, see [Use managed Kueue with the cluster autoscaler](use-managed-kueue-extension-with-the-cluster-autoscaler-on-aks).

## Understand Kueue basic concepts

The following resources connect a submitted workload to a quota and admission policy:

| Resource | Purpose |
| --- | --- |
| `ResourceFlavor` | Describes the node characteristics used when assigning resources to workloads. The managed extension generates flavors for eligible user nodes. |
| `ClusterQueue` | Defines cluster-scoped resource quotas, flavor references, and policies such as queueing and preemption. |
| `LocalQueue` | Provides a namespace-scoped submission point that references a `ClusterQueue`. A `LocalQueue` is usually named after a team, business unit, user, or project. |
| `Workload` | Records a workload's resource requests, quota reservation, and admission state. Supported workload integrations create this object. |
| `WorkloadPriorityClass` | Assigns a priority to workloads for admission ordering and applicable preemption policies. The managed extension provides default classes. |

The admission flow is:

**Job or other supported workload → LocalQueue → ClusterQueue → admission checks and quota reservation → workload admission → pod scheduling**

A workload's `kueue.x-k8s.io/queue-name` label identifies a LocalQueue in its namespace. The LocalQueue routes the workload to its ClusterQueue. If the required quota or an admission check isn't ready, the workload waits rather than starting its pods.

A ClusterQueue quota is an admission policy, not a node-pool size or an Azure subscription quota. Queue owners configure quotas according to their capacity and sharing policy.

## Understand managed resources and priorities for the AKS managed Kueue extension

The managed extension generates resources such as the `aks-cpu` ResourceFlavor for eligible CPU user nodes and provides `aks-low-priority`, `aks-medium-priority`, and `aks-high-priority` workload priority classes. GPU flavor names depend on the detected GPU hardware. Inspect the resources generated for your cluster rather than assuming a name.

Reference managed resources from your queues and workloads. Don't recreate them with reserved AKS names or change their protection markers. You still own your ClusterQueues, LocalQueues, workload requests, and quota policies.

Priority affects admission ordering. It enables preemption only when the ClusterQueue's preemption policy permits it. A higher priority alone doesn't authorize a workload to evict another workload. See the [low- and high-priority Job example](schedule-and-deploy-batch-jobs-with-managed-kueue-extension-on-aks#use-workload-priority-and-preemption).

## Kueue features in the managed extension

The managed preview provides the following feature configuration:

| Feature | Managed configuration |
| --- | --- |
| Topology-aware scheduling (`TopologyAwareScheduling`) | Enabled by default. Configure your queues and workloads to use topology-aware placement where supported. |
| LocalQueue metrics (`LocalQueueMetrics`) | Enabled by default. Kueue exposes metrics about LocalQueue activity and admission. |
| ClusterQueue resource metrics | Enabled. Kueue exposes per-ClusterQueue quota and resource-usage metrics. |
| Workload integrations | Kubernetes Job, Pod, Deployment, StatefulSet, JobSet, RayJob, RayService, RayCluster, MPIJob, and Trainer v2 TrainJob are enabled. Legacy Kubeflow Trainer v1 jobs, AppWrapper, and LeaderWorkerSet aren't enabled. |
| MultiKueue | Disabled by default. Azure services manage its configuration for supported multi-cluster scenarios. |

Exposing metrics doesn't configure their collection or storage. Configure monitoring separately.

Feature gates, controller configuration, and workload integrations are managed as part of the extension release. You can't override them through customer-supplied extension configuration settings or Helm values. You can still configure your own ClusterQueues, LocalQueues, quotas, and workload policies through the Kueue APIs.

## Responsibilities

Platform administrators typically:

- Provision and manage AKS node pools.
- Install the managed extension and verify controller health.
- Configure ClusterQueues, quotas, sharing, and preemption policies.
- Provide LocalQueues and monitor admission and cluster capacity.

Workload owners typically:

- Submit supported workloads to a LocalQueue.
- Select an appropriate workload priority class.
- Set resource requests and any required placement constraints.
- Monitor workload admission, pod scheduling, and application results.

## Choose an installation approach

### Recommended: managed Kueue extension

Use the managed extension to manage the supported Kueue version and controller configuration through Azure. AKS also generates managed ResourceFlavors and provides default workload priority classes. Follow [Install the managed Kueue extension on AKS](install-the-managed-kueue-extension-on-aks).

For cluster and client requirements, see the [managed extension prerequisites](install-the-managed-kueue-extension-on-aks#prerequisites).

For lifecycle operations, see [Uninstall the managed Kueue extension](install-the-managed-kueue-extension-on-aks#uninstall-the-managed-kueue-extension). Uninstalling deletes Kueue custom resources and queue configuration; it isn't a controller-health workaround.

### Alternative (not recommended)

If you need to select and manage your own Kueue version or controller configuration, you can alternatively install the open-source project, including through Helm. Use the [upstream Kueue installation instructions](https://kueue.sigs.k8s.io/docs/installation/) for that path instead of applying upstream installation commands to a managed extension.

Manage a self-hosted installation's configuration and lifecycle separately. Don't run a self-hosted Kueue controller alongside the managed extension on the same cluster.