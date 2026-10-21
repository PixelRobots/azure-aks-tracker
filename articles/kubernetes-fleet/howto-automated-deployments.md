---
layout: Conceptual
title: Use Azure Kubernetes Fleet Manager Automated Deployments to drive multi-cluster resource placement | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/howto-automated-deployments
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
learn_banner_products:
- azure
description: Learn how to use Azure Kubernetes Fleet Manager Automated Deployments to build and deploy an application across multiple clusters.
author: sjwaight
ms.author: simonwaight
ms.topic: how-to
ms.custom: build-2025
ms.date: 2026-08-21T00:00:00.0000000Z
ms.service: azure-kubernetes-fleet-manager
locale: en-us
document_id: 0fa49e5f-eda6-adc8-ce82-84b4c85e29bf
document_version_independent_id: d888c198-4a75-aabd-58cb-1694bbc94f23
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/howto-automated-deployments.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: kubernetes-fleet/howto-automated-deployments
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/howto-automated-deployments.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/9bdc1705-9b40-49d6-8377-caa0b71fda66
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/686ed158-d915-41e9-9760-efa46ba88f6d
platformId: d287680b-8600-bd25-75dc-34f3f710b708
---

# Use Azure Kubernetes Fleet Manager Automated Deployments to drive multi-cluster resource placement | Microsoft Learn

**Applies to**: ✔️ Fleet Manager with hub cluster

Azure Kubernetes Fleet Manager Automated Deployments can be used to build and deploy an application from a code repository to one or more AKS cluster in a fleet. Automated deployments simplify the process of setting up a GitHub Action workflow to build and deploy your code. Once connected, every new commit you make runs the pipeline.

Automated Deployments build on https://draft.sh. When you create a new deployment workflow, you can use an existing Dockerfile, generate a Dockerfile, use existing Kubernetes manifests, or generate Kubernetes manifests. The generated manifests are created with security and resiliency best practices in mind.

Important

Azure Kubernetes Fleet Manager preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. Azure Kubernetes Fleet Manager previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use.

## Prerequisites

- A GitHub account with the application to deploy.
- If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- Read the conceptual overviews of [Automated Deployments](concepts-automated-deployments) and [resource propagation](concepts-resource-placement) to understand the concepts and terminology used in this article.
- A Kubernetes Fleet Manager with a hub cluster and member clusters. If you don't have one, see [Create an Azure Kubernetes Fleet Manager resource and join member clusters by using the Azure CLI](quickstart-create-fleet-and-members).
- The user completing the configuration has permissions to the Fleet Manager hub cluster Kubernetes API. For more information, see [Access the Kubernetes API](access-fleet-hub-cluster-kubernetes-api) for more details.
- A Kubernetes namespace already deployed on the Fleet Manager hub cluster.
- An Azure Container Registry (ACR) with [AcrPull rights granted to member AKS clusters](/en-us/azure/aks/cluster-container-registry-integration).

## Bring your application source code

Find your Azure Kubernetes Fleet Manager and start Automated Deployments configuration.

