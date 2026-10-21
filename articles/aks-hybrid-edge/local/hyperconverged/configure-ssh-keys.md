---
layout: Conceptual
title: Configure SSH keys for a cluster in AKS Hybrid and Edge | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/configure-ssh-keys
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
description: Learn how to configure SSH keys for an AKS cluster.
ms.date: 2026-09-01T00:00:00.0000000Z
ms.topic: how-to
author: davidsmatlak
ms.author: davidsmatlak
ms.reviewer: leslielin
ms.lastreviewed: 2025-01-10T00:00:00.0000000Z
ms.custom: hyperconverged
locale: en-us
document_id: a01f17b4-fe1c-c541-bb20-e27f39ee4047
document_version_independent_id: 6d549bba-32a9-c6d3-1473-eaa98b916f95
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/configure-ssh-keys.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/configure-ssh-keys
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/configure-ssh-keys.md
platformId: 5bdf5093-f0bb-1d6e-48f9-55052112ca9a
---

# Configure SSH keys for a cluster in AKS Hybrid and Edge | Microsoft Learn

> 
> Applies to: AKS on Azure Local

[Secure Shell Protocol (SSH)](https://www.ssh.com/ssh/) is an encrypted connection protocol that provides secure sign-ins over unsecured connections. AKS on Azure Local supports access to a VM in your Kubernetes nodes over SSH using a public-private key pair, also known as *SSH keys*. For information about how to create and manage SSH keys, see [Create and manage SSH keys](/en-us/azure/virtual-machines/ssh-keys-azure-cli).

An SSH key is required when deploying an AKS cluster. When you create the cluster, you can either generate a new key pair or use an existing public key. This article explains how to use SSH keys for AKS clusters from Azure CLI and the Azure portal.

## Before you begin

To create an AKS cluster, ensure that you have the necessary details from your on-premises infrastructure administrator as described in [Create Kubernetes clusters](../aks-create-clusters-cli#before-you-begin).

## Azure CLI

Use the [az aksarc create](/en-us/cli/azure/aksarc#az-aksarc-create) command to create an AKS cluster with an SSH public key. To generate a new key, pass the `--generate-ssh-key` parameter. To use an existing public key, specify the key or key file using the `--ssh-key-value` parameter. To restrict SSH access to specific IP addresses, use the `--ssh-auth-ips` argument. For instructions, see [restrict SSH access to virtual machines](restrict-ssh-access).

| SSH parameter | Description |
| --- | --- |
| `--generate-ssh-key` | - Required parameter if no preexisting SSH key exists on your local machine. When you specify `--generate-ssh-key`, Azure CLI automatically generates a set of SSH keys and saves them in the default directory **~/.ssh/**. - If you already have an SSH key on your local machine, the AKS cluster reuses that key. In this scenario, whether you specify `--generate-ssh-keys` or omit the parameter entirely, it has no effect. |
| `--ssh-key-value` | - Public key path or key contents for SSH access to node VMs. For example: **ssh-rsa AAAAB ... UcyupgH azureuser@linuxvm**. - By default, this key is located in **~/.ssh/id\_rsa.pub**. You can specify a different location using the `--ssh-key-value` parameter during cluster creation. |
| `--ssh-auth-ips` | A comma-separated list of IP addresses or CIDR ranges that are allowed to SSH into the cluster VM. |

The following examples show how to use this command:

- To create an AKS cluster and use the default generated SSH keys:

    ```azurecli
    az aksarc create -n $<aks_cluster_name> -g $<resource_group_name> --custom-location $<customlocation_ID> --vnet-ids $<logicnet>_Id --aad-admin-group-object-ids <entra-admin-group-object-ids> --generate-ssh-keys
    ```
- To create an AKS cluster using a pre-generated SSH key:

    1. Generate the SSH key. For more information, see [Generate and store SSH keys with the Azure CLI](/en-us/azure/virtual-machines/ssh-keys-azure-cli#generate-new-keys):

        ```azurecli
        az sshkey create --name "mySSHKey" --resource-group $<resource_group_name>
        ```
    2. Create an AKS cluster with a pre-generated SSH key:

        ```azurecli
        az aksarc create -n $<aks_cluster_name> -g $<resource_group_name> --custom-location $<customlocation_ID> --vnet-ids $<logicnet_Id> --aad-admin-group-object-ids <entra-admin-group-object-ids> --ssh-key-value $pubkey.publickey
        ```
- To specify an SSH public key file, include the `--ssh-key-value` parameter:

    ```azurecli
    az aksarc create -n $<aks_cluster_name> -g $<resource_group_name> --custom-location $<customlocation_ID> --vnet-ids $<logicnet_Id> --aad-admin-group-object-ids <entra-admin-group-object-ids> --generate-ssh-keys --ssh-key-value ~/.ssh/id_rsa.pub
    ```

## Azure portal

For information about how to create new SSH keys from the Azure portal, see [Create and manage SSH keys in the portal](/en-us/azure/virtual-machines/ssh-keys-portal#generate-new-keys).

When you create an AKS cluster using the Azure portal, provide the necessary information as described in [Create a Kubernetes cluster](../aks-create-clusters-portal#create-a-kubernetes-cluster). You can configure your SSH key in the **Administrator account** section under the **Basic** tab.

You have three options for SSH key configuration:

- Generate a new key pair.
- Use an existing key stored in Azure and select from the stored keys.
- Use an existing public key by providing the SSH public key value.

## Error messages

For information about error messages that can occur when you create and deploy an AKS cluster on Azure Local, see the [Control plane configuration validation errors](control-plane-validation-errors) article.