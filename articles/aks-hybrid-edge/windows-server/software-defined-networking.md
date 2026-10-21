---
layout: Conceptual
title: How to use AKS on Windows Server with SDN and virtual networking infrastructure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/software-defined-networking
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
description: Learn how to use AKS on Windows Server with software defined networking and virtual networking infrastructure.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-10-07T00:00:00.0000000Z
ms.reviewer: anpaul
ms.custom: windows-server
locale: en-us
document_id: 166b4416-4ef1-464d-b66e-ed0670920ab5
document_version_independent_id: 4a57a288-ab0b-019c-4fcf-254e229e32fd
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/software-defined-networking.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/software-defined-networking
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/software-defined-networking.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/20ed8455-bc18-4537-87a4-83784e7b2a39
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/9a7f703b-30bb-4d62-9eb4-97213f571849
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
platformId: 2dd4b1c2-089f-8a33-f511-87a715310bf0
---

# How to use AKS on Windows Server with SDN and virtual networking infrastructure | Microsoft Learn

> 
> Applies to: AKS on Windows Server

This article describes how to deploy AKS infrastructure and workload VMs to an SDN Virtual Network using our SDN [Software Load Balancer](/en-us/azure/azure-local/concepts/software-load-balancer) for all AKS load balancing scenarios. AKS on Windows Server offers a fully supported container platform that can run cloud-native applications on the [Kubernetes container orchestration platform](https://kubernetes.io/). The architecture supports running virtualized Windows and Linux workloads.

## Limitations

The following features are out of scope and not supported in this GA release:

- Attaching pods and containers to an SDN virtual network.
    - Pods use Flannel or Calico (default) as the network provider.
- Network policy enforcement using the SDN Network Security Groups.
    - The SDN Network Security Groups can still be configured outside of AKS using SDN tools (REST/PowerShell/Windows Admin Center/SCVMM), but Kubernetes NetworkPolicy objects don't configure them.
- Attaching AKS VM NICs to SDN logical networks.
- Installation using Windows Admin Center.
- Physical host to AKS VM connectivity: VM NICs are joined to an SDN virtual network and thus aren't accessible from the host by default. For now, you can enable this connectivity manually by attaching a public IP directly to the VM using the SDN Software Load Balancer.

## Prerequisites

To deploy AKS on Windows Server with SDN, make sure your environment satisfies the deployment criteria of both AKS and SDN.

- [AKS requirements](system-requirements)
- SDN requirements: [Plan a Software Defined Network infrastructure](/en-us/azure/azure-local/concepts/plan-software-defined-networking-infrastructure)

Note

SDN integration with AKS only requires Network Controller and Software Load Balancer. Gateway VMs are optional.

## Install and prepare SDN for AKS

The first step is to install SDN. To install SDN, we recommend [SDN Express](/en-us/azure/azure-local/manage/sdn-express) or [Windows Admin Center](/en-us/azure/azure-local/deploy/sdn-wizard). A reference configuration file that deploys all the needed SDN infrastructure components can be found here: [Software Load Balancer.psd1][].

Once the SDN Express deployment completes, there should be a screen that reports the status as healthy.

If anything went wrong or is being reported as unhealthy, see [Troubleshooting SDN](/en-us/windows-server/networking/sdn/troubleshoot/troubleshoot-software-defined-networking).

It's important that SDN is healthy before proceeding. If you deploy SDN in a new environment, we also recommend creating test VMs and verifying connectivity to the load balancer VIPs. See [how to create and attach VMs to an SDN virtual network](/en-us/azure/azure-local/manage/vm) using Windows Admin Center.

## Steps to install AKS

Initialize and prepare all the physical host machines for AKS. See [Deploy an AKS host](prestage-cluster-service-host-create) for the most up-to-date instructions.

### Install the AKS-HCI PowerShell module

See [Install the AksHci PowerShell module](kubernetes-walkthrough-powershell#install-the-akshci-powershell-module) for information about installing the AKS-HCI PowerShell module.

Note

After you complete this step, refresh or reload any opened PowerShell sessions to reload the modules.

### Register the resource provider to your subscription

For information about how to register the resource provider to your subscription, see [Install the AksHci PowerShell module](kubernetes-walkthrough-powershell#register-the-resource-provider-to-your-subscription).

### Prepare your machines for deployment

For information about how to prepare your machines for deployment, see [Prepare your machines for deployment](kubernetes-walkthrough-powershell#step-1-prepare-your-machines-for-deployment).

### Configure AKS for installation

Choose one of your Windows Server machines to drive the creation of AKS. There are three steps that need to be done prior to installation:

1. Configure the AKS network settings for SDN; for example, using:

    1. SDN Virtual network "10.20.0.0/24" (10.20.0.0 – 10.20.0.255). A virtualized network, and you can use any IP subnet. This subnet does not need to exist on your physical network.
    2. vSwitch name "External." The external vSwitch on the Windows Server machines. Ensure that you use the same vSwitch that was used for SDN deployment.
    3. Gateway "10.20.0.1." This address is the gateway for your virtual network.
    4. DNS Server "10.127.130.7." The DNS server for your virtual network.

    ```powershell
    $vnet = New-AksHciNetworkSetting –name "myvnet" –vswitchName "External" -k8sNodeIpPoolStart "10.20.0.2" -k8sNodeIpPoolEnd "10.20.0.255"
    -ipAddressPrefix "10.20.0.0/24" -gateway "10.20.0.1" -dnsServers "10.127.130.7"
    ```

    | Parameter | Description |
    | --- | --- |
    | `-name` | Name of virtual network in AKS on Windows Server (must be lowercase). |
    | `-vswitchName` | Name of external vSwitch on the Windows Server machines. Use same vSwitch that was used for SDN deployment. |
    | `-k8sNodeIpPoolStart``-k8sNodeIpPoolEnd` | IP start/end range of SDN virtual network. |
    | `-ipAddressPrefix` | Virtual network subnet in CIDR notation. |
    | `-gateway``-dnsServers` | Gateway and DNS server of the SDN virtual network. |

    For more information about these parameters, see [New-AksHciNetworkSetting](/en-us/azure/aks/aksarc/reference/ps/new-akshcinetworksetting).
2. In the same PowerShell window you used in Step 1, create a VIP pool to inform AKS of our IPs that can be used from our SDN Load Balancing logical network:

    ```powershell
    $VipPool = New-AksHciVipPoolSetting -name "publicvip" -vipPoolStart "10.127.132.16" -vipPoolEnd "10.127.132.23
    ```

    | Parameter | Description |
    | --- | --- |
    | `-name` | The "PublicVIP" logical network that you provided when configuring SDN load balancers. Within the cmdlet, this name must be lowercase. |
    | `-vipPoolStart` | IP start range of logical network used for public load balancer VIP pool. You must use an address range from the "PublicVIP" SDN logical network. |
    | `-vipPoolEnd` | IP end range of logical network used for public load balancer VIP pool. You must use an address range from the "PublicVIP" SDN logical network. |
3. In the same PowerShell window used in Step 2, create the AKS configuration for SDN by providing references to the targeted SDN networks, and supply the network settings ($vnet, $vipPool) that we previously defined:

    ```powershell
    Set-AksHciConfig 
    –imageDir "C:\ClusterStorage\Volume1\ImageStore" 
    –workingDir "C:\ClusterStorage\Volume1\WorkDir"
    –cloudConfigLocation "C:\ClusterStorage\Volume1\Config" 
    –vnet $vnet –useNetworkController
    –NetworkControllerFqdnOrIpAddress "nc.contoso.com" 
    –networkControllerLbSubnetRef "/logicalnetworks/PublicVIP/subnets/my_vip_subnet" 
    –networkControllerLnetRef "/logicalnetworks/HNVPA" 
    -vipPool $vipPool
    ```

    The HNVPA logical network is used as the underlying provider for the AKS virtual network.

    If you use a static IP address assignment for your Windows Server cluster nodes, you must also provide the `CloudServiceCidr` parameter. This parameter is the IP address of the MOC cloud service, and must be in the same subnet as Windows Server cluster nodes. For more information, see [Microsoft On-premises Cloud service](concepts-node-networking#microsoft-on-premises-cloud-service).

    | Parameter | Description |
    | --- | --- |
    | `–imageDir` | The path to where AKS stores its VHD images. This path must be a shared storage path, or an SMB share. |
    | `–workingDir` | The path to where small files for the module are stored. This path must be a shared storage path, or an SMB share. |
    | `-cloudConfigLocation` | The path to the directory where cloud agent configuration is stored. This path must be a shared storage path, or an SMB share. |
    | `-vnet` | Name of `AksHciNetworkSetting` variable created in the previous step |
    | `-useNetworkController` | Enable integration with SDN. |
    | `-networkControllerFqdnOrIpAddress` | Network controller FQDN. You can get the FQDN by executing `Get-NetworkController` on the Network Controller VM and using the `RestName` parameter. |
    | `-networkControllerLbSubnetRef` | Reference to the public VIP logical network subnet configured in the Network Controller. You can get this subnet by running the `Get-NetworkControllerLogicalSubnet` cmdlet. When using this cmdlet, use `PublicVIP` as the `LogicalNetworkId`. The `VipPoolStart` and `vipPoolEnd` parameters in the `New-AksHciVipPoolSetting` cmdlet must be part of the subnet referenced here. |
    | `-networkControllerLnetRef` | Normally, this value is "/logicalnetworks/HNVPA." |
    | `-vipPool` | VIP pool used as the front end IPs for load balancing. |

    For more information about these parameters, see [Set-AksHciConfig](/en-us/azure/aks/aksarc/reference/ps/set-akshciconfig).

### Sign in to Azure and configure registration settings

Follow [the instructions here](kubernetes-walkthrough-powershell#step-4-sign-in-to-azure-and-configure-registration-settings) to configure registration settings.

Note

If you don't have owner permissions, it's recommended that you use an [Azure service principal](/en-us/azure/aks/aksarc/reference/ps/set-akshciregistration#register-aks-hybrid-using-a-service-principal).

### Install AKS

Once the AKS configuration completes, you are ready to install AKS on Windows Server.

```powershell
Install-AksHci
```

Once the installation succeeds, a control plane VM (management cluster) is created, and its VmNIC is attached to your SDN network.

### Collect logs from an SDN and AKS on Windows Server environment

With SDN and AKS on Windows Server, we gain isolation of the AKS nodes on virtual networks. Since they are isolated, we must import a new SDN AKS-HCI log collection script and run a modified command that uses the load balancer to retrieve logs from the nodes:

```powershell
Install-Module -Name AksHciSdnLogCollector -Repository PSGallery
Get-AksHciLogsSdn
```

### Feedback/issues

See the [self-help resources here](/en-us/windows-server/networking/sdn/troubleshoot/troubleshoot-software-defined-networking) for SDN [and here for AKS-HCI](/en-us/azure/aks/aksarc/known-issues).