---
layout: Conceptual
title: Quickstart to set up AKS on Windows Server using Windows Admin Center | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/setup
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
description: Learn how to set up AKS on Windows Server using Windows Admin Center
author: davidsmatlak
ms.topic: quickstart
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-03-16T00:00:00.0000000Z
ms.reviewer: dawhite
ms.custom: mode-portal, windows-server
locale: en-us
document_id: 22c667e4-5250-a639-6cd2-18163f6a9079
document_version_independent_id: 4491fba0-8f12-10a0-f902-426bf1e6d327
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/setup.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/setup
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/setup.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/68e4b2d8-b70c-4019-b49a-d1f8881e2aea
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/67b2ba1a-6f74-4044-a48a-f0f8ad076b8f
platformId: 69b98be7-5ea1-432b-b8d3-5f80378c12b7
---

# Quickstart to set up AKS on Windows Server using Windows Admin Center | Microsoft Learn

> 
> Applies to: AKS on Windows Server

In this quickstart, you set up AKS on Windows Server using Windows Admin Center. To use PowerShell instead, see [Set up with PowerShell](kubernetes-walkthrough-powershell).

Setup involves the following tasks:

- Set up Windows Admin Center.
- Set up an Azure Kubernetes Service host on the system to which you want to deploy the Kubernetes cluster.

Before getting started, make sure you satisfy all the prerequisites on the [system requirements](system-requirements) page.

## Set up Windows Admin Center

The AKS extension for Windows Admin Center is natively available as part of the Windows Admin Center MSI. You can [install Windows Admin Center](/en-us/windows-server/manage/windows-admin-center/deploy/install) either on a Windows 10 machine or on a server. If you already installed Windows Admin Center, make sure your version is `2103.2` or later. You can check your Windows Admin Center version by selecting the question mark in the top right-hand corner.

![Screenshot showing check for WAC version.](../media/setup/check-wac-version.png)

## Set up an Azure Kubernetes Service (AKS) host

You must set up an AKS host on your Kubernetes cluster before deploying AKS workload clusters. Setting up an AKS host is also referred to as setting up the platform services or management cluster.

