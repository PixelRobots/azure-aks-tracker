---
layout: Conceptual
title: Validation tests in AKS on Windows Server | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/validation-tests
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
description: Learn how to validate your environment and configuration prior to installing AKS on Windows Server.
author: davidsmatlak
ms.topic: troubleshooting
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2023-04-19T00:00:00.0000000Z
ms.reviewer: waltero
ms.custom: windows-server
locale: en-us
document_id: 0bb87d71-c594-9084-b5c7-72ae6533ab6b
document_version_independent_id: d9157bae-19c0-d4d9-6432-102fcf9c870f
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/validation-tests.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/validation-tests
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/validation-tests.md
platformId: c4a0b834-0813-4b11-16c5-d61139476112
---

# Validation tests in AKS on Windows Server | Microsoft Learn

> 
> Applies to: AKS on Windows Server

The following table lists the tests that are executed when you run the [Set-AksHciConfig](/en-us/azure/aks/aksarc/reference/ps/set-akshciconfig) and [Set-AksHciRegistration](/en-us/azure/aks/aksarc/reference/ps/set-akshciregistration) PowerShell cmdlets. The tests help to ensure that when you run the actual installation with [Install-AksHci](/en-us/azure/aks/aksarc/reference/ps/install-akshci), the installation process avoids many common environment and configuration issues. For a better understanding of the terms used in the tests, see the [AKS concepts article](kubernetes-concepts).

