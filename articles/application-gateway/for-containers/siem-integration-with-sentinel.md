---
layout: Conceptual
title: Configure Application Gateway for Containers for SIEM integration with Microsoft Sentinel and Microsoft Defender | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/siem-integration-with-sentinel
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
description: Configure Application Gateway for Containers for SIEM integration with Microsoft Sentinel
services: application-gateway
author: mbender-ms
ms.service: azure-application-gateway-containers
ms.topic: how-to
ms.date: 2026-02-19T00:00:00.0000000Z
ms.author: mbender
ms.custom: sfi-image-nochange
locale: en-us
document_id: 3cc74dc5-b064-8ccc-9d49-3fa646a8c81a
document_version_independent_id: f1174e6e-5aca-b01b-0663-ac35904b3975
original_content_git_url: https://github.com/MicrosoftDocs/azure-docs-pr/blob/live/articles/application-gateway/for-containers/siem-integration-with-sentinel.md
site_name: Docs
depot_name: Azure.azure-documents
page_type: conceptual
toc_rel: toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/Azure.azure-documents/{branchName}{pdfName}
asset_id: application-gateway/for-containers/siem-integration-with-sentinel
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-gateway/for-containers/siem-integration-with-sentinel.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/8a94907f-2511-4271-b5ca-ec7f2e75067c
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/bffa8e88-f633-409d-a24d-083bdbc68872
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
platformId: 227a9629-5b3e-f12a-b6df-25a03fa062f4
---

# Configure Application Gateway for Containers for SIEM integration with Microsoft Sentinel and Microsoft Defender | Microsoft Learn

By integrating Application Gateway for Containers (AGC) with Microsoft Sentinel, you centralize and streamline security data collection across your environment. By using this quickstart guide, you can quickly configure Microsoft Sentinel to ingest AGC access logs, enabling precise monitoring, threat detection, and investigation based on real traffic signals. By adding the solution from the Content Hub and configuring the appropriate data connector, AGC access logs begin flowing into Microsoft Sentinel seamlessly. You can then define analytic rules, validate detections with test alerts, and use built-in visualization tools to gain clear, actionable security insights across your deployment.

When surfaced through the Microsoft Defender XDR unified portal, these signals are correlated across identities, endpoints, email, and cloud resources. They provide end-to-end attack visibility, faster investigation, and coordinated response from a single SecOps experience.

In this quickstart guide, you set up:

- Integration with a Log Analytics workspace.
- Configuration of a data connector into Microsoft Sentinel.
- Establishment of an analytical rule, conduction of a test alert, and visualization of an alert for comprehensive oversight.
- Migration from Microsoft Sentinel to Microsoft Defender XDR.

