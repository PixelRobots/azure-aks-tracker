---
layout: Conceptual
title: Deploy Helm charts with Azure Kubernetes Fleet Manager and Flux | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/howto-gitops-fleet-flux-helm
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
description: Learn how to use Fleet Manager and Flux Helm resources to deploy a Helm chart across member clusters and override the chart version on a selected cluster.
ms.date: 2026-11-03T00:00:00.0000000Z
ms.topic: how-to
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
ms.custom: devx-track-azurecli, references-regions
ai-usage: ai-assisted
locale: en-us
document_id: c54c695e-09a3-7809-801c-4db09b2a603a
document_version_independent_id: adc7a6ed-291b-a877-12bb-03b9487027fe
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/howto-gitops-fleet-flux-helm.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: kubernetes-fleet/howto-gitops-fleet-flux-helm
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/howto-gitops-fleet-flux-helm.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://authoring-docs-microsoft.poolparty.biz/devrel/fcc3cd4a-59ea-47a2-9cc1-784142a5a25d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7a55faf-a992-4e27-aa3a-eadc9830e778
platformId: 1cbeeaef-5db2-c389-4f5a-b98ec8dbf069
---

# Deploy Helm charts with Azure Kubernetes Fleet Manager and Flux | Microsoft Learn

**Applies to**: ✔️ Fleet Manager with hub cluster

