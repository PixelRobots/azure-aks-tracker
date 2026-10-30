---
layout: Conceptual
title: Client IP address cant access the API server for AKS - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/client-ip-address-cannot-access-api-server
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: kaushika-msft
ms.author: kaushika
ms.topic: troubleshooting
description: Learn how to troubleshoot when a client IP address can't access the AKS API server and restore cluster connectivity quickly. Try these steps now.
ms.date: 2026-10-30T00:00:00.0000000Z
ms.reviewer: rissing, chiragpa, jaewonpark, v-leedennis, v-weizhu, kaushika
ms.service: azure-kubernetes-service
ms.custom: sap:Connectivity, innovation-engine
ai-usage: ai-assisted
locale: en-us
document_id: 7a7da520-1aff-2aaf-27ab-514f4c431b12
document_version_independent_id: 7a7da520-1aff-2aaf-27ab-514f4c431b12
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/connectivity/client-ip-address-cannot-access-api-server.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/connectivity/client-ip-address-cannot-access-api-server
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/connectivity/client-ip-address-cannot-access-api-server.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/fcc3cd4a-59ea-47a2-9cc1-784142a5a25d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7a55faf-a992-4e27-aa3a-eadc9830e778
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 93ff716f-0584-ef2c-048c-339d6bb4085b
---

# Client IP address cant access the API server for AKS - Azure | Microsoft Learn

## Summary

This article explains how to troubleshoot when a client IP address can't access the API server for Azure Kubernetes Service (AKS) so you can restore connectivity to your cluster.

## Prerequisites

Ensure the following prerequisites are met before troubleshooting access to the AKS API server:

- [Azure CLI](/en-us/cli/azure/install-azure-cli).
- The client URL ([curl](https://techcommunity.microsoft.com/t5/containers/tar-and-curl-come-to-windows/ba-p/382409)) tool.

## Symptoms

The following symptoms indicate that your client IP address can't access the AKS API server.

# [Azure portal](#tab/azure-portal)
When you try to access Kubernetes resources such as namespaces and workloads from the [Azure portal](https://portal.azure.com), you might encounter the following error.

> 
> Network error
> 
> Unable to reach the api server 'https://&lt;API-server-FQDN&gt;' or api server is too busy to respond. Check your network settings and refresh to try again.

[![Screenshot of the AKS portal view showing a network error when connecting to the API server from namespaces and workloads.](media/client-ip-address-cannot-access-api-server/network-error.png)](media/client-ip-address-cannot-access-api-server/network-error.png#lightbox)

# [Azure CLI](#tab/azure-cli)
When you try to connect to a cluster by using Azure CLI, you might see the following errors.

```output
"Unhandled Error" err="couldn't get current server API group list: Get \"https://<API-SERVER-FQDN>:443/api?timeout=32s\": dial tcp <API-SERVER-IP>:443: i/o timeout"

Unable to connect to the server: dial tcp <API-SERVER-IP>:443: i/o timeout

Unable to connect to the server: dial tcp <API-SERVER-IP>:443: connectex: A connection attempt failed because the connected party did not properly respond after a period, or established connection failed because connected host has failed to respond.
```

---

## Cause

You might have enabled [API server-authorized IP ranges](/en-us/azure/aks/api-server-authorized-ip-ranges) on the cluster's API server, but you didn't include the client's IP address in the IP ranges. To check whether this feature is enabled, see if the following [az aks show](/en-us/cli/azure/aks#az-aks-show) command in Azure CLI returns a list of IP ranges.

```azurecli
az aks show --resource-group ${RG_NAME} \
    --name ${CLUSTER_NAME} \
    --query apiServerAccessProfile.authorizedIpRanges
```

## Solution

Look at the cluster's API server-authorized ranges, and add your client's IP address within that range.

Note

Do you access the API server from a corporate network where traffic routes through a proxy server or firewall? If so, ask your network administrator before you add your client IP address to the list of authorized ranges for the API server. Also, ask your cluster administrator before you add your client IP address, because there might be security concerns with adding a temporary IP address to the list of authorized ranges.

# [Azure portal](#tab/azure-portal)
Follow these steps to add your client IP address to the authorized IP ranges for the AKS API server:

1. Go to the cluster in the Azure portal.
2. In the left menu, find **Settings** and then select **Networking**.
3. On the **Networking** page, select the **Overview** tab.
4. Select **Manage** under **Resource settings**.
5. In the **Authorized IP ranges** pane, add your client IP address as shown in the following screenshot.

    [![Screenshot of the Authorized IP ranges pane in the Azure portal where you add a client IP address to the AKS API server.](media/client-ip-address-cannot-access-api-server/authorized-ip-ranges.png)](media/client-ip-address-cannot-access-api-server/authorized-ip-ranges.png#lightbox)

# [Azure CLI](#tab/azure-cli)
Follow these steps to add your client IP address to the authorized IP ranges for the AKS API server using Azure CLI:

1. Get your client IP address by running this [curl](https://curl.se/docs/manpage.html) command.

    ```azurecli
    export CLIENT_IP=$(curl --silent https://ipinfo.io/ip | tr -d '\n')
    echo $CLIENT_IP
    ```

    Results:

    ```output
    0.255.127.63
    ```
2. Update the API server-authorized range with the [az aks update](/en-us/cli/azure/aks#az-aks-update) command in Azure CLI, using your client IP address.

    ```azurecli
    az aks update --resource-group $RG_NAME \
        --name $CLUSTER_NAME \
        --api-server-authorized-ip-ranges $CLIENT_IP
    ```

    Results:

    ```output
    {
      "apiServerAccessProfile": {
        "authorizedIpRanges": [
          "0.255.127.63/32"
        ],
        ...
      },
      ...
      "name": "aks-cluster-xxx",
      "resourceGroup": "aks-rg-xxx",
      ...
    }
    ```

---