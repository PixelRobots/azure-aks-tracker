---
layout: Conceptual
title: Get Upgrade Insights for Azure Arc-enabled Kubernetes clusters - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-upgrade-insights-arc-k8s
breadcrumb_path: ../../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/146/azure-arc/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/5c778dec-0625-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: ponatara
learn_banner_products:
- azure
ms.reviewer: davidsmatlak
ms.author: ponatara
ms.service: azure-arc
ms.subservice: azure-arc-kubernetes
description: Get Upgrade Insights for Azure Arc-enabled Kubernetes clusters
ms.topic: tutorial
ms.date: 2026-11-16T00:00:00.0000000Z
locale: en-us
document_id: 1b7b33ed-f1e7-a175-4bb6-a42099889fe7
document_version_independent_id: 45042939-b537-14df-5bf7-b611e21f60c9
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/tutorial-upgrade-insights-arc-k8s.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/tutorial-upgrade-insights-arc-k8s
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/tutorial-upgrade-insights-arc-k8s.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/970f20f1-2f12-4aa9-9c95-c00fe1f5e722
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/432c4950-b799-4ed5-93d5-b9b2934edf7d
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 8be236e7-11ee-4f4e-9b92-422fea7e5f83
---

# Get Upgrade Insights for Azure Arc-enabled Kubernetes clusters - Azure Arc | Microsoft Learn

Important

