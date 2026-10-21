---
layout: Conceptual
title: 'Quickstart: Create Application Gateway for Containers managed by ALB Controller | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/quickstart-create-application-gateway-for-containers-managed-by-alb-controller
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
description: In this quickstart, you learn how to provision the Application Gateway for Containers resources via Kubernetes definition.
services: application-gateway
author: mbender-ms
ms.service: azure-application-gateway-containers
ms.custom: devx-track-azurecli
ms.topic: quickstart
ms.date: 2024-02-27T00:00:00.0000000Z
ms.author: mbender
locale: en-us
document_id: 5ba247b0-4f42-d718-b685-68c7e7869e26
document_version_independent_id: f9a89f2c-f2ff-bad8-597d-dcc3a52e20e1
original_content_git_url: https://github.com/MicrosoftDocs/azure-docs-pr/blob/live/articles/application-gateway/for-containers/quickstart-create-application-gateway-for-containers-managed-by-alb-controller.md
site_name: Docs
depot_name: Azure.azure-documents
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/Azure.azure-documents/{branchName}{pdfName}
asset_id: application-gateway/for-containers/quickstart-create-application-gateway-for-containers-managed-by-alb-controller
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-gateway/for-containers/quickstart-create-application-gateway-for-containers-managed-by-alb-controller.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
- https://authoring-docs-microsoft.poolparty.biz/devrel/f98c9a19-e481-4f15-8047-76b641e6ed57
- https://authoring-docs-microsoft.poolparty.biz/devrel/20ed8455-bc18-4537-87a4-83784e7b2a39
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
- https://authoring-docs-microsoft.poolparty.biz/devrel/f5685781-a4fd-40f1-8126-59abde4643bf
- https://authoring-docs-microsoft.poolparty.biz/devrel/9a7f703b-30bb-4d62-9eb4-97213f571849
platformId: b42286b3-f3cf-b6fd-574e-e9eda3c04b2a
---

# Quickstart: Create Application Gateway for Containers managed by ALB Controller | Microsoft Learn

This guide assumes you're following the **managed by ALB controller**[deployment strategy](overview#deployment-strategies), where all the Application Gateway for Containers resources are managed by ALB controller. Lifecycle is determined by the resources defined in Kubernetes. ALB Controller creates the Application Gateway for Containers resource when an *ApplicationLoadBalancer* custom resource is defined on the cluster. The Application Gateway for Containers lifecycle is based on the lifecycle of the custom resource.

## Prerequisites

Ensure you have first deployed ALB Controller into your Kubernetes cluster. See the ALB Controller quickstart guide for [Add-on](quickstart-deploy-application-gateway-for-containers-alb-controller-addon) or [Helm](quickstart-deploy-application-gateway-for-containers-alb-controller-helm) if you haven't already deployed the ALB Controller.

### Prepare your virtual network / subnet for Application Gateway for Containers

If you don't have a subnet available with at least 250 available IP addresses and delegated to the Application Gateway for Containers resource, use the following steps to create a new subnet and enable subnet delegation. The new subnet address space can't overlap any existing subnets in the VNet.

# [New subnet in AKS managed virtual network](#tab/new-subnet-aks-vnet)
If you wish to deploy Application Gateway for Containers into the virtual network containing your AKS cluster, run the following command to find and assign the cluster's virtual network. This information is used in the next step.

```azurecli
AKS_NAME='<your cluster name>'
RESOURCE_GROUP='<your resource group name>'

MC_RESOURCE_GROUP=$(az aks show --name $AKS_NAME --resource-group $RESOURCE_GROUP --query "nodeResourceGroup" -o tsv)
CLUSTER_SUBNET_ID=$(az vmss list --resource-group $MC_RESOURCE_GROUP --query '[0].virtualMachineProfile.networkProfile.networkInterfaceConfigurations[0].ipConfigurations[0].subnet.id' -o tsv)
read -d '' VNET_NAME VNET_RESOURCE_GROUP VNET_ID <<< $(az network vnet show --ids $CLUSTER_SUBNET_ID --query '[name, resourceGroup, id]' -o tsv)
```

# [New subnet in non-AKS managed virtual network](#tab/new-subnet-non-aks-vnet)
If you wish to create a subnet in an existing virtual network, run the following command to set the variables for reference to the vnet and subnet prefix to be used during creation.

Warning

Upon creation of the subnet in the next step, ensure you establish connectivity between this virtual network/subnet and the AKS node pool to enable communication between Application Gateway for Containers and the pods running in AKS.

```azurecli
VNET_RESOURCE_GROUP=<resource group name of the virtual network>
VNET_NAME=<name of the virtual network to use>
```

---

Run the following command to create a new subnet containing at least 250 available IP addresses and enable subnet delegation for the Application Gateway for Containers association resource:

