---
layout: Conceptual
title: Create and use a custom load balancer with Azure Kubernetes Service on Windows Server | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/configure-custom-load-balancer
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
description: Learn how to create and use a custom load balancer with Azure Kubernetes Service on Windows Server.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-01-14T00:00:00.0000000Z
ms.reviewer: rbaziwane
ms.custom: windows-server
locale: en-us
document_id: d0ca5318-bc3d-d590-b7ff-d565642b4edc
document_version_independent_id: 87824728-919e-4a0d-5b73-81b780abdfb6
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/configure-custom-load-balancer.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/configure-custom-load-balancer
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/configure-custom-load-balancer.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f98c9a19-e481-4f15-8047-76b641e6ed57
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f5685781-a4fd-40f1-8126-59abde4643bf
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 74cf3580-61a8-8728-e6ea-29d0cb83bff4
---

# Create and use a custom load balancer with Azure Kubernetes Service on Windows Server | Microsoft Learn

> 
> Applies to: AKS on Windows Server

This article describes how to create and use a custom load balancer. In Azure Kubernetes Service (AKS) on Windows Server, you can use load balancers to send requests to the Kubernetes API server and to manage traffic to application services. When you use a custom load balancer, [kube-vip](https://kube-vip.io/) automatically deploys to manage the load balancing of requests to the Kubernetes API server and to make sure that it's highly available.

Note

You can also use a other load balancers, such as MetalLB or Software Defined Networking (SDN) load balancing, to load balance traffic to application services.

## Before you begin

You must install [AKS on Windows Server](kubernetes-walkthrough-powershell) and provide a range of virtual IP addresses for the load balancer during the network configuration step during installation.

## Configure a custom load balancer

Warning

If you choose to deploy your own load balancer, the Kubernetes cluster becomes unreachable after installation. If you deploy any services with `type=LoadBalancer`, the services are also unreachable until you configure your load balancer.

This configuration assumes you want to use a custom load balancer in your cluster. In this case, the workload cluster is deployed without a load balancer:

1. Create a load balancer configuration using the [New-AksHciLoadBalancerSetting](/en-us/azure/aks/aksarc/reference/ps/new-akshciloadbalancersetting) cmdlet and then select `none` for the `loadBalancerSku` parameter:

    ```powershell
    $lbCfg=New-AksHciLoadBalancerSetting -name "myLb" -loadBalancerSku "none" 
    ```
2. Deploy a workload cluster without providing the load balancer configuration using the following command:

    ```powershell
    New-AksHciCluster -name "summertime" -nodePoolName mynodepool -nodeCount 2 -OSType linux -nodeVmSize Standard_A4_v2 -loadBalancerSettings $lbCfg 
    ```
3. Use [Get-AksHciCluster](/en-us/azure/aks/aksarc/reference/ps/get-akshcicluster) to verify that the cluster is successfully deployed with the control plane nodes running `kube-vip` and that the API server requests are reachable.
4. Manually configure your load balancer.

If you run an upgrade, the load balancer configuration (`loadBalancerSku` and `count`) you defined during installation remains the same after the upgrade completes. However, if you want to update `loadBalancerSku` during an upgrade, you must redeploy your workload clusters. If you have existing clusters running a HAProxy-based load balancer, you can continue running your workloads. The upgrade then completes successfully.

Important

If you change from using a custom load balancer to using the default load balancer, you're required to redeploy your workload cluster with the new load balancer configuration. For information about how to configure the default load balancer, see [Configure load balancer](configure-load-balancer).