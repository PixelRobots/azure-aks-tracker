---
layout: Conceptual
title: Automate app deployment to Azure Kubernetes Service (AKS) with CI/CD via Automated deployments Automated deployments - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/automated-deployments
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
description: Learn how to use automated deployments to simplify the process of adding GitHub Actions or Azure DevOps Pipelines to your Azure Kubernetes Service (AKS) project.
author: schaffererin
ms.author: schaffererin
ms.date: 2023-05-10T00:00:00.0000000Z
ms.subservice: aks-developer
ms.topic: how-to
ms.custom:
- build-2023
- build-2024
- build-2025
locale: en-us
document_id: 19cd9ec2-73fe-3a82-c79c-18205275746c
document_version_independent_id: 91c5fc7d-8baf-d79a-0ae4-a1a3588d274d
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/automated-deployments.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/automated-deployments
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/automated-deployments.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/9bdc1705-9b40-49d6-8377-caa0b71fda66
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/686ed158-d915-41e9-9760-efa46ba88f6d
platformId: f52a141d-c49b-5ccf-e1b5-eb58147aabe5
---

# Automate app deployment to Azure Kubernetes Service (AKS) with CI/CD via Automated deployments Automated deployments - Azure Kubernetes Service | Microsoft Learn

Automated Deployments streamline the process of setting up a GitHub Action or Azure DevOps Pipeline, making it easy to create a continuous deployment pipeline for your application to Azure Kubernetes Service (AKS). Once connected, every new commit automatically triggers the pipeline, delivering updates to your application seamlessly. You can either bring your own deployment files for quick pipeline creation or generate Dockerfiles and Kubernetes manifests to containerize and deploy non-containerized applications with minimal effort.

## Prerequisites

- A GitHub account or an Azure DevOps organization.
- An AKS cluster. If you don't have one, you can create one using the steps in [Deploy an Azure Kubernetes Service (AKS) cluster](learn/quick-kubernetes-deploy-portal).
- An Azure Container Registry (ACR). If you don't have one, you can create one using the steps in [Integrate Azure Container Registry (ACR) with an Azure Kubernetes Service (AKS) cluster](cluster-container-registry-integration).
- An application to deploy.

### Connect to source code repository

Create an automated deployment workflow and authorize it to connect to the desired source code repository.

1. In the Azure portal, navigate to your AKS cluster resource.
2. From the service menu, under **Settings**, select **Automated deployments** &gt; **Create**.
3. Under **Repository details**, enter a name for the workflow, then select **GitHub or ADO** for your repository location.
4. Select **Authorize access** to connect to the desired repository.
5. Choose the **Repository** and **Branch**, and then select **Next**.

### Choose the container image configuration

To get an application ready for Kubernetes, you need to build it into a container image and store it in a container registry. You use a Dockerfile to provide instructions on how to build the container image. If your source code repository doesn't already have a Dockerfile, Automated Deployments can generate one for you. Otherwise, you can use an existing Dockerfile.

# [Without an existing Dockerfile](#tab/generate-dockerfile)
Use Automated Deployments to generate a Dockerfile for many languages and frameworks such as Go, C#, Node.js, Python, Java, Gradle, Clojure, PHP, Ruby, Erlang, Swift, and Rust. The language support is built on what's available in https://draft.sh.

1. Select **Auto-containerize (generate Dockerfile)** for the container configuration.
2. Select the **location of where to save the generated Dockerfile** in the repository.
3. Select the **application environment** from the list of supported languages and frameworks.
4. Enter the **application port**.
5. Provide the **Dockerfile build context** path.
6. Select an existing **Azure Container Registry** or create a new one. This registry is used to store the built application image.

# [With an existing Dockerfile](#tab/use-existing-dockerfile)
If your code repository already has a Dockerfile, you can select it to be used to build the application image.

1. Select **Existing Dockerfile** for the container configuration.
2. Select the **Dockerfile** from your repository.
3. Enter the **Dockerfile build context** to pass the set of files and directories to the build process. These files are used to build the image, and they're included in the final image, unless they're ignored by a `.dockerignore` file.
4. Select an existing **Azure Container Registry** or create a new one. This registry is used to store the built application image.

---

### Choose the Kubernetes manifest configuration

Note

The Generate Manifests option also supports advanced features like Service Connector integration, auto-generated Ingress resources, and more detailed, customizable Kubernetes manifest files.

An application running on Kubernetes consists of many Kubernetes primitive components. These components describe what container image to use, how many replicas to run, if there's a public IP required to expose the application, etc. For more information, see the official [Kubernetes documentation](https://kubernetes.io/docs/home/). If your source code repository doesn't already have the basic Kubernetes manifests to deploy, Automated Deployments can generate them for you. Otherwise, you can use a set of existing manifests. You can also choose an existing Helm chart.

# [Use existing Kubernetes manifests](#tab/existing-kubernetes-manifests)
If your code repository already has a Dockerfile, you can select it to be used to build the application image.

1. Select **Use existing Kubernetes manifest deployment files** for the deployment options.
2. Select the **Kubernetes manifest file or folder** from your repository.
3. Select **Next**.

# [Use an existing Helm chart](#tab/existing-helm-chart)
If your code repository already has a Helm chart, you can select it to be used to build the application image.

1. Select **Use existing Helm chart** for the deployment options.
2. Select the **Charts path** folder from your repository.
3. Select the **Values.yaml** file path from your repository.
4. Optionally, provide **Helm chart overrides**.
5. Select **Next**.