[![Screenshot of Application Gateway for Containers SIEM integration flowchart.](media/siem-integration-with-sentinel/sentinel-application-gateway-flowchart.png)](media/siem-integration-with-sentinel/sentinel-application-gateway-flowchart.png#lightbox)

Note

Starting in July 2026, Microsoft Sentinel support in the Azure portal ends. The Defender portal supports Microsoft Sentinel. Users are automatically redirected to the Defender portal.

## Learn about the services

- [What is Microsoft Sentinel?](/en-us/azure/sentinel/)
    - Microsoft Sentinel offers security content that's pre-packaged in SIEM solutions. You can monitor, analyze, investigate, notify, and integrate with many platforms and products, including Log Analytics workspace.
- [What is Azure Log Analytics workspace?](/en-us/azure/azure-monitor/logs/log-analytics-workspace-overview)
    - Log Analytics workspace scales with your business needs. It handles large volumes of log data efficiently and detects and diagnoses issues quickly.
- [What is Microsoft Defender portal?](https://security.microsoft.com/)
    - Microsoft Defender portal is the single place where security teams monitor, investigate, and respond to threats across identities, endpoints, email, applications, and cloud resources. See all capabilities of [Defender portal](/en-us/azure/sentinel/microsoft-sentinel-defender-portal).

## Prerequisites

- You must have an active Log Analytics workspace to ingest data into Microsoft Sentinel.
- You must have Microsoft Sentinel Contributor permissions at the subscription level.
- You must have Owner or User Access Administrator permissions at the subscription level.

## Enable Microsoft Sentinel for Log Analytics workspace

1. [Enable Microsoft Sentinel workspace](/en-us/azure/sentinel/overview).
2. Send logs to **Log Analytics workspace**:

    1. In **Search resources, services, and docs**, type **Application Gateways for Containers**.
    2. Go to your selected **Application Gateway for Containers** resource.
    3. Go to **Diagnostic settings** under **Monitoring**:
        1. Select a name, check the **allLogs** checkbox, which includes the Application Gateway for Containers access logs.
        2. Select **Send to Log Analytics workspace** with your desired subscription and your Log Analytics workspace. ![Screenshot of Log Management logging configuration.](media/siem-integration-with-sentinel/logging.png)
3. View data ingested to Microsoft Sentinel:

    1. In **Search resources, services, and docs**, type Microsoft Sentinel.
    2. Go to your selected Microsoft Sentinel resource.
    3. Select **Logs**.
    4. On the left sidebar, go to **Tables** where a section called **LogManagement** appears with ingested access logs.
    5. Preview all logs by hovering over access logs and select **Run**. [![Screenshot of Log Management section in Microsoft Sentinel.](media/siem-integration-with-sentinel/log-management.png)](media/siem-integration-with-sentinel/log-management.png#lightbox)

## Enable Microsoft Sentinel to Microsoft Defender portal

1. Go to your Microsoft Sentinel resource.
2. Select **Content Hub** under **Content Management**.
3. Search for **Microsoft Defender XDR** and select **Install**.
4. Go to **Data Connectors** under **Configuration**.
5. Check that **Microsoft Defender XDR** is connected and verify that your prerequisites are all green-checked and available. [![Screenshot of Microsoft Sentinel prerequisites check.](media/siem-integration-with-sentinel/sentinel-prerequisites.png)](media/siem-integration-with-sentinel/sentinel-prerequisites.png#lightbox)
6. Go to the **Overview** page of your selected Microsoft Sentinel.
7. Select **Learn More** on the banner to onboard to Microsoft Defender portal. Another way to access is the link: https://security.microsoft.com/.
8. Select **Connect a Workspace** and select your Microsoft Sentinel workspace. [![Screenshot of connecting Microsoft Sentinel workspace to Defender portal.](media/siem-integration-with-sentinel/sentinel-workspace.png)](media/siem-integration-with-sentinel/sentinel-workspace.png#lightbox)
9. Complete the remaining permission pages.

Note

Microsoft Defender portal has the same navigation as Microsoft Sentinel with **Threat Management**, **Investigation**, **Content Management**, and **Configuration** on the left panel.

## Create analytics rule

1. In the Microsoft Sentinel portal, go to the **Analytics** section under **Configuration**.
2. Select **Create** and choose **Scheduled Query Rule**.
3. Enter a name and description. Keep the default settings for the rest of the options and go to the next page.

    [![Screenshot of creating rule configuration in Microsoft Sentinel.](media/siem-integration-with-sentinel/create-rule.png)](media/siem-integration-with-sentinel/create-rule.png#lightbox)
4. Create a rule query based on your access logs:

    - **Example Scenario**: A user sends encrypted data through a specific URL.
    - **Goal**: Detect threats from a HostName with RequestURI **"/secret/path"**.
    - **Create query**: 

        ```kusto
        // Example Query
        AGCAccessLogs
           | where HostName == "4.150.168.211" or RequestUri contains "/secret/path"
        ```
 This query filters **AGCAccessLogs** based on conditions related to hostname and request URI.
5. Detect associated IPs by using **Entity Mapping**: [![Screenshot of entity mapping configuration.](media/siem-integration-with-sentinel/entity-mapping.png)](media/siem-integration-with-sentinel/entity-mapping.png#lightbox)
6. Set **Query Scheduling**:

    - Run every **5 hours**.
    - Look up data for the last **5 hours**.
7. Select **Review + Create**.

## Test incident

1. Send traffic to the URL to create an incident:

    - Now you're ready to send some traffic by using **/secret/path** to your sample application, through the **FQDN** (fully qualified domain name) assigned to the frontend. Use the following command to get the FQDN:

    ```bash
        fqdn=$(kubectl get gateway gateway-01 -n test-infra -o jsonpath='{.status.addresses[0].value}')
    ```
2. Curling this FQDN returns responses from the backend as configured on the HTTPRoute:

    ```bash
    curl --insecure https://$fqdn/secret/path
    ```

## Visualize test incidents

1. After an incident occurs, view the details in **Threat Management** under **Incidents & alerts** in **Investigation**.
2. Select an incident and open the pane on the right-hand side of the page.
3. Select **View Full Details**.
4. Select **Investigate**.

    [![Screenshot of investigation details in Microsoft Sentinel.](media/siem-integration-with-sentinel/investigate.png)](media/siem-integration-with-sentinel/investigate.png#lightbox)
5. In **Investigate**, visualize the associated entities and similar alerts.

    [![Screenshot of entity mapping and alert visualization.](media/siem-integration-with-sentinel/mapping.png)](media/siem-integration-with-sentinel/mapping.png#lightbox)
6. Select an entity to view **Insights** and dive deeper into the investigation.

    [![Screenshot of entity insights for deeper investigation.](media/siem-integration-with-sentinel/insights.png)](media/siem-integration-with-sentinel/insights.png#lightbox)

You can now create security barriers on your logs and investigate any incidents.