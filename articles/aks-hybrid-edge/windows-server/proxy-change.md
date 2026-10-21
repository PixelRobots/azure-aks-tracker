---
layout: Conceptual
title: Update noProxy settings, certificates in Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/proxy-change
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
description: Learn how to update proxy settings and certificates in AKS on Windows Server.
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-05-31T00:00:00.0000000Z
ms.reviewer: srikantsarwa
ms.custom: windows-server
author: davidsmatlak
locale: en-us
document_id: 849571be-bcfa-910d-6c9a-bb879d42686a
document_version_independent_id: d604abd9-113b-78e3-8cf6-4ee49e0c8cea
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/proxy-change.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/proxy-change
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/proxy-change.md
platformId: 15dd26af-047a-ef16-4b69-3698eedef332
---

# Update noProxy settings, certificates in Azure Kubernetes Service | Microsoft Learn

> 
> Applies to: AKS on Windows Server

This article describes how to update proxy settings and certificates for your deployment in AKS on Windows Server. Each AKS deployment has a single global proxy configuration. You can add exclusions using the `noProxy` parameter to exclude private subnets (for example, contoso.com) from using the proxy server, and you can update proxy certificates for the deployment. You can't change HTTP or HTTPS settings.

For information about the initial proxy server setup, see [Use proxy server settings in AKS](set-proxy-settings).

## Proxy settings you can update

Before you begin, review current limitations to proxy setting updates you can perform in AKS on Windows Server:

- AKS on Windows Server supports one global proxy configuration per AKS deployment. When you update the proxy settings, they're updated for the entire AKS deployment.
- You can only update `noProxy` settings, which are used to exclude a private subnet from using the proxy server, and proxy certificates. HTTP and HTTPs proxy settings can't be updated.
- You can't configure different proxy settings for a specific node pool or workload cluster. Similarly, you can't update proxy settings for a specific node pool or workload cluster.
- Updates to proxy settings are only applied after you update your entire AKS deployment. You must update the AKS host management cluster and all AKS workload clusters. To check whether an update is available, use the AKS PowerShell module cmdlet [Get-AksHciClusterUpdates](/en-us/azure/aks/aksarc/reference/ps/get-akshciclusterupdates).

## Prerequisites

Before you update proxy settings for an AKS deployment, you must meet the following prerequisites:

- Your AKS deployment is running the [October 2022 update](https://github.com/Azure/aks-hybrid/releases/tag/AKS-hybrid-2210) or later.
- The most recent version of the AksHci PowerShell module is installed. For more information, see [Install the AksHci PowerShell module](kubernetes-walkthrough-powershell#install-the-akshci-powershell-module).
- At least one update is available for your AKS deployment. Updates to proxy settings and certificates are applied automatically after updates are applied to an AKS deployment. To check for available updates, run the [`Get-AksHciClusterUpdates`](/en-us/azure-stack/aks-hci/reference/ps/get-akshciclusterupdates) command in the AksHci PowerShell module.

## Step 1: Create a new noProxy exclusion list

You might occasionally need to update `noProxy` settings to exclude a private subnet from using the proxy server for your AKS deployment. To prepare to update the `noProxy` settings, store a new exclusion list in a PowerShell variable.

1. Before you update your `noProxy` settings, review the required `noProxy` settings in the [proxy exclusion table](set-proxy-settings#exclusion-list-for-excluding-private-subnets-from-being-sent-to-the-proxy). For more information, see [Exclusion list for excluding private subnets from being sent to the proxy](set-proxy-settings#exclusion-list-for-excluding-private-subnets-from-being-sent-to-the-proxy).

    Certain exclusions are required for your AKS deployment to function. Not excluding these URLs can cause failures in your AKS deployment.
2. Store your updated `noProxy` URL list in a PowerShell variable:

    ```powershell
    $noProxy = "localhost,127.0.0.1,.svc,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,.contoso.com"
    ```

## Step 2: Create a proxy certificate bundle

To update certificates for your proxy server, create a new certificate bundle and then store the path to the file in a PowerShell variable. Bundle the certificates in a single .crt file in PEM format. This format is applicable for updating certificates on Linux container hosts.

To bundle your updated proxy server certificates:

1. Create a single .crt file with the bundled certificates for Linux hosts. Use the `concatenate` (`cat`) command with the following format:

    ```bash
    cat [leaf].crt  [intermediate].crt  [Root].crt > [bundle].crt
    ```

    You must concatenate the certificates in the order of: **leaf certificate &gt; intermediate certificate &gt; root certificate**. For detailed certificate requirements and an example, see [Update certificate bundle for your AKS deployment](update-certificate-bundle#certificate-format).

    Note

    The contents of the certificate file aren't validated. Check carefully to ensure the file contains the right certificates and is in the correct format.
2. Store the path to your updated certificate bundle in a PowerShell variable:

    ```powershell
    $certFile ="/../[certificate-bundle].crt" # path to the bundled .crt file
    ```

## Step 3: Update proxy settings

The next step is to use the `Set-AksHciProxySetting` command to update your `noProxy` settings and certificates.

1. Before you update the proxy settings and certificates, confirm that your PowerShell variables have the right changes:

    ```powershell
    echo $noProxy
    echo $certFile
    ```
2. To update both your proxy settings and proxy certificates, run the following command:

    ```powershell
    Set-AksHciProxySetting -noProxy $noProxy -certFile $certFile
    ```

## Step 4: Apply updated proxy settings to your AKS deployment

The updates to your global proxy settings and certificate are applied automatically after you update the AKS deployment.

To apply the proxy updates:

1. Check whether an update is available for your AKS host management cluster by running the following command:

    ```powershell
    Get-AksHciUpdates
    ```
2. If an update is available, update your AKS host management cluster by running the following command. This command applies the proxy changes on your AKS host management cluster:

    ```powershell
    Update-AksHci
    ```
3. Update all of the workload clusters in your AKS deployment. Proxy changes won't be applied unless you update your workload clusters.

    1. To check whether workload cluster updates are available, run the following command on each of your AKS workload clusters:

        ```powershell
        Get-AksHciClusterUpdates -name mycluster
        ```
    2. If an update is available (either a Kubernetes version or an updated OS image), update each of your workload clusters by running the `Update-AksHciCluster` command.

        - To update the Kubernetes version and OS version on a workload cluster, run the following command:

            ```powershell
            Update-AksHciCluster -name mycluster
            ```
        - To update the OS without updating the Kubernetes version, include the `-operatingSystem` parameter:

            ```powershell
            Update-AksHciCluster -name mycluster -operatingSystem
            ```

            If an OS image-only update isn't available for your workload cluster, you won't be able to apply the proxy changes unless you update the Kubernetes version.