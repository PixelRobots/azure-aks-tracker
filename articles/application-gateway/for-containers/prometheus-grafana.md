---
layout: Conceptual
title: Configure Application Gateway for Containers for Prometheus and Grafana | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/prometheus-grafana
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
description: Configure Application Gateway for Containers metrics to be sent to Prometheus and displayed on Grafana.
services: application-gateway
author: mbender-ms
ms.service: azure-application-gateway-containers
ms.topic: how-to
ms.date: 2026-01-27T00:00:00.0000000Z
ms.author: mbender
ms.custom: sfi-image-nochange
locale: en-us
document_id: c36833d1-6521-dec4-e9f6-8b0e8882e2f4
document_version_independent_id: 08526906-7699-2e04-5b7d-faf01d44757e
original_content_git_url: https://github.com/MicrosoftDocs/azure-docs-pr/blob/live/articles/application-gateway/for-containers/prometheus-grafana.md
site_name: Docs
depot_name: Azure.azure-documents
page_type: conceptual
toc_rel: toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/Azure.azure-documents/{branchName}{pdfName}
asset_id: application-gateway/for-containers/prometheus-grafana
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-gateway/for-containers/prometheus-grafana.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
platformId: da492db9-77f8-225b-a589-7b3d2b39965e
---

# Configure Application Gateway for Containers for Prometheus and Grafana | Microsoft Learn

Establishing monitoring for Application Gateway for Containers is a crucial part of successful operations. Monitoring allows you to visualize how traffic is controlled, providing actionable insights that help optimize performance and troubleshoot issues promptly. Monitoring also enhances security by providing valuable insights during investigations, which helps ensure that your gateway remains secure and resilient against threats.

## Learn about the services

Before you start the configuration, review how these components work together to create a unified monitoring solution.

- [What is Azure Monitor Managed Prometheus?](/en-us/azure/azure-monitor/metrics/prometheus-metrics-overview)

    - Azure Managed Prometheus offers native integration and management capabilities, simplifying the setup and management of monitoring infrastructure. It integrates with Azure Managed Grafana, provides a seamless data source for Azure Monitor dashboards with Grafana, and can also provide data for your existing self-managed Grafana environment. See [Self-managed Prometheus to Grafana](/en-us/azure/azure-monitor/metrics/prometheus-metrics-overview)
