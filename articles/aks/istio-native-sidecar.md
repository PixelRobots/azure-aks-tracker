---
layout: Conceptual
title: Enable native sidecar mode for Istio-based service mesh add-on in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/istio-native-sidecar
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
description: Enable native sidecar mode for Istio-based service mesh add-on in Azure Kubernetes Service (AKS)
ms.topic: how-to
ms.custom: devx-track-azurecli
ms.date: 2024-05-07T00:00:00.0000000Z
ms.author: fuyuanbie
author: biefy
locale: en-us
document_id: 51cc15b6-1aa9-241e-a5bd-ec7de5a86582
document_version_independent_id: 1760dca2-057d-5a3d-bfcf-dc5b4d4c6c94
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/istio-native-sidecar.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/istio-native-sidecar
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/istio-native-sidecar.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 44f8de14-9f7c-a6df-df20-91ae60a7c6fb
---

# Enable native sidecar mode for Istio-based service mesh add-on in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Kubernetes [sidecar containers](https://kubernetes.io/blog/2023/08/25/native-sidecar-containers/) feature aims to provide a more robust and user-friendly way to incorporate sidecar patterns into Kubernetes applications, improving efficiency, reliability, and simplicity.

Native sidecar is well-suited for Istio. It offers several benefits, including simplified sidecar management, improved reliability, and enhanced coordination. In native sidecar mode, the sidecar always starts before the main application. It also shuts down gracefully after the main app. This behavior removes the need for manual workarounds to handle container lifecycle or Pod termination issues.

Starting from Kubernetes version 1.29, [sidecar containers](https://kubernetes.io/blog/2023/08/25/native-sidecar-containers/) feature is turned on for AKS. With this change, [Istio native sidecar mode](https://istio.io/latest/blog/2023/native-sidecars/) can be used with the Istio add-on for AKS. Native sidecar mode became the default for Istio [starting in version 1.27](https://istio.io/latest/news/releases/1.27.x/announcing-1.27/change-notes/#installation). The Istio-based service mesh on AKS aligns with this behavior with minimal interruption for existing customers.

## Default behavior

Existing clusters with Istio add-on using the preview `IstioNativeSidecarModePreview` feature flag retain their current native sidecar status regardless of cluster version or Istio add-on revision.

Starting with AKS 1.33 and Istio add-on `asm-1-29`, AKS service mesh add-on uses native sidecar for the Envoy proxy by default for all clusters. Prior to `asm-1-29`, this setting applies based on your cluster version, the Azure service mesh add-on revision, and whether the add-on was newly installed or upgraded.

| AKS Version | ASM Revision | Add-on Install Behavior | Upgrade Behavior |
| --- | --- | --- | --- |
| &lt; 1.33 | Any | Disabled | Disabled |
| 1.33+ | &lt; `asm-1-27` | Disabled | Disabled |
| 1.33+ | `asm-1-27` | Enabled (transition release) | Disabled (upgrade doesn't auto-enable) |
| 1.33+ | `asm-1-28` | Enabled (transition release) | Disabled (upgrade doesn't auto-enable) |
| 1.33+ | `asm-1-29`+ | Enabled | Enabled (by mesh or cluster upgrade to required versions) |

## New clusters

When creating a new AKS cluster with the [az aks create](/en-us/cli/azure/aks#az-aks-create) command, choose version `1.33` or newer and Istio `asm-1-27` or newer. The new cluster has native sidecar mode enabled automatically.

```azurecli
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER \
    --enable-asm \
    --kubernetes-version 1.33 \
    --revision asm-1-27 \
    --generate-ssh-keys    
    ...
```

For a new service mesh installation on an existing cluster &gt;= version AKS 1.33, select `asm-1-27` or newer during [installation](istio-deploy-addon).

## Existing clusters

This section describes how to check native sidecar feature status.

### Check feature status

When native sidecar mode is enabled, environment variable `ENABLE_NATIVE_SIDECARS` appears with value `true` in Istio's control plane pod template. Use the following command to check `istiod` deployment.

```azurecli
kubectl get deployment -l app=istiod -n aks-istio-system -o json | jq '.items[].spec.template.spec.containers[].env[] | select(.name=="ENABLE_NATIVE_SIDECARS")'
```

If native sidecar mode is successfully enabled, the `istio-proxy` container is shown as an init container. Use the following command to check sidecar injection:

```bash
kubectl get pods -o "custom-columns=NAME:.metadata.name,INIT:.spec.initContainers[*].name,CONTAINERS:.spec.containers[*].name"
```

The `istio-proxy` container should be shown as an init container.

```bash
NAME                     INIT                     CONTAINERS
sleep-7656cf8794-5b5j4   istio-init,istio-proxy   sleep
```

### Check prerequisites

If native sidecar isn't enabled, it's likely one of the version prerequisites wasn't met.

1. Check that the AKS cluster's Kubernetes control plane version is 1.33 or higher using [az aks show](/en-us/cli/azure/aks#az-aks-show).

    ```azurecli
    az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER --query "kubernetesVersion" -o tsv
    ```

    If the control plane version is too old, you can [upgrade Kubernetes control plane](upgrade-aks-cluster).
2. Ensure node pools run version `1.33` or newer and the power state is running.

    ```azurecli
    az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER --query "agentPoolProfiles[].{name:name,currentOrchestratorVersion:currentOrchestratorVersion,powerState:powerState.code}" -o table
    ```

Caution

Native sidecar mode by default requires both Kubernetes control plane and data plane on version 1.33 or higher. Ensure all your nodes are version 1.33 or newer before enabling the service mesh add-on. Otherwise, native sidecar won't be enabled by default.

    If any node pool version is too old, [upgrade the node image](node-image-upgrade) to version `1.33` or newer.
3. If service mesh add-on is enabled, check the installed revision:

    ```azurecli
    az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER --query "serviceMeshProfile.istio.revisions" -o tsv
    ```

    Review the table on default behavior to determine if your revision meets prerequisites.