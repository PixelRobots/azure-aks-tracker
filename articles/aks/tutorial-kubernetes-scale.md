---
layout: Conceptual
title: Kubernetes on Azure tutorial - Scale applications in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/tutorial-kubernetes-scale
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
description: In this Azure Kubernetes Service (AKS) tutorial, you learn how to scale nodes and pods and implement horizontal pod autoscaling.
ms.topic: tutorial
ms.date: 2026-06-23T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: mvc, aks-getting-started
locale: en-us
document_id: 2f951156-a378-b3d9-78f2-9ee13d2faad8
document_version_independent_id: 2e55afc9-1459-3a32-c8fc-a78bf9d3d370
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/tutorial-kubernetes-scale.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,azurepowershell
toc_rel: toc.json
asset_id: aks/tutorial-kubernetes-scale
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/tutorial-kubernetes-scale.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 4ad0d8eb-5421-8377-789f-c2435786c3e6
---

# Kubernetes on Azure tutorial - Scale applications in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

If you followed the previous tutorials, you have a working Kubernetes cluster and Azure Store Front app.

In this tutorial, you scale out the pods in the app, try pod autoscaling, and scale the number of Azure VM nodes to change the cluster's capacity for hosting workloads. You learn how to:

- Scale the Kubernetes nodes.
- Manually scale Kubernetes pods that run your application.
- Configure autoscaling pods that run the app front end.

## Before you begin

In previous tutorials, you packaged an application into a container image, uploaded the image to Azure Container Registry, created an AKS cluster, deployed an application, and used Azure Service Bus to redeploy an updated application. If you haven't completed these steps and want to follow along, start with [Tutorial 1 - Prepare application for AKS](tutorial-kubernetes-prepare-app).

This tutorial changes pod and node counts and can increase compute costs. Use an identity with permission to scale AKS workloads and node pools, such as **Contributor** or **Owner** for the resource group.

# [Azure CLI](#tab/azure-cli)
This tutorial requires Azure CLI version 2.34.1 or later. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

# [Azure PowerShell](#tab/azure-powershell)
This tutorial requires Azure PowerShell version 5.9.0 or later. Run `Get-InstalledModule -Name Az` to find the version. If you need to install or upgrade, see [Install Azure PowerShell](/en-us/powershell/azure/install-az-ps).

---

## Manually scale pods

### AKS desktop

