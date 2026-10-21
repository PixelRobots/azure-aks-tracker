---
layout: Conceptual
title: Configure cross-tenant workload identity on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/workload-identity-cross-tenant
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
description: Learn how to configure cross-tenant workload identity on Azure Kubernetes Service (AKS).
author: schaffererin
ms.topic: how-to
ms.subservice: aks-security
ms.date: 2024-07-03T00:00:00.0000000Z
ms.author: schaffererin
locale: en-us
document_id: 6547f7c8-6779-f441-4f59-1bee23f556ec
document_version_independent_id: 0d6c8568-81ca-68b7-6776-cba8d9ce87c4
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/workload-identity-cross-tenant.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/workload-identity-cross-tenant
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/workload-identity-cross-tenant.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 22984ff3-2752-7b2e-610b-f25a16035a62
---

# Configure cross-tenant workload identity on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to configure cross-tenant workload identity on Azure Kubernetes Service (AKS). Cross-tenant workload identity allows you to access resources in another tenant from your AKS cluster. In this example, you create an Azure Service Bus in one tenant and send messages to it from a workload running in an AKS cluster in another tenant.

For more information on workload identity, see the [Workload identity overview](workload-identity-overview).

## Prerequisites

- ***Two Azure subscriptions***, each in a separate tenant. In this article, we refer to these as *Tenant A* and *Tenant B*.
- Azure CLI installed on your local machine. If you don't have the Azure CLI installed, see [Install the Azure CLI](/en-us/cli/azure/install-azure-cli).
- Bash shell environment. This article uses Bash shell syntax.
- You need to have the following subscription details:

    - *Tenant A* tenant ID
    - *Tenant A* subscription ID
    - *Tenant B* tenant ID
    - *Tenant B* subscription ID

Important

Make sure you stay within the same terminal window for the duration of this article to retain the environment variables you set. If you close the terminal window, you need to set the environment variables again.

## Configure resources in Tenant A

In *Tenant A*, you create an AKS cluster with workload identity and OIDC issuer enabled. You use this cluster to deploy an application that attempts to access resources in *Tenant B*.

### Log in to Tenant A

1. Log in to your *Tenant A* subscription using the [`az login`](/en-us/cli/azure/authenticate-azure-cli-interactively) command.

    ```azurecli
    # Set environment variable
    TENANT_A_ID=<tenant-id>
    
    az login --tenant $TENANT_A_ID
    ```
2. Ensure you're working with the correct subscription in *Tenant A* using the [`az account set`](/en-us/cli/azure/account#az-account-set) command.

    ```azurecli
    # Set environment variable
    TENANT_A_SUBSCRIPTION_ID=<subscription-id>
    
    # Log in to your Tenant A subscription
    az account set --subscription $TENANT_A_SUBSCRIPTION_ID
    ```

### Create resources in Tenant A

1. Create a resource group in *Tenant A* to host the AKS cluster using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    # Set environment variables
    RESOURCE_GROUP=<resource-group-name>
    LOCATION=<location>
    
    # Create a resource group
    az group create --name $RESOURCE_GROUP --location $LOCATION
    ```
2. Create an AKS cluster in *Tenant A* with workload identity and OIDC issuer enabled using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command.

    ```azurecli
    # Set environment variable
    CLUSTER_NAME=<cluster-name>
    
    # Create an AKS cluster
    az aks create \
      --resource-group $RESOURCE_GROUP \
      --name $CLUSTER_NAME \
      --enable-oidc-issuer \
      --enable-workload-identity \
      --generate-ssh-keys
    ```

### Get OIDC issuer URL from AKS cluster

- Get the OIDC issuer URL from the cluster in *Tenant A* using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```azurecli
    OIDC_ISSUER_URL=$(az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --query "oidcIssuerProfile.issuerUrl" --output tsv)
    ```

## Configure resources in Tenant B

In *Tenant B*, you create an Azure Service Bus, a managed identity and assign it permissions to read and write messages to the service bus, and establish the trust between the managed identity and the AKS cluster in *Tenant A*.

### Log in to Tenant B

1. Log out of your *Tenant A* subscription using the [`az logout`](/en-us/cli/azure/authenticate-azure-cli-interactively#logout) command.

    ```azurecli
    az logout
    ```
2. Log in to your *Tenant B* subscription using the [`az login`](/en-us/cli/azure/authenticate-azure-cli-interactively) command.

    ```azurecli
    # Set environment variable
    TENANT_B_ID=<tenant-id>
    
    az login --tenant $TENANT_B_ID
    ```
3. Ensure you're working with the correct subscription in *Tenant B* using the [`az account set`](/en-us/cli/azure/account#az-account-set) command.

    ```azurecli
    # Set environment variable
    TENANT_B_SUBSCRIPTION_ID=<subscription-id>
    
    # Log in to your Tenant B subscription
    az account set --subscription $TENANT_B_SUBSCRIPTION_ID
    ```

### Create resources in Tenant B

1. Create a resource group in *Tenant B* to host the managed identity using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    # Set environment variables
    RESOURCE_GROUP=<resource-group-name>
    LOCATION=<location>
    
    # Create a resource group
    az group create --name $RESOURCE_GROUP --location $LOCATION
    ```
