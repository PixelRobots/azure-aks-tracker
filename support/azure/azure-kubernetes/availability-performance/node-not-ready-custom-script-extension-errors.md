---
layout: Conceptual
title: Troubleshoot CSE errors that prevent AKS nodes from provisioning - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/availability-performance/node-not-ready-custom-script-extension-errors
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
description: Learn how to troubleshoot custom script extension (CSE) errors that prevent new virtual machine scale set instances from registering as AKS nodes.
ms.date: 2026-09-17T00:00:00.0000000Z
ms.reviewer: shiyao, pihe, siyueli
ms.service: azure-kubernetes-service
ms.custom: sap:Node/node pool availability and performance, devx-track-azurecli, innovation-engine
ai-usage: ai-assisted
locale: en-us
document_id: fcd51a9c-806d-4866-c47e-dcd8f03218a8
document_version_independent_id: fcd51a9c-806d-4866-c47e-dcd8f03218a8
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/availability-performance/node-not-ready-custom-script-extension-errors.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/availability-performance/node-not-ready-custom-script-extension-errors
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/availability-performance/node-not-ready-custom-script-extension-errors.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/96f6b0a2-2fd7-4de1-936d-89ad6e0eb7cc
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/ef8b0a5a-ba0a-4ec0-8636-48246ccd954f
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: f961f5a8-4c18-1481-5f00-503c00a360cb
---

# Troubleshoot CSE errors that prevent AKS nodes from provisioning - Azure | Microsoft Learn

## Summary

This article describes how to troubleshoot scenarios in which Azure Kubernetes Service (AKS) fails to provision a new node because of a custom script extension (CSE) error.

## Prerequisites

Ensure that you have [Azure CLI](/en-us/cli/azure/install-azure-cli) installed and that it's updated to the latest version. Use `az --version` to check the installed version.

## Symptoms

A newly provisioned virtual machine scale set instance doesn't register as an AKS node. After a node pool scale-out operation, you might observe that the number of Virtual Machine Scale Sets (VMSS) instances increases while the number of Kubernetes nodes remains unchanged.

If the cluster autoscaler is enabled, it might remove the unregistered VMSS instance after a period of time.

## Troubleshooting

To identify the cause, retrieve the CSE exit code from the affected VMSS instance.

Use Azure CLI to perform the following steps:

1. Set the variables for the AKS cluster.

    ```azurecli
    export RG_NAME="<cluster-resource-group>"
    export CLUSTER_NAME="<cluster-name>"
    
    export NODE_RG=$(az aks show \
      --resource-group "$RG_NAME" \
      --name "$CLUSTER_NAME" \
      --query nodeResourceGroup \
      --output tsv)
    
    export API_FQDN=$(az aks show \
      --resource-group "$RG_NAME" \
      --name "$CLUSTER_NAME" \
      --query fqdn \
      --output tsv)
    ```
2. List the VM scale sets in the node resource group, and identify the VM scale set for the affected node pool.

    ```azurecli
    az vmss list \
      --resource-group "$NODE_RG" \
      --query "[].{Name:name,Capacity:sku.capacity,ProvisioningState:provisioningState}" \
      --output table
    
    export VMSS_NAME="<affected-vmss-name>"
    ```
3. Find the instance ID of the affected VMSS instance and export the value.

    ```azurecli
    export INSTANCE_ID="<affected-vmss-instance-id>"
    ```
4. Retrieve the CSE status from the affected instance.

    ```azurecli
    az vmss get-instance-view \
      --resource-group "$NODE_RG" \
      --name "$VMSS_NAME" \
      --instance-id "$INSTANCE_ID" \
      --query "extensions[?name=='vmssCSE'].statuses[].{
        ExtensionState:code,
        Details:message
      }" \
      --output json
    ```

    The following is example output.

    ```output
     [
       {
         "ExtensionState": "ProvisioningState/failed/0",
         "Details": "failed to execute command: command terminated with exit status=1\n[stdout]\n{ \"ExitCode\": \"51\", \"Output\": \"... Failed to connect to <AKS API server FQDN> port 443: Connection timed out ... API server connection check code: 51 ... exit 51\", ... }\n\n[stderr]\n..."
       }
     ]
    ```

