---
layout: Conceptual
title: Deploy an App with Dapr Extension for Kubernetes - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/quickstart-dapr
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
description: Use the Dapr extension for Azure Kubernetes Service (AKS) or Arc-enabled Kubernetes to deploy an application.
author: shivamkm07
ms.author: shivamkumar
ms.reviewer: ramithar
ms.topic: quickstart
ms.subservice: dapr-aks
ms.date: 2026-02-11T00:00:00.0000000Z
ms.custom: template-quickstart, mode-other, devx-track-js, devx-track-python
ai-usage: ai-assisted
locale: en-us
document_id: 768b416a-6030-fb1f-06f6-d1d04bfb8fd5
document_version_independent_id: 6bbb9ef5-1980-06d5-0ae2-fdba2a504179
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/quickstart-dapr.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/quickstart-dapr
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/quickstart-dapr.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/e0e8de8a-7a16-43ad-90a9-6219f887a19e
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/584eb07b-29bd-4435-a43b-9be8d30d4d79
platformId: e5bed9f1-ac82-b5c2-a94f-e0bbcf03f456
---

# Deploy an App with Dapr Extension for Kubernetes - Azure Kubernetes Service | Microsoft Learn

In this quickstart, you use the [Dapr extension](dapr-overview) in an AKS or Arc-enabled Kubernetes cluster. You deploy [a `hello world` example](https://github.com/Azure-Samples/dapr-aks-extension-quickstart), which consists of a Python application that generates messages and a Node.js application that consumes and persists the messages.

## Prerequisites

- An Azure subscription. If you don't have one, you can [create a free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- [Azure CLI](/en-us/cli/azure/install-azure-cli) installed
- An AKS cluster with:
    - [Workload identity](workload-identity-deploy-cluster#enable-oidc-issuer-and-microsoft-entra-workload-id-on-an-aks-cluster) enabled
    - [Managed identity](workload-identity-deploy-cluster#create-a-managed-identity) created in the same subscription
    - [A Kubernetes service account](workload-identity-deploy-cluster#create-a-kubernetes-service-account)
    - [Federated identity credential](workload-identity-deploy-cluster#create-the-federated-identity-credential)
    - [Dapr extension](dapr-overview) installed on the AKS cluster
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed locally

## Clone the repository

1. Clone the [Dapr quickstart repository](https://github.com/Azure-Samples/dapr-aks-extension-quickstart) using the `git clone` command.

    ```bash
    git clone https://github.com/Azure-Samples/dapr-aks-extension-quickstart.git
    ```
2. Change to the `dapr-aks-extension-quickstart` directory.

    ```bash
    cd dapr-aks-extension-quickstart
    ```

## Create and configure a Redis store

Open the [Azure portal](https://portal.azure.com/#create/Microsoft.Cache/redisEnterprise) to start the Azure Managed Redis creation flow.

1. Fill out the recommended information according to the [Create an Azure Managed Redis instance](/en-us/azure/redis/quickstart-create-managed-redis) quickstart.
2. Select **Create** to start the Redis instance deployment.

### Verify resource information

1. Once the Redis resource is deployed, navigate to its overview page.
2. Take note of:

    - The hostname, found in the **Essentials** section of the resource overview page. The hostname format looks similar to: `<your-cache-name>.<region>.redis.azure.net`.
    - The SSL port, found in **Settings** &gt; **Advanced settings**. The default value is `10000`.
3. In your terminal, enable access-key authentication on the default database.

    ```bash
    az redisenterprise database update \
        --cluster-name <REDIS_NAME> \
        --resource-group <RESOURCE_GROUP> \
        --access-keys-auth Enabled
    ```
4. Retrieve the primary key for the default database and save it to an environment variable.

    ```bash
    export REDIS_PRIMARY_KEY=$(az redisenterprise database list-keys \
        --cluster-name <REDIS_NAME> \
        --resource-group <RESOURCE_GROUP> \
        --query primaryKey \
        -o tsv)
    ```

### Enable public network access

For this scenario, your Azure Managed Redis instance uses public network access. Be sure to clean up resources after you finish with this quickstart.

1. In the resource menu, under **Settings**, select **Networking**.
2. Set **Public network access** to **Enabled**.

## Configure the Dapr components

In the *redis.yaml* file, you configure the component to use access-key authentication with TLS.

```yml
- name: redisPassword
    secretKeyRef:
        name: redis-secret
        key: redisPassword
- name: useEntraID
    value: "false"
- name: enableTLS
  value: true
```

1. In your preferred code editor, navigate to the *deploy* directory in the sample repo and open *redis.yaml*.
2. For `redisHost`, replace the placeholder `<REDIS_HOST>:10000` value with the Azure Managed Redis hostname you saved earlier from the Azure portal.

    ```yml
    - name: redisHost
      value: <your-cache-name>.<region>.redis.azure.net:10000
    ```
3. Create the Kubernetes secret used by `redisPassword`.

    ```bash
    kubectl create secret generic redis-secret \
        --from-literal=redisPassword="$REDIS_PRIMARY_KEY"
    ```

### Apply the configuration

Apply the *redis.yaml* file using the `kubectl apply` command.

```bash
kubectl apply -f ./deploy/redis.yaml
```

**Expected output**

```output
component.dapr.io/statestore created
```

## Deploy the Node.js app with the Dapr sidecar

### Configure the Node.js app

1. Go to the `deploy` directory and open *workload-identity.yaml*.
2. Replace `<MANAGED_IDENTITY_CLIENT_ID>` with the client ID of the user-assigned managed identity you created.
3. Apply the service account manifest before you deploy app manifests.

    ```bash
    kubectl apply -f ./deploy/workload-identity.yaml
    ```

In *node.yaml*, the pod spec uses the workload identity label and the shared `workload-sa` service account:

```yaml
labels:
  app: node
  azure.workload.identity/use: "true"
```

### Apply the configuration

1. Apply the Node.js app deployment to your cluster using the `kubectl apply` command.

    ```bash
    kubectl apply -f ./deploy/node.yaml
    ```
2. Kubernetes deployments are asynchronous, so before moving on to the next steps, verify the deployment is complete with the following command:

    ```bash
    kubectl rollout status deploy/nodeapp
    ```
3. Access your service using the `kubectl get svc` command.

    ```bash
    kubectl get svc nodeapp
    ```
4. Make note of the `EXTERNAL-IP` in the output, and set it as an environment variable.

    ```bash
    export EXTERNAL_IP=<EXTERNAL-IP>
    ```

### Verify the Node.js service

1. Using `curl`, call the service with your `EXTERNAL-IP`.

    ```bash
    curl $EXTERNAL_IP/ports
    ```

    **Example output**

    ```output
    {"DAPR_HTTP_ENDPOINT":"http://localhost:3500","DAPR_GRPC_ENDPOINT":"http://localhost:50001"}
    ```
2. Submit an order to the application.

    ```bash
    curl --request POST --data "@sample.json" --header Content-Type:application/json $EXTERNAL_IP/neworder
    ```
3. Confirm the order.

    ```bash
    curl $EXTERNAL_IP/order
    ```

    **Expected output**

    ```output
    { "orderId": "42" }
    ```

## Deploy the Python app with the Dapr sidecar

### Configure the Python app

In *python.yaml*, the pod spec uses the workload identity label and the shared `workload-sa` service account:

```yaml
labels:
    app: python
    azure.workload.identity/use: "true"
```

### Apply the configuration

1. Deploy the Python app to your Kubernetes cluster using the `kubectl apply` command.

    ```bash
    kubectl apply -f ./deploy/python.yaml
    ```
2. Kubernetes deployments are asynchronous, so before moving on to the next steps, verify the deployment is complete with the following command:

    ```bash
    kubectl rollout status deploy/pythonapp
    ```

## Observe messages and confirm persistence

Now that both the Node.js and Python applications are deployed, you can watch messages come through.

1. Get the logs of the Node.js app using the `kubectl logs` command.

    ```bash
    kubectl logs --selector=app=node -c node --tail=-1
    ```

    **Expected output**

    ```output
    Got a new order! Order ID: 1
    Successfully persisted state
    Got a new order! Order ID: 2
    Successfully persisted state
    Got a new order! Order ID: 3
    Successfully persisted state
    ```
2. Using `curl`, call the Node.js app's order endpoint to get the latest order.

    ```bash
    curl $EXTERNAL_IP/order
    ```

    You should see the latest JSON output in the response.

## Clean up resources

If you no longer plan to use the resources from this quickstart, you can remove the resource group, cluster, namespace, and all related resources using the [az group delete](/en-us/cli/azure/group#az-group-delete) command.

```bash
az group delete --name <your-resource-group>
```