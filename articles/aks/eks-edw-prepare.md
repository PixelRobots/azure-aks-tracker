---
layout: Conceptual
title: Prepare to deploy the event-driven workflow (EDW) workload to Azure - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/eks-edw-prepare
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
description: Take the necessary steps so you can deploy the EDW workload in Azure.
ms.topic: how-to
ms.date: 2024-06-20T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: aks-migration
locale: en-us
document_id: e40abae8-cf7b-813b-2afb-064024abe9f4
document_version_independent_id: fd9f3cb3-7da2-9a9d-2ae5-7f591c7fd005
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/eks-edw-prepare.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/eks-edw-prepare
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/eks-edw-prepare.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 81df39ed-3aec-7dc6-99a8-fa0579f00f63
---

# Prepare to deploy the event-driven workflow (EDW) workload to Azure - Azure Kubernetes Service | Microsoft Learn

The AWS workload sample is deployed using Bash, CloudFormation, and AWS CLI. The consumer Python app is deployed as a container. The following sections describe how the Azure workflow is different. There are changes in the Bash scripts used to deploy the Azure Kubernetes Service (AKS) cluster and supporting infrastructure. Additionally, the Kubernetes deployment manifests are modified to configure KEDA to use an Azure Storage Queue scaler in place of the Amazon Simple Queue Service (SQS) scaler.

The Azure workflow uses the [AKS Node Autoprovisioning (NAP)](/en-us/azure/aks/node-autoprovision) feature, which is based on Karpenter. This feature greatly simplifies the deployment and usage of Karpenter on AKS by eliminating the need to use Helm to deploy Karpenter explicitly. However, if you have a need to deploy Karpenter directly, you can do so using the AKS [Karpenter provider on GitHub](https://github.com/Azure/karpenter-provider-azure).

## Configure Kubernetes deployment manifest

AWS uses a Kubernetes deployment YAML manifest to deploy the workload to EKS. The AWS deployment YAML has references to SQS and DynamoDB for KEDA scalers, so we need to change them to specify KEDA-equivalent values for the Azure scalers to use to connect to the Azure infrastructure. To do so, configure the [Azure Storage Queue KEDA scaler](https://keda.sh/docs/1.4/scalers/azure-storage-queue/).

The following code snippets show example YAML manifests for the AWS and Azure implementations.

### AWS implementation

```yaml
    spec:
      serviceAccountName: $SERVICE_ACCOUNT
      containers:
      - name: <sqs app name>
        image: <name of Python app container>
        imagePullPolicy: Always
        env:
        - name: SQS_QUEUE_URL
          value: https://<Url To SQS>/<region>/<QueueName>.fifo
        - name: DYNAMODB_TABLE
          value: <table name>
        - name: AWS_REGION
          value: <region>
```

### Azure implementation

```yaml
    spec:
      serviceAccountName: $SERVICE_ACCOUNT
      containers:
      - name: keda-queue-reader
        image: ${AZURE_CONTAINER_REGISTRY_NAME}.azurecr.io/aws2azure/aqs-consumer
        imagePullPolicy: Always
        env:
        - name: AZURE_QUEUE_NAME
          value: $AZURE_QUEUE_NAME
        - name: AZURE_STORAGE_ACCOUNT_NAME
          value: $AZURE_STORAGE_ACCOUNT_NAME
        - name: AZURE_TABLE_NAME
          value: $AZURE_TABLE_NAME
```

## Set environment variables

Before executing any of the deployment steps, you need to set some configuration information using the following environment variables:

- `K8sversion`: The version of Kubernetes deployed on the AKS cluster.
- `KARPENTER_VERSION`: The version of Karpenter deployed on the AKS cluster.
- `SERVICE_ACCOUNT`: The name of the service account associated with the managed identity.
- `AQS_TARGET_DEPLOYMENT`: The name of the consumer app container deployment.
- `AQS_TARGET_NAMESPACE`: The namespace into which the consumer app is deployed.
- `AZURE_QUEUE_NAME`: The name of the Azure Storage Queue.
- `AZURE_TABLE_NAME`: The name of the Azure Storage Table that stores the processed messages.
- `LOCAL_NAME`: A simple root for resource names constructed in the deployment scripts.
- `LOCATION`: The Azure region where the deployment is located.
- `TAGS`: Any user-defined tags along with their associated values.
- `STORAGE_ACCOUNT_SKU`: The Azure Storage Account SKU.
- `ACR_SKU`: The Azure Container Registry SKU.
- `AKS_NODE_COUNT`: The number of nodes.

You can review the `environmentVariables.sh` Bash script in the `deployment` directory of our [GitHub repository](https://github.com/Azure-Samples/aks-event-driven-replicate-from-aws). These environment variables have defaults set, so you don't need to update the file unless you want to change the defaults. The names of the Azure resources are created dynamically in the `deploy.sh` script and are saved in the `deploy.state` file. You can use the `deploy.state` file to create environment variables for Azure resource names.