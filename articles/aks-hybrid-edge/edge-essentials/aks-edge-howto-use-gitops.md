---
layout: Conceptual
title: GitOps with AKS Edge Essentials | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/edge-essentials/aks-edge-howto-use-gitops
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
learn_banner_products:
- azure
ms.service: azure-kubernetes-service-hybrid
description: Learn how to use GitOps with AKS Edge Essentials.
author: davidsmatlak
ms.author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.custom: template-how-to, edge-essentials
locale: en-us
document_id: c847dfd1-bbd9-d496-22d4-fadfc30c0373
document_version_independent_id: fd20787a-e0ce-0764-6368-8a9ec3a40b71
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/edge-essentials/aks-edge-howto-use-gitops.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/edge-essentials/aks-edge-howto-use-gitops
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/edge-essentials/aks-edge-howto-use-gitops.md
platformId: e60b7407-5485-4f96-6891-6c092517f259
---

# GitOps with AKS Edge Essentials | Microsoft Learn

This article describes how to deploy applications to your Arc-enabled AKS Edge Essentials cluster. The steps are as follows:

1. Point to your GitHub application to the Azure portal.
2. Push your application to your AKS Edge Essentials cluster by installing the GitOps configuration.
3. Commit a change to your GitHub application and show that your app updates automatically.

Note

Make sure you have allocated at least 4GB of RAM and 4 CPU for the Linux VM as well as a service IP range greater than 0. You might also need a larger disk space than the default 10 GB, depending on your workloads.

## Step 1: fork demo application repository

Go to the [Azure Arc Jumpstart repository](https://github.com/microsoft/azure-arc-jumpstart-apps) and fork it to your GitHub account.

## Step 2: create configuration

Go to your cluster in the Azure portal and select **GitOps**. Next, create a cluster-level configuration and a namespace-level configuration. Select **Create** and **Flux version 2**.

### Cluster-level configuration

| Attribute | Input |
| --- | --- |
| Configuration name | `config-nginx` |
| Namespace | `ingress-nginx` |
| Scope | Cluster |
| Source kind | Git repository |
| Repository URL | &lt;URL of your fork&gt; |
| Reference type | Branch |
| Branch | main |
| Repository type | Public |
| Sync interval | 1 |
| Sync timeout | 10 |
| **Kustomization** |  |
| Instance name | `nginx` |
| Path | `./nginx/release` |
| Sync interval | 10 |
| Sync timeout | 10 |
| Prune | Enabled |
| Force | Not enabled |

Wait until the `config-nginx` is successfully created and visible on your Azure portal GitOps before creating the namespace-level configuration (you can move on to creating the next configuration if the compliance is in a pending state).

[![Screenshot showing cluster-level configuration.](../media/aks-edge/gitops-first-config.png)](../media/aks-edge/gitops-first-config.png#lightbox)

### Namespace-level configuration

| Attribute | Input |
| --- | --- |
| Configuration name | `config-helloarc` |
| Namespace | `hello-arc` |
| Scope | Namespace |
| Source kind | Git Repository |
| Repository URL | &lt;URL of your fork&gt; |
| Reference type | Branch |
| Branch | main |
| Repository type | Public |
| Sync interval | 1 |
| Sync timeout | 10 |
| **Kustomization** |  |
| Instance name | `app` |
| Path | `./hello-arc/releases/app` |
| Sync interval | 10 |
| Sync timeout | 10 |
| Prune | Enabled |
| Force | Not enabled |

[![Screenshot showing namespace-level configuration.](../media/aks-edge/gitops-second-config.png)](../media/aks-edge/gitops-second-config.png#lightbox)

Refresh your configuration table and wait for the configuration to be installed and compliant. Using `kubectl`, check that the service is running:

```bash
kubectl get svc -n ingress-nginx
```

```bash
kubectl get pods -n hello-arc
```

[![Screenshot showing hello-arc service.](../media/aks-edge/hello-arc-pods-up.png)](../media/aks-edge/hello-arc-pods-up.png#lightbox)

Open a web browser and navigate to your node IP, which is the `external-IP` of your `ingress-nginx-controller`:

[![Screenshot of hello-arc application success.](../media/aks-edge/hello-arc-app-success.png)](../media/aks-edge/hello-arc-app-success.png#lightbox)

## Step 3: create Windows configuration (optional)

If you have a Windows node, you can also enable **flux2** for Windows. The **hello-arc-windows** sample uses a **hello-arc** Windows container.

Tip

Windows containers are larger in size than Linux containers. The download of the **hello-arc-windows** container can take up to 15 minutes.

Create a new namespace-level configuration for Windows nodes.

### Namespace-level configuration for Windows

| Attribute | Input |
| --- | --- |
| Configuration name | `config-helloarc-windows` |
| Namespace | `hello-arc` |
| Scope | Namespace |
| Source kind | Git Repository |
| Repository URL | &lt;URL of your fork&gt; |
| Reference type | Branch |
| Branch | main |
| Repository type | Public |
| Sync interval | 1 |
| Sync timeout | 10 |
| **Kustomization** |  |
| Instance name | `app` |
| Path | `./hello-arc-windows/releases/app` |
| Sync interval | 10 |
| Sync timeout | 10 |
| Prune | Enabled |
| Force | Not enabled |

## Step 4: update your application using GitOps

1. In your fork of the **azure-arc-jumpstart-apps** repository, navigate to **hello-arc &gt; releases &gt; app &gt; hello-arc.yaml**.
2. Make a change to this YAML file by selecting **Edit**. Change the **replicaCount** to 5. Change the value to "Deploying to AKS Edge Essentials Gitops!"
3. Commit this change.

    Note

    Because we set the **sync interval** to **1 min** when creating the configuration, Flux pulls down changes from GitHub every minute.

    [![Screenshot showing hello-arc yaml.](../media/aks-edge/edit-yaml.png)](../media/aks-edge/edit-yaml.png#lightbox)
4. Use `kubectl` to see the old pods terminate and new pods come online:

    ```bash
    kubectl get pods -n hello-arc -w
    ```

    [![Screenshot showing pods rolling update.](../media/aks-edge/pods-rolling-update.png)](../media/aks-edge/pods-rolling-update.png#lightbox)
5. Refresh your application to see this change reflected as a rolling update:

    [![Screenshot showing updated hello-arc application.](../media/aks-edge/app-update-success.png)](../media/aks-edge/app-update-success.png#lightbox)

For more information about GitOps, see the [Azure Arc Jumpstart guide](https://azurearcjumpstart.io/azure_arc_jumpstart/azure_arc_k8s/day2/microk8s/local_microk8s_gitops_helm/#deploy-gitops-configurations-and-perform-helm-based-gitops-flow-on-microk8s-as-an-azure-arc-connected-cluster).