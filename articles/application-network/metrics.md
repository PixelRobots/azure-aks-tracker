---
layout: Conceptual
title: Configure and View Azure Kubernetes Application Network Metrics (Preview) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-network/metrics
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
description: Learn how to configure and view Azure Kubernetes Application Network metrics in Azure Monitor, including data plane metrics from your workloads and Azure Kubernetes Application Network components.
author: Kochhars
ms.author: kochhars
ms.service: azure-kubernetes-app-net
ms.topic: how-to
ms.date: 2025-11-04T00:00:00.0000000Z
locale: en-us
document_id: b4624c53-2736-2193-be94-ecb1b07e0566
document_version_independent_id: 39cd68d4-e57c-2816-94dc-396335f569eb
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/application-network/metrics.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: application-network/metrics
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-network/metrics.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
platformId: 0e3b6fdd-2830-0f15-6a16-015d395d3293
---

# Configure and View Azure Kubernetes Application Network Metrics (Preview) | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

Azure Kubernetes Application Network provides comprehensive metrics for your workloads and the Azure Kubernetes Application Network data plane components (ZTunnel, Istio CNI, and Waypoint) through Azure Monitor metrics. This article explains how to configure and view these metrics in Azure Monitor.

## Limitations

Control plane metrics aren't currently supported. However, data plane metrics are available, and you can use them to monitor the health and performance of your workloads and Azure Kubernetes Application Network components.

## Data plane metrics

Data plane metrics include metrics from your workloads/applications and the `appnet-system` namespace. Azure Kubernetes Application Network currently only provides support for **data plane metrics**.

## Configure data plane metrics

### Workspace configuration options for data plane metrics

When you enable Prometheus metrics collection for Azure Kubernetes Application Network member clusters, you have the following options for workspace configuration:

- Use an existing Azure Monitor workspace.
- Omit the workspace resource ID and use the default workspace created for your resource group.
- Create a new Azure Monitor workspace.

### Enable data plane metrics collection

