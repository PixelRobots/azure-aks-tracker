---
layout: Conceptual
title: Deploy an application that uses OpenAI on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/open-ai-quickstart
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
description: Learn how to deploy an application that uses OpenAI on Azure Kubernetes Service (AKS).
ms.topic: how-to
ms.date: 2026-08-06T00:00:00.0000000Z
ms.custom: template-how-to, devx-track-azurecli
ms.subservice: aks-developer
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: fa17ab9d-8099-46ac-58bc-496fe4ae3317
document_version_independent_id: 93f99b36-5616-74d0-936d-88338aac242c
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/open-ai-quickstart.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/open-ai-quickstart
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/open-ai-quickstart.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/8a6e4dad-7050-4ce7-83f9-eb4123577a54
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/0a5fc323-00ce-4c20-9095-41948f54c83f
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: a1c9aded-7107-7b08-008a-c91a93e741a8
---

# Deploy an application that uses OpenAI on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

In this article, you deploy the AKS Store Demo application on Azure Kubernetes Service (AKS) and configure Azure OpenAI or the OpenAI API to generate product descriptions.

The sample cloud-native application comprises services written in multiple languages and frameworks, including:

- Golang with Gin
- Rust with Actix-Web
- JavaScript with Vue.js and Fastify
- Python with FastAPI

These applications provide front ends for shoppers and store administrators, REST APIs that send data to a RabbitMQ message queue and DocumentDB database, and console apps that simulate traffic.

Note

Don't run stateful containers, such as DocumentDB and RabbitMQ, without persistent storage in production. This article uses them without persistent storage for simplicity. For production workloads, use managed services such as Azure Cosmos DB or Azure Service Bus.

