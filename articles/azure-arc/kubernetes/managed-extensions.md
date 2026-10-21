---
layout: Conceptual
title: Version-managed extensions (preview) for Arc-enabled Kubernetes - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/managed-extensions
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
author: davidsmatlak
learn_banner_products:
- azure
ms.reviewer: davidsmatlak
ms.author: davidsmatlak
ms.service: azure-arc
ms.subservice: azure-arc-kubernetes
ms.date: 2025-06-23T00:00:00.0000000Z
ms.topic: overview
description: Version-managed extensions (preview) for Arc-enabled Kubernetes adds efficiency by helping your extensions work better together.
ms.custom:
- references_regions
- build-2025
locale: en-us
document_id: 06d3b8f5-7eff-edc2-2806-d53b8d818b73
document_version_independent_id: 63eafbd7-15f2-be9e-167f-505174cde3f4
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/managed-extensions.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/managed-extensions
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/managed-extensions.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 493b923a-08ed-191a-0a52-6d8ba0957965
---

# Version-managed extensions (preview) for Arc-enabled Kubernetes - Azure Arc | Microsoft Learn

Version-managed extensions (preview) simplifies the process of building, deploying, and maintaining applications on Arc-enabled Kubernetes clusters. Applications can use version-managed extensions to assure compatibility, reconcile interdependencies, and remove the complexity of relying on bring-your-own open-source solutions.

Version-managed extensions are provided in bundled sets that are validated for interoperability against a set of supported Arc-enabled Kubernetes platforms, providing a streamlined interface for installing, maintaining, and upgrading core Arc extension services. When version-managed extension bundles are upgraded, all dependencies are appropriately handled, resulting in a more robust operating experience.

The version-managed extensions experience currently includes two foundational services: Azure Container Storage enabled by Azure Arc (storage) and Azure Key Vault Secret Store extension for Kubernetes (secrets).

Important

Version-managed extensions for Arc-enabled Kubernetes is currently in PREVIEW. See the [Supplemental Terms of Use for Microsoft Azure Previews](https://azure.microsoft.com/support/legal/preview-supplemental-terms/) for legal terms that apply to Azure features that are in beta, preview, or otherwise not yet released into general availability.

Version-managed extensions (preview) currently offers the following benefits:

- **Consistent releases and updates**: Using version-managed extensions ensures that supported services are updated together, rather than individually. This means that system administrators benefit from regular updates of validated bundles, including critical security fixes, monthly updates, and major version updates. These updates are handled by version-managed extensions and applied using a rolling update strategy, which minimizes downtime and disruption to workloads. This consistent update process ensures that the software platform remains secure, reliable, and up to date.
- **Improved extension compatibility**: Updating supported extensions together reduces the risk of version incompatibility issues between extensions. This lets you focus on building and deploying applications knowing that your extensions will work together seamlessly and are validated to be compatible with each other. When a new version of a bundled extension is available, the resulting bundle that is installed has already qualified the interoperability of this new extension version with the others in the bundle.

Version-managed extensions (preview) for Arc-enabled Kubernetes is currently available in the following regions: East US, East US 2, West US, West US 2, West US 3, West Europe, North Europe.

## Prerequisites

To use version-managed extensions, an Arc-enabled Kubernetes cluster needs version 1.27.0 or later of the [Azure Arc-enabled Kubernetes agents](conceptual-agent-overview), To verify that your agent version is 1.27.0 or later, run the following command:

```azurecli
az connectedk8s show  -g $RESOURCE_GROUP  -n $CLUSTER_NAME --query '{version:agentVersion}'
```

If the agent version is lower, [upgrade your agents manually](agent-upgrade):

```azurecli
az connectedk8s upgrade -g $RESOURCE_GROUP  -n $CLUSTER_NAME --agent-version 1.27.0
```

Tip

We recommend upgrading to [the latest version of the Azure Arc-enabled Kubernetes agents](/en-us/azure/azure-arc/kubernetes/release-notes).

You must have version 2.70.0 or later of the Azure CLI to deploy version-managed extensions to your clusters.

## Deploy version-managed extensions (preview)

Currently, version-managed extensions (preview) provides support for the following extensions:

- [Azure Container Storage enabled by Azure Arc](/en-us/azure/azure-arc/container-storage/overview)
- [Azure Key Vault Secret Store extension for Kubernetes ("SSE")](/en-us/azure/azure-arc/kubernetes/secret-store-extension?tabs=arc-k8s)

To deploy and configure version-managed extensions (preview) for Arc-enabled Kubernetes, use the [az vme](/en-us/cli/azure/vme) command.

### Configure all available version-managed extensions

To deploy all currently supported version-managed extensions, you can use the `az vme install` command with the `--include all` option. This command installs all extensions that are part of the version-managed extensions (preview) program.

Currently, before running the command to deploy all currently supported extension, you must first install `cert-manager`, which is required for the Azure Container Storage enabled by Azure Arc extension:

```azurecli
az k8s-extension create --cluster-name "${YOUR-CLUSTER-NAME}" --name "aio-certmgr" --resource-group "${YOUR-RESOURCE-GROUP}" --cluster-type connectedClusters --extension-type microsoft.iotoperations.platform --scope cluster --release-namespace cert-manager
```

To simultaneously deploy all extensions currently supported by version-managed extensions, run the following command:

```azurecli
az vme install --resource-group my-resource-group --cluster-name my-cluster --include all
```

Currently, this command installs the Azure Container Storage enabled by Azure Arc and the Azure Key Vault Secret Store extension for Kubernetes ("SSE") extensions.

### Configure Azure Container Storage enabled by Azure Arc

Follow these steps to configure Azure Container Storage enabled by Azure Arc.

1. Install `cert-manager` as a prerequisite for the extension:

    ```azurecli
    az k8s-extension create --cluster-name "${YOUR-CLUSTER-NAME}" --name "aio-certmgr" --resource-group "${YOUR-RESOURCE-GROUP}" --cluster-type connectedClusters --extension-type microsoft.iotoperations.platform --scope cluster --release-namespace cert-manager
    ```
2. Deploy the Azure Container Storage enabled by Azure Arc extension:

    ```azurecli
    az vme install --resource-group my-resource-group --cluster-name my-cluster --include microsoft.arc.containerstorage
    ```

For more information, see [What is Azure Container Storage enabled by Azure Arc?](/en-us/azure/azure-arc/container-storage/overview)

### Configure Azure Key Vault Secret Store extension for Kubernetes

To deploy the Azure Key Vault Secret Store extension for Kubernetes ("SSE"), run the following command:

```azurecli
az vme install --resource-group my-resource-group --cluster-name my-cluster --include microsoft.azure.secretstore
```

For more information, see [Use the Secret Store extension to fetch secrets for offline access in Azure Arc-enabled Kubernetes clusters](/en-us/azure/azure-arc/kubernetes/secret-store-extension?tabs=arc-k8s).