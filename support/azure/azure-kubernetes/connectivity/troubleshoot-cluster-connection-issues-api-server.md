---
layout: Conceptual
title: Troubleshoot cluster connection issues with the API server - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/troubleshoot-cluster-connection-issues-api-server
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
description: Troubleshoot AKS API server connection issues by checking network, authentication, and authorization paths. Follow these steps to restore access fast.
ms.date: 2026-08-20T00:00:00.0000000Z
ms.reviewer: zhixinsun, shiyao, pihe
ms.service: azure-kubernetes-service
ms.custom: sap:Connectivity,innovation-engine
ai-usage: ai-assisted
locale: en-us
document_id: b0a5a416-4de7-9cf0-30d0-32dcc6a3a486
document_version_independent_id: b0a5a416-4de7-9cf0-30d0-32dcc6a3a486
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/connectivity/troubleshoot-cluster-connection-issues-api-server.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/connectivity/troubleshoot-cluster-connection-issues-api-server
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/connectivity/troubleshoot-cluster-connection-issues-api-server.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: efe9b797-0a63-efaa-a6ca-1cdf560b6d9c
---

# Troubleshoot cluster connection issues with the API server - Azure | Microsoft Learn

## Summary

This article helps you troubleshoot Azure Kubernetes Service (AKS) cluster connection issues with the API server when [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) or REST clients can't connect. The troubleshooting flow checks Domain Name System (DNS) resolution, network connectivity, and authentication and authorization in order.

## Prerequisites

