---
layout: Conceptual
title: Enable Istio CNI for Istio-based service mesh add-on for Azure Kubernetes Service - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/istio-cni
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
description: Enable Istio CNI for enhanced security in Istio-based service mesh add-on for Azure Kubernetes Service
ms.topic: how-to
ms.custom: devx-track-azurecli
ms.date: 2026-05-06T00:00:00.0000000Z
ms.author: gerobayopaz
author: german1608
locale: en-us
document_id: 082a3178-8a79-9bd7-7fed-2eb4e4e89f49
document_version_independent_id: a56dfe06-6bad-2be5-341f-88d5784dceec
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/istio-cni.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/istio-cni
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/istio-cni.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 9945c56e-6c81-5a23-ff17-66bf28e4b187
---

# Enable Istio CNI for Istio-based service mesh add-on for Azure Kubernetes Service - Azure Kubernetes Service | Microsoft Learn

This article shows you how to enable Istio CNI for the Istio-based service mesh add-on on Azure Kubernetes Service (AKS). Istio CNI improves security by eliminating the need for privileged network capabilities in application workloads within the service mesh.

## Overview

Istio redirects application traffic to the Envoy sidecar proxy using one of two mechanisms:

- **Istio CNI** (`CNIChaining`): A cluster-level CNI plugin configures traffic redirection, so application pods don't need privileged network capabilities. The `istio-validation` init container is added during sidecar injection to verify that traffic redirection is configured correctly.
- **Init containers** (`InitContainers`): Each application pod uses a privileged `istio-init` init container that requires `NET_ADMIN` and `NET_RAW` capabilities to configure traffic redirection. These capabilities often raise security concerns in enterprise environments.

Starting with revision `asm-1-30`, Istio CNI is the default redirection mechanism for new mesh installations. For revisions `asm-1-25` through `asm-1-29`, init containers remain the default and you must explicitly enable Istio CNI. Earlier revisions don't support Istio CNI.

Istio CNI provides the following benefits over init containers:

- **Improves security**: Removes the need for privileged network capabilities (`NET_ADMIN`, `NET_RAW`) from application workloads
- **Simplifies pod security policies**: Application pods only require minimal capabilities
- **Maintains functionality**: Provides the same traffic management capabilities as the traditional init container approach

Note

Istio CNI is **not** a replacement for [Azure CNI](concepts-network-cni-overview) and will not interfere with your normal AKS networking. It is a separate plugin designed to handle Istio’s traffic redirection setup at the node level, improving security by removing the need for privileged init containers in application pods.

## Before you begin

- Install the Azure CLI version 2.86.0 or later. You can run `az --version` to verify the version. To install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- You need an AKS cluster with the Istio-based service mesh add-on enabled. If you don't have this setup, see [Deploy Istio-based service mesh add-on for Azure Kubernetes Service](istio-deploy-addon).
- Ensure your Istio service mesh is using revision `asm-1-25` or later. You can check the current revision with:

    ```azurecli
    az aks show --resource-group <resource-group-name> --name <cluster-name> --query 'serviceMeshProfile.istio.revisions'
    ```

### Set environment variables

```bash
export CLUSTER=<cluster-name>
export RESOURCE_GROUP=<resource-group-name>
```

## Enable Istio CNI

### Enable Istio CNI on a new mesh installation

For revisions `asm-1-30` and later, `CNIChaining` is the default proxy redirection mechanism for new installations of the service mesh add-on. You don't need to specify any extra parameters. For revisions `asm-1-25` through `asm-1-29`, enable Istio CNI explicitly by specifying the `--proxy-redirection-mechanism` parameter:

```azurecli
az aks mesh enable --resource-group ${RESOURCE_GROUP} --name ${CLUSTER} --proxy-redirection-mechanism CNIChaining
```

### Enable Istio CNI on an existing mesh installation

If you already have the Istio service mesh add-on enabled, you can switch to Istio CNI using the following command:

```azurecli
az aks mesh proxy-redirection-mechanism --resource-group ${RESOURCE_GROUP} --name ${CLUSTER} --mechanism CNIChaining
```

The `asm-1-30` default applies only to new installations, so upgrading an existing mesh doesn't change its redirection mechanism.

Note

Existing pods won't automatically switch to the `istio-validation` init container. Restart your deployments after enabling Istio CNI so that pods pick up the change (for example, `kubectl rollout restart deployment/<name>`).

## Verify Istio CNI is enabled

Use `az aks get-credentials` to get the credentials for your AKS cluster:

```azurecli
az aks get-credentials --resource-group ${RESOURCE_GROUP} --name ${CLUSTER}
```

After enabling Istio CNI, verify the installation by checking that the CNI DaemonSet is running:

