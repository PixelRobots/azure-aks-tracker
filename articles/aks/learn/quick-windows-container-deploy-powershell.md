---
layout: Conceptual
title: Deploy a Windows Server Container on an Azure Kubernetes Service (AKS) Cluster using PowerShell - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/learn/quick-windows-container-deploy-powershell
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
description: Learn how to quickly deploy a Kubernetes cluster and deploy an application in a Windows Server container in Azure Kubernetes Service (AKS) using PowerShell.
ms.topic: quickstart
ms.date: 2026-07-13T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: devx-track-azurepowershell, aks-windows
locale: en-us
document_id: 6720eb8e-e45e-5c8c-3f20-d11729aa1bf8
document_version_independent_id: b2cdad79-458d-09b3-bed1-938fe40af997
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/learn/quick-windows-container-deploy-powershell.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurepowershell
toc_rel: ../toc.json
asset_id: aks/learn/quick-windows-container-deploy-powershell
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/learn/quick-windows-container-deploy-powershell.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/c783a8fb-cf36-41ad-90c6-0692a0540484
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 348f659d-f813-6f95-98fa-3184ed8f0fe3
---

# Deploy a Windows Server Container on an Azure Kubernetes Service (AKS) Cluster using PowerShell - Azure Kubernetes Service | Microsoft Learn

Azure Kubernetes Service (AKS) is a managed Kubernetes service that lets you quickly deploy and manage clusters. In this article, you use Azure PowerShell to deploy an AKS cluster that runs Windows Server containers. You also deploy an ASP.NET sample application in a Windows Server container to the cluster.

Note

To get started with quickly provisioning an AKS cluster, this article includes steps to deploy a cluster with default settings for evaluation purposes only. Before deploying a production-ready cluster, we recommend that you familiarize yourself with our [baseline reference architecture](/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks?toc=/azure/aks/toc.json&amp;bc=/azure/aks/breadcrumb/toc.json) to consider how it aligns with your business requirements.

## Before you begin

This quickstart assumes a basic understanding of Kubernetes concepts. For more information, see [Kubernetes core concepts for Azure Kubernetes Service (AKS)](../concepts-clusters-workloads).

