---
layout: Conceptual
title: Monitor GitOps (Flux v2) status and activity - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/monitor-gitops-flux-2
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
author: davidsmatlak
learn_banner_products:
- azure
ms.reviewer: davidsmatlak
ms.author: davidsmatlak
ms.service: azure-arc
ms.subservice: azure-arc-kubernetes
ms.date: 2025-02-26T00:00:00.0000000Z
ms.topic: how-to
description: Learn how to monitor status, compliance, resource consumption, and reconciliation activity for GitOps with Flux v2.
ms.custom: sfi-image-nochange
locale: en-us
document_id: 25786450-c6b5-0751-efb4-20912c67340b
document_version_independent_id: 2b172ad8-b7ee-608f-8813-c07307da14ae
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/monitor-gitops-flux-2.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/monitor-gitops-flux-2
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/monitor-gitops-flux-2.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/71313085-034b-42dc-8446-58627936c72c
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/32072957-9d5a-4e26-8db5-633ab8b422ea
platformId: 6f5855d2-76de-cb0b-f9b0-e341f8b03b6f
---

# Monitor GitOps (Flux v2) status and activity - Azure Arc | Microsoft Learn

To monitor status and activity related to GitOps with Flux v2 in your Azure Arc-enabled Kubernetes clusters or Azure Kubernetes Service (AKS) clusters, you have several options:

- Use the Azure portal to monitor Flux configurations and resources on individual clusters.
- Use a Grafana dashboard to monitor deployment and compliance status.
- Use the Flux Control Plane and Flux Cluster Stats dashboards to monitor resource consumption and reconciliations.
- Enable Prometheus scraping from clusters and create your own dashboards using the data in Azure Monitor workspace.
- Create alerts on Azure Monitor using the data available through Prometheus scraping.

This topic describes some of the ways you can monitor your Flux activity and status.

## Monitor Flux configurations in the Azure portal

