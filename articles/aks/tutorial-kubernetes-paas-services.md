---
layout: Conceptual
title: Kubernetes on Azure tutorial - Use PaaS services with an Azure Kubernetes Service (AKS) cluster - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/tutorial-kubernetes-paas-services
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
description: In this Azure Kubernetes Service (AKS) tutorial, you learn how to use the Azure Service Bus service with your AKS cluster.
ms.topic: tutorial
ms.date: 2026-06-23T00:00:00.0000000Z
ms.custom: mvc, devx-track-azurecli, devx-track-azurepowershell, aks-getting-started
ms.author: schaffererin
author: schaffererin
locale: en-us
document_id: cbcd646e-20bb-670b-911a-f7843ef897bd
document_version_independent_id: f8e55f97-dea3-809d-d353-dac4e6e8be7c
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/tutorial-kubernetes-paas-services.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,azurepowershell
toc_rel: toc.json
asset_id: aks/tutorial-kubernetes-paas-services
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/tutorial-kubernetes-paas-services.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/828c518e-a2df-46f1-8871-b760959c8fa8
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/54f6b674-eb1d-48ca-9254-9665ddd64677
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: fbbd37dd-cc04-bd3b-183a-ba8c96c66174
---

# Kubernetes on Azure tutorial - Use PaaS services with an Azure Kubernetes Service (AKS) cluster - Azure Kubernetes Service | Microsoft Learn

With Kubernetes, you can use PaaS services, such as [Azure Service Bus](/en-us/azure/service-bus-messaging/service-bus-messaging-overview), to develop and run your applications.

In this tutorial, you create an Azure Service Bus namespace and queue to test your application. You learn how to:

- Create an Azure Service Bus namespace and queue.
- Update the Kubernetes manifest file to use the Azure Service Bus queue.
- Test the updated application by placing an order.

## Before you begin

In previous tutorials, you packaged an application into a container image, uploaded the image to Azure Container Registry, created a Kubernetes cluster, and deployed an application. To complete this tutorial, you need the pre-created `aks-store-quickstart.yaml` Kubernetes manifest file. This file download was included with the application source code in a previous tutorial. Make sure you cloned the repo and changed directories into the cloned repo. If you haven't completed these steps and want to follow along, start with [Tutorial 1 - Prepare application for AKS](tutorial-kubernetes-prepare-app).

This tutorial creates billable Azure Service Bus resources. To complete these steps, use an identity that can create and manage Service Bus resources and update AKS workloads in your resource group, such as **Contributor** or **Owner**.

# [AKS desktop](#tab/aks-desktop)
This tutorial requires the installation of [AKS desktop](aks-desktop-overview).

# [Azure CLI](#tab/azure-cli)
This tutorial requires Azure CLI version 2.34.1 or later. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

# [Azure PowerShell](#tab/azure-powershell)
This tutorial requires Azure PowerShell version 5.9.0 or later. Run `Get-InstalledModule -Name Az` to find the version. If you need to install or upgrade, see [Install Azure PowerShell](/en-us/powershell/azure/install-az-ps).

---

## Create environment variables

# [AKS desktop](#tab/aks-desktop)
- Use the Azure CLI to create the following environment variables to use for the commands in this tutorial:

    ```azurecli
    LOC_NAME=westus2
    RAND=$RANDOM
    RG_NAME=myResourceGroup
    AKS_NAME=myAKSCluster
    SB_NS=sb-store-demo-$RAND
    ```

# [Azure CLI](#tab/azure-cli)
- Create the following environment variables to use for the commands in this tutorial:

    ```azurecli
    LOC_NAME=westus2
    RAND=$RANDOM
    RG_NAME=myResourceGroup
    AKS_NAME=myAKSCluster
    SB_NS=sb-store-demo-$RAND
    ```

# [Azure PowerShell](#tab/azure-powershell)
- Create the following environment variables to use for the commands in this tutorial:

    ```azurepowershell
    $LOC_NAME="westus2"
    $rand=New-Object System.Random
    $RAND=$rand.Next()
    $RG_NAME="myResourceGroup"
    $AKS_NAME="myAKSCluster"
    $SB_NS="sb-store-demo-$RAND"
    ```

---

## Create Azure Service Bus namespace and queue

