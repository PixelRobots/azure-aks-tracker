---
layout: Conceptual
title: Deploy CanIPull to an Azure Kubernetes Service (AKS) cluster - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/deploy-canipull-application-aks
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
description: Learn how to deploy CanIPull to an AKS cluster and test DNS resolution and the initial Azure Container Registry token exchange from a node.
ms.topic: how-to
ms.date: 2026-08-27T00:00:00.0000000Z
ms.custom: aeo-round-2
author: schaffererin
ms.author: schaffererin
ai-usage: ai-generated
locale: en-us
document_id: 68494d63-26ff-8a9e-dfa9-528ec86ce4e9
document_version_independent_id: ae89307d-7ba2-9a83-7502-a3f6b480cb92
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/deploy-canipull-application-aks.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/deploy-canipull-application-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/deploy-canipull-application-aks.md
platformId: 43fe1083-b9b9-72f6-0924-46b32e89eafb
---

# Deploy CanIPull to an Azure Kubernetes Service (AKS) cluster - Azure Kubernetes Service | Microsoft Learn

[CanIPull](https://github.com/Azure/aks-canipull) is a diagnostic tool for Azure Kubernetes Service (AKS). Deploy it by using Azure Copilot or the complete Kubernetes manifest in this article. CanIPull reads the cluster identity configuration from one selected node, checks DNS resolution for an Azure Container Registry (ACR) authentication server, and validates the initial ACR token exchange.

This article shows you how to run CanIPull by using Azure Copilot or a Kubernetes manifest. CanIPull `v0.1.0` runs on one AMD64 Linux node at a time. Repeat the check on other supported nodes to compare their connectivity or configuration.

Important

CanIPull isn't an end-to-end image pull test. A successful result doesn't confirm access to a repository, image manifest, or image layer because CanIPull doesn't select or pull an image.

## Prerequisites

Before you begin, you need:

- An existing AKS cluster with at least one AMD64 Linux node.
- An existing ACR instance that you want to test.

To deploy CanIPull with Azure Copilot, you also need access to [Azure Copilot in the Azure portal](/en-us/azure/copilot/overview).

To deploy CanIPull manually, you also need:

- [Azure CLI](/en-us/cli/azure/install-azure-cli) installed.
- An authenticated Azure CLI session with permissions to get user credentials for the AKS cluster and read the ACR instance.
- [`kubectl` configured to connect to your AKS cluster](learn/quick-kubernetes-deploy-cli#connect-to-the-cluster).
- Kubernetes permissions to list nodes at cluster scope; create, get, list, watch, and delete pods in the `default` namespace; and get pod logs in the `default` namespace.

## Deploy CanIPull with Azure Copilot

Azure Copilot can select the AKS cluster, AMD64 Linux node, and ACR authentication server, and then deploy CanIPull for you. The diagnostic checks DNS resolution and ACR token exchange from the selected node. It doesn't select or access a repository or image.

1. In the Azure portal, open **Copilot**.
2. Enter one of the following prompts:

- `Help me deploy CanIPull to my AKS cluster.`
- `Can an AMD64 Linux node in my AKS cluster resolve and authenticate to a specific Azure Container Registry?`
- `Help me test ACR token exchange from an AMD64 Linux node in my AKS cluster.`

1. Select the AKS cluster and the AMD64 Linux node where you want CanIPull to run.
2. Select the ACR instance whose authentication server you want to use for the DNS and token exchange checks.
3. Review the selections, and then confirm the deployment.
4. After the deployment completes, follow the prompt to open the **Run command** pane.
5. Review the CanIPull logs for DNS, cluster identity, and ACR token exchange results.

For more information about this experience, see [Use CanIPull with Azure Copilot](/en-us/azure/copilot/work-aks-clusters#deploy-aks-canipull-and-troubleshoot-image-pull-issues).

## Deploy CanIPull manually

To deploy CanIPull manually, connect to the cluster, select an AMD64 Linux node, get the fully qualified ACR login server, save the complete pod manifest provided in this section as `canipull.yaml`, and run `kubectl apply --filename canipull.yaml`. The one-shot pod lets you choose the target node and inspect the diagnostic logs directly with `kubectl`.

Important

The manifest mounts `/etc/kubernetes/azure.json` from the selected node. This file contains sensitive cluster identity configuration. Deploy the pod only if you're a trusted cluster administrator. Don't increase the CanIPull verbosity because higher levels can print access tokens. Delete the pod as soon as you finish the test.

### Connect to the cluster and select a node

1. Set variables for the AKS cluster and ACR instance.

    ```azurecli
    RESOURCE_GROUP=<resource-group>
    CLUSTER_NAME=<aks-cluster-name>
    ACR_NAME=<acr-name>
    ```
2. Get the cluster credentials.

    ```azurecli
    az aks get-credentials \
      --resource-group $RESOURCE_GROUP \
      --name $CLUSTER_NAME
    ```
3. Get the ACR login server. CanIPull expects the fully qualified login server, such as `myregistry.azurecr.io`, rather than the ACR resource name.

    ```azurecli
    ACR_LOGIN_SERVER=$(az acr show \
      --name $ACR_NAME \
      --query loginServer \
      --output tsv)
    
    echo $ACR_LOGIN_SERVER
    ```
4. List the AMD64 Linux nodes and choose the node where you want to run the diagnostic check. CanIPull `v0.1.0` supports only AMD64 nodes.

    ```bash
    kubectl get nodes \
      --selector kubernetes.io/os=linux,kubernetes.io/arch=amd64 \
      --output wide
    ```

### Create and deploy the complete CanIPull manifest

1. Copy the complete manifest into a file named `canipull.yaml`. Replace `<target-linux-node>` and `<acr-login-server>` with the node name and ACR login server from the previous section. The manifest pins CanIPull to the selected node, disables service account token mounting and privilege escalation, and mounts the required node configuration as read-only.

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: canipull
      namespace: default
      labels:
        app: canipull
    spec:
      automountServiceAccountToken: false
      nodeName: <target-linux-node>
      restartPolicy: Never
      containers:
        - name: canipull
          image: mcr.microsoft.com/aks/canipull:v0.1.0
          imagePullPolicy: IfNotPresent
          args:
            - <acr-login-server>
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
            readOnlyRootFilesystem: true
          volumeMounts:
            - name: azure-config
              mountPath: /etc/kubernetes/azure.json
              readOnly: true
      volumes:
        - name: azure-config
          hostPath:
            path: /etc/kubernetes/azure.json
            type: File
    ```
2. Create the pod.

    ```bash
    kubectl apply --filename canipull.yaml
    ```
3. Wait for the pod to finish.

    ```bash
    kubectl get pod canipull --watch
    ```

    Press Ctrl+C when the pod status changes to `Completed` or `Error`.

## Review the CanIPull results

View the diagnostic output.

```bash
kubectl logs canipull
```

A successful test includes the following results:

- The ACR authentication server resolves through DNS.
- CanIPull reads the Azure configuration from the node.
- The cluster's kubelet identity or service principal can authenticate.
- ACR accepts the initial token exchange.

These results confirm only that the selected node can resolve the ACR authentication server and that the cluster identity can complete the initial token exchange. CanIPull doesn't pull an image or validate access to a repository, image manifest, or image layer.

The tool's final success message uses broader wording than the scope of the test and resembles the following output:

```output
Your cluster can pull images from <acr-login-server>!
```

To verify an end-to-end image pull, deploy a workload that references an image in the target repository.

If the test fails, review the log line marked `FAILED`. Common causes include:

- The ACR authentication server doesn't resolve from the selected node.
- The selected node doesn't contain `/etc/kubernetes/azure.json`.
- The cluster identity credentials aren't valid.
- ACR rejects the token exchange for the kubelet identity or service principal.

If the token exchange fails because the identity isn't authorized to access ACR, see [Authenticate with ACR from AKS](cluster-container-registry-integration).

## Clean up resources

Delete the CanIPull pod and remove its access to the node configuration.

```bash
kubectl delete pod canipull
```