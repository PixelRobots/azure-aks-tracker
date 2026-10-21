---
layout: Conceptual
title: Resolve az aks command invoke failures - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/resolve-az-aks-command-invoke-failures
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: kaushika-msft
ms.author: kaushika
ms.topic: troubleshooting
description: Resolve az aks command invoke failures in Azure CLI for private AKS clusters. Learn fixes and apply steps now to restore secure access quickly.
ms.date: 2025-05-13T00:00:00.0000000Z
ms.reviewer: chiragpa, andbar, haitch, momajed, albarqaw, v-leedennis, v-weizhu
ms.service: azure-kubernetes-service
ms.custom: sap:Connectivity, devx-track-azurecli
locale: en-us
document_id: 2fc89cd7-3238-5260-d479-41c683255825
document_version_independent_id: 2fc89cd7-3238-5260-d479-41c683255825
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/connectivity/resolve-az-aks-command-invoke-failures.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/connectivity/resolve-az-aks-command-invoke-failures
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/connectivity/resolve-az-aks-command-invoke-failures.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 621cc427-572e-cd7a-809e-f01d68309167
---

# Resolve az aks command invoke failures - Azure | Microsoft Learn

## Summary

This article explains how to resolve [az aks command invoke](/en-us/cli/azure/aks/command#az-aks-command-invoke) failures in Azure CLI so you can restore access to your AKS cluster, especially a [private AKS cluster](/en-us/azure/aks/command-invoke).

Other connection methods need to use extra configuration components, as shown in the following table.

| Connection methods | Extra configuration component |
| --- | --- |
| Virtual network | Virtual private network (VPN) |
| Peered network | [Azure ExpressRoute](/en-us/azure/expressroute/expressroute-introduction) |
| Private endpoint | [Jumpbox](/en-us/azure/cloud-adoption-framework/scenarios/cloud-scale-analytics/architectures/connect-to-environments-privately) |

The `az aks command invoke` Azure CLI command is an alternative way of connecting to a cluster that doesn't require extra configuration components.

When you run the `az aks command invoke` command, Azure CLI automatically creates a `command-<ID>` pod in the `aks-command` namespace to access the AKS cluster and retrieve the required information.

## Prerequisites

- [Azure CLI](/en-us/cli/azure/install-azure-cli).
- The Kubernetes [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) tool. To install kubectl by using Azure CLI, run the [az aks install-cli](/en-us/cli/azure/aks#az-aks-install-cli) command.

## Symptoms

The following table lists common `az aks command invoke` error messages. Each error message has a link to the section that describes why the error is occurring, and how to fix it.

| Error message | Link |
| --- | --- |
| Operation returned an invalid status 'Not Found' | Cause 1: The pod can't be created because of node or resource constraints |
| Failed to run command in managed cluster due to kubernetes failure. details: admission webhook "validation.gatekeeper.sh" denied the request: &lt;policy-specific-message&gt; | Cause 2: Azure Policy doesn't allow the pod creation |
| Error from server (Forbidden): namespaces is forbidden: User "&lt;ID&gt;" cannot list resource "&lt;resource&gt;" in API group "" at the cluster scope | Cause 3: Required roles aren't granted |
| Failed to connect to MSI. Please make sure MSI is configured correctly.Get Token request returned: Response [400]; | Cause 4: There's a Cloud Shell issue |

## Cause 1: The pod can't be created because of node or resource constraints

The operation returns a `Not Found` status because the `command-<ID>` pod can't reach a successful state, such as `Running`. (In many cases, the pod stays in the `Pending` state.) In this case, the nodes aren't able to schedule the pod. This scenario can have different causes, such as the following causes:

- Resource constraints
- Nodes that have a `NotReady` or `SchedulingDisabled` state
- Nodes that have taints that the pod can't tolerate
- Other causes

Here are sample error messages for `KubernetesPerformanceError` or `KubernetesOperationError`:

```output
(KubernetesPerformanceError) Failed to run command due to cluster perf issue, container command-357ebsdfsd342869 in aks-command namespace did not start within 30s on your cluster, retry may helps. If issue persist, you may need to tune your cluster with better performance (larger node/paid tier).
Code: KubernetesPerformanceError
Message: Failed to run command due to cluster perf issue, container command-357ebc50d40c47a4a247ab6e067d2869 in aks-command namespace did not start within 30s on your cluster, retry may helps. If issue persist, you may need to tune your cluster with better performance (larger node/paid tier).
```

#### Solution 1: Change the configuration so that you can schedule and run the pod

Make sure that the `command-<ID>` pod can be scheduled and run by adjusting the configuration. For example:

- Increase the node pool size and make sure it has no pod secluding constraints like taints so that the `command-<ID>` pod can be deployed.
- Adjust resource requests and limits in your pod specifications.

## Cause 2: Azure Policy doesn't allow the pod creation

If you have specific Azure policies, the `az aks command invoke` command can fail because of a disallowed configuration in the `command-<ID>` pod. For example, you might have an Azure policy that requires a read-only root file system or other specific configuration.

#### Solution 2: Exempt the namespace for policies that prohibit pod creation

We recommend that you exempt the `aks-command` namespace for the associated Azure policies that don't allow the pod creation. For more information about exemption, see [Understand scope in Azure Policy](/en-us/azure/governance/policy/concepts/scope#:%7E:text=Exemption%20%2D%20A%20resource,Exemption%20definition.)

To exempt an Azure Policy:

1. In the [Azure portal](https://portal.azure.com), search for and select **Policy**.
2. In the **Policy** navigation pane, locate the **Authoring** section, and then select **Assignments**.
3. In the table of assignments, find the row that contains the **Assignment name** that you want to change, and then select the name of the assignment.
4. In the policy assignment page for that assignment, select **Edit assignment**.
5. Select the **Parameters** tab.
6. Clear the **Only show parameters that need input or review** option.
7. In the **Namespace exclusions** box, add the *aks-command* namespace to the list of namespaces to be excluded.

Alternatively, if the policy isn't a built-in policy, you can check the configuration of the `command-<ID>` pod, and adjust the policy as necessary. To explore the pod's YAML configuration, run the following command:

```bash
kubectl get pods command-<ID> --namespace aks-command --output yaml
```

You can exempt the `aks-command` namespace from restrictive policies by running the following command:

```bash
az policy exemption create --name ExemptAksCommand --scope /subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.ContainerService/managedClusters/{aks-cluster} --policyAssignment /subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyAssignments/{policy-assignment-id}
```

## Cause 3: Required roles aren't granted

To use the `az aks command invoke` command, you must have access to the following roles on the cluster:

- `Microsoft.ContainerService/managedClusters/runCommand/action`
- `Microsoft.ContainerService/managedClusters/commandResults/read`

If you don't have these roles, the `az aks command invoke` command can't retrieve the required information.

#### Solution 3: Add the required roles

To resolve this issue, follow these steps:

1. Add the `Microsoft.ContainerService/managedClusters/runCommand/action` and `Microsoft.ContainerService/managedClusters/commandResults/read` roles.
2. Assign the necessary roles to the user:

    ```bash
    az role assignment create --assignee {user-principal-name} --role "Azure Kubernetes Service Cluster User Role" --scope /subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.ContainerService/managedClusters/{aks-cluster}
    ```

## Cause 4: There's a Cloud Shell issue

The `az aks command invoke` command isn't processed as expected when it's run directly in the [Azure Cloud Shell](/en-us/azure/cloud-shell/overview) environment. This is a known issue in Cloud Shell.

#### Solution 4a: Run the az login command first

In Cloud Shell, run the [az login](/en-us/cli/azure/reference-index#az-login) command before you run the `az aks command invoke` command. For example:

```bash
az login
az aks command invoke --resource-group {resource-group} --name {aks-cluster} --command "kubectl get pods"
```

#### Solution 4b: Run the command on a local computer or a virtual machine

Run the `az aks command invoke` command on a local computer or any virtual machine (VM) that has Azure CLI installed.

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.