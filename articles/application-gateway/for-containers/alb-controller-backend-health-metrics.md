---
layout: Conceptual
title: ALB Controller - Backend Health and Metrics | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/alb-controller-backend-health-metrics
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
description: Identify and troubleshoot issues using ALB Controller's backend health & metrics endpoints for Application Gateway for Containers.
services: application-gateway
author: mbender-ms
ms.service: azure-application-gateway-containers
ms.topic: concept-article
ms.date: 2024-06-03T00:00:00.0000000Z
ms.author: mbender
locale: en-us
document_id: 46bb1612-f405-5d11-3ffa-05510de3d82a
document_version_independent_id: 472dc38b-7f5d-ec64-30b7-babcbcbb68ef
original_content_git_url: https://github.com/MicrosoftDocs/azure-docs-pr/blob/live/articles/application-gateway/for-containers/alb-controller-backend-health-metrics.md
site_name: Docs
depot_name: Azure.azure-documents
page_type: conceptual
toc_rel: toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/Azure.azure-documents/{branchName}{pdfName}
asset_id: application-gateway/for-containers/alb-controller-backend-health-metrics
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-gateway/for-containers/alb-controller-backend-health-metrics.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f98c9a19-e481-4f15-8047-76b641e6ed57
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f5685781-a4fd-40f1-8126-59abde4643bf
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
platformId: df1298f9-1088-98af-67f4-0ce93a35839d
---

# ALB Controller - Backend Health and Metrics | Microsoft Learn

Understanding backend health of your Kubernetes services and pods is crucial in identifying issues and assistance in troubleshooting. To help facilitate visibility into backend health, ALB Controller exposes backend health and metrics endpoints in all ALB Controller deployments.

ALB Controller's backend health exposes three different experiences:

1. Summarized backend health by Application Gateway for Containers resource
2. Summarized backend health by Kubernetes service
3. Detailed backend health for a specified Kubernetes service

ALB Controller's metric endpoint exposes both metrics and summary of backend health. This endpoint enables exposure to Prometheus.

Access to these endpoints can be reached via the following URLs:

- Backend Health - http://&lt;alb-controller-pod-ip&gt;:8000/backendHealth
    - Output is JSON format
- Metrics - http://&lt;alb-controller-pod-ip&gt;:8001/metrics
    - Output is text format

Any clients or pods that have connectivity to this pod and port may access these endpoints. To restrict access, we recommend using [Kubernetes network policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/) to restrict access to certain clients.

## Backend Health

### Discovering backend health

The ALB Controller exposes backend health on the ALB controller pod that is acting as primary.

To find the primary pod, run the following command:

```bash
CONTROLLER_NAMESPACE='azure-alb-system'
kubectl get lease -n $CONTROLLER_NAMESPACE alb-controller-leader-election -o jsonpath='{.spec.holderIdentity}' | awk -F'_' '{print $1}'
```

# [Access backend health via Kubectl command](#tab/backend-health-kubectl-access)
For indirect access via kubectl utility, you can create a listener that proxies traffic to the pod.

```bash
kubectl port-forward <pod-name> -n $CONTROLLER_NAMESPACE 8000 8001
```

Once the kubectl command is listening, open another terminal (or cloud shell session) and execute curl to 127.0.0.1 to be redirected to the pod.

```bash
curl http://127.0.0.1:8000
```

# [Access backend health via controller pod directly](#tab/backend-health-direct-access)
Run the following kubectl command to identify the IP address of the primary ALB Controller pod.

```bash
kubectl get pod <alb controller pod name from previous step> -n $CONTROLLER_NAMESPACE -o jsonpath="{.status.podIP}"
```

Once you have the IP address of your alb-controller pod, you may validate the backend health service is running by browsing to http://&lt;pod-ip&gt;:8000.

```bash
curl http://<your-pod-ip>:8000
```

---

Example response:

```text
Available paths:
Path: /backendHealth
Description: Prints the backend health of the ALB.
Query Parameters:
        detailed: if true, prints the detailed view of the backend health
        alb-id: Resource ID of the Application Gateway for Containers to filter backend health for.
        service-name: Service to filter backend health for. Expected format: \<namespace\>/\<service\>/\<service-port-number\>

Path: /
Description: Prints the help
```

### Summarized backend health by Application Gateway for Containers

