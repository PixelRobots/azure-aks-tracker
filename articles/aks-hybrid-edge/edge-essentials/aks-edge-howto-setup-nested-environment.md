---
layout: Conceptual
title: Nested virtualization environment for AKS Edge Essentials | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/edge-essentials/aks-edge-howto-setup-nested-environment
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
description: Learn how to prepare your nested virtualization environment for AKS Edge Essentials clusters.
author: davidsmatlak
ms.author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.custom: template-how-to, edge-essentials
locale: en-us
document_id: 20db7332-6b2a-3374-c28d-a36b11b190bb
document_version_independent_id: e7b3f1e2-852e-a5a4-e96c-4d0021e3913f
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/edge-essentials/aks-edge-howto-setup-nested-environment.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/edge-essentials/aks-edge-howto-setup-nested-environment
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/edge-essentials/aks-edge-howto-setup-nested-environment.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
- https://authoring-docs-microsoft.poolparty.biz/devrel/2ed91286-6cf7-4b83-810d-75d0ee3b09dd
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/c21d0a62-47cf-4452-bd24-e1ed14abbeda
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
- https://authoring-docs-microsoft.poolparty.biz/devrel/6735bd7e-4f7b-457d-b58c-29e6f0198677
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f43eaf81-15c1-41e2-95b2-89fb1560c563
platformId: 76153a38-17fb-f7b1-6430-808b4969e351
---

# Nested virtualization environment for AKS Edge Essentials | Microsoft Learn

This article describes how to set up a nested virtualization environment to deploy an Azure Kubernetes Service (AKS) Edge Essentials cluster.

Note

Deploying AKS Edge Essentials on top of a nested virtualization environment on VMware ESXi is supported. Other nested virtualization deployments are not supported for production scenarios and are limited to developer purposes. This guide assumes you're using the Hyper-V hypervisor. We do not support using a non-Microsoft hypervisor, such as KVM.

## Prerequisites

