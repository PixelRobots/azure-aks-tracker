---
layout: Conceptual
title: 'Quickstart: Deploy an application to a new Azure Kubernetes Service (AKS) Automatic cluster from a code repository using Automated Deployments - Azure Kubernetes Service | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/automatic/quick-automatic-from-code
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
description: Learn how to quickly deploy an application from source code to a new Azure Kubernetes Service (AKS) Automatic cluster.
ms.topic: quickstart
ms.custom: devx-track-azurecli, devx-track-bicepW
ms.date: 2026-05-22T00:00:00.0000000Z
author: wangyira
ms.author: wangamanda
locale: en-us
document_id: c9f04227-bdad-ce3b-f5e7-f178823cd9cf
document_version_independent_id: 22ad9abc-3fae-44ae-93a5-0d5ed4c76918
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/automatic/quick-automatic-from-code.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../toc.json
asset_id: aks/automatic/quick-automatic-from-code
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/automatic/quick-automatic-from-code.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 713bd127-f29c-12a2-cad4-7c036c3bf251
---

# Quickstart: Deploy an application to a new Azure Kubernetes Service (AKS) Automatic cluster from a code repository using Automated Deployments - Azure Kubernetes Service | Microsoft Learn

**Applies to:** ✔️ AKS Automatic

Use [automated deployments](../automated-deployments) to build and deploy an application from a code repository to a new or existing AKS Automatic cluster. Automated deployments simplify the process of setting up a GitHub Action workflow to build and deploy your code. Once connected, every new commit you make kicks off the pipeline. Automated deployments build on https://draft.sh. When you create a new deployment workflow, you can use an existing Dockerfile, generate a Dockerfile, use existing Kubernetes manifests, or generate Kubernetes manifests. The generated manifests are created with security and resiliency best practices in mind. AKS Automatic also includes a [pod readiness SLA](https://www.microsoft.com/licensing/docs/view/Service-Level-Agreements-SLA-for-Online-Services) that guarantees 99.9% of qualifying pod readiness operations complete within 5 minutes, guaranteeing reliable, self-healing infrastructure for your applications.

In this quickstart, you learn to:

- Connect to a code repository.
- Containerize your application.
- Configure Kubernetes manifests.
- Create an AKS Automatic cluster.
- Deploy the application via a pull request.

## Before you begin

