---
layout: Conceptual
title: Configure Kueue queues for Ray workloads on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/configure-ray-kueue-queues
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
description: Learn how to configure Kueue ResourceFlavors, ClusterQueues, and LocalQueues to manage admission control for Ray workloads on AKS.
ms.topic: how-to
ms.date: 2026-06-26T00:00:00.0000000Z
author: feiskyer
ms.author: peni
ms.custom: stateful-workloads
locale: en-us
document_id: f3e15628-c0af-d808-58fe-f508735a5075
document_version_independent_id: 183a145b-0157-9c2b-543b-7fab79704aa5
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/configure-ray-kueue-queues.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/configure-ray-kueue-queues
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/configure-ray-kueue-queues.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/63959238-cb90-4871-a33d-4a5519097e47
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/78d87f42-5582-4a6b-90be-7db2f12b34e6
platformId: d0a92d40-55f5-34d2-daac-d2faf39b0892
---

# Configure Kueue queues for Ray workloads on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

In this article, you configure Kueue admission control for Ray workloads on Azure Kubernetes Service (AKS). Kueue gates RayJob submissions: jobs are created with `suspend: true` and a queue label. Kueue admits them when quota is available by setting `suspend: false`, which triggers the KubeRay operator to create the Ray cluster.

Two queue configurations are provided. Choose the one that fits your use case:

| Configuration | What it demonstrates |
| --- | --- |
| **Single queue** | One ClusterQueue with backpressure - one workload runs, the next waits |
| **Team queues** | Two ClusterQueues in a shared cohort with per-team quotas, borrowing, and preemption |

Important

Open-source software is mentioned throughout AKS documentation and samples. Software that you deploy is excluded from AKS service-level agreements, limited warranty, and Azure support. As you use open-source technology alongside AKS, consult the support options available from the respective communities and project maintainers to develop a plan.

Microsoft takes responsibility for building the open-source packages that we deploy on AKS. That responsibility includes having complete ownership of the build, scan, sign, validate, and hotfix process, along with control over the binaries in container images. For more information, see [Vulnerability management for AKS](concepts-vulnerability-management#aks-container-images) and [AKS support coverage](support-policies#aks-support-coverage).

## Prerequisites

- Infrastructure deployed following [Deploy infrastructure for Ray and Kueue on AKS](deploy-ray-infrastructure).
- `kubectl` connected to the cluster.
- Kueue controller running (verify with `kubectl -n kueue-system get pods`).

## Create the namespace and service account

Navigate to the queue configuration module in the cloned repository:

```bash
cd <path-to-cloned-repo>/AKS/examples/kueue-and-ray-on-aks/2-kueue-queues
kubectl apply -f manifests/00-namespace.yaml
kubectl apply -f <(terraform -chdir=../1-infrastructure/terraform output -raw ray_workload_sa_yaml)
```

Verify the service account has workload identity annotations:

```bash
kubectl -n ray get serviceaccount ray-workload -o yaml
```

The output should include `azure.workload.identity/client-id` and `azure.workload.identity/tenant-id` annotations that allow Ray pods to access Azure Blob Storage without credentials.

## Create ResourceFlavors

ResourceFlavors describe types of nodes available in the cluster. Create two flavors - `default` (any node) and `gpu` (NVIDIA accelerator nodes):

```bash
kubectl apply -f manifests/10-resource-flavors.yaml
```

Verify:

```bash
kubectl get resourceflavors
```

Expected output:

```output
NAME      AGE
default   1m
gpu       1m
```

The `gpu` flavor targets nodes with label `accelerator=nvidia`, which AKS automatically applies to GPU node pools.

## Option A: Configure a single queue

The single-queue configuration creates one ClusterQueue with quotas sized for one workload at a time. When quota is fully consumed, the next submission stays Pending until the first completes.

```bash
kubectl apply -f manifests/20-single-queue.yaml
```

Verify the ClusterQueue and LocalQueue:

```bash
kubectl get clusterqueue cluster-queue
kubectl -n ray get localqueue default
```

Expected output:

```output
NAME            COHORT   PENDING WORKLOADS
cluster-queue            0
```

```output
NAME      CLUSTERQUEUE    PENDING WORKLOADS   ADMITTED WORKLOADS
default   cluster-queue   0                   0
```

Check the configured quotas:

```bash
kubectl get clusterqueue cluster-queue -o jsonpath='{.spec.resourceGroups}' | python3 -m json.tool
```

Default quotas are sized to admit one workload from this solution at a time: 96 CPU, 768 Gi memory, 8 GPUs.

## Option B: Configure team queues with borrowing

The team-queue configuration splits the GPU node across two teams, each with their own ClusterQueue, connected via a shared cohort:

```bash
kubectl apply -f manifests/30-team-queues.yaml
```

Important

Choose Option A or Option B, not both. To switch between them, delete the active configuration first:

```bash
kubectl delete -f manifests/20-single-queue.yaml
```

Verify:

```bash
kubectl get clusterqueues
kubectl -n ray get localqueues
```

Expected output:

```output
NAME        COHORT          PENDING WORKLOADS
team-a-cq   shared-cohort   0
team-b-cq   shared-cohort   0
```

```output
NAME     CLUSTERQUEUE    PENDING WORKLOADS   ADMITTED WORKLOADS
team-a   team-a-cq       0                   0
team-b   team-b-cq       0                   0
```

Note

The workload examples default to `QUEUE_NAME=default`, which matches Option A. If you chose Option B, set `export QUEUE_NAME=team-a` or `export QUEUE_NAME=team-b`**before** running `source env.example` in each workload directory.

Each team gets 4 GPUs guaranteed with a `borrowingLimit` of 4, so a team can use up to 8 GPUs total when the other team is idle. Key behaviors:

| Scenario | What happens |
| --- | --- |
| Team A submits, Team B idle | Team A gets all 8 GPUs (4 own + 4 borrowed) |
| Team B submits while Team A uses 8 | Kueue preempts Team A's borrowed GPUs, Team B gets its guaranteed 4 |
| Both teams busy | Each team uses its guaranteed 4 GPUs |

## Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| Workload stays Pending | Quota exhausted | Wait for the running workload to finish, or increase `nominalQuota` in the ClusterQueue |
| `LocalQueue not found` | Wrong queue-name label | Verify the `kueue.x-k8s.io/queue-name` label matches an existing LocalQueue name |
| ResourceFlavor not matching nodes | Missing node label | Check GPU nodes have `accelerator=nvidia` label with `kubectl get nodes --show-labels` |
| Kueue controller not running | Helm release issue | Check with `kubectl -n kueue-system logs deploy/kueue-controller-manager` |

For the full manifest details, see the [2-kueue-queues directory](https://github.com/Azure/AKS/tree/master/examples/kueue-and-ray-on-aks/2-kueue-queues) in the repository.

## Clean up resources

To remove the Kueue queue configuration (keeps the cluster and operators):

```bash
kubectl delete -f manifests/20-single-queue.yaml   # or 30-team-queues.yaml
kubectl delete -f manifests/10-resource-flavors.yaml
kubectl delete -f manifests/00-namespace.yaml
```

Note

Deleting the `ray` namespace removes all workloads, LocalQueues, and the ServiceAccount in that namespace. ClusterQueues and ResourceFlavors are cluster-scoped and must be deleted separately. To tear down the entire infrastructure, see [Deploy infrastructure for Ray and Kueue on AKS](deploy-ray-infrastructure#clean-up-resources).