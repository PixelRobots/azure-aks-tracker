---
layout: Conceptual
title: Deploy a Windows Server container on an Azure Kubernetes Service (AKS) cluster using the Azure portal - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/learn/quick-windows-container-deploy-portal
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
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn how to quickly deploy a Kubernetes cluster and deploy an application in a Windows Server container in Azure Kubernetes Service (AKS) using the Azure portal.
ms.topic: quickstart
ms.custom: azure-kubernetes-service, aks-windows
ms.date: 2026-07-13T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 918b4dff-806d-96a4-4777-5c4152eb7b71
document_version_independent_id: 4f23e28d-94e6-160a-ec4f-590d22ca167a
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/learn/quick-windows-container-deploy-portal.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,azurepowershell
toc_rel: ../toc.json
asset_id: aks/learn/quick-windows-container-deploy-portal
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/learn/quick-windows-container-deploy-portal.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
platformId: d2943ab8-82c2-1d32-d43b-93c72f8f2e5b
---

# Deploy a Windows Server container on an Azure Kubernetes Service (AKS) cluster using the Azure portal - Azure Kubernetes Service | Microsoft Learn

Azure Kubernetes Service (AKS) is a managed Kubernetes service that lets you quickly deploy and manage clusters. In this article, you deploy an AKS cluster that runs Windows Server containers using the Azure portal. You also deploy an ASP.NET sample application in a Windows Server container to the cluster.

Note

To get started with quickly provisioning an AKS cluster, this article includes steps to deploy a cluster with default settings for evaluation purposes only. Before deploying a production-ready cluster, we recommend that you familiarize yourself with our [baseline reference architecture](/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks?toc=/azure/aks/toc.json&amp;bc=/azure/aks/breadcrumb/toc.json) to consider how it aligns with your business requirements.

## Before you begin

This quickstart assumes a basic understanding of Kubernetes concepts. For more information, see [Kubernetes core concepts for Azure Kubernetes Service (AKS)](../concepts-clusters-workloads).

- If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- If you're unfamiliar with the Azure Cloud Shell, review [Overview of Azure Cloud Shell](/en-us/azure/cloud-shell/overview).
- Make sure that the identity you're using to create your cluster has the appropriate minimum permissions. For more details on access and identity for AKS, see [Access and identity options for Azure Kubernetes Service (AKS)](../concepts-identity).

Important

Starting on June 30, 2028, Azure Kubernetes Service (AKS) no longer supports Windows Server 2022 node pools. Windows Server 2022 isn't supported in Kubernetes version 1.37 and later. Starting on June 30, 2029, AKS will remove all existing node images for Windows Server 2022, meaning that scaling operations will fail. For more information on this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4168) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=ws2022-retirement-aks). To stay informed about announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

## Create an AKS cluster