# [Generate manifests](#tab/generate-kubernetes-manifests)
Use Automated Deployments to generate a set of basic Kubernetes manifest files to have your application up and running. At the moment, Automated Deployments creates a `Deployment`, a `Service`, and a `ConfigMap`.

The generated manifests are designed to apply recommendations of [deployment safeguards](deployment-safeguards), such as:

- Automatically generating [liveness, readiness, and startup probes](https://kubernetes.io/docs/concepts/configuration/liveness-readiness-startup-probes/).
- Preferring [pod anti-affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity) and [topology spread constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) that spread replicas onto different nodes for improved resiliency.
- Enforcing the `RuntimeDefault`[secure computing profile](secure-container-access#overview-of-default-seccomp-profiles-preview) which establishes an extra layer of protection against common system call vulnerabilities exploited by malicious actors.
- Dropping all Linux capabilities and only allowing a limited set following the baseline [Kubernetes Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/).

Generated Kubernetes manifests also support the addition of an **Ingress** and **Service Connector**. These optional integrations will be covered below.

To generate Kubernetes manifests:

1. Select **Generate application deployment files** for the deployment options.
2. Enter the **application port**. This port is used on the generated `Service`.
3. Select the **location of where to save the generated Kubernetes manifests** in the repository.
4. (Optional) Edit the **Application and configuration** or **Service** values in your manifest file by selecting **Change**.
    1. If you don't want to use the defaults that AKS recommends, you can change various values of the manifest file, such as the:
        - Memory/CPU requests
        - Memory/CPU limits
        - TCP Readiness and Startup Probes
        - Minimum/Maximum scaling replicas for HPA
        - Memory/CPU utilization for HPA
        - Loadbalancer Port/Target Port
5. Select **Next**.

---

## (Optional) Use a managed ingress and/or Service Connector

When generating Kubernetes manifests with Automated Deployments, you can optionally enable App Routing to set up an ingress controller for your application. You can also use Service Connector to create a new connection or seamlessly integrate your app with an existing Azure service backend.

# [Expose Ingress](#tab/expose-ingress)
App Routing provides a fully managed NGINX-based ingress controller out of the box, complete with built-in SSL/TLS encryption using certificates stored in Azure Key Vault and DNS zone management through Azure DNS. When using Automated Deployments, the expose ingress command integrates seamlessly with App Routing, making it easy to expose your application to external traffic under a secure, custom DNS name—with minimal configuration.

1. Select the **Expose ingress** box.
2. Choose between an **Existing ingress controller** or a **New ingress controller**.
3. Choose between using a **SSL/TLS enabled** or **Insecure** ingress controller.
4. (Optional) Enter **Certificate details** if choosing a **SSL/TLS enabled** ingress controller.
5. Choose between using **Azure DNS** or a **3rd party provider**.
6. Enter the **Azure DNS Zone** and **Subdomain name**.

# [Use Service Connector](#tab/use-service-connector)
Service Connector helps you connect your application to other backing Azure services. By configuring the proper networking settings and connection variables, it can automatically inject credentials into your application via Kubernetes secret objects with no manual setup needed. To learn more about Service Connector, see the official [documentation](/en-us/azure/service-connector/quickstart-portal-aks-connection).

1. Select an **existing connection** or **Create a connection**.
2. When **Creating a new connection**, make sure you fill out all appropriate fields.

---

## (Optional) Add environment variables

Define environment variables for a container in Kubernetes by specifying name-value pairs. Environment variables are important as they help enable easier management of settings, secure handling of sensitive information, and flexibility across environments.

## Review configuration and deploy

Review the configuration for the application, and Kubernetes manifests, then select **Deploy**. A pull request (PR) will be generated against the repository that you selected, so don't navigate away from deployment page.

### Review and merge pull request

When the deployment succeeds, select **View pull request** to view the details of the generated pull request on your code repository.

[![Screenshot of pull request on GitHub.](media/automatic/from-code/automatic-from-app-pull-request.png)](media/automatic/from-code/automatic-from-app-pull-request.png#lightbox)

1. Review the changes under **Files changed** and make any desired edits.
2. Select **Merge pull request** to merge the changes into your code repository.

Merging the change runs the GitHub Actions workflow that builds your application into a container image, stores it in Azure Container Registry, and deploys it to the cluster.

[![Screenshot showing GitHub Actions workflow in progress.](media/automatic/from-code/automatic-from-app-workflow-build.png)](media/automatic/from-code/automatic-from-app-workflow-build.png#lightbox)

### Check the deployed resources

After the pipeline is completed, you can review the created Kubernetes `Service` in the Azure portal by selecting **Services and ingresses** under the **Kubernetes resources** section of the service menu.

[![Screenshot of the Services and ingresses pane.](media/automatic/from-code/automatic-from-app-services.png)](media/automatic/from-code/automatic-from-app-services.png#lightbox)

Selecting the **External IP** should open up a new browser page with the running application.

[![Screenshot showing the Contoso Air application running.](media/automatic/from-code/automatic-from-app-running.png)](media/automatic/from-code/automatic-from-app-running.png#lightbox)

## Delete resources

Once you're done with your cluster, use the following steps to delete it to avoid incurring Azure charges:

1. In the Azure portal, navigate to **Automated deployments**
2. Select **...** on the pipeline of your choice.
3. Select **Delete**.