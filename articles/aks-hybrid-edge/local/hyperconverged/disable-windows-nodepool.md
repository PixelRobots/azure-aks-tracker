---
layout: Conceptual
title: Disable the Windows node pool feature | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/disable-windows-nodepool
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
learn_banner_products:
- azure
ms.service: azure-kubernetes-service-hybrid
description: Learn how to disable the Windows node pool feature on the 2509 release and earlier.
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
author: davidsmatlak
ms.author: davidsmatlak
ms.lastreviewed: 2025-09-25T00:00:00.0000000Z
ms.custom: hyperconverged
locale: en-us
document_id: 9d5049c5-8eeb-32b6-9891-f953c895fc0f
document_version_independent_id: d87547fc-b442-442c-ba05-10fe0abad217
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/disable-windows-nodepool.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/disable-windows-nodepool
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/disable-windows-nodepool.md
platformId: 54985a83-8510-3896-dad7-9391b8123864
---

# Disable the Windows node pool feature | Microsoft Learn

&gt; Applies to: AKS on Azure Local version 2508 and earlier

The Windows node pool feature is disabled by default in Azure Local release 2509 and later. If you are using Azure Local version 2508 or earlier, you can follow the steps in this article to disable the Windows node pool feature. For versions 2509 and later, see [Enable the Windows node pool feature](howto-enable-windows-node-pools).

This article describes how to disable the Windows node pool feature for Azure Kubernetes Service (AKS) on Azure Local versions 2508 and earlier. You can disable this feature to prevent the automatic download of Windows Virtual Hard Disks (VHDs), which are approximately 20 GB in size, and are required for creating Windows-based node pools. By doing so, enterprises with limited internet bandwidth can avoid unnecessary downloads, especially if their workloads are exclusively using Linux containers. This helps optimize bandwidth usage and simplifies resource management for environments where Windows nodes aren't needed.

## Before you begin

Before you begin, make sure you have the following prerequisites in place:

