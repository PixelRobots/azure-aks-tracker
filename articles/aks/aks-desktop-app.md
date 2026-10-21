---
layout: Conceptual
title: Deploy an Application using AKS Desktop for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/aks-desktop-app
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
description: Learn how to deploy a containerized application to AKS using AKS desktop without writing Kubernetes manifests.
ms.subservice: aks-developer
ms.reviewer: schaffererin
author: danielsollondon
ms.topic: how-to
ms.date: 2026-04-16T00:00:00.0000000Z
ms.author: danis
locale: en-us
document_id: 78884c9b-4113-2999-04af-8f37fd3d1f51
document_version_independent_id: c14b457c-bd39-c6b2-ab71-4707f79a0c02
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/aks-desktop-app.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/aks-desktop-app
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/aks-desktop-app.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 1ac3d4ad-2272-6a12-632b-2750b1b2cd62
---

# Deploy an Application using AKS Desktop for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article shows you how to sign in, add a cluster, create a [Project](aks-desktop-overview#projects-in-aks-desktop), deploy an application, and view metrics in AKS desktop for Azure Kubernetes Service (AKS). For an overview of AKS desktop, see [AKS desktop overview](aks-desktop-overview).

## Prerequisites

- An Azure subscription. If you don't have an Azure subscription, you can create a free [Azure account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- An existing [AKS Automatic cluster](intro-aks-automatic) with Microsoft Entra authentication. The cluster needs to be available through the Azure portal or an [Azure Container Registry (ACR)](/en-us/azure/container-registry/container-registry-intro) with your application image that you want to deploy.
- Azure CLI version 2.64.0 or later. Check your version using the [`az --version`](/en-us/cli/azure/reference-index#az-version) command. To install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- The `aks-preview` Azure CLI extension. Install it using the `az extension add --name aks-preview` command.
- [AKS desktop](https://github.com/Azure/aks-desktop/releases) installed. AKS desktop supports the following operating systems (OS): Windows, Linux, and Mac.
- Appropriate Role-Based Access Control (RBAC) roles assigned for your team. For more information, see [Set up permissions and RBAC for AKS desktop](aks-desktop-permissions).

## Sign in to your account

The first time you open AKS desktop, you need to sign into your Azure account. Signing in allows you to see AKS clusters and Projects that you have access to.

1. In the left pane, select **Home** &gt; **Sign in with Azure**.
2. Select the account that you want to use.

Once signed in, you have the ability to add clusters that you have access to into AKS desktop.

## Add a cluster to AKS desktop

Note

AKS Automatic is the recommended cluster type to use with AKS desktop. While AKS Standard SKU works in AKS desktop, you might not see the full benefits of the Project view. AKS Automatic includes built-in metrics, observability, and other tools that enable AKS desktop to surface important insights for users.

When you sign in, you can add clusters into AKS desktop from your Azure subscription or by uploading a kubeconfig file. If you have a single Azure subscription, AKS desktop autopopulates your subscription once you sign in.

# [Use your Azure subscription](#tab/azure-subscription)
1. Select **Add from Azure Subscription**.
2. Enter the name of your Azure subscription if you have more than one. (Alternatively, select the arrow to open the drop-down list, and then select your Azure subscription.)
3. Select your cluster, and then select **Register Cluster**.

    ![A video demonstrating how to add a cluster to the AKS desktop app.](media/aks-desktop-app/aks-desktop-app-add-cluster.gif)

# [Upload a kubeconfig file](#tab/kubeconfig-file)
1. Select **Home** &gt; **Add Other Clusters** &gt; **Load from KubeConfig**. (If you followed the Azure subscription method first, select **Add Cluster** &gt; **Load from KubeConfig**.)
2. Select one of the following options:

    - Select **Choose file**, locate and select your kubeconfig file, and then select **Open**.
    - Drag and drop your kubeconfig file into AKS desktop, and then select **Next**.

---

## Add additional clusters to AKS desktop

1. In the bottom left pane, select **Add Cluster**. You can choose to load from your kubeconfig file or from Azure.
2. Under **Providers**, select **Add**.
3. Enter the name of your Azure subscription if you have more than one. (Alternatively, select the arrow to open the drop-down list, and then select your Azure subscription.)
4. Select your cluster, and then select **Register Cluster**.

    ![A video demonstrating how to add additional clusters to the AKS desktop app.](media/aks-desktop-app/aks-desktop-app-add-additional-clusters.gif)

## Remove a cluster from AKS desktop

Delete a cluster from AKS desktop and your kubeconfig using the following steps:

1. Under the **Home** screen, select the box next to the cluster you want to remove.
2. Under **Actions**, select the three dots, and then select **Delete**.
3. The **Delete Cluster** window appears asking if you want to remove the specified cluster. Select **Delete**.

    ![A video demonstrating how to remove a cluster from the AKS desktop app.](media/aks-desktop-app/aks-desktop-app-remove-cluster.gif)

## Create a new Project in AKS desktop

When you create a Project on a cluster, any user with access to the associated namespace can view the Project. Namespace access and labeling determine which users can see each Project, since Projects are tied to namespaces. For more information, see the [Overview of Projects in AKS desktop](aks-desktop-projects).

There are three methods you can choose from to deploy your application using AKS desktop: **AKS managed Project**, **YAML Project**, or **New Project**.

# [Create an AKS managed project](#tab/aks-managed-project)
Important

Make sure you register the namespace preview feature for first time use. Under **Feature Flag Required**, select **Register ManagedNamespacePreview Feature**.

1. Provide a Project name. Adding a Project description is optional.
2. Select your subscription, your cluster, and then select **Next**.
3. Under **Networking Policies**, select the ingress and egress for your network traffic, and then select **Next**.
4. Under **Compute Quota**, adjust the quota based on your needs, and then select **Next**.
5. Under **Access**, assign the Project to one or more users and permission level for each under **Role**, and then select **Next**.
6. Under **Review**, verify the settings for your Project, and then select **Create Project**.
7. Add your application name, and then select **Create Application**.

    ![A video demonstrating how to create a new AKS-managed Project in the AKS desktop app.](media/aks-desktop-app/aks-desktop-app-create-new-project-aks-managed.gif)

# [Create a YAML project](#tab/yaml-project)
1. Provide a Project name.
2. Select a cluster to add to your Project.
3. Under **Load resources**, you can choose the following:

    - Select a `.yaml` or `.yml` file to load. You can also drag and drop your file into AKS desktop. Then select **Create**.
    - Select **Load from URL**, paste your YAML URL, and then select **Load** &gt; **Create**.

# [Create a new project](#tab/new-project)
1. Provide a Project name.
2. Select a cluster to add to your Project. You can add more once a cluster is selected.
3. Use an existing namespace or type a new namespace to use.
4. Select **Create**.

---

## Remove a Project from AKS desktop

1. In the left pane, select the **Home** button.
2. Under **Projects**, select your Project from the **Name** column.
3. Within your Project, select the trash can icon.
4. Under the **Delete Project** window, select **Delete Project** to remove your Project from the given namespace.

    Note

    If you also want to the delete the namespace along with your Project (which also removes associated resources), select **Also delete the namespaces** &gt; **Delete Project**.

## Deploy an application into a Project in AKS desktop

Tip

When you deploy an application to AKS Desktop for the first time, metrics might take 5–10 minutes to appear as data begins flowing into managed Prometheus. After this initial delay, metrics should load within seconds. If metrics don't appear, try refreshing AKS desktop.

Always create a new Project when deploying a new application. Once you create your first Project, AKS desktop places you directly into the newly created Project. Within your Project, select **Deploy Application**. There are two sources you can choose from to deploy your application: **Container Image** or **Kubernetes YAML**.

# [Container Image deployment](#tab/container-image)
1. Provide a name for your application.
2. Under **Container image**, paste the path to your container image. It must be in the format `<YourACR>.azurecr.io/<YourImageName>:<YourImageTag>`.

    Note

    You can't use the **latest** tag for your container images, as it results in best practice violation on AKS Automatic.
3. Select your replica amount.
4. Configure settings for the following sections, selecting **Continue** after each section:

    - **Networking**: Input your network port, select whether your application is meant for internal only or for public access.
    - **Health checks**: Select which checks you want to perform.
    - **Resource Limits**: Configure per your application requirements.
    - **Environment Variables**: Add your `key:value` pair variable for your application.
    - **HPA**: Select whether to enable Horizontal Pod Autoscaler (HPA) for your application. HPA automatically adjusts the number of pods in response to resource usage, helping maintain optimal performance and resource efficiency. If you enable HPA, configure per your application requirements.
    - **Advanced**: Select any extra settings to apply.
5. Review your application deployment configuration.
6. Select **Deploy** &gt; **Close**.

# [Kubernetes YAML deployment](#tab/kubernetes-yaml)
1. Select **Upload files** to upload one or more `.yaml` or `.yml` files, and then select **Next**. (Alternatively, you can paste the contents within your YAML files into the text editor, and then select **Next**.)
2. Review the resources to deploy.
3. Select **Deploy** &gt; **Close**.

---

## View cluster data and metrics in AKS desktop

AKS desktop provides a unified view of your application resources, health status, resource quotas, workloads, and configuration settings all in a single dashboard. You can use the tabs to view detailed information and manage each aspect of your deployment. You must have a cluster added into AKS desktop to view this information.

View cluster data and metrics in AKS desktop using the following steps:

1. Select **Home**.
2. Under the **Name** tab, select the cluster you want to view.
3. In the left pane, select the specific setting to view detailed cluster data and metrics.