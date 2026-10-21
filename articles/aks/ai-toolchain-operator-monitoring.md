---
layout: Conceptual
title: Monitor Inference Metrics via the AI Toolchain Operator - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/ai-toolchain-operator-monitoring
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
description: Learn how to collect and visualize AI inference service metrics in Azure Kubernetes Service (AKS) by using the managed service for Prometheus and Azure Managed Grafana.
ms.author: schaffererin
author: schaffererin
ms.topic: how-to
ms.custom: aks-ai-ml
ms.date: 2026-09-12T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: 3c7d29d7-77c4-d1a4-6a83-5242ba40a6fa
document_version_independent_id: 13eb30a8-9304-0ad7-6e62-845f27a84d48
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/ai-toolchain-operator-monitoring.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/ai-toolchain-operator-monitoring
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/ai-toolchain-operator-monitoring.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/71313085-034b-42dc-8446-58627936c72c
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/32072957-9d5a-4e26-8db5-633ab8b422ea
platformId: f91ebb35-3143-5a29-4b3a-ec8cc160d2f7
---

# Monitor Inference Metrics via the AI Toolchain Operator - Azure Kubernetes Service | Microsoft Learn

Monitoring and observability play a key role in maintaining high performance and low cost of your AI workload deployments in Azure Kubernetes Service (AKS). Visibility into system and performance metrics can indicate the limits of your underlying infrastructure and motivate real-time adjustments and optimizations to reduce workload interruptions. Monitoring also provides valuable insights into resource utilization for cost-effective management of computational resources and accurate provisioning.

The Kubernetes AI Toolchain Operator (KAITO) is a managed add-on for AKS that simplifies deployment and operations for AI models in your AKS cluster.

