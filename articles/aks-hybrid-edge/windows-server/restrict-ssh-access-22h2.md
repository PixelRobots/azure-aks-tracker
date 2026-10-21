---
layout: Conceptual
title: Restrict SSH access to virtual machines in AKS on Windows Server | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/restrict-ssh-access-22h2
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
description: Learn how to restrict SSH access in AKS on Windows Server.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2023-04-27T00:00:00.0000000Z
ms.reviewer: oadeniji
ms.custom: windows-server
locale: en-us
document_id: ed4987bd-513c-d97d-ae1f-f77ceab59d09
document_version_independent_id: 79064f6b-e74e-f77a-840d-cd444fdc4f58
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/restrict-ssh-access-22h2.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/restrict-ssh-access-22h2
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/restrict-ssh-access-22h2.md
platformId: c3f6a838-08f3-dc56-2e59-c41de2ed0f23
---

# Restrict SSH access to virtual machines in AKS on Windows Server | Microsoft Learn

> 
> Applies to: AKS on Windows Server

This article describes a new security feature in AKS that restricts Secure Shell Protocol (SSH) access to underlying virtual machines (VMs). The feature limits access to only certain IP addresses, and restricts the set of commands that you can run over SSH.

## Overview

Currently, anyone with administrator access to AKS on Windows Server has access to VMs through SSH on any machine. In some scenarios, you might want to limit that access, because unlimited access makes it difficult to pass compliance.

Note

Currently, this capability is available only for a new installation of AKS, and not for upgrades. Only a new installation of AKS can pass the restricted IPs and restrict the commands that run over SSH.

## Enable SSH restrictions

To enable SSH restrictions, perform the following steps:

1. Create an SSH configuration using the [New-AksHciSSHConfiguration](/en-us/azure/aks/aksarc/reference/ps/new-akshcisshconfiguration) cmdlet, with the allowed source IP addresses or CIDR you want to permit access to the VMs:

    ```powershell
    $ssh = New-AksHciSSHConfiguration -name sshConfig -cidr 172.16.0.0/24
    ```

    or

    ```powershell
    $ssh = New-AksHciSSHConfiguration -name sshConfig -ipAddresses 4.4.4.4,8.8.8.8
    ```

    or, to restrict SSH access:

    ```powershell
    $ssh = New-AksHciSSHConfiguration -name sshConfig –restrictSSHCommands 
    ```

    Note

    If the SSH keys aren't passed, the management cluster SSH keys are reused.
2. Add the SSH configuration by running the [Set-AksHciConfig](/en-us/azure/aks/aksarc/reference/ps/set-akshciconfig) cmdlet, passing in the SSH configuration you created in the previous step:

    ```powershell
    Set-AksHciConfig -ssh $ssh
    ```

### Validation: target cluster

Once you create the cluster, you can manually validate that the SSH restriction was added by trying to SSH into one of the VMs. For example:

```powershell
ssh -i (get-MocConfig).sshPrivateKey clouduser@<vm-ipaddress>
```

You can perform this step within the list of IP addresses/CIDRs specified, or outside the list of IP addresses. The SSH from within the range of IP addresses/CIDRs has access. SSH attempts from outside the list do not have access.

You can also run commands directly from SSH. This command returns the date. `Sudo` commands don't work:

```powershell
ssh -i (get-mocconfig).sshPrivateKey clouduser@<ip> date 
```

### Validation: log collection

This command returns the VM logs such as `cloudinit`, `lb` logs, etc.

```powershell
Get-AksHciLogs –virtualMachineLogs
```

### Considerations

- Individual SSH configuration for workload clusters is now available. The configuration for workload clusters uses the [New-AksHciSSHConfiguration](/en-us/azure/aks/aksarc/reference/ps/new-akshcisshconfiguration) PowerShell cmdlet.
- The restriction is only for Linux. Windows nodes don't have this restriction; you should be able to SSH successfully.
- You can only set the configuration during the installation phase of AKS.
- You must perform a reinstall if you incorrectly configure any SSH settings.
- There is no support for upgrades.
- You can add CIDRs or IP addresses to which the SSH access can be restricted.
- The SSH setting you provide is reused for all target clusters. Individual SSH configuration for workload clusters isn't available.