# [Use an existing Azure Monitor workspace](#tab/use-existing-workspace)
1. Enable Prometheus metrics collection on your Azure Kubernetes Application Network member cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--azure-monitor-workspace-resource-id` parameter set to your existing workspace ID. If Azure Monitor Metrics is already enabled on your member cluster, you can skip to the next step.

    ```azurecli
    az aks update --enable-azure-monitor-metrics \
      --name $CLUSTER_NAME \
      --resource-group $AKS_RG \
      --azure-monitor-workspace-resource-id $WORKSPACE_ID
    ```
2. Create and apply the following ConfigMap in the `kube-system` namespace using the `kubectl apply` command. This ConfigMap enables scraping of Ztunnel, Istio CNI, waypoint, and your application/workloads.

    ```bash
    kubectl apply -f - <<EOF
    kind: ConfigMap
    apiVersion: v1
    metadata:
      name: ama-metrics-settings-configmap
      namespace: kube-system
    data:
      schema-version: v1
      config-version: ver1
      prometheus-collector-settings: |-
        cluster_alias = ""
        https_config = true
      default-scrape-settings-enabled: |-
        ztunnel = true
        istio-cni = true
      pod-annotation-based-scraping: |-
        podannotationnamespaceregex = ".*"
      default-targets-metrics-keep-list: |-
        ztunnel = ""
        istio-cni = ""
        minimalingestionprofile = true
      default-targets-scrape-interval-settings: |-
        ztunnel = "30s"
        istio-cni = "30s"
        podannotations = "30s"
      debug-mode: |-
        enabled = false
    EOF
    ```
3. Add annotations to the applications pods you want to scrape.

    - `prometheus.io/scrape: "true"` is required to indicate that the pod should be scraped.
    - `prometheus.io/path` is optionally used to indicate the path where metrics are hosted. If omitted, it defaults to `/metrics`.
    - `prometheus.io/port` is optionally used to indicate the port where metrics are hosted. If omitted, Prometheus will use the container's declared ports from the pod spec. For containers with no declared ports, Prometheus creates a port-free target (IP only), which requires proper relabeling configuration to work with port annotations. It is recommended to explicitly specify the port to ensure reliable scraping.

    The following sample defines annotations for a pod that is hosting metrics at `<pod IP>:15020/metrics`

    ```bash
    prometheus.io/scrape: "true"
    prometheus.io/port: "15020"
    prometheus.io/path: "/metrics"
    ```

    It might take a few minutes for the AMA metrics ReplicaSet to load this configuration.

# [Use the default workspace](#tab/use-default-workspace)
1. Enable Prometheus metrics collection on your Azure Kubernetes Application Network member cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command. If Azure Monitor Metrics is already enabled on your member cluster, you can skip to the next step.

    ```azurecli
    az aks update --enable-azure-monitor-metrics \
      --name $CLUSTER_NAME \
      --resource-group $AKS_RG \
    ```
2. Create and apply the following ConfigMap in the `kube-system` namespace using the `kubectl apply` command. This ConfigMap enables scraping of Ztunnel, Istio CNI, waypoint, and your application/workloads.

    ```bash
    kubectl apply -f - <<EOF
    kind: ConfigMap
    apiVersion: v1
    metadata:
      name: ama-metrics-settings-configmap
      namespace: kube-system
    data:
      schema-version: v1
      config-version: ver1
      prometheus-collector-settings: |-
        cluster_alias = ""
        https_config = true
      default-scrape-settings-enabled: |-
        ztunnel = true
        istio-cni = true
      pod-annotation-based-scraping: |-
        podannotationnamespaceregex = ".*"
      default-targets-metrics-keep-list: |-
        ztunnel = ""
        istio-cni = ""
        minimalingestionprofile = true
      default-targets-scrape-interval-settings: |-
        ztunnel = "30s"
        istio-cni = "30s"
        podannotations = "30s"
      debug-mode: |-
        enabled = false
    EOF
    ```
3. Add annotations to the applications pods you want to scrape.

    - `prometheus.io/scrape: "true"` is required to indicate that the pod should be scraped.
    - `prometheus.io/path` is optionally used to indicate the path where metrics are hosted. If omitted, it defaults to `/metrics`.
    - `prometheus.io/port` is optionally used to indicate the port where metrics are hosted. If omitted, Prometheus will use the container's declared ports from the pod spec. For containers with no declared ports, Prometheus creates a port-free target (IP only), which requires proper relabeling configuration to work with port annotations. It is recommended to explicitly specify the port to ensure reliable scraping.

    The following sample defines annotations for a pod that is hosting metrics at `<pod IP>:15020/metrics`

    ```bash
    prometheus.io/scrape: "true"
    prometheus.io/port: "15020"
    prometheus.io/path: "/metrics"
    ```

    It might take a few minutes for the AMA metrics ReplicaSet to load this configuration.

# [Create a new Azure Monitor workspace](#tab/create-new-workspace)
1. Create a new Azure Monitor workspace using the [`az monitor account create`](/en-us/cli/azure/monitor/account#az-monitor-account-create) command.

    ```azurecli
    az monitor account create --name $AMW_NAME --resource-group $AKS_RG --location $LOCATION
    ```
2. Enable Prometheus metrics collection on your Azure Kubernetes Application Network member cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--azure-monitor-workspace-resource-id` parameter set to your existing workspace ID.

    ```azurecli
    az aks update --enable-azure-monitor-metrics \
      --name $CLUSTER_NAME \
      --resource-group $AKS_RG \
      --azure-monitor-workspace-resource-id $WORKSPACE_ID
    ```
3. Create and apply the following ConfigMap in the `kube-system` namespace using the `kubectl apply` command. This ConfigMap enables scraping of Ztunnel, Istio CNI, waypoint, and your application/workloads.

    ```bash
    kubectl apply -f - <<EOF
    kind: ConfigMap
    apiVersion: v1
    metadata:
      name: ama-metrics-settings-configmap
      namespace: kube-system
    data:
      schema-version: v1
      config-version: ver1
      prometheus-collector-settings: |-
        cluster_alias = ""
        https_config = true
      default-scrape-settings-enabled: |-
        ztunnel = true
        istio-cni = true
      pod-annotation-based-scraping: |-
        podannotationnamespaceregex = ".*"
      default-targets-metrics-keep-list: |-
        ztunnel = ""
        istio-cni = ""
        minimalingestionprofile = true
      default-targets-scrape-interval-settings: |-
        ztunnel = "30s"
        istio-cni = "30s"
        podannotations = "30s"
      debug-mode: |-
        enabled = false
    EOF
    ```