1. Sign in to the [Azure portal](https://portal.azure.com).
2. On the Azure portal home page, select **Create a resource**.
3. In the **Categories** section, select **Containers** &gt; **Azure Kubernetes Service (AKS)**.
4. On the **Basics** tab, configure the following settings:

    - Under **Project details**:
        - **Subscription**: Select the Azure subscription you want to use for this AKS cluster.
        - **Resource group**: Select **Create new**, enter a resource group name, such as *myResourceGroup*, and then select **Ok**. While you can select an existing resource group, for testing or evaluation purposes, we recommend creating a resource group to temporarily host these resources and avoid impacting your production or development workloads.
    - Under **Cluster details**:
        - **Cluster preset configuration**: Select **Dev/Test**. For more details on preset configurations, see [Cluster configuration presets in the Azure portal](../quotas-skus-regions#cluster-configuration-presets-in-the-azure-portal).

            Note

            You can change the preset configuration when creating your cluster by selecting **Compare presets** and choosing a different option. [![Screenshot of Create AKS cluster - portal preset options.](media/quick-kubernetes-deploy-portal/cluster-presets.png)](media/quick-kubernetes-deploy-portal/cluster-presets.png#lightbox)
        - **Kubernetes cluster name**: Enter a cluster name, such as *myAKSCluster*.
        - **Region**: Select a region, such as *East US 2*.
        - **Availability zones**: Select **None**.
        - **AKS pricing tier**: Select **Free**.
        - Leave the default values for the remaining settings, and select **Next**.

            [![Screenshot showing how to configure an AKS cluster in Azure portal.](media/quick-kubernetes-deploy-portal/create-cluster.png)](media/quick-kubernetes-deploy-portal/create-cluster.png#lightbox)
5. On the **Node pools** tab, configure the following settings:

    - Select **Add node pool** and enter a **Node pool name**, such as *npwin*. For a Windows node pool, the name must be *six characters or fewer*.
    - **Mode**: Select **User**.
    - **OS SKU**: Select **Windows 2025**. Windows Server 2025 requires a FIPS-enabled image, so enable FIPS for the node pool.
    - **Availability zones**: Select **None**.
    - Leave the **Enable Azure Spot instances** checkbox unchecked.
    - **Node size**: Select **Choose a size**. On the **Select a VM size** page, select **D2s\_v3**, and then select **Select**.
    - Leave the default values for the remaining settings, and select **Add**.

        [![Screenshot showing how to create a node pool running Windows Server 2025.](media/quick-windows-container-deploy-portal/add-node-pool-windows.png)](media/quick-windows-container-deploy-portal/add-node-pool-windows.png#lightbox)
6. Select **Review + create** to run validation on the cluster configuration. After validation completes, select **Create**.

    It takes a few minutes to create the AKS cluster. When your deployment is complete, navigate to your resource by selecting **Go to resource**, or by browsing to the AKS cluster resource group and selecting the AKS resource.

## Connect to the cluster

You use [kubectl](https://kubernetes.io/docs/reference/kubectl/), the Kubernetes command-line client, to manage your Kubernetes clusters. `kubectl` is already installed if you use Azure Cloud Shell. If you're unfamiliar with the Cloud Shell, review [Overview of Azure Cloud Shell](/en-us/azure/cloud-shell/overview).

# [Azure CLI](#tab/azure-cli)
1. Open Cloud Shell by selecting the `>_` button at the top of the Azure portal page.
2. Configure `kubectl` to connect to your Kubernetes cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command. The following command downloads credentials and configures the Kubernetes CLI to use them.

    ```azurecli
    az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
    ```
3. Verify the connection to your cluster using the `kubectl get nodes` command, which returns a list of the cluster nodes.

    ```bash
    kubectl get nodes -o wide
    ```

    The following sample output shows all the nodes in the cluster. Make sure the status of all nodes is *Ready*:

    ```output
    NAME                                STATUS   ROLES   AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION      CONTAINER-RUNTIME
    aks-nodepool1-20786768-vmss000000   Ready    agent   22h   v1.33.12   10.224.0.4    <none>        Ubuntu 22.04.5 LTS               5.15.0-1116-azure   containerd://1.7.33-1
    aks-nodepool1-20786768-vmss000001   Ready    agent   22h   v1.33.12   10.224.0.33   <none>        Ubuntu 22.04.5 LTS               5.15.0-1116-azure   containerd://1.7.33-1
    aksnpwin000000                      Ready    agent   20h   v1.33.12   10.224.0.62   <none>        Windows Server 2025 Datacenter   10.0.26100.32995    containerd://2.0.4+azure
    ```

# [Azure PowerShell](#tab/azure-powershell)
1. Open Cloud Shell by selecting the `>_` button at the top of the Azure portal page.
2. Configure `kubectl` to connect to your Kubernetes cluster using the [`Import-AzAksCredential`](/en-us/powershell/module/az.aks/import-azakscredential) cmdlet. The following command downloads credentials and configures the Kubernetes CLI to use them.

    ```azurepowershell
    Import-AzAksCredential -ResourceGroupName myResourceGroup -Name myAKSCluster
    ```
3. Verify the connection to your cluster using the `kubectl get nodes` command, which returns a list of the cluster nodes.

    ```bash
    kubectl get nodes -o wide
    ```

    The following sample output shows all the nodes in the cluster. Make sure the status of all nodes is *Ready*:

    ```output
    NAME                                STATUS   ROLES   AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION      CONTAINER-RUNTIME
    aks-nodepool1-20786768-vmss000000   Ready    agent   22h   v1.33.12   10.224.0.4    <none>        Ubuntu 22.04.5 LTS               5.15.0-1116-azure   containerd://1.7.33-1
    aks-nodepool1-20786768-vmss000001   Ready    agent   22h   v1.33.12   10.224.0.33   <none>        Ubuntu 22.04.5 LTS               5.15.0-1116-azure   containerd://1.7.33-1
    aksnpwin000000                      Ready    agent   20h   v1.33.12   10.224.0.62   <none>        Windows Server 2025 Datacenter   10.0.26100.32995    containerd://2.0.4+azure
    ```

---

## Deploy the application

A Kubernetes manifest file defines a desired state for the cluster, such as which container images to run. In this quickstart, you use a manifest file to create all objects needed to run the ASP.NET sample application in a Windows Server container. This manifest file includes a [Kubernetes deployment](../concepts-clusters-workloads#deployments-and-yaml-manifests) for the ASP.NET sample application and an external [Kubernetes service](../concepts-network-services) to access the application from the internet.

The ASP.NET sample application is provided as part of the [.NET Framework Samples](https://hub.docker.com/_/microsoft-dotnet-framework-samples/) and runs in a Windows Server container. The Kubernetes manifest file must define a [node selector](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) to tell your AKS cluster to run your ASP.NET sample application's pod on a node that can run Windows Server containers.

1. Create a file named `sample.yaml` and paste in the following YAML definition.

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: sample
      labels:
        app: sample
    spec:
      replicas: 1
      template:
        metadata:
          name: sample
          labels:
            app: sample
        spec:
          nodeSelector:
            "kubernetes.io/os": windows
          containers:
          - name: sample
            image: mcr.microsoft.com/dotnet/framework/samples:aspnetapp
            resources:
              limits:
                cpu: 1
                memory: 800M
            ports:
              - containerPort: 80
      selector:
        matchLabels:
          app: sample
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: sample
    spec:
      type: LoadBalancer
      ports:
      - protocol: TCP
        port: 80
      selector:
        app: sample
    ```

    For a breakdown of YAML manifest files, see [Deployments and YAML manifests](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).

    If you create and save the YAML file locally, then you can upload the manifest file to your default directory in CloudShell by selecting the **Upload/Download files** button and selecting the file from your local file system.
2. Deploy the application using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command and specify the name of your YAML manifest.

    ```bash
    kubectl apply -f sample.yaml
    ```

    The following sample output shows the deployment and service created successfully:

    ```output
    deployment.apps/sample created
    service/sample created
    ```

## Test the application

When the application runs, a Kubernetes service exposes the application front end to the internet. This process can take a few minutes to complete. Occasionally, the service can take longer than a few minutes to provision. Allow up to 10 minutes for provisioning.

1. Check the status of the deployed pods using the [`kubectl get pods`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command. Make all pods are `Running` before proceeding.

    ```bash
    kubectl get pods
    ```
2. Monitor progress using the [`kubectl get service`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command with the `--watch` argument.

    ```bash
    kubectl get service sample --watch
    ```

    Initially, the output shows the *EXTERNAL-IP* for the sample service as *pending*:

    ```output
    NAME               TYPE           CLUSTER-IP   EXTERNAL-IP   PORT(S)        AGE
    sample             LoadBalancer   10.0.37.27   <pending>     80:30572/TCP   6s
    ```
3. When the *EXTERNAL-IP* address changes from *pending* to an actual public IP address, use `CTRL-C` to stop the `kubectl` watch process.
4. See the sample app in action by opening a web browser to the external IP address of your service.

    [![Screenshot of browsing to ASP.NET sample application.](media/quick-windows-container-deploy-portal/asp-net-sample-app.png)](media/quick-windows-container-deploy-portal/asp-net-sample-app.png#lightbox)

## Delete resources

If you don't plan on going through the [AKS tutorial](../tutorial-kubernetes-prepare-app), you should delete your cluster to avoid incurring Azure charges.

1. In the Azure portal, navigate to your resource group.
2. Select **Delete resource group**.
3. Enter the name of your resource group to confirm deletion and select **Delete**.
4. In the **Delete confirmation** dialog box, select **Delete**.

    Note

    The AKS cluster was created with system-assigned managed identity (default identity option used in this quickstart), the identity is managed by the platform and does not require removal.