Kubernetes Upgrade Insights is currently in **public preview**. Preview features are provided under the [Supplemental Terms of Use for Microsoft Azure Previews](https://azure.microsoft.com/support/legal/preview-supplemental-terms/).

Kubernetes upgrades can expose application and cluster compatibility issues that are difficult to identify in advance. An API used by a workload might be removed in the target Kubernetes version, an installed component might not support the target version, or the cluster might have a health condition that could block the upgrade.

Kubernetes Upgrade Insights for Azure Arc-enabled Kubernetes provides a proactive, read-only assessment to help you identify these risks before you begin an upgrade. It evaluates your cluster for deprecated Kubernetes API usage, component compatibility, and upgrade readiness conditions. Upgrade Insights provides assessment findings and recommendations only. It doesn't initiate the Kubernetes upgrade or automatically remediate issues.

In this tutorial, you learn how to:

- Verify the prerequisites for Upgrade Insights.
- Enable Upgrade Insights from the Azure portal or Azure CLI.
- Confirm that the extension is installed and producing assessments.
- Review findings in the Azure portal.
- Import and use the optional Azure Monitor dashboard with Grafana.
- Query assessment results across clusters with Azure Resource Graph.
- Interpret findings and prepare for a Kubernetes upgrade.

## How Upgrade Insights works

Upgrade Insights is deployed as an Azure Arc-enabled Kubernetes cluster extension. After installation, the extension collects signals relevant to upgrade readiness and assesses the cluster against the next applicable minor Kubernetes version identified for the cluster.

The extension performs an initial assessment after installation and refreshes supported assessments daily. You can review the results in the Azure portal or query them at scale by using Azure Resource Graph. The extension publishes the results as Azure resources in your tenant.

Upgrade Insights evaluates three areas:

| Assessment area | What it identifies |
| --- | --- |
| Deprecated Kubernetes APIs | API versions used by workloads, controllers, clients, Helm charts, or automation that are deprecated or removed in the target Kubernetes version. |
| Component compatibility | Installed component versions that might be incompatible with, untested against, or undetermined for the target Kubernetes version. |
| Upgrade readiness | Current cluster health or configuration conditions that might block or disrupt an upgrade, including Pod Disruption Budgets, node readiness, and API server health. |

The component compatibility assessment currently evaluates a defined set of common components listed in the following table:

| Component category | Components evaluated |
| --- | --- |
| Cluster autoscaling | Cluster Autoscaler |
| Service mesh | Istio, Linkerd |
| Monitoring | Prometheus |
| Ingress | NGINX, Traefik |
| Cluster datastore | etcd |
| Container runtimes (CRI) | containerd, CRI-O |
| Cluster DNS | CoreDNS |
| Container networking (CNI) | Calico, Cilium, Flannel |
| Certificate management | cert-manager |
| Azure Arc agents | Azure Arc agents |

Note

Upgrade Insights doesn't replace your Kubernetes distribution's upgrade documentation or application-specific testing. The assessment covers a defined set of components and readiness conditions and might not identify every compatibility issue.

## Prerequisites

Before you begin, ensure that you have:

- An existing Kubernetes cluster connected to Azure Arc. To connect a cluster, see [Quickstart: Connect an existing Kubernetes cluster to Azure Arc](/en-us/azure/azure-arc/kubernetes/quickstart-connect-cluster?tabs=azure-cli).
- Access to Azure Public Cloud.
- Azure RBAC permissions to install cluster extension on the target cluster and view assessment results.
- Azure CLI, if you plan to use the command-line steps.
- The Kubernetes Upgrade Insights extension version 1.0.2 or later.

If you use Azure CLI, sign in and select the subscription that contains the Arc-enabled Kubernetes resource:

```azurecli
az login \
az account set --subscription <subscription-id>
```

## Enable Upgrade Insights

You can enable Upgrade Insights from the Azure portal or by using Azure CLI.

### Option 1: Enable Upgrade Insights in the Azure portal

1. Sign in to the [Azure portal](https://portal.azure.com/).
2. Navigate to **Azure Arc**.
3. Under **Infrastructure**, select **Kubernetes clusters**.
4. Select the target cluster or clusters.
5. Verify that each cluster has a **Connected** status.
6. Select **Enable Upgrade Insights**.
7. Follow the portal prompts to deploy the extension.

### Option 2: Enable Upgrade Insights with Azure CLI

Run the following command:

```azurecli
az k8s-extension create \
  --cluster-type connectedClusters \
  --cluster-name <cluster-name> \
  --resource-group <resource-group> \
  --name <extension-name> \
  --extension-type microsoft.kubernetesupgradeinsights
```

The extension deploys Upgrade Insights components in the `k8s-upgrade-insights` namespace. These components collect the signals required for the read-only assessment and publish the assessment results to Azure.

## Verify the extension installation

Check the extension provisioning state:

```azurecli
az k8s-extension show \
  --cluster-type connectedClusters \
  --cluster-name <cluster-name> \
  --resource-group <resource-group> \
  --name <extension-name> \
  --query provisioningState \
  --output tsv
```

The expected value is `Succeeded`.

You can also verify that the extension pods are running:

```bash
kubectl get pods -n k8s-upgrade-insights
```

Allow time for the initial assessment to complete and publish results. After the initial assessment, supported findings are refreshed daily.

## Review Upgrade Insights in the Azure portal

1. In the Azure portal, go to **Azure Arc** &gt; **Kubernetes clusters**.
2. Select the cluster where you enabled Upgrade Insights.
3. Open **Upgrade Insights**.
4. Review the current Kubernetes version, target Kubernetes version, assessment time, and summary of critical and warning findings.
5. Review each assessment category:
    - **Deprecated API usage**
    - **Component compatibility**
    - **Upgrade readiness**
6. Select a finding to view the affected resource or component, severity, details, and recommended remediation.

### Understand the findings

#### Deprecated API usage

For each deprecated API, Upgrade Insights shows information such as:

- Affected cluster.
- Current and target Kubernetes versions.
- API group, version, and resource.
- Kubernetes version in which the API is removed.
- Severity.
- Recently observed usage and request activity.

A **Critical** finding means that the API version is removed in the target Kubernetes version. A **Warning** means that the API is deprecated but remains available in the target version and is scheduled for removal in a later release.

Update workloads, controllers, manifests, Helm charts, and automation that use an API removed in the target Kubernetes version before you upgrade.

#### Component compatibility

For detected components, Upgrade Insights shows the installed version, compatibility status, severity, and a recommended action.

| Compatibility status | Meaning |
| --- | --- |
| Compatible | The detected component version is compatible with the target Kubernetes version. |
| Incompatible | The detected component version isn't compatible with the target version. Review the recommended minimum or supported version. |
| Not validated | Compatibility with the target version hasn't been validated. Investigate before upgrading. |
| Undetermined | Compatibility couldn't be determined from the available information. Review the component vendor's guidance. |

#### Upgrade readiness

Readiness checks evaluate the cluster's current health and configuration. Current checks include:

- **Pod Disruption Budgets:** Identifies configurations that might prevent pod eviction and block node drain.
- **Node readiness:** Identifies nodes that aren't reporting a ready status.
- **API server health:** Identifies API server health conditions that might prevent an upgrade from starting or completing successfully.

Resolve critical readiness findings before you begin the Kubernetes upgrade.

## Review fleet-level results in the Azure portal

Use the fleet-level multi-cluster Upgrade Insights experience to understand assessment coverage and findings across multiple Azure Arc-enabled Kubernetes clusters.

1. In the Azure portal, go to the Upgrade Insights fleet or multi-cluster experience.
2. Review the number of clusters with Upgrade Insights enabled and the number of clusters with available assessments.
3. Filter results by subscription, resource group, cluster, location, current Kubernetes version, target Kubernetes version, or severity.
4. Select a critical or warning summary to view the affected clusters and findings.

## Import the optional Grafana dashboard

You can keep the Azure Monitor dashboard with Grafana as an optional fleet visualization and troubleshooting experience. The dashboard uses Upgrade Insights assessment resources in Azure Resource Graph and provides summary metrics, filters, and detailed tables.

You don't need an Azure Managed Grafana workspace to use the provided dashboard with **Azure Monitor &gt; Dashboards with Grafana**.

1. Download or locate the provided `ArcKubernetesUpgradeInsights.json` dashboard file.
2. In the [Azure portal](https://portal.azure.com/), go to **Azure Monitor**.
3. Select **Dashboards with Grafana**.
4. Select **New** &gt; **Import**.
5. Upload `ArcKubernetesUpgradeInsights.json`.
6. Enter a dashboard name.
7. Select the subscription, resource group, and region where you want to save the dashboard resource.
8. Select **Import**.
9. Use the dashboard filters to select subscriptions, resource groups, clusters, locations, current Kubernetes versions, and target Kubernetes versions.

The dashboard includes views for:

- Total critical and warning issues.
- Clusters with assessment reports.
- Deprecated API summaries and details.
- Component compatibility summaries and recommendations.
- Pod Disruption Budget findings.
- Node readiness.
- API server health.

## Query results with Azure Resource Graph

Upgrade Insights publishes assessment resources with the following resource type:

`microsoft.kubernetesconfiguration/upgradeassessments`

### Query in Resource Graph Explorer

1. In the Azure portal, open **Resource Graph Explorer**.
2. Run the following query:

```kusto
KubernetesConfigurationResources
| where type =~ "microsoft.kubernetesconfiguration/upgradeassessments"
```

### Query with Azure CLI

Run the query:

```azurecli
az graph query -q "KubernetesConfigurationResources | where type =~ 'microsoft.kubernetesconfiguration/upgradeassessments'"
```

### Summarize critical and warning findings

The following query combines the three assessment categories and summarizes findings by severity:

```kusto
KubernetesConfigurationResources
| where type =~ "microsoft.kubernetesconfiguration/upgradeassessments"
| extend clusterName = tostring(split(id, "/")[8])
| extend findings = array_concat(
    properties.componentCompatibility,
    properties.deprecatedApis,
    properties.readinessChecks)
| mv-expand finding = findings
| summarize
    Critical = countif(tostring(finding.severity) =~ "Critical"),
    Warning = countif(tostring(finding.severity) =~ "Warning")
  by subscriptionId, resourceGroup, clusterName,
     currentVersion = tostring(properties.currentKubernetesVersion),
     targetVersion = tostring(properties.targetKubernetesVersion)
| order by Critical desc, Warning desc
```

## Remediate findings and prepare for the upgrade

Use the assessment as an input to your normal upgrade process:

1. Address deprecated APIs that are removed in the target Kubernetes version.
2. Upgrade or replace incompatible cluster components.
3. Investigate components with unvalidated or undetermined compatibility.
4. Resolve Pod Disruption Budget, node readiness, and API server health findings.
5. Recheck the portal or Azure Resource Graph after the next daily assessment.
6. Complete application, integration, backup, and recovery testing required by your organization.
7. Follow your Kubernetes distribution's upgrade guidance to perform the upgrade.

Important

Upgrade Insights is advisory. It doesn't schedule or perform upgrades, update APIs or components, change Pod Disruption Budgets, or repair unhealthy nodes.

## Troubleshooting

### No assessment results appear

If you don't see assessment results:

1. Verify that the extension provisioning state is `Succeeded`.
2. Verify that the pods in the `k8s-upgrade-insights` namespace are running.
3. Confirm that you have permission to read the Arc-enabled Kubernetes resource and Upgrade Insights assessment resources.
4. Allow time for the initial assessment to complete.
5. Query Azure Resource Graph directly to determine whether results are being published.

### The portal shows partial assessment coverage

Partial coverage can occur when Upgrade Insights isn't enabled on every selected cluster, the initial assessment hasn't completed, or a cluster isn't connected. Review the coverage information, verify the extension status on affected clusters, and check the assessment timestamp.

### A component is shown as not validated or undetermined

Review the component vendor's compatibility guidance for the target Kubernetes version. Upgrade Insights surfaces the available compatibility evidence but doesn't replace component-specific release notes and support policies.

## Current limitations

- You can't manually trigger an on-demand assessment.
- The assessment evaluates a defined set of components and readiness conditions.
- Findings don't replace distribution-specific compatibility checks, application testing, or upgrade documentation.
- Upgrade Insights doesn't guarantee that every application or component compatibility issue will be identified.

## Clean up resources

If you created the optional Grafana dashboard only for this tutorial, you can delete the dashboard resource from its resource group.

To remove the Upgrade Insights extension from a cluster, run:

```azurecli
az k8s-extension delete \
  --cluster-type connectedClusters \
  --cluster-name <cluster-name> \
  --resource-group <resource-group> \
  --name <extension-name> \
  --yes
```

Removing the extension stops future assessments for that cluster.