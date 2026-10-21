---
layout: Conceptual
title: Install Dapr Extension for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/dapr
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
description: Install and configure Dapr on your Azure Kubernetes Service (AKS) and Arc-enabled Kubernetes clusters using the Dapr cluster extension.
author: shivamkm07
ms.author: shivamkumar
ms.reviewer: ramithar
ms.topic: how-to
ms.date: 2026-02-05T00:00:00.0000000Z
ms.subservice: dapr-aks
ms.custom: devx-track-azurecli, references_regions
locale: en-us
document_id: 8b347b23-f008-5837-d6df-96365f87af91
document_version_independent_id: 6422c6d9-a078-bcb5-d6e0-6c50be21413f
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/dapr.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/dapr
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/dapr.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 0da00d6d-215b-c2ba-1eca-db25a81317f0
---

# Install Dapr Extension for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

[Dapr](dapr-overview) simplifies building resilient, stateless, and stateful applications that run on the cloud and edge and embrace the diversity of languages and developer frameworks. With Dapr's sidecar architecture, you can keep your code platform agnostic while tackling challenges around building microservices, like:

- Calling other services reliably and securely
- Building event-driven apps with pub/sub
- Building applications that are portable across multiple cloud services and hosts (for example, Kubernetes vs. a virtual machine)

Note

