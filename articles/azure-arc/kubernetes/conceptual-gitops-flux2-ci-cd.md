---
layout: Conceptual
title: CI/CD Workflow using GitOps (Flux v2) - Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/conceptual-gitops-flux2-ci-cd
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
author: eedorenko
learn_banner_products:
- azure
ms.reviewer: davidsmatlak
ms.author: iefedore
ms.service: azure-arc
ms.subservice: azure-arc-kubernetes
description: This article provides a conceptual overview of a CI/CD workflow using GitOps.
ms.date: 2025-04-22T00:00:00.0000000Z
ms.topic: concept-article
locale: en-us
document_id: 27022faf-bf5b-fad5-c2fc-0b3cf30136e1
document_version_independent_id: d4fbcf03-6c3b-1b9b-c0e0-64a23eb40c07
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/conceptual-gitops-flux2-ci-cd.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/conceptual-gitops-flux2-ci-cd
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/conceptual-gitops-flux2-ci-cd.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: d2a6ce9a-20f7-1f34-c02a-78f7d16330b3
---

# CI/CD Workflow using GitOps (Flux v2) - Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn

Modern Kubernetes deployments contain multiple applications, clusters, and environments. With GitOps, you can manage these complex setups more easily, tracking the desired state of the Kubernetes environments declaratively with Git. Using common Git tooling to declare cluster state, you can increase accountability, facilitate fault investigation, and enable automation to manage environments.

This article describes how GitOps fits into the full application change lifecycle using Azure Arc, Azure Repos, and Azure Pipelines. It also provides an example of a single application change to GitOps-controlled Kubernetes environments.

## Architecture

This diagram shows the CI/CD workflow for an application deployed to one or more Kubernetes environments.

[![Diagram showing GitOps CI/CD architecture.](media/gitops/gitops-flux2-ci-cd-arch.png)](media/gitops/gitops-flux2-ci-cd-arch.png#lightbox)

*To download architecture diagrams in high resolution, visit [Jumpstart Gems](https://aka.ms/JumpstartGems_Docs).*

### Application code repository

The application repository contains the application code that developers work on during their inner loop. The application's deployment templates live in this repository in a generic form, such as Helm or Kustomize. Environment-specific values aren't stored in the repository.

Changes to this repo invoke a PR or CI pipeline that starts the deployment process.

### Container registry

The container registry holds all the first- and third-party images used in the Kubernetes environments. First-party application images are tagged with human-readable tags and the Git commit used to build the image. Third-party images may be cached to help with security, speed, and resilience. Set a plan for timely testing and integration of security updates.

For more information, see [How to consume and maintain public content with Azure Container Registry Tasks](../../container-registry/tasks-consume-public-content).

### PR pipeline

Pull requests from developers made to the application repository are gated on a successful run of the PR pipeline. This pipeline runs the basic quality gates, such as linting and unit tests on the application code. The pipeline tests the application and lints Dockerfiles and Helm templates used for deployment to a Kubernetes environment. Docker images should be built and tested, but not pushed. Keep the pipeline duration relatively short to allow for rapid iteration.

### CI pipeline

The application CI pipeline runs all the PR pipeline steps, expanding the testing and deployment checks. The pipeline can be run for each commit to main, or it can run at a regular cadence with a group of commits.

At this stage, application tests that are too consuming for the PR pipeline can be performed, including:

- Pushing images to container registry
- Image building, linting, and testing
- Template generation of raw YAML files

By the end of the CI build, artifacts are generated. These artifacts can be used by the CD step to consume in preparation for deployment.

### Flux cluster extension

Flux is an agent that runs in each cluster as a cluster extension. This Flux cluster extension is responsible for maintaining the desired state. The agent polls the GitOps repository at a user-defined interval, then reconciles the cluster state with the state declared in the Git repository.

For more information, see [Tutorial: Deploy applications using GitOps with Flux v2](tutorial-use-gitops-flux2).

### CD pipeline

The CD pipeline is automatically triggered by successful CI builds. In this pipeline environment, environment-specific values are substituted into the previously published templates, and a new pull request is raised against the GitOps repository with these values. This pull request contains the proposed changes to the desired state of one or more Kubernetes clusters. Cluster administrators review the pull request and approve the merge to the GitOps repository. The pipeline waits for the pull request to merge, after which Flux syncs and applies the state changes.

### GitOps repository

The GitOps repository represents the current desired state of all environments across clusters. Any change to this repository is picked up by the Flux service in each cluster and deployed. Changes to the desired state of the clusters are presented as pull requests, which are then reviewed, and finally merged upon approval of the changes. These pull requests contain changes to deployment templates and the resulting rendered Kubernetes manifests. Low-level rendered manifests allow more careful inspection of changes typically unseen at the template-level.

### GitOps connector

[GitOps Connector](https://github.com/microsoft/gitops-connector) creates a connection between the Flux agent and the GitOps Repository/CD pipeline. While changes are applied to the cluster, Flux notifies the GitOps connector of every phase change and health check performed. This component serves as an adapter. It understands how to communicate to a Git repository, and it updates the Git commit status so the synchronization progress is visible in the GitOps repository. When the deployment finishes (whether it succeeds or fails), the connector notifies the CD pipeline to continue so the pipeline can perform post-deployment activities, such as integration testing.

### Kubernetes clusters

At least one Azure Arc-enabled Kubernetes or Azure Kubernetes Service (AKS) cluster serves the different environments needed by the application. For example, a single cluster can serve both a dev and QA environment through different namespaces. A second cluster can provide easier separation of environments and more fine-grained control.

## Example workflow

As an application developer, Alice:

- Writes application code.
- Determines how to run the application in a Docker container.
- Defines the templates that run the container and dependent services in a Kubernetes cluster.

Alice wants to make sure the application has the capability to run in multiple environments, but she doesn't know the specific settings for each environment.

Suppose Alice wants to make an application change that alters the Docker image used in the application deployment template.

1. Alice changes the deployment template, pushes it to a remote branch called `alice` in the Application Repo, and opens a pull request for review against the `main` branch.
2. Alice asks her team to review the change.

    - The PR pipeline runs validation.
    - After a successful PR pipeline run and team approval, the change is merged.
3. The CI pipeline then kicks off and validates Alice's change and successfully completes.

    - The change is safe to deploy to the cluster, and the artifacts are saved to the CI pipeline run.
4. The successful CI pipeline run triggers the CD pipeline.

    - The CD pipeline picks up the artifacts stored by Alice's CI pipeline run.
    - The CD pipeline substitutes the templates with environment-specific values and stages any changes against the existing cluster state in the GitOps repository.
    - The CD pipeline creates a pull request against the production branch of the GitOps Repo with the desired changes to the cluster state.
5. Alice's team reviews and approves her pull request.

    - The change is merged into the target branch corresponding to the environment.
6. Within minutes, Flux notices a change in the GitOps repository and pulls Alice's change.

    - Because of the Docker image change, the application pod requires an update.
    - Flux applies the change to the cluster.
    - Flux reports the deployment status back to the GitOps repository via [GitOps Connector](https://github.com/microsoft/gitops-connector).
7. The CD pipeline runs automated tests to verify the new deployment successfully completed and works as expected.

    Note

    For additional environments targeted for deployment, the CD pipeline iterates by creating a pull request for the next environment and repeats steps 4-7. The process many need extra approval for riskier deployments or environments, such as a security-related change or a production environment.
8. When all the environments have received successful deployments, the pipeline completes.