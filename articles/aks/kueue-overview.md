---
layout: Conceptual
title: Install Kueue on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/kueue-overview
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
zone_pivot_group_filename: zone-pivots/azure-aks/zone-pivot-groups.json
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn how to install and configure Kueue on Azure Kubernetes Service (AKS) using the AKS managed Kueue extension or the open-source Kueue Helm chart.
ms.topic: how-to
ms.date: 2025-09-26T00:00:00.0000000Z
author: colinmixonn
ms.author: colinmixon
zone_pivot_groups: helm-or-extension
locale: en-us
document_id: b9b83cb2-fb48-423b-6238-df3deac1d479
document_version_independent_id: ecc29b48-21da-2236-2b75-108194e17fa0
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/kueue-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/kueue-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/kueue-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/86a4b315-a9f1-4577-b985-6fb0e0e67420
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/96ac410d-d052-4707-8007-df31dd0fe041
platformId: 6cb10746-ab2f-dbb5-fa0d-0cac1cde1d10
---

# Install Kueue on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Kueue provides Kubernetes-native job queueing and resource admission for batch and AI workloads running on Azure Kubernetes Service (AKS). This article describes two ways to install Kueue on AKS:

- AKS managed Kueue extension (preview): Use the Azure-managed extension experience to deploy Kueue on your AKS cluster.
- Open-source Kueue with Helm: Install and configure Kueue directly from the upstream Kueue Helm chart.

After installation, use Kueue APIs such as ClusterQueue, LocalQueue, and ResourceFlavor to control how workloads are admitted to cluster resources.

## What is Kueue?

