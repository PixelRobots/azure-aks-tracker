---
layout: Conceptual
title: Toggle SELinux Mode on Azure Container Linux (ACL) Node Pools for Troubleshooting | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/selinux-toggle-troubleshoot
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/133/azure
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/79b1327d-d925-ec11-b6e6-000d3a4f06a4
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
manager: kumud
description: Guidance on how to switch SELinux (Security-Enhanced Linux) from enforcing mode to permissive mode on Azure Container Linux (ACL) nodes in Azure Kubernetes Service (AKS) for troubleshooting purposes, including identifying symptoms, understanding causes, and applying solutions.
author: flora-taagen
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: how-to
ms.date: 2026-05-12T00:00:00.0000000Z
locale: en-us
document_id: 81628662-b048-ef0a-e6e8-bea52dd69907
document_version_independent_id: 37960295-185f-1210-03b1-7c2525e8ff68
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/selinux-toggle-troubleshoot.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/selinux-toggle-troubleshoot
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/selinux-toggle-troubleshoot.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: a77de6c0-852f-80c9-cefa-1063ed9c4d2e
---

# Toggle SELinux Mode on Azure Container Linux (ACL) Node Pools for Troubleshooting | Microsoft Learn

This article shows you how to switch SELinux (Security-Enhanced Linux) from *enforcing mode* to *permissive mode* on Azure Container Linux (ACL) nodes in Azure Kubernetes Service (AKS) for troubleshooting purposes. This can be useful when you need to collect diagnostics or validate workload behavior that is being blocked by SELinux enforcement on ACL nodes.

## Symptom

You need to collect diagnostics or validate workload behavior, but SELinux enforcement blocks the action on ACL nodes.

## Cause

ACL nodes run SELinux in enforcing mode by default. To change behavior, you must apply the ACL security profile tag on the node pool.

## Prerequisites

- Azure CLI installed and signed in.
- You know your AKS cluster name, resource group, and node pool name.
- You can access a node for verification. For details, see [Connect to AKS nodes with kubectl debug](/en-us/azure/aks/node-access#connect-with-kubectl-debug).

## Resolution

To switch SELinux from enforcing mode to permissive mode on ACL nodes, you can either **create a new ACL node pool** or **update an existing ACL node pool** with the appropriate tag. The tag to set is `acl-node-security-profile=selinux=permissive`.

### Option 1: Create a new ACL node pool in permissive mode

1. Create a new ACL node pool in *permissive mode* using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command with the `--tags` parameter to set the ACL security profile tag.

    ```azurecli
    az aks nodepool add \
      --resource-group <resource-group-name> \
      --cluster-name <cluster-name> \
      --name <node-pool-name> \
      --node-count 1 \
      --tags acl-node-security-profile="selinux=permissive" \
      --no-wait
    ```
2. Verify the tag was applied using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command to check the node pool profiles and their tags.

    ```azurecli
    az aks show \
      --resource-group <resource-group-name> \
      --name <cluster-name> \
      --query "agentPoolProfiles[].{nodepoolName:name,tags:tags}"
    ```

    Example output:

    ```output
    [
      {
        "nodepoolName": "<node-pool-name>",
        "tags": {
          "acl-node-security-profile": "selinux=permissive"
        }
      }
    ]
    ```

### Option 2: Update an existing ACL node pool

1. Update an existing ACL node pool to *permissive mode* using the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command with the `--tags` parameter to set the ACL security profile tag.

    ```azurecli
    az aks nodepool update \
      --resource-group <resource-group-name> \
      --cluster-name <cluster-name> \
      --name <node-pool-name> \
      --tags acl-node-security-profile="selinux=permissive" \
      --no-wait
    ```
2. Verify the tag was applied using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command to check the node pool profiles and their tags.

    ```azurecli
    az aks show \
      --resource-group <resource-group-name> \
      --name <cluster-name> \
      --query "agentPoolProfiles[].{nodepoolName:name,tags:tags}"
    ```

    Example output:

    ```output
    [
      {
        "nodepoolName": "<node-pool-name>",
        "tags": {
          "acl-node-security-profile": "selinux=permissive"
        }
      }
    ]
    ```
3. Restart the nodes in the node pool so the new SELinux mode takes effect.

## Verification

1. Connect to a node in the target pool using `kubectl debug` and chroot into the host filesystem.
2. Run the `sestatus` command to check the current SELinux mode:

    ```bash
    sestatus
    ```

    In the output, confirm `Current mode` shows `permissive`. For example:

    ```output
    SELinux status:                 enabled
    SELinuxfs mount:                /sys/fs/selinux
    SELinux root directory:         /etc/selinux
    Loaded policy name:             targeted
    Current mode:                   permissive
    Mode from config file:          permissive
    Policy MLS status:              enabled
    Policy deny_unknown status:     allowed
    Memory protection checking:     actual (secure)
    Max kernel policy version:      33
    ```