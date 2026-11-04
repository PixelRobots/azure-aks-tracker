---
layout: Conceptual
title: GitOps-based deployments with Azure Kubernetes Fleet Manager and Flux | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/howto-gitops-fleet-flux
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
description: Learn how Fleet Manager can use the Flux v2 GitOps extension model to deploy applications across multiple clusters and tenant boundaries using Git and OCI sources.
ms.date: 2026-10-27T00:00:00.0000000Z
ms.topic: concept-article
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
ms.custom: devx-track-azurecli, references-regions
ai-usage: ai-assisted
locale: en-us
document_id: 7d8e3fe1-b1b7-7626-fe6c-eba0313915bf
document_version_independent_id: 513f071c-e0ea-5f13-51cc-1ebd7d7ec162
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/howto-gitops-fleet-flux.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: kubernetes-fleet/howto-gitops-fleet-flux
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/howto-gitops-fleet-flux.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/63959238-cb90-4871-a33d-4a5519097e47
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/78d87f42-5582-4a6b-90be-7db2f12b34e6
platformId: f1cc5f12-1dc7-764e-508c-bd93ea6a45b3
---

# GitOps-based deployments with Azure Kubernetes Fleet Manager and Flux | Microsoft Learn

**Applies to**: ✔️ Fleet Manager with hub cluster

Azure Kubernetes Fleet Manager can use GitOps to reconcile application state across a fleet of member clusters. The Fleet Manager GitOps model follows the same Flux v2 extension pattern used by AKS and Azure Arc-enabled Kubernetes, but is optimized for fleet-level deployment at scale. This model is well suited for multicluster rollout, environment promotion, and shared platform operations across many application teams.

The key benefits of adopting GitOps with Fleet Manager include:

- Consistent application deployment across a fleet of member clusters.
- Separation of responsibilities between platform teams and application teams.
- Faster recovery and repeatable cluster state because the desired configuration is versioned in Git.
- Better support for multitenancy, environment isolation, and controlled rollout across regions or clusters.
- Support for both Git-based and OCI-based sources, which is useful for registry-first delivery workflows.

With GitOps, you declare the desired state of Kubernetes workloads in a repository or OCI registry. The repository or registry can contain:

- [YAML manifests](https://yaml.org/) for workloads, namespaces, and policies
- [Helm charts](https://helm.sh/docs/topics/charts/) for packaged applications
- [Kustomize overlays](https://kustomize.io/) for environment-specific variations
- [OCI artifacts](https://opencontainers.org/) for immutable, registry-hosted application packages

Because the source is versioned, changes are auditable and reproducible. Flux controllers running in the target cluster continuously reconcile the actual cluster state with the declared desired state.

Important

Azure Kubernetes Fleet Manager preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. Azure Kubernetes Fleet Manager previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use.

## GitOps in Fleet Manager

Fleet Manager's GitOps support uses the same Flux extension model as other Azure Kubernetes deployment surfaces. A cluster extension such as `microsoft.flux` installs the Flux components needed to reconcile workloads from a source. The Fleet Manager control plane can then coordinate delivery across selected member clusters.

This architecture is especially useful when you want to combine two patterns:

- Use Fleet Manager for cluster selection, placement, and rollout orchestration.
- Use Flux for continuous reconciliation of workloads from Git or OCI sources.

In practice, Fleet Manager and Flux complement each other. Fleet Manager decides where workloads should run, while Flux ensures the desired state is maintained on those clusters.

Note

The Fleet Manager hub cluster doesn't run synchronized resources locally by design. The hub cluster is intended to only store resource definitions for distribution to member clusters.

## Flux extension model

The Fleet Manager GitOps model follows the same cluster extension pattern used by Azure Kubernetes Service and Azure Arc-enabled Kubernetes. The `microsoft.flux` extension installs the core Flux controllers and supporting Kubernetes resources needed to reconcile workloads in a cluster.

By default, the extension installs the following components:

- [Flux Source controller](https://fluxcd.io/flux/components/source/): watches `GitRepository`, `OCIRepository`, `HelmRepository`, and related source objects.
- [Flux Kustomize controller](https://fluxcd.io/flux/components/kustomize/): applies Kustomize or raw YAML manifests to a cluster.
- [Flux Helm controller](https://fluxcd.io/flux/components/helm/): manages Helm-based deployments.
- [Flux Notification controller](https://fluxcd.io/flux/components/notification/): sends reconciliation and alert events.
- Flux custom resources such as `GitRepository`, `OCIRepository`, `Kustomization`, and `HelmRelease`.
- The Azure `fluxconfig-agent` and `fluxconfig-controller` components that connect the cluster to the managed configuration service.

By using this extension model, you can enable a cluster with GitOps through an Azure-managed configuration resource, while the Flux controllers running in the cluster drive the actual reconciliation.

## Multi-tenant deployments

Multi-tenancy is a key requirement for many fleet scenarios. In a Fleet Manager deployment, different application teams or business units often need isolated namespaces, different policy boundaries, or separate delivery pipelines even though they share the same fleet.

The GitOps pattern works well for this requirement because you can scope a deployment to a tenant namespace, a specific application, or a specific set of clusters. Each tenant can own its own source repository, Kubernetes namespaces, and application overlays without sharing the same GitOps configuration or deployment path.

A typical multitenant design includes:

- One fleet with multiple member clusters.
- One or more managed namespaces per tenant or business unit.
- Separate Flux configurations for each team or environment.
- Namespace-scoped RBAC for team-specific access to workloads and secrets.
- Tenant-specific overlays or source paths that only include the workloads relevant to that team.

This pattern keeps application ownership aligned with platform responsibilities. The fleet operator manages connectivity, cluster placement, and shared service boundaries, while each tenant manages its deployment contents through its own GitOps source.

### Multitenancy best practices

When you design multitenant Fleet Manager GitOps, keep the following recommendations in mind:

- Keep namespace boundaries aligned with the tenant or application domain.
- Use a single source repository per tenant when isolation is required, or use a shared repository with clear tenant-specific paths.
- Ensure `sourceRef` references stay within the same namespace when you use Flux multitenancy controls.
- Scope workloads to the appropriate cluster sets to avoid accidental deployment to the wrong member clusters.
- Use Fleet Manager policies and RBAC to separate cluster and namespace access between tenants.

## Multi-cluster deployments

Fleet Manager is built for multi-cluster orchestration. GitOps adds the desired-state reconciliation layer that makes it possible to deploy the same workload or workload variation across many clusters in a predictable way.

A common Fleet Manager pattern is:

1. Define a Fleet and join the member clusters.
2. Create a resource placement or cluster selection policy for the workloads.
3. Use GitOps to reconcile the workload manifests to the selected clusters.
4. Roll out updates by environment, region, or cluster group.

This gives you a consistent deployment model for:

- Regional rollouts.
- Staged releases across dev, test, and production clusters.
- Environment-specific overlays.
- Shared services that must be present on multiple member clusters.

Fleet Manager and Flux can work together across cluster groups without requiring manual duplication of deployment logic. The source of truth remains in Git or an OCI registry, while the placement rules decide which clusters receive the desired state.

## OCIRepository sources

Flux supports both Git and OCI sources. For Fleet Manager, OCIRepository support is especially important because it aligns closely with the open source Flux Operator model and with registry-first application delivery workflows.

An `OCIRepository` points to a container registry location that contains an OCI artifact, such as a versioned application bundle or Kustomize package. This pattern is useful when you want immutable, signed, and centrally managed artifacts instead of directly syncing a Git repo.

A common pattern is to store application packages in an Azure Container Registry (ACR) or another OCI-compatible registry, then have Flux reconcile the artifact into the cluster through an `OCIRepository` and `Kustomization`:

```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: OCIRepository
metadata:
  name: team-a-application
  namespace: team-a
spec:
  interval: 5m
  url: oci://contoso.azurecr.io/team-a/application
  ref:
    tag: 2026.08.27
  secretRef:
    name: acr-credentials
```

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: team-a-application
  namespace: team-a
spec:
  interval: 10m
  path: ./deploy
  prune: true
  sourceRef:
    kind: OCIRepository
    name: team-a-application
```

This approach is well suited for:

- Multi-tenant application packaging.
- Registry-based release promotion between environments.
- Immutable deployment artifacts that support rollback and auditability.
- Shared software distribution across many clusters in a fleet.

OCIRepository sources also work well with a multicluster deployment model because the same artifact can be promoted and consumed consistently by different member clusters, while the Fleet Manager placement policy decides which cluster set receives the application.

## Fleet Manager design patterns

A Fleet Manager GitOps architecture typically follows one of these patterns:

- Shared platform repository: one Git or OCI source contains common infrastructure and shared application overlays.
- Tenant-specific repositories: each team has a dedicated source for their workloads and namespace configuration.
- Centralized platform plus per-environment overlay: shared base manifests are promoted with environment-specific Kustomize overlays.
- Registry-based releases: immutable OCI artifacts are stored in a registry and pulled into clusters as part of the reconciliation flow.

The right pattern depends on the level of autonomy, governance, and release control you need across your fleet.