In previous tutorials, you used a RabbitMQ container to store orders submitted by the `order-service`. In this tutorial, you use an Azure Service Bus namespace to provide a scoping container for the Service Bus resources within the application. You also use an Azure Service bus queue to send and receive messages between the application components. For more information on Azure Service Bus, see [Create an Azure Service Bus namespace and queue](/en-us/azure/service-bus-messaging/service-bus-quickstart-cli).

In this flow, `order-service` sends messages to the `orders` queue by using the `sender` authorization rule and key that you create in this section.

# [AKS desktop](#tab/aks-desktop)
Use the Azure CLI to create the following environment variables to use for the commands in this tutorial.

1. Create an Azure Service Bus namespace by using the [`az servicebus namespace create`](/en-us/cli/azure/servicebus/namespace#az-servicebus-namespace-create) command.

    ```azurecli
    az servicebus namespace create --name $SB_NS --resource-group $RG_NAME --location $LOC_NAME
    ```

    Continue when the command completes successfully and returns the namespace details.
2. Create an Azure Service Bus queue using the [`az servicebus queue create`](/en-us/cli/azure/servicebus/queue#az-servicebus-queue-create) command.

    ```azurecli
    az servicebus queue create --name orders --resource-group $RG_NAME --namespace-name $SB_NS
    ```

    Verify that the queue exists before continuing:

    ```azurecli
    az servicebus queue show --name orders --resource-group $RG_NAME --namespace-name $SB_NS --query name -o tsv
    ```
3. Create an Azure Service Bus authorization rule using the [`az servicebus queue authorization-rule create`](/en-us/cli/azure/servicebus/queue/authorization-rule#az-servicebus-queue-authorization-rule-create) command.

    ```azurecli
    az servicebus queue authorization-rule create \
        --name sender \
        --namespace-name $SB_NS \
        --resource-group $RG_NAME \
        --queue-name orders \
        --rights Send
    ```
4. Get the Azure Service Bus credentials for later use by using the [`az servicebus namespace show`](/en-us/cli/azure/servicebus/namespace#az-servicebus-namespace-show) and [`az servicebus queue authorization-rule keys list`](/en-us/cli/azure/servicebus/queue/authorization-rule/keys#az-servicebus-queue-authorization-rule-keys-list) commands.

    ```azurecli
    az servicebus namespace show --name $SB_NS --resource-group $RG_NAME --query name -o tsv
    az servicebus queue authorization-rule keys list --namespace-name $SB_NS --resource-group $RG_NAME --queue-name orders --name sender --query primaryKey -o tsv
    ```

    Save these values for the manifest update step:

    - `<REPLACE_WITH_YOUR_ACR_NAME>`: your Azure Container Registry name from earlier tutorials.
    - `<REPLACE_WITH_YOUR_SB_NS_HOSTNAME>`: `$SB_NS.servicebus.windows.net`.
    - `<REPLACE_WITH_YOUR_SB_SENDER_PASSWORD>`: the `primaryKey` value from the command output.

# [Azure CLI](#tab/azure-cli)
1. Create an Azure Service Bus namespace using the [`az servicebus namespace create`](/en-us/cli/azure/servicebus/namespace#az-servicebus-namespace-create) command.

    ```azurecli
    az servicebus namespace create --name $SB_NS --resource-group $RG_NAME --location $LOC_NAME
    ```

    Continue when the command finishes successfully and returns the namespace details.
2. Create an Azure Service Bus queue using the [`az servicebus queue create`](/en-us/cli/azure/servicebus/queue#az-servicebus-queue-create) command.

    ```azurecli
    az servicebus queue create --name orders --resource-group $RG_NAME --namespace-name $SB_NS
    ```

    Verify that the queue exists before continuing.

    ```azurecli
    az servicebus queue show --name orders --resource-group $RG_NAME --namespace-name $SB_NS --query name -o tsv
    ```
3. Create an Azure Service Bus authorization rule using the [`az servicebus queue authorization-rule create`](/en-us/cli/azure/servicebus/queue/authorization-rule#az-servicebus-queue-authorization-rule-create) command.

    ```azurecli
    az servicebus queue authorization-rule create \
        --name sender \
        --namespace-name $SB_NS \
        --resource-group $RG_NAME \
        --queue-name orders \
        --rights Send
    ```
4. Get the Azure Service Bus credentials for later use by using the [`az servicebus namespace show`](/en-us/cli/azure/servicebus/namespace#az-servicebus-namespace-show) and [`az servicebus queue authorization-rule keys list`](/en-us/cli/azure/servicebus/queue/authorization-rule/keys#az-servicebus-queue-authorization-rule-keys-list) commands.

    ```azurecli
    az servicebus namespace show --name $SB_NS --resource-group $RG_NAME --query name -o tsv
    az servicebus queue authorization-rule keys list --namespace-name $SB_NS --resource-group $RG_NAME --queue-name orders --name sender --query primaryKey -o tsv
    ```

    Save these values for the manifest update step:

    - `<REPLACE_WITH_YOUR_ACR_NAME>`: your Azure Container Registry name from earlier tutorials.
    - `<REPLACE_WITH_YOUR_SB_NS_HOSTNAME>`: `$SB_NS.servicebus.windows.net`.
    - `<REPLACE_WITH_YOUR_SB_SENDER_PASSWORD>`: the `primaryKey` value from the command output.

# [Azure PowerShell](#tab/azure-powershell)
1. Create an Azure Service Bus namespace using the [`New-AzServiceBusNamespace`](/en-us/powershell/module/az.servicebus/new-azservicebusnamespace) cmdlet.

    ```azurepowershell
    New-AzServiceBusNamespace -Name $SB_NS -ResourceGroupName $RG_NAME -Location $LOC_NAME
    ```

    Continue when the command completes successfully and returns the namespace details.
2. Create an Azure Service Bus queue using the [`New-AzServiceBusQueue`](/en-us/powershell/module/az.servicebus/new-azservicebusqueue) cmdlet.

    ```azurepowershell
    New-AzServiceBusQueue -Name orders -ResourceGroupName $RG_NAME -NamespaceName $SB_NS
    ```

    Verify that the queue exists before continuing:

    ```azurepowershell
    (Get-AzServiceBusQueue -Name orders -ResourceGroupName $RG_NAME -NamespaceName $SB_NS).Name
    ```
3. Create an Azure Service Bus authorization rule using the [`New-AzServiceBusAuthorizationRule`](/en-us/powershell/module/az.servicebus/new-azservicebusauthorizationrule) cmdlet.

    ```azurepowershell
    New-AzServiceBusAuthorizationRule `
        -Name sender `
        -NamespaceName $SB_NS `
        -ResourceGroupName $RG_NAME `
        -QueueName orders `
        -Rights Send
    ```
4. Get the Azure Service Bus credentials for later use by using the [`Get-AzServiceBusNamespace`](/en-us/powershell/module/az.servicebus/get-azservicebusnamespace) and [`Get-AzServiceBusKey`](/en-us/powershell/module/az.servicebus/get-azservicebuskey) cmdlets.

    ```azurepowershell
    (Get-AzServiceBusNamespace -Name $SB_NS -ResourceGroupName $RG_NAME).Name 
    (Get-AzServiceBusKey -NamespaceName $SB_NS -ResourceGroupName $RG_NAME -Name sender -QueueName orders).PrimaryKey
    ```

    Save these values for the manifest update step:

    - `<REPLACE_WITH_YOUR_ACR_NAME>`: your Azure Container Registry name from earlier tutorials.
    - `<REPLACE_WITH_YOUR_SB_NS_HOSTNAME>`: `$SB_NS.servicebus.windows.net`.
    - `<REPLACE_WITH_YOUR_SB_SENDER_PASSWORD>`: the `PrimaryKey` value from the command output.

---

## Update Kubernetes manifest file

# [AKS desktop](#tab/aks-desktop)
1. Go to **Projects** in AKS desktop and select the one you created in the previous tutorial, `my-dev-frontend`.
2. Select the **Resources** tab, and then select **Workloads** &gt; **Deployment: order-service**. ![Screenshot that shows editing deployment, Resources, Workloads, Deployment, Order-service.](media/aks-desktop-app/aks-desktop-res-map.png)
3. Select the **Editor**.
4. Remove the existing `rabbitmq` StatefulSet, ConfigMap, and Service sections. Replace the existing `order-service` Deployment section with the following content. Copy and paste the content:

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: order-service
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: order-service
      template:
        metadata:
          labels:
            app: order-service
        spec:
          nodeSelector:
            "kubernetes.io/os": linux
          containers:
          - name: order-service
            image: <REPLACE_WITH_YOUR_ACR_NAME>.azurecr.io/aks-store-demo/order-service:latest
            ports:
            - containerPort: 3000
            env:
            - name: ORDER_QUEUE_HOSTNAME
              value: "<REPLACE_WITH_YOUR_SB_NS_HOSTNAME>" # Example: sb-store-demo-123456.servicebus.windows.net
            - name: ORDER_QUEUE_PORT
              value: "5671"
            - name: ORDER_QUEUE_TRANSPORT
              value: "tls"
            - name: ORDER_QUEUE_USERNAME
              value: "sender"
            - name: ORDER_QUEUE_PASSWORD
              value: "<REPLACE_WITH_YOUR_SB_SENDER_PASSWORD>"
            - name: ORDER_QUEUE_NAME
              value: "orders"
            - name: FASTIFY_ADDRESS
              value: "0.0.0.0"
            resources:
              requests:
                cpu: 1m
                memory: 50Mi
              limits:
                cpu: 75m
                memory: 128Mi
            startupProbe:
              httpGet:
                path: /health
                port: 3000
              failureThreshold: 5
              initialDelaySeconds: 20
              periodSeconds: 10
            readinessProbe:
              httpGet:
                path: /health
                port: 3000
              failureThreshold: 3
              initialDelaySeconds: 3
              periodSeconds: 5
            livenessProbe:
              httpGet:
                path: /health
                port: 3000
              failureThreshold: 5
              initialDelaySeconds: 3
              periodSeconds: 3
    ```

    ![Screenshot that shows using the editor to update the YAML deployment.](media/aks-desktop-app/aks-desktop-yaml-edits-update.png)

    Note

    Directly adding sensitive information, such as API keys, to your Kubernetes manifest files isn't secure and might accidentally get committed to code repositories. This example adds it for simplicity. For production workloads, use [Managed Identity](use-managed-identity) to authenticate with Azure Service Bus or store your secrets in [Azure Key Vault](csi-secrets-store-driver).
5. Persist the update by selecting **Save & Apply**.
6. Verify that the updated `order-service` deployment reaches a healthy state in the workload view before continuing.

# [Azure CLI](#tab/azure-cli)
1. Configure `kubectl` to connect to your cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
    ```
2. Open the `aks-store-quickstart.yaml` file in a text editor.
3. Remove the existing `rabbitmq` StatefulSet, ConfigMap, and Service sections. Replace the existing `order-service` Deployment section with the following content:

Replace the placeholders in the YAML with the values you saved earlier before you apply the manifest.

```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: order-service
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: order-service
    template:
      metadata:
        labels:
          app: order-service
      spec:
        nodeSelector:
          "kubernetes.io/os": linux
        containers:
        - name: order-service
          image: <REPLACE_WITH_YOUR_ACR_NAME>.azurecr.io/aks-store-demo/order-service:latest
          ports:
          - containerPort: 3000
          env:
          - name: ORDER_QUEUE_HOSTNAME
            value: "<REPLACE_WITH_YOUR_SB_NS_HOSTNAME>" # Example: sb-store-demo-123456.servicebus.windows.net
          - name: ORDER_QUEUE_USERNAME
            value: "sender"
          - name: ORDER_QUEUE_PASSWORD
            value: "<REPLACE_WITH_YOUR_SB_SENDER_PASSWORD>"
          - name: ORDER_QUEUE_NAME
            value: "orders"
          - name: FASTIFY_ADDRESS
            value: "0.0.0.0"
          resources:
            requests:
              cpu: 1m
              memory: 50Mi
            limits:
              cpu: 75m
              memory: 128Mi
          startupProbe:
            httpGet:
              path: /health
              port: 3000
            failureThreshold: 5
            initialDelaySeconds: 20
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /health
              port: 3000
            failureThreshold: 3
            initialDelaySeconds: 3
            periodSeconds: 5
          livenessProbe:
            httpGet:
              path: /health
              port: 3000
            failureThreshold: 5
            initialDelaySeconds: 3
            periodSeconds: 3
```

Note

Directly adding sensitive information, such as API keys, to your Kubernetes manifest files isn't secure and may accidentally get committed to code repositories. We added it here for simplicity. For production workloads, use [Managed Identity](use-managed-identity) to authenticate with Azure Service Bus or store your secrets in [Azure Key Vault](csi-secrets-store-driver).

1. Save and close the updated `aks-store-quickstart.yaml` file.

# [Azure PowerShell](#tab/azure-powershell)
1. Configure `kubectl` to connect to your cluster using the [`Import-AzAksCredential`](/en-us/powershell/module/az.aks/import-azakscredential) cmdlet.

    ```azurepowershell
    Import-AzAksCredential -ResourceGroupName myResourceGroup -Name myAKSCluster
    ```
2. Open the `aks-store-quickstart.yaml` file in a text editor.
3. Remove the existing `rabbitmq` Deployment and Service sections and replace the existing `order-service` Deployment section with the following content:

Replace the placeholders in the YAML with the values you saved earlier before you apply the manifest.

```YAML
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: order-service
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: order-service
    template:
      metadata:
        labels:
          app: order-service
      spec:
        nodeSelector:
          "kubernetes.io/os": linux
        containers:
        - name: order-service
          image: <REPLACE_WITH_YOUR_ACR_NAME>.azurecr.io/aks-store-demo/order-service:latest
          ports:
          - containerPort: 3000
          env:
          - name: ORDER_QUEUE_HOSTNAME
            value: "<REPLACE_WITH_YOUR_SB_NS_HOSTNAME>" # Example: sb-store-demo-123456.servicebus.windows.net
          - name: ORDER_QUEUE_USERNAME
            value: "sender"
          - name: ORDER_QUEUE_PASSWORD
            value: "<REPLACE_WITH_YOUR_SB_SENDER_PASSWORD>"
          - name: ORDER_QUEUE_NAME
            value: "orders"
          - name: FASTIFY_ADDRESS
            value: "0.0.0.0"
          resources:
            requests:
              cpu: 1m
              memory: 50Mi
            limits:
              cpu: 75m
              memory: 128Mi
```

Note

Directly adding sensitive information, such as API keys, to your Kubernetes manifest files isn't secure and may accidentally get committed to code repositories. We added it here for simplicity. For production workloads, use [Managed Identity](use-managed-identity) to authenticate with Azure Service Bus or store your secrets in [Azure Key Vault](csi-secrets-store-driver).

1. Save and close the updated `aks-store-quickstart.yaml` file.

---

## Deploy the updated application

1. Deploy the updated application by using the `kubectl apply` command.

    ```console
    kubectl apply -f aks-store-quickstart.yaml
    ```

    The following example output shows the successfully updated resources:

    ```output
    deployment.apps/order-service configured
    service/order-service unchanged
    deployment.apps/product-service unchanged
    service/product-service unchanged
    deployment.apps/store-front configured
    service/store-front unchanged
    ```
2. Verify that the updated deployment is running.

    ```console
    kubectl get pods
    ```

Continue when the application pods are in `Running` state.

## Test the application

### Place a sample order

#### AKS desktop

Get the public IP address by going to **Resource** &gt; **Network** &gt; **Service: store-front** &gt; **External IP**.

![Screenshot that shows getting the external IP address.](media/aks-desktop-app/aks-desktop-networking-resources.png)

#### Command line

1. Get the external IP address of the `store-front` service using the `kubectl get service` command.

    ```console
    kubectl get service store-front
    ```

    If `EXTERNAL-IP` is `<pending>`, wait a minute and run the command again until a public IP address appears.
2. Navigate to the external IP address of the `store-front` service in your browser using `http://<external-ip>`.
3. Place an order by choosing a product and selecting **Add to cart**.
4. Select **Cart** to view your order, and then select **Checkout**.

### View the order in the Azure Service Bus queue

1. Navigate to the Azure portal and open the Azure Service Bus namespace you created earlier.
2. Under **Entities**, select **Queues**, and then select the **orders** queue.
3. In the **orders** queue, select **Service Bus Explorer**.
4. Select **Peek from start** to view the order you submitted.