---
layout: Conceptual
title: Use Pod Security Admission in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-psa
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
description: Learn how to enable and use Pod Security Admission with Azure Kubernetes Service (AKS).
ms.custom: azure-kubernetes-service
ms.topic: how-to
ms.subservice: aks-security
ms.date: 2023-09-12T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 3f8381ed-5d63-5ff1-33d1-d0a43ec355b6
document_version_independent_id: ef16d142-2543-9146-bf9c-0b6729e09aac
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-psa.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/use-psa
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-psa.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/85471516-e887-4861-a31d-238805d7ea16
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/4050859d-6dc5-419c-9a74-98f056c86e70
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 4a26f87f-039b-d294-e023-ad0fa8160532
---

# Use Pod Security Admission in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Pod Security Admission (PSA) uses labels to enforce Pod Security Standards policies on pods running in a namespace. In AKS, Pod Security Admission is enabled by default. For more information about Pod Security Admission and Pod Security Standards, see [Enforce Pod Security Standards with namespace labels](https://kubernetes.io/docs/tasks/configure-pod-container/enforce-standards-namespace-labels/) and [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/).

Pod Security Admission is a built-in policy solution for single cluster implementations. If you want to use an enterprise-grade policy, we recommend you use [Azure policy](use-azure-policy).

## Before you begin

- An Azure subscription. If you don't have an Azure subscription, you can create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- [Azure CLI installed](/en-us/cli/azure/install-azure-cli).
- An existing AKS cluster running Kubernetes version 1.23 or higher.

## Enable Pod Security Admission for a namespace in your cluster

### Enable PSA for a single namespace

- Enable PSA for a single namespace in your cluster using the `kubectl label` command and set the `pod-security.kubernetes.io/enforce` label with the policy value you want to enforce. The following example enables the `restricted` policy for the *NAMESPACE* namespace.

    ```azurecli
    kubectl label --overwrite ns NAMESPACE pod-security.kubernetes.io/enforce=restricted
    ```

### Enable PSA for all namespaces

- Enable PSA for all namespaces in your cluster using the `kubectl label` command and set the `pod-security.kubernetes.io/warn` label with the policy value you want to enforce. The following example enables the `baseline` policy for all namespaces in your cluster. This policy generates a user-facing warning if any pods are deployed to a namespace that doesn't meet the *baseline* policy.

    ```azurecli
    kubectl label --overwrite ns --all pod-security.kubernetes.io/warn=baseline
    ```

## Enforce a Pod Security Admission policy with a deployment

1. Create two namespaces using the `kubectl create namespace` command.

    ```azurecli
    kubectl create namespace test-restricted
    kubectl create namespace test-privileged
    ```
2. Enable a PSA policy for each namespace, one with the `restricted` policy and one with the `baseline` policy, using the `kubectl label` command.

    ```azurecli
    kubectl label --overwrite ns test-restricted pod-security.kubernetes.io/enforce=restricted pod-security.kubernetes.io/warn=restricted
    kubectl label --overwrite ns test-privileged pod-security.kubernetes.io/enforce=privileged pod-security.kubernetes.io/warn=privileged
    ```

    This configures the `test-restricted` and `test-privileged` namespaces to block running pods and generate a user-facing warning if any pods that don't meet the configured policy attempt to run.
3. Attempt to deploy pods to the `test-restricted` namespace using the `kubectl apply` command. This command results in an error because the `test-restricted` namespace is configured to block pods that don't meet the `restricted` policy.

    ```azurecli
    kubectl apply --namespace test-restricted -f https://raw.githubusercontent.com/Azure-Samples/azure-voting-app-redis/master/azure-vote-all-in-one-redis.yaml
    ```

    The following example output shows a warning stating the pods violate the configured policy:

    ```output
    ...
    Warning: would violate PodSecurity "restricted:latest": allowPrivilegeEscalation != false (container "azure-vote-back" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "azure-vote-back" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "azure-vote-back" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "azure-vote-back" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
    deployment.apps/azure-vote-back created
    service/azure-vote-back created
    Warning: would violate PodSecurity "restricted:latest": allowPrivilegeEscalation != false (container "azure-vote-front" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "azure-vote-front" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "azure-vote-front" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "azure-vote-front" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
    deployment.apps/azure-vote-front created
    service/azure-vote-front created
    ```
4. Confirm there are no pods running in the `test-restricted` namespace using the `kubectl get pods` command.

    ```azurecli
    kubectl get pods --namespace test-restricted
    ```

    The following example output shows no pods running in the `test-restricted` namespace:

    ```output
    No resources found in test-restricted namespace.
    ```
5. Attempt to deploy pods to the `test-privileged` namespace using the `kubectl apply` command. This time, the pods should deploy successfully because the `test-privileged` namespace is configured to allow pods that violate the `privileged` policy.

    ```azurecli
    kubectl apply --namespace test-privileged -f https://raw.githubusercontent.com/Azure-Samples/azure-voting-app-redis/master/azure-vote-all-in-one-redis.yaml
    ```

    The following example output shows the pods deployed successfully:

    ```output
    deployment.apps/azure-vote-back created
    service/azure-vote-back created
    deployment.apps/azure-vote-front created
    service/azure-vote-front created
    ```
6. Confirm you have pods running in the `test-privileged` namespace using the `kubectl get pods` command.

    ```azurecli
    kubectl get pods --namespace test-privileged
    ```

    The following example output shows two pods running in the `test-privileged` namespace:

    ```output
    NAME                               READY   STATUS    RESTARTS   AGE
    azure-vote-back-6fcdc5cbd5-svbdf   1/1     Running   0          2m29s
    azure-vote-front-5f4b8d498-tqzwv   1/1     Running   0          2m28s
    ```
7. Remove the `test-restricted` and `test-privileged` namespaces using the `kubectl delete` command.

    ```azurecli
    kubectl delete namespace test-restricted test-privileged
    ```