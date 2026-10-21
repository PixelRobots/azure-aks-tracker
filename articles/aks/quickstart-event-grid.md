---
layout: Conceptual
title: Subscribe to Azure Kubernetes Service events with Azure Event Grid - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/quickstart-event-grid
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
description: Use Azure Event Grid to subscribe to Azure Kubernetes Service events
ms.topic: how-to
ms.custom: devx-track-azurepowershell, devx-track-azurecli, aks-getting-started
ms.date: 2023-06-22T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 15111ae8-d202-aeeb-6afa-d60252e23c3b
document_version_independent_id: a560ac4a-35c4-9f18-f488-87001c68bc7a
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/quickstart-event-grid.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,azurepowershell
toc_rel: toc.json
asset_id: aks/quickstart-event-grid
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/quickstart-event-grid.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/467aaae1-e916-4fcd-a463-5b27f9d4745c
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/fbd4eef5-2258-406b-95d3-2c68fa333b20
platformId: fc3c2525-d977-7a5c-9bf2-3de15fcabf1c
---

# Subscribe to Azure Kubernetes Service events with Azure Event Grid - Azure Kubernetes Service | Microsoft Learn

Azure Event Grid is a fully managed event routing service that provides uniform event consumption using a publish-subscribe model.

In this quickstart, you create an AKS cluster and subscribe to AKS events.

## Prerequisites

- An Azure subscription. If you don't have an Azure subscription, you can create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- [Azure CLI](/en-us/cli/azure/install-azure-cli) or [Azure PowerShell](/en-us/powershell/azure/install-az-ps) installed.

Note

AKS operations are independent of Azure Event Grid availability and aren't impacted during Event Grid [Service Outages](https://azure.status.microsoft/status).

## Create an AKS cluster

