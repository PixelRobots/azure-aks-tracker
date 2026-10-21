---
layout: Conceptual
title: Connect with SSH to Azure Kubernetes Service nodes | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/ssh-connection
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
description: Learn how to use Secure Shell Protocol (SSH) to connect to worker nodes for maintenance and troubleshooting in AKS on Windows Server.
author: davidsmatlak
ms.topic: how-to
ms.custom: linux-related-content, windows-server
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-01-14T00:00:00.0000000Z
ms.reviewer: srikantsarwa
locale: en-us
document_id: cab910f2-a9e4-753a-89ad-1dcb8b805ad5
document_version_independent_id: f9c48731-b326-837d-8bcc-1180a5083bc5
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/ssh-connection.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/ssh-connection
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/ssh-connection.md
platformId: 37d008c3-7963-21f0-3116-97df372d08d6
---

# Connect with SSH to Azure Kubernetes Service nodes | Microsoft Learn

> 
> Applies to: AKS on Windows Server

You might need to access Windows or Linux worker nodes in AKS on Windows Server for maintenance, log collection, or other troubleshooting operations. For security purposes, you must create a Secure Shell Protocol (SSH) connection to access the Windows or Linux worker nodes. To use SSH, you sign in using the node's IP address.

This article describes how to create an SSH connection to access both Windows and Linux nodes.

## Use SSH to connect to Windows worker nodes

To use SSH to sign in to a Windows worker node, run `kubectl get` to obtain the IP address of your node and capture the `EXTERNAL-IP` value.

Note

You must pass the correct location to your SSH private key. The following example uses the default location of **%systemdrive%\akshci.ssh\akshci\_rsa**, but you might need to change this location if you requested a different path. To change the location, specify the `-sshPublicKey` parameter for [Set-AksHciConfig](/en-us/azure/aks/aksarc/reference/ps/set-akshciconfig).

To obtain the IP address of the Windows worker node, run the following command:

```cmd
kubectl --kubeconfig=yourkubeconfig get nodes -o wide
```

Next, run `ssh Administrator@ip` to connect to a Windows node:

```cmd
ssh -i $env:SYSTEMDRIVE\AksHci\.ssh\akshci_rsa administrator@<IP Address of the Node>
```

After you use SSH to connect to the node, you can run `net user administrator *` to update your administrator password.

## Use SSH to connect to Linux worker nodes

To use SSH to sign in to a Linux worker node, first run `kubectl get` to obtain the IP address of your node and capture the `EXTERNAL-IP` value.

Note

You must pass the correct location to your SSH private key. The following example uses the default location of **%systemdrive%\akshci.ssh\akshci\_rsa**, but you might need to change this location if you requested a different path. To change the location, specify the `-sshPublicKey` parameter for [Set-AksHciConfig](/en-us/azure/aks/aksarc/reference/ps/set-akshciconfig).

To get the IP address of the Linux worker node:

```cmd
kubectl --kubeconfig=yourkubeconfig get nodes -o wide
```

Use `ssh clouduser@ip` to connect to the Linux node:

```cmd
ssh -i $env:SYSTEMDRIVE\AksHci\.ssh\akshci_rsa clouduser@<IP Address of the Node>
```

After you use SSH to connect to the node, you can run `net user administrator *` to update your administrator password.