Exit codes identify the specific issue that caused the provisioning failure. In the preceding example, CSE returns exit code `51`, which indicates a connectivity issue with the Kubernetes API server.

For mappings of other exit codes, see the [CSE helper](https://github.com/Azure/AgentBaker/blob/1bf9892afd715a34e0c6b7312e712047f10319ce/parts/linux/cloud-init/artifacts/cse_helpers.sh).

## Solution: Test and fix API network time-outs

Make sure that the API server is reachable from the affected VMSS instance. Check the following network configurations:

- Check whether the network security group (NSG) associated with the AKS subnet blocks outbound traffic to the API server IP address on TCP port 443.
- Check whether an additional NSG is associated with the VMSS network interface. Every applicable NSG must allow outbound traffic to the API server IP address on TCP port 443.
- Check whether a firewall or network virtual appliance (NVA) is in the outbound traffic path. An NVA is typically configured through a route table associated with the AKS node subnet. Ensure that the firewall or NVA allows outbound traffic to the API server IP address on TCP port 443. For more information, see [Control egress traffic for cluster nodes in AKS](/en-us/azure/aks/limit-egress-traffic).

To test connectivity from the VMSS instance to the API server, use Azure CLI to run the following commands.

```azurecli
az vmss run-command invoke \
  --resource-group "$NODE_RG" \
  --name "$VMSS_NAME" \
  --instance-id "$INSTANCE_ID" \
  --command-id RunShellScript \
  --scripts '
API_FQDN="'"$API_FQDN"'"

echo "=== DNS resolution ==="
getent ahostsv4 "$API_FQDN" |
  awk '"'"'NR==1 {print "Resolved IP: " $1}'"'"'

echo "=== TCP connectivity ==="
if timeout 10 bash -c "</dev/tcp/$API_FQDN/443"; then
  echo "TCP 443: connected"
else
  echo "TCP 443: failed"
fi

echo "=== HTTPS response ==="
curl -sS -k \
  --connect-timeout 10 \
  --max-time 15 \
  --output /dev/null \
  --write-out \
"HTTP status: %{http_code}
Remote IP: %{remote_ip}
Connect time: %{time_connect}s
TLS time: %{time_appconnect}s
" \
  "https://$API_FQDN/"
' \
  --query "value[0].message" \
  --output tsv
```

The command tests Domain Name System (DNS) resolution, Transmission Control Protocol (TCP) connectivity, and HTTPS connectivity. If the connection succeeds, the output should resemble the following example.

```output
Enable succeeded:
[stdout]
=== DNS resolution ===
Resolved IP: 172.199.220.208
=== TCP connectivity ===
TCP 443: connected
=== HTTPS response ===
HTTP status: 401
Remote IP: 172.199.220.208
Connect time: 0.018883s
TLS time: 0.058870s

[stderr]
```

An HTTP `401` response is expected because the request doesn't include authentication credentials. The response confirms that DNS resolution, the TCP connection, and the TLS handshake succeeded and that the API server is reachable.

If the connection times out, the output should resemble the following example.

```output
Enable succeeded:
[stdout]
=== DNS resolution ===
Resolved IP: 20.238.162.102
=== TCP connectivity ===
TCP 443: failed
=== HTTPS response ===
HTTP status: 000
Remote IP:
Connect time: 0.000000s
TLS time: 0.000000s

[stderr]
curl: (28) Connection timeout after 10000 ms
```

If the connection times out, the VMSS instance can't reach the API server on TCP port 443. Check the effective NSG rules, user-defined routes, firewalls, NVAs, and other network devices that might block the connection.

## References

- For general troubleshooting steps, see [Basic troubleshooting of Node Not Ready failures](node-not-ready-basic-troubleshooting).