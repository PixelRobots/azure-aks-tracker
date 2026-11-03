---
layout: Conceptual
title: Install the managed Kueue extension on Azure Kubernetes Service (AKS) (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/install-the-managed-kueue-extension-on-aks
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
description: Install and verify managed Kueue on AKS.
ms.topic: how-to
ms.date: 2026-10-22T00:00:00.0000000Z
author: colinmixon
ms.author: colinmixon
ms.custom: devx-track-azurecli
ai-usage: ai-assisted
locale: en-us
document_id: 811b411d-f1fe-b080-ee04-3eb4804314c3
document_version_independent_id: 8b0d89c1-72f0-8c72-c075-6f60eaa9dcd1
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/install-the-managed-kueue-extension-on-aks.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/install-the-managed-kueue-extension-on-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/install-the-managed-kueue-extension-on-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 3c38f872-f3c9-229f-befe-f7465cf17b1c
---

# Install the managed Kueue extension on Azure Kubernetes Service (AKS) (preview) - Azure Kubernetes Service | Microsoft Learn

The managed Kueue extension installs and manages the supported Kueue controller on Azure Kubernetes Service (AKS). It also generates ResourceFlavors for eligible user nodes and provides default workload priority classes that you can reference from your own queues and workloads.

This article shows you how to install, verify, update, and uninstall the extension by using the Azure CLI. For concepts, see [Managed Kueue extension overview](managed-kueue-extension-overview). To configure queues and try workload admission and preemption, see [Schedule and deploy batch jobs with the managed Kueue extension](schedule-and-deploy-batch-jobs-with-managed-kueue-extension-on-aks).

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Prerequisites

- An AKS cluster that runs Kubernetes 1.34 or later. To create one, see [Create an AKS cluster using the Azure CLI](learn/quick-kubernetes-deploy-cli).
- A current version of the [Azure CLI](/en-us/cli/azure/install-azure-cli) and the `k8s-extension` CLI extension version 1.9.3 or later.
- [kubectl](https://kubernetes.io/docs/tasks/tools/) compatible with your cluster version.
- Permissions to manage cluster extensions, retrieve cluster credentials, and read the Kubernetes resources used to verify the installation.

## Limitations

- The managed extension currently supports cluster autoscaler integration. Node auto-provisioning and AKS Automatic aren't supported by this preview.
- Uninstall an existing self-hosted Kueue installation before installing the managed extension, or use a clean target cluster. Kueue is a cluster singleton; installation rejects an unmanaged controller even in another namespace. Preserve configuration and review active and queued workloads before planning an uninstall.
- Supported workload integrations include Kubernetes Job, Pod, Deployment, StatefulSet, JobSet, Ray, MPIJob, and Trainer v2 TrainJob.
- Legacy Kubeflow v1 jobs, AppWrapper, and LeaderWorkerSet aren't supported integrations in this managed preview.

## Prepare your environment

Set your subscription and cluster details:

```bash
SUBSCRIPTION_ID="<subscription-id>"
RESOURCE_GROUP="<resource-group>"
CLUSTER_NAME="<aks-cluster-name>"
EXTENSION_NAME="aks-kueue"
RELEASE_TRAIN="preview"

az login
az account set --subscription "$SUBSCRIPTION_ID"
az aks get-credentials --resource-group "$RESOURCE_GROUP" --name "$CLUSTER_NAME"
az extension add --name k8s-extension --upgrade
az extension show --name k8s-extension --query version --output tsv
```

Register the resource providers if they aren't already registered:

```bash
az provider register --namespace Microsoft.ContainerService --wait
az provider register --namespace Microsoft.KubernetesConfiguration --wait
```

## Uninstall the existing self-hosted Kueue

Skip this section if your cluster doesn't have a self-hosted Kueue controller. If it does, plan its uninstall before you install the managed extension.

Warning

Uninstalling self-hosted Kueue can delete its CRDs and all custom resources of those types. Before you proceed, save important configuration and workload manifests in your own source of truth. Preserve ClusterQueues, LocalQueues, ResourceFlavors, workload priority classes, and admission policies that you need to recreate. Review running and queued workloads, preserve application data, and pause GitOps reconciliation so that it doesn't reinstall the old controller.

Follow the supported uninstall procedure for the version and installation method that you used. For a Helm installation, first identify its release and namespace:

```bash
helm list --all-namespaces
```

After you verify the release identity and preserve the required information, uninstall that self-hosted release:

```bash
OSS_KUEUE_RELEASE="<self-hosted-release-name>"
OSS_KUEUE_NAMESPACE="<self-hosted-release-namespace>"

helm uninstall "$OSS_KUEUE_RELEASE" --namespace "$OSS_KUEUE_NAMESPACE"
```

For a manifest-based installation, follow the [upstream uninstall instructions](https://kueue.sigs.k8s.io/docs/installation/). Confirm that the old controller is no longer running before continuing. Don't transfer ownership of a self-hosted controller or its CRDs to the managed extension.

After you install the managed extension, restore only your customer-owned queue and workload configuration. Reference the new managed resources rather than restoring old controller manifests or creating replacements with reserved AKS names.

## Install the managed Kueue extension

Check which extension versions are available for your cluster and release train:

```bash
az k8s-extension extension-types list-versions-by-cluster \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --cluster-type managedClusters \
  --extension-type microsoft.kueue \
  --release-train "$RELEASE_TRAIN" \
  --output table
```

If no compatible version is returned, check the prerequisites and package availability before continuing.

Install the extension into the required `kueue-system` namespace. This example enables compatible automatic upgrades and doesn't specify an exact version:

```bash
az k8s-extension create \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --cluster-type managedClusters \
  --name "$EXTENSION_NAME" \
  --extension-type microsoft.kueue \
  --scope cluster \
  --release-namespace kueue-system \
  --release-train "$RELEASE_TRAIN" \
  --auto-upgrade-mode compatible
```

Don't install another Kueue controller or use direct Helm operations to configure the managed release.

## Verify the extension installation

Use the same extension resource name that you used during installation:

```bash
az k8s-extension show \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --cluster-type managedClusters \
  --name "$EXTENSION_NAME" \
  --query '{name:name,version:currentVersion,provisioningState:provisioningState,extensionState:extensionState,statuses:statuses}' \
  --output json
```

Confirm that provisioning succeeds and the extension reports availability. Then check both controller deployments and the managed Kueue APIs:

```bash
kubectl rollout status deployment/kueue-controller-manager --namespace kueue-system --timeout=5m
kubectl rollout status deployment/kueue-extension --namespace kueue-system --timeout=5m
kubectl wait --for=condition=Established \
  crd/clusterqueues.kueue.x-k8s.io \
  crd/localqueues.kueue.x-k8s.io \
  crd/resourceflavors.kueue.x-k8s.io \
  crd/workloadpriorityclasses.kueue.x-k8s.io \
  crd/workloads.kueue.x-k8s.io \
  --timeout=2m
```

If these checks fail, inspect extension status, controller events, and logs before making further changes. Don't replace managed CRDs with definitions from an upstream release. See [Troubleshoot cluster extension deployment errors](/en-us/troubleshoot/azure/azure-kubernetes/extensions/cluster-extension-deployment-errors).

## Update the managed Kueue extension

Use the version-listing command in Install the managed Kueue extension to check which versions are available for your cluster.

In the same shell session, or after you redefine the variables in Prepare your environment, enable compatible automatic upgrades for an existing extension:

```bash
az k8s-extension update \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --cluster-type managedClusters \
  --name "$EXTENSION_NAME" \
  --release-train "$RELEASE_TRAIN" \
  --auto-upgrade-mode compatible \
  --yes
```

Don't combine an exact `--version` with automatic upgrades. Repeat the verification checks after an update and confirm the installed version.

## Uninstall the managed Kueue extension

Uninstall the extension only when you intend to stop using Kueue, not as a controller-health workaround.

Warning

Uninstalling managed Kueue deletes Kueue custom resources across the cluster, including customer-created LocalQueues, ClusterQueues, ResourceFlavors, Workloads, and other queue configuration. Cleanup also clears finalizers that block deletion. Preserve customer-owned configuration in Git or export it before uninstalling. Pause GitOps reconciliation during the planned uninstall.

Kubernetes Jobs and their pods aren't deleted when you uninstall Kueue. Running Jobs continue without Kueue management, while queued Jobs remain suspended. A later installation creates new Workloads for surviving Jobs that still have a queue label; it doesn't restore the deleted queue policy or admission state.

Use the actual extension resource name and the cluster variables from Prepare your environment. If you didn't install it in this session, discover its name with `az k8s-extension list` before deleting it:

```bash
az k8s-extension delete \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --cluster-type managedClusters \
  --name "$EXTENSION_NAME" \
  --yes
```

Before submitting queued Jobs after a new installation, restore and verify your customer-owned queue configuration. Don't delete CRDs or manually clear finalizers to bypass a failed uninstall.

For generated resource flavors, node-pool setup, queue configuration, and the low- and high-priority example, continue to [Schedule and deploy batch jobs](schedule-and-deploy-batch-jobs-with-managed-kueue-extension-on-aks#use-workload-priority-and-preemption).