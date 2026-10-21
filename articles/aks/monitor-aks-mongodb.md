---
layout: Conceptual
title: Monitoring for MongoDB cluster on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/monitor-aks-mongodb
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
zone_pivot_group_filename: zone-pivots/azure-aks/zone-pivot-groups.json
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: In this article, you learn how to monitor a MongoDB cluster on Azure Kubernetes Service (AKS).
ms.topic: how-to
ms.date: 2025-01-07T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
zone_pivot_groups: azure-cli-or-terraform
ms.custom: stateful-workloads, aks-data-messaging
locale: en-us
document_id: e32cfb4e-1d0c-9854-d3f9-23330d9efde6
document_version_independent_id: 42ff9073-d86e-9b7a-2b09-67e2e9a878bc
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/monitor-aks-mongodb.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/monitor-aks-mongodb
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/monitor-aks-mongodb.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 82a23c07-5df2-9e2d-7d36-6a246595395e
---

# Monitoring for MongoDB cluster on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to monitor a MongoDB cluster on Azure Kubernetes Service (AKS) using [Percona Monitoring and Management (PMM)](https://docs.percona.com/percona-operator-for-mongodb/monitoring.html). Monitoring is essential for ensuring the health and performance of your MongoDB cluster. By monitoring key metrics, you can identify issues early and take corrective actions to prevent downtime and data loss.

## Set up Percona Monitoring and Management (PMM) for MongoDB