In this article, you deploy the [AKS Store Demo](https://github.com/Azure-Samples/aks-store-demo) Helm chart across all member clusters in your fleet. You create the application namespace and Flux Helm resources on the Fleet Manager hub cluster, then distribute them across member clusters by using [Fleet Manager resource placement](quickstart-resource-propagation). You configure the `HelmRepository` and `HelmRelease` resources as suspended on the Fleet Manager hub cluster, and enable them only when distributed to member clusters. This approach demonstrates how to use Fleet Manager resource placement overrides.

[![Diagram showing how the Flux and Fleet Manager elements combined to deliver the end-to-end solution to distribute an application defined using a Helm chart.](media/howto-gitops-flux-helm/fleet-gitops-helm-workflow.png)](media/howto-gitops-flux-helm/fleet-gitops-helm-workflow.png#lightbox)

Important

Azure Kubernetes Fleet Manager preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. Azure Kubernetes Fleet Manager previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use.

## Before you begin

- If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- You need a Fleet Manager with a hub cluster and member clusters. If you don't have one, see [Create an Azure Kubernetes Fleet Manager resource and join member clusters by using the Azure CLI](quickstart-create-fleet-and-members).
- You need access to the Kubernetes API of the hub cluster. If you don't have access, see [Access the Kubernetes API for an Azure Kubernetes Fleet Manager hub cluster](access-fleet-hub-cluster-kubernetes-api).
- Set environment variables for your subscription, Fleet Manager resource, and member cluster that should receive the older artifact tag.

    ```bash
    export SUBSCRIPTION_ID=<subscription-id>
    export GROUP=<resource-group-name>
    export FLEET=<fleet-name>
    ```
- You need Azure CLI installed to complete this article. To install or upgrade, see [Install the Azure CLI](/en-us/cli/azure/install-azure-cli).
- Set the default Azure subscription by using the [`az account set`](/en-us/cli/azure/account#az-account-set) command:

    ```azurecli
    az account set --subscription ${SUBSCRIPTION_ID}
    ```

- For the subscription where Fleet Manager is deployed, register the following Azure resource providers.

    ```azurecli
    az provider register --namespace Microsoft.Kubernetes
    az provider register --namespace Microsoft.ContainerService
    az provider register --namespace Microsoft.KubernetesConfiguration
    ```
- The user who installs and configures the extension must have both the [Azure Kubernetes Fleet Manager Contributor](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-kubernetes-fleet-manager-contributor-role) and [Kubernetes Extension Contributor](/en-us/azure/role-based-access-control/built-in-roles/containers#kubernetes-extension-contributor) roles.
- You need the `k8s-extension` and `fleet` Azure CLI extensions. You can install them by running the following commands.

    ```azurecli
    az extension add --name k8s-extension
    az extension add --name fleet
    ```

    Run the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command to update to the latest version of the extensions.

    ```azurecli
    az extension update --name k8s-extension
    az extension update --name fleet
    ```
- Enable the Flux extension on the Fleet Manager hub cluster.

    ```azurecli
    az k8s-extension create \
        --name flux \
        --extension-type microsoft.flux \
        --cluster-name ${FLEET} \
        --resource-group ${GROUP} \
        --cluster-type fleets \
        --scope cluster
    ```

    If you want to change the namespace the Flux extension uses to be other than the default `flux-system`, provide the namespace by using the `--release-namespace` parameter.

    Note

    You can only install one instance of the Flux extension on a Fleet Manager.

## Stage resources on Fleet Manager hub cluster

Start by creating the application namespace and staging its resources on the Fleet Manager hub cluster.

- Get the kubeconfig file of the Fleet Manager hub cluster by using the [`az fleet get-credentials`](/en-us/cli/azure/fleet#az-fleet-get-credentials) command.

    ```azurecli
    az fleet get-credentials \
        --resource-group ${GROUP} \
        --name ${FLEET}
    ```
- Create the application namespace.

    ```bash
    kubectl create namespace aks-store-demo
    ```
- Use Fleet Manager resource placement to distribute the staged namespace across member clusters. Save the following YAML as `crp-aks-store-demo.yaml`.

    ```yaml
    apiVersion: placement.kubernetes-fleet.io/v1
    kind: ClusterResourcePlacement
    metadata:
      name: crp-aks-store-demo
    spec:
      resourceSelectors:
        - group: ""
          kind: Namespace
          version: v1
          name: aks-store-demo
          selectionScope: NamespaceOnly
      policy:
        placementType: PickAll
      strategy:
        type: RollingUpdate
        rollingUpdate:
          maxUnavailable: 1
          maxSurge: 25%
    ```
- Apply the resource placement on the Fleet Manager hub cluster.

    ```bash
    kubectl apply -f crp-aks-store-demo.yaml
    ```
- Authorize the `flux-applier` service account to manage resources in the `aks-store-demo` namespace. Save the following YAML as `apply-service-account.yaml`.

    ```yaml
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: flux-applier
      namespace: aks-store-demo
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      name: flux-applier
      namespace: aks-store-demo
    rules:
      - apiGroups: ["*"]
        resources: ["*"]
        verbs: ["*"]
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: flux-applier
      namespace: aks-store-demo
    subjects:
      - kind: ServiceAccount
        name: flux-applier
        namespace: aks-store-demo
    roleRef:
      kind: Role
      name: flux-applier
      apiGroup: rbac.authorization.k8s.io
    ```
- Apply the authorization on the Fleet Manager hub cluster.

    ```bash
    kubectl apply -f apply-service-account.yaml
    ```
- So the Flux extension on member clusters can also manage resources in the distributed `aks-store-demo` namespace, use a Fleet Manager resource placement to roll out the service account to member clusters. Save the following YAML as `distribute-service-account.yaml`.

    ```yaml
    apiVersion: placement.kubernetes-fleet.io/v1
    kind: ResourcePlacement
    metadata:
      name: aks-store-demo-flux-roles-placement
      namespace: aks-store-demo
    spec:
      resourceSelectors:
        - group: ""
          version: v1
          kind: ServiceAccount
          name: flux-applier
    
        - group: rbac.authorization.k8s.io
          version: v1
          kind: Role
          name: flux-applier
    
        - group: rbac.authorization.k8s.io
          version: v1
          kind: RoleBinding
          name: flux-applier
    
      policy:
        placementType: PickAll
      strategy:
        type: RollingUpdate
        rollingUpdate:
          maxUnavailable: 1
          maxSurge: 25%
    ```
- Apply the placement on the Fleet Manager hub cluster.

    ```bash
    kubectl apply -f distribute-service-account.yaml
    ```
- Next, attach the hub cluster to the Git source and use Kustomize to hydrate the resources onto the hub cluster. Save the following YAML as `bootstrap-fleet-gitops-helm.yaml`.

    ```yaml
    apiVersion: source.toolkit.fluxcd.io/v1
    kind: GitRepository
    metadata:
        name: git-repo-fleet-config
        namespace: aks-store-demo
    spec:
        interval: 1m
        url: https://github.com/azure-samples/aks-store-demo
        ref:
            branch: main
    ---
    apiVersion: kustomize.toolkit.fluxcd.io/v1
    kind: Kustomization
    metadata:
        name: kustonize-fleet-config
        namespace: aks-store-demo
    spec:
        interval: 1m
        path: ./fleet/aks-store-fleet-helm
        prune: true
        sourceRef:
          kind: GitRepository
          name: git-repo-fleet-config
    ```
- Stage the resources on the Fleet Manager hub cluster.

    ```bash
    kubectl apply -f bootstrap-fleet-gitops-helm.yaml
    ```

    Note

    The Fleet Manager hub cluster doesn't run synchronized resources locally by design. The hub cluster is intended to only store resource definitions for distribution to member clusters.

## Understanding the source repository

When Flux synchronizes the GitRepo source, it applies the manifests in the [aks-store-fleet-helm](https://github.com/Azure-Samples/aks-store-demo/tree/main/fleet/aks-store-fleet-helm) folder and runs the Kustomization.

The file contents in the folder perform the following functions:

- **app-release.yaml** - Flux HelmRelease that runs on each member cluster, deploying the contents of the HelmRepository.
- **app-source.yaml** - Flux HelmRepository source that points to the repository containing the Helm chart to deploy.
- **fleet-resource-placement.yaml** - A Fleet Manager namespace-scoped [resource placement](howto-understand-placement) that selects just the HelmRepository and HelmRelease resources in the application namespace and distributes them to the same namespace on all member clusters.
- **fleet-resource-override.yaml** - A Fleet Manager [resource placement override](howto-use-overrides-customize-resources-placement) that removes the `suspend` from the HelmRepository and HelmRelease resources when it distributes them to member clusters.

Note

Both app components are bundled with `suspend` set to `true` so that the Fleet Manager hub cluster doesn't reconcile the resources. The hub cluster can't schedule workloads, so there's no impact other than an unnecessary use of scheduler time on the hub.

## Validating the deployment

1. Check the placement rollout:

    ```bash
    kubectl get resourceplacement aks-store-demo-flux-placement -n aks-store-demo
    ```

    Your output should look similar to the following example:

    ```output
    NAME                             GEN   SCHEDULED   SCHEDULED-GEN   AVAILABLE   AVAILABLE-GEN   AGE
    aks-store-demo-flux-placement    1     True        1               True        1               2m45s
    ```
2. On member clusters, view the services that Flux deployed from the OCI artifact.

    ```bash
    kubectl get services --namespace aks-store-demo
    ```
3. Browse to the `store-front` or `store-admin` services to access the web experiences deployed and confirm the solution functions as expected.

## Deleting the deployment

Delete the Kustomization on the Fleet Manager hub cluster. This action removes the resource placement and override, which in turn removes the application deployment on member clusters.

```bash
kubectl delete Kustomization kustomize-fleet-config -n aks-store-demo
```

## Alternative use cases

To gradually roll out an OCI artifact update, change the tag in the `OCIRepository` and use a namespace-scoped `ResourcePlacement` with a staged update run. Configure stages to distribute the updated source to clusters in order, and validate each stage before proceeding. To roll back, restore the previous artifact tag and run another staged rollout. For details, see [Control cluster order for resource placement](howto-staged-update-run) and [Understand resource placement](howto-understand-placement).

## Summary

In this article, you deployed the AKS Store Demo Helm chart across Fleet Manager member clusters by using Flux `HelmRepository` and `HelmRelease` resources. You staged the resources on the Fleet Manager hub cluster, used resource placement to distribute the namespace and Helm resources, applied a chart version override for one selected member cluster, and validated the deployed services.

This approach adds Fleet Manager placement, rollout control, and per-cluster overrides to Flux reconciliation, which helps you manage multicluster deployments without maintaining separate Flux configuration for each target cluster. As you add or remove clusters from your environment, you can easily expand, move, or remove your Helm managed applications from those clusters all via Fleet Manager.