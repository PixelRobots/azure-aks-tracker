---
layout: Conceptual
title: Resource Graph Queries for Azure Container Registry - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/resource-graph-samples
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/62/azure-container-registry/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/180a533d-0d25-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: KumudD
learn_banner_products:
- azure
manager: kumud
ms.reviewer: kumud
ms.author: kumud
ms.service: azure-container-registry
description: Sample Azure Resource Graph queries for Azure Container Registry using resource types and tables to access related resources and properties.
ms.topic: sample
ms.date: 2023-10-31T00:00:00.0000000Z
ms.custom: subject-resourcegraph-sample
locale: en-us
document_id: 54242a96-fe6c-16d3-7815-54ccd72d9ed1
document_version_independent_id: dc81d9e6-18ad-030f-382a-d0a8b3db306e
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/resource-graph-samples.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli,azurepowershell
toc_rel: toc.json
asset_id: container-registry/resource-graph-samples
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/resource-graph-samples.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/d3928677-9b71-43a6-875f-004dc4f98b65
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/6bbc70ca-58b2-4c69-8249-28ec92c08029
platformId: db535376-de6c-c626-3148-7c21f21b7dc5
---

# Resource Graph Queries for Azure Container Registry - Azure Container Registry | Microsoft Learn

This page is a collection of [Azure Resource Graph](/en-us/azure/governance/resource-graph/overview) sample queries for Azure Container Registry.

Tip

You can use Microsoft Copilot in Azure to author Azure Resource Graph queries using natural language. For more information, see [Get resource information using Microsoft Copilot in Azure](/en-us/azure/copilot/get-information-resource-graph).

## Sample queries

### List Container Registry vulnerability assessment results

Returns all the vulnerabilities found on container images. Microsoft Defender for Containers has to be enabled in order to view these security findings.

```kusto
SecurityResources
| where type == 'microsoft.security/assessments'
| where properties.displayName contains 'Container registry images should have vulnerability findings resolved'
| summarize by assessmentKey=name //the ID of the assessment
| join kind=inner (
  securityresources
  | where type == 'microsoft.security/assessments/subassessments'
  | extend assessmentKey = extract('.*assessments/(.+?)/.*',1,  id)
) on assessmentKey
| project assessmentKey, subassessmentKey=name, id, parse_json(properties), resourceGroup, subscriptionId, tenantId
| extend description = properties.description,
  displayName = properties.displayName,
  resourceId = properties.resourceDetails.id,
  resourceSource = properties.resourceDetails.source,
  category = properties.category,
  severity = properties.status.severity,
  code = properties.status.code,
  timeGenerated = properties.timeGenerated,
  remediation = properties.remediation,
  impact = properties.impact,
  vulnId = properties.id,
  additionalData = properties.additionalData
```

# [Azure CLI](#tab/azure-cli)
```azurecli
az graph query -q "SecurityResources | where type == 'microsoft.security/assessments' | where properties.displayName contains 'Container registry images should have vulnerability findings resolved' | summarize by assessmentKey=name //the ID of the assessment | join kind=inner ( securityresources | where type == 'microsoft.security/assessments/subassessments' | extend assessmentKey = extract('.*assessments/(.+?)/.*',1, id) ) on assessmentKey | project assessmentKey, subassessmentKey=name, id, parse_json(properties), resourceGroup, subscriptionId, tenantId | extend description = properties.description, displayName = properties.displayName, resourceId = properties.resourceDetails.id, resourceSource = properties.resourceDetails.source, category = properties.category, severity = properties.status.severity, code = properties.status.code, timeGenerated = properties.timeGenerated, remediation = properties.remediation, impact = properties.impact, vulnId = properties.id, additionalData = properties.additionalData"
```

# [Azure PowerShell](#tab/azure-powershell)
```azurepowershell
Search-AzGraph -Query "SecurityResources | where type == 'microsoft.security/assessments' | where properties.displayName contains 'Container registry images should have vulnerability findings resolved' | summarize by assessmentKey=name //the ID of the assessment | join kind=inner ( securityresources | where type == 'microsoft.security/assessments/subassessments' | extend assessmentKey = extract('.*assessments/(.+?)/.*',1, id) ) on assessmentKey | project assessmentKey, subassessmentKey=name, id, parse_json(properties), resourceGroup, subscriptionId, tenantId | extend description = properties.description, displayName = properties.displayName, resourceId = properties.resourceDetails.id, resourceSource = properties.resourceDetails.source, category = properties.category, severity = properties.status.severity, code = properties.status.code, timeGenerated = properties.timeGenerated, remediation = properties.remediation, impact = properties.impact, vulnId = properties.id, additionalData = properties.additionalData"
```