# [Azure CLI](#tab/azure-cli)
Create an AKS cluster using the [az aks create](/en-us/cli/azure/aks#az-aks-create) command. The following example creates a resource group *MyResourceGroup* and a cluster named *MyAKS* with one node in the *MyResourceGroup* resource group:

```azurecli
az group create --name MyResourceGroup --location eastus
az aks create --resource-group MyResourceGroup --name MyAKS --location eastus  --node-count 1 --generate-ssh-keys
```

# [Azure PowerShell](#tab/azure-powershell)
Create an AKS cluster using the [New-AzAksCluster](/en-us/powershell/module/az.aks/new-azakscluster) command. The following example creates a resource group *MyResourceGroup* and a cluster named *MyAKS* with one node in the *MyResourceGroup* resource group:

```azurepowershell
New-AzResourceGroup -Name MyResourceGroup -Location eastus
New-AzAksCluster -ResourceGroupName MyResourceGroup -Name MyAKS -Location eastus -NodeCount 1 -GenerateSshKey
```

---

## Subscribe to AKS events

# [Azure CLI](#tab/azure-cli)
Create a namespace and event hub using [az eventhubs namespace create](/en-us/cli/azure/eventhubs/namespace#az-eventhubs-namespace-create) and [az eventhubs eventhub create](/en-us/cli/azure/eventhubs/eventhub#az-eventhubs-eventhub-create). The following example creates a namespace *MyNamespace* and an event hub *MyEventGridHub* in *MyNamespace*, both in the *MyResourceGroup* resource group.

```azurecli
az eventhubs namespace create --location eastus --name MyNamespace --resource-group MyResourceGroup
az eventhubs eventhub create --name MyEventGridHub --namespace-name MyNamespace --resource-group MyResourceGroup
```

Note

The *name* of your namespace must be unique.

Subscribe to the AKS events using [az eventgrid event-subscription create](/en-us/cli/azure/eventgrid/event-subscription#az-eventgrid-event-subscription-create):

```azurecli
SOURCE_RESOURCE_ID=$(az aks show --resource-group MyResourceGroup --name MyAKS --query id --output tsv)
ENDPOINT=$(az eventhubs eventhub show --resource-group MyResourceGroup --name MyEventGridHub --namespace-name MyNamespace --query id --output tsv)
az eventgrid event-subscription create --name MyEventGridSubscription \
--source-resource-id $SOURCE_RESOURCE_ID \
--endpoint-type eventhub \
--endpoint $ENDPOINT
```

Verify your subscription to AKS events using `az eventgrid event-subscription list`:

```azurecli
az eventgrid event-subscription list --source-resource-id $SOURCE_RESOURCE_ID
```

The following example output shows you're subscribed to events from the *MyAKS* cluster and those events are delivered to the *MyEventGridHub* event hub:

```output
[
  {
    "deadLetterDestination": null,
    "deadLetterWithResourceIdentity": null,
    "deliveryWithResourceIdentity": null,
    "destination": {
      "deliveryAttributeMappings": null,
      "endpointType": "EventHub",
      "resourceId": "/subscriptions/SUBSCRIPTION_ID/resourceGroups/MyResourceGroup/providers/Microsoft.EventHub/namespaces/MyNamespace/eventhubs/MyEventGridHub"
    },
    "eventDeliverySchema": "EventGridSchema",
    "expirationTimeUtc": null,
    "filter": {
      "advancedFilters": null,
      "enableAdvancedFilteringOnArrays": null,
      "includedEventTypes": [
        "Microsoft.ContainerService.NewKubernetesVersionAvailable","Microsoft.ContainerService.ClusterSupportEnded","Microsoft.ContainerService.ClusterSupportEnding","Microsoft.ContainerService.NodePoolRollingFailed","Microsoft.ContainerService.NodePoolRollingStarted","Microsoft.ContainerService.NodePoolRollingSucceeded"
      ],
      "isSubjectCaseSensitive": null,
      "subjectBeginsWith": "",
      "subjectEndsWith": ""
    },
    "id": "/subscriptions/SUBSCRIPTION_ID/resourceGroups/MyResourceGroup/providers/Microsoft.ContainerService/managedClusters/MyAKS/providers/Microsoft.EventGrid/eventSubscriptions/MyEventGridSubscription",
    "labels": null,
    "name": "MyEventGridSubscription",
    "provisioningState": "Succeeded",
    "resourceGroup": "MyResourceGroup",
    "retryPolicy": {
      "eventTimeToLiveInMinutes": 1440,
      "maxDeliveryAttempts": 30
    },
    "systemData": null,
    "topic": "/subscriptions/SUBSCRIPTION_ID/resourceGroups/MyResourceGroup/providers/microsoft.containerservice/managedclusters/MyAKS",
    "type": "Microsoft.EventGrid/eventSubscriptions"
  }
]
```

# [Azure PowerShell](#tab/azure-powershell)
Create a namespace and event hub using [New-AzEventHubNamespace](/en-us/powershell/module/az.eventhub/new-azeventhubnamespace) and [New-AzEventHub](/en-us/powershell/module/az.eventhub/new-azeventhub). The following example creates a namespace *MyNamespace* and an event hub *MyEventGridHub* in *MyNamespace*, both in the *MyResourceGroup* resource group.

```azurepowershell
New-AzEventHubNamespace -Location eastus -Name MyNamespace -ResourceGroupName MyResourceGroup
New-AzEventHub -Name MyEventGridHub -Namespace MyNamespace -ResourceGroupName MyResourceGroup
```

Note

The *name* of your namespace must be unique.

Subscribe to the AKS events using [New-AzEventGridSubscription](/en-us/powershell/module/az.eventgrid/new-azeventgridsubscription):

```azurepowershell
$SOURCE_RESOURCE_ID = (Get-AzAksCluster -ResourceGroupName MyResourceGroup -Name MyAKS).Id
$ENDPOINT = (Get-AzEventHub -ResourceGroupName MyResourceGroup -EventHubName MyEventGridHub -Namespace MyNamespace).Id
$params = @{
    EventSubscriptionName = 'MyEventGridSubscription'
    ResourceId            = $SOURCE_RESOURCE_ID
    EndpointType          = 'eventhub'
    Endpoint              = $ENDPOINT 
}
New-AzEventGridSubscription @params
```

Verify your subscription to AKS events using `Get-AzEventGridSubscription`:

```azurepowershell
Get-AzEventGridSubscription -ResourceId $SOURCE_RESOURCE_ID | Select-Object -ExpandProperty PSEventSubscriptionsList
```

The following example output shows you're subscribed to events from the *MyAKS* cluster and those events are delivered to the *MyEventGridHub* event hub:

```Output
EventSubscriptionName : MyEventGridSubscription
Id                    : /subscriptions/SUBSCRIPTION_ID/resourceGroups/MyResourceGroup/providers/Microsoft.ContainerService/managedClusters/MyAKS/providers/Microsoft.EventGrid/eventSubscriptions/MyEventGridSubscription
Type                  : Microsoft.EventGrid/eventSubscriptions
Topic                 : /subscriptions/SUBSCRIPTION_ID/resourceGroups/myresourcegroup/providers/microsoft.containerservice/managedclusters/myaks
Filter                : Microsoft.Azure.Management.EventGrid.Models.EventSubscriptionFilter
Destination           : Microsoft.Azure.Management.EventGrid.Models.EventHubEventSubscriptionDestination
ProvisioningState     : Succeeded
Labels                : 
EventTtl              : 1440
MaxDeliveryAttempt    : 30
EventDeliverySchema   : EventGridSchema
ExpirationDate        : 
DeadLetterEndpoint    : 
Endpoint              : /subscriptions/SUBSCRIPTION_ID/resourceGroups/MyResourceGroup/providers/Microsoft.EventHub/namespaces/MyNamespace/eventhubs/MyEventGridHub
```

---

When AKS events occur, you see those events appear in your event hub. For example, when the list of available Kubernetes versions for your clusters changes, you see a `Microsoft.ContainerService.NewKubernetesVersionAvailable` event. There are also new events available now for upgrades and cluster within support. For more information on the events AKS emits, see [Azure Kubernetes Service (AKS) as an Event Grid source](/en-us/azure/event-grid/event-schema-aks).

## Delete the cluster and subscriptions

# [Azure CLI](#tab/azure-cli)
Use the [az group delete](/en-us/cli/azure/group#az-group-delete) command to remove the resource group, the AKS cluster, namespace, and event hub, and all related resources.

```azurecli
az group delete --name MyResourceGroup --yes --no-wait
```

# [Azure PowerShell](#tab/azure-powershell)
Use the [Remove-AzResourceGroup](/en-us/powershell/module/az.resources/remove-azresourcegroup) cmdlet to remove the resource group, the AKS cluster, namespace, and event hub, and all related resources.

```azurepowershell
Remove-AzResourceGroup -Name MyResourceGroup
```

---

Note

When you delete the cluster, the Microsoft Entra service principal used by the AKS cluster isn't removed. For steps on how to remove the service principal, see [AKS service principal considerations and deletion](kubernetes-service-principal#considerations-when-using-a-service-principal).

If you used a managed identity, the identity is managed by the platform and doesn't require removal.