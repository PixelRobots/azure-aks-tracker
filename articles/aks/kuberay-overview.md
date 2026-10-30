---
layout: Conceptual
title: Install the managed KubeRay extension on Azure Kubernetes Service (AKS) (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/kuberay-overview
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
description: Learn how to install, verify, update, and remove the managed KubeRay extension on Azure Kubernetes Service (AKS).
ms.topic: how-to
ms.date: 2026-10-27T00:00:00.0000000Z
author: alyssa1303
ms.author: alyssavu
ms.custom: devx-track-azurecli
ai-usage: ai-generated
locale: en-us
document_id: 2bae8447-c3f4-d52a-3fc8-fbdc1b605a37
document_version_independent_id: 15744e7d-f19f-23e3-f56d-a8d8b804705a
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/kuberay-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/kuberay-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/kuberay-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: bcd560b9-03e5-25e4-5cc8-92463f21dd71
---

# Install the managed KubeRay extension on Azure Kubernetes Service (AKS) (preview) - Azure Kubernetes Service | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

The managed KubeRay extension for Azure Kubernetes Service (AKS) is in preview. It installs and manages the [KubeRay](https://docs.ray.io/en/latest/cluster/kubernetes/getting-started.html) operator and the Ray custom resource definitions (CRDs) on your cluster: `RayCluster`, `RayJob`, `RayCronJob`, and `RayService`.

This article shows you how to install, verify, update, and remove the extension by using the Azure CLI. You also deploy a sample Ray workload to confirm that the operator manages Ray resources as expected.

## Prerequisites

- An Azure subscription and an AKS cluster that runs Kubernetes 1.34 or later and uses [managed identity](managed-identity-overview) in an [AKS-supported Azure public cloud region](quotas-skus-regions#region-availability). If you don't have a cluster, see [Create an AKS cluster using the Azure CLI](learn/quick-kubernetes-deploy-cli).
- A current version of the [Azure CLI](/en-us/cli/azure/install-azure-cli).
- The `k8s-extension` Azure CLI extension version 1.8.0 or later.
- [kubectl](https://kubernetes.io/docs/tasks/tools/) compatible with your cluster's Kubernetes version.
- Permissions to register Azure resource providers, manage cluster extensions, retrieve cluster credentials, and inspect Kubernetes resources.

## Limitations

- **Existing open-source software (OSS) KubeRay installations:**Uninstall any existing self-hosted KubeRay operator before you install the managed KubeRay extension (`microsoft.kuberay`). A rejected installation can still change Ray CRD schemas and ownership, and deleting the failed extension doesn't undo those changes. Preserve CRDs and workload resources. If an installation already failed, follow the [recovery guidance](/en-us/troubleshoot/azure/azure-kubernetes/extensions/troubleshoot-kuberay-extension-errors#installation-detects-an-existing-self-hosted-kuberay-operator) before retrying.

## Prepare your environment

The following examples use Bash. Set your subscription and existing cluster details, and then sign in:

```bash
SUBSCRIPTION_ID="<subscription-id>"
RESOURCE_GROUP="<existing-resource-group>"
CLUSTER_NAME="<existing-aks-cluster>"
EXTENSION_NAME="kuberay"
RELEASE_TRAIN="preview"

az login
az account set --subscription "$SUBSCRIPTION_ID"
```

Check the cluster's Kubernetes version. Confirm that the returned version is 1.34 or later before you continue:

```bash
az aks show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CLUSTER_NAME" \
  --query kubernetesVersion \
  --output tsv
```

Connect to the cluster:

```bash
az aks get-credentials \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CLUSTER_NAME"
```

Install or update the CLI extension and register the required resource providers:

```bash
az extension add --name k8s-extension --upgrade

az provider register --namespace Microsoft.ContainerService --wait
az provider register --namespace Microsoft.KubernetesConfiguration --wait
```

Check the installed CLI extension version:

```bash
az extension show --name k8s-extension --query version --output tsv
```

Installing the CLI extension provides management commands; it doesn't install KubeRay on your cluster.

### Uninstall an existing OSS KubeRay operator

Skip this step if you don't have a self-hosted operator. Otherwise, back up workload data and manifests, suspend `RayCronJob` schedules, and wait for running jobs to finish before removing the operator.

For a Helm installation, find the release name and namespace:

```bash
helm list --all-namespaces
```

Remove only the operator release and confirm that its deployment is gone:

```bash
OSS_RELEASE_NAME="<existing-kuberay-release-name>"
OSS_RELEASE_NAMESPACE="<existing-kuberay-release-namespace>"

helm uninstall "$OSS_RELEASE_NAME" --namespace "$OSS_RELEASE_NAMESPACE"
kubectl get deployments --namespace "$OSS_RELEASE_NAMESPACE"
```

Check that the retained namespace shows `Active` and each retained `*.ray.io` CRD shows `True` in the `ESTABLISHED` column:

```bash
kubectl get namespace "$OSS_RELEASE_NAMESPACE"
kubectl get crds \
  --output='custom-columns=NAME:.metadata.name,ESTABLISHED:.status.conditions[?(@.type=="Established")].status'
```

If the namespace is terminating or a Ray CRD isn't established, resolve the issue before enabling the extension.

For other installation methods, use their operator removal procedure. Preserve Ray CRDs and workload resources; don't delete their namespaces or CRDs.

## Install the managed KubeRay extension

List the extension versions available for your cluster and the `preview` release train:

```bash
az k8s-extension extension-types list-versions-by-cluster \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --cluster-type managedClusters \
  --extension-type microsoft.kuberay \
  --release-train "$RELEASE_TRAIN" \
  --output table
```

Confirm that a compatible version is returned. If none is returned, see [Troubleshoot extension version discovery](/en-us/troubleshoot/azure/azure-kubernetes/extensions/troubleshoot-kuberay-extension-errors#installation-or-update-cant-resolve-an-extension-version).

Create the extension with automatic upgrades enabled. The command uses the following values:

- `--extension-type microsoft.kuberay` installs the managed KubeRay extension.
- `--scope cluster` installs the extension for the whole cluster.
- `--release-namespace kuberay-system` sets the namespace for the `kuberay-operator` deployment.
- `--release-train "$RELEASE_TRAIN"` selects the `preview` release train.
- `--auto-upgrade-minor-version true` enables automatic upgrades. Don't specify `--version` with this setting.

```bash
az k8s-extension create \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --cluster-type managedClusters \
  --name "$EXTENSION_NAME" \
  --extension-type microsoft.kuberay \
  --scope cluster \
  --release-namespace kuberay-system \
  --release-train "$RELEASE_TRAIN" \
  --auto-upgrade-minor-version true
```

## Verify the extension installation

Inspect the installed version and provisioning state:

```bash
az k8s-extension show \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --cluster-type managedClusters \
  --name "$EXTENSION_NAME" \
  --query "{name:name,version:currentVersion,provisioningState:provisioningState,extensionState:extensionState}" \
  --output table
```

Installation can take up to 15 minutes. Wait until the command output shows the following values, then verify that the operator deployment is available and the Ray CRDs are installed:

- `provisioningState` is `Succeeded`.
- `extensionState` is `Available` or `Ready`.

```bash
kubectl wait \
  --for=condition=Available \
  deployment/kuberay-operator \
  --namespace kuberay-system \
  --timeout=5m

kubectl get crds \
  rayclusters.ray.io \
  raycronjobs.ray.io \
  rayjobs.ray.io \
  rayservices.ray.io \
  --output name
```

If provisioning or readiness checks fail, see [Troubleshoot the managed KubeRay extension](/en-us/troubleshoot/azure/azure-kubernetes/extensions/troubleshoot-kuberay-extension-errors).

## Run a sample Ray workload

Deploy a CPU-only `RayCluster` and submit a `RayJob` to confirm that the KubeRay operator can reconcile Ray resources and run distributed tasks. The sample uses one head pod and one worker pod.

Set the sample resource names and Ray image:

```bash
RAY_NAMESPACE="kuberay-sample"
RAY_CLUSTER_NAME="sample-raycluster"
RAY_JOB_NAME="sample-rayjob"
RAY_VERSION="2.58.0"
RAY_IMAGE="mcr.microsoft.com/aks/ai-runtime/ray@sha256:e9a329eef15e5a13d50c3186c2b8036cd3728c6e218da860de23e8494b99ddd3"
```

Create a namespace and deploy the `RayCluster`:

```bash
kubectl create namespace "$RAY_NAMESPACE"

kubectl apply -f - <<YAML
apiVersion: ray.io/v1
kind: RayCluster
metadata:
  name: ${RAY_CLUSTER_NAME}
  namespace: ${RAY_NAMESPACE}
spec:
  rayVersion: "${RAY_VERSION}"
  headGroupSpec:
    rayStartParams:
      num-cpus: "0"
      dashboard-host: "0.0.0.0"
    template:
      spec:
        containers:
        - name: ray-head
          image: ${RAY_IMAGE}
          resources:
            requests:
              cpu: 500m
              memory: 2Gi
            limits:
              cpu: "1"
              memory: 4Gi
  workerGroupSpecs:
  - groupName: cpu-workers
    replicas: 1
    minReplicas: 1
    maxReplicas: 1
    rayStartParams:
      num-cpus: "1"
    template:
      spec:
        containers:
        - name: ray-worker
          image: ${RAY_IMAGE}
          resources:
            requests:
              cpu: 500m
              memory: 1Gi
            limits:
              cpu: "1"
              memory: 2Gi
YAML
```

Wait for the `RayCluster` to report `ready`, and then confirm that the head and worker pods are running:

```bash
kubectl wait \
  --for=jsonpath='{.status.state}'=ready \
  raycluster/"$RAY_CLUSTER_NAME" \
  --namespace "$RAY_NAMESPACE" \
  --timeout=10m

kubectl get raycluster,pods --namespace "$RAY_NAMESPACE"
```

Submit an HTTP-mode `RayJob` to the existing cluster. The job runs four remote tasks on the worker and prints a success marker after validating their results:

```bash
kubectl apply -f - <<YAML
apiVersion: ray.io/v1
kind: RayJob
metadata:
  name: ${RAY_JOB_NAME}
  namespace: ${RAY_NAMESPACE}
spec:
  jobId: ${RAY_JOB_NAME}
  submissionMode: HTTPMode
  clusterSelector:
    ray.io/cluster: ${RAY_CLUSTER_NAME}
  entrypoint: >-
    python3 -c "import ray; ray.init(address='auto'); square=ray.remote(lambda x: x*x);
    values=ray.get([square.remote(i) for i in range(4)]);
    assert values == [0, 1, 4, 9], values;
    print('KUBERAY_SAMPLE_OK', values, flush=True)"
  shutdownAfterJobFinishes: false
YAML
```

Wait for the job to succeed:

```bash
kubectl wait \
  --for=jsonpath='{.status.jobStatus}'=SUCCEEDED \
  rayjob/"$RAY_JOB_NAME" \
  --namespace "$RAY_NAMESPACE" \
  --timeout=10m
```

Read the Ray driver log from the head pod:

```bash
HEAD_POD="$(kubectl get pods \
  --namespace "$RAY_NAMESPACE" \
  --selector="ray.io/cluster=$RAY_CLUSTER_NAME,ray.io/node-type=head" \
  --output jsonpath='{.items[0].metadata.name}')"

kubectl exec \
  --namespace "$RAY_NAMESPACE" \
  "$HEAD_POD" \
  --container ray-head \
  -- sh -c 'grep -h "KUBERAY_SAMPLE_OK" /tmp/ray/session_latest/logs/job-driver-*.log'
```

The expected output is:

```output
KUBERAY_SAMPLE_OK [0, 1, 4, 9]
```

This output confirms that the operator created the Ray cluster, submitted the job, and ran tasks on the worker. Delete the sample resources when you're finished:

```bash
kubectl delete namespace "$RAY_NAMESPACE"
```

## Update the managed KubeRay extension

Use the `az k8s-extension extension-types list-versions-by-cluster` command in Install the managed KubeRay extension to check which versions are available for your cluster.

In the same shell session, or after you redefine `RESOURCE_GROUP`, `CLUSTER_NAME`, `EXTENSION_NAME`, and `RELEASE_TRAIN` as described in Prepare your environment, enable automatic upgrades for an existing extension:

```bash
az k8s-extension update \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --cluster-type managedClusters \
  --name "$EXTENSION_NAME" \
  --release-train "$RELEASE_TRAIN" \
  --auto-upgrade-minor-version true \
  --yes
```

Don't specify `--version` when automatic upgrades are enabled. After the update, repeat the verification steps and confirm the installed version.

## Uninstall the managed KubeRay extension

Before you remove the managed KubeRay extension, ensure `RESOURCE_GROUP`, `CLUSTER_NAME`, and `EXTENSION_NAME` are still set as described in Prepare your environment. Then review existing Ray resources:

```bash
kubectl get rayclusters,raycronjobs,rayjobs,rayservices --all-namespaces
```

- Suspend scheduled jobs, let running jobs finish, and preserve required data and manifests.
- If you want to delete Ray workloads, delete them while the operator is still running so it can complete cleanup.

Remove the extension instance:

```bash
az k8s-extension delete \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --cluster-type managedClusters \
  --name "$EXTENSION_NAME" \
  --yes
```

Important

Removing the extension leaves Ray CRDs and workloads in place, but the operator no longer manages them. Don't delete CRDs as a cleanup shortcut, because doing so also deletes their custom resources.

Confirm that the `kuberay` extension no longer appears in the extension list and that the `kuberay-operator` deployment is removed:

```bash
az k8s-extension list \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --cluster-type managedClusters \
  --output table

kubectl get deployments --namespace kuberay-system
```