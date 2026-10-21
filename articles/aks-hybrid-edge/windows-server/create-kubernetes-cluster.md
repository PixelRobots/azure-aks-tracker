---
layout: Conceptual
title: Quickstart to create a local Kubernetes cluster using Windows Admin Center | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/create-kubernetes-cluster
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
description: Learn how to create a local Kubernetes cluster using Windows Admin Center
author: davidsmatlak
ms.topic: quickstart
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-01-14T00:00:00.0000000Z
ms.reviewer: dawhite
ms.custom: mode-portal, windows-server
locale: en-us
document_id: 4a508de0-9dcc-a592-4ce2-fbe7113cc338
document_version_independent_id: 7aa1343a-8db0-c94e-65a7-945bb5d14566
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/create-kubernetes-cluster.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/create-kubernetes-cluster
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/create-kubernetes-cluster.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/68e4b2d8-b70c-4019-b49a-d1f8881e2aea
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/67b2ba1a-6f74-4044-a48a-f0f8ad076b8f
platformId: fbf85151-aab5-59a9-4225-30ce2fc57e77
---

# Quickstart to create a local Kubernetes cluster using Windows Admin Center | Microsoft Learn

> 
> Applies to: AKS on Windows Server

After you set up your Azure Kubernetes Service (AKS) host, you can use Windows Admin Center to create a local Kubernetes cluster. To use PowerShell instead, see [Create a Kubernetes cluster with PowerShell](kubernetes-walkthrough-powershell).

Before you proceed to the **Create Kubernetes cluster** wizard, make sure you [set up Azure Kubernetes Service](setup) and check the [system requirements](system-requirements). You can access the wizard through the Azure Kubernetes Service host dashboard, as described in the next section.

## Create a local Kubernetes cluster in the AKS host dashboard

You can create a local Kubernetes cluster through the AKS host dashboard. You can find this dashboard in the AKS tool if you're connected to the system that has an AKS host deployed on it. Follow these steps and then proceed to the Use the Create Kubernetes cluster wizard section:

1. Connect to the system on which you want to create your Kubernetes cluster, and then navigate to the **Azure Kubernetes Service** tool. This system should already have an AKS host set up.
2. Select **Add cluster** under the **Kubernetes cluster** heading as shown in the following image:

    ![Screenshot showing the Azure Kubernetes Service tool dashboard.](../media/create-kubernetes-cluster/dashboard-kubernetes-wizard.png)

## Use the Create Kubernetes cluster wizard

This section describes how to use the Create Kubernetes cluster wizard through the Azure Kubernetes Service tool.

1. Review the prerequisites for the system that hosts the Kubernetes cluster and Windows Admin Center. When you're finished, select **Next**.
2. On the **Basics** page, configure information about your Kubernetes cluster. The Azure Kubernetes Service host field requires the fully qualified domain name of the Kubernetes cluster that you used during the [setup process](setup). You must complete the host setup for this system using the Azure Kubernetes Service tool. When you're finished, select **Next**.

    [![Screenshot showing Basics cluster creation pane.](../media/create-kubernetes-cluster/basics.png)](../media/create-kubernetes-cluster/basics.png#lightbox)
3. This step is mandatory. Configure node pools to run your workloads on the **Node pools** page. You can add any number of Windows node pools and Linux node pools. If you enabled Azure Arc integration earlier in this wizard, configure a Linux node pool with at least one Linux worker node. However, if you disabled Azure Arc integration earlier, then any node pool addition allows you to proceed to the next step. You can also set maximum pod counts and node taints when configuring node pools. Both of these settings are optional. For more information about the available taint settings, see [New-AksHciCluster](/en-us/azure/aks/aksarc/reference/ps/new-akshcicluster#new-aks-on-azure-local-cluster-with-a-linux-node-pool-and-taints).

    ![Screenshot that illustrates the Node pools page of the Kubernetes cluster wizard where you can configure maximum pod counts and taints.](../media/create-kubernetes-cluster/node-pool-added.png)

    When you're finished, select **Next**.
4. In the **Authentication** step, select whether you'd like to enable Microsoft Entra authentication. If you choose to enable this feature, you must provide information such as your API server service principal name, a Keytab file, and a cluster admin group or user name. When you're finished, select **Next**.
5. Specify your network configuration on the **Networking** page. You can either select an existing virtual network or create a new one by selecting **Add network interface**. If you select the **Flannel** container network interface (CNI), only Windows or hybrid clusters are supported. Once **Flannel** is set, it can't be changed, and the cluster won't support any network policy. If the **Calico** CNI is selected, it isn't needed to support Calico network policy, and Calico becomes the default option for your network policy under **Security**. When complete, select **Next: Review + Create**.

    The following image shows the static IP configuration settings:

    [![Screenshot showing the networking, static page of the Kubernetes cluster wizard.](../media/create-kubernetes-cluster/networking-static.png)](../media/create-kubernetes-cluster/networking-static.png#lightbox)

    The following image shows the DHCP configuration settings:

    [![Screenshot showing the networking, DHCP page of the Kubernetes cluster wizard.](../media/create-kubernetes-cluster/networking-dhcp.png)](../media/create-kubernetes-cluster/networking-dhcp.png#lightbox)
6. Review your selections on the **Review + create** page. When you're satisfied, select **Create** to begin deployment. Your deployment progress is shown at the top of this page.
7. When your deployment is complete, the **Next steps** page details how to manage your cluster. If you chose to disable the Azure Arc integration in the previous step, some of the information and instructions on this page might not be available or functional.

    [![Illustrates the successful completion of the Kubernetes cluster.](../media/create-kubernetes-cluster/deployment-complete.png)](../media/create-kubernetes-cluster/deployment-complete.png#lightbox)