1. In the [Azure portal](https://portal.azure.com), search for **Kubernetes Fleet Manager** in the top search bar.
2. Select [**Kubernetes fleet manager**](https://portal.azure.com/#browse/Microsoft.ContainerService%2Ffleets) in the search results.
3. Select your Azure Kubernetes Fleet Manager from the resource list.
4. From the Fleet Manager service menu, under **Fleet resources**, select **Automated deployments**.
5. Select **+ Create** in the top menu. If this deployment is your first, you can also select **Create** in the deployment list area.

[![Screenshot showing create options for Fleet Manager Automated Deployments.](media/automated-deployments/fleet-auto-deploy-create.png)](media/automated-deployments/fleet-auto-deploy-create.png#lightbox)

### Connect to source code repository

Create a workflow and authorize it to connect to the desired source code repository and branch. Complete the following details on the **Repository** tab.

1. Enter a meaningful name for the workflow in the **Workflow name** field.
2. Next, select **Authorize access** to authorize a user against GitHub to obtain a list of repositories.
3. For **Repository source**select either:
    1. **My repositories** for repositories the currently authorized GitHub user owns, or;
    2. **All repositories** for repositories the currently authorized GitHub user can access. You need to select the **Organization** which owns the repository.
4. Choose the **Repository** and **Branch**.
5. Select the **Next** button.

[![Screenshot showing selection of source control repository when setting up Fleet Manager Automated Deployments.](media/automated-deployments/fleet-auto-deploy-repository.png)](media/automated-deployments/fleet-auto-deploy-repository.png#lightbox)

### Specify application image and deployment configuration

To prepare an application to run on Kubernetes, you need to build it into a container image that you store in a container registry. A [Dockerfile](https://docs.docker.com/build/concepts/dockerfile/) provides instructions on how to build the container image. If your source code repository doesn't already have a Dockerfile, Automated Deployments can generate one for you.

# [Use existing Dockerfile](#tab/use-existing-dockerfile)
If your code repository already has a Dockerfile, you can use it to build the application image.

1. Select **Existing Dockerfile** for the **Container configuration**.
2. Select the **Dockerfile** from your repository.
3. Enter the **Dockerfile build context** to pass the set of files and directories to the build process (typically the same folder as the Dockerfile). These files are used to build the image, and they're included in the final image, unless they're ignored through inclusion in a `.dockerignore` file.
4. Select an existing **Azure Container Registry**. This registry is used to store the built application image. Any AKS cluster that can receive the application must be given `AcrPull` permissions on the Registry.
5. Set the **Azure Container Registry image** name. You must use this image name in your Kubernetes deployment manifests.

[![Screenshot showing selection of an existing Dockerfile when setting up Fleet Manager Automated Deployments.](media/automated-deployments/fleet-auto-deploy-existing-dockerfile.png)](media/automated-deployments/fleet-auto-deploy-existing-dockerfile.png#lightbox)

# [Generate a Dockerfile](#tab/generate-dockerfile)
Use Fleet Manager Automated Deployments to generate a Dockerfile for many languages and frameworks such as Go, C#, Node.js, Python, Java, Gradle, Clojure, PHP, Ruby, Erlang, Swift, and Rust. The language support is built on what's available in https://draft.sh.

1. Select **Auto-containerize (generate Dockerfile)** for the container configuration.
2. Set the **Save files in repository** location to a folder in the source repository.
3. Choose the **Application environment** from the list of supported languages and frameworks.
4. Enter the **Application port**.
5. Select an existing **Azure Container Registry**. This registry is used to store the built application image. Any AKS cluster that can receive the application must be given `AcrPull` permissions on the Registry.
6. Set the **Azure Container Registry image** name. You must use this image name in your Kubernetes deployment manifests.
7. Review the generated `Dockerfile` and `.dockerignore` files.

[![Screenshot showing creating a Dockerfile when setting up Fleet Manager Automated Deployments.](media/automated-deployments/fleet-auto-deploy-create-dockerfile.png)](media/automated-deployments/fleet-auto-deploy-create-dockerfile.png#lightbox)

---

### Choose the Kubernetes manifest configuration

An application running on Kubernetes consists of many Kubernetes primitive components. These components describe what container image to use, how many replicas to run, if there's a public IP required to expose the application, etc. For more information, see the official [Kubernetes documentation](https://kubernetes.io/docs/concepts/workloads/). If your source code repository doesn't already have Kubernetes manifests, Automated Deployments can generate them for you. You can also choose an existing Helm chart.

Warning

Don't choose the `fleet-system` or any of the `fleet-member` namespaces as these are internal namespaces used by Fleet Manager and can't be used to place your application.

# [Use existing Kubernetes manifests](#tab/existing-kubernetes-manifests)
If your code repository already has a Kubernetes manifest, you can select it to control what workload is deployed and configured by a cluster resource placement.

1. Select **Use existing Kubernetes manifest deployment files** for the deployment options.
2. Select the **Kubernetes manifest file or folder** from your repository.
3. Select the existing Fleet Manager **Namespace** to stage the workload in.
4. Select the **Next** button.

[![Screenshot showing selection of an existing Kubernetes manifest when setting up Fleet Manager Automated Deployments.](media/automated-deployments/fleet-auto-deploy-existing-manifest.png)](media/automated-deployments/fleet-auto-deploy-existing-manifest.png#lightbox)

# [Generate Kubernetes manifests](#tab/generate-kubernetes-manifests)
Use Fleet Manager Automated Deployments to generate a set of basic Kubernetes manifest files to get your application up and running. Currently, Automated Deployments creates a `Deployment`, a `Service`, and a `ConfigMap`.

The generated manifests are designed to apply recommendations of [deployment safeguards](/en-us/azure/aks/deployment-safeguards), such as:

- Automatically generating [liveness, readiness, and startup probes](https://kubernetes.io/docs/concepts/configuration/liveness-readiness-startup-probes/).
- Preferring [pod anti-affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity) and [topology spread constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) that spread replicas onto different nodes for improved resiliency.
- Enforcing the `RuntimeDefault`[secure computing profile](/en-us/azure/aks/secure-container-access#secure-computing-seccomp) which establishes an extra layer of protection against common system call vulnerabilities exploited by malicious actors.
- Dropping all Linux capabilities and only allowing a limited set following the baseline [Kubernetes Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/).

To generate Kubernetes manifests:

1. Select **Generate application deployment files** for the deployment options.
2. Enter the **Application port**. This port is used on the generated `Service`.
3. Select the existing Fleet Manager **Namespace** to stage the workload in.
4. Set the **Save files in repository** location to a folder in the source repository.
5. Select the **Next** button.

# [Use existing Helm chart](#tab/existing-helm-chart)
If your code repository already has a Helm chart, you can select it to build the application image.

1. Select **Use existing Helm chart** for the deployment options.
2. Select the **Charts path** folder from your repository.
3. Select the **Values.yaml** file path from your repository.
4. Optionally, provide **Helm chart overrides**.
5. Select the existing Fleet Manager **Namespace** to stage the workload in.
6. Select the **Next** button.

---

## Review configuration

Review the configuration for the repository, image, and deployment configuration.

[![Screenshot showing the configuration of an Automated Deployment so it can be reviewed before being submitted.](media/automated-deployments/fleet-auto-deploy-review.png)](media/automated-deployments/fleet-auto-deploy-review.png#lightbox)

Select **Next** to start the process. This process performs these actions:

1. Creates federated credentials to allow the GitHub Action to:
    1. Push the built container image to the Azure Container Registry.
    2. Stage the Kubernetes manifests into the selected namespace on the Fleet Manager hub cluster.
2. Creates a pull request on the code repository with any generated files and the workflow.

Setup takes a few minutes, so don't navigate away from the Deploy page.

[![Screenshot showing Automated Deployment configuration completed with a button to approve the pull request.](media/automated-deployments/fleet-auto-deploy-run.png)](media/automated-deployments/fleet-auto-deploy-run.png#lightbox)

### Review and merge pull request

When the Deploy stage finishes, select the **Approve pull request** button to open the generated pull request on your code repository.

Note

There's a known issue with the naming of the generated pull request where it says it's deploying to AKS. Despite this incorrect name, the resulting workflow does stage your workload on the Fleet Manager hub cluster in the namespace you selected.

[![Screenshot of pull request on GitHub.](media/automated-deployments/fleet-auto-deploy-merge-pr.png)](media/automated-deployments/fleet-auto-deploy-merge-pr.png#lightbox)

1. Review the changes under **Files changed** and make any desired edits.
2. Select **Merge pull request** to merge the changes into your code repository.

Merging the change runs the GitHub Actions workflow that builds your application into a container image and stores it in the selected Azure Container Registry.

[![Screenshot showing GitHub Actions workflow in progress.](media/automated-deployments/fleet-auto-deploy-github-action.png)](media/automated-deployments/fleet-auto-deploy-github-action.png#lightbox)

### Check the generated resources

After the pipeline is completed, you can review the created container image on the Azure portal by locating the Azure Container Registry instance you configured and opening the image repository.

[![Screenshot of the built container image hosted in an Azure Container Registry repository.](media/automated-deployments/fleet-auto-deploy-check-registry-image.png)](media/automated-deployments/fleet-auto-deploy-check-registry-image.png#lightbox)

You can also view the Fleet Manager Automated Deployment configuration. Selecting the `workflow` name opens GitHub on the GitHub Action.

[![Screenshot of the configured Fleet Manager Automated Deployment, including a link to the GitHub Action.](media/automated-deployments/fleet-auto-deploy-check-deployments.png)](media/automated-deployments/fleet-auto-deploy-check-deployments.png#lightbox)

Finally, you can confirm the expected Kubernetes resources are staged on the Fleet Manager hub cluster.

```azurecli
az fleet get-credentials \
    --resource-group ${GROUP} \
    --name ${FLEET}
```

```bash
kubectl describe deployments virtual-worker --namespace=contoso-store
```

Output looks similar to the below. The replicas of 0 is expected as workloads aren't scheduled on the Fleet Manager hub cluster. Make sure that the `Image` property points at the built image in your Azure Container Registry.

```output
Name:                   virtual-worker
Namespace:              contoso-store
CreationTimestamp:      Thu, 24 Apr 2025 01:56:49 +0000
Labels:                 workflow=actions.github.com-k8s-deploy
                        workflowFriendlyName=contoso-store-deploy
Annotations:            <none>
Selector:               app=virtual-worker
Replicas:               1 desired | 0 updated | 0 total | 0 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=virtual-worker
  Containers:
   virtual-worker:
    Image:      contoso03.azurecr.io/virtual-worker:latest
    Port:       <none>
    Host Port:  <none>
    Limits:
      cpu:     2m
      memory:  20Mi
    Requests:
      cpu:     1m
      memory:  1Mi
    Environment:
      MAKELINE_SERVICE_URL:  http://makeline-service:3001
      ORDERS_PER_HOUR:       100
    Mounts:                  <none>
  Volumes:                   <none>
  Node-Selectors:            kubernetes.io/os=linux
  Tolerations:               <none>
Events:                      <none>
```

## Define cluster resource placement

During preview, to configure placement of your staged workload on to member clusters you can follow these steps.

1. In the source code repository for your application, create a folder in the repository root called **fleet**.
2. Create a new file `deploy-contoso-ns-two-regions.yaml` in the **fleet** folder and add the contents shown. This sample deploys the `contoso-store` namespace across two clusters that must be in two different Azure regions.

    ```yml
    apiVersion: placement.kubernetes-fleet.io/v1
    kind: ClusterResourcePlacement
    metadata:
      name: distribute-virtual-worker-two-regions
    spec:
      resourceSelectors:
        - group: ""
          kind: Namespace
          version: v1          
          name: contoso-store
      policy:
        placementType: PickN
        numberOfClusters: 2
        topologySpreadConstraints:
        - maxSkew: 1
          topologyKey: region
          whenUnsatisfiable: DoNotSchedule
    ```
3. Modify the GitHub Action workflow file, adding a reference to the CRP file.

    ```yml
    DEPLOYMENT_MANIFEST_PATH: |
      ./virtual-worker.yaml
      ./fleet/deploy-contoso-ns-two-regions.yaml
    ```
4. Commit the new CRP manifest and updated GitHub Action workflow file.
5. Check that the workload is placed according to the policy defined in the CRP definition. You can check by using either the Azure portal or `kubectl` at the command line.

[![Screenshot of the Fleet Manager Resource Placements showing a successfully completed placement.](media/automated-deployments/fleet-auto-deploy-check-placement.png)](media/automated-deployments/fleet-auto-deploy-check-placement.png#lightbox)