```azurecli
SUBNET_ADDRESS_PREFIX='<network address and prefix for an address space under the vnet that has at least 250 available addresses (/24 or larger subnet)>'
ALB_SUBNET_NAME='subnet-alb' # subnet name can be any non-reserved subnet name (i.e. GatewaySubnet, AzureFirewallSubnet, AzureBastionSubnet would all be invalid)
az network vnet subnet create \
  --resource-group $VNET_RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $ALB_SUBNET_NAME \
  --address-prefixes $SUBNET_ADDRESS_PREFIX \
  --delegations 'Microsoft.ServiceNetworking/trafficControllers'
ALB_SUBNET_ID=$(az network vnet subnet show --name $ALB_SUBNET_NAME --resource-group $VNET_RESOURCE_GROUP --vnet-name $VNET_NAME --query '[id]' --output tsv)
```

## Delegate permissions to managed identity

ALB Controller needs the ability to provision new Application Gateway for Containers resources and to join the subnet intended for the Application Gateway for Containers association resource.

In this example, we delegate the *AppGW for Containers Configuration Manager* role to the resource group containing the managed cluster and delegate the *Network Contributor* role to the subnet used by the Application Gateway for Containers association subnet, which contains the *Microsoft.Network/virtualNetworks/subnets/join/action* permission.

If desired, you can [create and assign a custom role](../../role-based-access-control/custom-roles-portal) with the *Microsoft.Network/virtualNetworks/subnets/join/action* permission to eliminate other permissions contained in the *Network Contributor* role. Learn more about [managing subnet permissions](../../virtual-network/virtual-network-manage-subnet#permissions).

```azurecli
IDENTITY_RESOURCE_NAME='azure-alb-identity'

MC_RESOURCE_GROUP=$(az aks show --name $AKS_NAME --resource-group $RESOURCE_GROUP --query "nodeResourceGroup" -otsv | tr -d '\r')

mcResourceGroupId=$(az group show --name $MC_RESOURCE_GROUP --query id -otsv)
principalId=$(az identity show -g $RESOURCE_GROUP -n $IDENTITY_RESOURCE_NAME --query principalId -otsv)

# Delegate AppGw for Containers Configuration Manager role to AKS Managed Cluster RG
az role assignment create --assignee-object-id $principalId --assignee-principal-type ServicePrincipal --scope $mcResourceGroupId --role "fbc52c3f-28ad-4303-a892-8a056630b8f1" 

# Delegate Network Contributor permission for join to association subnet
az role assignment create --assignee-object-id $principalId --assignee-principal-type ServicePrincipal --scope $ALB_SUBNET_ID --role "4d97b98b-1d4f-4787-a291-c67834d212e7" 
```

Note

When the identity is created via the [Add-on](quickstart-deploy-application-gateway-for-containers-alb-controller-addon) the name of the identity is actually `applicationloadbalancer-<cluster-name>`. Also the *AppGW for Containers Configuration Manager* role is already assigned.

## Create ApplicationLoadBalancer Kubernetes resource

1. Define the Kubernetes namespace for the ApplicationLoadBalancer resource

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: alb-test-infra
EOF
```

1. Define the *ApplicationLoadBalancer* resource, specifying the subnet ID the Application Gateway for Containers association resource should deploy into. The association establishes connectivity from Application Gateway for Containers to the defined subnet (and connected networks where applicable) to be able to proxy traffic to a defined backend.

Note

When the ALB Controller creates the Application Gateway for Containers resources in ARM, it'll use the following naming conventions for its resources:

- alb-&lt;8 randomly generated characters&gt; to define the Application Gateway for Containers resource
- as-&lt;8 randomly generated characters&gt; to define the association resource

If you would like to change the name of the resources created in Azure, consider following the [bring your own deployment strategy](quickstart-create-application-gateway-for-containers-byo-deployment).

Run the following command to create the Application Gateway for Containers resource and association.

```bash
kubectl apply -f - <<EOF
apiVersion: alb.networking.azure.io/v1
kind: ApplicationLoadBalancer
metadata:
  name: alb-test
  namespace: alb-test-infra
spec:
  associations:
  - $ALB_SUBNET_ID
EOF
```

## Validate creation of the Application Gateway for Containers resources

Once the *ApplicationLoadBalancer* resource has been created, you can track deployment progress of the Application Gateway for Containers resources. The deployment transitions from *InProgress* to *Programmed* state when provisioning has completed. It can take 5-6 minutes for the Application Gateway for Containers resources to be created.

You can check the status of the *ApplicationLoadBalancer* resource by running the following command:

```bash
kubectl get applicationloadbalancer alb-test -n alb-test-infra -o yaml -w
```

Example output of a successful provisioning of the Application Gateway for Containers resource from Kubernetes.

```yaml
status:
  conditions:
  - lastTransitionTime: "2023-06-19T21:03:29Z"
    message: Valid Application Gateway for Containers resource
    observedGeneration: 1
    reason: Accepted
    status: "True"
    type: Accepted
  - lastTransitionTime: "2023-06-19T21:03:29Z"
    message: alb-id=/subscriptions/xxx/resourceGroups/yyy/providers/Microsoft.ServiceNetworking/trafficControllers/alb-zzz
    observedGeneration: 1
    reason: Ready
    status: "True"
    type: Deployment
```