4. Add annotations to the applications pods you want to scrape.

    - `prometheus.io/scrape: "true"` is required to indicate that the pod should be scraped.
    - `prometheus.io/path` is optionally used to indicate the path where metrics are hosted. If omitted, it defaults to `/metrics`.
    - `prometheus.io/port` is optionally used to indicate the port where metrics are hosted. If omitted, Prometheus will use the container's declared ports from the pod spec. For containers with no declared ports, Prometheus creates a port-free target (IP only), which requires proper relabeling configuration to work with port annotations. It is recommended to explicitly specify the port to ensure reliable scraping.

    The following sample defines annotations for a pod that is hosting metrics at `<pod IP>:15020/metrics`

    ```bash
    prometheus.io/scrape: "true"
    prometheus.io/port: "15020"
    prometheus.io/path: "/metrics"
    ```

    It might take a few minutes for the AMA metrics ReplicaSet to load this configuration.

---

## View data plane metrics

1. Navigate to your Azure Monitor workspace in the Azure portal to query the metrics using PromQL.
2. Generate some traffic, then select queries from the exposed metrics to view metrics. For example, you can run the following query to view the total number of requests handled by waypoint:

    ```promql
    # ztunnel
    istio_xds_connection_terminations_total
    
    # waypoint
    istio_requests_total
    
    # istio-cni
    istio_cni_install_ready
    ```

    The following screenshot shows results for the sample queries:

    [![Screenshot of the results of the queries to view the total number of requests handled by waypoint.](media/metrics/prometheus-query.png)](media/metrics/prometheus-query.png#lightbox)

### List of metrics exposed

| Component | Metrics exposed |
| --- | --- |
| **ZTunnel** | `istio_build``istio_xds_connection_terminations_total``istio_xds_message_total``istio_xds_message_bytes_total``istio_tcp_connections_opened_total``istio_tcp_connections_closed_total``istio_tcp_received_bytes_total``istio_tcp_sent_bytes_total``istio_on_demand_dns``istio_dns_requests_total``istio_dns_upstream_requests``istio_dns_upstream_failures``istio_dns_upstream_request_duration_seconds``workload_manager_active_proxy_count``workload_manager_pending_proxy_count``workload_manager_proxies_started_total``workload_manager_proxies_stopped_total` |
| **Istio CNI** | `istio_cni_install_ready``istio_cni_installs_total``nodeagent_reconcile_events_total``ztunnel_connected` |
| **Waypoint** | `istio_build``istio_request_bytes_bucket``istio_request_bytes_count``istio_request_bytes_sum``istio_request_duration_milliseconds_bucket``istio_request_duration_milliseconds_count``istio_request_duration_milliseconds_sum``istio_requests_total``istio_response_bytes_bucket``istio_response_bytes_count``istio_response_bytes_sum` |

### Access metrics directly from waypoint proxies

Aside from the Istio request/response metrics, waypoint proxies also emit Envoy metrics.

- To find a complete list of metrics emitted by waypoint, you can port-forward to a waypoint proxy in your namespace and list the metrics using following commands:

    ```bash
    # Port-forward to waypoint proxy
    kubectl port-forward -n <namespace> deployment/waypoint 15020:15020 &
    
    # List metrics exposed by waypoint
    curl http://localhost:15020/stats/prometheus | grep -v '^#' | grep -v '^$' | awk -F'{' '{print $1}' | sort -u
    ```

### Visualize metrics with Grafana in Azure portal

1. Import the [Istio community dashboards](https://grafana.com/orgs/istio/dashboards).
2. Generate traffic for your member cluster, and then navigate to your Azure Monitor workspace in the Azure portal.
3. Select **Monitoring** &gt; **Dashboards with Grafana**.

    The following screenshots show examples of importing the [Istio Ztunnel Dashboard](https://grafana.com/grafana/dashboards/21306-istio-ztunnel-dashboard/):

    [![Screenshot showing the import dashboard option in the Azure Monitor workspace in Azure portal.](media/metrics/import-dashboard.png)](media/metrics/import-dashboard.png#lightbox)

    [![Screenshot showing the review options for importing the Ztunnel dashboard in Azure portal.](media/metrics/ztunnel-import.png)](media/metrics/ztunnel-import.png#lightbox)

    [![Screenshot showing Ztunnel dashboard visualizations in a Grafana Dashboard in Azure portal.](media/metrics/visualize-ztunnel-dashboard.png)](media/metrics/visualize-ztunnel-dashboard.png#lightbox)

If you want to configure Azure Managed Grafana instead of Dashboards with Grafana, see [Create an Azure Managed Grafana workspace using the Azure CLI](/en-us/azure/managed-grafana/quickstart-managed-grafana-cli).