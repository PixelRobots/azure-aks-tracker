---
layout: Conceptual
title: Deploy extension for MetalLB for Azure Arc enabled Kubernetes using the Azure portal | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/deploy-load-balancer-portal
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
description: Learn how to deploy extension for MetalLB for Azure Arc enabled Kubernetes using the Azure portal
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
author: davidsmatlak
ms.author: davidsmatlak
ms.reviewer: srikantsarwa
ms.lastreviewed: 2024-04-02T00:00:00.0000000Z
ms.custom: hyperconverged
locale: en-us
document_id: cdfc9dca-d235-0911-b3fe-4706639ce2ed
document_version_independent_id: cb81a371-13dd-3c1e-3a57-1a23b28f249c
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/deploy-load-balancer-portal.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/deploy-load-balancer-portal
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/deploy-load-balancer-portal.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f98c9a19-e481-4f15-8047-76b641e6ed57
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f5685781-a4fd-40f1-8126-59abde4643bf
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
platformId: 969c50b3-a746-f671-0243-632accd3de5e
---

# Deploy extension for MetalLB for Azure Arc enabled Kubernetes using the Azure portal | Microsoft Learn

> 
> Applies to: AKS on Azure Local

The main purpose of a load balancer is to distribute traffic across multiple nodes in a Kubernetes cluster. This can help prevent downtime and improve overall performance of applications. AKS Hybrid and Edge supports creating a [MetalLB](https://metallb.universe.tf/) load balancer instance on your Kubernetes cluster using the **MetalLB extension for Azure Arc enabled Kubernetes**.

## Prerequisites

- An Azure Arc enabled Kubernetes cluster with at least one Linux node. You can create a Kubernetes cluster on Azure Local using the [Azure CLI](../aks-create-clusters-cli) or the [Azure portal](../aks-create-clusters-portal). AKS on Azure Local clusters are Arc enabled by default.
- Make sure you have enough IP addresses for the load balancer. For AKS on Azure Local, ensure that the IP addresses reserved for the load balancer don't conflict with the IP addresses in Arc VM logical networks and control plane IPs. For more information about IP address planning and networking in Kubernetes, see [Networking requirements for Kubernetes](network-system-requirements) and [IP address planning for Kubernetes](aks-hci-ip-address-planning).
- This how-to guide assumes you understand how MetalLB works. For more information, see the [overview for MetalLB for Kubernetes](load-balancer-overview).

## Deploy MetalLB load balancer using the Azure Arc extension

Warning

IP address conflict checking is not currently supported. It's recommended that you perform this check when you create load balancers.

Once you successfully create your Kubernetes cluster, navigate to the **Networking** blade in the Azure portal and select **Install**:

[![Screenshot showing extension install screen on portal.](../../media/deploy-load-balancer-portal/install-extension.png)](../../media/deploy-load-balancer-portal/install-extension.png#lightbox)

After the extension is successfully installed, you can create a load balancer service. Select **Add** and fill in the load balancer name and its IP range. The **Service Selector** field is optional. Then select **OK**.

[![Screenshot showing create load balancer on portal.](../../media/deploy-load-balancer-portal/create-load-balancer.png)](../../media/deploy-load-balancer-portal/create-load-balancer.png#lightbox)

- The IP range should be set to available IPs depending on your environment. The IP range should be in CIDR notation; for example, **192.168.50.51/28** or **192.168.50.1-192.168.50.100**. Multiple IP ranges must be separated by commas.
- The advertise mode can be **ARP**, **BGP**, or **Both**. If you use **BGP** or **Both**, you must configure BGP peers.
- **Service Selector** limits the set of services that can get an IP from the load balancer. The default option (null or empty string) means that the load balancer applies for all services. **Selector** should be in a format of a list of key-value pairs such as **a:b,c:d**, where the key-value pairs are separated by a comma.

Once the load balancer is successfully created, it's shown in the list as follows. **Provisioning state** shows the operation result:

[![Screenshot showing provisioning state on portal.](../../media/deploy-load-balancer-portal/load-balancer-created.png)](../../media/deploy-load-balancer-portal/load-balancer-created.png#lightbox)

### Clean up resources

To clean up resources, do the following:

- When one of the load balancers is no longer needed, select the start of the row for the load balancer and select **Delete**. Then select **Yes**.
- When the load balancer service is no longer needed, delete all existing load balancers and then select **Uninstall**. Select **Yes** to uninstall the MetalLB extension.