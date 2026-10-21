---
layout: Conceptual
title: Use Key Manager for Kubernetes clusters on AKS Edge Essentials (preview) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/edge-essentials/aks-edge-howto-key-manager
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
description: Learn how to use the Key Manager for Kubernetes extension to rotate service account keys in Azure Kubernetes Service (AKS) Edge Essentials clusters.
ms.topic: how-to
author: davidsmatlak
ms.author: davidsmatlak
ms.date: 2026-09-01T00:00:00.0000000Z
ms.reviewer: leslielin
ms.custom: edge-essentials
locale: en-us
document_id: 3083da9f-64d4-94a0-5741-02dbf92c6043
document_version_independent_id: 07bb5e81-458a-c394-3c59-d0040bfd11c0
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/edge-essentials/aks-edge-howto-key-manager.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/edge-essentials/aks-edge-howto-key-manager
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/edge-essentials/aks-edge-howto-key-manager.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/c21d0a62-47cf-4452-bd24-e1ed14abbeda
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f43eaf81-15c1-41e2-95b2-89fb1560c563
platformId: c6b4a668-aad6-f3be-832f-c3bf07ba07f7
---

# Use Key Manager for Kubernetes clusters on AKS Edge Essentials (preview) | Microsoft Learn

Important

Microsoft is retiring the Key Manager for Kubernetes extension (preview) on April 15, 2026. After this date, the extension will no longer be available for deployment, and no further updates or support will be provided. If you have additional questions, please contact us through the [AKS Hybrid and Edge GitHub repository](https://aka.ms/aksarc-github).

The [Kubernetes service account](https://kubernetes.io/docs/concepts/security/service-accounts/) is a a non-human account that provides a unique identity within a Kubernetes cluster. Service account tokens serve important security and authentication functions in Kubernetes.

In AKS Edge Essentials, *service account tokens* enable workload pods to authenticate and access Azure resources through [*workload identity federation*](aks-edge-workload-identity). Key Manager for Kubernetes is an Azure Arc extension that automates the rotation of the signing key used to issue these service account tokens. The rotation reduces the risk of token misuse and improves the overall security posture of the cluster.

The following table compares the default behavior with and without using the Key Manager for Kubernetes extension:

| Behavior | By default, without the Key Manager extension | With the Key Manager extension |
| --- | --- | --- |
| Automated service account key rotation | By default, Kubernetes doesn't automatically rotate service account signing keys. Instead, it uses the same key indefinitely to sign tokens. | Once enabled, the service account signing key is rotated automatically every 45 days. |
| Service account signing key validity | Unlimited | 45 days |

Important

These preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. Azure Kubernetes Service Edge Essentials previews are partially covered by customer support on a best-effort basis.

Note

During the preview, the Key Manager for Kubernetes is only available for AKS Edge Essentials K3s version 1.30.6 or later single control plane node deployments with Arc connectivity. It's not compatible with other Arc-enabled Kubernetes distributions.

## Before you begin

Before you begin, ensure you have the following prerequisites:

- An AKS Edge Essentials K3s cluster with Arc connectivity. If you plan to use Azure IoT Operations with AKS Edge Essentials, follow this [Quickstart guide](aks-edge-howto-deploy-azure-iot#create-an-arc-enabled-cluster) to create your cluster.
- To enable TLS for intracluster log communication, the `cert-manager` and `trust-manager` tools are required.

    - If you plan to [use Azure IoT Operations](/en-us/azure/iot-operations/get-started-end-to-end-sample/quickstart-deploy#deploy-azure-iot-operations), deploy it before installing the Key Manager for Kubernetes extension, since Azure IoT Operations installs its own copy of these applications by default.
    - To verify if `cert-manager` and `trust-manager` are installed, run the following command::

        ```bash
        kubectl get pods -n cert-manager
        ```

        If they are installed, you can see their pods in a running state.
    - If `cert-manager` and `trust-manager` are not present, follow the documentation to:

        1. Install [cert-manager](https://cert-manager.io/docs/installation/).
        2. Install [trust-manager](https://cert-manager.io/docs/trust/trust-manager/installation/). While installing trust manager, set the `trust namespace` to `cert-manager`. For example:

            ```bash
            helm upgrade trust-manager jetstack/trust-manager --install --namespace cert-manager --set app.trust.namespace=cert-manager --wait
            ```

            `trust-manager` is used to distribute a trust bundle to components.
- The Key Manager extension only works with [bounded service account tokens](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/#manual-secret-management-for-serviceaccounts). It doesn't support legacy tokens with infinite lifetimes. If your workflow relies on legacy tokens, do not install this extension.
- Bounded service account tokens have a default lifetime of one year. To rotate these tokens, this lifetime should be reduced to one day, which ensures that tokens are rapidly reissued and signed with newly rotated keys. To implement these changes, you must modify the `api-server` configuration by running the following commands:

    ```powershell
    $url = "https://raw.githubusercontent.com/Azure/AKS-Edge/refs/heads/main/tools/scripts/AksEdgeKeyManagerExtension/UpdateK3sConfigForKeyManager.ps1"
    Invoke-WebRequest -Uri $url -OutFile .\UpdateK3sConfigForKeyManager.ps1
    Unblock-File .\UpdateK3sConfigForKeyManager.ps1
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
    
    .\UpdateK3sConfigForKeyManager.ps1
    ```

## Install the Key Manager for Kubernetes extension for service account key rotation

Important

After you install the Key Manager extension, the `api-server` is updated with the new service account token during token rotation. This process briefly makes the API server inaccessible while it restarts.

Now run the following commands. Replace the variables with your specific resource group name and AKS cluster name:

# [Azure PowerShell](#tab/powershell)
```powershell
New-AzKubernetesExtension -SubscriptionId $yoursubscriptionID -ResourceGroupName $resource_group_name -ClusterName $aks_cluster_name -ClusterType connectedClusters -Name "MySAkeymanager" -ExtensionType microsoft.arc.kuberneteskeymanager
```

# [Azure CLI](#tab/azurecli)
```azurecli
az k8s-extension create -g $resource_group_name -c $aks_cluster_name -t connectedClusters -n "MySAkeymanager" --extension-type microsoft.arc.kuberneteskeymanager 
```

---

After you install the extension, you can view the **MySAkeymanager** extension in the Azure portal under the **Settings/Extensions** section of your Kubernetes cluster.

## Remove key manager for Kubernetes extension

You can uninstall the Key Manager extension using the [az k8s-extension delete](/en-us/cli/azure/k8s-extension#az-k8s-extension-delete) command:

# [Azure PowerShell](#tab/powershell)
```powershell
Remove-AzKubernetesExtension -ResourceGroupName $resource_group_name -ClusterName $aks_cluster_name -ClusterType connectedClusters -Name "MySAkeymanager"
```

# [Azure CLI](#tab/azurecli)
```azurecli
az k8s-extension delete -g $resource_group_name -c $aks_cluster_name -t connectedClusters -n "MySAkeymanager"
```

---

## Working with Azure IoT Operations

If you installed the Key Manager for Kubernetes extension before you deployed Azure IoT Operations, you must follow the [Bring your own issuer](/en-us/azure/iot-operations/secure-iot-ops/concept-default-root-ca#bring-your-own-issuer) instructions, as Azure IoT Operations installs `cert-manager` and `trust-manager` by default.