To access the GitHub codebase for the sample application, see [AKS Store Demo](https://github.com/Azure-Samples/aks-store-demo).

## Before you begin

- You need an Azure account with an active subscription. If you don't have one, [create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- For this demo, use either Azure OpenAI or the OpenAI API.
    - To use Azure OpenAI, you need permissions to create an Azure OpenAI resource and deploy a model. Registration is required only for [limited-access models or modified safeguards](/en-us/azure/foundry/responsible-ai/openai/limited-access).
    - To use the OpenAI API, sign up on the [OpenAI website](https://openai.com/).

## Prerequisites

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

## Create a resource group

An [Azure resource group](/en-us/azure/azure-resource-manager/management/overview) is a logical group in which you deploy and manage Azure resources. When you create a resource group, you're prompted to specify a location. This location is the storage location of your resource group metadata and where your resources run in Azure if you don't specify another region during resource creation.

The following example creates a resource group named *myResourceGroup* in the *eastus* location.

Create a resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

```azurecli
az group create --name myResourceGroup --location eastus
```

The following example output shows successful creation of the resource group:

```output
{
  "id": "/subscriptions/<guid>/resourceGroups/myResourceGroup",
  "location": "eastus",
  "managedBy": null,
  "name": "myResourceGroup",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
}
```

## Create an AKS cluster

The following example creates a cluster named *myAKSCluster* in *myResourceGroup*.

Create an AKS cluster using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command.

```azurecli
az aks create --resource-group myResourceGroup --name myAKSCluster --generate-ssh-keys
```

After a few minutes, the command completes and returns JSON-formatted information about the cluster.

## Connect to the cluster

To manage a Kubernetes cluster, use the Kubernetes command-line client, [`kubectl`](https://kubernetes.io/docs/reference/kubectl/). If you use Azure Cloud Shell, `kubectl` is already installed.

1. Install `kubectl` locally using the [`az aks install-cli`](/en-us/cli/azure/aks#az-aks-install-cli) command.

    ```azurecli
    az aks install-cli
    ```

    Note

    If your Linux-based system requires elevated permissions, use the `sudo az aks install-cli` command.
2. Configure `kubectl` to connect to your Kubernetes cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    This command runs the following operations:

    - Downloads credentials and configures the Kubernetes CLI to use them.
    - Uses `~/.kube/config`, the default location for the [Kubernetes configuration file](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/). Specify a different location for your Kubernetes configuration file by using the *--file* argument.

    ```azurecli
    az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
    ```
3. Verify the connection to your cluster using the [`kubectl get`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command. This command returns a list of the cluster nodes.

    ```bash
    kubectl get nodes
    ```

    The following example output shows the nodes created in the preceding steps. Verify that each node has a status of *Ready*.

    ```output
    NAME                                STATUS   ROLES   AGE     VERSION
    aks-nodepool1-31469198-vmss000000   Ready    agent   3h29m   v1.25.6
    aks-nodepool1-31469198-vmss000001   Ready    agent   3h29m   v1.25.6
    aks-nodepool1-31469198-vmss000002   Ready    agent   3h29m   v1.25.6
    ```

Note

For a private AKS cluster, connect from an endpoint in the same virtual network as the cluster. For configuration instructions, see [Create a private AKS cluster](private-clusters).

## Deploy the application

The [AKS Store application](https://github.com/Azure-Samples/aks-store-demo) manifest includes the following Kubernetes deployments and services:

- **Product service**: Shows product information.
- **Order service**: Places orders.
- **Makeline service**: Processes orders from the queue and completes the orders.
- **Store front**: Web application for customers to view products and place orders.
- **Store admin**: Web application for store employees to view orders in the queue and manage product information.
- **Virtual customer**: Simulates order creation on a scheduled basis.
- **Virtual worker**: Simulates order completion on a scheduled basis.
- **DocumentDB**: NoSQL instance for persisted data.
- **RabbitMQ**: Message queue for an order queue.

Note

Don't run stateful containers, such as DocumentDB and RabbitMQ, without persistent storage in production. This article uses them without persistent storage for simplicity. For production workloads, use managed services such as Azure Cosmos DB or Azure Service Bus.

1. Review the [YAML manifest](https://github.com/Azure-Samples/aks-store-demo/blob/main/aks-store-all-in-one.yaml) for the application.
2. Deploy the application using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command and specify the name of your YAML manifest.

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/Azure-Samples/aks-store-demo/main/aks-store-all-in-one.yaml
    ```

## Deploy an OpenAI service

Choose Azure OpenAI or the OpenAI API for the application running on AKS.

# [Azure OpenAI](#tab/aoai)
1. In the Azure portal, create an Azure OpenAI instance.
2. Sign in to [Microsoft Foundry](https://ai.azure.com/).
3. Turn off the **New Foundry** toggle, and then select **View all resources** under **Keep building with Foundry**.
4. Select the Azure OpenAI resource you created, and then select **Deployments** under **Shared resources**.
5. Select **Deploy model** &gt; **Deploy base model**.
6. Select the **gpt-4o-mini** base model, enter a deployment name, and then deploy the model. Save the deployment name for the next section.

For more information about creating an Azure OpenAI deployment, see [Get started generating text using Azure OpenAI](/en-us/azure/ai-services/openai/quickstart).

# [OpenAI](#tab/openai)
1. [Generate an OpenAI key](https://platform.openai.com/account/api-keys) by selecting **Create new secret key** and save the key. You need this key in the Deploy the AI microservice section.
2. [Start a paid plan](https://platform.openai.com/account/billing/overview) to use OpenAI API.

---

## Deploy the AI microservice

Deploy the Python-based AI microservice that uses OpenAI to automatically generate product descriptions. This microservice connects to the AKS Store application you deployed in the previous section.

# [Azure OpenAI](#tab/aoai)
Use the Azure OpenAI resource and model deployment you created in the Deploy an OpenAI service section. Configure the following environment variables in the AI microservice manifest:

| Environment variable | Value |
| --- | --- |
| `USE_AZURE_OPENAI` | Set to `"True"` to use Azure OpenAI. |
| `AZURE_OPENAI_DEPLOYMENT_NAME` | The name of your `gpt-4o-mini` model deployment in Microsoft Foundry. |
| `AZURE_OPENAI_ENDPOINT` | The endpoint from the **Keys and Endpoint** page of your Azure OpenAI resource. |
| `OPENAI_API_KEY` | An API key from the **Keys and Endpoint** page of your Azure OpenAI resource. |

1. Create a file named `ai-service.yaml` and copy in the following manifest:

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: ai-service
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: ai-service
      template:
        metadata:
          labels:
            app: ai-service
        spec:
          nodeSelector:
            "kubernetes.io/os": linux
          containers:
            - name: ai-service
              image: ghcr.io/azure-samples/aks-store-demo/ai-service:2.2.0
              ports:
                - containerPort: 5001
              env:
                - name: USE_AZURE_OPENAI
                  value: "True"
                - name: AZURE_OPENAI_DEPLOYMENT_NAME
                  value: ""
                - name: AZURE_OPENAI_ENDPOINT
                  value: ""
                - name: OPENAI_API_KEY
                  value: ""
              resources:
                requests:
                  cpu: 20m
                  memory: 50Mi
                limits:
                  cpu: 50m
                  memory: 128Mi
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: ai-service
    spec:
      type: ClusterIP
      ports:
        - name: http
          port: 5001
          targetPort: 5001
      selector:
        app: ai-service
    ```
2. Set the environment variable `USE_AZURE_OPENAI` to `"True"`.
3. In [Microsoft Foundry](https://ai.azure.com/), copy the Azure OpenAI deployment name and set the `AZURE_OPENAI_DEPLOYMENT_NAME` value.
4. In the Azure portal, select **Keys and Endpoint** in your Azure OpenAI resource. Copy the endpoint and API key, and then set the `AZURE_OPENAI_ENDPOINT` and `OPENAI_API_KEY` values.
5. Deploy the application using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command and specify the name of your YAML manifest.

    ```bash
    kubectl apply -f ai-service.yaml
    ```

    The following example output shows the successfully created deployments and services:

    ```output
      deployment.apps/ai-service created
      service/ai-service created
    ```

# [OpenAI](#tab/openai)
Use the OpenAI secret key and organization ID from the Deploy an OpenAI service section. Configure the following environment variables in the AI microservice manifest:

| Environment variable | Value |
| --- | --- |
| `USE_AZURE_OPENAI` | Set to `"False"` to use OpenAI. |
| `OPENAI_API_KEY` | The OpenAI secret key generated on the [OpenAI API keys page](https://platform.openai.com/account/api-keys). |
| `OPENAI_ORG_ID` | Your organization ID from the [OpenAI organization settings page](https://platform.openai.com/account/org-settings). |

1. Create a file named `ai-service.yaml` and copy in the following manifest:

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: ai-service
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: ai-service
      template:
        metadata:
          labels:
            app: ai-service
        spec:
          nodeSelector:
            "kubernetes.io/os": linux
          containers:
            - name: ai-service
              image: ghcr.io/azure-samples/aks-store-demo/ai-service:2.2.0
              ports:
                - containerPort: 5001
              env:
                - name: USE_AZURE_OPENAI
                  value: "False"
                - name: OPENAI_API_KEY
                  value: ""
                - name: OPENAI_ORG_ID
                  value: ""
              resources:
                requests:
                  cpu: 20m
                  memory: 50Mi
                limits:
                  cpu: 50m
                  memory: 128Mi
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: ai-service
    spec:
      type: ClusterIP
      ports:
        - name: http
          port: 5001
          targetPort: 5001
      selector:
        app: ai-service
    ```
2. Set the environment variable `USE_AZURE_OPENAI` to `"False"`.
3. Set `OPENAI_API_KEY` to the OpenAI secret key you generated on the [OpenAI API keys page](https://platform.openai.com/account/api-keys) in the Deploy an OpenAI service section.
4. Set `OPENAI_ORG_ID` to the organization ID from your [OpenAI organization settings page](https://platform.openai.com/account/org-settings).
5. Deploy the application using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command and specify the name of your YAML manifest.

    ```bash
    kubectl apply -f ai-service.yaml
    ```

    The following example output shows the successfully created deployments and services:

    ```output
      deployment.apps/ai-service created
      service/ai-service created
    ```

---

Note

Storing API keys directly in Kubernetes manifests is insecure and can expose secrets in source control. This example uses manifest values for simplicity. For production workloads, authenticate to Azure OpenAI by using a [managed identity](/en-us/azure/ai-services/openai/how-to/managed-identity#authorize-access-to-managed-identities), or store secrets in [Azure Key Vault](csi-secrets-store-driver).

## Test the application

1. Check the status of the deployed pods using the [`kubectl get pods`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command.

    ```bash
    kubectl get pods
    ```

    Verify that all pods have a status of *Running* before you continue.
2. Get the external IP address for Store Admin by using the `kubectl get service` command.

    ```bash
    kubectl get service store-admin
    ```

    A Kubernetes service exposes Store Admin through a public load balancer. The load balancer might take a few minutes to assign an address. The **EXTERNAL-IP** value displays *pending* until the address is available.

    ```output
    NAME          TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)        AGE
    store-admin   LoadBalancer   10.0.142.228   40.64.86.161    80:32494/TCP   50m
    ```
3. Repeat the preceding step for the `store-front` service.
4. In a web browser, go to the external IP address for Store Admin. In this example, the address is *40.64.86.161*.
5. In Store Admin, select **Products** &gt; **Add Product**.
6. After `ai-service` starts, the **Ask AI Assistant** button appears next to the description field. Enter the name, price, and keywords, select **Ask AI Assistant** to generate a product description, and then select **Save Product**.
7. Verify that Dog Smart Collar appears in Store Admin.

    ![Screenshot showing the new product in Store Admin.](media/ai-walkthrough/new-product-store-admin.png)
8. Go to the external IP address for Store Front and verify that Dog Smart Collar appears.

    ![Screenshot showing the new product in Store Front.](media/ai-walkthrough/new-product-store-front.png)