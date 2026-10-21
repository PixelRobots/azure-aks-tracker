---
layout: Conceptual
title: 'Quickstart: Deploy Application Gateway for Containers ALB Controller - AKS Add-on | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/quickstart-deploy-application-gateway-for-containers-alb-controller-addon
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
description: In this quickstart, you learn how to provision the Application Gateway for Containers ALB Controller in an AKS cluster using the AKS add-on.
services: application-gateway
author: mbender-ms
ms.service: azure-application-gateway-containers
ms.custom: devx-track-azurecli
ms.topic: quickstart
ms.date: 2026-08-24T00:00:00.0000000Z
ms.author: mbender
locale: en-us
document_id: f5ee84b2-173d-ecc3-11a7-e2275b7b5365
document_version_independent_id: ec932b32-5ade-dfbc-6cf1-c51a776447cd
original_content_git_url: https://github.com/MicrosoftDocs/azure-docs-pr/blob/live/articles/application-gateway/for-containers/quickstart-deploy-application-gateway-for-containers-alb-controller-addon.md
site_name: Docs
depot_name: Azure.azure-documents
page_type: conceptual
interactive_type: azurecli,azurepowershell
toc_rel: toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/Azure.azure-documents/{branchName}{pdfName}
asset_id: application-gateway/for-containers/quickstart-deploy-application-gateway-for-containers-alb-controller-addon
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-gateway/for-containers/quickstart-deploy-application-gateway-for-containers-alb-controller-addon.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
- https://authoring-docs-microsoft.poolparty.biz/devrel/f98c9a19-e481-4f15-8047-76b641e6ed57
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
- https://authoring-docs-microsoft.poolparty.biz/devrel/f5685781-a4fd-40f1-8126-59abde4643bf
platformId: 7870c729-adeb-1dea-8504-6e6fab5fa9a5
---

# Quickstart: Deploy Application Gateway for Containers ALB Controller - AKS Add-on | Microsoft Learn