This experience summarizes of all Kubernetes services with references to Application Gateway for Containers and their corresponding health status.

This experience may be accessed by specifying the Application Gateway for Containers resource ID in the query of the request to the alb-controller pod.

The following command can be used to probe backend health for the specified Application Gateway for Containers resource.

```bash
curl http://\<alb-controller-pod-ip-address\>:8000/backendHealth?alb-id=/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourcegroups/yyyyyyyy/providers/Microsoft.ServiceNetworking/trafficControllers/zzzzzzzzzz
```

Example output:

```json
{
  "services": [
    {
      "serviceName": "default/service-hello-world/80",
      "serviceHealth": [
        {
          "albId": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourcegroups/yyyyyyyy/providers/Microsoft.ServiceNetworking/trafficControllers/zzzzzzzzzz",
          "totalEndpoints": 1,
          "totalHealthyEndpoints": 1,
          "totalUnhealthyEndpoints": 0
        }
      ]
    },
    {
      "serviceName": "default/service-contoso/443",
      "serviceHealth": [
        {
          "albId": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourcegroups/yyyyyyyy/providers/Microsoft.ServiceNetworking/trafficControllers/zzzzzzzzzz",
          "totalEndpoints": 1,
          "totalHealthyEndpoints": 1,
          "totalUnhealthyEndpoints": 0
        }
      ]
    }
  ]
}
```

### Summarized backend health by Kubernetes service

This experience searches for the health summary status of a given service.

This experience may be accessed by specifying the name of the namespace, service, and port number of the service in the following format of the query string to the alb-controller pod: *&lt;namespace&gt;/&lt;service&gt;/&lt;service-port-number&gt;*

The following command can be used to probe backend health for the specified Kubernetes service.

```bash
curl http://\<alb-controller-pod-ip-address\>:8000/backendHealth?service-name=default/service-hello-world/80
```

Example output:

```json
{
  "services": [
    {
      "serviceName": "default/service-hello-world/80",
      "serviceHealth": [
        {
          "albId": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourcegroups/yyyyyyyy/providers/Microsoft.ServiceNetworking/trafficControllers/zzzzzzzzzz",
          "totalEndpoints": 1,
          "totalHealthyEndpoints": 1,
          "totalUnhealthyEndpoints": 0
        }
      ]
    }
  ]
}
```

### Detailed backend health for a specified Kubernetes service

This experience shows all endpoints that make up the service, including their corresponding health status and IP address. Endpoint status is reported as either *HEALTHY* or *UNHEALTHY*.

This experience may be accessed by specifying detailed=true in the query string to the alb-controller pod.

For example, we can verify individual endpoint health by executing the following command:

```bash
curl http://\<alb-controller-pod-ip-address\>:8000/backendHealth?service-name=default/service-hello-world/80\&detailed=true
```

Example output:

```json
{
  "services": [
    {
      "serviceName": "default/service-hello-world/80",
      "serviceHealth": [
        {
          "albId": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourcegroups/yyyyyyyy/providers/Microsoft.ServiceNetworking/trafficControllers/zzzzzzzzzz",
          "totalEndpoints": 1,
          "totalHealthyEndpoints": 1,
          "totalUnhealthyEndpoints": 0,
          "endpoints": [
            {
              "address": "10.1.1.22",
              "health": {
                "status": "HEALTHY"
              }
            }
          ]
        }
      ]
    }
  ]
}
```

## Metrics

ALB Controller currently surfaces metrics following [text based format](https://prometheus.io/docs/instrumenting/exposition_formats/#text-based-format) to be exposed to Prometheus. Access to these logs are available on port 8001 of the primary alb controller pod `http://\<alb-controller-pod-ip\>:8001/metrics`.

The following metrics are exposed today:

| Metric Name | Description |
| --- | --- |
| alb\_connection\_status | Connection status to an Application Gateway for Containers resource |
| alb\_reconnection\_count | Number of reconnection attempts to an Application Gateway for Containers resources |
| total\_config\_updates | Number of service routing config operations |
| total\_endpoint\_updates | Number of backend pool config operations |
| total\_deployments | Number of Application Gateway for Containers resource deployments |
| total\_endpoints | Number of endpoints in a service |
| total\_healthy\_endpoints | Number of healthy endpoints in a service |
| total\_unhealthy\_endpoints | Number of unhealthy endpoints in a service |