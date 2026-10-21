---
layout: Conceptual
title: Deploy Workflows with the Dapr Extension for AKS - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/dapr-workflow
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
description: Learn how to deploy and run Dapr Workflow on your Azure Kubernetes Service (AKS) clusters via the Dapr extension.
author: shivamkm07
ms.author: shivamkumar
ms.reviewer: ramithar
ms.topic: how-to
ms.date: 2026-02-06T00:00:00.0000000Z
ms.subservice: dapr-aks
ms.custom: devx-track-azurecli
locale: en-us
document_id: 3698df4c-0295-b558-d949-4b2829fc322b
document_version_independent_id: 7ae6b0da-55ab-8670-50b9-8fe93fe84396
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/dapr-workflow.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/dapr-workflow
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/dapr-workflow.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: e8cc521c-ebb2-9f8a-b977-f5f2a3ed88d3
---

# Deploy Workflows with the Dapr Extension for AKS - Azure Kubernetes Service | Microsoft Learn

With Dapr Workflow, you can easily orchestrate messaging, state management, and failure-handling logic across various microservices. Dapr Workflow can help you create long-running, fault-tolerant, and stateful applications.

In this guide, you use the [provided order processing workflow example](https://github.com/Azure-Samples/dapr-workflows-aks-sample) to:

- Create an Azure Container Registry and an AKS cluster for this sample.
- Install the Dapr extension on your AKS cluster.
- Deploy the sample application to AKS.
- Start and query workflow instances using HTTP API calls.

The workflow example is an ASP.NET Core project with:

- A [`Program.cs` file](https://github.com/Azure-Samples/dapr-workflows-aks-sample/blob/main/Program.cs) that contains the setup of the app, including the registration of the workflow and workflow activities.
- Workflow definitions found in the [`Workflows` directory](https://github.com/Azure-Samples/dapr-workflows-aks-sample/blob/main/Workflows/OrderProcessingWorkflow.cs).
- Workflow activity definitions found in the [`Activities` directory](https://github.com/Azure-Samples/dapr-workflows-aks-sample/tree/main/Activities).

## Prerequisites

- An [Azure subscription](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) with Owner or Admin role
- [An Azure Kubernetes Service Role-Based Access Control Admin role](/en-us/azure/role-based-access-control/built-in-roles#azure-kubernetes-service-rbac-admin)
- The latest version of the [Azure CLI](/en-us/cli/azure/install-azure-cli)
- The latest version of [Dapr](https://docs.dapr.io/getting-started/install-dapr-cli/)
- Latest [Docker](https://docs.docker.com/get-docker/)
- Latest [Helm](https://helm.sh/docs/intro/install/)

## Set up the environment

### Clone the sample project

Clone the example workflow application.

```bash
git clone https://github.com/Azure-Samples/dapr-workflows-aks-sample.git
```

Navigate to the sample's root directory.

```bash
cd dapr-workflows-aks-sample
```

### Create a Kubernetes cluster

Create a resource group to hold the AKS cluster.

```bash
az group create --name <your-resource-group> --location eastus
```

Create an AKS cluster.

```bash
az aks create --resource-group <your-resource-group> --name <your-AKS-cluster> --node-count 2 --generate-ssh-keys 
```

[Make sure `kubectl` is installed and pointed to your AKS cluster.](tutorial-kubernetes-deploy-cluster#connect-to-cluster-using-kubectl) If you use the Azure Cloud Shell, `kubectl` is already installed.

For more information, see the [Deploy an AKS cluster](tutorial-kubernetes-deploy-cluster) tutorial.

## Deploy the application to AKS

### Install Dapr on your AKS cluster

Install the Dapr extension on your AKS cluster. Before you start, make sure you:

- [Install or update the `k8s-extension`](dapr#add-the-azure-cli-extension-for-cluster-extensions)
- [Register the `Microsoft.KubernetesConfiguration` service provider](dapr#register-the-kubernetesconfiguration-resource-provider)

```bash
az k8s-extension create --cluster-type managedClusters --cluster-name myAKSCluster --resource-group <your-resource-group> --name dapr --extension-type Microsoft.Dapr
```

After a few minutes, the output shows the Dapr connection to your AKS cluster. Next, initialize Dapr on your cluster.

```bash
dapr init -k
```

Verify that Dapr is installed:

```bash
kubectl get pods -A
```

### Deploy the Redis actor state store component

Navigate to the `Deploy` directory in your forked version of the sample:

```bash
cd Deploy
```

Deploy the Redis component:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install redis bitnami/redis
kubectl apply -f redis.yaml
```

### Run the application

Once Redis is deployed, deploy the application to AKS:

```bash
kubectl apply -f deployment.yaml
```

Expose the Dapr sidecar and the sample app:

```bash
kubectl apply -f service.yaml
export APP_URL=$(kubectl get svc/workflows-sample -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export DAPR_URL=$(kubectl get svc/workflows-sample-dapr -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

Verify that the above commands were exported:

```bash
echo $APP_URL
echo $DAPR_URL
```

## Start the workflow

Now that the application and Dapr are deployed to the AKS cluster, you can now start and query workflow instances. Restock items in the inventory using the following API call to the sample app:

```bash
curl -X GET $APP_URL/stock/restock
```

Start the workflow:

```bash
curl -i -X POST $DAPR_URL/v1.0/workflows/dapr/OrderProcessingWorkflow/start \
  -H "Content-Type: application/json" \
  -H "dapr-app-id: dwf-app" \
  -d '{"Name": "Paperclips", "TotalCost": 99.95, "Quantity": 1}'
```

Expected output includes an auto-generated instance ID:

```
HTTP/1.1 202 Accepted
Content-Type: application/json
Traceparent: 00-00000000000000000000000000000000-0000000000000000-00
Date: Tue, 23 Apr 2024 15:35:00 GMT
Content-Length: 21

 {"instanceID":"<generated-id>"}
```

Check the workflow status:

```bash
curl -i -X GET $DAPR_URL/v1.0/workflows/dapr/OrderProcessingWorkflow/<instance-id> \
  -H "dapr-app-id: dwf-app"
```

Expected output:

```json
HTTP/1.1 200 OK
Content-Type: application/json
Traceparent: 00-00000000000000000000000000000000-0000000000000000-00
Date: Tue, 23 Apr 2024 15:51:02 GMT
Content-Length: 580
```

Monitor the application logs:

```bash
kubectl logs -l run=workflows-sample -c workflows-sample --tail=20
```

Expected output:

```
{
  "instanceID":"1234",
  "workflowName":"OrderProcessingWorkflow",
  "createdAt":"2024-04-23T15:35:00.156714334Z",
  "lastUpdatedAt":"2024-04-23T15:35:00.176459055Z",
  "runtimeStatus":"COMPLETED",
  "dapr.workflow.input":"{ \"input\" : {\"Name\": \"Paperclips\", \"TotalCost\": 99.95, \"Quantity\": 1}}",
  "dapr.workflow.output":"{\"Processed\":true}"
}
```

Notice that the workflow status is marked as completed.