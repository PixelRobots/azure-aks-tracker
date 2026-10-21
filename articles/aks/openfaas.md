---
layout: Conceptual
title: Use OpenFaaS on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/openfaas
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
description: Learn how to deploy and use OpenFaaS on an Azure Kubernetes Service (AKS) cluster to build serverless functions with containers.
author: schaffererin
ms.topic: concept-article
ms.date: 2023-08-29T00:00:00.0000000Z
ms.subservice: aks-developer
ms.author: schaffererin
ms.custom: mvc, devx-track-azurecli
locale: en-us
document_id: 3fe3d9d0-e1ce-8596-cd7e-97dbbb92575e
document_version_independent_id: 609c4576-7965-a3e8-1844-0a192eaafcfb
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/openfaas.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/openfaas
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/openfaas.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/540ac133-a371-4dbb-8f94-28d6cc77a70b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/60bfc045-f127-4841-9d00-ea35495a5800
platformId: 47538ce7-a5a0-954e-6609-5109331a031d
---

# Use OpenFaaS on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

[OpenFaaS](https://www.openfaas.com/) is a framework that uses containers to build serverless functions. As an open source project, it has gained large-scale adoption within the community. This document details installing and using OpenFaas on an Azure Kubernetes Service (AKS) cluster.

## Before you begin

- This article assumes a basic understanding of Kubernetes concepts. For more information, see [Kubernetes core concepts for Azure Kubernetes Service (AKS)](concepts-clusters-workloads).
- You need an active Azure subscription. If you don't have one, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- You need an AKS cluster. If you don't have an existing cluster, you can create one using the [Azure CLI](learn/quick-kubernetes-deploy-cli), [Azure PowerShell](learn/quick-kubernetes-deploy-powershell), or [Azure portal](learn/quick-kubernetes-deploy-portal).
- You need to install the OpenFaaS CLI. For installation options, see the [OpenFaaS CLI documentation](https://github.com/openfaas/faas-cli).

## Add the OpenFaaS helm chart repo

1. Navigate to [Azure Cloud Shell](https://shell.azure.com).
2. Add the OpenFaaS helm chart repo and update to the latest version using the following `helm` commands.

    ```console
    helm repo add openfaas https://openfaas.github.io/faas-netes/
    helm repo update
    ```

## Deploy OpenFaaS

As a good practice, OpenFaaS and OpenFaaS functions should be stored in their own Kubernetes namespace.

1. Create a namespace for the OpenFaaS system and functions using the `kubectl apply` command.

    ```console
    kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml
    ```
2. Generate a password for the OpenFaaS UI Portal and REST API using the following commands. The helm chart uses this password to enable basic authentication on the OpenFaaS Gateway, which is exposed to the Internet through a cloud LoadBalancer.

    ```console
    # generate a random password
    PASSWORD=$(head -c 12 /dev/urandom | shasum| cut -d' ' -f1)
    
    kubectl -n openfaas create secret generic basic-auth \
    --from-literal=basic-auth-user=admin \
    --from-literal=basic-auth-password="$PASSWORD"
    ```

    Important

    Using a username and password for authentication is an insecure pattern. If you have an OpenFaaS enterprise license, we recommend using [Identity and Access Management (IAM) for OpenFaaS](https://www.openfaas.com/blog/walkthrough-iam-for-openfaas/) instead.
3. Get the value for your password using the following `echo` command.

    ```console
    echo $PASSWORD
    ```
4. Deploy OpenFaaS into your AKS cluster using the `helm upgrade` command.

    ```console
    helm upgrade openfaas --install openfaas/openfaas \
        --namespace openfaas  \
        --set basic_auth=true \
        --set functionNamespace=openfaas-fn \
        --set serviceType=LoadBalancer
    ```

    Your output should look similar to the following condensed example output:

    ```output
    NAME: openfaas
    LAST DEPLOYED: Tue Aug 29 08:26:11 2023
    NAMESPACE: openfaas
    STATUS: deployed
    ...
    NOTES:
    To verify that openfaas has started, run:
    
    kubectl --namespace=openfaas get deployments -l "release=openfaas, app=openfaas"
    ...
    ```
5. A public IP address is created for accessing the OpenFaaS gateway. Get the IP address using the [`kubectl get service`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command.

    ```console
    kubectl get service -l component=gateway --namespace openfaas
    ```

    Your output should look similar to the following example output:

    ```output
    NAME               TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)          AGE
    gateway            ClusterIP      10.0.156.194   <none>         8080/TCP         7m
    gateway-external   LoadBalancer   10.0.28.18     52.186.64.52   8080:30800/TCP   7m
    ```
6. Test the OpenFaaS system by browsing to the external IP address on port 8080, `http://52.186.64.52:8080` in this example, where you're prompted to log in. The default user is `admin` and your password can be retrieved using `echo $PASSWORD`.

    ![Screenshot of OpenFaaS UI.](media/container-service-serverless/openfaas.png)
7. Set `$OPENFAAS_URL` to the URL of the external IP address on port 8080 and log in with the Azure CLI using the following commands.

    ```console
    export OPENFAAS_URL=http://52.186.64.52:8080
    echo -n $PASSWORD | ./faas-cli login -g $OPENFAAS_URL -u admin --password-stdin
    ```

## Create first function

1. Navigate to the OpenFaaS system using your OpenFaaS URL.
2. Create a function using the OpenFaas portal by selecting **Deploy A New Function** and search for **Figlet**.
3. Select the **Figlet** function, and then select **Deploy**.

    ![Screenshot shows the Deploy A New Function dialog box with the text Figlet on the search line.](media/container-service-serverless/figlet.png)
4. Invoke the function using the following `curl` command. Make sure you replace the IP address in the following example with your OpenFaaS gateway address.

    ```console
    curl -X POST http://52.186.64.52:8080/function/figlet -d "Hello Azure"
    ```

    Your output should look similar to the following example output:

    ```output
     _   _      _ _            _
    | | | | ___| | | ___      / \    _____   _ _ __ ___
    | |_| |/ _ \ | |/ _ \    / _ \  |_  / | | | '__/ _ \
    |  _  |  __/ | | (_) |  / ___ \  / /| |_| | | |  __/
    |_| |_|\___|_|_|\___/  /_/   \_\/___|\__,_|_|  \___|
    ```

## Create second function

### Configure your Azure Cosmos DB instance

1. Navigate to [Azure Cloud Shell](https://shell.azure.com).
2. Create a new resource group for the Azure Cosmos DB instance using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    az group create --name serverless-backing --location eastus
    ```
3. Deploy an Azure Cosmos DB instance of kind `MongoDB` using the [`az cosmosdb create`](/en-us/cli/azure/cosmosdb#az-cosmosdb-create) command. Replace `openfaas-cosmos` with your own unique instance name.

    ```azurecli
    az cosmosdb create --resource-group serverless-backing --name openfaas-cosmos --kind MongoDB
    ```
4. Get the Azure Cosmos DB database connection string and store it in a variable using the [`az cosmosdb keys list`](/en-us/cli/azure/cosmosdb/keys#az-cosmosdb-keys-list) command. Make sure you replace the value for the `--resource-group` argument with the name of your resource group, and the `--name` argument with the name of your Azure Cosmos DB instance.

    ```azurecli
    COSMOS=$(az cosmosdb keys list \
      --type connection-strings \
      --resource-group serverless-backing \
      --name openfaas-cosmos \
      --output tsv)
    ```
5. Populate the Azure Cosmos DB with test data by creating a file named `plans.json` and copying in the following json.

    ```json
    {
        "name" : "two_person",
        "friendlyName" : "Two Person Plan",
        "portionSize" : "1-2 Person",
        "mealsPerWeek" : "3 Unique meals per week",
        "price" : 72,
        "description" : "Our basic plan, delivering 3 meals per week, which will feed 1-2 people.",
        "__v" : 0
    }
    ```

### Create the function

1. Install the MongoDB tools. The following example command installs these tools using brew. For more installation options, see the [MongoDB documentation](https://docs.mongodb.com/manual/installation/).

    ```console
    brew install mongodb
    ```
2. Load the Azure Cosmos DB instance with data using the *mongoimport* tool.

    ```console
    mongoimport --uri=$COSMOS -c plans < plans.json
    ```

    Your output should look similar to the following example output:

    ```output
    2018-02-19T14:42:14.313+0000    connected to: localhost
    2018-02-19T14:42:14.918+0000    imported 1 document
    ```
3. Create the function using the `faas-cli deploy` command. Make sure you update the value of the `-g` argument with your OpenFaaS gateway address.

    ```console
    faas-cli deploy -g http://52.186.64.52:8080 --image=shanepeckham/openfaascosmos --name=cosmos-query --env=NODE_ENV=$COSMOS
    ```

    Once deployed, your output should look similar to the following example output:

    ```output
    Deployed. 202 Accepted.
    URL: http://52.186.64.52:8080/function/cosmos-query
    ```
4. Test the function using the following `curl` command. Make sure you update the IP address with the OpenFaaS gateway address.

    ```console
    curl -s http://52.186.64.52:8080/function/cosmos-query
    ```

    Your output should look similar to the following example output:

    ```output
    [{"ID":"","Name":"two_person","FriendlyName":"","PortionSize":"","MealsPerWeek":"","Price":72,"Description":"Our basic plan, delivering 3 meals per week, which will feed 1-2 people."}]
    ```

    Note

    You can also test the function within the OpenFaaS UI:

    ![Screenshot of OpenFaas UI.](media/container-service-serverless/openfaasui.png)