- **Azure Local deployed**. This article is only applicable if you already deployed Azure Local (release 2508 or earlier). You can't run the commands in this article before you deploy Azure Local. We currently don't support the ability to make this change before the initial Azure Local deployment.
- **Azure RBAC permissions to update Azure Local configuration**. Make sure you have the following roles. For more information, see [required permissions for deployment](/en-us/azure/azure-local/deploy/deployment-arc-register-server-permissions?tabs=powershell#assign-required-permissions-for-deployment):
    - Azure Local Administrator
    - Reader
- **Custom Location**. The name of the custom location. The custom location is configured during the Azure Local deployment. If you're in the Azure portal, go to the **Overview &gt; Server** page in the Azure Local system resource. You should see a custom location for your cluster.
- **Azure resource group**. The Azure resource group in which Azure Local is deployed.

## Recommended option: disable Windows node pool from an Azure CloudShell session

To help simplify configuration, the following steps define environment variables that are referenced in this article. Remember to replace the values shown with your own values.

Set the custom location and the resource group values in environment variables:

```azurecli
$customlocationName = <The custom location name for Azure Local>
$resourceGroup = <The Azure resource group in which Azure Local is deployed>
```

Next, run the following command to obtain the `clusterName` parameter. This parameter is the name of the Arc Resource Bridge that you deployed on Azure Local:

```azurecli
az customlocation show -n $customlocationName -g $resourceGroup --query hostResourceId
```

Expected output:

```output
/subscriptions/f3dwer-00000-4383-2345-00000/resourceGroups/SanJose/providers/Microsoft.ResourceConnector/appliances/sanjose-arcbridge
```

In this output, `sanjose-arcbridge` is the name of the Arc resource bridge you deployed on the Azure local cluster. This name is different for your deployment.

```azurecli
$clusterName = <Name of Arc resource bridge deployed on the Azure Local cluster>
```

Next, obtain the name of the AKS extension you deployed to the custom location. To get this name, run the following command to list the extensions installed on the custom location:

```azurecli
az customlocation show -n $customlocationID -g $resourceGroup --query clusterExtensionIds -o tsv
```

Expected output:

```output
/subscriptions/fbaf508b-cb61-4383-9cda-a42bfa0c7bc9/resourceGroups/SanJose/providers/Microsoft.ResourceConnector/appliances/sanjose-arcbridge/providers/Microsoft.KubernetesConfiguration/extensions/hybridaksextension
/subscriptions/fbaf508b-cb61-4383-9cda-a42bfa0c7bc9/resourceGroups/SanJose/providers/Microsoft.ResourceConnector/appliances/sanjose-arcbridge/providers/Microsoft.KubernetesConfiguration/extensions/vmss-hci
```

You should have two extensions installed on your custom location: AKS and Arc VM management. Copy the extension name for AKS into an environment variable. In the example output, the extension name is `hybridaksextension`. It might be different from what you see:

```azurecli
$extensionName = <Name of AKS Arc extension you deployed on the custom location>
```

After you have the extension name, create variables for the following parameters, and then disable the Windows node pool feature:

```azurecli
$extensionVersion = "$(az k8s-extension show -n $extensionName  -g $resourceGroup -c $clusterName --cluster-type appliances --query version -o tsv)"
$releaseTrain = "$(az k8s-extension show -n $extensionName -g $resourceGroup -c $clusterName --cluster-type appliances --query releaseTrain -o tsv)"
az k8s-extension update --resource-group $resourceGroup --cluster-name $clusterName --cluster-type appliances --name $extensionName --version $extensionVersion --release-train $releaseTrain --config disable-windows-nodepool=true --yes
```

## Alternate option: disable Windows node pool after connecting to an Azure Local physical node via Remote Desktop

If for some reason you're not able to use Azure CloudShell or a machine with connectivity to Azure in order to disable the Windows node pool, you can disable the Windows node pool after connecting to any one of the Azure Local physical nodes with Remote Desktop. You must first sign in to Azure.

```powershell
az login --use-device-code --tenant <Azure tenant ID>
az account set -s <subscription ID>
$res=get-archcimgmt

az k8s-extension update --resource-group $res.HybridaksExtension.resourceGroup --cluster-name $res.ResourceBridge.name --cluster-type appliances --name $res.HybridaksExtension.name --version $res.HybridaksExtension.version --release-train  $res.HybridaksExtension.releaseTrain --config disable-windows-nodepool=true --yes
```

### Validate if the Windows node pool feature is disabled

You can check if the configuration settings were applied by running `az k8s-extension show`, as follows:

```azurecli
az k8s-extension show --name $extensionName --resource-group $resourceGroup --cluster-name $clusterName --cluster-type appliances --query configurationSettings
```

Expected output:

```output
...
"disable-windows-nodepool": "true",
...
```

Next, check if Windows node pools were disabled by running the following command:

```azurecli
az aksarc get-versions --resource-group $resourceGroup --custom-location $customlocationName
```

The output for `osType=Windows` should say "Windows node pool feature is disabled" and the `ready` state should be `false`, for each Kubernetes version option:

```output
...
"1.27.7": {
            "readiness": [
              {
                "errorMessage": null,
                "osSku": "CBLMariner",
                "osType": "Linux",
                "ready": true
              },
              {
                "errorMessage": "Windows node pool feature is disabled",
                "osSku": "Windows2019",
                "osType": "Windows",
                "ready": false
              },
              {
                "errorMessage": "Windows node pool feature is disabled",
                "osSku": "Windows2022",
                "osType": "Windows",
                "ready": false
              }
            ],
...
```

## FAQ

### What happens if I try disabling Windows node pools and Windows node pools exist on at least 1 AKS cluster on the Azure local deployment?

Starting with [release 2509](../aks-whats-new-local#release-2509), the Windows node pool feature is disabled by default. This change improves the download experience by avoiding unnecessary downloads of the Windows VHD when it's not required.

If you have existing clusters created before this build that include Windows node pools, you can re-enable the feature as needed. However, if the feature remains disabled, cluster upgrades won't succeed while Windows node pools still exist. It's recommended that you delete all Windows node pools before upgrading Azure Local or AKS.

To ensure a smooth upgrade experience, either re-enable the Windows node pool feature if you plan to continue using Windows node pools, or remove all Windows node pools from your clusters.

### What happens to downloaded Windows VHDs if I disable Windows node pools?

The Windows VHDs that were previously downloaded are automatically deleted if the Windows node pools feature is disabled. You can verify if Windows VHDs were removed by checking the Azure Local storage paths. Deletion can take some time. Wait 30 minutes before checking. You must check all the storage paths, because Windows VHDs are assigned to storage paths in round-robin fashion, based on available storage capacity.