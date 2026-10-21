---
layout: Conceptual
title: Proxy server settings in AKS on Windows Server | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/set-proxy-settings
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
description: Learn about proxy server settings in Azure Kubernetes Service (AKS) on Windows Server.
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-05-25T00:00:00.0000000Z
ms.reviewer: srikantsarwa
ms.custom: windows-server
author: davidsmatlak
locale: en-us
document_id: 5aeb599c-938d-3216-6ca9-5950714baf45
document_version_independent_id: 20afdbdb-b6ee-3c66-f1f1-efda84c75dfa
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/set-proxy-settings.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/set-proxy-settings
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/set-proxy-settings.md
platformId: 9ef8859d-d079-61d3-863e-813d349a26c2
---

# Proxy server settings in AKS on Windows Server | Microsoft Learn

> 
> Applies to: AKS on Windows Server

This article describes how to configure proxy settings for AKS on Windows Server. If your network requires the use of a proxy server to connect to the internet, this article walks you through the steps to set up proxy support in AKS using the **AksHci** PowerShell module. The steps are different depending on whether the proxy server requires authentication.

Note

If you want to use Kubernetes and Azure Services with Azure Arc, make sure you also add the URLs shown in [Connect an existing Kubernetes cluster to Azure Arc](/en-us/azure/azure-arc/kubernetes/quickstart-connect-cluster?tabs=azure-cli#meet-network-requirements) to your allow list.

Once you've configured your deployment using the following options, you can [install an AKS host on Windows Server](kubernetes-walkthrough-powershell) and [create Kubernetes clusters using PowerShell](kubernetes-walkthrough-powershell#step-6-create-a-kubernetes-cluster).

## Before you begin

Make sure you have satisfied all prerequisites in the [system requirements](system-requirements).

### Proxy server configuration information

The proxy server configuration for your AKS deployment includes the following settings:

- HTTP URL and port, such as `http://proxy.corp.contoso.com:8080`.
- HTTPS URL and port, such as `https://proxy.corp.contoso.com:8443`.
- (Optional) Valid credentials for authentication to the proxy server.
- (Optional) Valid certificate chain if your proxy server is configured to intercept SSL traffic. This certificate chain will be imported into all AKS control plane and worker nodes as well as the management cluster to establish a trusted connection to the proxy server.

### Exclusion list for excluding private subnets from being sent to the proxy

The following table contains the list of addresses that you must exclude by using the `-noProxy` parameter in [`New-AksHciProxySetting`](/en-us/azure/aks/aksarc/reference/ps/new-akshciproxysetting).

| IP address | Reason for exclusion |
| --- | --- |
| `localhost`, `127.0.0.1` | localhost traffic |
| `.svc` | Internal Kubernetes service traffic, where `.svc` represents a wildcard name. This is similar to saying `*.svc`, but none is used in this schema. |
| `10.0.0.0/8` | Private network address space. |
| `172.16.0.0/12` | Private network address space - Kubernetes service CIDR. |
| `192.168.0.0/16` | Private network address space - Kubernetes pod CIDR. |
| `.contoso.com`` | You might want to exempt your enterprise namespace (.contoso.com) from being directed through the proxy. To exclude all addresses in a domain, you must add the domain to the `noProxy`list. Use a leading period rather than a wildcard (\*) character. In the example, the addresses`.contoso.com`excludes addresses`prefix1.contoso.com`, `prefix2.contoso.com`, and so on. |  |

The default value for `noProxy` is `localhost,127.0.0.1,.svc,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16`. While these default values work for many networks, you might need to add more subnet ranges and/or names to the exemption list. For example, you might want to exempt your enterprise namespace (.contoso.com) from being directed through the proxy. You can achieve that by specifying the values in the `noProxy` list.

## Set proxy for Windows Server clusters with machine-wide proxy settings

If you already have machine-wide proxy settings on your Windows Server cluster, the settings might override any AKS-specific proxy settings and lead to a failure during installation.

To detect whether you have machine-wide proxy settings, run the following script on each of your physical cluster nodes:

```powershell
$http_proxy = [System.Environment]::GetEnvironmentVariable("HTTP_PROXY", "Machine")
$https_proxy = [System.Environment]::GetEnvironmentVariable("HTTPS_PROXY", "Machine")
$no_proxy = [System.Environment]::GetEnvironmentVariable("NO_PROXY", "Machine")

if ($http_proxy -or $https_proxy) {
    if (-not $no_proxy) {
        Write-Host "Problem Detected! A machine-wide proxy server is configured, but no proxy exclusions are configured"
    }
}
```

Configure machine-wide proxy exclusions on each of the physical cluster hosts where the problem was detected.

Run the following PowerShell script and replace the `$no_proxy` parameter string with a suitable `NO_PROXY` exclusion string for your environment. For information about how to correctly configure a `noProxy` list for your environment, see Exclusion list for excluding private subnets from being sent to the proxy.

```powershell
$no_proxy = "localhost,127.0.0.1,.svc,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,.contoso.com"
[Environment]::SetEnvironmentVariable("NO_PROXY", $no_proxy, "Machine")
$env:NO_PROXY = [System.Environment]::GetEnvironmentVariable("NO_PROXY", "Machine")
```

Note

We recommend that you use the same proxy settings on all nodes in the failover cluster. Having different proxy settings on different physical nodes in the failover cluster might lead to unexpected results or installation issues. Also, an IP address with a wildcard (\*), such as **172.**\*, is not valid. The IP address must be in proper CIDR notation (**172.0.0.0/8**).

## Install the AksHci PowerShell modules

Configure the system proxy settings on each of the physical nodes in the cluster and ensure that all nodes have access to the URLs and ports outlined in [System requirements](system-requirements#network-port-and-url-requirements).

If you are using remote PowerShell, you must use CredSSP.

Close all open PowerShell windows before running the following command:

```powershell
Install-Module -Name AksHci -Repository PSGallery
```

If your environment uses a proxy server to access the internet, you might need to add proxy parameters to the **Install-Module** command before installing AKS. For more information, see the [Install-Module documentation](/en-us/powershell/module/powershellget/install-module).

When you download the **AksHci** PowerShell module, we also download the Az PowerShell modules that are required for registering an AKS host with Azure for billing.

## Configure an AKS host for a proxy server with basic authentication

If your proxy server requires authentication, open PowerShell as an administrator and run the following command to get credentials and set the configuration details:

```powershell
$proxyCred = Get-Credential
$proxySetting=New-AksHciProxySetting -name "corpProxy" -http http://contosoproxy:8080 -https https://contosoproxy:8443 -noProxy localhost,127.0.0.1,.svc,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,.contoso.com -credential $proxyCredential
```

## Configure an AKS host for a proxy server without authentication

If your proxy server doesn't require authentication, run the following command:

```powershell
$proxySetting=New-AksHciProxySetting -name "corpProxy" -http http://contosoproxy:8080 -https https://contosoproxy:8443 -noProxy localhost,127.0.0.1,.svc,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,.contoso.com
```

## Configure an AKS host for a proxy server with a trusted certificate

If your proxy server requires proxy clients to trust a certificate, specify the certificate file when you run `Set-AksHciConfig`. The format of the certificate file is **Base-64 encoded X .509**. This enables you to create and trust the certificate throughout the stack.

Important

If your proxy requires a certificate to be trusted by the physical nodes, make sure that you import the certificate chain to the appropriate certificate store on each node before you continue. Follow the procedures for your deployment to enroll the nodes with the required certificates for proxy authentication.

```powershell
$proxySetting=New-AksHciProxySetting -name "corpProxy" -http http://contosoproxy:8080 -https https://contosoproxy:8443 -noProxy localhost,127.0.0.1,.svc,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,.contoso.com -credential $proxyCredential
```

Note

Proxy certificates must be provided as a personal information exchange (PFX) file format or string, and contain the root authority chain to use the certificate for authentication or for SSL tunnel setup.