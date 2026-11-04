---
layout: Conceptual
title: Use Azure Kubernetes Fleet Manager to deliver modern GitOps Architectures | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/concepts-gitops-fleet-scale
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
description: Learn how Fleet Manager can be combined with GitOps platforms to support modern GitOps architectures and deliver a service akin to a Kubernetes-native CDN for deployments.
ms.date: 2026-10-27T00:00:00.0000000Z
ms.topic: concept-article
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
ms.custom: devx-track-azurecli, references-regions
ai-usage: ai-assisted
locale: en-us
document_id: 0d7e7123-188f-4b36-26e0-1d53bd9e0855
document_version_independent_id: d6db80cd-66d2-6718-be39-fd282fe57d29
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/concepts-gitops-fleet-scale.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: kubernetes-fleet/concepts-gitops-fleet-scale
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/concepts-gitops-fleet-scale.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/63959238-cb90-4871-a33d-4a5519097e47
- https://authoring-docs-microsoft.poolparty.biz/devrel/befac1c4-b371-401f-bb32-b2c555258404
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/78d87f42-5582-4a6b-90be-7db2f12b34e6
- https://authoring-docs-microsoft.poolparty.biz/devrel/a3a42e80-4ec5-48ab-90ee-478df3614861
platformId: d134184f-adaa-dbfe-5700-e869c38ef030
---

# Use Azure Kubernetes Fleet Manager to deliver modern GitOps Architectures | Microsoft Learn

**Applies to**: ✔️ Fleet Manager with hub cluster

GitOps is the preferred model for deploying Kubernetes applications and cluster configurations. By defining desired state declaratively and continuously reconciling clusters against that state, GitOps delivers consistency, auditability, and operational simplicity.

However, most GitOps platforms were originally designed around the assumption that you manage each Kubernetes cluster independently. As your organization grows from a handful of clusters to hundreds or thousands, new challenges emerge:

- Coordinating deployments across many clusters.
- Managing placement decisions.
- Enforcing rollout order and approval workflows.
- Reducing duplication across repositories and controllers.
- Supporting multicloud and edge environments.
- Avoiding Git and controller scaling bottlenecks.

Azure Kubernetes Fleet Manager introduces a higher-level orchestration layer above individual clusters. Rather than replacing GitOps tools such as Flux, Fleet Manager complements them by handling the concerns that naturally emerge at fleet scale, including placement, rollout orchestration, update management, and multicluster governance. Fleet Manager provides centralized resource placement and safe multicluster update orchestration capabilities designed specifically for large Kubernetes environments.

The result is a modern platform architecture where GitOps remains responsible for local cluster reconciliation while Fleet Manager provides fleet-level coordination.

Important

Azure Kubernetes Fleet Manager preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. Azure Kubernetes Fleet Manager previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use.

## Challenges of existing GitOps architectures

Traditional GitOps architectures typically follow this basic model:

