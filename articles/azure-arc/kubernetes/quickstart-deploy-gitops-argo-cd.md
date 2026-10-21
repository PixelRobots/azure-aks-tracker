---
layout: Conceptual
title: 'Quickstart: Deploy an application by using GitOps with Argo CD - Azure Arc | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/quickstart-deploy-gitops-argo-cd
breadcrumb_path: ../../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/146/azure-arc/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/5c778dec-0625-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: ponatara
learn_banner_products:
- azure
ms.reviewer: davidsmatlak
ms.author: ponatara
ms.service: azure-arc
ms.subservice: azure-arc-kubernetes
description: Install the Azure-managed Argo CD extension on an AKS or Azure Arc-enabled Kubernetes cluster, and deploy a sample application from Git.
ms.topic: quickstart
ms.date: 2026-09-17T00:00:00.0000000Z
locale: en-us
document_id: 0d5200b3-30c5-0fa6-39bc-1b9645847e6b
document_version_independent_id: fa8c8353-4311-0853-5732-ecdaff0c24fd
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/quickstart-deploy-gitops-argo-cd.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-arc/kubernetes/quickstart-deploy-gitops-argo-cd
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/quickstart-deploy-gitops-argo-cd.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 390fe89a-65e6-f94f-1e8f-a1d328367f42
---

# Quickstart: Deploy an application by using GitOps with Argo CD - Azure Arc | Microsoft Learn

In this quickstart, you install the Argo CD cluster extension and create an Argo CD Application that deploys the AKS store demo from Git.

## Prerequisites

You need one of the following target clusters:

- An Azure Arc-enabled Kubernetes cluster that's connected and running. You need read and write permissions on `Microsoft.Kubernetes/connectedClusters`.
- An AKS cluster that's running and uses managed identity. You need read and write permissions on `Microsoft.ContainerService/managedClusters`.

For either cluster type, you also need:

- Read and write permissions on `Microsoft.KubernetesConfiguration/extensions`.
- The latest Azure CLI. The source tutorial lists Azure CLI version 2.15 or later, but use the latest version.
- The latest `k8s-extension` and `k8s-configuration` Azure CLI extensions.
- `kubectl`. It's preinstalled in Azure Cloud Shell. To install it locally through Azure CLI, run `az aks install-cli`.
- Outbound access to the repository and required Azure endpoints. See [Network requirements](tutorial-use-gitops-argocd#network-requirements).

Run the following commands in Bash. Set `CLUSTER_TYPE` to `managedClusters` for AKS or `connectedClusters` for Azure Arc-enabled Kubernetes.

```azurecli
RESOURCE_GROUP="my-resource-group"
CLUSTER_NAME="my-cluster"
CLUSTER_TYPE="managedClusters"
EXTENSION_NAME="argocd"
```

Sign in and select the subscription that contains the cluster.

```azurecli
az login
az account set --subscription "my-subscription-id"
```

## Verify AKS managed identity

Skip this section for Azure Arc-enabled Kubernetes.

Check the AKS identity type.

```azurecli
az aks show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CLUSTER_NAME" \
  --query identity.type \
  --output tsv
```

If the command doesn't return `SystemAssigned` or `UserAssigned`, enable managed identity.

```azurecli
az aks update \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CLUSTER_NAME" \
  --enable-managed-identity
```

## Register resource providers

Register the resource providers used by the extension platform.

```azurecli
az provider register --namespace Microsoft.Kubernetes --wait
az provider register --namespace Microsoft.ContainerService --wait
az provider register --namespace Microsoft.KubernetesConfiguration --wait
```

## Install or update Azure CLI extensions

The `--upgrade` option installs each extension if it isn't present and updates it if an earlier version is installed.

```azurecli
az extension add --name k8s-extension --upgrade --yes
az extension add --name k8s-configuration --upgrade --yes
```

## Install the Argo CD extension

This quickstart disables Redis high availability so the extension can run on a cluster with fewer than four nodes. It allows Argo CD Application resources in the `argocd` namespace.

```azurecli
az k8s-extension create \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --cluster-type "$CLUSTER_TYPE" \
  --name "$EXTENSION_NAME" \
  --extension-type Microsoft.ArgoCD \
  --config "redis-ha.enabled=false" \
  --config "configs.params.application\.namespaces=argocd"
```

Note

For a production-oriented deployment, review high availability and workload identity in the [Argo CD deployment tutorial](tutorial-use-gitops-argocd). High availability is the default and requires at least four nodes.

Verify that the extension reached the `Succeeded` provisioning state.

```azurecli
az k8s-extension show \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --cluster-type "$CLUSTER_TYPE" \
  --name "$EXTENSION_NAME" \
  --query provisioningState \
  --output tsv
```

## Get cluster credentials

For AKS, run:

```azurecli
az aks get-credentials \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CLUSTER_NAME" \
  --overwrite-existing
```

For Azure Arc-enabled Kubernetes, use your existing kubeconfig and confirm that `kubectl` points to the intended cluster.

```bash
kubectl config current-context
kubectl get nodes
```

## Deploy the sample application

Create an Argo CD Application in the `argocd` namespace.

```bash
kubectl apply -f - <<'EOF'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: aks-store-demo
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/Azure-Samples/aks-store-demo.git
    targetRevision: HEAD
    path: kustomize/overlays/dev
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated: {}
EOF
```

The example follows the source tutorial and tracks `HEAD`. For repeatable production deployments, pin `targetRevision` to a reviewed commit, tag, or branch according to your release process.

## Verify the application

Check the Argo CD Application resource.

```bash
kubectl get application aks-store-demo \
  --namespace argocd \
  --output wide
```

Inspect synchronization and health details.

```bash
kubectl describe application aks-store-demo \
  --namespace argocd
```

## Clean up resources

Delete the sample Application.

```bash
kubectl delete application aks-store-demo --namespace argocd
```