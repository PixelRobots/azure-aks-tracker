---
layout: Conceptual
title: Azure Monitor metrics for Application Gateway for Containers | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/application-gateway-for-containers-metrics
breadcrumb_path: /azure/bread/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/148/azure-application-gateway/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/8ae9bf04-8326-ec11-b6e6-000d3a4f0789?c=8d429912-8326-ec11-b6e6-000d3a4f0789
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
adobe-target: true
learn_banner_products:
- azure
manager: kumud
ms.reviewer: mbender
description: Learn how to use metrics to monitor performance of Application Gateway for Containers
services: application-gateway
author: mbender-ms
ms.service: azure-application-gateway-containers
ms.topic: concept-article
ms.date: 2025-07-21T00:00:00.0000000Z
ms.author: mbender
locale: en-us
document_id: c2647722-956d-14a6-9bca-a4d3de7a7c5b
document_version_independent_id: fd487b68-6562-79c9-b326-1660fa506b2b
original_content_git_url: https://github.com/MicrosoftDocs/azure-docs-pr/blob/live/articles/application-gateway/for-containers/application-gateway-for-containers-metrics.md
site_name: Docs
depot_name: Azure.azure-documents
page_type: conceptual
toc_rel: toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/Azure.azure-documents/{branchName}{pdfName}
asset_id: application-gateway/for-containers/application-gateway-for-containers-metrics
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-gateway/for-containers/application-gateway-for-containers-metrics.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
platformId: 4a71dfe9-e6d1-8478-680c-f54520392b4a
---

# Azure Monitor metrics for Application Gateway for Containers | Microsoft Learn

Application Gateway for Containers publishes data points to [Azure Monitor](/en-us/azure/azure-monitor/overview) for the performance of your Application Gateway for Containers and backend instances. These data points are called metrics, and are numerical values in an ordered set of time-series data. Metrics describe some aspect of your application gateway at a particular time. If there are requests flowing through the Application Gateway, it measures and sends its metrics in 60-second intervals. If there are no requests flowing through the Application Gateway or no data for a metric, the metric isn't reported. For more information, see [Azure Monitor metrics](/en-us/azure/azure-monitor/essentials/data-platform-metrics).

## Metrics supported by Application Gateway for Containers

| Metric Name | Description | Aggregation Type | Dimensions |
| --- | --- | --- | --- |
| Backend Connection Timeouts | Count of requests that timed out waiting for a response from the backend target (includes all retry requests initiated from Application Gateway for Containers to the backend target) | Sum | Backend Service |
| Backend Healthy Targets | Count of healthy backend targets | Avg | Backend Service |
| Backend HTTP Response Status | HTTP response status returned by the backend target to Application Gateway for Containers | Sum | Backend Service, HTTP Response Code |
| Connection Timeouts | Count of connections closed due to timeout between clients and Application Gateway for Containers | Sum | Frontend |
| HTTP Response Status | HTTP response status returned by Application Gateway for Containers | Sum | Frontend, HTTP Response Code |
| Total Connection Idle Timeouts | Count of connections closed, between client and Application Gateway for Containers frontend, due to exceeding idle timeout | Sum | Frontend |
| Total Requests | Count of requests Application Gateway for Containers has served | Sum | Frontend |

## WAF Metrics supported by Application Gateway for Containers

Metrics specific to requests processed by web application firewall functionality on Application Gateway for Containers.

| Metric Name | Description | Aggregation Type | Dimensions |
| --- | --- | --- | --- |
| WAF Custom Rule Matches | Count of custom rule matches | Sum | Action, Country/Region, Mode, Policy Name, Policy Scope, Rule Name |
| WAF Managed Rule Matches | Count of total managed rule matches | Sum | Action, Country/Region, Mode, Policy Name, Policy Scope, Rule Group, Rule ID, Rule Set Name |
| WAF Total Requests | Count of successful requests that WAF engine has served | Sum | Action, Country/Region, Method, Mode, Policy Name, Policy Scope |

## View Application Gateway for Containers metrics

Use the following steps to view Application Gateway for Containers in the Azure portal.

1. Sign in to the [Azure portal](https://portal.azure.com) with your Azure account.
2. In **Search resources, service, and docs**, type **Application Gateways for Containers** and select your Application Gateway for Containers name.
3. Under **Monitoring**, select **Metrics**.
4. Next to **Chart Title**, enter a title for your metrics view.
5. **Scope** and **Metric Namespace** are is automatically populated. Under **Metric**, select a metric such as: **Total Requests**. For the **Total Requests** metric, the **Aggregation** is set to **Sum**.
6. Select **Add filter**. **Property** is set to **Frontend**. Choose the **=** (equals) **Operator**.
7. Enter values to use for filtering under **Values**.

    For example:

    - **frontend-primary:80**
    - **ingress-frontend:443**
    - **ingress-frontend:80**
8. Select the values you want to actively filter from the entries you create.
9. Choose **Apply Splitting**, select **Frontend**, and accept default values for **Limit** and **Sort**. See the following example:

**Total Requests**

![Application Gateway for Containers metrics total requests](media/application-gateway-for-containers-metrics/total-requests.png)

The following are some other useful chart examples:

**HTTP Response Status**

In the HTTP response status example is shown, a filter can be applied to quickly identify trends on response codes returned to client requests. Optionally, a filter may be applied to further monitor a specific grouping of HTTP response codes.

![Application Gateway for Containers metrics HTTP response status](media/application-gateway-for-containers-metrics/http-response-status.png)

**Backend Health Targets**

In the backend health targets example shown, the number of healthy backend targets increases from 1 to 2 for Kubernetes service *echo* and then decreases to 1. This validates that Application Gateway for Containers is able to detect the new replica, begin load balancing to the replica, and then remove the replica when the replica count is decreased in Kubernetes.

![Application Gateway for Containers metrics backend healthy targets](media/application-gateway-for-containers-metrics/backend-healthy-targets.png)