[![Diagram showing a Git repository feeding a GitOps controller, which reconciles a Kubernetes cluster.](media/concepts-gitops-at-scale/gitops-traditional-model.png)](media/concepts-gitops-at-scale/gitops-traditional-model.png#lightbox)

For a single cluster this model works extremely well.

While technically scalable, platform teams frequently encounter:

- Large numbers of reconciliation loops.
- Repository fan-out challenges.
- Large pull rates against Git providers.
- Complex promotion pipelines.
- Custom tooling for progressive rollout patterns.
- Difficulty coordinating deployments across environments.

For hundreds of clusters and environments it often evolves into:

[![Diagram showing a Git repository feeding separate Flux instances for each cluster across Dev, Test, and Prod environments.](media/concepts-gitops-at-scale/gitops-many-flux-instances.png)](media/concepts-gitops-at-scale/gitops-many-flux-instances.png#lightbox)

At this scale, teams often have to hand-tune controllers, repository boundaries, source paths, and sync intervals to keep the system stable. A common pattern is to split repositories, add per-team overlays, or throttle controller settings only after a bottleneck or drift problem appears in production. This approach creates operational overhead because the architecture is no longer simple to operate at scale. Much of the tuning happens reactively, when the first reliability or performance issue surfaces.

GitOps tools excel at ensuring an individual cluster eventually converges to its intended state. They are less suited to acting as a global deployment orchestrator across hundreds of clusters.

This distinction becomes increasingly important as organizations scale the number of clusters they operate and adopt platform engineering and cloud native continuous delivery practices.

## Evolving GitOps with Fleet Manager

Fleet Manager addresses these scale challenges by separating fleet orchestration from cluster-level reconciliation, allowing organizations to manage deployment placement, rollout progression, and governance at the fleet level while preserving the GitOps model that teams already trust.

### Separating responsibilities

A useful design principle is to separate deployment responsibilities into four layers:

| Layer | Responsibility |
| --- | --- |
| Source of truth | Git, OCI, artifact repositories |
| Reconciliation | Flux |
| Placement and distribution | Fleet Manager |
| Rollout and governance | Fleet Manager |

Under this model:

- Developers continue using GitOps workflows.
- Flux remains the reconciliation engine.
- Fleet Manager determines where workloads run.
- Fleet Manager orchestrates deployment progression.

Each component focuses on what it does best.

### Enabling GitOps controllers on Fleet Manager

When you run GitOps controllers on the Fleet Manager hub cluster, the traditional GitOps model changes to:

[![Diagram showing a Fleet Hub cluster where Flux connects to the source and Fleet Placement distributes to 1,000 member clusters, where Flux reconciles changes.](media/concepts-gitops-at-scale/gitops-hub-flux-placement.png)](media/concepts-gitops-at-scale/gitops-hub-flux-placement.png#lightbox)

In this new approach:

- You pull Git once to the hub cluster.
- Fleet Manager resource placement handles distribution and modifies configuration based on requirements.
- Each member pulls OCI artifacts or Helm charts from a scalable repository.
- Local Flux reconciles configuration based on distributed resources from Fleet Manager.

This approach significantly reduces:

- Controller footprint.
- Git server load.
- Artifact fetches.
- Potential reconciliation storms.

Fleet Manager behaves like a Kubernetes-native CDN for deployments.

### GitOps remains the cluster-level reconciliation engine

Fleet Manager doesn't attempt to replace Flux. The controllers on each member cluster remain responsible for:

- Applying manifests.
- Managing deployment release artifacts such as Helm charts or OCI artifacts.
- Dependency ordering.
- Drift detection.
- Workload reconciliation.
- Health status monitoring.

For each member cluster, the local reconciliation loop stays the same. This approach preserves your existing investments and avoids disrupting established GitOps operating models.

[![Diagram showing a member cluster where Flux reconciles Helm releases and Kustomizations to deploy workloads.](media/concepts-gitops-at-scale/gitops-member-cluster-components.png)](media/concepts-gitops-at-scale/gitops-member-cluster-components.png#lightbox)

### Fleet Manager becomes the fleet-level control plane

Fleet Manager introduces a layer above individual clusters.

Now, instead of asking: how do I deploy this manifest?

Teams can ask: Which clusters should receive this application?

Fleet Manager provides intelligent resource placement based on cluster properties, labels, regions, resource availability, and other fleet-level attributes.

Cluster-level Flux accepts distributed resources and deploys application components.

[![Diagram showing a Helm or OCI artifact application passing through a Fleet Placement Policy to Cluster A, B, and C, each running Flux.](media/concepts-gitops-at-scale/gitops-fleet-placement-policy.png)](media/concepts-gitops-at-scale/gitops-fleet-placement-policy.png#lightbox)

Platform teams can express intent once and allow placement policies to determine the appropriate targets.

This approach eliminates significant duplication across repositories and deployment definitions.

### Supporting Gitless GitOps

The GitOps ecosystem is increasingly moving toward OCI-based delivery models.

Flux's [D2 reference architecture](https://control-plane.io/posts/d2-reference-architecture-guide/) and broader industry efforts are encouraging a separation between:

- Authoring.
- Packaging.
- Distribution.
- Reconciliation.

In these models, Git becomes an authoring system rather than a runtime dependency.

A modern workflow becomes:

[![Diagram showing the Gitless GitOps workflow: Git, Build, OCI artifact or Helm chart, Fleet Distribution, and Cluster Reconciliation.](media/concepts-gitops-at-scale/gitops-new-workflow.png)](media/concepts-gitops-at-scale/gitops-new-workflow.png#lightbox)

Benefits include:

- Reduced Git server load.
- Immutable, signed deployment artifacts.
- Better promotion workflows.
- Improved supply chain security.
- Faster deployment at scale.

Fleet Manager aligns naturally with this approach. Applications can be packaged into OCI artifacts and distributed independently of Git repositories, while Flux continues performing cluster-level reconciliation. This approach allows organizations to evolve from traditional Git-centric GitOps toward Gitless GitOps without replacing their operational model.

This approach allows organizations to evolve from traditional Git-centric GitOps toward Gitless GitOps without replacing their operational model.

## Overcoming traditional GitOps scale constraints

Large GitOps environments often encounter several limitations.

### Controller fan-out

Deploying an application to hundreds of clusters means hundreds of independent reconciliations.

Fleet allows targeting clusters through placement policies rather than managing each cluster explicitly.

### Promotion complexity

Many organizations rely on repository structures such as:

[![Diagram showing a repository structure with dev, test, stage, and prod folders.](media/concepts-gitops-at-scale/gitops-environment-folders.png)](media/concepts-gitops-at-scale/gitops-environment-folders.png#lightbox)

Promotion frequently requires:

- Pull requests.
- Cherry-picks.
- Branch management.
- Repository synchronization.

Fleet Manager enables platform teams to manage deployment progression as a deployment concern rather than a repository topology concern.

### Multi-cloud coordination

GitOps tools largely operate cluster by cluster.

Fleet Manager is designed to manage Kubernetes clusters across regions, clouds, and on-premises environments through a single control plane.

This approach provides a common orchestration layer regardless of where member clusters are running.

### Progressive rollouts beyond GitOps

One of the most significant advantages of Fleet Manager is deployment orchestration.

Traditional GitOps tools typically provide:

- Reconciliation.
- Drift correction.
- Deployment status.

Large-scale rollout strategies often require additional tooling.

Fleet Manager introduces reusable rollout strategies by using:

- Stages.
- Groups.
- Approval gates.
- Concurrency controls.
- Scheduled execution.
- Automated progression rules.

These capabilities were designed for safe fleet-wide operations.

Example:

[![Diagram showing a four-stage rollout: Canary, Region Test, and Production Region A each with soak and approval, then Production Region B.](media/concepts-gitops-at-scale/gitops-rollout-stages.png)](media/concepts-gitops-at-scale/gitops-rollout-stages.png#lightbox)

Each stage can include approvals, waits, and progression control based on successful deployment to clusters in the stage.

GitOps controllers continue reconciling locally once a deployment reaches a cluster.

Fleet Manager resource placement controls when clusters receive the deployment.

## Reference architecture

[![Reference architecture showing developers, Git repo, CI pipeline, and OCI artifacts feeding Fleet Manager placement, rollouts, and governance, which deliver to clusters where Flux reconciles workloads.](media/concepts-gitops-at-scale/gitops-reference-architecture.png)](media/concepts-gitops-at-scale/gitops-reference-architecture.png#lightbox)

In this architecture:

- Git remains an authoring workflow.
- OCI or Helm charts become the distribution format.
- Flux remains the reconciliation engine.
- Fleet Manager becomes the orchestration plane.

## Conclusion

GitOps remains the best model for Kubernetes reconciliation, but fleet-scale operations introduce concerns that extend beyond the scope of traditional GitOps tooling.

Azure Kubernetes Fleet Manager complements rather than replaces GitOps by introducing fleet-level placement, governance, and rollout orchestration. While Flux continues ensuring that individual clusters converge on their desired state, Fleet Manager determines where applications should run, how deployments progress across environments, and how organizations safely operate at scale.

The resulting architecture supports both traditional Git-based workflows and emerging Gitless GitOps patterns, allowing organizations to scale application delivery from a few clusters to hundreds or thousands without abandoning the GitOps principles that made Kubernetes operations successful in the first place.