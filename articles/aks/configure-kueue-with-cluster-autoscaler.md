---
layout: Conceptual
title: Configure Kueue with the cluster autoscaler on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/configure-kueue-with-cluster-autoscaler
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
description: Learn how to pair Kueue with the AKS cluster autoscaler to autoscale your AI workloads.
ms.topic: how-to
ms.date: 2026-07-17T00:00:00.0000000Z
author: AaronLiChen
ms.author: lichen5
ms.custom: stateful-workloads
locale: en-us
document_id: 2945c0e8-f98c-faef-8612-250fb33d9ad0
document_version_independent_id: d5c3d80e-c9f0-0eaa-ad9c-61362ff3cc28
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/configure-kueue-with-cluster-autoscaler.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/configure-kueue-with-cluster-autoscaler
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/configure-kueue-with-cluster-autoscaler.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 447ba266-c832-e254-2105-670da4064d85
---

# Configure Kueue with the cluster autoscaler on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

In this article, you pair [Kueue](https://kueue.sigs.k8s.io/) admission control with the Azure Kubernetes Service (AKS) [cluster autoscaler](cluster-autoscaler-overview) so that batch jobs get the nodes they need *before* they run. Create jobs with `suspend: true` and a queue label. Kueue creates a Kubernetes [ProvisioningRequest](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/provisioningrequest) on their behalf. The cluster autoscaler atomically scales up the node pool to satisfy it, and only then does Kueue admit the job.

| Component | Role |
| --- | --- |
| **Kueue** | Queues the job and gates admission against quota |
| **ProvisioningRequest AdmissionCheck** | Asks the cluster autoscaler for capacity before admission |
| **Cluster autoscaler** | Atomically scales up the node pool to satisfy the request |

Important

Open-source software is mentioned throughout AKS documentation and samples. Software that you deploy is excluded from AKS service-level agreements, limited warranty, and Azure support. As you use open-source technology alongside AKS, consult the support options available from the respective communities and project maintainers to develop a plan.

Microsoft takes responsibility for building the open-source packages that we deploy on AKS. That responsibility includes having complete ownership of the build, scan, sign, validate, and hotfix process, along with control over the binaries in container images. For more information, see [Vulnerability management for AKS](concepts-vulnerability-management#aks-container-images) and [AKS support coverage](support-policies#aks-support-coverage).

## Prerequisites

- This article assumes basic knowledge of Kueue. For more information, see [Learn about Kueue for batch scheduling](kueue-overview).
- An AKS cluster with a node pool that has the [cluster autoscaler enabled](cluster-autoscaler-overview). The examples use a pool named `scalepool` with `--min-count 1 --max-count 5`.
- The Azure CLI version 2.70 or later. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- `kubectl` connected to the cluster (`az aks get-credentials`).
- Helm 3.12 or later to install the Kueue controller.

You can find the example manifests used in this article in the [kueue-and-ray-on-aks](https://github.com/Azure/AKS/tree/master/examples/kueue-and-ray-on-aks) directory of the Azure/AKS repository. Clone the repository so you can run them:

```bash
git clone https://github.com/Azure/AKS.git
cd AKS/examples/kueue-and-ray-on-aks
```

## Install Kueue

Install the Kueue controller by using Helm:

```bash
helm install kueue oci://registry.k8s.io/kueue/charts/kueue \
  --version 0.17.1 \
  --namespace kueue-system \
  --create-namespace \
  --wait
```

Verify the controller is running:

```bash
kubectl -n kueue-system get pods
```

## Create the queue configuration

Apply the autoscale queue configuration. The file creates its own `cas-kueue-demo` namespace along with the queue objects, so you don't need a separate namespace step:

```bash
kubectl apply -f 2-kueue-queues/manifests/40-autoscale-queue.yaml
```

The ResourceFlavor targets nodes labeled `agentpool=scalepool`, which AKS applies automatically to that node pool:

```yaml
apiVersion: kueue.x-k8s.io/v1beta2
kind: ResourceFlavor
metadata:
  name: scalepool
spec:
  nodeLabels:
    agentpool: scalepool
```

Verify:

```bash
kubectl get resourceflavor scalepool
```

## Configure the provisioning gate

The same file connects the provisioning gate with three more objects:

- **ProvisioningRequestConfig**`cas-provreq-config` selects the `best-effort-atomic-scale-up.autoscaling.x-k8s.io` provisioning class, so the autoscaler adds the requested capacity as a single atomic increase.
- **AdmissionCheck**`cas-provisioning` uses the `kueue.x-k8s.io/provisioning-request` controller and points at that config.
- **ClusterQueue**`cas-cluster-queue` gates admission on `cas-provisioning` through `admissionChecksStrategy`, so every workload it admits goes through the provisioning gate first.

Verify the objects:

```bash
kubectl get admissioncheck cas-provisioning
kubectl get clusterqueue cas-cluster-queue
kubectl -n cas-kueue-demo get localqueue cas-local-queue
```

Expected output:

```output
NAME               AGE
cas-provisioning   1m

NAME                COHORT   PENDING WORKLOADS
cas-cluster-queue            0

NAME              CLUSTERQUEUE        PENDING WORKLOADS   ADMITTED WORKLOADS
cas-local-queue   cas-cluster-queue   0                   0
```

## Submit a workload

Submit a suspended Job routed through the queue. It requests three pods that can't all fit on the single starting node, which forces a scale-up:

```bash
kubectl apply -f 3-workloads/cas-batch-job/manifests/job.yaml
```

The Job carries the `kueue.x-k8s.io/queue-name: cas-local-queue` label and `suspend: true`, so Kueue takes over admission:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: kueue-cas-job
  namespace: cas-kueue-demo
  labels:
    kueue.x-k8s.io/queue-name: cas-local-queue
spec:
  parallelism: 3
  completions: 3
  suspend: true
  template:
    spec:
      nodeSelector:
        agentpool: scalepool
      containers:
        - name: worker
          image: mcr.microsoft.com/azurelinux/busybox:1.36
          command: ["sh", "-c", "echo running on $(hostname); sleep 30"]
          resources:
            requests:
              cpu: "1800m"
              memory: "256Mi"
      restartPolicy: Never
```

## Watch the provisioning flow

Kueue creates a Workload, then a ProvisioningRequest. The cluster autoscaler satisfies the request and the pool grows:

```bash
# Kueue creates a Workload and a ProvisioningRequest
kubectl -n cas-kueue-demo get workloads
kubectl -n cas-kueue-demo get provisioningrequest

# The autoscaler marks the request Provisioned and adds nodes
kubectl get nodes -l agentpool=scalepool -w

# The Job runs to completion once nodes are Ready
kubectl -n cas-kueue-demo get job kueue-cas-job -w
```

Expected end state:

```output
NAME            STATUS     COMPLETIONS   DURATION   AGE
kueue-cas-job   Complete   3/3           34s        2m
```

## Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| Job stays suspended, no `ProvisioningRequest` | Wrong queue-name label | Verify `kueue.x-k8s.io/queue-name: cas-local-queue` matches the `LocalQueue` name. |
| ProvisioningRequest created but `status.conditions` empty | Autoscaler hasn't processed the request yet | Confirm the node pool has the cluster autoscaler enabled, then recheck after a minute |
| `Provisioned=False` with reason `CapacityIsNotFound` | The pool can't reach the requested size, usually because existing workloads occupy it or the request exceeds `--max-count` | Free capacity or raise `--max-count`. The autoscaler keeps retrying, and the job stays suspended rather than partially scheduling. |
| Pods Pending after admission | Node label mismatch | Confirm `scalepool` nodes carry the `agentpool=scalepool` label with `kubectl get nodes --show-labels` |
| Kueue controller not running | Helm release issue | Check with `kubectl -n kueue-system logs deploy/kueue-controller-manager` |

For the full manifests, see the [kueue-and-ray-on-aks directory](https://github.com/Azure/AKS/tree/master/examples/kueue-and-ray-on-aks) in the Azure/AKS repository.

## Clean up resources

Remove the workload and queue configuration:

```bash
kubectl delete -f 3-workloads/cas-batch-job/manifests/job.yaml
kubectl delete -f 2-kueue-queues/manifests/40-autoscale-queue.yaml
```