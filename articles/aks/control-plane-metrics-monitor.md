---
layout: Conceptual
title: Monitor AKS Control Plane Metrics - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/control-plane-metrics-monitor
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
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn how to monitor Azure Kubernetes Service (AKS) control plane metrics in Azure Monitor to ensure operational excellence and maintain the performance and availability of critical control plane components.
ms.date: 2026-09-06T00:00:00.0000000Z
ms.topic: how-to
author: schaffererin
ms.author: sunasing
ms.subservice: aks-monitoring
ai-usage: ai-assisted
locale: en-us
document_id: c6160af0-ea74-af27-6184-b83f20782b87
document_version_independent_id: 103a51a8-2a79-326e-82e7-964fc3c66370
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/control-plane-metrics-monitor.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/control-plane-metrics-monitor
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/control-plane-metrics-monitor.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
platformId: 4730febb-3e84-05d1-4fd6-d9afea1a9df6
---

# Monitor AKS Control Plane Metrics - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to monitor the Azure Kubernetes Service (AKS) control plane by using control plane metrics in Azure Monitor.

AKS supports a subset of control plane metrics free through [Azure Monitor platform metrics](monitor-aks#aks-monitoring-data-metrics-logs-integrations). The control plane metrics feature gives you visibility into the availability and performance of critical control plane components like the API server, etcd, the scheduler, the autoscaler, and the controller manager in AKS. The feature is also fully compatible with the managed service for Prometheus and Azure Managed Grafana. You can use these metrics to maximize overall observability and to maintain operational excellence for your AKS cluster.

## Control plane platform metrics

AKS offers some free control plane metrics for monitoring the API server and etcd. These metrics are automatically collected for all AKS clusters at no cost. You can analyze the metrics by using the [metrics explorer](/en-us/azure/azure-monitor/essentials/analyze-metrics) in the Azure portal. You can also create metrics-based alerts by using the metrics data.

To see the full list of supported control plane platform metrics, see the [AKS monitoring reference](monitor-aks-reference#metrics).

## Prerequisites and limitations

- The control plane metrics feature supports only the [managed service for Prometheus](/en-us/azure/azure-monitor/essentials/prometheus-metrics-overview) in Azure Monitor.
- [Azure Private Link](/en-us/azure/azure-monitor/logs/private-link-security) isn't supported.
- You can customize only the default [`ama-metrics-settings-configmap.yaml`](/en-us/azure/azure-monitor/containers/prometheus-metrics-scrape-configuration#configmaps) configmap file. No other customization is supported.
- Your AKS cluster must use [managed identity authentication](managed-identity-overview).

## Enable control plane metrics on an AKS cluster

Enable control plane metrics by using the managed service for Prometheus add-on when you create a new cluster or update an existing cluster.

Note

Unlike the metrics that are collected from cluster nodes, control plane metrics are collected by a component that isn't part of the `ama-metrics` add-on. Enabling control plane metrics (for example, by using the `--enable-control-plane-metrics` option) together with the managed service for Prometheus add-on ensures that control plane metrics are collected. AKS clusters that were previously enabled for control plane metrics during preview automatically have `--enable-control-plane-metrics` enabled and continue to collect control plane metrics. After you enable metrics collection, it can take several minutes for the data to appear in the workspace.

### New AKS cluster

Use the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command to enable control plane metrics collection through managed service for Prometheus. To learn how to collect managed service for Prometheus metrics from your AKS cluster, see [Enable Prometheus and Grafana for AKS clusters](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable#enable-prometheus-and-grafana).

```azurecli
az aks create --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --enable-control-plane-metrics --enable-azure-monitor-metrics
```

### Existing AKS cluster

If your cluster already has the managed service for Prometheus add-on, update the cluster to ensure that it collects control plane metrics by using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command:

```azurecli
az aks update --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --enable-control-plane-metrics
```

## Query control plane metrics

Control plane metrics are stored in an Azure Monitor workspace in the cluster's region. You can query the metrics directly in the workspace or by using the Azure Managed Grafana instance that's connected to the workspace.

1. In the [Azure portal](https://portal.azure.com), go to your AKS cluster resource.
2. On the left menu, select **Monitor** &gt; **Monitor Settings**.

    [![Screenshot of an example of an Azure Monitor workspace.](media/monitor-control-plane-metrics/azmon-settings.png)](media/monitor-control-plane-metrics/azmon-settings.png#lightbox)
3. Go to the Azure Monitor workspace that is linked to the cluster.

    [![Screenshot of the linked  Azure Monitor workspace.](media/monitor-control-plane-metrics/monitor-workspace.png)](media/monitor-control-plane-metrics/monitor-workspace.png#lightbox)
4. In the Azure Monitor workspace, under **Managed Prometheus**, query the metrics by using the Prometheus explorer.

    [![Screenshot that shows the Prometheus explorer experience.](media/monitor-control-plane-metrics/workspace-prometheus-explorer.png)](media/monitor-control-plane-metrics/workspace-prometheus-explorer.png#lightbox)

Note

AKS provides dashboard templates to help you view and analyze your control plane telemetry data in real time. If you use Azure Managed Grafana to visualize the data, you can import the following dashboards:

- [API server](https://grafana.com/grafana/dashboards/20331-kubernetes-api-server/)
- [etcd](https://grafana.com/grafana/dashboards/20330-kubernetes-etcd/)

## Customize control plane metrics

AKS includes a preconfigured set of metrics to collect and store for each component. Metrics for the API server and etcd are collected by default. You can customize the list of metrics that are collected by modifying the [`ama-metrics-settings-configmap.yaml`](https://github.com/Azure/prometheus-collector/blob/main/otelcollector/configmaps/ama-metrics-settings-configmap.yaml) configmap file.

Default targets include the following values:

```yaml
controlplane-metrics: |-
    default-targets-scrape-enabled: |-
      apiserver = true
      cluster-autoscaler = false
      node-auto-provisioning = false
      kube-scheduler = false
      kube-controller-manager = false
      etcd = true
```

All configmap files should be applied to the `kube-system` namespace for any cluster.

Note

Schema v2 change: The configuration for targets is now separately under cluster-metrics and controlplane-metrics allowing separate control of ingestion volume for cluster-level targets and control plane targets. If you are migrating from v1, replace the configurations to the corresponding sections within cluster-metrics and controlplane-metrics, also note the following:

- Modify the key name from 'default-scrape-settings-enabled' to 'default-targets-scrape-enabled'
- For targets within controlplane-metrics section, drop the "controlplane-" prefix
- Replace `minimalingestionprofile = true` in the keep list with the `minimal-ingestion-profile` section and set its nested `enabled` value to `true`.

### Customize an ingestion profile

You can customize an ingestion profile for collected metrics. For more information, see [Minimal ingestion profile for control plane metrics in managed service for Prometheus](/en-us/azure/azure-monitor/containers/prometheus-metrics-scrape-configuration-minimal#minimal-ingestion-for-default-on-targets).

#### Ingest only minimal metrics from default targets

Set `controlplane-metrics.minimal-ingestion-profile.enabled` to `true`, so it ingests only the minimal set of metrics for each of the default targets: `apiserver` and `etcd`.

#### Ingest all metrics from selected targets

1. Download the [`ama-metrics-settings-configmap.yaml`](https://github.com/Azure/prometheus-collector/blob/main/otelcollector/configmaps/ama-metrics-settings-configmap.yaml) configmap file.
2. Rename the configmap file `configmap-controlplane.yaml`.
3. Set `controlplane-metrics.minimal-ingestion-profile.enabled` to `false`.
4. Under `controlplane-metrics.default-targets-scrape-enabled`, verify that the targets you want to scrape are set to `true`.

    The targets you can set are:

    - `apiserver`
    - `cluster-autoscaler`
    - `node-auto-provisioning`
    - `kube-scheduler`
    - `kube-controller-manager`
    - `etcd`
5. Apply the configmap file by using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command:

    ```bash
    kubectl apply -f configmap-controlplane.yaml
    ```

After you apply the configuration, it takes several minutes for the metrics from the specified targets that are scraped from the control plane to appear in the Azure Monitor workspace.

#### Ingest more than minimal metrics

Using the `controlplane-metrics.minimal-ingestion-profile` setting helps reduce the ingestion volume of metrics. If set to `true`, only default recording rules, default alerts, and metrics that appear in the default dashboards are collected.

1. Download the [`ama-metrics-settings-configmap.yaml`](https://github.com/Azure/prometheus-collector/blob/main/otelcollector/configmaps/ama-metrics-settings-configmap.yaml) configmap file.
2. Rename the configmap file `configmap-controlplane.yaml`.
3. Set `controlplane-metrics.minimal-ingestion-profile.enabled` to `true`.
4. Under `controlplane-metrics.default-targets-scrape-enabled`, verify that the targets you want to scrape are set to `true`.

    The targets you can set are:

    - `apiserver`
    - `cluster-autoscaler`
    - `node-auto-provisioning`
    - `kube-scheduler`
    - `kube-controller-manager`
    - `etcd`
5. Under `controlplane-metrics.default-targets-metrics-keep-list`, specify the list of metrics for the `true` targets.

    For example:

    ```yaml
    apiserver= "apiserver_admission_webhook_admission_duration_seconds|apiserver_longrunning_requests"
    ```
6. Apply the configmap file by using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command:

    ```bash
    kubectl apply -f configmap-controlplane.yaml
    ```

After you apply the configuration, it takes several minutes for the metrics from the specified targets that are scraped from the control plane to appear in the Azure Monitor workspace.

#### Ingest specific metrics from specific targets

1. Download the [`ama-metrics-settings-configmap.yaml`](https://github.com/Azure/prometheus-collector/blob/main/otelcollector/configmaps/ama-metrics-settings-configmap.yaml) configmap file.
2. Rename the configmap file `configmap-controlplane.yaml`.
3. Set `controlplane-metrics.minimal-ingestion-profile.enabled` to `false`.
4. Under `controlplane-metrics.default-targets-scrape-enabled`, verify that the targets that you want to scrape are set to `true`.

    The targets you can set are:

    - `apiserver`
    - `cluster-autoscaler`
    - `node-auto-provisioning`
    - `kube-scheduler`
    - `kube-controller-manager`
    - `etcd`
5. Under `controlplane-metrics.default-targets-metrics-keep-list`, specify the list of metrics for the `true` targets.

    For example:

    ```yaml
    apiserver= "apiserver_admission_webhook_admission_duration_seconds|apiserver_longrunning_requests"
    ```
6. Apply the configmap file:

    ```bash
    kubectl apply -f configmap-controlplane.yaml
    ```

After you apply the configuration, it takes several minutes for the metrics from the specified targets that are scraped from the control plane to appear in the Azure Monitor workspace.

## Troubleshoot control plane metrics issues

Ensure that you enable the `--enable-control-plane-metrics` flag and that the `ama-metrics` pods are running.

Note

The [troubleshooting methods](/en-us/azure/azure-monitor/containers/prometheus-metrics-troubleshoot) for the managed service for Prometheus don't apply directly in this scenario. The components that scrape the control plane aren't included in the managed service for Prometheus add-on.

- **ConfigMap file formatting**: Ensure that you use the correct formatting in the ConfigMap file. Verify that the fields `controlplane-metrics.default-targets-metrics-keep-list`, `controlplane-metrics.minimal-ingestion-profile`, and `controlplane-metrics.default-targets-scrape-enabled` and other fields are correctly populated with their intended values.
- **Isolate the control plane from the data plane**: Start by setting some of the [node-related metrics](/en-us/azure/azure-monitor/containers/prometheus-metrics-scrape-default) to `true`, and then verify that the metrics are forwarded to the workspace. Completing these steps helps you determine whether an issue is specific to scraping control plane metrics.
- **A change in the number of events ingested**: After you apply the changes, open Metrics Explorer in the Azure portal. Go to the Azure Monitor overview pane for the cluster or go to the **Monitoring** section of the selected cluster. Check for an increase or a decrease in the number of events ingested per minute. This information can help you determine whether a specific metric is missing or if all metrics are missing.
- **A specific metric isn't exposed**: In some scenarios, a metric is documented, but it isn't exposed from the target and isn't forwarded to the Azure Monitor workspace. In this case, it's necessary to verify that other metrics are forwarded to the workspace.
- **Schema v2 change**: The configuration for targets in schema v2 of the ConfigMap is now separately under `cluster-metrics` and `controlplane-metrics` allowing separate control of ingestion volume for cluster-level targets and control plane targets. If you're migrating from v1, replace the configurations to the corresponding sections within `cluster-metrics` and `controlplane-metrics`. Also note that the key name from `default-scrape-settings-enabled` is changed to `default-targets-scrape-enabled`.

    Note

    If you want to collect the `apiserver_request_duration_seconds` metric or another bucket metric, you must set the entire series in the histogram family:

    ```yaml
    apiserver = "apiserver_request_duration_seconds_bucket|apiserver_request_duration_seconds_sum|apiserver_request_duration_seconds_count"
    ```
- **No access to the Azure Monitor workspace**: When you enable the add-on, you might specify an existing workspace that you can't access. In that scenario, it might appear that metrics aren't collected and forwarded. Verify that the cluster is linked to the intended workspace and that you have the Monitoring Reader or Monitoring Contributor role required to view its data.

## Disable control plane metrics on your AKS cluster

You can disable control plane metrics at any time by using the `--disable-control-plane-metrics` flag or by disabling the managed service for Prometheus add-on.

1. To disable scraping control plane metrics on the AKS cluster, use the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command:

    ```azurecli
    az aks update --disable-control-plane-metrics --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP
    ```
2. Alternatively, remove the metrics add-on that scrapes Prometheus metrics by using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command. Note that disabling Prometheus metrics disables metrics collection from other targets in your AKS cluster.

    ```azurecli
    az aks update --disable-azure-monitor-metrics --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP
    ```

## Frequently asked questions (FAQs)

### Can I scrape control plane metrics by using self-hosted Prometheus?

No. Currently, you can't scrape control plane metrics by using self-hosted Prometheus. Self-hosted Prometheus can scrape only a single instance, depending on the load balancer, so the metrics aren't reliable. Often, multiple replicas of the control plane metrics are visible only through the managed service for Prometheus.

### Why isn't the user agent available in the control plane metrics?

In AKS, [control plane metrics](https://kubernetes.io/docs/reference/instrumentation/metrics/) don't have the user agent. The user agent is available only through the control plane logs that you access in [diagnostic settings](/en-us/azure/azure-monitor/essentials/diagnostic-settings).