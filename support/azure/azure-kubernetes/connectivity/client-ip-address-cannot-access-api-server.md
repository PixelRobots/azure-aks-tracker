---
layout: Conceptual
title: Client IP address can't access the API server - Azure | Microsoft Learn
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
ms.date: 2024-10-08T00:00:00.0000000Z
ms.reviewer: rissing, chiragpa, jaewonpark, v-leedennis, v-weizhu
ms.service: azure-kubernetes-service
ms.custom: sap:Connectivity, innovation-engine
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
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 93ff716f-0584-ef2c-048c-339d6bb4085b
---

# Client IP address can't access the API server - Azure | Microsoft Learn

## Summary

This article explains how to troubleshoot when a client IP address can't access the AKS API server so you can reconnect to your Azure Kubernetes Service (AKS) cluster.

## Prerequisites

- [Azure CLI](/en-us/cli/azure/install-azure-cli).
- The client URL ([curl](https://techcommunity.microsoft.com/t5/containers/tar-and-curl-come-to-windows/ba-p/382409)) tool.

## Symptoms

# [Azure portal](#tab/azure-portal)
When you try to access Kubernetes resources such as mamespaces and workloads from the Azure portal, you might encounter the following errors:

> 
> Network error
> 
> Unable to reach the api server 'https://&lt;API-server-FQDN&gt;' or api server is too busy to respond. Check your network settings and refresh to try again.

[![Screenshot of the AKS portal view showing a network error when connecting to the API server from namespaces and workloads.](media/client-ip-address-cannot-access-api-server/network-error.png)](media/client-ip-address-cannot-access-api-server/network-error.png#lightbox)

# [Azure CLI](#tab/azure-cli)
When you try to connect to a cluster using the Azure CLI, you might see the following errors:

```output
"Unhandled Error" err="couldn't get current server API group list: Get \"https://<API-SERVER-FQDN>:443/api?timeout=32s\": dial tcp <API-SERVER-IP>:443: i/o timeout"

Unable to connect to the server: dial tcp <API-SERVER-IP>:443: i/o timeout

Unable to connect to the server: dial tcp <API-SERVER-IP>:443: connectex: A connection attempt failed because the connected party did not properly respond after a period, or established connection failed because connected host has failed to respond.
```

---

## Cause

[API server-authorized IP ranges](/en-us/azure/aks/api-server-authorized-ip-ranges) may have been enabled on the cluster's API server, but the client's IP address wasn't included in the IP ranges. To check whether this feature has been enabled, see if the following [az aks show](/en-us/cli/azure/aks#az-aks-show) command in Azure CLI produces a list of IP ranges:

```azurecli
az aks show --resource-group ${RG_NAME} \
    --name ${CLUSTER_NAME} \
    --query apiServerAccessProfile.authorizedIpRanges
```

## Solution

Look at the cluster's API server-authorized ranges, and add your client's IP address within that range.

Note

1. Do you access the API server from a corporate network where traffic is routed through a proxy server or firewall? Then ask your network administrator before you add your client IP address to the list of authorized ranges for the API server.
2. Also ask your cluster administrator before you add your client IP address, because there might be security concerns with adding a temporary IP address to the list of authorized ranges.

# [Azure portal](#tab/azure-portal)
1. Navigate to the cluster from the Azure portal.
2. In the left menu, locate **Settings** and then select **Networking**.
3. On the **Networking** page, select the **Overview** tab.
4. Select **Manage** under **Resource settings**.
5. In the **Authorized IP ranges** pane, add your client IP address as shown in the following screenshot:

    [![Screenshot of Authorized-ip-ranges pane.](media/client-ip-address-cannot-access-api-server/authorized-ip-ranges.png)](media/client-ip-address-cannot-access-api-server/authorized-ip-ranges.png#lightbox)

# [Azure CLI](#tab/azure-cli)
1. Get your client IP address by running this [curl](https://curl.se/docs/manpage.html) command:

    ```azurecli
    export CLIENT_IP=$(curl --silent https://ipinfo.io/ip | tr -d '\n')
    echo $CLIENT_IP
    ```

    Results:

    ```output
    0.255.127.63
    ```
2. Update the API server-authorized range with the [az aks update](/en-us/cli/azure/aks#az-aks-update) command in Azure CLI, using your client IP address:

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