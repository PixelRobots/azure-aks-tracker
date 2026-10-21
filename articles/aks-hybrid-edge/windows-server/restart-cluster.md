---
layout: Conceptual
title: Restart, remove, or reinstall Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/restart-cluster
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
description: Learn how to restart, remove, or reinstall AKS on Windows Server.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.custom: windows-server
locale: en-us
document_id: 4db0db9e-88f5-dece-c6b0-3e3db68d84f7
document_version_independent_id: 80e91b8d-1520-d58c-446c-033621f6dcaa
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/restart-cluster.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/restart-cluster
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/restart-cluster.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 6247c475-be46-e608-8095-2a429b5cbc3e
---

# Restart, remove, or reinstall Azure Kubernetes Service | Microsoft Learn

> 
> Applies to: AKS on Windows Server

After you deploy AKS, you can restart, remove, or reinstall your deployment if necessary.

## Restart AKS

Restarting AKS removes all of your Kubernetes clusters (if any) and the Azure Kubernetes Service host. The restart process also uninstalls the AKS agents and services from the nodes. Then, it repeats the original install process steps until the host is recreated. The AKS configuration that you configured via [Set-AksHciConfig](/en-us/azure/aks/aksarc/reference/ps/set-akshciconfig) and the downloaded VHDX images are preserved. The `Set-AksHciConfig` command removes the current VMs and creates new ones.

To restart AKS with the same configuration settings, run the following command:

```powershell
Restart-AksHci
```

## Remove AKS

To remove AKS, run the following [Uninstall-AksHci](/en-us/azure/aks/aksarc/reference/ps/uninstall-akshci) command. This command removes the old configuration, and you must run [Set-AksHciConfig](/en-us/azure/aks/aksarc/reference/ps/set-akshciconfig) again when you reinstall.

If your clusters are Arc-enabled, delete any Azure resources before proceeding. To delete any associated Arc resources for your on-premises cluster, follow the guidance for [cleaning up Azure Arc resources](/en-us/azure/azure-arc/kubernetes/quickstart-connect-cluster#clean-up-resources).

```powershell
Uninstall-AksHci
```

If you want to retain the old configuration, run the following command:

```powershell
Uninstall-AksHci -SkipConfigCleanup
```

## Reinstall configuration settings and AKS

To reinstall AKS after uninstalling it, follow these instructions.

If you ran the `Uninstall-AksHci` command with the `-SkipConfigCleanup` parameters, your old configuration settings were retained. To reinstall, run the following command:

```powershell
Install-AksHci
```

If you didn't use the `-SkipConfigCleanup` parameter when uninstalling, then you must reset your configuration settings with the following commands. This example command creates a virtual network with a static IP address. If you want to configure your AKS deployment with DHCP, see [new-akshcinetworksetting](/en-us/azure/aks/aksarc/reference/ps/new-akshcinetworksetting) for examples of how to configure DHCP:

```powershell
# static IP
$vnet = New-AksHciNetworkSetting -name myvnet -vswitchName "extSwitch" -k8sNodeIpPoolStart "172.16.10.0" -k8sNodeIpPoolEnd "172.16.10.255" -vipPoolStart "172.16.255.0" -vipPoolEnd
"172.16.255.254" -ipAddressPrefix "172.16.0.0/16" -gateway "172.16.0.1" -dnsServers "172.16.0.1"

Set-AksHciConfig -imageDir c:\clusterstorage\volume1\Images -workingDir c:\ClusterStorage\Volume1\ImageStore -cloudConfigLocation c:\clusterstorage\volume1\Config -vnet $vnet -cloudservicecidr "172.16.10.10/16"

Install-AksHci
```