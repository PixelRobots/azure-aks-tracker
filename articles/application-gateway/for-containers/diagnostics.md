---
layout: Conceptual
title: Diagnostic logs for Application Gateway for Containers | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/diagnostics
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
description: Learn how to enable access logs for Application Gateway for Containers
services: application-gateway
author: mbender-ms
ms.service: azure-application-gateway-containers
ms.topic: concept-article
ms.date: 2025-07-21T00:00:00.0000000Z
ms.author: mbender
locale: en-us
document_id: f835da96-4c50-f768-f5a9-4727402da098
document_version_independent_id: 49aef3f1-3f7b-c097-fade-6dcb5acd9340
original_content_git_url: https://github.com/MicrosoftDocs/azure-docs-pr/blob/live/articles/application-gateway/for-containers/diagnostics.md
site_name: Docs
depot_name: Azure.azure-documents
page_type: conceptual
toc_rel: toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/Azure.azure-documents/{branchName}{pdfName}
asset_id: application-gateway/for-containers/diagnostics
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-gateway/for-containers/diagnostics.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
platformId: 3b9b14fc-f749-c009-f4b5-c81ec95e943f
---

# Diagnostic logs for Application Gateway for Containers | Microsoft Learn

Learn how to troubleshoot common problems in Application Gateway for Containers.

You can monitor Azure Application Gateway for Containers resources in the following ways:

- Logs: Logs allow for performance, access, and other data to be saved or consumed from a resource for monitoring purposes.
- Metrics: Application Gateway for Containers has several metrics that help you verify your system is performing as expected.

## Diagnostic logs

You can use different types of logs in Azure to manage and troubleshoot Application Gateway for Containers. You can access some of these logs through the portal. All logs can be extracted from Azure Blob storage and viewed in different tools, such as [Azure Monitor logs](/en-us/azure/azure-monitor/logs/data-platform-logs), Excel, and Power BI. You can learn more about the different types of logs from the following list:

- **Activity log**: You can use [Azure activity logs](/en-us/azure/azure-monitor/essentials/activity-log) (formerly known as operational logs and audit logs) to view all operations that are submitted to your Azure subscription, and their status. Activity log entries are collected by default, and you can view them in the Azure portal.
- **Access log**: You can use this log to view Application Gateway for Containers access patterns and analyze important information. This includes the caller's IP, requested URL, response latency, return code, and bytes in and out. An access log is collected every 60 seconds. The data may be stored in a storage account that is specified at time of enable logging.
- **Firewall log**: You can use the Firewall log to view the requests that are logged through either detection or prevention mode of an application gateway for containers deployment that is configured with the web application firewall. Firewall logs are collected every 60 seconds.

### Configure access log

Activity logging is automatically enabled for every Resource Manager resource. You must enable access logging to start collecting the data available through those logs. To enable logging, you may configure diagnostic settings in Azure Monitor.

# [Azure portal](#tab/configure-log-portal)
Use the following steps to enable all logging to a storage account for Application Gateway for Containers using the Azure portal. You must have an available storage account in the same region as your Application Gateway for Containers.

