---
layout: Conceptual
title: Use multiple load balancers | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/multiple-load-balancers
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
description: How to use multiple load balancer instances and scale the numbers of instances on your AKS deployment in AKS on Windows Server.
author: davidsmatlak
ms.author: davidsmatlak
ms.date: 2026-09-01T00:00:00.0000000Z
ms.reviewer: rbaziwane
ms.lastreviewed: 2022-07-29T00:00:00.0000000Z
ms.topic: how-to
ms.custom: windows-server
locale: en-us
document_id: 20d6cc57-acf6-0cb4-60de-b4c8f216eb51
document_version_independent_id: 4ee2dd55-007e-f0e1-1805-4b1d4368d880
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/multiple-load-balancers.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/multiple-load-balancers
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/multiple-load-balancers.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f98c9a19-e481-4f15-8047-76b641e6ed57
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f5685781-a4fd-40f1-8126-59abde4643bf
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
platformId: 34cfe2fb-bf77-771f-6679-cb1ff73dd65a
---

# Use multiple load balancers | Microsoft Learn

> 
> Applies to: AKS on Windows Server

This article describes how to deploy one or more instances of the **HAProxy** load balancer in AKS on Windows Server, and how to scale the load balancer configuration in the target cluster.

In AKS on Windows Server, the load balancer is deployed as a virtual machine (VM) running Linux and **HAProxy + KeepAlive** to provide load balanced services for the workload clusters. This VM is used to load balance requests to the Kubernetes API server and for handling traffic to application services.

You can also use a custom load balancer with AKS. For more information, see [Create and use a custom load balancer](configure-custom-load-balancer).

## Before you begin

- Install [AKS](kubernetes-walkthrough-powershell), and provide a range of virtual IP addresses for the load balancer during the network configuration step.
- Make sure you have enough memory and storage to create a new virtual machine and have virtual IP addresses to assign to application services.

## Deploy multiple load balancer instances

To deploy multiple load balancers during the workload cluster creation, use the `New-AksHciLoadBalancerSetting` cmdlet to set the `VmSize`; the number of instances for your **HAProxy** load balancer as follows:

1. Create a load balancer configuration using the [New-AksHciLoadBalancerSetting](/en-us/azure/aks/aksarc/reference/ps/new-akshciloadbalancersetting) cmdlet, and then select `HAProxy` for the `loadBalancerSku` parameter:

    ```powershell
    $lbcfg = New-AksHciLoadBalancerSetting -name "haProxyLB" -loadBalancerSku HAProxy -vmSize Standard_K8S3_v1 -loadBalancerCount 3
    ```
2. Deploy a workload cluster by providing the load balancer configuration using the following command:

    ```powershell
    New-AksHciCluster -name "holidays" -nodePoolName "thanksgiving" -nodeCount 2 -OSType linux -nodeVmSize Standard_A4_v2 -loadBalancerSettings $lbCfg
    ```
3. Verify that a new workload cluster is created with a load balancer deployed as a virtual machine running **HAProxy** to manage traffic for your applications.

## Scale out the load balancer instances

Important

Make sure you have enough physical memory and storage in your cluster before you perform this operation. If the amount of physical memory required to deploy the requested number of load balancers is insufficient, this operation will fail.

To scale your load balancer instances out (or in) after deployment of a workload cluster, follow these steps:

1. Run `Set-AksHciLoadBalancer` with the number of instances you want to deploy in the cluster

    ```powershell
    Set-AksHciLoadBalancer -clusterName "holidays" -loadBalancerCount 5
    ```
2. Verify that the exact number of load balancer instances are created and that Kubernetes services are reachable.