If you plan to install Dapr in a Kubernetes production environment, see the [Dapr production guidelines](https://docs.dapr.io/operations/hosting/kubernetes/kubernetes-production).

## How it works

The Dapr extension uses the Azure CLI or a Bicep template to provision the Dapr control plane on your AKS or Arc-enabled Kubernetes cluster, creating the following Dapr services:

| Dapr service | Description |
| --- | --- |
| `dapr-operator` | Manages component updates and Kubernetes services endpoints for Dapr (state stores, pub/subs, etc.) |
| `dapr-sidecar-injector` | Injects Dapr into annotated deployment pods and adds the environment variables `DAPR_HTTP_PORT` and `DAPR_GRPC_PORT` to enable user-defined applications to easily communicate with Dapr without hard-coding Dapr port values. |
| `dapr-placement` | Used for actors only. Creates mapping tables that map actor instances to pods. |
| `dapr-sentry` | Manages mTLS between services and acts as a certificate authority. For more information, read the [security overview](https://docs.dapr.io/concepts/security-concept/). |

Once Dapr is installed on your cluster, you can begin to develop using the Dapr building block APIs by [adding a few annotations](https://docs.dapr.io/operations/hosting/kubernetes/kubernetes-overview/#adding-dapr-to-a-kubernetes-deployment) to your deployments. For a more in-depth overview of the building block APIs and how to best use them, see the [Dapr building blocks overview](https://docs.dapr.io/developing-applications/building-blocks/).

Warning

If you install Dapr through the AKS or Arc-enabled Kubernetes extension, our recommendation is to continue using the extension for future management of Dapr instead of the Dapr CLI. Combining the two tools can cause conflicts and result in undesired behavior.

## Prerequisites

- An Azure subscription. If you don't have one, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- The latest version of the [Azure CLI](/en-us/cli/azure/install-azure-cli).
- An existing [AKS cluster](tutorial-kubernetes-deploy-cluster) or connected [Arc-enabled Kubernetes cluster](/en-us/azure/azure-arc/kubernetes/quickstart-connect-cluster).
- An [Azure Kubernetes Service Role-Based Access Control Admin role](/en-us/azure/role-based-access-control/built-in-roles#azure-kubernetes-service-rbac-admin).

Select how you'd like to install, deploy, and configure the Dapr extension.

# [Azure CLI](#tab/cli)
## Before you begin

### Add the Azure CLI extension for cluster extensions

Install the `k8s-extension` Azure CLI extension by running the following commands:

```azurecli
az extension add --name k8s-extension
```

If the `k8s-extension` extension is already installed, you can update it to the latest version using the following command:

```azurecli
az extension update --name k8s-extension
```

### Register the `KubernetesConfiguration` resource provider

If you aren't already using cluster extensions, you might need to register the resource provider with your subscription. You can check the status of the provider registration using the [az provider list](/en-us/cli/azure/provider#az-provider-list) command, as shown in the following example:

```azurecli
az provider list --query "[?contains(namespace,'Microsoft.KubernetesConfiguration')]" -o table
```

The *Microsoft.KubernetesConfiguration* provider should report as *Registered*, as shown in the following example output:

```output
Namespace                          RegistrationState    RegistrationPolicy
---------------------------------  -------------------  --------------------
Microsoft.KubernetesConfiguration  Registered           RegistrationRequired
```

If the provider shows as *NotRegistered*, register the provider using the [az provider register](/en-us/cli/azure/provider#az-provider-register) as shown in the following example:

```azurecli
az provider register --namespace Microsoft.KubernetesConfiguration
```

### Register the `ExtensionTypes` feature to your Azure subscription

The `ExtensionTypes` feature needs to be registered to your Azure subscription. In the terminal, verify you're in the correct subscription:

```azurecli
az account set --subscription <your-azure-subscription-ID>
```

Register the `ExtensionTypes` feature.

```azurecli
az feature registration create --namespace Microsoft.KubernetesConfiguration --name ExtensionTypes
```

Feature registration might take some time. After a few minutes, check the registration status using the following command:

```azurecli
az feature show --namespace Microsoft.KubernetesConfiguration --name ExtensionTypes
```

## Create the extension and install Dapr on your AKS or Arc-enabled Kubernetes cluster

When installing the Dapr extension, use the flag value that corresponds to your cluster type:

- **AKS cluster**: `--cluster-type managedClusters`
- **Arc-enabled Kubernetes cluster**: `--cluster-type connectedClusters`

Note

If you're using Dapr OSS on your AKS cluster and would like to install the Dapr extension for AKS, see [Migrate from Dapr OSS to the Dapr extension](dapr-migration).

Create the Dapr extension, which installs Dapr on your AKS or Arc-enabled Kubernetes cluster.

For example, install the latest version of Dapr via the Dapr extension on your AKS cluster:

```azurecli
az k8s-extension create --cluster-type managedClusters \
--cluster-name <your-AKS-cluster> \
--resource-group <your-resource-group> \
--name dapr \
--extension-type Microsoft.Dapr \
--auto-upgrade-minor-version false
```

### Keep your managed AKS cluster updated to the latest version

Based on your environment (dev, test, or production), you can keep up-to-date with the latest stable Dapr versions.

#### Choose a release train

When configuring the extension, you can choose to install Dapr from a particular release train. Specify one of the two release train values:

| Value | Description |
| --- | --- |
| `stable` | Default. |
| `dev` | Early releases that can contain experimental features. Not suitable for production. |

For example:

```azurecli
--release-train stable
```

#### Configure automatic updates to Dapr control plane

Warning

Auto-upgrade isn't suitable for production environments. Only enable automatic updates to the Dapr control plane in dev or test environments. Learn how to manually upgrade to the latest Dapr version for production environments.

If you install Dapr without specifying a version, `--auto-upgrade-minor-version`*is automatically enabled*, which configures the Dapr control plane to automatically update its minor version on new releases.

You can disable auto-update by specifying the `--auto-upgrade-minor-version` parameter and setting the value to `false`.

Dapr versioning is in [`MAJOR.MINOR.PATCH` format](https://docs.dapr.io/operations/support/support-versioning/#versioning), which means `1.11.0` to `1.12.0` is a *minor* version upgrade.

```azurecli
--auto-upgrade-minor-version true
```

#### View the latest stable Dapr versions available

To upgrade to the latest Dapr version in a production environment, you need to manually upgrade. Start by viewing a list of the stable Dapr versions available to your managed AKS cluster. Run the following command:

```azurecli
az k8s-extension extension-types list-versions-by-cluster --resource-group <your-resource-group> --cluster-name <your-AKS-cluster> --cluster-type managedClusters --extension-type microsoft.dapr --release-train stable
```

To see the latest stable Dapr version available to your managed AKS cluster, run the following command:

```azurecli
az k8s-extension extension-types list-versions-by-cluster --resource-group <your-resource-group> --cluster-name <your-AKS-cluster> --cluster-type managedClusters --extension-type microsoft.dapr  --release-train stable --show-latest
```

To view a list of the stable Dapr versions available *by location*:

1. Make sure you've [registered the `ExtensionTypes` feature to your Azure subscription](dapr#register-the-extensiontypes-feature-to-your-azure-subscription).
2. Run the following command.

```azurecli
az k8s-extension extension-types list-versions-by-location --location westus --extension-type microsoft.dapr
```

#### Target a specific Dapr version

Next, manually update Dapr to the latest stable version.

Note

Dapr is supported with a rolling window, including only the current and previous versions. It is your operational responsibility to remain up to date with these supported versions. If you have an older version of Dapr, you might need to do intermediate upgrades to get to a supported version.

The same command-line argument is used for installing a specific version of Dapr or rolling back to a previous version. Set `--auto-upgrade-minor-version` to `false` and `--version` to the version of Dapr you wish to install. If the `version` parameter is omitted, the extension installs the latest version of Dapr. The following example command installs Dapr version `1.14.4-msft.10` on your AKS cluster:

```azurecli
az k8s-extension create --cluster-type managedClusters \
--cluster-name <your-AKS-cluster> \
--resource-group <your-resource-group> \
--name dapr \
--extension-type Microsoft.Dapr \
--auto-upgrade-minor-version false \
--version 1.14.4-msft.10
```

# [Bicep](#tab/bicep)
## Before you begin

### Register the `KubernetesConfiguration` resource provider

If you aren't already using cluster extensions, you might need to register the resource provider with your subscription. You can check the status of the provider registration using the [az provider list](/en-us/cli/azure/provider#az-provider-list) command, as shown in the following example:

```azurecli
az provider list --query "[?contains(namespace,'Microsoft.KubernetesConfiguration')]" -o table
```

The *Microsoft.KubernetesConfiguration* provider should report as *Registered*, as shown in the following example output:

```output
Namespace                          RegistrationState    RegistrationPolicy
---------------------------------  -------------------  --------------------
Microsoft.KubernetesConfiguration  Registered           RegistrationRequired
```

If the provider shows as *NotRegistered*, register the provider using the [az provider register](/en-us/cli/azure/provider#az-provider-register) as shown in the following example:

```azurecli
az provider register --namespace Microsoft.KubernetesConfiguration
```

### Register the `ExtensionTypes` feature to your Azure subscription

The `ExtensionTypes` feature needs to be registered to your Azure subscription. In the terminal, verify you're in the correct subscription:

```azurecli
az account set --subscription <your-azure-subscription-ID>
```

Register the `ExtenstionTypes` feature.

```azurecli
az feature registration create --namespace Microsoft.KubernetesConfiguration --name ExtensionTypes
```

Feature registration might take some time. After a few minutes, check the registration status using the following command:

```azurecli
az feature show --namespace Microsoft.KubernetesConfiguration --name ExtensionTypes
```

## Deploy the Dapr extension on your AKS or Arc-enabled Kubernetes cluster

Create a Bicep template similar to the following example and deploy the Dapr extension to your existing cluster.

```bicep
@description('The name of the Managed Cluster resource.')
param clusterName string

resource existingManagedClusters 'Microsoft.ContainerService/managedClusters@2023-05-02-preview' existing = {
  name: clusterName
}

resource daprExtension 'Microsoft.KubernetesConfiguration/extensions@2022-11-01' = {
  name: 'dapr'
  scope: existingManagedClusters
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    autoUpgradeMinorVersion: true
    configurationProtectedSettings: {}
    configurationSettings: {
      'global.clusterType': 'managedclusters'
    }
    extensionType: 'microsoft.dapr'
    releaseTrain: 'stable'
    scope: {
      cluster: {
        releaseNamespace: 'dapr-system'
      }
    }
    version: '1.11.2'
  }
}
```

Set the following variables, changing the following values to your actual resource group and cluster names.

```azurecli
MY_RESOURCE_GROUP=<your-resource-group>
MY_AKS_CLUSTER=<your-AKS-cluster>
```

Deploy the Bicep template using the `az deployment group` command.

```azurecli
az deployment group create \
  --resource-group $MY_RESOURCE_GROUP \
  --template-file ./my-bicep-file-path.bicep \
  --parameters clusterName=$MY_AKS_CLUSTER
```

### Configure automatic updates to Dapr control plane

Warning

You can enable automatic updates to the Dapr control plane only in dev or test environments. Auto-upgrade isn't suitable for production environments.

If you deploy Dapr without specifying a version, `autoUpgradeMinorVersion`*is automatically enabled*, which configures the Dapr control plane to automatically update its minor version on new releases.

You can disable auto-update by specifying the `autoUpgradeMinorVersion` parameter and setting the value to `false`.

Dapr versioning is in [`MAJOR.MINOR.PATCH` format](https://docs.dapr.io/operations/support/support-versioning/#versioning), which means `1.11.0` to `1.12.0` is a *minor* version upgrade.

```bicep
properties {
  autoUpgradeMinorVersion: true
}
```

### Target a specific Dapr version

Note

Dapr is supported with a rolling window, including only the current and previous versions. It is your operational responsibility to remain up to date with these supported versions. If you have an older version of Dapr, you might need to do intermediate upgrades to get to a supported version.

Set `autoUpgradeMinorVersion` to `false` and `version` to the version of Dapr you wish to install. If the `autoUpgradeMinorVersion` parameter is set to `true`, and `version` parameter is omitted, the extension installs the latest version of Dapr.

For example, to use Dapr 1.11.2:

```bicep
properties: {
  autoUpgradeMinorVersion: false
  version: '1.11.2'
}
```

### Choose a release train

When configuring the extension, you can choose to install Dapr from a particular release train. Specify one of the two release train values:

| Value | Description |
| --- | --- |
| `stable` | Default. |
| `dev` | Early releases that can contain experimental features. Not suitable for production. |

For example:

```bicep
properties: {
  releaseTrain: 'stable'
}
```

---

## Troubleshooting

### Troubleshoot extension management errors

If the extension fails to create or update, try suggestions and solutions in the [Dapr extension troubleshooting guide](/en-us/troubleshoot/azure/azure-kubernetes/extensions/troubleshoot-dapr-extension-installation-errors).

### Troubleshoot Dapr functional errors

Troubleshoot Dapr open-source errors unrelated to the extension by viewing the [common Dapr issues and solutions guide](https://docs.dapr.io/operations/troubleshooting/common_issues/).

## Support

Note

Learn more about [how Microsoft handles issues raised for the Dapr extension](dapr-overview#issue-handling).

If you're experiencing Dapr runtime security risks and regressions while using the extension, open an issue with the [Dapr open source project](https://github.com/dapr/dapr/issues/new/choose).

You could also start a discussion in the Dapr project Discord:

- [Dapr runtime](https://discord.com/channels/778680217417809931/778684372475707416)
- [Dapr components](https://discord.com/channels/778680217417809931/781589820128493598)

## Delete the Dapr extension from your cluster

The process of uninstalling the Dapr extension from AKS doesn't delete the custom resource definitions (CRDs) created during installation. These CRDs remain in the cluster as residual components, essential for the reconciler during the installation and uninstallation of the extension.

To clean the cluster of these CRDs, you can manually delete them *after* the Dapr extension is completely uninstalled from AKS.

### Uninstall the extension

Delete the extension from your AKS cluster by using the following command:

```azurecli
az k8s-extension delete --resource-group <your-resource-group> --cluster-name <your-AKS-cluster> --cluster-type managedClusters --name dapr
```

Or, if using a Bicep template, you can delete the template.

### List the CRDs in your cluster

To find the CRDs you'd like to remove, run the following command:

```powershell
kubectl get crds | findstr dapr.io
```