- [What is Azure Grafana?](/en-us/azure/azure-monitor/visualize/visualize-grafana-overview#azure-managed-grafana)

    - Azure Monitor Dashboards with Grafana: Delivers prebuilt Grafana dashboards directly in the Azure portal. It's automatically available at no cost and with no configuration requirements. See available data sources with [Azure Monitor Dashboards with Grafana](/en-us/azure/azure-monitor/visualize/visualize-grafana-overview#data-sources). If you require other data sources, then see Azure Managed Grafana.
    - Azure Managed Grafana is an open-source analytics and visualization platform that enables you to query, monitor, and create interactive dashboards for metrics, logs, and traces from multiple data sources.
- [What is Azure Monitor Workspace?](/en-us/azure/azure-monitor/metrics/azure-monitor-workspace-manage?tabs=azure-portal)

    - The workspace is a unique environment for data collected by Azure Monitor. Each workspace has its own data repository, configuration, and permissions.

You can monitor Azure Application Gateway for Containers resources in the following ways. Refer to the diagram.

- [Backend Metrics](application-gateway-for-containers-metrics): Each client request creates a log entry that can be used to identify slow requests, determine error rates, and correlate WAF Metrics with backend services. The metrics endpoint enables exposure to Prometheus.
- [Diagnostic Logs](diagnostics): Access Logs audit all requests made to Application Gateway for Containers. Logs can provide several characteristics, such as the client's IP, requested URL, request latencies, return code, and bytes in and out. An access log is collected every 60 seconds. This includes the activity log, access log, and firewall log.

[![Screenshot of architecture grid diagram.](media/prometheus-grafana/agc-monitoring-flowchart.png)](media/prometheus-grafana/agc-monitoring-flowchart.png#lightbox)

## Prerequisites

- An active Kubernetes cluster.
- An active Application Gateway for Containers deployment.
- An active resource group with Contributor permission.
- Monitoring Reader role assigned for access to Azure Managed Prometheus (Azure Monitor workspace).

## Azure Monitor dashboards with Grafana

Azure Monitor includes native support for Grafana dashboards directly within the Azure portal. This built-in capability allows you to quickly access prebuilt dashboards and create custom visualizations for monitoring your Azure resources without leaving Azure Monitor.

Use the following steps to use the Grafana dashboards that are already available in the Azure portal with the data sources from Azure Monitor managed service for Prometheus metrics scraped from Kubernetes clusters.

1. In the Azure portal, navigate to your AKS cluster.
2. Select **Monitoring**.
3. Select **Dashboards with Grafana**.
4. Select **Configure**.
5. Select **Enable Prometheus Metrics** and **Container Logs**. Under **Advanced Settings**, select your specific Azure Monitor workspace, Log Analytics workspace, and log presets.

    ![Screenshot of configuring monitoring with Grafana.](media/prometheus-grafana/configure-monitor-with-grafana.png)
6. Browse the list of available dashboards in the Azure Managed Prometheus listings.

    ![Screenshot of Prometheus template dashboards.](media/prometheus-grafana/prometheus-template.png)

See additional customization in [Azure Monitor Dashboards with Grafana](/en-us/azure/azure-monitor/visualize/visualize-use-grafana-dashboards)

## Azure Managed Grafana

Azure Managed Grafana provides a dedicated, fully managed Grafana instance with broader flexibility. Choose Azure Managed Grafana when you need advanced user management, customization, integration with a wide variety of Azure and non-Azure data sources, or when you require Grafana's full feature set, such as advanced alerting, reporting, and enterprise plugins.

## Complete the steps to configure Prometheus and Grafana

1. Sign in to the [Azure portal](https://portal.azure.com) with your Azure account.
2. Navigate to your AKS cluster in the Azure portal.

    - **New AKS cluster**: Configure monitoring in the **Monitoring** tab and enable Prometheus metrics and container logs.
    - **Existing cluster**: Navigate to your cluster in the Azure portal. In the service menu, select **Monitor** and then **Monitor Settings**.

    ![Screenshot of configuring Azure Monitor with Grafana.](media/prometheus-grafana/configure-monitor-with-grafana.png)
3. In the **Search resources, services, and docs (G+/)** box, enter *Azure Managed Grafana* and select **Azure Managed Grafana**.
4. Create an [Azure Managed Grafana workspace](/en-us/azure/managed-grafana/quickstart-managed-grafana-portal).

    Note

    An Azure Managed Grafana instance is automatically configured with a managed identity with the Monitoring Data Reader role. This role allows the identity to read monitoring data for the subscription. The identity is used to authenticate Grafana to Azure Monitor.
5. Create an [Azure Monitor workspace](/en-us/azure/azure-monitor/metrics/azure-monitor-workspace-manage?tabs=azure-portal). Copy the **Query endpoint**.

    ![Screenshot of the Monitor query endpoint.](media/prometheus-grafana/query-endpoint.png)

## Create the Prometheus data source in Grafana

1. Open your Azure Managed Grafana workspace in the Azure portal and select the endpoint to view the Grafana workspace.
2. Select **Connections** &gt; **Data sources** and then select **Add data source**.
3. Search for and select **Prometheus**.
4. Paste the query endpoint from your Azure Monitor workspace into the **Prometheus server URL** field.
5. Under **Authentication**, select **Azure Auth**.
6. Under **Azure Authentication**, select **Managed Identity** from the **Authentication** dropdown list.
7. Scroll to the bottom of the page and select **Save & test**.

    ![Screenshot of the Prometheus data source configuration.](media/prometheus-grafana/prometheus-data-source.png)

## Graph Prometheus metrics on Grafana

A Grafana dashboard contains panels and rows. You can import a Grafana dashboard and adapt it to your own scenario, create a new Grafana dashboard, or duplicate an existing dashboard.

1. In the Azure portal, open your Azure Managed Grafana workspace and select the **Endpoint URL**.
2. In the Grafana portal, go to **Dashboards** &gt; **New Dashboard**.
3. Select one of the following options:

    - **Add a new panel**: Instantly creates a dashboard from scratch with a first default panel.
    - **Add a new row**: Instantly creates a dashboard with a new empty row.
    - **Add a panel from the panel library**: Instantly creates a dashboard with an existing reusable panel from another workspace you have access to.
4. Select **Add a new panel**.
5. Search for and select **Prometheus** as a data source.
6. Select the desired metric. For example, select `alb_controller_total_unhealthy_endpoints` to show any unhealthy endpoints of your backend service. Choose **app** as `alb-controller`. Select the name of the panel, type of visualization, and time range.

    ![Screenshot of the Prometheus metrics visualization in Grafana.](media/prometheus-grafana/prometheus-grafana-viewing.png)
7. Select **Save** and **Apply** to add the panel to your dashboard.

## Graph Azure Monitor Logs on Grafana

After you create the resources, you can combine them and configure Prometheus.

1. Expand the menu on the left and select **Connections** &gt; **Data sources**.

    ![Screenshot of the Monitor data source configuration.](media/prometheus-grafana/monitor-data-source-configuration.png)
2. **Azure Monitor** is listed as a built-in data source for your Azure Managed Grafana workspace. Select **Azure Monitor**.
3. In the **Settings** tab, authenticate through **Managed Identity** and select your subscription from the dropdown list. When you select managed identity, the authentication and authorization are made through the system-assigned or the user-assigned managed identity you configured in your Azure Managed Grafana workspace.
4. Select **Add a new panel**.
5. Search for and select **Azure Monitor** as a data source.
6. Enter the following example query:

    ```kusto
    AGCAccessLogs
    | project BackendResponseLatency, TimeGenerated
    ```
7. Select **Time Series** as a visualization.
8. Select the name, description, and time range of the panel.

    ![Screenshot of an Application Gateway for Containers logging example.](media/prometheus-grafana/logging-example.png)
9. Select **Save** and **Apply** to add the panel to your dashboard.

Congratulations! You set up a monitoring service to enhance your health tracking!