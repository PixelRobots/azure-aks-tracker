---
layout: Conceptual
title: Uninstall AKS Edge Essentials | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/edge-essentials/aks-edge-howto-uninstall
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
description: Learn how to uninstall AKS Edge Essentials.
author: davidsmatlak
ms.author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.custom: edge-essentials - template-how-to - devx-track-azurecli
locale: en-us
document_id: 8769c362-16c1-0647-33df-cb2103d004a2
document_version_independent_id: 9ccd773d-2028-5943-2887-f8d92a6f1333
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/edge-essentials/aks-edge-howto-uninstall.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/edge-essentials/aks-edge-howto-uninstall
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/edge-essentials/aks-edge-howto-uninstall.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/c21d0a62-47cf-4452-bd24-e1ed14abbeda
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f43eaf81-15c1-41e2-95b2-89fb1560c563
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
platformId: 1e882150-b242-9f42-22f9-4aa6726fc02f
---

# Uninstall AKS Edge Essentials | Microsoft Learn

This article describes how to uninstall AKS Edge Essentials.

## Disconnect from Azure Arc

If you used `Connect-AideArcKubernetes` to connect to Azure Arc, run `Disconnect-AideArcKubernetes` to disconnect your cluster from Azure Arc. For a complete cleanup, delete the service principal and resource group you created for this example:

```powershell
Disconnect-AideArcKubernetes
```

Run `Disconnect-AksEdgeArc` to disconnect your cluster from Azure Arc:

```powershell
Disconnect-AksEdgeArc -JsonConfigFilePath .\aksedge-config.json
```

You can also manually remove the cluster from Arc using the Azure portal and delete the Arc pods in the cluster.

## Remove your application from cluster

Delete the applications that you deployed using the following command:

```powershell
kubectl delete -f ./path-to-your-YAML-file/app.yaml
```

For example, if you deployed the sample Linux application, you can delete it using:

```powershell
kubectl delete -f linux-sample.yaml
```

## Remove nodes on a single-machine cluster

To remove the Windows node only, issue the following command:

```powershell
Remove-AksEdgeNode -nodeType Windows
```

To remove your single machine cluster with a `Linux` or `LinuxandWindows` workload, run:

```powershell
Remove-AksEdgeDeployment

# or run
Remove-AksEdgeDeployment -Force #to force removal of all clusters.
```

You can't remove the Linux node alone in this configuration; you must remove the deployment if you need to remove the Linux node.

Note

If your single-machine cluster doesn't clean up properly, run `hnsdiag list networks`, then delete any existing AKS Edge Essentials network objects using `hnsdiag delete networks <ID>`.

Note

There is a known issue in which repeatedly creating a new deployment and removing the node might result in an "error during ConnectToVirtualMachine." If this occurs, reboot your system to resolve the error.

## Remove nodes on a multi-machine cluster

Be careful when removing control plane nodes. Make sure you have another working control plane node before doing so.

To remove a Windows-only node:

```powershell
Remove-AksEdgeNode -NodeType Windows
```

To remove a Linux-only node:

```powershell
Remove-AksEdgeNode -NodeType Linux
```

During the removal of a control plane node from a cluster, it's important for the cluster administrator to verify that the cluster has completed reconciliation and that the removed node no longer serves as the leader.

You can verify this by running `kubectl get leases -A` and checking until the removed node is no longer a lease holder in the output. This is vital for maintaining cluster stability.

To remove both nodes:

```powershell
Remove-AksEdgeDeployment
```

Note

There is a known issue in which repeatedly creating a new deployment and removing the node can result in an error. If this occurs, reboot your system to resolve the error.

## Uninstall AKS Edge Essentials

On your machine, go to **Settings &gt; Apps &gt; Apps & Features**. Alternatively, you can go to **Control Panel &gt; Uninstall a Program**. From there, look for **Azure Kubernetes Service Edge Essentials (Public Preview)**. Select **Uninstall**.

Note

You might want to reboot your machine right after the uninstall so that all resources are cleaned up, and your machine is ready for a new installation.

If you encounter any issues uninstalling AKS Edge Essentials, try downloading [this troubleshooting tool](https://support.microsoft.com/topic/fix-problems-that-block-programs-from-being-installed-or-removed-cca7d1b6-65a9-3d98-426b-e9f927e1eb4d) to uninstall.

## Uninstall Azure CLI

See [Uninstall Azure CLI](/en-us/cli/azure/install-azure-cli-windows#uninstall).

## Uninstall Az PowerShell

See [How to uninstall Azure PowerShell modules](/en-us/powershell/azure/uninstall-az-ps).