The vLLM inference runtime is enabled by default in the AKS managed add-on. [vLLM](https://docs.vllm.ai/en/latest/) is a library for language model inference and serving. It surfaces key system performance, resource usage, and request processing for [Prometheus metrics](https://docs.vllm.ai/en/latest/design/v1/metrics.html) that you can use to evaluate your KAITO inference deployments.

In this article, you'll learn how to monitor and visualize vLLM inference metrics using the AI toolchain operator add-on with Azure Managed Prometheus and Azure Managed Grafana on your AKS cluster.

## Before you begin

- This article assumes that you have an existing AKS cluster. If you don't have a cluster, create one by using the [Azure CLI](learn/quick-kubernetes-deploy-cli), [Azure PowerShell](learn/quick-kubernetes-deploy-powershell), or the [Azure portal](learn/quick-kubernetes-deploy-portal).
- Install and configure Azure CLI version 2.47.0 or later. To find your version, run `az --version`. To install or update, see [Install the Azure CLI](/en-us/cli/azure/install-azure-cli).

## Prerequisites

- Install and configure kubectl, the Kubernetes command-line client. For more information, see [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
- Enable the [AI toolchain operator add-on](ai-toolchain-operator) in your AKS cluster.
- If you already have the AI toolchain operator add-on enabled, update your AKS cluster to the latest version.
- Enable [the managed service for Prometheus and Azure Managed Grafana](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable) in your AKS cluster.
- Have permissions to [create or update Azure Managed Grafana instances](/en-us/azure/managed-grafana/how-to-manage-access-permissions-users-identities) in your Azure subscription.

## Deploy a KAITO inference service

In this example, you collect metrics for the [Qwen-2.5-coder-7B-instruct language model](https://github.com/kaito-project/kaito/blob/main/examples/inference/kaito_workspace_qwen_2.5_coder_7b-instruct.yaml).

1. Start by applying the following KAITO workspace custom resource to your cluster:

    ```azurecli
    kubectl apply -f https://raw.githubusercontent.com/kaito-project/kaito/main/examples/inference/kaito_workspace_qwen_2.5_coder_7b-instruct.yaml
    ```
2. Track the live resource changes in your KAITO workspace:

    ```azurecli
    kubectl get workspace workspace-qwen-2-5-coder-7b-instruct -w
    ```

    Note

    Machine readiness can take up to 10 minutes, and workspace readiness can take up to 20 minutes depending on the size of your language model.
3. Confirm that your inference service is running and get the service IP address:

    ```azurecli
    export SERVICE_IP=$(kubectl get svc workspace-qwen-2-5-coder-7b-instruct -o jsonpath='{.spec.clusterIP}')
    
    echo $SERVICE_IP
    ```

## Surface KAITO inference metrics to the managed service for Prometheus

Prometheus metrics are collected by default at the KAITO [`/metrics` endpoint](https://github.com/kaito-project/kaito/tree/main).

1. Add the following label to your KAITO inference service so that a Kubernetes `ServiceMonitor` deployment can detect it:

    ```azurecli
    kubectl label svc workspace-qwen-2-5-coder-7b-instruct App=qwen-2-5-coder
    ```
2. Create a `ServiceMonitor` resource to define the inference service endpoints and the required configurations to scrape the vLLM Prometheus metrics. Export these metrics to the managed service for Prometheus by deploying the following `ServiceMonitor` YAML manifest in the `kube-system` namespace:

    ```azurecli
    cat <<EOF | kubectl apply -n kube-system -f -
    apiVersion: azmonitoring.coreos.com/v1
    kind: ServiceMonitor
    metadata:
      name: prometheus-kaito-monitor
    spec:
      selector:
        matchLabels:
          App: qwen-2-5-coder
      endpoints:
      - port: http
        interval: 30s
        path: /metrics
        scheme: http
    EOF
    ```

    Check for the following output to verify that `ServiceMonitor` is created:

    ```output
    servicemonitor.azmonitoring.coreos.com/prometheus-kaito-monitor created
    ```
3. Verify that your `ServiceMonitor` deployment is running successfully:

    ```azurecli
    kubectl get servicemonitor prometheus-kaito-monitor -n kube-system
    ```
4. In the Azure portal, verify that vLLM metrics are successfully collected in the managed service for Prometheus.

    1. In your Azure Monitor workspace, go to **Managed Prometheus** &gt; **Prometheus explorer**.
    2. Select the **Grid** tab and confirm that a metrics item is associated with the job named `workspace-qwen-2-5-coder-7b-instruct`.

        Note

        The `up` value of this item should be `1`. A value of `1` indicates that Prometheus metrics are successfully being scraped from your AI inference service endpoint.

## Visualize KAITO inference metrics in Azure Managed Grafana

1. The vLLM project provides a Grafana dashboard configuration named [grafana.json](https://docs.vllm.ai/en/stable/examples/observability/prometheus_grafana/#example-materials) for inference workload monitoring. Navigate to the bottom of this [page](https://docs.vllm.ai/en/stable/examples/observability/prometheus_grafana/#example-materials) and copy the entire contents of the `grafana.json` file.
2. Go to the bottom of the [examples page](https://docs.vllm.ai/en/stable/examples/observability/prometheus_grafana/#example-materials) and copy the entire contents of the `grafana.json` file:

    [![Screenshot of vLLM Grafana dashboard configuration.](media/ai-toolchain-operator/vllm-grafana-config.png)](media/ai-toolchain-operator/vllm-grafana-config.png#lightbox)
3. Complete the steps to [import the Grafana configurations into a new dashboard](/en-us/azure/managed-grafana/how-to-create-dashboard#import-a-json-dashboard) in Azure Managed Grafana.
4. Go to your Managed Grafana endpoint, view the available dashboards, and select the **vLLM** dashboard.

    [![Screenshot of available dashboards in Azure Managed Grafana.](media/ai-toolchain-operator/available-grafana-dashboards.png)](media/ai-toolchain-operator/available-grafana-dashboards.png#lightbox)
5. To begin collecting data for your selected model deployment, confirm that the **datasource** value shown at the top left of the Grafana dashboard is your instance of the managed service for Prometheus you created for this example.
6. Copy the inference preset name defined in your KAITO workspace to the **model\_name** field in the Grafana dashboard. In this example, the model name is [qwen2.5-coder-7b-instruct](https://github.com/kaito-project/kaito/blob/main/examples/inference/kaito_workspace_qwen_2.5_coder_7b-instruct.yaml).
7. In a few moments, verify that the metrics for your KAITO inference service appear in the vLLM Grafana dashboard.

    [![Screenshot of a vLLM Grafana dashboard and an example inference service deployment.](media/ai-toolchain-operator/example-grafana-dashboard.png)](media/ai-toolchain-operator/example-grafana-dashboard.png#lightbox)

    Note

    The value of these inference metrics remains **0** until the requests are submitted to the model inference server.