```bash
kubectl get daemonset -n aks-istio-system
```

You should see the Istio CNI DaemonSet running:

```output
NAME                                      DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
azure-service-mesh-istio-cni-addon-node   3         3         3       3            3           kubernetes.io/os=linux   94s
```

## Deploy workloads and verify behavior

To verify the security improvement, you can deploy the bookinfo sample application and check that workloads use the secure `istio-validation` init container instead of the privileged `istio-init` container.

### Deploy sample application

First, enable sidecar injection for the default namespace:

```bash
# Get the current Istio revision
REVISION=$(az aks show --resource-group ${RESOURCE_GROUP} --name ${CLUSTER} --query 'serviceMeshProfile.istio.revisions[0]' -o tsv)

# Label the namespace for sidecar injection
kubectl label namespace default istio.io/rev=${REVISION}
```

Deploy the bookinfo sample application:

```bash
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.25/samples/bookinfo/platform/kube/bookinfo.yaml
```

### Verify secure init container usage

Check that the deployed pods use the secure `istio-validation` init container instead of `istio-init`:

```bash
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.initContainers[0].name}{"\t"}{.spec.initContainers[0].securityContext.capabilities}{"\n"}{end}'
```

Expected output should show `istio-validation` as the init container with dropped capabilities:

```output
details-v1-799dc5d847-7x9gl     istio-validation        {"drop":["ALL"]}
productpage-v1-99d6d698f-89gpj  istio-validation        {"drop":["ALL"]}
ratings-v1-7545c4bb6c-m7t42     istio-validation        {"drop":["ALL"]}
reviews-v1-8679d76d6c-jz4vg     istio-validation        {"drop":["ALL"]}
reviews-v2-5b9c77895c-b2b7m     istio-validation        {"drop":["ALL"]}
reviews-v3-5b57874f5f-kk9rt     istio-validation        {"drop":["ALL"]}
```

You can also check the YAML for a specific pod to verify the security context:

```bash
kubectl get pod <pod-name> -n <namespace> -o yaml | grep -A 20 -B 25 "name: istio-validation"
```

The output should show that the `istio-validation` init container has no privileged capabilities:

```output
initContainers:
  - args:
    …
    name: istio-validation
    …
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
      privileged: false
      readOnlyRootFilesystem: true
      runAsGroup: 1337
      runAsNonRoot: true
      runAsUser: 1337
```

## Disable Istio CNI

To disable Istio CNI and return to using traditional init containers, use the following command:

```azurecli
az aks mesh proxy-redirection-mechanism --resource-group ${RESOURCE_GROUP} --name ${CLUSTER} --mechanism InitContainers
```

After disabling Istio CNI:

1. The CNI DaemonSet will be removed:

    ```bash
    kubectl get daemonset azure-service-mesh-istio-cni-addon-node -n aks-istio-system
    ```

    Expected output (no CNI DaemonSet):

    ```output
    Error from server (NotFound): daemonsets.apps "azure-service-mesh-istio-cni-addon-node" not found
    ```
2. New workloads will use the traditional `istio-init` init container with network capabilities. Restart all existing deployments to pick up the change:

    ```bash
    kubectl rollout restart deployment/details-v1
    kubectl rollout restart deployment/productpage-v1
    kubectl rollout restart deployment/ratings-v1
    kubectl rollout restart deployment/reviews-v1
    kubectl rollout restart deployment/reviews-v2
    kubectl rollout restart deployment/reviews-v3
    ```
3. Verify init container name and capabilities:

    ```bash
    kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.initContainers[0].name}{"\t"}{.spec.initContainers[0].securityContext.capabilities}{"\n"}{end}'
    ```

    Expected output should show `istio-init` with network capabilities:

    ```output
    details-v1-57bc58c559-722v8     istio-init        {"add":["NET_ADMIN","NET_RAW"],"drop":["ALL"]}
    productpage-v1-7bb64f657c-jw6gs istio-init        {"add":["NET_ADMIN","NET_RAW"],"drop":["ALL"]}
    ratings-v1-57d5594c75-4zd49     istio-init        {"add":["NET_ADMIN","NET_RAW"],"drop":["ALL"]}
    reviews-v1-7fd8f9cd59-mdcf9     istio-init        {"add":["NET_ADMIN","NET_RAW"],"drop":["ALL"]}
    reviews-v2-7b8bdc9cdf-k9qgb     istio-init        {"add":["NET_ADMIN","NET_RAW"],"drop":["ALL"]}
    reviews-v3-588854d9d7-s2f7j     istio-init        {"add":["NET_ADMIN","NET_RAW"],"drop":["ALL"]}
    ```