The [ALB Controller](application-gateway-for-containers-components#application-gateway-for-containers-alb-controller) is responsible for translating Gateway API and Ingress API configuration within Kubernetes to load balancing rules within Application Gateway for Containers. The following guide walks through the steps needed to enable both the AKS managed Gateway API and Application Gateway for Containers ALB Controller add-ons on a new or existing Azure Kubernetes Service (AKS) cluster.

![Diagram depicting traffic from the Internet ingressing into Application Gateway for Containers and being sent to backend pods in AKS; installed by an AKS add-on.](media/overview/application-gateway-for-containers-kubernetes-addon.svg)

## Prerequisites

You need to complete the following tasks before enabling the ALB Controller add-on on your cluster:

1. Prepare your Azure subscription and your `az-cli` client.

# [Azure CLI](#tab/azure-cli)
```azurecli
    # Sign in to your Azure subscription.
    SUBSCRIPTION_ID='<your subscription id>'
    az login
    az account set --subscription $SUBSCRIPTION_ID
    
    # Register required resource providers on Azure.
    az provider register --namespace Microsoft.ContainerService
    az provider register --namespace Microsoft.Network
    az provider register --namespace Microsoft.NetworkFunction
    az provider register --namespace Microsoft.ServiceNetworking
    
    # Install Azure CLI extensions.
    az extension add --name alb
    az extension add --name aks-preview 
    ```

# [Azure PowerShell](#tab/azure-powershell)
```azurepowershell
    # Sign in to your Azure subscription.
    $SUBSCRIPTION_ID = '<your subscription id>'
    Connect-AzAccount
    Set-AzContext -SubscriptionId $SUBSCRIPTION_ID
    
    # Register required resource providers on Azure.
    Register-AzResourceProvider -ProviderNamespace Microsoft.ContainerService
    Register-AzResourceProvider -ProviderNamespace Microsoft.Network
    Register-AzResourceProvider -ProviderNamespace Microsoft.NetworkFunction
    Register-AzResourceProvider -ProviderNamespace Microsoft.ServiceNetworking
    
    # Install Azure PowerShell module for Application Gateway for Containers (ALB).
    Install-Module -Name Az.Alb -Force -AllowClobber
    ```

---
2. Register add-on feature

    Use the Azure CLI to register the add-on feature.

    ```azurecli
    # Register required preview features
    az feature register --namespace "Microsoft.ContainerService" --name "ManagedGatewayAPIPreview"
    az feature register --namespace "Microsoft.ContainerService" --name "ApplicationLoadBalancerPreview"
    ```

    Important

    The Application Gateway for Containers AKS add-on is currently in preview. See the [Supplemental Terms of Use for Microsoft Azure Previews](https://azure.microsoft.com/support/legal/preview-supplemental-terms/) for legal terms that apply to Azure features that are in beta, preview, or otherwise not yet released into general availability.

## Set up an AKS cluster with the AKS add-on

The AKS add-on can be enabled on new or existing clusters.

The following AKS cluster requirements are needed for successful provisioning of the add-on:

- Must be in a [region where Application Gateway for Containers is available](overview#supported-regions).
- Must use [Azure CNI](/en-us/azure/aks/configure-azure-cni) or [Azure CNI Overlay](/en-us/azure/aks/concepts-network-azure-cni-overlay) network.
- Must have the workload identity feature enabled. [Learn how](/en-us/azure/aks/workload-identity-deploy-cluster#update-an-existing-aks-cluster) to enable workload identity on an existing AKS cluster.
- Must be using a [supported AKS Kubernetes version](/en-us/azure/aks/supported-kubernetes-versions).

### New Cluster

Use the following commands to create a new AKS cluster with Azure CNI, workload identity enabled, gateway API add-on, and the Application Gateway for Containers add-on enabled.

```azurecli
AKS_NAME='<your cluster name>'
RESOURCE_GROUP='<your resource group name>'
LOCATION='northeurope'
VM_SIZE='<the size of the vm in AKS>' # The size needs to be available in your location

az group create --name $RESOURCE_GROUP --location $LOCATION
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_NAME \
    --location $LOCATION \
    --node-vm-size $VM_SIZE \
    --network-plugin azure \
    --enable-oidc-issuer \
    --enable-workload-identity \
    --enable-gateway-api \
    --enable-application-load-balancer \
    --generate-ssh-key
```

Note

Note

### Existing Cluster

#### Add prerequisites to an existing cluster

If using an existing cluster, ensure you enable Workload Identity support on your AKS cluster. Workload identities can be enabled via the following commands:

# [Azure CLI](#tab/azure-cli)
```azurecli
AKS_NAME='<your cluster name>'
RESOURCE_GROUP='<your resource group name>'
az aks update -g $RESOURCE_GROUP -n $AKS_NAME --enable-oidc-issuer --enable-workload-identity --no-wait
```

# [Azure PowerShell](#tab/azure-powershell)
```azurepowershell
$AKS_NAME = '<your cluster name>'
$RESOURCE_GROUP = '<your resource group name>'

# Get the AKS cluster object
$cluster = Get-AzAksCluster -ResourceGroupName $RESOURCE_GROUP -Name $AKS_NAME

# Set security profile
$cluster.SecurityProfile.WorkloadIdentity = $True

# Update the cluster
Set-AzAksCluster -InputObject $cluster -EnableOidcIssuer
```

---

#### Install ALB Controller add-on

With an existing cluster, you can enable the Gateway API and Application Gateway for Containers add-ons with the following commands:

# [Azure CLI](#tab/azure-cli2)
```azurecli
AKS_NAME='<your cluster name>'
RESOURCE_GROUP='<your resource group name>'

# Update the AKS cluster
az aks update --name ${AKS_NAME} --resource-group ${RESOURCE_GROUP} --enable-gateway-api --enable-application-load-balancer
```

# [Azure Rest](#tab/azure-rest2)
Here's how to update an existing AKS cluster via REST API, by using the Azure CLI REST command.

```azurecli
AKS_NAME='<your cluster name>'
RESOURCE_GROUP='<your resource group name>'
AKS_ID=$(az aks show -g $RESOURCE_GROUP -n $AKS_NAME --query id -o tsv)
AKS_REGION=$(az aks show -g $RESOURCE_GROUP -n $AKS_NAME --query location -o tsv)

az rest \
  --method put \
  --uri "https://management.azure.com${AKS_ID}?api-version=2025-09-02-preview" \
  --body '{
    "location": "${AKS_REGION}",
    "properties": {
      "ingressProfile": {
        "applicationLoadBalancer": {
          "enabled": true
        },
        "gatewayAPI": {
          "installation": "Standard"
        }
      }
    }
  }' \
  --verbose
```

---

### Verify the ALB Controller installation

Both the new cluster and existing cluster paths use the same verification checks. After the add-on is enabled, complete the following checks regardless of which path you used.

#### Verify ALB Controller Pods

Verify the ALB Controller pods are running in the `kube-system` namespace:

```azurecli
kubectl get pods -n kube-system | grep alb-controller
```

You should see two `alb-controller` pods in `Running` state:

| NAME | READY | STATUS | RESTARTS | AGE |
| --- | --- | --- | --- | --- |
| alb-controller-6648c5d5c-sdd9t | 1/1 | Running | 0 | 4d6h |
| alb-controller-6648c5d5c-au234 | 1/1 | Running | 0 | 4d6h |

#### Verify GatewayClass

Verify GatewayClass `azure-alb-external` is installed on your cluster:

```azurecli
kubectl get gatewayclass azure-alb-external -o yaml
```

You should see that the GatewayClass has a condition that reads **Valid GatewayClass**. This condition indicates that a default GatewayClass is set up and that any gateway resources that reference this GatewayClass is managed by ALB Controller.

```output
apiVersion: gateway.networking.k8s.io/v1beta1
kind: GatewayClass
metadata:
  creationTimestamp: "2023-07-31T13:07:00Z"
  generation: 1
  name: azure-alb-external
  resourceVersion: "64270"
  uid: 6c1443af-63e6-4b79-952f-6c3af1f1c41e
spec:
  controllerName: alb.networking.azure.io/alb-controller
status:
  conditions:
    - lastTransitionTime: "2023-07-31T13:07:23Z"
    message: Valid GatewayClass
    observedGeneration: 1
    reason: Accepted
    status: "True"
    type: Accepted
```

#### Validate Add-on Resources in Azure portal

Navigate to the `MC_` (node) resource group for your AKS cluster. You should see the following resources created by the add-on:

##### Managed Identity

An identity named `applicationloadbalancer-<cluster-name>` is created with the following role assignments:

| Role | Scope |
| --- | --- |
| Network Contributor | MC resource group |
| AppGw for Containers Configuration Manager | MC resource group |
| Reader | MC resource group |

The `applicationloadbalancer-<cluster-name>` identity has a federated identity credential configured with the following properties:

- **Name:** aksfic
- **Namespace:** kube-system
- **Service Account:** alb-controller-sa

Warning

It is unsupported to modify the identity or namespace when provisioning integration with the add-on. If you wish to customize your deployment, consider [deployment with helm](quickstart-deploy-application-gateway-for-containers-alb-controller-helm).

##### Subnet

When the add-on is enabled on an AKS cluster using the AKS-managed virtual network option, a subnet named `aks-appgateway` is automatically created with delegation enabled for `Microsoft.ServiceNetworking/TrafficController`.