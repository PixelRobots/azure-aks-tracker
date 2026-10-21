---
layout: Conceptual
title: Collect metrics for Istio service mesh add-on workloads for Azure Kubernetes Service in Azure Managed Prometheus - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/istio-metrics-managed-prometheus
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
description: Collect metrics for Istio service mesh add-on workloads for Azure Kubernetes Service in Azure Managed Prometheus
ms.topic: how-to
ms.custom: devx-track-azurecli
author: deveshdama
ms.date: 2025-02-12T00:00:00.0000000Z
ms.author: ddama
ai-usage: ai-assisted
locale: en-us
document_id: 9d93f3cd-a549-747d-11d3-8bc3b0de85be
document_version_independent_id: eb9ad037-bea3-ee1a-6537-af73bccc3f25
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/istio-metrics-managed-prometheus.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/istio-metrics-managed-prometheus
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/istio-metrics-managed-prometheus.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 2c9abc93-9664-df7e-4c04-2bd102cb2afd
---

# Collect metrics for Istio service mesh add-on workloads for Azure Kubernetes Service in Azure Managed Prometheus - Azure Kubernetes Service | Microsoft Learn

This guide explains how to set up and use Azure Managed Prometheus to collect metrics from Istio service mesh add-on workloads on your Azure Kubernetes cluster.

## Prerequisites

- Complete steps to enable the Istio add-on on the cluster as per [documentation](istio-deploy-addon)

    - [Set environment variables](istio-deploy-addon#set-environment-variables)
    - [Install Istio add-on](istio-deploy-addon#install-istio-add-on)
    - [Enable sidecar injection](istio-deploy-addon#enable-sidecar-injection)
    - [Deploy sample application](istio-deploy-addon#deploy-sample-application)
- [Deploy an external Istio ingress gateway](istio-deploy-ingress)

## Enable Azure Monitor managed service for Prometheus

Azure Monitor managed service for Prometheus collects data from Azure Kubernetes cluster. To enable Azure Monitor managed service for Prometheus, you must create an [Azure Monitor workspace](/en-us/azure/azure-monitor/essentials/azure-monitor-workspace-manage?tabs=cli#create-an-azure-monitor-workspace) to store the metrics:

```azurecli
export AZURE_MONITOR_WORKSPACE=<azure-monitor-workspace-name>

export AZURE_MONITOR_WORKSPACE_ID=$(az monitor account create \
    --name $AZURE_MONITOR_WORKSPACE \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --query id -o tsv)
```

### Enable Prometheus add-on

To collect Prometheus metrics from your Kubernetes cluster, [enable Prometheus add-on](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable?tabs=cli#enable-with-cli):

```azurecli
az aks update --enable-azure-monitor-metrics --name $CLUSTER --resource-group $RESOURCE_GROUP --azure-monitor-workspace-resource-id $AZURE_MONITOR_WORKSPACE_ID
```

### Customize scraping of Prometheus metrics in Azure Monitor managed service

Create a scrape config in a file named `prometheus-config`, similar to the sample provided below. This configuration enables pod annotation-based scraping, which allows Prometheus to automatically discover and scrape metrics from pods with specific annotations.

Important

The scrape config below is just an example. We **highly** recommend customizing it based on your needs. If not adjusted, it could lead to unexpected costs from frequent metric collection and increased data storage.

```bash
global: 
  scrape_interval: 30s
scrape_configs: 
- job_name: workload
  scheme: http
  kubernetes_sd_configs:
    - role: endpoints
  relabel_configs:
    - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
      action: keep
      regex: true
    - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
      action: replace
      target_label: __metrics_path__
      regex: (.+)
    - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
      action: replace
      regex: ([^:]+)(?::\d+)?;(\d+)
      replacement: $1:$2
      target_label: __address__ 
```

To [enable pod annotation-based scraping](/en-us/azure/azure-monitor/containers/prometheus-metrics-scrape-configuration), create configmap `ama-metrics-prometheus-config` that references `prometheus-config` file in `kube-system` namespace.

```bash
kubectl create configmap ama-metrics-prometheus-config --from-file=prometheus-config -n kube-system
```

### Verify Metric Collection

1. Configure access permissions: navigate to your Azure Monitor workspace in Azure portal and create role assignment for yourself to grant 'Monitoring Data Reader' role on the workspace resource.
2. Generate sample traffic: send a few requests to the product page created earlier, for example:

    ```bash
    curl -s "http://${GATEWAY_URL_EXTERNAL}/productpage" | grep -o "<title>.*</title>"
    ```
3. View/Query metrics in Azure portal: navigate to Prometheus explorer under your Azure Monitor workspace and [query metrics](/en-us/azure/azure-monitor/essentials/prometheus-workbooks). The example below shows results for query `istio_requests_total`.

    [![Diagram that shows sample query execution on prometheus explorer.](media/aks-istio-addon/managed-prometheus-integration/prometheus-explorer.jpg)](media/aks-istio-addon/managed-prometheus-integration/prometheus-explorer.jpg#lightbox)

## Delete resources

If you want to clean up the Istio service mesh and the ingresses (leaving behind the cluster), run the following command:

```azurecli
az aks mesh disable --resource-group ${RESOURCE_GROUP} --name ${CLUSTER}
```

If you want to clean up all the resources created from the Istio how-to guidance documents, run the following command:

```azurecli
az group delete --name ${RESOURCE_GROUP} --yes --no-wait
```