1. Edit the scaling configuration for the order-service by selecting **Scaling** &gt; **Select Deployment: order-service** &gt; **Edit Configuration** &gt; **Number of Replicas: 5**. ![Screenshot that shows editting the scale configuration of the order-service.](media/aks-desktop-app/aks-desktop-edit-scaling.png)
2. Verify that the deployment update completes before continuing.
3. View the pods in your cluster using the [`kubectl get`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command.

    ```console
    kubectl get pods
    ```

    The following example output shows the pods running the Azure Store Front app:

    ```output
    NAME                               READY     STATUS     RESTARTS   AGE
    order-service-848767080-tf34m      1/1       Running    0          31m
    product-service-4019737227-2q2qz   1/1       Running    0          31m
    store-front-2606967446-2q2qz       1/1       Running    0          31m
    ```
4. Manually change the number of pods in the *store-front* deployment using the [`kubectl scale`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#scale) command.

    ```console
    kubectl scale --replicas=5 deployment.apps/store-front
    ```
5. Verify the additional pods were created using the [`kubectl get pods`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command.

    ```console
    kubectl get pods --selector app=store-front
    ```

    The following example output shows the additional pods running the Azure Store Front app:

    ```output
    NAME                              READY     STATUS    RESTARTS   AGE
    store-front-3309479140-2hfh0      1/1       Running   0          3m
    store-front-3309479140-bzt05      1/1       Running   0          3m
    store-front-3309479140-fvcvm      1/1       Running   0          3m
    store-front-3309479140-hrbf2      1/1       Running   0          15m
    store-front-3309479140-qphz8      1/1       Running   0          3m
    ```

## Autoscale pods

### AKS desktop

1. Within the Project, select the **Deploy Application** button &gt; **Kubernetes YAML**. ![Select the application source, Kubernetes YAML](media/aks-desktop-app/aks-desktop-deploy-option-yaml.png)
2. Copy and paste this YAML autoscaler manifest and resource limits.

    ```yaml
    apiVersion: autoscaling/v2
    kind: HorizontalPodAutoscaler
    metadata:
      name: store-front-hpa
    spec:
      maxReplicas: 10 # define max replica count
      minReplicas: 3  # define min replica count
      scaleTargetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: store-front
      metrics:
      - type: Resource
        resource:
          name: cpu
          target:
            type: Utilization
            averageUtilization: 50
    ```
3. Select **Next** &gt; **Deploy** &gt; **Close**. ![Screenshot that shows pasting in the YAML configuration.](media/aks-desktop-app/aks-desktop-yaml-paste.png)
4. Select **Scaling** &gt; **Select Deployment: store-front**. You can see the scaling mode is now set to **HPA**, Replica Bounds, and CPU Usage / Target set by the configuration. ![Screenshot that shows AKS desktop scaling overview showing HPA mode for the store-front deployment.](media/aks-desktop-app/aks-desktop-auto-scaling.png)
5. Verify that HPA mode is enabled and the replica bounds match the manifest values.

### Command line

To use the horizontal pod autoscaler, all containers must have defined CPU requests and limits, and pods must have specified requests. In the `aks-store-quickstart` deployment, the *front-end* container requests 1m CPU with a limit of 1000m CPU.

These resource requests and limits are defined for each container, as shown in the following condensed example YAML:

```yaml
...
  containers:
  - name: store-front
    image: ghcr.io/azure-samples/aks-store-demo/store-front:latest
    ports:
    - containerPort: 8080
      name: store-front
...
    resources:
      requests:
        cpu: 1m
...
      limits:
        cpu: 1000m
...
```

### Autoscale pods using a manifest file

1. Create a manifest file to define the autoscaler behavior and resource limits, as shown in the following condensed example manifest file `aks-store-quickstart-hpa.yaml`:

    ```yaml
    apiVersion: autoscaling/v2
    kind: HorizontalPodAutoscaler
    metadata:
      name: store-front-hpa
    spec:
      maxReplicas: 10 # define max replica count
      minReplicas: 3  # define min replica count
      scaleTargetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: store-front
      metrics:
      - type: Resource
        resource:
          name: cpu
          target:
            type: Utilization
            averageUtilization: 50
    ```
2. Apply the autoscaler manifest file using the `kubectl apply` command.

    ```console
    kubectl apply -f aks-store-quickstart-hpa.yaml
    ```
3. Check the status of the autoscaler using the `kubectl get hpa` command.

    ```console
    kubectl get hpa
    ```

    After a few minutes, with minimal load on the Azure Store Front app, the number of pod replicas decreases to three. You can use `kubectl get pods` command again to see the unneeded pods being removed.

    Continue when the `TARGETS` and `REPLICAS` columns show expected autoscaling behavior for `store-front-hpa`.

Note

You can enable the Kubernetes-based Event-Driven Autoscaler (KEDA) AKS add-on to your cluster to drive scaling based on the number of events needing to be processed. For more information, see [Enable simplified application autoscaling with the Kubernetes Event-Driven Autoscaling (KEDA) add-on (Preview)](keda-about).

## Manually scale AKS nodes

Note

If you created an AKS Automatic cluster, these steps don't apply because the cluster autoscales nodes.

If you created your AKS Standard cluster by using the commands in the previous tutorials, your cluster has three nodes. If you want to increase or decrease this amount, you can manually adjust the number of nodes.

The following example increases the number of nodes to five in the Kubernetes cluster named *myAKSCluster*. The command takes a couple of minutes to complete.

# [Azure CLI](#tab/azure-cli)
- Scale your cluster nodes using the [`az aks scale`](/en-us/cli/azure/aks#az-aks-scale) command.

    Once the cluster scales successfully, your output is similar to the following example output:

    ```azurecli
    az aks nodepool list --resource-group myResourceGroup --cluster-name myAKSCluster --query "[].{name:name,count:count}" -o table
    ```

    ```azurecli
    az aks scale --resource-group myResourceGroup --name myAKSCluster --node-count 5
    ```

    Once the cluster successfully scales, your output will be similar to following example output:

    ```output
    "aadProfile": null,
    "addonProfiles": null,
    "agentPoolProfiles": [
      {
        ...
        "count": 5,
        "mode": "System",
        "name": "nodepool1",
        "osDiskSizeGb": 128,
        "osDiskType": "Managed",
        "osType": "Linux",
        "ports": null,
        "vmSize": "Standard_DS2_v2",
        "vnetSubnetId": null
        ...
      }
      ...
    ]
    ```

# [Azure PowerShell](#tab/azure-powershell)
- Scale your cluster nodes using the [`Get-AzAksCluster`](/en-us/powershell/module/az.aks/get-azakscluster) and [`Set-AzAksCluster`](/en-us/powershell/module/az.aks/set-azakscluster) cmdlets.

    Once the cluster scales successfully, your output is similar to the following example output:

    ```azurepowershell
    (Get-AzAksCluster -ResourceGroupName myResourceGroup -Name myAKSCluster).AgentPoolProfiles | Select-Object Name,Count
    ```

    ```azurepowershell
    Get-AzAksCluster -ResourceGroupName myResourceGroup -Name myAKSCluster | Set-AzAksCluster -NodeCount 5
    ```

    Once the cluster successfully scales, your output will be similar to following example output:

    ```output
    ...
    ProvisioningState        : Succeeded
    MaxAgentPools            : 100
    KubernetesVersion        : 1.28
    CurrentKubernetesVersion : 1.28.9
    DnsPrefix                : myAKSCluster
    Fqdn                     : myakscluster-000a0aa0.hcp.eastus.azmk8s.io
    PrivateFQDN              :
    AzurePortalFQDN          : myakscluster-000a0aa0.portal.hcp.eastus.azmk8s.io
    AgentPoolProfiles        : {default}
    ...
    ResourceGroupName        : myResourceGroup
    Id                       : /subscriptions/aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e/resourcegroups/myResourceGroup/providers/Mic
                               rosoft.ContainerService/managedClusters/myAKSCluster
    Name                     : myAKSCluster
    Type                     : Microsoft.ContainerService/ManagedClusters
    Location                 : eastus
    Tags                     :
    ```

---

You can also autoscale the nodes in your cluster. For more information, see [Use the cluster autoscaler with node pools](cluster-autoscaler#enable-or-disable-the-cluster-autoscaler-on-node-pools).