| Test name | Description | Troubleshooting resources |
| --- | --- | --- |
| [MOC](concepts-node-networking) host internet connectivity | The test validates that the machine hosting MOC has internet connectivity to key Microsoft endpoints. | - Ensure that there is connectivity from the physical hosts to the internet.  - [Blog post on troubleshooting network issues in Windows Server](https://techcommunity.microsoft.com/t5/itops-talk-blog/how-to-troubleshoot-windows-server-network-connectivity-issues/ba-p/1500934) - [Use HUD for troubleshooting network issues in Azure Local](https://techcommunity.microsoft.com/t5/networking-blog/introducing-network-hud-for-azure-stack-hci/ba-p/3676097) - [Firewall requirements for Azure Local](/en-us/azure/azure-local/concepts/firewall-requirements) - [Troubleshooting Windows Server components](/en-us/windows-server/troubleshoot/windows-server-troubleshooting) |
| MOC host limits | Validates that the machine hosting MOC has the minimum resources needed. See the published [hardware requirements](system-requirements?tabs=allow-table). | Ensure that the minimum requirements are met: [AKS system requirements](system-requirements?tabs=allow-table). |
| MOC host remoting | Validates that PowerShell remoting is enabled and working from the MOC hosting machine to other physical hosts in the cluster. | - [Troubleshoot CredSSP issues](/en-us/azure-stack/hci/manage/troubleshoot-credssp) - [Troubleshoot PowerShell remoting issues](/en-us/powershell/module/microsoft.powershell.core/about/about_remote_troubleshooting) |
| MOC network configuration | Validates that the MOC network configuration is correct. It verifies that:  - The virtual switch exists.  - The CloudServiceIP can be used to provide a static IP address to be assigned to the MOC CloudAgent service. This value should be provided using the standard IPv4 format; for example, **192.168.1.2**. The cloudServiceIP address should also be created from one of the ClusterAndClient networks in the underlying failover cluster.  You can run the `Get-ClusterNetwork` command in an elevated PowerShell window to find the network role. You may want to specify this address to ensure that anything important on the network is always accessible, because the IP address doesn't change.  - Should be able to create and start the failover cluster resource.  - The cloud service IP should not overlap with the VIP pool, or k8snodepool IP addresses provided during VNET configuration. | - Ensure that the IP address of the **CloudServiceIP** meets the requirements in the description.  - [AKS network concepts](concepts-node-networking) - [AKS network troubleshooting](/en-us/azure/aks/aksarc/known-issues-networking) - [Can't bring a network name online in a failover cluster](/en-us/troubleshoot/windows-server/high-availability/troubleshoot-cannot-bring-network-name-online) |
| MOC SDN configuration | Validates that the SDN configuration is correct, and the Network Controller is available. The test checks that:  - Network Controller FQDN or IP address information is reachable.  - Network Controller load balancer subnet resource reference is provided.  - Network Controller L netRef is provided. | - If you're providing SDN parameters, ensure that SDN is available in the system.  - [AKS network concepts](concepts-node-networking) - [Troubleshooting SDN](/en-us/windows-server/networking/sdn/troubleshoot/troubleshoot-software-defined-networking) - [Checklist for troubleshooting SDN](/en-us/troubleshoot/windows-server/software-defined-networking/troubleshoot-sdn-guidance) |
| MOC directories | Validates MOC directories. The test checks for:  - Valid directory names.  - Config directory cannot contain the working directory.  - Check if the working directory is in the cluster shared volume.  - Check that the directories aren't local.  - Check to ensure the working directory is not the system drive or root. | - Ensure the user account has access to the directories provided.  - Verify that no previous install of MOC exists.  - Verify that the config directory cannot contain the working directory. |
| Failover cluster health | Validates failover cluster health. It checks that the cluster nodes and cluster network are available. | - Ensure that there is a failover setup, see [Failover clustering](/en-us/windows-server/failover-clustering/failover-clustering-overview).  - [Run an Azure Local cluster validation test](/en-us/azure-stack/hci/manage/validate-qos).  - [Troubleshooting the failover cluster](/en-us/windows-server/failover-clustering/troubleshooting-using-wer-reports) |
| Failover cluster Azure Local registration | Validates failover cluster Azure Local registration. The test checks for the presence of a failover cluster. | - [Run an Azure Local cluster validation test](/en-us/azure-stack/hci/manage/validate-qos).  - [Troubleshooting the failover cluster](/en-us/windows-server/failover-clustering/troubleshooting-using-wer-reports) |
| AKS management cluster configuration | Validates the AKS management cluster configuration and corresponding host machine configuration to make sure the host is ready to install it successfully. Verifies:  - AKS management image is present.  - AKS-related binaries are present in all nodes.  - Necessary Azure Local cloud roles are added.  - Verifies Azure Local cloud location.  - Verifies Azure Local cloud storage container.  - Verifies permissions to create an Azure resource.  - Verifies Azure Local network and load balancer type.  - Verifies Kube-Vip configuration.  - Verifies Vip-pool IPs.  - Verifies K8s node pool IPs. | - Review the [Active Directory requirements](system-requirements?tabs=allow-table).  - [AKS network troubleshooting](concepts-node-networking) - Ensure the user has the necessary permissions.  - Ensure that IP formatting is correct. |
| AKS management cluster configuration proxy connectivity | Validates that the configuration allows internet connectivity to Microsoft endpoints with or without a proxy server. | - Ensure the host has internet connectivity.  - Follow the [proxy settings guide](set-proxy-settings). |
| AKS internet connectivity | Validates that the virtual machine hosting AKS has internet connectivity to key [Microsoft endpoints](system-requirements?tabs=allow-table#network-port-and-url-requirements). | - Ensure that there's connectivity from the physical hosts to the internet.  - If you're using a proxy, ensure that the proxy settings passed in [Set-AksHciConfig](/en-us/azure/aks/aksarc/reference/ps/set-akshciconfig) are correct. - Ensure there is connectivity from any VMs in the nodepool IP range provided in the [New-AksHciNetworkSetting](/en-us/azure/aks/aksarc/reference/ps/new-akshcinetworksetting) cmdlet parameters `-k8sNodeIpPoolStart` and `-k8sNodeIpPoolStart`. - [Blog post on troubleshooting network issues in Windows Server](https://techcommunity.microsoft.com/t5/itops-talk-blog/how-to-troubleshoot-windows-server-network-connectivity-issues/ba-p/1500934) - [Use HUD for troubleshooting network issues in Azure Local](https://techcommunity.microsoft.com/t5/networking-blog/introducing-network-hud-for-azure-stack-hci/ba-p/3676097) - [Firewall requirements for Azure Local](/en-us/azure-stack/hci/concepts/firewall-requirements) - [Troubleshooting Windows Server components](/en-us/windows-server/troubleshoot/windows-server-troubleshooting) |
| DNS availability | Validates that the provided DNS servers are available. | Ensure that the DNS servers provided in the [New-AksHciNetworkSetting](/en-us/azure/aks/aksarc/reference/ps/new-akshcinetworksetting) cmdlet parameter `-dnsServers` are available to VMs in the IP range provided in the parameters `-k8sNodeIpPoolStart` and `-k8sNodeIpPoolStart`. |
| Connectivity between the VM that hosts the AKS ([management cluster](kubernetes-concepts#the-management-cluster)) and the cloud agent. | Validates that VMs in the **K8sNoodPool** range can reach the cloud agent endpoint. | - Ensure that the DNS servers provided in [New-AksHciNetworkSetting](/en-us/azure/aks/aksarc/reference/ps/new-akshcinetworksetting) can resolve the cloud agent FQDN.  - Ensure that the cloud agent endpoint is online. |