[![Picture of an architecture diagram that highlights the platform services portion.](../media/setup/aks-hci-architecture-focused.png)](../media/setup/aks-hci-architecture-focused.png#lightbox)

Note

Setting up Azure Kubernetes Service hosts on two independent systems with the intention of merging them during Kubernetes cluster creation isn't a supported scenario.

You can set up an AKS host by using the new Azure Kubernetes Service tool. This tool installs and downloads the necessary packages, and creates an AKS host cluster that provides core Kubernetes services and orchestrates application workloads.

After you verify the system settings, follow these steps:

1. Select **Set up** to launch the Setup wizard.
2. Review the prerequisites for the machine on which you're running Windows Admin Center, on the cluster to which you're connected, and the network. Additionally, make sure you're signed into an Azure account on Windows Admin Center and that the Azure subscription you're planning on using isn't expired. You must have the **Owner** role on the subscription you are planning on using. When you're finished, select **Next**.

    Warning

    Make sure you configure at least one external virtual switch before proceeding past this step, or you won't be able to successfully set up your AKS host.
3. On the **System checks** page of the wizard, take any required actions, such as [connecting your Windows Admin Center gateway to Azure](/en-us/windows-server/manage/windows-admin-center/azure/azure-integration). When connecting your Windows Admin Center gateway to Azure, be sure to create a new Microsoft Entra application. This step checks that Windows Admin Center and the system that hosts AKS have the proper configuration to continue. When you're finished taking action, select **Next**.
4. Ensure system connectivity through CredSSP in the **Connectivity** step. CredSSP lets Windows Admin Center delegate the user's credentials from the gateway to a target server for remote authentication. CredSSP must be enabled to set up AKS. After you enable CredSSP, select **Next**.
5. Configure the machine that hosts AKS in the **Host configuration** step. Select **automatically download updates** in this section. This step of the wizard asks you to configure the following details:

    - **Host details**, such as a name for the AKS host cluster and an image directory where VM images are stored. The image directory must point to a shared storage path or an SMB share that is accessible by the host machine.
    - **Kubernetes node networking**, which serves as the default for the AKS host and all Linux and Windows Kubernetes nodes VMs that are created to run containers and orchestrate container management.

        You can also specify separate network configurations for a workload cluster. These settings include the fields for the internet-connected virtual switch, virtual LAN identification enablement, IP address allocation method, and CloudAgent IP. You can use the CloudAgent IP to provide a static IP address to the CloudAgent service. This address is applicable regardless of your IP address allocation selection. For more information, see [Kubernetes node networking](concepts-node-networking). If you select the static IP address allocation method, there are a few extra fields that you must specify:

        - **Subnet prefix**, an IP address range that doesn't conflict with other addresses.
        - **Gateway**, the gateway through which packets are routed outside the machine.
        - **DNS servers**, the comma-separated list of IP addresses for the DNS servers. Use a minimum of one and a maximum of three addresses.
        - **Kubernetes node IP pool start**, the pool start range for IP addresses used by Kubernetes clusters.
        - **Kubernetes node IP pool end**, the pool end range for IP addresses used by Kubernetes clusters.
        - **Load balancer settings**, which define the pool of addresses used for external services. If you select the static IP configuration in the VM networking section, the address pool start and end must be within the subnet range specified in that section.

    The following image shows an example of a DHCP host configuration:

    [![Screenshot that illustrates a DHCP configuration on the Host Configuration page.](../media/setup/host-configuration-dhcp.png)](../media/setup/host-configuration-dhcp.png#lightbox)

    The following image shows an example of a static IP host configuration:

    [![Screenshot that illustrates a static IP configuration on the Host Configuration page.](../media/setup/host-configuration-static.png)](../media/setup/host-configuration-static.png#lightbox)

    (Optional) Configure proxy settings as required for the AKS host. Make sure you also provision the list of IP addresses that needs to bypass the proxy. When complete, select **Next: Review + Create**.

    [![Screenshot that shows the optional proxy settings that you configure on the Host Configuration page.](../media/setup/proxy-settings-host-configuration.png)](../media/setup/proxy-settings-host-configuration.png#lightbox)

    Select **Next** after you're finished.
6. On the **Azure Registration** page of the wizard, provide details about the subscription, resource group, and region you want to use for this service. Your resource group must be in the Australia East, East US, Southeast Asia, or West Europe region.

    Windows Admin Center requires permissions to access resources in your organization that only an admin can grant. Select **View in Azure** to view your Windows Admin Center gateway in Azure and confirm you were granted admin consent for the following services:

    - Azure Service Management: user\_impersonation
    - Microsoft Graph: Application.ReadWrite.All
    - Microsoft Graph: Directory.AccessAsUser.All

    If you have these permissions, the permissions appear in green under **Status**, as shown here:

    [![Screenshot showing access granted.](../media/setup/access-granted.png)](../media/setup/access-granted.png#lightbox)

    If you don't have permissions, you might need the Azure subscription owner to manually grant admin consent.

    To add permissions:

    1. Select **Add a permission** in the top left corner.
    2. Select **Microsoft Graph**, then select **Delegated permissions**.
    3. Search for **Application.ReadWrite.All**, and if necessary, expand the **Application** dropdown box.
    4. Search for **Directory.AccessAsUser.All**, and if necessary, expand the **Directory** dropdown box.
    5. Select the checkboxes, then select **Add permissions**.

    You can also remove permissions that aren't required for AKS hybrid. To remove permissions before granting admin consent:

    1. Select the **...** to the right of the permission that shouldn't be granted.
    2. Select **Remove permission**.

    Once permissions are correct, select **Grant admin consent for &lt;user&gt;**, then select **Yes** to confirm them. You can revoke permissions at any time as needed.

    When you're done, your permissions look something like this:

    [![Screenshot showing permissions.](../media/setup/wac-api-permissions.png)](../media/setup/wac-api-permissions.png#lightbox)

    When you're finished, select **Next**.
7. Review all of your selections in the **Review + create** step. If you're satisfied with your selections, select **Next: new cluster** to begin host setup.
8. On the **Setup progress** page, you can watch the progress of your host setup. At this point, you can open Windows Admin Center in a new tab and continue your management tasks.

    Warning

    During installation of your Azure Kubernetes Service host, a **Kubernetes - Azure Arc** resource type is created in the resource group that you set during registration. Don't delete this resource; it represents your Azure Kubernetes Service host. You can identify the resource by checking its distribution field for a value of `aks_management`. Deleting this resource results in an out-of-policy deployment.
9. If the deployment succeeds, select **Finish**. You're presented with a management dashboard where you can create and manage your Kubernetes clusters.

    [![Screenshot showing Kubernetes dashboard.](../media/setup/dashboard.png)](../media/setup/dashboard.png#lightbox)