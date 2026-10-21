---
layout: Conceptual
title: Determine app behavior with HTTP response codes - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/get-and-analyze-http-response-codes
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
description: Use cURL or a browser to get HTTP response codes and analyze app behavior in AKS. Start troubleshooting faster with clear response insights.
ms.date: 2024-09-26T00:00:00.0000000Z
ms.reviewer: chiragpa, jopalhei, v-leedennis, v-weizhu
ms.service: azure-kubernetes-service
ms.custom: sap:Connectivity
locale: en-us
document_id: 78a1d0ba-77ae-74a6-bc49-6d767833b082
document_version_independent_id: 78a1d0ba-77ae-74a6-bc49-6d767833b082
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/connectivity/get-and-analyze-http-response-codes.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/connectivity/get-and-analyze-http-response-codes
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/connectivity/get-and-analyze-http-response-codes.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: dfa251a0-0eb3-9054-a7d8-c798b1c83de8
---

# Determine app behavior with HTTP response codes - Azure | Microsoft Learn

## Summary

If an application responds to HTTP or HTTPS requests, you can check the HTTP response codes to determine the behavior of the application.

## Prerequisites

- The Client URL ([cURL](https://curl.se)) tool, or another similar command-line tool.
- The Kubernetes [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) tool, or a similar tool to connect to the cluster. To install kubectl by using [Azure CLI](/en-us/cli/azure/install-azure-cli), run the [az aks install-cli](/en-us/cli/azure/aks#az-aks-install-cli) command.

## Get HTTP response codes by using cURL

The [cURL](https://curl.se) command-line tool can send an HTTP request to an application endpoint and get the response. For a load balancer service (that responds on the path "/" on port 80), a curl request can be initiated by running the following command:

```bash
curl -Iv http://<load-balancer-service-ip-address>:80/
```

For example, you can use cURL together with the [kubectl get](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command, as follows:

```console
$ kubectl get service
NAME                      TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)        AGE
my-loadbalancer-service   LoadBalancer   10.0.81.95     20.62.x.x       80:32131/TCP   18h
  
$ curl -Iv http://20.62.x.x:80/
*   Trying 20.62.x.x:80...
* Connected to 20.62.x.x (20.62.x.x) port 80 (#0)
> HEAD / HTTP/1.1
> Host: 20.62.x.x
> User-Agent: curl/7.79.1
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
HTTP/1.1 200 OK
< ...
...
< Server: Apache/2.4.52 (Unix)
Server: Apache/2.4.52 (Unix)
< ...
...
<
* Connection #0 to host 20.62.x.x left intact
```

The response from this URI is `HTTP 200`.

## Get HTTP response codes by using a browser

You can also get the HTTP response of an HTTP endpoint from a browser. Follow these steps:

1. In a browser window, press Ctrl+Shift+I or F12. The developer tools window or pane appears.
2. Select the **Network** tab, and then access the endpoint. The details about the HTTP response appear in the developer tools window or pane.

## Get HTTP response codes by issuing API requests

To make API requests to the application and get details about the response, you can choose from many other command-line and GUI tools. These tools include the following:

| Tool | Link |
| --- | --- |
| Postman | [Postman API platform](https://www.postman.com/) |
| wget | [GNU Wget 1.21.1-dirty Manual](https://www.gnu.org/software/wget/manual/wget.html) |
| PowerShell | [Invoke-WebRequest cmdlet](/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest) |

After you get an HTTP response code, start troubleshooting to better understand the application's behavior. For more information about the HTTP status codes and the behavior that they indicate, see the following content:

| Information source | Link |
| --- | --- |
| Internet Assigned Numbers Authority (IANA) | [Hypertext Transfer Protocol (HTTP) status code registry](https://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml) |
| Mozilla | [HTTP response status codes](https://developer.mozilla.org/docs/Web/HTTP/Status) |
| Wikipedia | [List of HTTP status codes](https://wikipedia.org/wiki/List_of_HTTP_status_codes) |

The following HTTP status codes might indicate the listed issues.

| HTTP status code | Issue |
| --- | --- |
| `4xx` | An issue affects the client request. For example, the requested page doesn't exist, or the client doesn't have permission to access the page.<br><br>OR<br><br>A network blocker exists between the client and the server. For example, traffic is being blocked by a network security group or a firewall. |
| `5xx` | An issue affects the server. For example, the application is down, or a gateway isn't working. |