- See the [system requirements](aks-edge-system-requirements).
- OS requirements: install Windows 10/11 IoT Enterprise/Enterprise/Pro on your machine and activate Windows. We recommend using the latest [client version 22H2 (OS build 19045)](/en-us/windows/release-health/release-information) or [Server 2022 (OS build 20348)](/en-us/windows/release-health/windows-server-release-info). You can [download a version of Windows 10 here](https://www.microsoft.com/software-download/windows10) or [Windows 11 here](https://www.microsoft.com/software-download/windows11).

## Deployment on Windows VM on VMware ESXi

VMware ESXi [8.0](https://docs.vmware.com/en/VMware-vSphere/8.0/rn/vmware-vsphere-80-release-notes/index.html) versions can host AKS Edge Essentials on top of a Windows virtual machine.

To set up AKS Edge Essentials on a VMware ESXi Windows virtual machine, use the following steps:

1. Create a Windows virtual machine on the VMware ESXi host. For more information about VMware VM deployment, see [VMware - Deploying Virtual Machines](https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.vm_admin.doc/GUID-39D19B2B-A11C-42AE-AC80-DDA8682AB42C.html).

Note

If you're creating a Windows 11 virtual machine, ensure that it meets the minimum requirements by Microsoft to run Windows 11. For more information about Windows 11 VM VMware support, see [Installing Windows 11 as a guest OS on VMware](https://kb.vmware.com/s/article/86207).

1. Turn off the virtual machine created in previous step.
2. Select the Windows virtual machine and then **Edit settings**.
3. Search for **Hardware virtualization** and turn on **Expose hardware assisted virtualization to the guest OS**.
4. Select **Save** and start the virtual machine.
5. Install the Hyper-V hypervisor. If you're using Windows client, make sure you [Install Hyper-V on Windows 10](/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v). If you're using Windows Server, make sure you [install the Hyper-V role](/en-us/windows-server/virtualization/hyper-v/get-started/install-the-hyper-v-role-on-windows-server).

## Deployment on Azure virtual machines

If you're running AKS Edge Essentials on top of an Azure VM, ensure that you use an Azure Compute Unit (ACU) that supports nested virtualization. For more information, see [Azure Compute Unit (ACU)](/en-us/azure/virtual-machines/acu). Also, Azure VMs don't support using an external virtual switch, so AKS Edge Essentials deployments on top of the VM host OS are limited to single-machine clusters.

## Deployment environment

This section describes the nested architecture, highlighting the main components and configuration needed. The levels of virtualization described later in this article are:

- **L0 Host OS**: Windows host operating system. This OS can be running bare-metal or as a virtual machine, but in this article, the **L0 Host OS** is the one that creates the nested Windows L1 VMs.
- **L1 Virtual Machine**: Windows VM running on top of L0 Windows host OS. This VM has the AKS Edge Essentials installation.
- **L2 Virtual Machine**: AKS Edge Essentials nested VM (Linux or Windows) running on top of the L1 Windows virtual machine.

You can set up a nested environment using an internal or external virtual switch. However, this article assumes you're using an internal virtual switch. IP addresses of the L0 Windows machine and L1/L2 virtual machines can change depending on the networking scenario. This article assumes that you're using the **172.20.1.0/24** IP address family.

Also, deploying AKS Edge Essentials Windows nodes is optional, and impacts your assigned memory requirements. This article describes a Linux-only deployment, but you can add your Windows nodes by adding the appropriate configuration to the deployment JSON files.

Tip

If you're using external virtual switches for the deployment, make sure you use the correct network adapters and IP addresses allocations.

[![Diagram showing nested virtualization architecture.](../media/aks-edge/nested-virtualization-environment.png)](../media/aks-edge/nested-virtualization-environment.png#lightbox)

The previous diagram shows the different virtual machines and components of this nested architecture.

| Device/VM | OS | Level | Parent | Memory | IP Address |
| --- | --- | --- | --- | --- | --- |
| Windows host OS | Windows | L0 | - | 32/64 GB | 172.20.1.1 |
| Windows-VM-1 | Windows | L1 | Windows host OS | 8/16 GB | 172.20.1.2 |
| Windows-VM-2 | Windows | L1 | Windows host OS | 8/16 GB | 172.20.1.3 |
| AKS-Edge-Linux-VM-1 | CBL-Mariner | L2 | Windows-VM-1 | 4 GB | 172.20.1.4 |
| AKS-Edge-Windows-VM-1 (optional) | Windows | L2 | Windows-VM-1 | 4 GB | 172.20.1.5 |
| AKS-Edge-Linux-VM-2 | CBL-Mariner | L2 | Windows-VM-2 | 4 GB | 172.20.1.6 |
| AKS-Edge-Windows-VM-2 (optional) | Windows | L2 | Windows-VM-2 | 4 GB | 172.20.1.7 |

## Set up nested virtual machines

The following guide is an example of IP address allocation. You can use your own allocation based on your network environment and requirements. Naming conventions for virtual machines and virtual hardware assignments are also suggested, but you can use your own configuration.

1. Open an elevated PowerShell session.
2. Create an internal virtual switch:

    ```powershell
    New-VMSwitch -Name "AKS-Int" -SwitchType Internal
    ```

    If you created the switch correctly, you should see something similar to the following output:

    ```output
    Name    SwitchType NetAdapterInterfaceDescription
    ----    ---------- ------------------------------
    AKS-Int Internal
    ```
3. Assign an IP address to the **AKS-Int** virtual switch. This example uses the **172.20.1.0/24** network. The **Windows host OS** uses this virtual switch IP address to communicate with the other virtual machines and AKS Edge Essentials nodes:

    ```powershell
    $ifIndex = (Get-NetAdapter -Name "vEthernet (AKS-Int)").ifIndex
    New-NetIPAddress –IPAddress "172.20.1.1" -PrefixLength "24" -InterfaceIndex $ifIndex
    ```
4. Create a NAT table for connecting the internal virtual switch and the internal network connected devices with the external/Internet network:

    ```powershell
     New-NetNat -Name "AKS-EE-Int-Network" -InternalIPInterfaceAddressPrefix "172.20.1.0/24"
    ```
5. Using Hyper-V Manager, create the first Windows virtual machine and name it **Windows-VM-1**. For more information about virtual machine creation, see [Windows Server virtualization](/en-us/windows-server/virtualization/hyper-v/get-started/create-a-virtual-machine-in-hyper-v?tabs=hyper-v-manager). During the configuration of the VM, make sure you correctly set up the following parameters:

    - **Processors**: Number of virtual processors: 4
    - **Memory**: RAM: 8192 MB
    - **Network adapter**: Virtual switch: **AKS-Int**
6. When Windows setup and configuration are finished, turn off your **Windows-VM-1** virtual machine.
7. Enable nested virtualization for **Windows-VM-1**. For more information about nested virtualization, see [Run Hyper-V in a Virtual Machine with Nested Virtualization](/en-us/virtualization/hyper-v-on-windows/user-guide/nested-virtualization):

    ```powershell
    Set-VMProcessor -VMName <windows-vm-name> -ExposeVirtualizationExtensions $true
    ```
8. Enable MAC spoofing for **Windows-VM-1**:

    ```powershell
    Get-VMNetworkAdapter -VMName <windows-vm-name> | Set-VMNetworkAdapter -MacAddressSpoofing On
    ```
9. Turn on the **Windows-VM-1** virtual machine and connect using the Hyper-V **Connect** option.
10. Inside the **Windows-VM-1** virtual machine, open an elevated PowerShell session.
11. Check the adapters connected to the virtual machine. Look for the **name** of the connected **Ethernet adapter &lt;name&gt;**. For example, **Ethernet 2**:

    ```powershell
    ipconfig
    ```

    You should see something similar to the following output:

    ```output
    PS C:\Windows\system32> ipconfig
    
    Windows IP Configuration
    
    Ethernet adapter Ethernet 2:
    
       Connection-specific DNS Suffix  . : mshome.net
       Link-local IPv6 Address . . . . . : fe80::f4b3:63b3:20d0:2e60%12
       Autoconfiguration IPv4 Address. . : 169.254.233.233
       Subnet Mask . . . . . . . . . . . : 255.255.0.0
       Default Gateway . . . . . . . . . :
    
    Ethernet adapter vEthernet (Default Switch):
    
       Connection-specific DNS Suffix  . :
       Link-local IPv6 Address . . . . . : fe80::545e:7d5:812b:c17b%18
       IPv4 Address. . . . . . . . . . . : 172.21.144.1
       Subnet Mask . . . . . . . . . . . : 255.255.240.0
       Default Gateway . . . . . . . . . :
    ```
12. Get the **ifIndex** of the **Ethernet adapter** with the name from previous step:

    ```powershell
    $ifIndex = (Get-NetAdapter -Name "<name>").ifIndex
    ```
13. Configure static IP **172.20.1.2** and gateway IP **172.20.1.1** and DNS Server **172.20.1.1**:

    Tip

    If you are using an Azure VM, use the **Windows host OS (L0)** DNS server. Use the `ipconfig /all` command to get the DNS server address. Check that you're able to get internet access using your web browser. If you have no access, check the if the DNS server is correctly configured:

    ```powershell
    New-NetIPAddress –IPAddress "172.20.1.2" -DefaultGateway "172.20.1.1" -PrefixLength "24" -InterfaceIndex $ifIndex
    Set-DNSClientServerAddress –InterfaceIndex $ifIndex –ServerAddresses "172.20.1.1"
    ```
14. Set up the **Windows-VM-1** virtual machine, following the [Prepare your machines for AKS Edge Essentials](aks-edge-howto-setup-machine) procedure.
15. Install all AKS Edge Essentials prerequisites for the **Windows-VM-1** virtual machine. For more information about prerequisites, see [AKS Edge Essentials requirements and support matrix](aks-edge-system-requirements):

    ```powershell
    Install-AksEdgeHostFeatures
    ```
16. Create the AKS Edge Essentials full-scale deployment configuration file. Once the JSON is created, add the required parameters. Make sure to change the network adapter for external virtual switch creation, DNS server, assigned memory, and correct static IP addresses. For more information, see [Full Kubernetes deployments in AKS Edge Essentials](aks-edge-howto-multi-node-deployment):

    ```powershell
    New-AksEdgeConfig -NodeType Linux -DeploymentType ScalableCluster
    ```
17. Deploy the AKS Edge Essentials full-scale deployment using the configuration JSON file created in previous step:

    ```powershell
    New-AksEdgeDeployment -JsonConfigFilePath .\AksEdgeDeployConfigTemplate.json
    ```
18. Enable pinging ICMP traffic on the **AKS-Edge-VM-1** virtual machine:

    ```powershell
    Invoke-AksEdgeNodeCommand -NodeType "Linux" -command "sudo iptables -A INPUT -p ICMP -j ACCEPT"
    ```
19. Ping **AKS-Edge-VM-1** from the **Windows-VM-1** virtual machine:

    ```powershell
    ping 172.20.1.4
    ```
20. Ping **AKS-Edge-VM-1** from the **Windows host OS**:

    ```powershell
    ping 172.20.1.4
    ```

    Warning

    If the ping requests to the **AKS-Edge-VM-1** VM fail, review the IP configuration and troubleshoot the network connections.
21. Inside **Windows-VM-1**, get the **scaleConfig** JSON file to be used in **Windows-VM-2**:

    ```powershell
     New-AksEdgeScaleConfig -NodeType Linux -ScaleType AddMachine -LinuxNodeIp <VM2-Linux-Node-IP>
    ```
22. Create the **Windows-VM-2** virtual machine. Repeat steps 4 to 14 with the new **Windows-VM-2** parameters:

    - Virtual machine name: **Windows-VM-2**
    - IP Address: **172.20.1.3**
    - Processors: Number of virtual processors: **4**
    - Memory: **8192 MB**
    - Network adapter (Virtual switch): **AKS-Int**
    - IP Gateway address: **172.20.1.1**
    - DNS Server address: **172.20.1.1**
23. Test the ping from **Windows-VM-2** to **AKS-Edge-VM-1**:

    ```powershell
    ping 172.20.1.4
    ```

    Warning

    If the ping requests to the **AKS-Edge-VM-1** fail, review the IP configuration and troubleshoot the network connections.
24. Set up the **Windows-VM-2** virtual machine, following the [Prepare your machines for AKS Edge Essentials](aks-edge-howto-setup-machine) procedure.
25. Install all AKS Edge Essentials prerequisites for the **Windows-VM-2** virtual machine. For more information about prerequisites, see [AKS Edge Essentials requirements and support matrix](aks-edge-system-requirements):

    ```powershell
    Install-AksEdgeHostFeatures
    ```
26. Connect to the **Windows-VM-1** virtual machine, and using an elevated PowerShell session, get the AKS Edge cluster join configuration:

    ```powershell
    New-AksEdgeScaleConfig -NodeType Linux -ScaleType AddMachine -LinuxNodeIp <AKS-Edge-Linux-VM-2>
    ```
27. Copy the AKS Edge Essentials scale configuration file from **Windows-VM-1** and modify it with the appropriate parameters. For more information, see [Scaling out on multiple machines](aks-edge-howto-scale-out).
28. Deploy **AKS-Edge-VM-2** on **Window-VM-2** using the scale configuration JSON file from the previous step:

    ```powershell
    New-AksEdgeDeployment -JsonConfigFilePath <scale-config-json>
    ```
29. Validate that the node was added to the cluster. On any node in the cluster, run the following cmdlet:

    ```powershell
    kubectl get nodes
    ```

    If everything was correctly set up, you should see both Linux nodes running in your cluster:

    ```output
    PS C:\> kubectl get nodes
    NAME                     STATUS   ROLES                       AGE     VERSION
    windows-vm1-ledge        Ready    control-plane,etcd,master   3m45s   v1.24.3+k3s-
    windows-vm2-ledge        Ready    control-plane,etcd,master  10m25s   v1.24.3+k3s-
    ```

    Note

    For a list of currently supported Kubernetes versions on both K3s and K8s, see the table in [Download AKS Edge Essentials](aks-edge-howto-setup-machine#download-aks-edge-essentials).