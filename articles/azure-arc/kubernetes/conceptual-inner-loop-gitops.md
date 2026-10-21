---
layout: Conceptual
title: Inner loop developer experience for teams adopting GitOps - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/conceptual-inner-loop-gitops
breadcrumb_path: ../../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/146/azure-arc/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/5c778dec-0625-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: davidsmatlak
learn_banner_products:
- azure
ms.reviewer: davidsmatlak
ms.author: davidsmatlak
ms.service: azure-arc
ms.subservice: azure-arc-kubernetes
ms.date: 2025-01-23T00:00:00.0000000Z
ms.topic: concept-article
description: Learn how an established inner loop can enhance developer productivity and help in a seamless transition for teams adopting GitOps.
locale: en-us
document_id: 073834c0-5fd8-7944-9b7f-3a4092f94900
document_version_independent_id: 83e3a171-2255-7d1a-f1bd-0978be1c8e17
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/conceptual-inner-loop-gitops.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/conceptual-inner-loop-gitops
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/conceptual-inner-loop-gitops.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/0850fefd-e402-4507-ae98-46cfdfc2e16c
- https://authoring-docs-microsoft.poolparty.biz/devrel/63959238-cb90-4871-a33d-4a5519097e47
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/6ecf98a5-97c7-4249-b209-a9d9e42633a0
- https://authoring-docs-microsoft.poolparty.biz/devrel/78d87f42-5582-4a6b-90be-7db2f12b34e6
platformId: 7e665b0c-ab62-1164-6253-451aed8e9987
---

# Inner loop developer experience for teams adopting GitOps - Azure Arc | Microsoft Learn

This article describes how an established inner loop dev framework can enhance developer productivity for teams adopting GitOps with Arc-enabled Kubernetes or Azure Container Service (AKS) clusters.

## Inner dev loop frameworks

Cloud-native development teams working with containers can benefit from a robust inner dev loop framework. Inner dev loop frameworks help with the iterative process of writing code, building, and debugging.

Capabilities of inner dev loop frameworks include:

- Automation of repetitive steps such as building code and deploying to the target cluster.
- Enhanced ability to work with remote and local clusters, and supporting local tunnel debugging for hybrid setup.
- Ability to configure custom flow for team-based productivity.
- Handling microservice dependencies.
- Hot reloading, port forwarding, log, and terminal access.

Depending on the maturity and complexity of the service, dev teams can choose between cluster setup options to accelerate the inner dev loop:

- All local
- All remote
- Hybrid

Many frameworks support these capabilities, and various market offerings are available, such as DevSpace, Scaffold, and Tilt.

## Inner loop to outer loop transition

After you evaluate and select an inner loop dev framework, you can build a seamless inner loop to outer loop transition.

As described in the [CI/CD workflow using GitOps](conceptual-gitops-flux2-ci-cd) example scenario, a developer works on application code within an application repository. This application repository also holds high-level deployment Helm and/or Kustomize templates.

The CI/CD pipelines:

- Generate the low-level manifests from the high-level templates, adding environment-specific values.
- Create a pull request that merges the low-level manifests with the GitOps repo that holds desired state for the specific environment.

Similar low-level manifests can be generated locally for the inner dev loop, using the configuration values local to the developer. Application developers can iterate on the code changes and use the low-level manifests to deploy and debug applications. Generation of the low-level manifests can be integrated into an inner loop workflow, using the developer’s local configuration. Most of the inner loop framework allows configuring custom flows by either extending through custom plugins or injecting script invocation based on hooks.

## Example inner loop workflow built with DevSpace framework

To illustrate the inner loop workflow, we can look at an example scenario. This example uses the DevSpace framework, but the same general workflow can be used with other frameworks.

This diagram shows the workflow for the inner loop.

[![Diagram showing the inner loop flow.](media/dev-inner-loop.png)](media/dev-inner-loop.png#lightbox)

This diagram shows the workflow for the inner loop to outer loop transition.

[![Diagram showing inner loop to outer loop transition.](media/inner-loop-to-outer-loop.png)](media/inner-loop-to-outer-loop.png#lightbox)

In this example, our application developer:

- Authors a devspace.yaml file to configure the inner loop.
- Writes and tests application code using the inner loop for efficiency.
- Deploys to staging or prod with outer loop.

To update, run, and debug the application, either in a local or remote cluster, the application developer takes the following steps:

1. Updates the local configuration for the development environment represented in .env file.
2. Runs `devspace use context` and selects the Kubernetes cluster context.
3. Selects a namespace to work with by running `devspace use namespace <namespace_name>`.
4. Iterates changes to the application code, and deploys and debugs the application onto the target cluster by running `devspace dev`.
5. Runs `devspace dev` to generate low-level manifests based on the local configuration, and deploys the application. These low-level manifests are configured with DevSpace hooks in devspace.yaml.

    - Since DevSpace enables hot reloading, using file sync to copy the latest changes inside the container, the container doesn't have to be rebuilt for each code change.
    - Running `devspace dev` also deploys any dependencies configured in devspace.yaml, such as back-end dependencies to front-end.
6. Tests the changes by accessing the application through the forwarding configured through devspace.yaml.
7. After finalizing the changes, purges the deployment by running `devspace purge` and creating a new pull request to merge the changes to the dev branch of the application repository.

Note

Find the sample code for this workflow in our [GitHub repo](https://github.com/Azure/arc-cicd-demo-src).