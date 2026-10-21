---
layout: Conceptual
title: Stop and restart a cluster | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/stop-start-cluster
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
description: Learn how to stop and restart a cluster in AKS on Windows Server.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-01-14T00:00:00.0000000Z
ms.reviewer: EkeleAsonye
ms.custom: windows-server
locale: en-us
document_id: 6057ec94-93a6-c03f-3208-dea2d6c9ebbb
document_version_independent_id: 0fd94d55-1302-7c43-ca3c-083376d274f0
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/stop-start-cluster.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/stop-start-cluster
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/stop-start-cluster.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
platformId: f8655554-c251-f368-609a-a6ec47663489
---

# Stop and restart a cluster | Microsoft Learn

> 
> Applies to: AKS on Windows Server

In AKS on Windows Server, your workloads might not need to run continuously. To save resource costs, you can stop (or shut down) your Azure Kubernetes Service (AKS) cluster. To stop a cluster, run the commands described in this article from your Hyper-V host to power down the different components. This article also describes how to restart a stopped cluster, and how to verify that the control plane nodes are running after a restart.

## Before you begin

This article assumes you have an existing Kubernetes cluster installed and configured on your machine. If you need to install a cluster, see the AKS quickstart to [set up an AKS host and deploy a workload cluster](kubernetes-walkthrough-powershell).

## Stop a cluster

To stop (or shut down) a cluster, you must stop the cluster service and then stop the local and/or remote computers.

### Stop the cluster service

Use the [Stop-Cluster](/en-us/powershell/module/failoverclusters/stop-cluster?view=windowsserver2019-ps&amp;preserve-view=true) PowerShell command to shut down a cluster and stop the cluster service on all nodes in the cluster. Running this command stops all services and applications configured in the cluster.

Important

When you run `Stop-Cluster`, all other nodes and VM-based applications in the cluster are affected.

To stop the cluster service on all nodes of the local cluster, open PowerShell as an administrator and run the following command on one of the machines in the cluster:

```powershell
Stop-Cluster 
```

After you run the command, type **Y (Yes)** to confirm that you want to stop the cluster.

Note

If you run `Stop-Cluster` twice on the same machine, or on more than one machine in the cluster, you receive a message that says "No cluster service running."

### Stop local and remote computers

To shut down the local and remote computers, use the [Stop-Computer](/en-us/powershell/module/microsoft.powershell.management/stop-computer?view=powershell-7.1&amp;preserve-view=true) PowerShell command:

```powershell
Stop-Computer 
```

## Start a cluster

To restart a stopped cluster, you first restart the operating system on the local and/or remote computers, and then restart the cluster.

To restart the operating system on your local and remote computers, use the following [Restart-Computer](/en-us/powershell/module/microsoft.powershell.management/restart-computer?view=powershell-7.1&amp;preserve-view=true) PowerShell command:

```powershell
Restart-Computer 
```

To restart all the nodes of the cluster, use the [Start-Cluster](/en-us/powershell/module/failoverclusters/start-cluster?view=windowsserver2019-ps&amp;preserve-view=true) PowerShell command:

```powershell
Start-Cluster 
```

A node can only function as part of a cluster when the cluster service is running.

Note

You cannot remotely run `Start-Cluster` without CredSSP authentication on the server machine.

To verify that your cluster started, use the [Get-ClusterNode](/en-us/powershell/module/failoverclusters/get-clusternode?view=windowsserver2019-ps&amp;preserve-view=true) PowerShell command as shown in the following example:

```powershell
Get-ClusterNode -ErrorAction SilentlyContinue | foreach-object { 
   $node = $_.Name 
   $state = $_.State 
   Write-Host "$node State = $state" 
   } 
```

The output is similar to the following list of cluster nodes:

```output
TK5-3WP15R1625 State = Up
TK5-3WP15R1627 State = Up
TK5-3WP15R1629 State = Up
TK5-3WP15R1631 State = Up
```

## Verify the control plane nodes are running

To verify that the control plane nodes are running, enumerate the VMs, and make sure their state is **running**.

To view the status of your control plane VM from your Hyper-V host, run the following PowerShell command on a physical machine that contains the management cluster control plane VM:

```powershell
$controlPlanes = Get-VM | ? { $_.Name -like '*-control-plane-*' -and $_.State -eq 'Running' } | % { $_.Name } 
```

The example output is shown here. If you run this command on a machine other than the one with the control plane VM, you receive a null output:

```output
c8bf39ad-67bd-4a7d-ac77-638be6eecf46-control-plane-0-d38498de
my-cluster-control-plane-q9mbp-ae97a3e5
```

If the control plane node isn't running, restart the VM by running the following PowerShell command:

```powershell
Restart-VM -name $vmName -force 
```