1. Sign in to the [Azure portal](https://portal.azure.com) with your Azure account.
2. In **Search resources, service, and docs**, type **Application Gateways for Containers** and select your Application Gateway for Containers name.
3. Under **Monitoring**, select **Diagnostic settings**.
4. Select **Add diagnostic setting**.
5. Enter a **Diagnostic setting name** (ex: agfc-logs), choose the logs and metrics to save and choose a destination, such as **Archive to a storage account**. To save all logs, select **allLogs** and **AllMetrics**.
6. Select **Save** to save your settings. See the following example:

    ![Configure diagnostic logs](media/diagnostics/enable-diagnostic-logs.png)

# [PowerShell](#tab/configure-log-powershell)
The following PowerShell sample enables all logging to a storage account for Application Gateway for Containers. Replace the resource group name, storage account name, and subscription ID with your own values. The storage account and resource group must be in the same region as your Application Gateway for Containers.

```PowerShell
# Retrieve the Azure Storage Account information
$storageAccount = Get-AzStorageAccount -ResourceGroupName acctest5097 -Name centraluseuaptclogs

# Initialize arrays to store metric and log settings
$metric = @()
$log = @()

# Configure metric settings
$metric += New-AzDiagnosticSettingMetricSettingsObject -Enabled $true -Category AllMetrics -RetentionPolicyDay 30 -RetentionPolicyEnabled $true

# Configure log settings
$log += New-AzDiagnosticSettingLogSettingsObject -Enabled $true -CategoryGroup allLogs -RetentionPolicyDay 30 -RetentionPolicyEnabled $true

# Create a new diagnostic setting for the specified resource
New-AzDiagnosticSetting -Name 'AppGWForContainersLogs' -ResourceId "/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/acctest5097/providers/Microsoft.ServiceNetworking/trafficControllers/myagfc" -StorageAccountId $storageAccount.Id -Log $log -Metric $metric
```

---

Note

After initially enabling diagnostic logs, it may take up to one hour before logs are available at your selected destination.

For more information and Azure Monitor deployment tutorials, see [Diagnostic settings in Azure Monitor](/en-us/azure/azure-monitor/essentials/diagnostic-settings).

### Access log format

Each access log entry in Application Gateway for Containers contains the following information.

| Value | Description |
| --- | --- |
| backendHost | Address of backend target with appended port. For example &lt;ip&gt;:&lt;port&gt; |
| backendIp | IP address of backend target Application Gateway for Containers proxies the request to. |
| backendPort | Port number of the backend target. |
| backendResponseLatency | Time in milliseconds to receive first byte from Application Gateway for Containers to the backend target. |
| backendTimeTaken | Time in milliseconds for the response to be transmitted from the backend target to Application Gateway for Containers. |
| clientIp | IP address of the client initiating the request to the frontend of Application Gateway for Containers |
| frontendName | Name of the Application Gateway for Containers frontend that received the request from the client |
| frontendPort | Port number the request was listened on by Application Gateway for Containers |
| frontendTLSFailureReason | Contains information on why TLS negotiation failed. Commonly used for understanding failed authentication requests for client mutual authentication |
| frontendTLSPeerFingerprint | The fingerprint (thumbprint) of the certificate presented by a client to the frontend of Application Gateway for Containers |
| hostName | Host header value received from the client by Application Gateway for Containers |
| httpMethod | HTTP Method of the request received from the client by Application Gateway for Containers as per [RFC 7231](https://datatracker.ietf.org/doc/html/rfc7231#section-4.3). |
| httpStatusCode | HTTP Status code returned from Application Gateway for Containers to the client |
| httpVersion | HTTP version of the request received from the client by Application Gateway for Containers |
| referrer | Referrer header of the request received from the client by Application Gateway for Containers |
| requestBodyBytes | Size in bytes of the body payload of the request received from the client by Application Gateway for Containers |
| requestHeaderBytes | Size in bytes of the headers of the request received from the client by Application Gateway for Containers |
| requestUri | URI of the request received from the client by Application Gateway for Containers (everything after &lt;protocol&gt;://&lt;host&gt; of the URL) |
| responseBodyBytes | Size in bytes of the body payload of the response returned to the client by Application Gateway for Containers |
| responseHeaderBytes | Size in bytes of the headers of the response returned to the client by Application Gateway for Containers |
| timeTaken | Time in milliseconds of the client request received by Application Gateway for Containers and the last byte returned to the client from Application Gateway for Containers |
| tlsCipher | TLS cipher suite negotiated between the client and Application Gateway for Containers frontend |
| tlsProtocol | TLS version negotiated between the client and Application Gateway for Containers frontend |
| trackingId | Generated guid by Application Gateway for Containers to help with tracking and debugging. This value correlates to the x-request-id header returned to the client from Application Gateway for Containers. |
| userAgent | User-Agent header of the request received from the client by Application Gateway for Containers |

Note

Query string parameter values such as "secret", "password", "pwd", "passwd", "key", "token", "pat", "accesskey", "accesstoken", "credential", "sas", "personalAccessToken", and "personal.access.token" logged in the requestUri field will be replaced with a value of ***&lt;redacted&gt;*** to prevent sensitive information from being logged. This is non-configurable.

Here an example of the access log emitted in JSON format to a storage account.

```JSON
{
    "category": "TrafficControllerAccessLog",
    "operationName": "ReqRespLogs",
    "properties": {
        "backendHost": "10.1.0.15:80",
        "backendIp": "10.1.0.15",
        "backendPort": "80",
        "backendResponseLatency": "2",
        "backendTimeTaken": "-",
        "clientIp": "xxx.xxx.xxx.xxx:52526",
        "frontendName": "frontend-primary",
        "frontendPort": "443",
        "frontendTLSFailureReason": "-",
        "frontendTLSPeerFingerprint": "2c01bbc93009ad1fc977fe9115fae7ad298b665f",
        "hostName": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.fzXX.alb.azure.com",
        "httpMethod": "GET",
        "httpStatusCode": "200",
        "httpVersion": "HTTP\/1.1",
        "referer": "-",
        "requestBodyBytes": "0",
        "requestHeaderBytes": "223",
        "requestUri": "\/index.php",
        "responseBodyBytes": "91",
        "responseHeaderBytes": "190",
        "timeTaken": "2",
        "tlsCipher": "TLS_AES_256_GCM_SHA384",
        "tlsProtocol": "-",
        "trackingId": "0ef125db-7fb7-48a0-b3fe-03fe0ffed873",
        "userAgent": "curl\/7.81.0"
    },
    "resourceId": "/SUBSCRIPTIONS/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/RESOURCEGROUPS/YYYYYY/PROVIDERS/MICROSOFT.SERVICENETWORKING/TRAFFICCONTROLLERS/ZZZZZZZ",
    "time": "2023-07-22T06:26:58.895Z",
    "location": "northcentralus"
}
```

### Firewall log format

The firewall log is generated only if a security policy of type `WAF` is defined. Each firewall log entry in Application Gateway for Containers contains the following information.

| Value | Description |
| --- | --- |
| TimeGenerated | Time (UTC) when the log was created. |
| OperationName | Name of the operation. |
| InstanceId | Application Gateway instance for which firewall data is being generated. For a multiple-instance application gateway, there is one row per instance. |
| ClientIp | Originating IP for the request. |
| ClientPort | Originating port for the request. |
| Action | Action taken on the request. Available values are Blocked and Allowed (for custom rules), Matched (when a rule matches a part of the request), and Detected and Blocked (these are both for mandatory rules). |
| Message | User-friendly message for the triggering event. More details are provided in the details section. |
| DetailedMessage | Description of the rule for the triggered event. |
| DetailedData | Specific data found in request that matched the rule for the triggered event. |
| FileDetails | Configuration file that contained the rule for the triggered event. |
| LineDetails | Line number in the configuration file that triggered the event. |
| Hostname | Hostname or IP address of the Application Gateway. |
| PolicyId | Resource ID of the web application firewall policy. |
| PolicyScope | A named scope consisting of Kubernetes resource references the scope is applied to. |
| PolicyScopeName | The name to the type of scope assignment the web application firewall policy is assigned to. |
| RequestUri | URL of the received request. |
| RuleSetType | Rule set type. The available value is Microsoft\_DefaultRuleSet or Microsoft\_BotManagerRuleSet. |
| RuleSetVersion | Rule set version used for Microsoft\_DefaultRuleSet or Microsoft\_BotManagerRuleSet. |
| RuleId | Rule ID of the triggering event. |
| TrackingId | Generated guid by Application Gateway for Containers |

```json
{
    "timeStamp": "2025-06-17T20:06:05+00:00",
    "resourceId": "/SUBSCRIPTIONS/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/RESOURCEGROUPS/YYYYYY/PROVIDERS/MICROSOFT.SERVICENETWORKING/TRAFFICCONTROLLERS/ZZZZZZZ",
    "operationName": "TrafficControllerFirewall",
    "category": "TrafficControllerFirewallLog",
    "properties": {
        "instanceId": "8a02ae47-8435-4f3d-84a5-6f5ded3763f5",
        "clientIp": "xxx.xxx.xxx.xxx",
        "requestUri": "\/?1=1=1",
        "ruleSetType": "Microsoft_DefaultRuleSet",
        "ruleSetVersion": "2.1",
        "ruleId": "949110",
        "ruleGroup": "BLOCKING-EVALUATION",
        "message": "Inbound Anomaly Score Exceeded (Total Score: 5)",
        "action": "Blocked",
        "details": {
            "message": "Greater and Equal to Tx:inbound_anomaly_score_threshold at TX:anomaly_score.",
            "data": "",
            "file": "BLOCKING-EVALUATION.conf",
            "line": "36"
        },
        "hostName": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.fzXX.alb.azure.com",
        "trackingId": "0ef125db-7fb7-48a0-b3fe-03fe0ffed873",
        "policyId": "/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/YYYYYY/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/ZZZZZZZ",
        "policyScope": "HTTPRoute-test-infra-contoso-waf-route-rule-0-match-0-waf.fzXX.alb.azure.com",
        "policyScopeName": "Route",
        "engine": "Azwaf"
    },
    "location": "northcentralus"
}
```