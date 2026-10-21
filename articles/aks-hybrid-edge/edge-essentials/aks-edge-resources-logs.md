---
layout: Conceptual
title: Logs for AKS Edge Essentials | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/edge-essentials/aks-edge-resources-logs
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
description: Gather and troubleshoot AKS Edge Essentials using logs.
author: davidsmatlak
ms.author: davidsmatlak
ms.topic: end-user-help
ms.date: 2026-09-01T00:00:00.0000000Z
ms.custom: end-user-help, edge-essentials
locale: en-us
document_id: dacab3fa-605b-5a4d-e1f1-c2a642af0be1
document_version_independent_id: a57e4cd7-abc2-e2af-ae4b-2abdfd74675c
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/edge-essentials/aks-edge-resources-logs.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/edge-essentials/aks-edge-resources-logs
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/edge-essentials/aks-edge-resources-logs.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/c21d0a62-47cf-4452-bd24-e1ed14abbeda
- https://authoring-docs-microsoft.poolparty.biz/devrel/2ed91286-6cf7-4b83-810d-75d0ee3b09dd
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f43eaf81-15c1-41e2-95b2-89fb1560c563
- https://authoring-docs-microsoft.poolparty.biz/devrel/6735bd7e-4f7b-457d-b58c-29e6f0198677
platformId: 212c6b2c-726f-4642-3e43-9cc3cbb95e3c
---

# Logs for AKS Edge Essentials | Microsoft Learn

If you experience issues running AKS Edge Essentials IoT Edge in your environment, use this article as a guide for gathering and using logs.

## Get logs

When troubleshooting AKS Edge Essentials, your first step should be to gather logs. The most convenient way is to use the `Get-AksEdgeLogs` command. By default, this cmdlet collects different logs around VM management, networking, Kubernetes services, and more. It compresses them into a single file for easy sharing.

To get the AKS Edge Essentials logs, use the following steps:

1. Open an elevated PowerShell session.
2. Run the cmdlet to get the logs:

    ```powershell
    Get-AksEdgeLogs
    ```
3. All logs are stored in a .zip file under the following path: **C:\ProgramData\AksEdge\logs\aksedge-logs-ddmmyy-hhmm.zip**.
4. Go to the **C:\ProgramData\AksEdge\logs** folder and unzip the **aksedge-logs-ddmmyy-hhmm.zip** logs file.

## Understanding logs

The compressed log file consists of different configuration files, deployment and services logs, and information about host OS and deployed cluster. Depending on the cluster state, Kubernetes distribution and host OS, some files might not be available.

### Windows host OS logs

| File name | Group | Description |
| --- | --- | --- |
| **aksedgeevents.xml** | Windows Event Log | Windows events logged during deployment or VM lifecycle. To manually check these events, use the Event Viewer application and check the events under **Applications and Services Logs** -&gt; **AKS Edge Essentials- K3s/K8s**. |
| **aksedgehost-systeminfo** | Information | Windows host OS information including: PowerShell version, Windows OS version, CPU, memory, and storage. |
| **Microsoft-Windows-Host-Network-Service-Admin.xml** | Windows Event Log | HNS service Windows Event Log - Internal use only. |
| **Microsoft-Windows-Host-Network-Service-Operational.xml** | Windows Event Log | HNS operational service Windows Event Log - internal use only. |
| **Microsoft-Windows-Hyper-V-Compute-Admin.xml** | Windows Event Log | Events from the Host Compute Service (HCS) are collected here - internal use only. |
| **Microsoft-Windows-Hyper-V-Compute-Operational.xml** | Windows Event Log | Events from the Host Compute Service (HCS) are collected here - internal use only. |
| **Microsoft-Windows-Hyper-V-VMMS-Admin.xml** | Windows Event Log | Events from the virtual machine management service (VMMS) can be found here - internal use only. |
| **Microsoft-Windows-Hyper-V-VMMS-Networking.xml** | Windows Event Log | Events from the virtual machine management service (VMMS) networking stack can be found here - internal use only. |
| **Microsoft-Windows-Hyper-V-VMMS-Operational.xml** | Windows Event Log | Events from the virtual machine management service (VMMS) operation can be found here - internal use only. |

### Wssdagent logs

The WSSDAgent is the AKS Edge Essentials service used for virtual machines creation and lifecycle management. This service runs on the Windows host OS and uses Hyper-V API implementations (HCS or VMMS) to manage the VMs.

| File name | Group | Description |
| --- | --- | --- |
| **agent-log-0** | VM Information | Virtual machines lifecycle logs - internal use only. |
| **wssdagent** | VM Information | Virtual machines lifecycle logs - internal use only. |
| **Other files** | Deployment configuration. | Internal use only. |

### Linux-containers logs

Linux containers running inside the Linux nodes use `/var/log/continers/<container-name>.log` files to store container logs. All these `.log` files are copied and compressed under the **linux-containers** folder.

### AKS Edge nodes logs

These logs should be independent of the cluster type and the Kubernetes distribution being used (K3s or K8s).