# [Portal](#tab/azure-portal)
- Azure portal: [portal.azure.com](https://portal.azure.com/#blade/HubsExtension/ArgQueryBlade/query/SecurityResources%0a%7c%20where%20type%20%3d%3d%20%27microsoft.security%2fassessments%27%0a%7c%20where%20properties.displayName%20contains%20%27Container%20registry%20images%20should%20have%20vulnerability%20findings%20resolved%27%0a%7c%20summarize%20by%20assessmentKey%3dname%20%2f%2fthe%20ID%20of%20the%20assessment%0a%7c%20join%20kind%3dinner%20%28%0a%09securityresources%0a%09%7c%20where%20type%20%3d%3d%20%27microsoft.security%2fassessments%2fsubassessments%27%0a%09%7c%20extend%20assessmentKey%20%3d%20extract%28%27.*assessments%2f%28.%2b%3f%29%2f.*%27%2c1%2c%20%20id%29%0a%29%20on%20assessmentKey%0a%7c%20project%20assessmentKey%2c%20subassessmentKey%3dname%2c%20id%2c%20parse_json%28properties%29%2c%20resourceGroup%2c%20subscriptionId%2c%20tenantId%0a%7c%20extend%20description%20%3d%20properties.description%2c%0a%09displayName%20%3d%20properties.displayName%2c%0a%09resourceId%20%3d%20properties.resourceDetails.id%2c%0a%09resourceSource%20%3d%20properties.resourceDetails.source%2c%0a%09category%20%3d%20properties.category%2c%0a%09severity%20%3d%20properties.status.severity%2c%0a%09code%20%3d%20properties.status.code%2c%0a%09timeGenerated%20%3d%20properties.timeGenerated%2c%0a%09remediation%20%3d%20properties.remediation%2c%0a%09impact%20%3d%20properties.impact%2c%0a%09vulnId%20%3d%20properties.id%2c%0a%09additionalData%20%3d%20properties.additionalData)
- Azure Government portal: [portal.azure.us](https://portal.azure.us/#blade/HubsExtension/ArgQueryBlade/query/SecurityResources%0a%7c%20where%20type%20%3d%3d%20%27microsoft.security%2fassessments%27%0a%7c%20where%20properties.displayName%20contains%20%27Container%20registry%20images%20should%20have%20vulnerability%20findings%20resolved%27%0a%7c%20summarize%20by%20assessmentKey%3dname%20%2f%2fthe%20ID%20of%20the%20assessment%0a%7c%20join%20kind%3dinner%20%28%0a%09securityresources%0a%09%7c%20where%20type%20%3d%3d%20%27microsoft.security%2fassessments%2fsubassessments%27%0a%09%7c%20extend%20assessmentKey%20%3d%20extract%28%27.*assessments%2f%28.%2b%3f%29%2f.*%27%2c1%2c%20%20id%29%0a%29%20on%20assessmentKey%0a%7c%20project%20assessmentKey%2c%20subassessmentKey%3dname%2c%20id%2c%20parse_json%28properties%29%2c%20resourceGroup%2c%20subscriptionId%2c%20tenantId%0a%7c%20extend%20description%20%3d%20properties.description%2c%0a%09displayName%20%3d%20properties.displayName%2c%0a%09resourceId%20%3d%20properties.resourceDetails.id%2c%0a%09resourceSource%20%3d%20properties.resourceDetails.source%2c%0a%09category%20%3d%20properties.category%2c%0a%09severity%20%3d%20properties.status.severity%2c%0a%09code%20%3d%20properties.status.code%2c%0a%09timeGenerated%20%3d%20properties.timeGenerated%2c%0a%09remediation%20%3d%20properties.remediation%2c%0a%09impact%20%3d%20properties.impact%2c%0a%09vulnId%20%3d%20properties.id%2c%0a%09additionalData%20%3d%20properties.additionalData)
- Microsoft Azure operated by 21Vianet portal: [portal.azure.cn](https://portal.azure.cn/#blade/HubsExtension/ArgQueryBlade/query/SecurityResources%0a%7c%20where%20type%20%3d%3d%20%27microsoft.security%2fassessments%27%0a%7c%20where%20properties.displayName%20contains%20%27Container%20registry%20images%20should%20have%20vulnerability%20findings%20resolved%27%0a%7c%20summarize%20by%20assessmentKey%3dname%20%2f%2fthe%20ID%20of%20the%20assessment%0a%7c%20join%20kind%3dinner%20%28%0a%09securityresources%0a%09%7c%20where%20type%20%3d%3d%20%27microsoft.security%2fassessments%2fsubassessments%27%0a%09%7c%20extend%20assessmentKey%20%3d%20extract%28%27.*assessments%2f%28.%2b%3f%29%2f.*%27%2c1%2c%20%20id%29%0a%29%20on%20assessmentKey%0a%7c%20project%20assessmentKey%2c%20subassessmentKey%3dname%2c%20id%2c%20parse_json%28properties%29%2c%20resourceGroup%2c%20subscriptionId%2c%20tenantId%0a%7c%20extend%20description%20%3d%20properties.description%2c%0a%09displayName%20%3d%20properties.displayName%2c%0a%09resourceId%20%3d%20properties.resourceDetails.id%2c%0a%09resourceSource%20%3d%20properties.resourceDetails.source%2c%0a%09category%20%3d%20properties.category%2c%0a%09severity%20%3d%20properties.status.severity%2c%0a%09code%20%3d%20properties.status.code%2c%0a%09timeGenerated%20%3d%20properties.timeGenerated%2c%0a%09remediation%20%3d%20properties.remediation%2c%0a%09impact%20%3d%20properties.impact%2c%0a%09vulnId%20%3d%20properties.id%2c%0a%09additionalData%20%3d%20properties.additionalData)

---