- [Azure CLI](/en-us/cli/azure/install-azure-cli).
- [kubectl](https://kubernetes.io/docs/tasks/tools/).
- [curl](https://curl.se/docs/manpage.html).
- [nslookup](/en-us/windows-server/administration/windows-commands/nslookup).
- For a private cluster, a client that has network connectivity to the cluster virtual network.

## Root cause and solutions

Troubleshoot the connection in the following stages. Complete each stage before you continue to the next stage:

- **Stage 1: DNS resolution**
- **Stage 2: Network connectivity**
- **Stage 3: Authentication and authorization**

### Before you begin

1. Use [az aks show](/en-us/cli/azure/aks#az-aks-show) to identify the API server access model and the FQDN that the client should use.

    ```azurecli
    az aks show \
      --resource-group <resource-group> \
      --name <cluster-name> \
      --query "{
        provisioningState:provisioningState,
        powerState:powerState.code,
        fqdn:fqdn,
        privateFqdn:privateFqdn,
        privateCluster:apiServerAccessProfile.enablePrivateCluster,
        apiServerVnetIntegration:apiServerAccessProfile.enableVnetIntegration,
        authorizedIpRanges:apiServerAccessProfile.authorizedIpRanges
      }" \
      --output yaml
    ```

    If this command fails, verify the Azure tenant, subscription, resource group, and permissions.

    Confirm that `provisioningState` is `Succeeded` and `powerState` is `Running`.

    Use `fqdn` for a public API server. If `privateCluster` is `true`, use `privateFqdn` from a network that has connectivity to the cluster virtual network. You can take these common troubleshooting steps to check the connectivity to the AKS cluster's API server:

### Stage 1: DNS resolution

1. Resolve the FQDN from step 1.

    ```bash
    nslookup <cluster-fqdn>
    ```

    - For a public API server, verify that the public FQDN resolves to a public IP address.
    - For a private API server, verify that the private FQDN resolves to a private IP address from the connected network.
    - If private name resolution fails, verify the private DNS zone link, custom DNS conditional forwarders, or Azure DNS Private Resolver configuration before you continue.

    Note

    When you stop and start an AKS cluster, the API server's IP address can change while the FQDN stays the same. If connection issues begin after a stop/start operation, flush the relevant DNS caches and resolve the FQDN again. For more information, see [Stop and start an Azure Kubernetes Service (AKS) cluster](/en-us/azure/aks/start-stop-cluster#about-the-cluster-stopstart-feature).

    Continue to Stage 2 only after the FQDN resolves to the expected address.

### Stage 2: Network connectivity

1. Use a timed `curl` request to test HTTPS connectivity to the API server.

# [Bash](#tab/bash)
```bash
    curl -kv --connect-timeout 5 --max-time 15 https://<cluster-fqdn>/version
    ```

# [PowerShell](#tab/powershell)
```powershell
    curl.exe -kv --connect-timeout 5 --max-time 15 https://<cluster-fqdn>/version
    ```

---

    Note

    The `-k` option skips certificate validation. Use it only for this connectivity test.

    - `curl: (28) Connection timed out` after DNS succeeds means that the TCP connection to port 443 wasn't established. Continue to step 4 for a private endpoint or step 5 for a public endpoint.
    - `HTTP 401 Unauthorized` from `/version` confirms that network connectivity works and that the unauthenticated request reached the API server. Continue to Stage 3.
2. If the client targets a private endpoint, including a private cluster or an [API Server VNet Integration](/en-us/azure/aks/api-server-vnet-integration) cluster in private mode, and the request times out, verify the private network path.

    **Understand the access path:**

    - A private API server requires private network connectivity. A public FQDN on a private cluster doesn't make the API server publicly reachable.
    - With API Server VNet Integration, node-to-API-server connectivity is separate from the path used by an external client.

    **Verify the client path:**

    1. Confirm that the client network connects to the cluster virtual network through virtual network peering, VPN, ExpressRoute, or another supported private path.
    2. Verify that routes, network security groups, firewalls, and other network virtual appliances allow TCP port 443 from the client to the private API server IP.
    3. Repeat the timed `curl` request after you correct the private network path.

    **Optional isolation test:**

    If direct private connectivity isn't available, use [Run Command options for connecting to the private cluster](/en-us/azure/aks/access-private-cluster). If Run Command succeeds, focus the investigation on the client's private network path. Run Command requires separate Azure permissions and can also be affected by policy or pod scheduling.
3. If the client targets a public API server and the request times out, check the client's outbound path and the API server's authorized IP ranges.

    ```azurecli
    az aks show \
      --resource-group <resource-group> \
      --name <cluster-name> \
      --query apiServerAccessProfile.authorizedIpRanges
    ```

    - If the result is `null` or empty, authorized IP ranges aren't enabled. Check the client's routing, VPN, proxy, and firewall rules for outbound TCP port 443.
    - If ranges are configured, follow [Client IP address can't access the API server](client-ip-address-cannot-access-api-server) to verify and update the client's actual source public IP. Consider management networks, VPN or firewall source network address translation (SNAT), automation agents, cluster egress addresses, and node public IP prefixes.

    Allow time for an update to propagate, and repeat the timed `curl` request. During propagation, individual connections can produce different results, so don't declare recovery or failure from a single request.

### Stage 3: Authentication and authorization

1. After the `curl` request returns `HTTP 401 Unauthorized`, use `kubectl` to validate the credentials in kubeconfig and the user's access to cluster resources.

    ```bash
    kubectl get --raw=/version --request-timeout=10s
    kubectl get nodes --request-timeout=10s
    ```

    - If both commands succeed, authentication works and the user can list cluster nodes.
    - `Unauthorized` or `You must be logged in to the server` indicates an authentication or credential problem. Continue to step 7.
    - If the version request succeeds but `kubectl get nodes` returns `Forbidden`, authentication succeeded but the user isn't authorized to list nodes. Continue to step 8.
2. If authentication fails, check the client configuration and authentication toolchain.

    - Follow [Config file isn't available when connecting](config-file-is-not-available-when-connecting) if kubeconfig is missing, invalid, or points to the wrong endpoint.
    - For Microsoft Entra-integrated clusters, verify that `kubelogin` is installed when the kubeconfig uses an exec credential plugin, and confirm that the selected authentication method is compatible with the applicable Conditional Access policy.
    - Keep `kubectl` within one minor version of the API server, in either direction, according to the [Kubernetes version skew policy](https://kubernetes.io/releases/version-skew-policy/). Use [az aks install-cli](/en-us/cli/azure/aks#az-aks-install-cli) or the platform-specific [kubectl installation instructions](https://kubernetes.io/docs/tasks/tools/) when an update is required.

    Repeat the `kubectl` commands in step 6 after you correct the authentication problem.
3. If `kubectl` returns `Forbidden`, follow [User can't get cluster resources](user-cannot-get-cluster-resources). Determine whether the cluster uses Kubernetes RBAC or Azure RBAC for Kubernetes Authorization, and verify the role assignment or role binding for the exact operation that failed.

    Repeat `kubectl get nodes --request-timeout=10s` after you correct the authorization problem.

### Additional check for node-specific operations

1. If the commands in step 6 succeed but `kubectl logs`, `exec`, `attach`, or `port-forward` fails, check the API-server-to-node path.

    - Follow [Troubleshoot tunnel connectivity issues](tunnel-connectivity-issues) and verify that network security controls associated with AKS nodes allow the required control-plane-to-kubelet communication on TCP port 10250.
    - If nodes or extensions can't reach required AKS endpoints, verify the [minimum required egress rules for AKS](/en-us/azure/aks/limit-egress-traffic), including proxy, firewall, TLS inspection, and ALPN behavior.
    - TCP port 10250 failures can affect only some node-dependent operations. Compare the failing operation with the successful commands from step 6 instead of treating it as a general client-to-API-server failure.

For additional timeout scenarios, see [TCP time-outs when kubectl or other third-party tools connect to the API server](tcp-timeouts-kubetctl-third-party-tools-connect-api-server).