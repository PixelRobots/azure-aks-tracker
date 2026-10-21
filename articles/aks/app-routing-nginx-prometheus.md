---
layout: Conceptual
title: Monitor the ingress-nginx controller metrics in the application routing add-on with Prometheus - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/app-routing-nginx-prometheus
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
description: Configure Prometheus to scrape the ingress-nginx controller metrics.
ms.subservice: aks-networking
author: sabbour
ms.topic: how-to
ms.date: 2025-09-15T00:00:00.0000000Z
ms.author: asabbour
ai-usage: ai-assisted
locale: en-us
document_id: c64a35af-dadb-e9f4-cd7a-e6d31c26a480
document_version_independent_id: a47d9a43-6b70-5b46-4a43-cd0c5364e451
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/app-routing-nginx-prometheus.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/app-routing-nginx-prometheus
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/app-routing-nginx-prometheus.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 1f6fc745-3d8e-c317-e606-18e6fdda03b1
---

# Monitor the ingress-nginx controller metrics in the application routing add-on with Prometheus - Azure Kubernetes Service | Microsoft Learn

Caution

The [Kubernetes SIG Network](https://github.com/kubernetes/community/blob/master/sig-network/README.md) and the Security Response Committee [announced the retirement](https://www.kubernetes.dev/blog/2025/11/12/ingress-nginx-retirement/) of the [Ingress NGINX project](https://github.com/kubernetes/ingress-nginx/), with maintenance that ended in March 2026. Microsoft will provide official support for critical security patches for application routing add-on NGINX Ingress resources through **November 2026**.

AKS aligns with upstream Kubernetes and uses **[Gateway API](https://gateway-api.sigs.k8s.io) as the long-term standard for ingress and L7 traffic management**. Migrate before support ends in November 2026, based on your requirements:

- **Application routing add-on users** and **OSS NGINX users**: Migrate to the [application routing Gateway API implementation](/en-us/azure/aks/app-routing-gateway-api) for a Gateway API-based ingress traffic management experience, or to [Application Gateway for Containers](/en-us/azure/application-gateway/for-containers/overview), which supports both Ingress API and Gateway API.
- **Service mesh or advanced ingress requirements**: Consider [Gateway API ingress with the Istio service mesh add-on](/en-us/azure/aks/istio-gateway-api). You can use it for ingress without injecting sidecars into your workloads. If you need request header and body size limits, Lua scripts, or rate limiting, review the [Gateway API limitations and alternatives](/en-us/azure/aks/app-routing-gateway-api#limitations).

The ingress-nginx controller in the application routing add-on exposes many metrics for requests, the nginx process, and the controller that can be helpful in analyzing the performance and usage of your application.

The application routing add-on exposes the Prometheus metrics endpoint at `/metrics` on port 10254 and a private Service `nginx-metrics`.

## Prerequisites

- An Azure Kubernetes Service (AKS) cluster with the [application routing add-on enabled](/en-us/azure/aks/app-routing).
- A Prometheus instance, such as Azure Monitor managed service for Prometheus.

## Validating the metrics endpoint

To validate the metrics are being collected, you can set up a port forward from a local port to port 10254 on the `nginx-metrics` service.

```bash
kubectl port-forward -n app-routing-system service/nginx-metrics :10254
```

```bash
Forwarding from 127.0.0.1:43307 -> 10254
Forwarding from [::1]:43307 -> 10254
```

Note the local port (`43307` in this case) and open http://localhost:43307/metrics in your browser. You should see the ingress-nginx controller metrics loading.

![Screenshot of the Prometheus metrics in the browser.](media/app-routing/prometheus-metrics.png)

You can now terminate the `port-forward` process to close the forwarding.

## Configuring Azure Monitor managed service for Prometheus

Azure Monitor managed service for Prometheus is a fully managed Prometheus-compatible service that supports industry standard features such as PromQL, Grafana dashboards, and Prometheus alerts. This service requires configuring the metrics add-on for the Azure Monitor agent, which sends data to Prometheus. If your cluster isn't configured with the add-on, you can follow this article to configure your Azure Kubernetes Service (AKS) cluster to send data to Azure Monitor managed service for Prometheus.

### Enable Service Monitor based scraping

Once your cluster is updated with the Azure Monitor agent, you need to configure the agent to enable scraping the metrics endpoint. You can [create a Pod or a Service Monitor](/en-us/azure/azure-monitor/containers/prometheus-metrics-scrape-crd) to accomplish this.

The following creates a Service Monitor scrape metrics from the ingress-nginx controller deployed by the application routing add-on.

```bash
kubectl apply -f - <<EOF
apiVersion: azmonitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: nginx-monitor
  namespace: app-routing-system
spec:
  labelLimit: 63
  labelNameLengthLimit: 511
  labelValueLengthLimit: 1023
  selector:
    matchLabels:
      app.kubernetes.io/component: ingress-controller
      app.kubernetes.io/managed-by: aks-app-routing-operator
      app.kubernetes.io/name: nginx
  endpoints:
  - port: prometheus
EOF
```

In a few minutes, the `ama-metrics` pods in the `kube-system` namespace should restart and pick up the new configuration.

## Review visualization of metrics in Azure Managed Grafana

Now that you have Azure Monitor managed service for Prometheus and Azure Managed Grafana configured, you should [access your Managed Grafana instance](/en-us/azure/managed-grafana/quickstart-managed-grafana-portal#access-your-managed-grafana-instance).

There are two [official ingress-nginx dashboards](https://github.com/kubernetes/ingress-nginx/tree/main/deploy/grafana/dashboards) dashboards that you can download and import into your Grafana instance:

- Ingress-nginx controller dashboard
- Request handling performance dashboard

### Ingress-nginx controller dashboard

This dashboard gives you visibility of request volume, connections, success rates, config reloads and configs out of sync. You can also use it to view the network IO pressure, memory and CPU use of the ingress controller. Finally, it also shows the P50, P95, and P99 percentile response times of your ingresses and their throughput.

You can download this dashboard from [GitHub](https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/grafana/dashboards/nginx.json).

![Screenshot of a browser showing the ingress-nginx dashboard on Grafana.](media/app-routing/grafana-dashboard.png)

### Request handling performance dashboard

This dashboard gives you visibility into the request handling performance of the different ingress upstream destinations, which are your applications' endpoints that the ingress controller is forwarding traffic to. It shows the P50, P95 and P99 percentile of total request and upstream response times. You can also view aggregates of request errors and latency. Use this dashboard to review and improve the performance and scalability of your applications.

You can download this dashboard from [GitHub](https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/grafana/dashboards/request-handling-performance.json).

![Screenshot of a browser showing the ingress-nginx request handling performance dashboard on Grafana.](media/app-routing/grafana-dashboard-2.png)

### Importing a dashboard

To import a Grafana dashboard, expand the left menu and click on **Import** under Dashboards.

![Screenshot of a browser showing the Grafana instance with Import dashboard highlighted.](media/app-routing/grafana-import.png)

Then upload the desired dashboard file and click on **Load**.

![Screenshot of a browser showing the Grafana instance import dashboard dialog.](media/app-routing/grafana-import-json.png)