After you [create Flux configurations](tutorial-use-gitops-flux2#apply-a-flux-configuration) on your cluster, you can view status information in the Azure portal by navigating to a cluster and selecting **GitOps** from the service menu.

### View details on cluster compliance and objects

The **Compliance** state shows whether the current state of the cluster matches the desired state. Possible values:

- **Compliant**: The cluster's state matches the desired state.
- **Pending**: An updated desired state was detected, but that state isn't yet reconciled on the cluster.
- **Not Compliant**: The current state doesn't match the desired state.

To help debug reconciliation issues for a cluster, select **Configuration objects**. Here, you can view logs of each of the configuration objects that Flux creates for each Flux configuration. Select an object name to view its logs.

[![Screenshot showing detailed conditions for a configuration object.](media/monitor-gitops-flux2/portal-configuration-object-details.png)](media/monitor-gitops-flux2/portal-configuration-object-details.png#lightbox)

To view the Kubernetes objects that were created as a result of Flux configurations being applied, select **Workloads** in the [Kubernetes resources](kubernetes-resource-view) section of the cluster's service menu. Here, you can view all details of any resources that were created on the cluster.

By default, you can filter by namespace and service name. You can also add any label filter that you may be using in your applications to help narrow down the search.

### View Flux configuration state and details

For each Flux configuration, the **State** column indicates whether the Flux configuration object was successfully created on the cluster.

Select any Flux configuration to see its **Overview** page, including the following information:

- Source commit ID for the last synchronization
- Timestamp of the latest source update
- Status update timestamp (indicating when the latest statistics were obtained)
- Repo URL and branch
- Links to view different kustomizations

[![Screenshot of the Overview page of a Flux configuration in the Azure portal.](media/monitor-gitops-flux2/portal-gitops-overview.png)](media/monitor-gitops-flux2/portal-gitops-overview.png#lightbox)

## Use dashboards to monitor GitOps status and activity

We provide dashboards to help you monitor status, compliance, resource consumption, and reconciliation activity for GitOps with Flux v2. These JSON dashboards can be imported to Grafana to help you view and analyze your data in real time. You can also set up alerts for this information.

To import and use these dashboards, you need:

- One or more existing Arc-enabled Kubernetes clusters or AKS clusters.
- The [microsoft.flux extension](extensions-release#flux-gitops) installed on the clusters.
- At least one [Flux configuration](tutorial-use-gitops-flux2) created on the clusters.

## Monitor deployment and compliance status

Follow these steps to import dashboards that let you monitor Flux extension deployment and status across clusters, and the compliance status of Flux configuration on those clusters.

Note

These steps describe the process for importing the dashboard to [Azure Managed Grafana](/en-us/azure/managed-grafana/overview). You can also [import this dashboard to any Grafana instance](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/import-dashboards/). With this option, a service principal must be used; managed identity is not supported for data connection outside of Azure Managed Grafana.

1. Create an Azure Managed Grafana instance by using the [Azure portal](/en-us/azure/managed-grafana/quickstart-managed-grafana-portal) or [Azure CLI](/en-us/azure/managed-grafana/quickstart-managed-grafana-cli). Ensure that you're able to access Grafana by selecting its endpoint on the Overview page. You need at least **Grafana Editor** level permissions to view and edit dashboards. You can check your access by going to **Access control (IAM)** on the Grafana instance.
2. If you're using a managed identity for the Azure Managed Grafana instance, follow these steps to assign it the **Monitoring Reader** role on the subscription where you created your Azure Managed Grafana instance:

    1. In the Azure portal, navigate to the subscription that you want to add.
    2. Select **Access control (IAM)**.
    3. Select **Add role assignment**.
    4. Select the **Monitoring Reader** role, then select **Next**.
    5. On the **Members** tab, select **Managed identity**, then choose **Select members**.
    6. From the **Managed identity** list, select the subscription, then select **Azure Managed Grafana** and the name of your Azure Managed Grafana instance.
    7. Select **Review + assign**.

    If you're using a service principal, grant the **Monitoring Reader** role to the service principal that you'll use for your data source connection. Follow these same steps, but change the **Assign access to** selection to **User, group, or service principal**. Then choose **Select members** and select your service principal. (If you're using a Grafana instance outside of Azure Managed Grafana, you must use a service principal for data connection access.)
3. [Create the Azure Monitor Data Source connection](https://grafana.com/docs/grafana/latest/datasources/azure-monitor/) in your Azure Managed Grafana instance. This connection lets the dashboard access Azure Resource Graph data.
4. Download the [GitOps Flux - Application Deployments Dashboard](https://github.com/Azure/fluxv2-grafana-dashboards/blob/main/dashboards/GitOps%20Flux%20-%20Application%20Deployments%20Dashboard.json).
5. Follow the steps to [import the JSON dashboard to Azure Managed Grafana](/en-us/azure/managed-grafana/how-to-create-dashboard#import-a-json-dashboard) or [import the dashboard to another Grafana instance](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/import-dashboards/).

After you import the dashboard, it displays information from the clusters that you're monitoring, with several panels that provide details. For more details on an item, select the link to visit the Azure portal, where you can find information about configurations, errors and logs.

[![Screenshot of the Flux Application Deployments Dashboard.](media/monitor-gitops-flux2/flux-application-deployments-dashboard.png)](media/monitor-gitops-flux2/flux-application-deployments-dashboard.png#lightbox)

The **Flux Extension Deployment Status** table lists all clusters where the Flux extension is deployed, along with current deployment status.

[![Screenshot showing the Flux Extension Deployments Status table in the Application Deployments dashboard.](media/monitor-gitops-flux2/flux-extension-deployments-status.png)](media/monitor-gitops-flux2/flux-extension-deployments-status.png#lightbox)

The **Flux Configuration Compliance Status** table lists all Flux configurations created on the clusters, along with their compliance status. To see status and error logs for configuration objects such as Helm releases and kustomizations, select the **Non-Compliant** link from the **ComplianceState** column.

[![Screenshot showing the Flux Configuration Compliance Status table in the Application Deployments dashboard.](media/monitor-gitops-flux2/flux-configuration-compliance.png)](media/monitor-gitops-flux2/flux-configuration-compliance.png#lightbox)

The **Count of Flux Extension Deployments by Status** chart shows the count of clusters, based on their provisioning state.

![Screenshot of the Flux Extension Deployments by Status pie chart in the Application Deployments dashboard.](media/monitor-gitops-flux2/flux-deployments-by-status.png)

The **Count of Flux Configurations by Compliance Status** chart shows the count of Flux configurations, based on their compliance status with respect to the source repository.

![Screenshot of the Flux Configuration by Compliance Status chart on the Application Deployments dashboard.](media/monitor-gitops-flux2/flux-configurations-by-status.png)

### Filter dashboard data to track application deployments

You can filter data in the **GitOps Flux - Application Deployments Dashboard** to change the information shown. For example, you can show data for only certain subscriptions or resource groups, or limit data to a particular cluster. To do so, select the filter option either from the top level dropdowns or from any column header in the tables.

For example, in the **Flux Configuration Compliance Status** table, you can select a specific commit from the **SourceLastSyncCommit** column. By doing so, you can track the status of a configuration deployment to all of the clusters affected by that commit.

### Create alerts for extension and configuration failures

After you import the dashboard as described in the previous section, you can set up alerts. These alerts notify you when Flux extensions or Flux configurations experience failures.

Follow these steps to create an alert. Example queries are provided to detect extension provisioning or extension upgrade failures, or to detect compliance state failures.

1. In the left navigation menu of the dashboard, select **Alerting**.
2. Select **Alert rules**.
3. Select **+ Create alert rule**. The new alert rule page opens, with the **Grafana managed alerts** option selected by default.
4. In **Rule name**, add a descriptive name. This name is displayed in the alert rule list, and it's used as the `alertname` label for every alert instance created from this rule.
5. Under **Set a query and alert condition**:

    - Select a data source. The same data source used for the dashboard may be used here.
    - For **Service**, select **Azure Resource Graph**.
    - Select the subscriptions from the dropdown list.
    - Enter the query you want to use. For example, for extension provisioning or upgrade failures, you can enter this query:

        ```kusto
        kubernetesconfigurationresources
        | where type == "microsoft.kubernetesconfiguration/extensions"
        | extend provisioningState = tostring(properties.ProvisioningState)
        | where provisioningState == "Failed"
        | summarize count() by provisioningState
        ```

        Or for compliance state failures, you can enter this query:

        ```kusto
        kubernetesconfigurationresources
        | where type == "microsoft.kubernetesconfiguration/fluxconfigurations"
        | extend complianceState=tostring(properties.complianceState)
        | where complianceState == "Non-Compliant"
        | summarize count() by complianceState
        ```
    - For **Threshold box**, select **A** for input type and set the threshold to **0** to receive alerts even if just one extension fails on the cluster. Mark this as the **Alert condition**.

    [![Screenshot showing the alert creation process.](media/monitor-gitops-flux2/application-dashboard-set-alerts.png)](media/monitor-gitops-flux2/application-dashboard-set-alerts.png#lightbox)
6. Specify the alert evaluation interval:

    - For **Condition**, select the query or expression to trigger the alert rule.
    - For **Evaluate every**, enter the evaluation frequency as a multiple of 10 seconds.
    - For **Evaluate for**, specify how long the condition must be true before the alert is created.
    - In **Configure no data and error handling**, indicate what should happen when the alert rule returns no data or returns an error.
    - To check the results from running the query, select **Preview**.
7. Add the storage location, rule group, and any other metadata that you want to associate with the rule.

    - For **Folder**, select the folder where the rule should be stored.
    - For **Group**, specify a predefined group.
    - If desired, add a description and summary to customize alert messages.
    - Add Runbook URL, panel, dashboard, and alert IDs as needed.
8. If desired, add any custom labels. Then select **Save**.

You can also [configure contact points and notification policies](https://grafana.com/docs/grafana/latest/alerting/configure-notifications/manage-contact-points/) for your alerts.

## Monitor resource consumption and reconciliations

Follow these steps to import dashboards that let you monitor Flux resource consumption, reconciliations, API requests, and reconciler status.

1. Follow the steps to [create an Azure Monitor Workspace](/en-us/azure/azure-monitor/essentials/azure-monitor-workspace-manage).
2. Create an Azure Managed Grafana instance by using the [Azure portal](/en-us/azure/managed-grafana/quickstart-managed-grafana-portal) or [Azure CLI](/en-us/azure/managed-grafana/quickstart-managed-grafana-cli).
3. Enable Prometheus metrics collection on the [AKS clusters](/en-us/azure/azure-monitor/containers/prometheus-metrics-enable) and/or [Arc-enabled Kubernetes clusters](/en-us/azure/azure-monitor/essentials/prometheus-metrics-from-arc-enabled-cluster) that you want to monitor.
4. Configure Azure Monitor Agent to scrape the Azure Managed Flux metrics by creating a [configmap](/en-us/azure/azure-monitor/essentials/prometheus-metrics-scrape-configuration):

    ```yaml
    kind: ConfigMap
    apiVersion: v1
    data:
      schema-version:
          #string.used by agent to parse config. supported versions are {v1}. Configs with other schema versions will be rejected by the agent.
        v1
      config-version:
        #string.used by customer to keep track of this config file's version in their source control/repository (max allowed 10 chars, other chars will be truncated)
        ver1
      default-scrape-settings-enabled: |-
        kubelet = true
        coredns = false
        cadvisor = true
        kubeproxy = false
        apiserver = false
        kubestate = true
        nodeexporter = true
        windowsexporter = false
        windowskubeproxy = false
        kappiebasic = true
        prometheuscollectorhealth = false
      # Regex for which namespaces to scrape through pod annotation based scraping.
      # This is none by default. Use '.*' to scrape all namespaces of annotated pods.
      pod-annotation-based-scraping: |-
        podannotationnamespaceregex = "flux-system"
      default-targets-scrape-interval-settings: |-
        kubelet = "30s"
        coredns = "30s"
        cadvisor = "30s"
        kubeproxy = "30s"
        apiserver = "30s"
        kubestate = "30s"
        nodeexporter = "30s"
        windowsexporter = "30s"
        windowskubeproxy = "30s"
        kappiebasic = "30s"
        prometheuscollectorhealth = "30s"
        podannotations = "30s"
    metadata:
      name: ama-metrics-settings-configmap
      namespace: kube-system
    ```
5. Download the [Flux Control Plane](https://github.com/Azure/fluxv2-grafana-dashboards/blob/main/dashboards/Flux%20Control%20Plane.json) and [Flux Cluster Stats](https://github.com/Azure/fluxv2-grafana-dashboards/blob/main/dashboards/Flux%20Cluster%20Stats.json) dashboards.
6. [Link the Managed Prometheus workspace to the Managed Grafana instance](/en-us/azure/azure-monitor/essentials/azure-monitor-workspace-manage#link-a-grafana-workspace). This process takes a few minutes to complete.
7. Follow the steps to [import these JSON dashboards to Grafana](/en-us/azure/managed-grafana/how-to-create-dashboard#import-a-json-dashboard).

After you import the dashboards, they display information from the clusters that you're monitoring. To show information only for a particular cluster or namespace, use the filters near the top of each dashboard.

The **Flux Control Plane** dashboard shows details about status resource consumption, reconciliations at the cluster level, and Kubernetes API requests.

[![Screenshot of the Flux Control Plane dashboard.](media/monitor-gitops-flux2/flux-control-plane-dashboard.png)](media/monitor-gitops-flux2/flux-control-plane-dashboard.png#lightbox)

The **Flux Cluster Stats** dashboard shows details about the number of reconcilers, along with the status and execution duration of each reconciler.

[![Screenshot of the Flux Cluster Stats dashboard.](media/monitor-gitops-flux2/flux-cluster-stats-dashboard.png)](media/monitor-gitops-flux2/flux-cluster-stats-dashboard.png#lightbox)

### Create alerts for resource consumption and reconciliation issues

After you import the dashboard as described in the previous section, you can set up alerts. These alerts notify you of resource consumption and reconciliation issues that may require attention.

To enable these alerts, you deploy a Bicep template similar to the one shown here. The alert rules in this template are samples that can be modified as needed.

After you download the Bicep template and make your changes, [follow these steps to deploy the template](/en-us/azure/azure-resource-manager/bicep/template-specs).

```bicep
param azureMonitorWorkspaceName string
param alertReceiverEmailAddress string

param kustomizationLookbackPeriodInMinutes int = 5
param helmReleaseLookbackPeriodInMinutes int = 5
param gitRepositoryLookbackPeriodInMinutes int = 5
param bucketLookbackPeriodInMinutes int = 5
param helmRepoLookbackPeriodInMinutes int = 5
param timeToResolveAlerts string = 'PT10M'
param location string = resourceGroup().location

resource azureMonitorWorkspace 'Microsoft.Monitor/accounts@2023-04-03' = {
  name: azureMonitorWorkspaceName
  location: location
}

resource fluxRuleActionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: 'fluxRuleActionGroup'
  location: 'global'
  properties: {
    enabled: true
    groupShortName: 'fluxGroup'
    emailReceivers: [
      {
        name: 'emailReceiver'
        emailAddress: alertReceiverEmailAddress
      }
    ]
  }
}

resource fluxRuleGroup 'Microsoft.AlertsManagement/prometheusRuleGroups@2023-03-01' = {
  name: 'fluxRuleGroup'
  location: location
  properties: {
    description: 'Flux Prometheus Rule Group'
    scopes: [
      azureMonitorWorkspace.id
    ]
    enabled: true
    interval: 'PT1M'
    rules: [
      {
        alert: 'KustomizationNotReady'
        expression: 'sum by (cluster, namespace, name) (gotk_reconcile_condition{type="Ready", status="False", kind="Kustomization"}) > 0'
        for: 'PT${kustomizationLookbackPeriodInMinutes}M'
        labels: {
          description: 'Kustomization reconciliation failing for last ${kustomizationLookbackPeriodInMinutes} minutes.'
        }
        annotations: {
          description: 'Kustomization reconciliation failing for last ${kustomizationLookbackPeriodInMinutes} minutes.'
        }
        enabled: true
        severity: 3
        resolveConfiguration: {
          autoResolved: true
          timeToResolve: timeToResolveAlerts
        }
        actions: [
          {
            actionGroupId: fluxRuleActionGroup.id
          }
        ]
      }
      {
        alert: 'HelmReleaseNotReady'
        expression: 'sum by (cluster, namespace, name) (gotk_reconcile_condition{type="Ready", status="False", kind="HelmRelease"}) > 0'
        for: 'PT${helmReleaseLookbackPeriodInMinutes}M'
        labels: {
          description: 'HelmRelease reconciliation failing for last ${helmReleaseLookbackPeriodInMinutes} minutes.'
        }
        annotations: {
          description: 'HelmRelease reconciliation failing for last ${helmReleaseLookbackPeriodInMinutes} minutes.'
        }
        enabled: true
        severity: 3
        resolveConfiguration: {
          autoResolved: true
          timeToResolve: timeToResolveAlerts
        }
        actions: [
          {
            actionGroupId: fluxRuleActionGroup.id
          }
        ]
      }
      {
        alert: 'GitRepositoryNotReady'
        expression: 'sum by (cluster, namespace, name) (gotk_reconcile_condition{type="Ready", status="False", kind="GitRepository"}) > 0'
        for: 'PT${gitRepositoryLookbackPeriodInMinutes}M'
        labels: {
          description: 'GitRepository reconciliation failing for last ${gitRepositoryLookbackPeriodInMinutes} minutes.'
        }
        annotations: {
          description: 'GitRepository reconciliation failing for last ${gitRepositoryLookbackPeriodInMinutes} minutes.'
        }
        enabled: true
        severity: 3
        resolveConfiguration: {
          autoResolved: true
          timeToResolve: timeToResolveAlerts
        }
        actions: [
          {
            actionGroupId: fluxRuleActionGroup.id
          }
        ]
      }
      {
        alert: 'BucketNotReady'
        expression: 'sum by (cluster, namespace, name) (gotk_reconcile_condition{type="Ready", status="False", kind="Bucket"}) > 0'
        for: 'PT${bucketLookbackPeriodInMinutes}M'
        labels: {
          description: 'Bucket reconciliation failing for last ${bucketLookbackPeriodInMinutes} minutes.'
        }
        annotations: {
          description: 'Bucket reconciliation failing for last ${bucketLookbackPeriodInMinutes} minutes.'
        }
        enabled: true
        severity: 3
        resolveConfiguration: {
          autoResolved: true
          timeToResolve: timeToResolveAlerts
        }
        actions: [
          {
            actionGroupId: fluxRuleActionGroup.id
          }
        ]
      }
      {
        alert: 'HelmRepositoryNotReady'
        expression: 'sum by (cluster, namespace, name) (gotk_reconcile_condition{type="Ready", status="False", kind="HelmRepository"}) > 0'
        for: 'PT${helmRepoLookbackPeriodInMinutes}M'
        labels: {
          description: 'HelmRepository reconciliation failing for last ${helmRepoLookbackPeriodInMinutes} minutes.'
        }
        annotations: {
          description: 'HelmRepository reconciliation failing for last ${helmRepoLookbackPeriodInMinutes} minutes.'
        }
        enabled: true
        severity: 3
        resolveConfiguration: {
          autoResolved: true
          timeToResolve: timeToResolveAlerts
        }
        actions: [
          {
            actionGroupId: fluxRuleActionGroup.id
          }
        ]
      }
    ]
  }
}

```