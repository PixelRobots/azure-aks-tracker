---
layout: Conceptual
title: Deploy to Azure Kubernetes Service with Azure Pipelines - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/devops-pipeline
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
description: Build and push images to Azure Container Registry; Deploy to Azure Kubernetes Service with Azure Pipelines
ms.topic: how-to
ms.author: jukullam
author: juliakm
ms.date: 2025-01-30T00:00:00.0000000Z
ms.custom: devops-pipelines-deploy, devx-track-azurepowershell
locale: en-us
document_id: f37ab6e7-be48-b5a8-b1da-255f2c2b17f9
document_version_independent_id: 8926f12c-7880-dc90-1267-d52b5badcf7c
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/devops-pipeline.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/devops-pipeline
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/devops-pipeline.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/7960090f-b1c1-4f33-accd-7f42c377c619
- https://authoring-docs-microsoft.poolparty.biz/devrel/9bdc1705-9b40-49d6-8377-caa0b71fda66
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/61f08768-d46a-4092-af3e-b449ce915a2b
- https://authoring-docs-microsoft.poolparty.biz/devrel/686ed158-d915-41e9-9760-efa46ba88f6d
platformId: bdceffec-0bbb-c942-5890-efef2ba412b5
---

# Deploy to Azure Kubernetes Service with Azure Pipelines - Azure Kubernetes Service | Microsoft Learn

**Azure DevOps Services**

Use [Azure Pipelines](/en-us/azure/devops/pipelines/) to automatically deploy to Azure Kubernetes Service (AKS). Azure Pipelines lets you build, test, and deploy with continuous integration (CI) and continuous delivery (CD) using [Azure DevOps](/en-us/azure/devops/).

In this article, you'll learn how to create a pipeline that continuously builds and deploys your app. Every time you change your code in a repository that contains a Dockerfile, the images are pushed to your Azure Container Registry, and the manifests are then deployed to your AKS cluster.

## Prerequisites

- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- An Azure Resource Manager service connection. [Create an Azure Resource Manager service connection](/en-us/azure/devops/pipelines/library/connect-to-azure#create-an-azure-resource-manager-service-connection-using-automated-security).
- A GitHub account. Create a free [GitHub account](https://github.com/join) if you don't have one already.

## Get the code

Fork the following repository containing a sample application and a Dockerfile:

```
https://github.com/MicrosoftDocs/pipelines-javascript-docker
```

## Create the Azure resources

Sign in to the [Azure portal](https://portal.azure.com/), and then select the [Cloud Shell](/en-us/azure/cloud-shell/overview) button in the upper-right corner. Use Azure CLI or PowerShell to create an AKS cluster.

### Create a container registry

# [Azure CLI](#tab/cli)
```azurecli
# Create a resource group
az group create --name myapp-rg --location eastus

# Create a container registry
az acr create --resource-group myapp-rg --name mycontainerregistry --sku Basic

# Create a Kubernetes cluster
az aks create \
    --resource-group myapp-rg \
    --name myapp \
    --node-count 1 \
    --enable-addons monitoring \
    --generate-ssh-keys
```

# [PowerShell](#tab/powershell)
```powershell
# Install Azure PowerShell
Install-Module -Name Az -Repository PSGallery -Force

# The Microsoft.OperationsManagement resource provider must be registered. This is a one-time activity per subscription.
Register-AzResourceProvider -ProviderNamespace Microsoft.OperationsManagement

# Create a resource group
New-AzResourceGroup -Name myapp-rg -Location eastus

# Create a container registry
New-AzContainerRegistry -ResourceGroupName myapp-rg -Name myContainerRegistry -Sku Basic -Location eastus

# Create a log analytics workspace (or use an existing one)
New-AzOperationalInsightsWorkspace -ResourceGroupName myapp-rg -Name myWorkspace -Location eastus

# Create an AKS cluster with monitoring add-on enabled
$aksParameters = @{ 
  ResourceGroupName = 'myapp-rg'
  Name = 'myapp'
  NodeCount = 1
  AddOnNameToBeEnabled = 'Monitoring'
  GenerateSshKey = $true
  WorkspaceResourceId = '/subscriptions/<subscription-id>/resourceGroups/myapp-rg/providers/Microsoft.OperationalInsights/workspaces/myWorkspace'
}

New-AzAksCluster @aksParameters
```

---

## Sign in to Azure Pipelines

Sign in to [Azure Pipelines](https://azure.microsoft.com/services/devops/pipelines). After you sign in, your browser goes to `https://dev.azure.com/my-organization-name` and displays your Azure DevOps dashboard.

Within your selected organization, create a *project*. If you don't have any projects in your organization, you see a **Create a project to get started** screen. Otherwise, select the **Create Project** button in the upper-right corner of the dashboard.

## Create the pipeline

### Connect and select your repository

1. Sign in to your Azure DevOps organization and go to your project.
2. Go to **Pipelines**, and then select **New pipeline**.
3. Do the steps of the wizard by first selecting **GitHub** as the location of your source code.
4. You might be redirected to GitHub to sign in. If so, enter your GitHub credentials.
5. When you see the list of repositories, select your repository.
6. You might be redirected to GitHub to install the Azure Pipelines app. If so, select **Approve & install**.
7. Select **Deploy to Azure Kubernetes Service**.
8. If you're prompted, select the subscription in which you created your registry and cluster.
9. Select the `myapp` cluster.
10. For **Namespace**, select **Existing**, and then select **default**.
11. Select the name of your container registry.
12. You can leave the image name set to the default.
13. Set the service port to 8080.
14. Set the **Enable Review App for Pull Requests** checkbox for [review app](/en-us/azure/devops/pipelines/process/environments-kubernetes) related configuration to be included in the pipeline YAML autogenerated in subsequent steps.
15. Select **Validate and configure**.

    As Azure Pipelines creates your pipeline, the process will:

    - Create a *Docker registry service connection* to enable your pipeline to push images into your container registry.
    - Create an *environment* and a Kubernetes resource within the environment. For an RBAC-enabled cluster, the created Kubernetes resource implicitly creates ServiceAccount and RoleBinding objects in the cluster so that the created ServiceAccount can't perform operations outside the chosen namespace.
    - Generate an *azure-pipelines.yml* file, which defines your pipeline.
    - Generate Kubernetes manifest files. These files are generated by hydrating the [deployment.yml](https://github.com/Microsoft/azure-pipelines-yaml/blob/master/templates/resources/k8s/deployment.yml) and [service.yml](https://github.com/Microsoft/azure-pipelines-yaml/blob/master/templates/resources/k8s/service.yml) templates based on selections you made. When you're ready, select **Save and run**.
16. Select **Save and run**.
17. You can change the **Commit message** to something like *Add pipeline to our repository*. When you're ready, select **Save and run** to commit the new pipeline into your repo, and then begin the first run of your new pipeline!

## See your app deploy

As your pipeline runs, watch as your build stage, and then your deployment stage, go from blue (running) to green (completed). You can select the stages and jobs to watch your pipeline in action.

Note

If you're using a Microsoft-hosted agent, you must add the IP range of the Microsoft-hosted agent to your firewall. Get the weekly list of IP ranges from the [weekly JSON file](https://www.microsoft.com/download/details.aspx?id=56519), which is published every Wednesday. The new IP ranges become effective the following Monday. For more information, see [Microsoft-hosted agents](/en-us/azure/devops/pipelines/agents/hosted?tabs=yaml&amp;view=azure-devops&amp;preserve-view=true#networking). To find the IP ranges that are required for your Azure DevOps organization, learn how to [identify the possible IP ranges for Microsoft-hosted agents](/en-us/azure/devops/pipelines/agents/hosted?tabs=yaml&amp;view=azure-devops&amp;preserve-view=true#to-identify-the-possible-ip-ranges-for-microsoft-hosted-agents).

After the pipeline run is finished, explore what happened and then go see your app deployed. From the pipeline summary:

1. Select the **Environments** tab.
2. Select **View environment**.
3. Select the instance of your app for the namespace you deployed to. If you used the defaults, then it is the **myapp** app in the **default** namespace.
4. Select the **Services** tab.
5. Select and copy the external IP address to your clipboard.
6. Open a new browser tab or window and enter &lt;IP address&gt;:8080.

If you're building our sample app, then *Hello world* appears in your browser.

## How the pipeline builds

When you finished selecting options and then proceeded to validate and configure the pipeline Azure Pipelines created a pipeline for you, using the *Deploy to Azure Kubernetes Service* template.

The build stage uses the [Docker task](/en-us/azure/devops/pipelines/tasks/build/docker) to build and push the image to the Azure Container Registry.

```YAML
- stage: Build
  displayName: Build stage
  jobs:  
  - job: Build
    displayName: Build job
    pool:
      vmImage: $(vmImageName)
    steps:
    - task: Docker@2
      displayName: Build and push an image to container registry
      inputs:
        command: buildAndPush
        repository: $(imageRepository)
        dockerfile: $(dockerfilePath)
        containerRegistry: $(dockerRegistryServiceConnection)
        tags: |
          $(tag)
          
    - task: PublishPipelineArtifact@1
      inputs:
        artifactName: 'manifests'
        path: 'manifests'
```

The deployment job uses the *Kubernetes manifest task* to create the `imagePullSecret` required by Kubernetes cluster nodes to pull from the Azure Container Registry resource. Manifest files are then used by the Kubernetes manifest task to deploy to the Kubernetes cluster. The manifest files, `service.yml` and `deployment.yml`, were generated when you used the **Deploy to Azure Kubernetes Service** template.

```YAML
- stage: Deploy
  displayName: Deploy stage
  dependsOn: Build
  jobs:
  - deployment: Deploy
    displayName: Deploy job
    pool:
      vmImage: $(vmImageName)
    environment: 'myenv.aksnamespace' #customize with your environment
    strategy:
      runOnce:
        deploy:
          steps:
          - task: DownloadPipelineArtifact@2
            inputs:
              artifactName: 'manifests'
              downloadPath: '$(System.ArtifactsDirectory)/manifests'

          - task: KubernetesManifest@1
            displayName: Create imagePullSecret
            inputs:
              action: 'createSecret'
              connectionType: 'kubernetesServiceConnection'
              kubernetesServiceConnection: 'myapp-default' #customize for your Kubernetes service connection
              secretType: 'dockerRegistry'
              secretName: '$(imagePullSecret)'
              dockerRegistryEndpoint: '$(dockerRegistryServiceConnection)'

          - task: KubernetesManifest@1
            displayName: Deploy to Kubernetes cluster
            inputs:
              action: 'deploy'
              connectionType: 'kubernetesServiceConnection'
              kubernetesServiceConnection: 'myapp-default' #customize for your Kubernetes service connection
              manifests: |
                $(Pipeline.Workspace)/manifests/deployment.yml
                $(Pipeline.Workspace)/manifests/service.yml
              containers: '$(containerRegistry)/$(imageRepository):$(tag)'
              imagePullSecrets: '$(imagePullSecret)'
```

## Clean up resources

Whenever you're done with the resources you created, you can use the following command to delete them:

```azurecli
az group delete --name myapp-rg
```

Enter `y` when you're prompted.