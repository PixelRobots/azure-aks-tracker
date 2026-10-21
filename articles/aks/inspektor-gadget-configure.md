---
layout: Conceptual
title: Install and configure the Inspektor Gadget extension on AKS (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/inspektor-gadget-configure
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
description: Learn how to install, configure, and remove the Inspektor Gadget cluster extension on Azure Kubernetes Service (AKS) by using the Azure CLI.
author: mqasimsarfraz
ms.author: qasimsarfraz
ms.date: 2026-06-26T00:00:00.0000000Z
ms.topic: how-to
ai-usage: ai-assisted
locale: en-us
document_id: 7d72bebf-e487-d235-9340-69003c340e07
document_version_independent_id: 01842a73-394f-15f3-6b97-3b954232e86b
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/inspektor-gadget-configure.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,bash
toc_rel: toc.json
asset_id: aks/inspektor-gadget-configure
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/inspektor-gadget-configure.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 9e71bbf0-63bf-157f-4c1f-e07fa0e6348c
---

# Install and configure the Inspektor Gadget extension on AKS (preview) - Azure Kubernetes Service | Microsoft Learn

This article shows how to install the [Inspektor Gadget](https://go.microsoft.com/fwlink/?LinkId=2260072) cluster extension on your Azure Kubernetes Service (AKS) cluster, change its configuration, and remove it.

The extension deploys Inspektor Gadget as a DaemonSet named `gadget` in the `gadget` namespace. You manage it through the Azure resource management plane by using the `az k8s-extension` commands. To learn how to inspect workloads after you install the extension, see [Run gadgets to inspect workloads on AKS](inspektor-gadget-run-gadgets).

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Prerequisites

- An AKS cluster with `kubectl` access. If you don't have one, see [Create an AKS cluster](tutorial-kubernetes-deploy-cluster).
- The Azure CLI with the `k8s-extension` extension installed:

    ```azurecli
    az extension add --name k8s-extension
    ```
- Any existing Inspektor Gadget installation removed before you install the extension. If you previously deployed it manually, run `kubectl gadget undeploy` or `helm uninstall`.

In the commands in this article, replace `myResourceGroup` and `myAKSCluster` with the values for your environment.

## Install the extension

Install the extension by using `az k8s-extension create` with the `microsoft.inspektorgadget` extension type:

```azurecli
az k8s-extension create \
    --cluster-type managedClusters \
    --cluster-name myAKSCluster \
    --resource-group myResourceGroup \
    --name inspektor-gadget \
    --extension-type microsoft.inspektorgadget \
    --release-train preview
```

By default, the extension automatically upgrades its minor version. To keep it on the installed version instead, add `--auto-upgrade-minor-version false` to the install command.

### Verify the installation

Confirm that the extension is provisioned successfully and that the DaemonSet is running. The provisioning state should show `Succeeded`, and all gadget pods should be `Running` and `Ready`.

```azurecli
az k8s-extension show \
    --cluster-type managedClusters \
    --cluster-name myAKSCluster \
    --resource-group myResourceGroup \
    --name inspektor-gadget
```

```bash
kubectl get ds gadget -n gadget
kubectl get pods -n gadget -l k8s-app=gadget
```

## Configure the extension

Pass configuration settings by using the `--configuration-settings` parameter on `az k8s-extension update`. Organize settings in two levels:

- **Extension settings** at the top level configure the extension itself, such as integrations.
- **Inspektor Gadget settings** are under the `inspektor-gadget.` key, which in turn splits into runtime settings (`inspektor-gadget.config`) and Kubernetes resource settings (root level).

### Extension settings

Top-level settings configure the extension integrations:

| Setting | Description | Default |
| --- | --- | --- |
| `azureMonitor.enabled` | Exports gadget metrics to Azure Monitor managed Prometheus. | `false` |

### Inspektor Gadget settings

Runtime settings under `inspektor-gadget.config` configure the gadget daemon:

| Setting | Description | Default |
| --- | --- | --- |
| `inspektor-gadget.config.daemonLogLevel` | Daemon log level: `trace`, `debug`, `info`, `warning`, `error`, `fatal`, or `panic`. | `info` |
| `inspektor-gadget.config.hookMode` | How the daemon gets container notifications: `auto`, `crio`, `podinformer`, `nri`, or `fanotify+ebpf`. | `auto` |
| `inspektor-gadget.config.operator.oci.verify-image` | Verifies the signature of gadget images before running them. | `true` |
| `inspektor-gadget.config.operator.oci.allowed-gadgets` | Restricts which gadget images are allowed to run. | `[]` |

Kubernetes resource settings at the root level configure the `gadget` DaemonSet:

| Setting | Description | Default |
| --- | --- | --- |
| `inspektor-gadget.nodeSelector` | Limits which nodes run the DaemonSet. | `kubernetes.io/os: linux` |
| `inspektor-gadget.tolerations` | Tolerations for the `gadget` container. | `{}` |
| `inspektor-gadget.resources` | CPU and memory requests and limits. | `{}` |
| `inspektor-gadget.hostPID` | Uses the host PID namespace. | `true` |
| `inspektor-gadget.additionalEnv` | Extra environment variables for the gadget container. | `[]` |

For the complete list of Inspektor Gadget values, see the [upstream chart `values.yaml`](https://go.microsoft.com/fwlink/?LinkId=2370616).

Important

`az k8s-extension update` is additive. New configuration settings merge with the existing ones. If an update fails, the broken setting can persist and block later updates. To recover, run `az k8s-extension update` again and explicitly revert the problematic setting.

Note

Inspektor Gadget doesn't pick up configuration changes live. After you update settings, restart the DaemonSet to apply them:

```bash
kubectl rollout restart daemonset/gadget -n gadget
kubectl rollout status daemonset/gadget -n gadget --timeout=120s
```

For example, set the daemon log level to `debug`:

```azurecli
az k8s-extension update \
    --cluster-type managedClusters \
    --cluster-name myAKSCluster \
    --resource-group myResourceGroup \
    --name inspektor-gadget \
    --configuration-settings inspektor-gadget.config.daemonLogLevel=debug \
    --yes
```

## Remove the extension

When you no longer need Inspektor Gadget, delete the extension. This action removes the gadget pods, DaemonSet, and related resources.

```azurecli
az k8s-extension delete \
    --cluster-type managedClusters \
    --cluster-name myAKSCluster \
    --resource-group myResourceGroup \
    --name inspektor-gadget \
    --yes
```