| File name | Group | Description |
| --- | --- | --- |
| **aksedgeconfig.txt** | Deployment configurations | Stores deployment configuration being used to create the cluster. Both internal and user-provided configurations are stored in this file. |
| **aksedgelogs-summary** | Information | Details about which logs were collected and included in the logs compressed file. |
| **AksEdgenetworkConfig\_LinuxVm** | VM information | Output of networking configurations: IP addresses of network interfaces (`sudo ip a`), routes being used (`sudo route`) and **iptables** firewall rules (`sudo iptables -L`). |
| ***&lt;Windows-hostname&gt;*-ledge\_cloudinit** and ***&lt;Windows-hostname&gt;*-ledge\_cloudinit-output** | VM Information | Output of cloudinit configuration used for the Linux VM creation. For more information, see [the cloudinit documentation](https://cloudinit.readthedocs.io/en/latest/). |
| ***&lt;Windows-hostname&gt;*-ledge\_systemd** | VM information | Logs of Linux **systemd** (`sudo journalctl`). |
| ***&lt;Windows-hostname&gt;*-ledge\_vmconfig** | Deployment configuration | Linux virtual machine configuration - internal use only. |
| ***&lt;Windows-hostname&gt;*-ledge-aksedge-agent** | VM information | Linux virtual machine deployment logs - internal use only. |
| ***&lt;Windows-hostname&gt;*-ledge-aksedge-agent-config** | Deployment configuration | Linux virtual machine configuration - internal use only. |
| ***&lt;Windows-hostname&gt;*-ledge-aksedge-lifecycle-config** | Deployment configuration | Linux virtual machine configuration - internal use only. |
| ***&lt;Windows-hostname&gt;*-wedge\_cloudbase-init** and ***&lt;Windows-hostname&gt;*-ledge\_cloudbase-init-unattend** | VM information | Output of cloudinit configuration used for the Windows VM creation. For more information, check [cloudbase-init docs](https://cloudbase-init.readthedocs.io/en/latest/tutorial.html). |
| ***&lt;Windows-hostname&gt;*-wedge\_ipconfig** | VM information | Output of networking configuration: IP addresses of network interfaces (`ipconfig /all`). |
| ***&lt;Windows-hostname&gt;*-wedge\_vmconfig** | Deployment configuration | Windows virtual machine configurations - internal use only. |
| ***&lt;Windows-hostname&gt;*-wedge-aksedge-agent** | VM information | Windows virtual machine deployment logs - internal use only. |
| ***&lt;Windows-hostname&gt;*-wedge-aksedge-agent-config** | Deployment configuration | Windows virtual machine configuration - internal use only. |
| ***&lt;Windows-hostname&gt;*-ledge-aksedge-lifecycle-mgmt** | VM information | Windows virtual machine lifecycle management logs - Internal use only. |
| **config** | Deployment configuration | Copy of JSON configuration used for deployment. Sensitive information isn't included. |
| **hcsdiag\_list** | VM Information | Running virtual machines created by HCS. Only valid for Windows Client host OS deployments. AKS Edge Essentials nodes should run under the **wssdagent** name. |
| **hnsdiag\_list\_all** | VM information | Network information related to the virtual machines. Only valid for Windows Client host OS deployments. |
| **kubectl\_describe** | Kubernetes information | Output of running `kubectl describe nodes`. For more information about this command, see the [Kubectl reference documentation](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#describe). |
| **kubectl\_pods** | Cluster information | Output of running `kubectl describe pods`. For more information about this command, see the [Kubectl reference documentation](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#describe). |

### K3s specific logs

These logs are only available if the AKS Edge Essentials K3s version was installed, and **Linux** and/or **Windows** nodes were deployed.

| File name | Group | Description |
| --- | --- | --- |
| ***&lt;Windows-hostname&gt;*-ledge\_k3s** | Kubernetes information | Logs of K3S Linux system service (`sudo journalctl -u k3s` or `sudo journalctl -u k3s-agent`). |
| ***&lt;Windows-hostname&gt;*-wedge\_k3s** | Kubernetes information | Logs of K3S Windows system service (`C:\tmp\K3s.log`). |
| ***&lt;Windows-hostname&gt;*-wedge\_k3s-config** | Kubernetes information | Configuration file used for adding Windows K3s nodes. |

### K8s specific logs

These logs are only available if the AKS Edge Essentials K8s version was installed, and **Linux** and/or **Windows** nodes were deployed.

| File name | Group | Description |
| --- | --- | --- |
| ***&lt;Windows-hostname&gt;*-ledge\_k8s** | Kubernetes information | Logs of K8s Linux system service (`sudo journalctl -u kubelet`). |
| ***&lt;Windows-hostname&gt;*-wedge\_k8s** | Kubernetes information | Logs of K8s Windows system service (`C:\tmp\kubelet.log`). |
| ***&lt;Windows-hostname&gt;*-wedge\_k8s-config** | Kubernetes information | Configuration file used for adding Windows K8s node. |