- If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- For ease of use, try the PowerShell environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Quickstart for Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    If you want to use PowerShell locally, then install the [Az PowerShell](/en-us/powershell/azure/new-azureps-module-az) module and connect to your Azure account using the [Connect-AzAccount](/en-us/powershell/module/az.accounts/Connect-AzAccount) cmdlet. Make sure that you run the commands with administrative privileges. For more information, see [Install Azure PowerShell](/en-us/powershell/azure/install-az-ps).
- Make sure that the identity you're using to create your cluster has the appropriate minimum permissions. For more details on access and identity for AKS, see [Access and identity options for Azure Kubernetes Service (AKS)](../concepts-identity).
- If you have more than one Azure subscription, set the subscription that you wish to use for the quickstart by calling the [Set-AzContext](/en-us/powershell/module/az.accounts/set-azcontext) cmdlet. For more information, see [Manage Azure subscriptions with Azure PowerShell](/en-us/powershell/azure/manage-subscriptions-azureps#change-the-active-subscription).
- Specifying the `OsSKU` parameter requires PowerShell Az module version 9.2.0 or higher.

## Create a resource group

An [Azure resource group](/en-us/azure/azure-resource-manager/management/overview) is a logical group in which Azure resources are deployed and managed. When you create a resource group, you're asked to specify a location. This location is where resource group metadata is stored and where your resources run in Azure if you don't specify another region during resource creation.

- Create a resource group using the [`New-AzResourceGroup`](/en-us/powershell/module/az.resources/new-azresourcegroup) cmdlet. The following example creates a resource group named *myResourceGroup* in the *eastus* region.

    ```azurepowershell
    New-AzResourceGroup -Name myResourceGroup -Location eastus
    ```

    The following example output shows that the resource group was created successfully:

    ```output
    ResourceGroupName : myResourceGroup
    Location          : eastus
    ProvisioningState : Succeeded
    Tags              :
    ResourceId        : /subscriptions/a0a0a0a0-bbbb-cccc-dddd-e1e1e1e1e1e1/resourceGroups/myResourceGroup
    ```

## Create an AKS cluster

In this section, we create an AKS cluster with the following configuration:

- The cluster is configured with two nodes to ensure it operates reliably. A [node](../concepts-clusters-workloads#nodes) is an Azure virtual machine (VM) that runs the Kubernetes node components and container runtime.
- The `-WindowsProfileAdminUserName` and `-WindowsProfileAdminUserPassword` parameters set the administrator credentials for any Windows Server nodes on the cluster and must meet the [Windows Server password complexity requirements](/en-us/windows/security/threat-protection/security-policy-settings/password-must-meet-complexity-requirements#reference).
- The node pool uses `VirtualMachineScaleSets`.

Use the following steps to create the AKS cluster with Azure PowerShell:

1. Create the administrator credentials for your Windows Server containers using the following command. This command prompts you to enter a `WindowsProfileAdminUserName` and `WindowsProfileAdminUserPassword`. The password must be a minimum of 14 characters and meet the [Windows Server password complexity requirements](/en-us/windows/security/threat-protection/security-policy-settings/password-must-meet-complexity-requirements#reference).

    ```azurepowershell
    $AdminCreds = Get-Credential `
        -Message 'Please create the administrator credentials for your Windows Server containers'
    ```
2. Create your cluster using the [`New-AzAksCluster`](/en-us/powershell/module/az.aks/new-azakscluster) cmdlet and specify the `WindowsProfileAdminUserName` and `WindowsProfileAdminUserPassword` parameters.

    ```azurepowershell
    New-AzAksCluster -ResourceGroupName myResourceGroup `
        -Name myAKSCluster `
        -KubernetesVersion 1.33 `
        -NodeCount 2 `
        -NetworkPlugin azure `
        -NodeVmSetType VirtualMachineScaleSets `
        -WindowsProfileAdminUserName $AdminCreds.UserName `
        -WindowsProfileAdminUserPassword $secureString `
        -GenerateSshKey
    ```

    After a few minutes, the command completes and returns JSON-formatted information about the cluster. Occasionally, the cluster can take longer than a few minutes to provision. Allow up to 10 minutes for provisioning.

    If you get a password validation error, and the password that you set meets the length and complexity requirements, try creating your resource group in another region. Then try creating the cluster with the new resource group.

    If you don't specify an administrator username and password when creating the node pool, the username is set to *azureuser* and the password is set to a random value. For more information, see the [Windows Server FAQ](../windows-faq).

    The administrator username can't be changed, but you can change the administrator password that your AKS cluster uses for Windows Server nodes using `az aks update`. For more information, see the [Windows Server FAQ](../windows-faq).

    To run an AKS cluster that supports node pools for Windows Server containers, your cluster needs to use a network policy that uses [Azure CNI (advanced)](https://github.com/Azure/azure-container-networking/blob/master/docs/cni.md) network plugin. The `-NetworkPlugin azure` parameter specifies Azure CNI.

## Add a node pool

By default, an AKS cluster is created with a node pool that can run Linux containers. You must add another node pool that can run Windows Server containers alongside the Linux node pool.

To create a Windows node pool, you need to specify a supported `OsType` and `OsSku`. Use the information in the following table to determine which is appropriate for your cluster:

| `OsType` | `OsSku` | Default | Supported K8s versions | Details |
| --- | --- | --- | --- | --- |
| `windows` | `Windows2025` | Default in K8s 1.36+ | 1.32+ | Updated defaults: `containerd` 2.0, Generation 2 image is used by default. FIPS is required - include `-EnableFIPS` when you create the node pool. |
| `windows` | `Windows2022` | Default in K8s 1.25-1.35 | Not available in K8s 1.37+ | Retires in June 2028. Updated defaults: FIPS is enabled by default. |

Windows Server 2025 is the default operating system for Kubernetes version 1.36 and later. Windows Server 2022 is the default for Kubernetes versions 1.25-1.35. If you don't specify a particular OS SKU, Azure creates the new node pool with the default SKU for the version of Kubernetes used by the cluster.

Important

Starting on June 30, 2028, Azure Kubernetes Service (AKS) no longer supports Windows Server 2022 node pools. Windows Server 2022 isn't supported in Kubernetes version 1.37 and later. Starting on June 30, 2029, AKS will remove all existing node images for Windows Server 2022, meaning that scaling operations will fail. For more information on this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4168) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=ws2022-retirement-aks). To stay informed about announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

- Add a Windows Server node pool by using the [`New-AzAksNodePool`](/en-us/powershell/module/az.aks/new-azaksnodepool) cmdlet. The following command creates a new node pool named *npwin* and adds it to *myAKSCluster*. The command also uses the default subnet in the default virtual network created when running `New-AzAksCluster`. Windows Server 2025 node pools require a FIPS-enabled image, so the following command includes `-EnableFIPS`:

    ```azurepowershell
    New-AzAksNodePool -ResourceGroupName myResourceGroup `
        -ClusterName myAKSCluster `
        -VmSetType VirtualMachineScaleSets `
        -OsType Windows `
        -OsSKU Windows2025 `
        -EnableFIPS `
        -Name npwin
    ```

## Connect to the cluster

You use [kubectl](https://kubernetes.io/docs/reference/kubectl/), the Kubernetes command-line client, to manage your Kubernetes clusters. If you use Azure Cloud Shell, `kubectl` is already installed. If you want to install `kubectl` locally, you can use the `Install-AzAzAksCliTool` cmdlet.

1. Configure `kubectl` to connect to your Kubernetes cluster using the [`Import-AzAksCredential`](/en-us/powershell/module/az.aks/import-azakscredential) cmdlet. This command downloads credentials and configures the Kubernetes CLI to use them.

    ```azurepowershell
    Import-AzAksCredential -ResourceGroupName myResourceGroup -Name myAKSCluster
    ```
2. Verify the connection to your cluster using the [`kubectl get`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command, which returns a list of the cluster nodes.

    ```bash
    kubectl get nodes -o wide
    ```

    The following example output shows all the nodes in the cluster. Make sure the status of all nodes is **Ready**:

    ```output
    NAME                                STATUS   ROLES   AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION      CONTAINER-RUNTIME
    aks-nodepool1-20786768-vmss000000   Ready    agent   22h   v1.33.12   10.224.0.4    <none>        Ubuntu 22.04.5 LTS               5.15.0-1116-azure   containerd://1.7.33-1
    aks-nodepool1-20786768-vmss000001   Ready    agent   22h   v1.33.12   10.224.0.33   <none>        Ubuntu 22.04.5 LTS               5.15.0-1116-azure   containerd://1.7.33-1
    aksnpwin000000                      Ready    agent   20h   v1.33.12   10.224.0.62   <none>        Windows Server 2025 Datacenter   10.0.26100.32995    containerd://2.0.4+azure
    ```

## Deploy the application

A Kubernetes manifest file defines a desired state for the cluster, such as what container images to run. In this article, you use a manifest to create all objects needed to run the ASP.NET sample application in a Windows Server container. This manifest includes a [Kubernetes deployment](../concepts-clusters-workloads#deployments-and-yaml-manifests) for the ASP.NET sample application and an external [Kubernetes service](../concepts-network-services) to access the application from the internet.

The ASP.NET sample application is part of the [.NET Framework Samples](https://hub.docker.com/_/microsoft-dotnet-framework-samples/) and runs in a Windows Server container. AKS requires Windows Server containers to be based on images of *Windows Server 2022* or greater. The Kubernetes manifest file must also define a [node selector](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) to tell your AKS cluster to run your ASP.NET sample application's pod on a node that can run Windows Server containers.

1. Create a file named `sample.yaml` and copy in the following YAML definition:

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

    The following example output shows the deployment and service created successfully:

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

    The following example output shows a valid public IP address assigned to the service:

    ```output
    sample  LoadBalancer   10.0.37.27   52.179.23.131   80:30572/TCP   2m
    ```
4. See the sample app in action by opening a web browser to the external IP address of your service.

    [![Screenshot of browsing to ASP.NET sample application.](media/quick-windows-container-deploy-powershell/asp-net-sample-app.png)](media/quick-windows-container-deploy-powershell/asp-net-sample-app.png#lightbox)

## Delete resources

If you don't plan on going through the [AKS tutorial](../tutorial-kubernetes-prepare-app), then delete your cluster to avoid incurring Azure charges.

- Remove the resource group, container service, and all related resources using the [`Remove-AzResourceGroup`](/en-us/powershell/module/az.resources/remove-azresourcegroup) cmdlet.

    ```azurepowershell
    Remove-AzResourceGroup -Name myResourceGroup
    ```

    Note

    The AKS cluster was created with system-assigned managed identity (default identity option used in this quickstart). The Azure platform manages this identity, so it doesn't require removal.