PMM operates as a client/server application, consisting of a [PMM Server](https://docs.percona.com/percona-monitoring-and-management/details/architecture.html#pmm-server) and multiple [PMM Clients](https://docs.percona.com/percona-monitoring-and-management/details/architecture.html#pmm-client) installed on each node of the database you want to monitor. The PMM Clients gather essential metrics and transmit this data to the PMM Server. You can then connect to the PMM Server to view database metrics across various dashboards.

### Enable monitoring Percona Server for MongoDB with PMM

1. To enable monitoring for Percona Server for MongoDB, you need to make sure that the `pmm.enabled` field is set to `true` in the PerconaServerMongoDB custom resource. You can check this setting using the `kubectl describe` command.

    ```bash
    kubectl describe PerconaServerMongoDB ${AKS_MONGODB_CLUSTER_NAME} -n ${AKS_MONGODB_NAMESPACE}
    ```

    Example output:

    ```output
    Name:         cluster-aks-mongodb
    Namespace:    mongodb
    ...
    Spec:
      ...
      Pmm:
        Enabled:      true
        Image:        <your-acr-name>.azurecr.io/pmm-client:2.41.2
        Server Host:  monitoring-service
      ...
    ```
2. If the `pmm.enabled` field is set to `false`, you can enable it using the `kubectl patch` command.

    ```bash
    kubectl patch PerconaServerMongoDB ${AKS_MONGODB_CLUSTER_NAME} -n ${AKS_MONGODB_NAMESPACE} --type='merge' -p '{"spec":{"pmm":{"enabled":true}}}'
    ```

### Create a node pool for PMM server

::: zone pivot="azure-cli"

Create a dedicated node pool for the PMM server using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command.

```azurecli
az aks nodepool add \
--resource-group $MY_RESOURCE_GROUP_NAME \
--cluster-name $MY_CLUSTER_NAME \
--name pmmsrvpool \
--node-vm-size Standard_DS4_v2 \
--node-count 3 \
--zones 1 2 3 \
--mode User \
--output table
```

::: zone-end

::: zone pivot="terraform"

Create a dedicated node pool for the PMM server using terraform.

1. Run the following command to update the `mongodb.tfvars` file created earlier with the following configuration:

    ```bash
    sed -i '/mongodbserver = {/,/}/s/^\( *}\)/  }, \
    pmmserver = {\
      name       = "pmmsrvpool" \
      vm_size    = "Standard_D2ds_v4" \
      node_count = 3 \
      zones      = [1, 2, 3] \
      os_type    = "Linux" \
    }/' mongodb.tfvars
    ```
2. Apply the terraform configuration to the target resource.

    ```bash
    terraform fmt
    terraform apply -var-file="mongodb.tfvars" -target module.default
    ```

::: zone-end

## Install PMM server

1. Add and update the Percona Helm repository using the `helm repo add` and `helm repo update` commands.

    ```bash
    helm repo add percona https://percona.github.io/percona-helm-charts/
    helm repo update
    ```
2. Install the PMM server using the `helm install` command.

    ```bash
    helm install pmm --namespace mongodb \
    --set nodeSelector."kubernetes\.azure\.com/agentpool"="pmmsrvpool" \
    --set service.type="LoadBalancer" \
    --version 1.3.13 \
    percona/pmm
    ```
3. Get the external IP address of the PMM server using the `kubectl get svc` command.

    ```bash
    export SERVICE_IP=$(kubectl get svc --namespace mongodb monitoring-service -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
      echo https://$SERVICE_IP:
    ```
4. Get the password for the admin user using the `kubectl get secret` command.

    ```bash
      export ADMIN_PASS=$(kubectl get secret pmm-secret --namespace mongodb -o jsonpath='{.data.PMM_ADMIN_PASSWORD}' | base64 --decode)      
    ```
5. You can now access the PMM server by using the external IP address and the "admin" user password. You can also access the PMM server on your local machine using the `kubectl port-forward` command.

    ```bash
    kubectl port-forward svc/monitoring-service -n mongodb 8080:80
    ```
6. Once port forwarding is enabled, you can access the PMM server by navigating to `http://localhost:8080`.

## Configure PMM server

1. Access the PMM server using the admin user and the password you obtained earlier.
2. From the side menu, select **Configuration** &gt; **API keys**.

    ![Screenshot of a web page showing the PMM Mongodb dashboard menu.](media/monitor-aks-mongodb/pmm-api-keys-menu.png)
3. On the *Configuration* page, select **Add API Key**.
4. Enter the following information:

    - Key name (you can give any desired name)
    - Select the Admin role from the drop-down
    - Enter a value in the Time to live text box (hover on the tooltip for more information)

    ![Screenshot of a web page showing the PMM Mongodb dashboard with API key generated.](media/monitor-aks-mongodb/pmm-api-key-generated.png)
5. Select **Add**.
6. Copy your key from the *API Key Created window* and export it to the environment variable as shown below.

    ```bash
    export API_KEY="Paste your API Key here"
    ```

### Set API key as secret and refresh ExternalSecret resource with the new secret

::: zone pivot="azure-cli"

1. Set the API key as a secret in Azure Key Vault using the following command.

    ```azurecli
    az keyvault secret set --vault-name $MY_KEYVAULT_NAME --name PMM-SERVER-API-KEY --value $API_KEY --output none
    ```

::: zone-end

::: zone pivot="terraform"

1. Run the following command to update the `mongodb.tfvars` file created earlier and apply the terraform configuration to the target resource with the following commands: 

    ```bash
    sed -i "/mongodb_kv_secrets = {/,/^ *}/s/\(PMM-SERVER-API-KEY *= *\"\)[^\"]*\"/\1$API_KEY\"/" mongodb.tfvars
    
    terraform fmt
    
    terraform apply -var-file="mongodb.tfvars" -target module.mongodb[0].azurerm_key_vault_secret.this
    ```

::: zone-end

1. Refresh the secret in the ExternalSecret resource with the new secret key using the `kubectl annotate` command.

    ```bash
    kubectl annotate es ${AKS_MONGODB_SECRETS_NAME} force-sync=$(date +%s) --overwrite -n ${AKS_MONGODB_NAMESPACE}
    ```

## Test PMM server

Once you configure the PMM server, you can generate test data using Locust, as described in [Validate resiliency of MongoDB cluster on Azure Kubernetes Service (AKS)](resiliency-mongodb-cluster). After generating test data, you can monitor the performance of your MongoDB cluster on the PMM server.

![Screenshot of a web page showing the PMM Mongodb dashboard.](media/monitor-aks-mongodb/pmm-mongodb-1.png)

![Screenshot of another web page showing the PMM Mongodb dashboard.](media/monitor-aks-mongodb/pmm-mongodb-2.png)