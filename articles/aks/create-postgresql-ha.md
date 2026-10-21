---
layout: Conceptual
title: Create infrastructure for deploying a PostgreSQL database on AKS - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/create-postgresql-ha
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
description: Create the infrastructure needed to deploy a highly available PostgreSQL cluster on Azure Kubernetes Service (AKS) using Azure CLI and the CloudNativePG operator.
ms.topic: how-to
ms.date: 2025-06-18T00:00:00.0000000Z
author: KenKilty
ms.author: kkilty
ms.custom: innovation-engine, aks-related-content, stateful-workloads
locale: en-us
document_id: 37dd3268-f50b-d5da-27a8-e8c2f719a3d6
document_version_independent_id: d15e8a35-b727-4489-96c1-3447f5cdbec0
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/create-postgresql-ha.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/create-postgresql-ha
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/create-postgresql-ha.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/982661b3-cc41-45b1-b21d-18b4b6937344
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/bbee35d0-ba85-4062-b9c2-388c328eb4fa
platformId: b8624840-6527-06ed-a159-270df2ee6d20
---

# Create infrastructure for deploying a PostgreSQL database on AKS - Azure Kubernetes Service | Microsoft Learn

In this article, you create the infrastructure resources needed to deploy a highly available PostgreSQL database on AKS using the [CloudNativePG (CNPG)](https://cloudnative-pg.io/) operator.

Important

Open-source software is mentioned throughout AKS documentation and samples. Software that you deploy is excluded from AKS service-level agreements, limited warranty, and Azure support. As you use open-source technology alongside AKS, consult the support options available from the respective communities and project maintainers to develop a plan.

Microsoft takes responsibility for building the open-source packages that we deploy on AKS. That responsibility includes having complete ownership of the build, scan, sign, validate, and hotfix process, along with control over the binaries in container images. For more information, see [Vulnerability management for AKS](concepts-vulnerability-management#aks-container-images) and [AKS support coverage](support-policies#aks-support-coverage).

## Before you begin

- Review the deployment overview and make sure you meet all the prerequisites in [How to deploy a highly available PostgreSQL database on AKS with Azure CLI](postgresql-ha-overview).
- Set environment variables for use throughout this guide.
- Install the required extensions.

## Set environment variables

Set the following environment variables for use throughout this guide:

```bash
export SUFFIX=$(cat /dev/urandom | LC_ALL=C tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
export LOCAL_NAME="cnpg"
export TAGS="owner=user"
export RESOURCE_GROUP_NAME="rg-${LOCAL_NAME}-${SUFFIX}"
export PRIMARY_CLUSTER_REGION="canadacentral"
export AKS_PRIMARY_CLUSTER_NAME="aks-primary-${LOCAL_NAME}-${SUFFIX}"
export AKS_PRIMARY_MANAGED_RG_NAME="rg-${LOCAL_NAME}-primary-aksmanaged-${SUFFIX}"
export AKS_PRIMARY_CLUSTER_FED_CREDENTIAL_NAME="pg-primary-fedcred1-${LOCAL_NAME}-${SUFFIX}"
export AKS_PRIMARY_CLUSTER_PG_DNSPREFIX=$(echo $(echo "a$(openssl rand -hex 5 | cut -c1-11)"))
export AKS_UAMI_CLUSTER_IDENTITY_NAME="mi-aks-${LOCAL_NAME}-${SUFFIX}"
export AKS_CLUSTER_VERSION="1.32"
export PG_NAMESPACE="cnpg-database"
export PG_SYSTEM_NAMESPACE="cnpg-system"
export PG_PRIMARY_CLUSTER_NAME="pg-primary-${LOCAL_NAME}-${SUFFIX}"
export PG_PRIMARY_STORAGE_ACCOUNT_NAME="hacnpgpsa${SUFFIX}"
export PG_STORAGE_BACKUP_CONTAINER_NAME="backups"
export MY_PUBLIC_CLIENT_IP=$(dig +short myip.opendns.com @resolver3.opendns.com)
```

## Install required extensions

Install the extensions needed for Kubernetes integration and monitoring:

```bash
az extension add --upgrade --name k8s-extension --yes
az extension add --upgrade --name amg --yes
```

As a prerequisite for using `kubectl`, you need to first install [Krew](https://krew.sigs.k8s.io/), followed by the installation of the [CNPG plugin](https://cloudnative-pg.io/documentation/current/kubectl-plugin/#using-krew). These installations enable the management of the PostgreSQL operator using the subsequent commands.

```bash
(
    set -x; cd "$(mktemp -d)" &&
    OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
    KREW="krew-${OS}_${ARCH}" &&
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
    tar zxvf "${KREW}.tar.gz" &&
    ./"${KREW}" install krew
)

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

kubectl krew install cnpg
```

## Create a resource group

Create a resource group to hold the resources you create in this guide using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

```bash
az group create \
    --name $RESOURCE_GROUP_NAME \
    --location $PRIMARY_CLUSTER_REGION \
    --tags $TAGS \
    --query 'properties.provisioningState' \
    --output tsv
```

## Create a user-assigned managed identity

In this section, you create a user-assigned managed identity (UAMI) to allow the CNPG PostgreSQL to use an AKS workload identity to access Azure Blob Storage. This configuration allows the PostgreSQL cluster on AKS to connect to Azure Blob Storage without a secret.

1. Create a user-assigned managed identity using the [`az identity create`](/en-us/cli/azure/identity#az-identity-create) command.

    ```bash
    AKS_UAMI_WI_IDENTITY=$(az identity create \
        --name $AKS_UAMI_CLUSTER_IDENTITY_NAME \
        --resource-group $RESOURCE_GROUP_NAME \
        --location $PRIMARY_CLUSTER_REGION \
        --output json)
    ```
2. Enable AKS workload identity and generate a service account to use later in this guide using the following commands:

    ```bash
    export AKS_UAMI_WORKLOAD_OBJECTID=$( \
        echo "${AKS_UAMI_WI_IDENTITY}" | jq -r '.principalId')
    export AKS_UAMI_WORKLOAD_RESOURCEID=$( \
        echo "${AKS_UAMI_WI_IDENTITY}" | jq -r '.id')
    export AKS_UAMI_WORKLOAD_CLIENTID=$( \
        echo "${AKS_UAMI_WI_IDENTITY}" | jq -r '.clientId')
    
    echo "ObjectId: $AKS_UAMI_WORKLOAD_OBJECTID"
    echo "ResourceId: $AKS_UAMI_WORKLOAD_RESOURCEID"
    echo "ClientId: $AKS_UAMI_WORKLOAD_CLIENTID"
    ```

The object ID is a unique identifier for the client ID (also known as the application ID) that uniquely identifies a security principal of type *Application* within the Microsoft Entra ID tenant. The resource ID is a unique identifier to manage and locate a resource in Azure. These values are required to enabled AKS workload identity.

The CNPG operator automatically generates a service account called *postgres* that you use later in the guide to create a federated credential that enables OAuth access from PostgreSQL to Azure Storage.

## Create a storage account in the primary region

1. Create an object storage account to store PostgreSQL backups in the primary region using the [`az storage account create`](/en-us/cli/azure/storage/account#az-storage-account-create) command.

    ```bash
    az storage account create \
        --name $PG_PRIMARY_STORAGE_ACCOUNT_NAME \
        --resource-group $RESOURCE_GROUP_NAME \
        --location $PRIMARY_CLUSTER_REGION \
        --sku Standard_ZRS \
        --kind StorageV2 \
        --query 'provisioningState' \
        --output tsv
    ```
2. Create the storage container to store the Write Ahead Logs (WAL) and regular PostgreSQL on-demand and scheduled backups using the [`az storage container create`](/en-us/cli/azure/storage/container#az-storage-container-create) command.

    ```bash
    az storage container create \
        --name $PG_STORAGE_BACKUP_CONTAINER_NAME \
        --account-name $PG_PRIMARY_STORAGE_ACCOUNT_NAME \
        --auth-mode login
    ```

    Example output:

    ```output
    {
        "created": true
    }
    ```

    Note

    If you encounter the error message: `The request may be blocked by network rules of storage account. Please check network rule set using 'az storage account show -n accountname --query networkRuleSet'. If you want to change the default action to apply when no rule matches, please use 'az storage account update'`. Make sure to verify user permissions for Azure Blob Storage and, if **necessary**, elevate your role to `Storage Blob Data Owner` using the commands provided and after retry the [`az storage container create`](/en-us/cli/azure/storage/container#az-storage-container-create) command.

    ```bash
    export USER_ID=$(az ad signed-in-user show --query id --output tsv)
    
    export STORAGE_ACCOUNT_PRIMARY_RESOURCE_ID=$(az storage account show \
        --name $PG_PRIMARY_STORAGE_ACCOUNT_NAME \
        --resource-group $RESOURCE_GROUP_NAME \
        --query "id" \
        --output tsv)
    
    az role assignment list --scope $STORAGE_ACCOUNT_PRIMARY_RESOURCE_ID --output table
    
    az role assignment create \
        --assignee-object-id $USER_ID \
        --assignee-principal-type User \
        --scope $STORAGE_ACCOUNT_PRIMARY_RESOURCE_ID \
        --role "Storage Blob Data Owner" \
        --output tsv
    ```

## Assign RBAC to storage accounts

To enable backups, the PostgreSQL cluster needs to read and write to an object store. The PostgreSQL cluster running on AKS uses a workload identity to access the storage account via the CNPG operator configuration parameter [`inheritFromAzureAD`](https://cloudnative-pg.io/documentation/1.23/appendixes/object_stores/#azure-blob-storage).

1. Get the primary resource ID for the storage account using the [`az storage account show`](/en-us/cli/azure/storage/account#az-storage-account-show) command.

    ```bash
    export STORAGE_ACCOUNT_PRIMARY_RESOURCE_ID=$(az storage account show \
        --name $PG_PRIMARY_STORAGE_ACCOUNT_NAME \
        --resource-group $RESOURCE_GROUP_NAME \
        --query "id" \
        --output tsv)
    
    echo $STORAGE_ACCOUNT_PRIMARY_RESOURCE_ID
    ```
2. Assign the "Storage Blob Data Contributor" Azure built-in role to the object ID with the storage account resource ID scope for the UAMI associated with the managed identity for each AKS cluster using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command.

    ```bash
    az role assignment create \
        --role "Storage Blob Data Contributor" \
        --assignee-object-id $AKS_UAMI_WORKLOAD_OBJECTID \
        --assignee-principal-type ServicePrincipal \
        --scope $STORAGE_ACCOUNT_PRIMARY_RESOURCE_ID \
        --query "id" \
        --output tsv
    ```

## Set up monitoring infrastructure

In this section, you deploy an instance of Azure Managed Grafana, an Azure Monitor workspace, and an Azure Monitor Log Analytics workspace to enable monitoring of the PostgreSQL cluster. You also store references to the created monitoring infrastructure to use as input during the AKS cluster creation process later in the guide. This section might take some time to complete.

Note

Azure Managed Grafana instances and AKS clusters are billed independently. For more pricing information, see [Azure Managed Grafana pricing](https://azure.microsoft.com/pricing/details/managed-grafana/).

1. Create an Azure Managed Grafana instance using the [`az grafana create`](/en-us/cli/azure/grafana#az-grafana-create) command.

    ```bash
    export GRAFANA_PRIMARY="grafana-${LOCAL_NAME}-${SUFFIX}"
    
    export GRAFANA_RESOURCE_ID=$(az grafana create \
        --resource-group $RESOURCE_GROUP_NAME \
        --name $GRAFANA_PRIMARY \
        --location $PRIMARY_CLUSTER_REGION \
        --zone-redundancy Enabled \
        --tags $TAGS \
        --query "id" \
        --output tsv)
    
    echo $GRAFANA_RESOURCE_ID
    ```
2. Create an Azure Monitor workspace using the [`az monitor account create`](/en-us/cli/azure/monitor/account#az-monitor-account-create) command.

    ```bash
    export AMW_PRIMARY="amw-${LOCAL_NAME}-${SUFFIX}"
    
    export AMW_RESOURCE_ID=$(az monitor account create \
        --name $AMW_PRIMARY \
        --resource-group $RESOURCE_GROUP_NAME \
        --location $PRIMARY_CLUSTER_REGION \
        --tags $TAGS \
        --query "id" \
        --output tsv)
    
    echo $AMW_RESOURCE_ID
    ```
3. Create an Azure Monitor Log Analytics workspace using the [`az monitor log-analytics workspace create`](/en-us/cli/azure/monitor/log-analytics/workspace#az-monitor-log-analytics-workspace-create) command.

    ```bash
    export ALA_PRIMARY="ala-${LOCAL_NAME}-${SUFFIX}"
    
    export ALA_RESOURCE_ID=$(az monitor log-analytics workspace create \
        --resource-group $RESOURCE_GROUP_NAME \
        --workspace-name $ALA_PRIMARY \
        --location $PRIMARY_CLUSTER_REGION \
        --query "id" \
        --output tsv)
    
    echo $ALA_RESOURCE_ID
    ```

## Create the AKS cluster to host the PostgreSQL cluster

In this section, you create a multizone AKS cluster with a system node pool. The AKS cluster hosts the PostgreSQL cluster primary replica and two standby replicas, each aligned to a different availability zone to enable zone redundancy.

You also add a user node pool to the AKS cluster to host the PostgreSQL cluster. Using a separate node pool allows for control over the Azure VM SKUs used for PostgreSQL and enables the AKS system pool to optimize performance and costs. You apply a label to the user node pool that you can reference for node selection when deploying the CNPG operator later in this guide. This section might take some time to complete.

Important

If you opt to use local NVMe as your PostgreSQL storage in the later parts of this guide, you need to choose a VM SKU that supports local NVMe drives, for example, [Storage optimized VM SKUs](/en-us/azure/virtual-machines/sizes/overview#storage-optimized) or [GPU accelerated VM SKUs](/en-us/azure/virtual-machines/sizes/overview#gpu-accelerated). Update `$USER_NODE_POOL_VMSKU` accordingly.

1. Create an AKS cluster using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command.

    ```bash
    export SYSTEM_NODE_POOL_VMSKU="standard_d2s_v3"
    export USER_NODE_POOL_NAME="postgres"
    export USER_NODE_POOL_VMSKU="standard_d4s_v3"
    
    az aks create \
        --name $AKS_PRIMARY_CLUSTER_NAME \
        --tags $TAGS \
        --resource-group $RESOURCE_GROUP_NAME \
        --location $PRIMARY_CLUSTER_REGION \
        --generate-ssh-keys \
        --node-resource-group $AKS_PRIMARY_MANAGED_RG_NAME \
        --enable-managed-identity \
        --assign-identity $AKS_UAMI_WORKLOAD_RESOURCEID \
        --network-plugin azure \
        --network-plugin-mode overlay \
        --network-dataplane cilium \
        --nodepool-name systempool \
        --enable-oidc-issuer \
        --enable-workload-identity \
        --enable-cluster-autoscaler \
        --min-count 2 \
        --max-count 3 \
        --node-vm-size $SYSTEM_NODE_POOL_VMSKU \
        --enable-azure-monitor-metrics \
        --azure-monitor-workspace-resource-id $AMW_RESOURCE_ID \
        --grafana-resource-id $GRAFANA_RESOURCE_ID \
        --api-server-authorized-ip-ranges $MY_PUBLIC_CLIENT_IP \
        --tier standard \
        --kubernetes-version $AKS_CLUSTER_VERSION \
        --zones 1 2 3 \
        --output table
    ```
2. Wait for the initial cluster operation to complete using the [`az aks wait`](/en-us/cli/azure/aks#az-aks-wait) command so additional updates, such as adding the user node pool, don’t collide with an in-progress managed-cluster update:

    ```bash
    az aks wait \
        --resource-group $RESOURCE_GROUP_NAME \
        --name $AKS_PRIMARY_CLUSTER_NAME \
        --created
    ```
3. Add a user node pool to the AKS cluster using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command.

    ```bash
    az aks nodepool add \
        --resource-group $RESOURCE_GROUP_NAME \
        --cluster-name $AKS_PRIMARY_CLUSTER_NAME \
        --name $USER_NODE_POOL_NAME \
        --enable-cluster-autoscaler \
        --min-count 3 \
        --max-count 6 \
        --node-vm-size $USER_NODE_POOL_VMSKU \
        --zones 1 2 3 \
        --labels workload=postgres \
        --output table
    ```

## Connect to the AKS cluster and create namespaces

In this section, you get the AKS cluster credentials, which serve as the keys that allow you to authenticate and interact with the cluster. Once connected, you create two namespaces: one for the CNPG controller manager services and one for the PostgreSQL cluster and its related services.

1. Get the AKS cluster credentials using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```bash
    az aks get-credentials \
        --resource-group $RESOURCE_GROUP_NAME \
        --name $AKS_PRIMARY_CLUSTER_NAME \
        --output none
    ```
2. Create the namespace for the CNPG controller manager services, the PostgreSQL cluster, and its related services by using the [`kubectl create namespace`](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_create/kubectl_create_namespace/) command.

    ```bash
    kubectl create namespace $PG_NAMESPACE --context $AKS_PRIMARY_CLUSTER_NAME
    kubectl create namespace $PG_SYSTEM_NAMESPACE --context $AKS_PRIMARY_CLUSTER_NAME
    ```

You can now define another environment variable based on your desired storage option, which you reference later in the guide when deploying PostgreSQL.

# [Premium SSD](#tab/pv1)
You can reference the default preinstalled Premium SSD Azure Disks CSI driver storage class:

```bash
export POSTGRES_STORAGE_CLASS="managed-csi-premium"
```

# [Premium SSD v2](#tab/pv2)
To use Premium SSD v2, you can create a custom storage class.

Define a new CSI driver storage class:

```bash
cat <<EOF | kubectl apply --context $AKS_PRIMARY_CLUSTER_NAME -n $PG_NAMESPACE -v 9 -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: premium2-disk-sc
parameters:
  cachingMode: None
  skuName: PremiumV2_LRS
  DiskIOPSReadWrite: "3500"
  DiskMBpsReadWrite: "125"
provisioner: disk.csi.azure.com
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
EOF

export POSTGRES_STORAGE_CLASS="premium2-disk-sc"
```

# [Local NVMe](#tab/acstor)
Important

Ensure that your cluster is using VM SKUs that support local NVMe drives, for example, [Storage optimized VM SKUs](/en-us/azure/virtual-machines/sizes/overview#storage-optimized) or [GPU accelerated VM SKUs](/en-us/azure/virtual-machines/sizes/overview#gpu-accelerated). The below instructions require Azure Container Storage v2.0.0 or later.

1. Update AKS cluster to install Azure Container Storage on user node pool.

    ```bash
    az aks update \
        --name $AKS_PRIMARY_CLUSTER_NAME \
        --resource-group $RESOURCE_GROUP_NAME \
        --enable-azure-container-storage
    ```
2. Use the provided Azure Container Storage storage class.

    ```bash
    cat <<EOF | kubectl apply -f -
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
        name: acstor-ephemeraldisk-nvme-db
    provisioner: localdisk.csi.acstor.io
    reclaimPolicy: Delete
    volumeBindingMode: WaitForFirstConsumer
    EOF
    
    export POSTGRES_STORAGE_CLASS="acstor-ephemeraldisk-nvme-db"
    ```

---

## Update the monitoring infrastructure

The Azure Monitor workspace for Managed Prometheus and Azure Managed Grafana are automatically linked to the AKS cluster for metrics and visualization during the cluster creation process. In this section, you enable log collection with AKS Container insights and validate that Managed Prometheus is scraping metrics and Container insights is ingesting logs.

1. Enable Container insights monitoring on the AKS cluster using the [`az aks enable-addons`](/en-us/cli/azure/aks#az-aks-enable-addons) command.

    ```bash
    az aks enable-addons \
        --addon monitoring \
        --name $AKS_PRIMARY_CLUSTER_NAME \
        --resource-group $RESOURCE_GROUP_NAME \
        --workspace-resource-id $ALA_RESOURCE_ID \
        --output table
    ```
2. Validate that Managed Prometheus is scraping metrics and Container insights is ingesting logs from the AKS cluster by inspecting the DaemonSet using the [`kubectl get`](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_get/) command and the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```bash
    kubectl get ds ama-metrics-node \
        --context $AKS_PRIMARY_CLUSTER_NAME \
        --namespace=kube-system
    
    kubectl get ds ama-logs \
        --context $AKS_PRIMARY_CLUSTER_NAME \
        --namespace=kube-system
    
    az aks show \
        --resource-group $RESOURCE_GROUP_NAME \
        --name $AKS_PRIMARY_CLUSTER_NAME \
        --query addonProfiles
    ```

    Your output should resemble the following example output, with *six* nodes total (three for the system node pool and three for the PostgreSQL node pool) and the Container insights showing `"enabled": true`:

    ```output
    NAME               DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR
    ama-metrics-node   6         6         6       6            6           <none>       
    
    NAME               DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR
    ama-logs           6         6         6       6            6           <none>       
    
    {
      "omsagent": {
        "config": {
          "logAnalyticsWorkspaceResourceID": "/subscriptions/aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e/resourceGroups/rg-cnpg-9vbin3p8/providers/Microsoft.OperationalInsights/workspaces/ala-cnpg-9vbin3p8",
          "useAADAuth": "true"
        },
        "enabled": true,
        "identity": null
      }
    }
    ```

## Create a public static IP for PostgreSQL cluster ingress

To validate deployment of the PostgreSQL cluster and use client PostgreSQL tooling, such as *psql* and *PgAdmin*, you need to expose the primary and read-only replicas to ingress. In this section, you create an Azure public IP resource that you later supply to an Azure load balancer to expose PostgreSQL endpoints for query.

1. Get the name of the AKS cluster node resource group using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```bash
    export AKS_PRIMARY_CLUSTER_NODERG_NAME=$(az aks show \
        --name $AKS_PRIMARY_CLUSTER_NAME \
        --resource-group $RESOURCE_GROUP_NAME \
        --query nodeResourceGroup \
        --output tsv)
    
    echo $AKS_PRIMARY_CLUSTER_NODERG_NAME
    ```
2. Create the public IP address using the [`az network public-ip create`](/en-us/cli/azure/network/public-ip#az-network-public-ip-create) command.

    ```bash
    export AKS_PRIMARY_CLUSTER_PUBLICIP_NAME="$AKS_PRIMARY_CLUSTER_NAME-pip"
    
    az network public-ip create \
        --resource-group $AKS_PRIMARY_CLUSTER_NODERG_NAME \
        --name $AKS_PRIMARY_CLUSTER_PUBLICIP_NAME \
        --location $PRIMARY_CLUSTER_REGION \
        --sku Standard \
        --zone 1 2 3 \
        --allocation-method static \
        --output table
    ```
3. Get the newly created public IP address using the [`az network public-ip show`](/en-us/cli/azure/network/public-ip#az-network-public-ip-show) command.

    ```bash
    export AKS_PRIMARY_CLUSTER_PUBLICIP_ADDRESS=$(az network public-ip show \
        --resource-group $AKS_PRIMARY_CLUSTER_NODERG_NAME \
        --name $AKS_PRIMARY_CLUSTER_PUBLICIP_NAME \
        --query ipAddress \
        --output tsv)
    
    echo $AKS_PRIMARY_CLUSTER_PUBLICIP_ADDRESS
    ```
4. Get the resource ID of the node resource group using the [`az group show`](/en-us/cli/azure/group#az-group-show) command.

    ```bash
    export AKS_PRIMARY_CLUSTER_NODERG_NAME_SCOPE=$(az group show --name \
        $AKS_PRIMARY_CLUSTER_NODERG_NAME \
        --query id \
        --output tsv)
    
    echo $AKS_PRIMARY_CLUSTER_NODERG_NAME_SCOPE
    ```
5. Assign the "Network Contributor" role to the UAMI object ID using the node resource group scope using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command.

    ```bash
    az role assignment create \
        --assignee-object-id ${AKS_UAMI_WORKLOAD_OBJECTID} \
        --assignee-principal-type ServicePrincipal \
        --role "Network Contributor" \
        --scope ${AKS_PRIMARY_CLUSTER_NODERG_NAME_SCOPE}
    ```

## Install the CNPG operator in the AKS cluster

In this section, you install the CNPG operator in the AKS cluster using Helm or a YAML manifest.

# [Helm](#tab/helm)
1. Add the CNPG Helm repo using the [`helm repo add`](https://helm.sh/docs/helm/helm_repo_add/) command.

    ```bash
    helm repo add cnpg https://cloudnative-pg.github.io/charts
    ```
2. Upgrade the CNPG Helm repo and install it on the AKS cluster using the [`helm upgrade`](https://helm.sh/docs/helm/helm_upgrade/) command with the `--install` flag.

    ```bash
    helm upgrade --install cnpg \
        --namespace $PG_SYSTEM_NAMESPACE \
        --create-namespace \
        --kube-context=$AKS_PRIMARY_CLUSTER_NAME \
        cnpg/cloudnative-pg
    ```
3. Verify the operator installation on the AKS cluster using the [`kubectl get`](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_get/) command.

    ```bash
    kubectl get deployment \
        --context $AKS_PRIMARY_CLUSTER_NAME \
        --namespace $PG_SYSTEM_NAMESPACE cnpg-cloudnative-pg
    ```

# [YAML](#tab/yaml)
1. Install the CNPG operator on the AKS cluster using the [`kubectl apply`](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_apply/) command.

    ```bash
    kubectl apply --context $AKS_PRIMARY_CLUSTER_NAME \
        --namespace $PG_SYSTEM_NAMESPACE \
        --server-side -f \
        https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.27/releases/cnpg-1.27.0.yaml
    ```
2. Verify the operator installation on the AKS cluster using the [`kubectl get`](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_get/) command.

    ```bash
    kubectl get deployment \
        --namespace $PG_SYSTEM_NAMESPACE cnpg-controller-manager \
        --context $AKS_PRIMARY_CLUSTER_NAME
    ```

---