2. Create a service bus and queue in *Tenant B* using the [`az servicebus namespace create`](/en-us/cli/azure/servicebus/namespace#az-servicebus-namespace-create) and [`az servicebus queue create`](/en-us/cli/azure/servicebus/queue#az-servicebus-queue-create) commands.

    ```azurecli
    # Set environment variable
    SERVICEBUS_NAME=sb-crosstenantdemo-$RANDOM
    
    # Create a new service bus namespace and and return the service bus hostname
    SERVICEBUS_HOSTNAME=$(az servicebus namespace create \
      --name $SERVICEBUS_NAME \
      --resource-group $RESOURCE_GROUP \
      --disable-local-auth \
      --query serviceBusEndpoint \
      --output tsv | sed -e 's/https:\/\///' -e 's/:443\///')
    
    # Create a new queue in the service bus namespace
    az servicebus queue create \
      --name myqueue \
      --namespace $SERVICEBUS_NAME \
      --resource-group $RESOURCE_GROUP
    ```
3. Create a user-assigned managed identity in *Tenant B* using the [`az identity create`](/en-us/cli/azure/identity#az-identity-create) command.

    ```azurecli
    # Set environment variable
    IDENTITY_NAME=${SERVICEBUS_NAME}-identity
    
    # Create a user-assigned managed identity
    az identity create --resource-group $RESOURCE_GROUP --name $IDENTITY_NAME
    ```

### Get resource IDs and assign permissions in Tenant B

1. Get the principal ID of the managed identity in *Tenant B* using the [`az identity show`](/en-us/cli/azure/identity#az-identity-show) command.

    ```azurecli
    # Get the user-assigned managed identity principalId
    PRINCIPAL_ID=$(az identity show \
      --resource-group $RESOURCE_GROUP \
      --name $IDENTITY_NAME \
      --query principalId \
      --output tsv)
    ```
2. Get the client ID of the managed identity in *Tenant B* using the [`az identity show`](/en-us/cli/azure/identity#az-identity-show) command.

    ```azurecli
    CLIENT_ID=$(az identity show \
      --resource-group $RESOURCE_GROUP \
      --name $IDENTITY_NAME \
      --query clientId \
      --output tsv)
    ```
3. Get the resource ID of the service bus namespace in *Tenant B* using the [`az servicebus namespace show`](/en-us/cli/azure/servicebus/namespace#az-servicebus-namespace-show) command.

    ```azurecli
    SERVICEBUS_ID=$(az servicebus namespace show \
      --name $SERVICEBUS_NAME \
      --resource-group $RESOURCE_GROUP \
      --query id \
      --output tsv)
    ```
4. Assign the managed identity in *Tenant B* permissions to read and write service bus messages using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command.

    ```azurecli
    az role assignment create \
      --role "Azure Service Bus Data Owner" \
      --assignee-object-id $PRINCIPAL_ID \
      --assignee-principal-type ServicePrincipal \
      --scope $SERVICEBUS_ID
    ```

## Establish trust between AKS cluster and managed identity

In this section, you create the federated identity credential needed to establish trust between the AKS cluster in *Tenant A* and the managed identity in *Tenant B*. You use the OIDC issuer URL from the AKS cluster in *Tenant A* and the name of the managed identity in *Tenant B*.

- Create a federated identity credential using the [`az identity federated-credential create`](/en-us/cli/azure/identity/federated-credential#az-identity-federated-credential-create) command.

    ```azurecli
    az identity federated-credential create \
      --name $IDENTITY_NAME-$RANDOM \
      --identity-name $IDENTITY_NAME \
      --resource-group $RESOURCE_GROUP \
      --issuer $OIDC_ISSUER_URL \
      --subject system:serviceaccount:default:myserviceaccount
    ```

`--subject system:serviceaccount:default:myserviceaccount` is the name of the Kubernetes service account that you create in *Tenant A* later in the article. When your application pod makes authentication requests, this value is sent to Microsoft Entra ID as the `subject` in the authorization request. Microsoft Entra ID determines eligibility based on whether this value matches what you set when you created the federated identity credential, so it's important to ensure the value matches.

## Deploy application to send messages to Azure Service Bus queue

In this section, you deploy an application to your AKS cluster in *Tenant A* that sends messages to the Azure Service Bus queue in *Tenant B*.

### Log in to Tenant A and get AKS credentials

1. Log out of your *Tenant B* subscription using the [`az logout`](/en-us/cli/azure/authenticate-azure-cli-interactively#logout) command.

    ```azurecli
    az logout
    ```
2. Log in to your *Tenant A* subscription using the [`az login`](/en-us/cli/azure/authenticate-azure-cli-interactively) command.

    ```azurecli
    az login --tenant $TENANT_A_ID
    ```
3. Ensure you're working with the correct subscription in *Tenant A* using the [`az account set`](/en-us/cli/azure/account#az-account-set) command.

    ```azurecli
    az account set --subscription $TENANT_A_SUBSCRIPTION_ID
    ```
4. Get the credentials for the AKS cluster in *Tenant A* using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
    ```

### Create Kubernetes resources to send messages to Azure Service Bus queue

1. Create a new Kubernetes ServiceAccount in the `default` namespace and pass in the client ID of your managed identity in *Tenant B* to the `kubectl apply` command. The client ID is used to authenticate the app in *Tenant A* to the Azure Service Bus in *Tenant B*.

    ```azurecli
    kubectl apply -f - <<EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      annotations:
        azure.workload.identity/client-id: $CLIENT_ID
      name: myserviceaccount
    EOF
    ```
2. Create a new Kubernetes Job in the `default` namespace to send 100 messages to your Azure Service Bus queue. The Pod template is configured to use workload identity and the service account you created in the previous step. Also note that the `AZURE_TENANT_ID` environment variable is set to the tenant ID of *Tenant B*. This is required as workload identity defaults to the tenant of the AKS cluster, so you need to explicitly set the tenant ID of *Tenant B*.

    ```azurecli
    kubectl apply -f - <<EOF
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: myproducer
    spec:
      template:
        metadata:
          labels:
            azure.workload.identity/use: "true"
        spec:
          serviceAccountName: myserviceaccount
          containers:
          - image: ghcr.io/azure-samples/aks-app-samples/servicebusdemo:latest
            name: myproducer
            resources: {}
            env:
            - name: OPERATION_MODE
              value: "producer"
            - name: MESSAGE_COUNT
              value: "100"
            - name: AZURE_SERVICEBUS_QUEUE_NAME
              value: myqueue
            - name: AZURE_SERVICEBUS_HOSTNAME
              value: $SERVICEBUS_HOSTNAME
            - name: AZURE_TENANT_ID
              value: $TENANT_B_ID
          restartPolicy: Never
    EOF
    ```

## Verify the deployment

1. Verify that the pod is correctly configured to interact with the Azure Service Bus queue in *Tenant B* by checking the status of the pod using the `kubectl describe pod` command.

    ```azurecli
    # Get the dynamically generated pod name
    POD_NAME=$(kubectl get po --selector job-name=myproducer -o jsonpath='{.items[0].metadata.name}')
    
    # Verify the tenant ID environment variable is set for Tenant B
    kubectl describe pod $POD_NAME | grep AZURE_TENANT_ID
    ```
2. Check the logs of the pod to see if the application was able to send messages across tenants using the `kubectl logs` command.

    ```azurecli
    kubectl logs $POD_NAME
    ```

    Your output should look similar to the following example output:

    ```output
    ...
    Adding message to batch: Hello World!
    Adding message to batch: Hello World!
    Adding message to batch: Hello World!
    Sent 100 messages
    ```

Note

As an extra verification step, you can go to the [Azure portal](https://portal.azure.com) and navigate to the Azure Service Bus queue in *Tenant B* to view the messages that were sent in the Service Bus Explorer.

## Clean up resources

After you verify that the deployment is successful, you can clean up the resources to avoid incurring Azure costs.

### Delete resources in Tenant A

1. Log in to your *Tenant A* subscription using the [`az login`](/en-us/cli/azure/authenticate-azure-cli-interactively) command.

    ```azurecli
    az login --tenant $TENANT_A_ID
    ```
2. Ensure you're working with the correct subscription in *Tenant A* using the [`az account set`](/en-us/cli/azure/account#az-account-set) command.

    ```azurecli
    az account set --subscription $TENANT_A_SUBSCRIPTION_ID
    ```
3. Delete the Azure resource group and all resources in it using the [`az group delete`](/en-us/cli/azure/group#az-group-delete) command.

    ```azurecli
    az group delete --name $RESOURCE_GROUP --yes --no-wait
    ```

### Delete resources in Tenant B

1. Log in to your *Tenant B* subscription using the [`az login`](/en-us/cli/azure/authenticate-azure-cli-interactively) command.

    ```azurecli
    az login --tenant $TENANT_B_ID
    ```
2. Ensure you're working with the correct subscription in *Tenant B* using the [`az account set`](/en-us/cli/azure/account#az-account-set) command.

    ```azurecli
    az account set --subscription $TENANT_B_SUBSCRIPTION_ID
    ```
3. Delete the Azure resource group and all resources in it using the [`az group delete`](/en-us/cli/azure/group#az-group-delete) command.

    ```azurecli
    az group delete --name $RESOURCE_GROUP --yes --no-wait
    ```