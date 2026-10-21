---
layout: Conceptual
title: Configure the Azure App Configuration extension for your Azure Kubernetes Service - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/azure-app-configuration-settings
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
description: Learn how to configure the Azure App Configuration extension specifically for your Azure Kubernetes Service (AKS).
author: RichardChen820
ms.author: junbchen
ms.topic: concept-article
ms.custom: devx-track-azurecli
ms.subservice: aks-developer
ms.date: 2024-09-10T00:00:00.0000000Z
locale: en-us
document_id: c0182910-195b-9d3e-7f89-f3f46a551c2d
document_version_independent_id: 97ffcf41-0736-f692-9351-70cdf28b0f60
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/azure-app-configuration-settings.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/azure-app-configuration-settings
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/azure-app-configuration-settings.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/80beb97b-18aa-44f8-9420-8f2a4cd448eb
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/8c09e0ef-0fde-4b6d-bf1b-b517e4db7f80
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 589cf6a4-5e64-6164-58c5-23ffcf820e61
---

# Configure the Azure App Configuration extension for your Azure Kubernetes Service - Azure Kubernetes Service | Microsoft Learn

Once you [created the Azure App Configuration extension](azure-app-configuration), you can configure the extension to work best for you and your project using various configuration options, like:

- Configuring the replica count.
- Configuring the log verbosity.
- Configuring the installation namespace.

The extension enables you to configure Azure App Configuration extension settings by using the `--configuration-settings` parameter in the Azure CLI.

Tip

For a list of available options, see [Azure App Configuration Kubernetes Provider helm values](https://raw.githubusercontent.com/Azure/AppConfiguration-KubernetesProvider/main/deploy/parameter/helm-values.yaml).

## Configure the replica count

The default replica count is `1`. Create Azure App Configuration extension with customized replica count:

```azurecli
az k8s-extension create --cluster-type managedClusters \
    --cluster-name myAKSCluster \
    --resource-group myResourceGroup \
    --name appconfigurationkubernetesprovider \
    --extension-type Microsoft.AppConfiguration \
    --auto-upgrade-minor-version true \
    --configuration-settings "replicaCount=3"
```

Note

If configuration settings are sensitive and need to be protected (for example, cert-related information), pass the `--configuration-protected-settings` parameter and the value will be protected from being read.

## Configure the log verbosity

The default log verbosity is `1`. Create Azure App Configuration extension with customized log verbosity:

```azurecli
az k8s-extension create --cluster-type managedClusters \
    --cluster-name myAKSCluster \
    --resource-group myResourceGroup \
    --name appconfigurationkubernetesprovider \
    --extension-type Microsoft.AppConfiguration \
    --auto-upgrade-minor-version true \
    --configuration-settings "logVerbosity=3"
```

Log verbosity levels follow the [klog](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-instrumentation/logging.md#what-method-to-use) convention:

- `0`: Warning and error only.
- `1`: Informational, this level is default.
- `2`: Detailed steady state information.
- `3`: Extended information about changes.
- `4`: Debug level verbosity.
- `5`: Trace level verbosity.

## Configure the Azure App Configuration extension namespace

The Azure App Configuration extension gets installed in the `azappconfig-system` namespace by default. To override it, use `--release-namespace`. Include the cluster `--scope` to redefine the namespace.

```azurecli
az k8s-extension create --cluster-type managedClusters \
    --cluster-name myAKSCluster \
    --resource-group myResourceGroup \
    --name appconfigurationkubernetesprovider \
    --extension-type Microsoft.AppConfiguration \
    --auto-upgrade-minor-version true \
    --scope cluster \
    --release-namespace custom-namespace
```

## Show current configuration settings

Use the `az k8s-extension show` command to show the current Azure App Configuration extension settings:

```azurecli
az k8s-extension show --cluster-type managedClusters \
    --cluster-name myAKSCluster \
    --resource-group myResourceGroup \
    --name appconfigurationkubernetesprovider
```

## Update configuration settings

To update your Azure App Configuration extension settings, recreate the extension with the desired state. For example, assume we installed the extension using the following configuration:

```azurecli
az k8s-extension create --cluster-type managedClusters \
    --cluster-name myAKSCluster \
    --resource-group myResourceGroup \
    --name appconfigurationkubernetesprovider \
    --extension-type Microsoft.AppConfiguration \
    --auto-upgrade-minor-version true \  
    --configuration-settings "replicaCount=2" 
```

To update the `replicaCount` from two to three, use the following command:

```azurecli
az k8s-extension create --cluster-type managedClusters \
    --cluster-name myAKSCluster \
    --resource-group myResourceGroup \
    --name appconfigurationkubernetesprovider \
    --extension-type Microsoft.AppConfiguration \
    --auto-upgrade-minor-version true \
    --configuration-settings "replicaCount=3"
```