- Have a GitHub account with the application to deploy.
- AKS Automatic will [enable Azure Policy on your AKS cluster](/en-us/azure/governance/policy/concepts/policy-for-kubernetes#install-azure-policy-add-on-for-aks), but you should pre-register the `Microsoft.PolicyInsights` resource provider in your subscription for a smoother experience. See [Azure resource providers and types](/en-us/azure/azure-resource-manager/management/resource-providers-and-types#register-resource-provider) for more information.

Important

Starting on AKS 1.36, new AKS Automatic clusters will by default enable [Kubernetes Gateway API via the application routing add-on](../app-routing-gateway-api) instead of [Managed NGINX ingress with the application routing add-on](../app-routing) due to the upstream [Ingress NGINX retirement](https://www.kubernetes.dev/blog/2025/11/12/ingress-nginx-retirement/).

Existing Automatic clusters aren't affected but should begin migration to [Kubernetes Gateway API via the application routing add-on](../app-routing-gateway-api#enable-for-an-existing-cluster).

## Limitations

The following limitations apply to AKS Automatic clusters:

- AKS Automatic is generally available in the following regions: `australiacentral`, `australiaeast`, `australiasoutheast`, `austriaeast`, `belgiumcentral`, `brazilsouth`, `canadacentral`, `canadaeast`, `centralindia`, `centralus`, `chilecentral`, `denmarkeast`, `eastasia`, `eastus`, `eastus2`, `francecentral`, `germanywestcentral`, `indonesiacentral`, `israelcentral`, `italynorth`, `japaneast`, `japanwest`, `koreacentral`, `koreasouth`, `malaysiawest`, `mexicocentral`, `newzealandnorth`, `northcentralus`, `northeurope`, `norwayeast`, `polandcentral`, `southafricanorth`, `southcentralus`, `southeastasia`, `southindia`, `spaincentral`, `swedencentral`, `switzerlandnorth`, `uaenorth`, `uksouth`, `ukwest`, `westcentralus`, `westeurope`, `westus`, `westus2`, `westus3`.
- New AKS Automatic clusters by default enable managed system node pools and [LocalDNS](../dns-concepts#localdns-in-azure-kubernetes-service). You can't create AKS Automatic clusters without managed system node pools in any region.
- AKS Automatic cluster has [node resource group lockdown](../node-resource-group-lockdown) preconfigured, which doesn't allow changes to the `MC_` resource group, preventing virtual network links on the default Private DNS zone. For cross‑VNet or custom DNS scenarios, use custom network and private DNS by following [Create a private Azure Kubernetes Service (AKS) Automatic cluster in a custom virtual network](quick-automatic-private-custom-network).
- Azure CLI version 2.86.0 or later is required. To find the version, run `az --version` command. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/get-started-with-azure-cli).
- The following extensions aren't supported:
    - [Dapr](../dapr)
    - [Azure Machine Learning](/en-us/azure/machine-learning/how-to-attach-kubernetes-anywhere)
- Windows nodes aren't supported.
- Migration from AKS base SKU to automatic SKU isn't supported.
- Migration from an existing AKS Automatic cluster without managed system node pools to AKS Automatic with managed system node pools is supported in preview in regions where managed system node pools are generally available. Migration from AKS Automatic with managed system node pools back to AKS Automatic without managed system node pools isn't supported.

## Bring your application source code

To deploy an application from a code repository, start at the [Azure portal](https://portal.azure.com) home page.

[![Screenshot showing select 'Deploy application' on the Kubernetes services create menu.](../media/automatic/from-code/deploy-from-code-automatic.png)](../media/automatic/from-code/deploy-from-code-automatic.png#lightbox)

1. Search for **Kubernetes services** in the top search bar.
2. Select [**Kubernetes services**](https://portal.azure.com/#browse/Microsoft.ContainerService%2FmanagedClusters) in the search results.
3. Select the **Create** button and select **Deploy application**.

### Connect to source code repository

Create and automated deployment workflow and authorize it to connect to the desired source code repository.

1. In the **Basics** tab, select **Deploy your application**.
2. Under **Project details**, choose the **Subscription**, **Resource Group**, and **Region**.
3. Under **Repository details**, enter a name for the workflow, then select **Authorize access** to connect to the desired GitHub repository.
4. Choose the **Repository** and **Branch**.
5. Select the **Next** button.

### Choose the container image configuration

To get an application ready for Kubernetes, you need to build it into a container image and stored into a container registry. You use a Dockerfile to provide instructions on how to build the container image. If your source code repository doesn't already have a Dockerfile, Automated Deployments can generate one for you, otherwise, you can utilize an existing Dockerfile.

# [Without an existing Dockerfile](#tab/generate-dockerfile)
Use Automated Deployments to generate a Dockerfile for many languages and frameworks such as Go, C#, Node.js, Python, Java, Gradle, Clojure, PHP, Ruby, Erlang, Swift, and Rust. The language support is built on what's available in https://draft.sh.

1. Select **Auto-containerize (generate Dockerfile)** for the container configuration.
2. Select the **location of where to save the generated Dockerfile** in the repository.
3. Choose the **application environment** from the list of supported languages and frameworks.
4. Enter the **application port**.
5. Select an existing **Azure Container Registry** or create a new one. This registry is used to store the built application image. The [kubelet identity](../managed-identity-overview#summary-of-managed-identities-used-by-aks) of the AKS Automatic cluster is given `AcrPull` permissions on that registry.

# [With an existing Dockerfile](#tab/use-existing-dockerfile)
If your code repository already has a Dockerfile, you can select it to be used to build the application image.

1. Select **Existing Dockerfile** for the container configuration.
2. Select the **Dockerfile** from your repository.
3. Enter the **Dockerfile build context** to pass the set of files and directories to the build process. These files are used to build the image, and they're included in the final image, unless they're ignored by a `.dockerignore` file.
4. Select an existing **Azure Container Registry** or create a new one. This registry is used to store the built application image. The [kubelet identity](../managed-identity-overview#summary-of-managed-identities-used-by-aks) of the AKS Automatic cluster is given `AcrPull` permissions on that registry.

---

### Choose the Kubernetes manifest configuration

An application running on Kubernetes consists of many Kubernetes primitive components. These components describe what container image to use, how many replicas to run, if there's a public IP required to expose the application, etc. For more information, see the official [Kubernetes documentation](https://kubernetes.io/docs/concepts/workloads/). If your source code repository doesn't already have the basic Kubernetes manifests to deploy, Automated Deployments can generate them for you, otherwise, you can utilize a set of existing manifests. You can also choose an existing Helm chart.

# [Generate manifests](#tab/generate-kubernetes-manifests)
Use Automated Deployments to generate a set of basic Kubernetes manifest files to have your application up and running. At the moment, Automated Deployments creates a `Deployment`, a `Service`, and a `ConfigMap`.

The generated manifests are designed to apply recommendations of [deployment safeguards](../deployment-safeguards), such as:

- Automatically generating [liveness, readiness, and startup probes](https://kubernetes.io/docs/concepts/configuration/liveness-readiness-startup-probes/).
- Preferring [pod anti-affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity) and [topology spread constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) that spread replicas onto different nodes for improved resiliency.
- Enforcing the `RuntimeDefault`[secure computing profile](../secure-container-access#overview-of-default-seccomp-profiles-preview) which establishes an extra layer of protection against common system call vulnerabilities exploited by malicious actors.
- Dropping all Linux capabilities and only allowing a limited set following the baseline [Kubernetes Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/).

To generate Kubernetes manifests:

1. Select **Generate application deployment files** for the deployment options.
2. Enter the **application port**. This port is used on the generated `Service`.
3. Select the **location of where to save the generated Kubernetes manifests** in the repository.
4. Select the **Next** button.

# [With existing Kubernetes manifests](#tab/existing-kubernetes-manifests)
If your code repository already has a Dockerfile, you can select it to be used to build the application image.

1. Select **Use existing Kubernetes manifest deployment files** for the deployment options.
2. Select the **Kubernetes manifest file or folder** from your repository.
3. Select the **Next** button.

# [With an existing Helm chart](#tab/existing-helm-chart)
If your code repository already has a Helm chart, you can select it to be used to build the application image.

1. Select **Use existing Helm chart** for the deployment options.
2. Select the **Charts path** folder from your repository.
3. Select the **Values.yaml** file path from your repository.
4. Optionally, provide **Helm chart overrides**.
5. Select the **Next** button.

---

## Select where you want to deploy the application

# [Create a new AKS Automatic cluster](#tab/new-aks-automatic-cluster)
If you don't have a cluster already, you can create a new AKS Automatic cluster as part of this deployment.

1. Select **Create Automatic Kubernetes cluster** for the cluster configuration.
2. Enter a **cluster name**.
3. Choose the **automatic upgrade maintenance schedule** or leave the default selected.
4. Enter the **Kubernetes namespace** where the application is deployed.
5. Choose the **monitoring and logging level** or leave the default selected.
6. Select the **Next** button.

# [Existing AKS cluster](#tab/existing-aks-cluster)
If you have a cluster, you can use it to deploy the application.

1. Select **Existing AKS cluster** for the cluster configuration.
2. Select the **Subscription**, **Resource Group**, and **Cluster**.
3. Enter the **Kubernetes namespace** where the application is deployed.
4. Select the **Next** button.

---

## Review configuration and deploy

Review the configuration for the cluster, application, and Kubernetes manifests, then select **Deploy**. Creating a cluster takes a few minutes, don't navigate away from deployment page.

[![Screenshot showing Deploying the application.](../media/automatic/from-code/automatic-from-app-deploy.png)](../media/automatic/from-code/automatic-from-app-deploy.png#lightbox)

1. A new AKS Automatic cluster is created or an existing one is configured.
2. A container registry is created or an existing one is configured with the cluster.
3. Federated credentials are created to allow the GitHub Action workflow to deploy to the cluster.
4. A pull request is created on the code repository with any generated files and the workflow.

### Review and merge pull request

When the deployment succeeds, select the **View pull request** button to view the details of the generated pull request on your code repository.

[![Screenshot of pull request on GitHub.](../media/automatic/from-code/automatic-from-app-pull-request.png)](../media/automatic/from-code/automatic-from-app-pull-request.png#lightbox)

1. Review the changes under **Files changed** and make any desired edits.
2. Select **Merge pull request** to merge the changes into your code repository.

Merging the change runs the GitHub Actions workflow that builds your application into a container image, store it in Azure Container Registry, and deploy it to the cluster.

[![Screenshot showing GitHub Actions workflow in progress.](../media/automatic/from-code/automatic-from-app-workflow-build.png)](../media/automatic/from-code/automatic-from-app-workflow-build.png#lightbox)

### Check the deployed resources

After the pipeline is completed, you can review the created Kubernetes `Service` on the Azure portal by selecting **Services and ingresses** under **Kubernetes resources** service menu.

[![Screenshot of the Services and ingresses pane.](../media/automatic/from-code/automatic-from-app-services.png)](../media/automatic/from-code/automatic-from-app-services.png#lightbox)

Selecting the **External IP** should open up a new browser page with the running application.

[![Screenshot showing the Contoso Air application running.](../media/automatic/from-code/automatic-from-app-running.png)](../media/automatic/from-code/automatic-from-app-running.png#lightbox)

## Delete resources

Once you're done with your cluster, can delete it to avoid incurring Azure charges.

1. In the Azure portal, navigate to your resource group.
2. Select **Delete resource group**.
3. Enter the name of your resource group to confirm deletion and select **Delete**.
4. In the **Delete confirmation** dialog box, select **Delete**.