[Kueue](https://kueue.sigs.k8s.io/docs/overview/) is an open-source Kubernetes-native job queueing project designed to manage batch workloads and ensure efficient, fair, and policy-driven scheduling in Kubernetes clusters. Kueue integrates with the [Kubernetes scheduling](https://github.com/kubernetes/community/blob/master/sig-scheduling/README.md) ecosystem to coordinate resource allocation, prioritization, and capacity control for workloads. Kueue controls whether workloads are admitted based on configured resource quotas and policies. After a workload is admitted, the Kubernetes scheduler places the workload's pods onto nodes.

Kueue is useful for workloads such as:

- AI and machine learning training
- GPU-intensive jobs
- Data processing
- Security vulnerability scans
- Media encoding and video transcoding
- Report generation and financial analysis
- Other batch workloads that can wait for sufficient resources to become available

Model these workloads by using a Kubernetes Job, CronJob, or custom resource definition (CRD) like [RayJob](https://docs.ray.io/en/latest/cluster/kubernetes/getting-started/rayjob-quick-start.html) or [Kubeflow MPIJob](https://www.kubeflow.org/docs/components/trainer/legacy-v1/user-guides/mpi/) and admit them according to their `ClusterQueue` and `LocalQueue`

## Understand Kueue queues

Before you submit workloads with Kueue, configure queues that control workload admission.

Kueue uses two primary queue resources:

- `ClusterQueue` defines cluster-wide resource quotas for shared resource pools (such as CPU, memory, GPU quotas) and policies that determine which workloads can be admitted.
- `LocalQueue` provides a namespace-scoped queue where users submit workloads and references a ClusterQueue.

The following flow shows how Kueue evaluates a workload before Kubernetes schedules its pods: **Workload (Pod, Job, etc.) → LocalQueue → ClusterQueue → workload admission → Kubernetes scheduling**

A `LocalQueue` identifies the `ClusterQueue` that should evaluate the workload. The `ClusterQueue` determines whether sufficient quota is available for the workload to be admitted. Platform administrators typically configure cluster-level resources and policies, while workload owners submit jobs through a `LocalQueue`.

Note

To submit a workload to Kueue, add the `kueue.x-k8s.io/queue-name: <local-queue-name>` label to the workload. This label associates the workload with a LocalQueue, which routes it to the appropriate ClusterQueue for admission.

Important

Open-source software is mentioned throughout AKS documentation and samples. Software that you deploy is excluded from AKS service-level agreements, limited warranty, and Azure support. As you use open-source technology alongside AKS, consult the support options available from the respective communities and project maintainers to develop a plan.

Microsoft takes responsibility for building the open-source packages that we deploy on AKS. That responsibility includes having complete ownership of the build, scan, sign, validate, and hotfix process, along with control over the binaries in container images. For more information, see [Vulnerability management for AKS](concepts-vulnerability-management#aks-container-images) and [AKS support coverage](support-policies#aks-support-coverage).

## When to use Kueue

Batch and AI workloads can have scheduling and resource-management requirements that differ from long-running Kubernetes services. Batch workload administrators (including platform or cluster administrators and DevOps engineers) and batch users (data scientists, developers, and ML engineers) can benefit from deploying workloads with Kueue on AKS.

A batch admin focuses on configuring, managing, and securing the platform-level infrastructure to support batch workloads, and have the following responsibilities:

- Provision and manage AKS node pools.
- Define resource quotas, ClusterQueues, and policies for workload isolation.
- Tune autoscaling and cost-efficiency (such as the Cluster Autoscaler or Kueue quotas).
- Monitor cluster and queue health.
- Create and maintain templates and reusable workflows.

A batch user runs compute-intensive or parallel jobs using the platform-level infrastructure configured by a batch admin, and typically:

- Submit batch jobs (such as Job, Workload, or custom controller CRDs) and monitor job status and outputs
- Select appropriate queue or resource flavor for jobs (based on guidance from batch admins)
- Optimize job specs for resource and performance needs

## Prerequisites

- An existing AKS cluster. If you don't have a cluster, create one using the [Azure CLI](learn/quick-kubernetes-deploy-cli), [Azure PowerShell](learn/quick-kubernetes-deploy-powershell), or the [Azure portal](learn/quick-kubernetes-deploy-portal).
- Azure CLI installed on your local machine. To install or upgrade, see [Install the Azure CLI](/en-us/cli/azure/install-azure-cli).
- [Helm version 3 or above](https://helm.sh/docs/intro/install/) installed.

Additional prerequisites depend on the installation method you choose.

## Choose how to install Kueue

AKS supports two installation approaches for Kueue. Choose the option that best matches how you want to install and configure Kueue on your cluster. The Kueue Kubernetes APIs and queueing concepts remain the same regardless of the installation method. The primary difference is how the Kueue components are installed and configured.

| Installation Path | Description |
| --- | --- |
| AKS managed Kueue extension (preview) | You want to deploy Kueue through the AKS cluster extension experience and use the Kueue version and configuration supported by the extension. |
| Open-source Kueue with Helm | You want to install Kueue directly from the upstream project and control the Kueue version, feature gates, integrations, and Helm configuration. |

::: zone pivot="extension"

## Install and configure managed Kueue extension on Azure Kubernetes Service (preview)

The AKS managed Kueue extension provides an Azure-native installation path for deploying Kueue on an AKS cluster. Use this installation method if you want to deploy Kueue through the AKS cluster extension experience instead of installing the upstream Helm chart directly.

### Managed extension prerequisites

Before you begin, make sure you have the following tools:

- AKS version 1.34 or later
- Azure CLI version 2.56 or later
- kubectl version 1.33–1.35
- Azure CLI k8s-extension version 1.9.3 or later

### Limitations

- The AKS managed Kueue extension currently only supports Cluster Autoscaler with support for node auto-provisioning planned.
- AKS Automatic isn't supported yet. Support is planned for a future release.
- You must remove existing OSS Kueue installations first. Managed Kueue is a cluster singleton and installation rejects an unmanaged Kueue controller, even in another namespace.
- Supported workload integrations: Kubernetes Job, Pod, Deployment, StatefulSet, JobSet, Ray, MPIJob, and Trainer v2 TrainJob.
- Unsupported workload integrations: Legacy Kubeflow v1 jobs, AppWrapper, and LeaderWorkerSet.

### Install the managed Kueue extension

Set environment variables for your Azure subscription, resource group, and AKS cluster:

```bash
RESOURCE_GROUP="<resource-group-name>"
CLUSTER_NAME="<aks-cluster-name>"
```

Install the Kueue cluster extension:

```bash
az k8s-extension create \
--resource-group "$RESOURCE_GROUP" \
--cluster-name "$CLUSTER_NAME" \
--cluster-type managedClusters \
--name aks-kueue \
--extension-type microsoft.kueue \
--release-train preview
```

### Verify the extension installation

Get the provisioning state and installed version of the Kueue extension. Verify that `provisioningState` is `Succeeded` and `extensionState` is `Available`. Then continue to Confirm deployment status.

```bash
az k8s-extension show \
--resource-group "$RESOURCE_GROUP" \
--cluster-name "$CLUSTER_NAME" \
--cluster-type managedClusters \
--name kueue \
--output json
```

### Uninstall the managed Kueue extension

Uninstalling Managed Kueue deletes all Kueue custom resources in the cluster, including customer-created LocalQueues, ClusterQueues, ResourceFlavors, and other Kueue configuration. It also clears finalizers that block deletion. Keep customer-owned configuration in Git or export it before uninstalling. Reapply it after reinstalling Kueue and before admitting queued Jobs. If you use GitOps, pause reconciliation before uninstalling and resume it after Kueue is reinstalled.

Kueue-managed Kubernetes Jobs and their Pods aren't deleted:

- Running Jobs and Pods continue without Kueue management.
- Queued Jobs remain suspended and don't create Pods.
- After Kueue is reinstalled, it creates new Workloads for surviving Jobs that still have a queue label.

If you want to remove managed Kueue without deleting the AKS cluster, delete the extension:

```bash
az k8s-extension delete \
--resource-group "$RESOURCE_GROUP" \
--cluster-name "$CLUSTER_NAME" \
--cluster-type managedClusters \
--name kueue \
--yes
```

::: zone-end

::: zone pivot="helm"

## Install Kueue with Helm

### Helm prerequisites

Before you begin, make sure you have the following tools:

- Helm v3.0.0 or later
- Permissions to create and delete: resource groups, AKS clusters, AKS node pools, and cluster extensions

### Configure optional Kueue features

While most features and scheduling policies that you might require are enabled by default, some aren't like `TopologyAwareScheduling`. If needed, reconfigure your Kueue installation by changing the default [Feature Gates](https://kueue.sigs.k8s.io/docs/installation/#feature-gates-for-alpha-and-beta-features) or by configuring [Kueue paramater values](https://github.com/kubernetes-sigs/kueue/blob/main/charts/kueue/README.md#configuration) in the `values.yaml` file of the Helm chart.

Kueue supports multiple workload [Frameworks](https://kueue.sigs.k8s.io/docs/tasks/run/) that you need to explicitly enable to use Kueue’s scheduling and resource management capabilities when running [MPI Operator](https://www.kubeflow.org/docs/components/training/mpi/) MPIJobs, [KubeRay's](https://github.com/ray-project/kuberay)[RayJob](https://docs.ray.io/en/latest/cluster/kubernetes/getting-started/rayjob-quick-start.html) and more.

The following example enables:

- `LocalQueueMetrics` provides detailed Prometheus metrics specific to the state and activity of LocalQueues, enabling fine-grained monitoring of workload admission, quota reservation, and resource utilization.
- `TopologyAwareScheduling` allows scheduling of pods based on the topology of nodes in a pool or cluster to improve available bandwidth between the pods.
- Integrations for batch and AI workload frameworks including Kubeflow, Ray, and [JobSet](https://jobset.sigs.k8s.io/docs/concepts/).

1. Create and save a `values.yaml` file to optionally customize your Kueue configuration.

    ```bash
    cat <<EOF > values.yaml
    controllerManager:
      featureGates:
        - name: TopologyAwareScheduling
          enabled: true
        - name: LocalQueueMetrics
          enabled: true
      managerConfig:
        controllerManagerConfigYaml: |
          apiVersion: config.kueue.x-k8s.io/v1beta1
          kind: Configuration
          integrations:
            frameworks:
              - batch/job
              - kubeflow.org/mpijob
              - ray.io/rayjob
              - ray.io/raycluster
              - jobset.x-k8s.io/jobset
              - kubeflow.org/paddlejob
              - kubeflow.org/pytorchjob
              - kubeflow.org/tfjob
              - kubeflow.org/xgboostjob
              - kubeflow.org/jaxjob
    EOF
    ```

Note

Update version as needed: [kueue/releases](https://github.com/kubernetes-sigs/kueue/releases)

1. Install the latest version of the Kueue controller and CRDs in a dedicated namespace using the `helm install` command.

    ```bash
    LATEST_VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/kueue/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/^v//')
    
    helm install kueue oci://registry.k8s.io/kueue/charts/kueue \
     --version=${LATEST_VERSION} \
    --create-namespace --namespace=kueue-system \
    --values values.yaml
    ```
2. Confirm the deployment status using the `helm list` command.

    ```bash
    helm list --namespace kueue-system
    ```

    Your output should include a `Status` of `deployed` and look like:

    ```output
    Pulled: registry.k8s.io/kueue/charts/kueue:0.13.4
    Digest: -
    NAME: kueue
    LAST DEPLOYED: -
    NAMESPACE: kueue-system
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    ```

### Uninstall Kueue

If you no longer need the Kueue controller manager or Kueue custom resources in your AKS cluster, uninstall the Helm repository and remove the dedicated namespace and resources.

1. Uninstall the Kueue Helm repository by using the `helm uninstall` command.

    ```bash
    helm uninstall kueue --namespace kueue-system  
    ```
2. Remove the dedicated namespace and resources by using the `kubectl delete` command.

    ```bash
    kubectl delete namespace kueue-system  
    ```

::: zone-end

## Confirm deployment status

Regardless of which installation method you use, verify that the Kueue components are running before configuring queues or submitting workloads.

1. Verify that controller pods are running properly.

    ```bash
    kubectl get deploy -n kueue-system
    ```

    Your output should look similar to the following example output:

    ```output
    NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
    kueue-controller-manager       1/1     1            1           7s
    ```

For the AKS managed Kueue extension, the output should include both `kueue-controller-manager` and `kueue-extension`. Verify that both deployments show `READY` and `AVAILABLE` as `1`.

1. Confirm the installation of Kueue resources on your AKS cluster:

    ```bash
    kubectl get crds | grep kueue
    ```

    Your output should include the following Kueue CRDs:

    ```output
    admissionchecks.kueue.x-k8s.io                   2025-09-11T18:20:48Z
    clusterqueues.kueue.x-k8s.io                     2025-09-11T18:20:48Z
    cohorts.kueue.x-k8s.io                           2025-09-11T18:20:48Z
    localqueues.kueue.x-k8s.io                       2025-09-11T18:20:48Z
    multikueueclusters.kueue.x-k8s.io                2025-09-11T18:20:48Z
    multikueueconfigs.kueue.x-k8s.io                 2025-09-11T18:20:48Z
    provisioningrequestconfigs.kueue.x-k8s.io        2025-09-11T18:20:48Z
    resourceflavors.kueue.x-k8s.io                   2025-09-11T18:20:48Z
    topologies.kueue.x-k8s.io                        2025-09-11T18:20:48Z
    workloadpriorityclasses.kueue.x-k8s.io           2025-09-11T18:20:48Z
    workloads.kueue.x-k8s.io                         2025-09-11T18:20:48Z
    ```

The exact set of CRDs can vary depending on the installed Kueue version.

After Kueue is running, configure queues, resource quotas, and workload admission policies before submitting workloads.