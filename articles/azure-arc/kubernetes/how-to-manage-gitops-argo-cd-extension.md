---
layout: Conceptual
title: Manage the Argo CD extension on AKS and Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/how-to-manage-gitops-argo-cd-extension
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
description: How to article for managing the Argo CD extension on AKS and Azure Arc-enabled Kubernetes
ms.topic: how-to
ms.date: 2026-09-25T00:00:00.0000000Z
locale: en-us
document_id: 4d12694b-61cc-7fb1-0326-c1b33f73e54f
document_version_independent_id: 948c9afe-b726-af39-be0a-f89d5f341026
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/how-to-manage-gitops-argo-cd-extension.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-arc/kubernetes/how-to-manage-gitops-argo-cd-extension
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/how-to-manage-gitops-argo-cd-extension.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 61ef1333-6490-ba73-98fe-252aa76e1869
---

# Manage the Argo CD extension on AKS and Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn

This article shows how to manage an existing Argo CD extension deployment. For installation, workload identity, private Azure Container Registry access, monitoring setup, migration, and first application deployment, see [Tutorial: Deploy applications using GitOps with Argo CD](tutorial-use-gitops-argocd).

## Prerequisites

Before you begin, ensure:

- Argo CD extension is installed on an AKS or Azure Arc-enabled Kubernetes cluster.
- Read and write permissions are configured on the cluster resource and `Microsoft.KubernetesConfiguration/extensions`.
- The latest Azure CLI and `k8s-extension` Azure CLI extensions are installed.
- `kubectl` configured to access the target cluster.

Set the following Bash variables. Use `managedClusters` for AKS or `connectedClusters` for Azure Arc-enabled Kubernetes.

```azurecli
RESOURCE_GROUP="my-resource-group"
CLUSTER_NAME="my-cluster"
CLUSTER_TYPE="managedClusters"
EXTENSION_NAME="argocd"
ARGOCD_NAMESPACE="argocd"
```

## Inspect extension status

View the extension provisioning state, installed version, and configuration.

```azurecli
az k8s-extension show \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --cluster-type "$CLUSTER_TYPE" \
  --name "$EXTENSION_NAME" \
  --output yaml
```

Return only the provisioning state.

```azurecli
az k8s-extension show \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --cluster-type "$CLUSTER_TYPE" \
  --name "$EXTENSION_NAME" \
  --query provisioningState \
  --output tsv
```

Verify that the Argo CD workloads are available in the cluster.

```bash
kubectl get deployments,pods --namespace "$ARGOCD_NAMESPACE"
```

## Configure Application namespaces

Use the `configs.params.application\.namespaces` setting to specify the namespaces in which Argo CD Application resources can be created.

The following example allows Application resources in the `default`, `argocd`, and `team-a` namespaces.

```azurecli
az k8s-extension update \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --cluster-type "$CLUSTER_TYPE" \
  --name "$EXTENSION_NAME" \
  --config "configs.params.application\.namespaces=default,argocd,team-a"
```

| Scenario | Configuration value |
| --- | --- |
| Application resources only in the Argo CD namespace | `argocd` |
| Application resources in two namespaces | `argocd,team-a` |
| Application resources in multiple team namespaces | `argocd,team-a,team-b` |

After the update completes, verify the provisioning state.

```azurecli
az k8s-extension show \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --cluster-type "$CLUSTER_TYPE" \
  --name "$EXTENSION_NAME" \
  --query provisioningState \
  --output tsv
```

Note

The configured namespaces control where Argo CD Application resources can be defined. The destination namespace in an Application specification controls where that application's Kubernetes resources are deployed.

## Update extension settings

Use `az k8s-extension update` to change extension-managed Argo CD settings. The following example updates the URL used by Argo CD.

```azurecli
az k8s-extension update \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --cluster-type "$CLUSTER_TYPE" \
  --name "$EXTENSION_NAME" \
  --config "configs.cm.url=https://argocd.contoso.com"
```

You can pass more than one setting in the same update operation.

```azurecli
az k8s-extension update \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --cluster-type "$CLUSTER_TYPE" \
  --name "$EXTENSION_NAME" \
  --config "configs.cm.url=https://argocd.contoso.com" \
  --config "configs.params.application\.namespaces=argocd,team-a"
```

Important

Don't directly update Argo CD ConfigMaps. Apply configuration changes through the extension configuration API or the infrastructure-as-code template that manages the extension.

## Inspect application status

List Application resources across namespaces.

```bash
kubectl get applications.argoproj.io --all-namespaces
```

View the synchronization and health status of a specific Application.

```bash
APPLICATION_NAME="my-application"
APPLICATION_NAMESPACE="argocd"

kubectl get application "$APPLICATION_NAME" \
  --namespace "$APPLICATION_NAMESPACE" \
  --output jsonpath='{.status.sync.status}{"\t"}{.status.health.status}{"\n"}'
```

Review Application conditions, events, and recent status details.

```bash
kubectl describe application "$APPLICATION_NAME" \
  --namespace "$APPLICATION_NAMESPACE"
```

## Troubleshoot the extension

### Extension provisioning doesn't succeed

Inspect the extension resource and review `provisioningState`, error details, and configuration values.

```azurecli
az k8s-extension show \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --cluster-type "$CLUSTER_TYPE" \
  --name "$EXTENSION_NAME" \
  --output yaml
```

Then inspect Kubernetes events and workloads in the extension namespace.

```bash
kubectl get events \
  --namespace "$ARGOCD_NAMESPACE" \
  --sort-by=.lastTimestamp

kubectl get deployments,pods \
  --namespace "$ARGOCD_NAMESPACE"
```

Check whether an admission policy blocks creation of the Argo CD namespace or workloads.

### Installation times out on a small cluster

High availability is enabled by default and requires at least four nodes. For a smaller test cluster, disable Redis HA.

```azurecli
az k8s-extension update \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --cluster-type "$CLUSTER_TYPE" \
  --name "$EXTENSION_NAME" \
  --config "redis-ha.enabled=false"
```

### Application synchronization fails

Inspect the Application conditions and controller workloads.

```bash
kubectl describe application "$APPLICATION_NAME" \
  --namespace "$APPLICATION_NAMESPACE"

kubectl get pods \
  --namespace "$ARGOCD_NAMESPACE"
```

Confirm that the cluster has outbound access to:

- The configured repository on TCP port 22 for SSH or TCP port 443 for HTTPS.
- `https://management.azure.com`
- `https://<region>.dp.kubernetesconfiguration.azure.com`
- `https://login.microsoftonline.com`
- `https://mcr.microsoft.com`

For extension-platform diagnostics, see [Troubleshoot extension issues for Azure Arc-enabled Kubernetes clusters](extensions-troubleshooting).

## Delete the extension

Before deleting the extension, review the applications, repository credentials, and cluster registrations that depend on it.

```azurecli
az k8s-extension delete \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --cluster-type "$CLUSTER_TYPE" \
  --name "$EXTENSION_NAME" \
  --yes
```