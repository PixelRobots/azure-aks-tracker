---
layout: Conceptual
title: Use Azure Policy to secure your Azure Kubernetes Service (AKS) clusters - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-azure-policy
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
zone_pivot_group_filename: zone-pivots/azure-aks/zone-pivot-groups.json
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn how to use Azure Policy to secure your Azure Kubernetes Service (AKS) clusters.
ms.topic: how-to
ms.subservice: aks-security
ms.date: 2026-06-30T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: template-how-to
zone_pivot_groups: portal-terraform
locale: en-us
document_id: 096bb1d7-c5c3-785e-e8f3-022c56863d31
document_version_independent_id: 55cd53e9-63ee-2069-7ad4-a29fa97a6fb1
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-azure-policy.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/use-azure-policy
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-azure-policy.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/eea02214-631d-404a-92d1-5a3357c32a26
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/f42c31d7-eed9-43b7-9757-54caffb53cdc
platformId: e237ba01-ecf9-e979-0814-352330960c8c
---

# Use Azure Policy to secure your Azure Kubernetes Service (AKS) clusters - Azure Kubernetes Service | Microsoft Learn

You can apply and enforce built-in security policies on your Azure Kubernetes Service (AKS) clusters by using [Azure Policy](/en-us/azure/governance/policy/overview). Azure Policy helps you enforce organizational standards and assess compliance at scale. After you install the [Azure Policy add-on for AKS](/en-us/azure/governance/policy/concepts/policy-for-kubernetes), you can apply individual policy definitions or groups of policy definitions called initiatives (sometimes called policysets) to your cluster. For a complete list of AKS policy and initiative definitions, see [Azure Policy built-in definitions for AKS](policy-reference).

This article shows you how to apply policy definitions to your cluster and verify that the assignments are enforced.

## Prerequisites

::: zone pivot="azure-portal"

- This article assumes you have an existing AKS cluster. If you need an AKS cluster, you can create one using [Azure CLI](learn/quick-kubernetes-deploy-cli), [Azure PowerShell](learn/quick-kubernetes-deploy-powershell), or [Azure portal](learn/quick-kubernetes-deploy-portal).
- You need the [Azure Policy add-on for AKS installed on your AKS cluster](/en-us/azure/governance/policy/concepts/policy-for-kubernetes#install-azure-policy-add-on-for-aks).

::: zone-end

::: zone pivot="terraform"

You need the following resources installed and configured before you begin:

- This article assumes you have an existing AKS cluster. If you need an AKS cluster, you can create one using [Azure CLI](learn/quick-kubernetes-deploy-cli), [Azure PowerShell](learn/quick-kubernetes-deploy-powershell), or [Azure portal](learn/quick-kubernetes-deploy-portal).
- You need the [Azure Policy add-on for AKS installed on your AKS cluster](/en-us/azure/governance/policy/concepts/policy-for-kubernetes#install-azure-policy-add-on-for-aks).
- Terraform version 1.6.0 or later.
- Azure CLI version 2.47.0 or later. To install or update the Azure CLI, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- Kubectl installed and configured.

::: zone-end

## Assign a built-in policy definition or initiative

::: zone pivot="azure-portal"

You can apply a policy definition or initiative in the Azure portal by using the following steps:

1. Go to the Azure Policy service in the Azure portal called **Policy**.
2. In the left pane of the Azure Policy page, select **Definitions**.
3. Under **Categories**, select `Kubernetes`.
4. Choose the policy definition or initiative you want to apply. For this example, select the **Kubernetes cluster pod security baseline standards for Linux-based workloads** initiative.
5. Select **Assign**.
6. Set the **Scope** to the resource group of the AKS cluster with the Azure Policy add-on enabled.
7. Select the **Parameters** page and update the **Effect** from `audit` to `deny` to block new deployments that violate the baseline initiative. You can also add extra namespaces to exclude from evaluation. For this example, keep the default values.
8. Select **Review + create** &gt; **Create** to submit the policy assignment.

::: zone-end

::: zone pivot="terraform"

Create a directory for the Terraform configuration.

```bash
mkdir aks-use-azure-policy
cd aks-use-azure-policy
```

### Create the Terraform configuration

Create a *main.tf* file and copy the following tested sample configuration into it. The sample is maintained in the [Azure Terraform GitHub repository](https://github.com/Azure/terraform/tree/master/quickstart/101-aks-use-azure-policy). The configuration:

- Configures the Azure provider for Terraform (`azurerm`).
- Defines input variables for the existing resource group and AKS cluster.
- Retrieves the existing resource group and built-in pod security baseline initiative.
- Assigns the initiative to the resource group with the policy effect set to `Deny`.

```terraform
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
provider "azurerm" {
  features {}
}
variable "resource_group_name" {
  description = "Name of the resource group that contains the existing AKS cluster."
  type = string
}
variable "aks_cluster_name" {
  description = "Name of the existing AKS cluster."
  type = string
}
data "azurerm_resource_group" "aks" {
  name = var.resource_group_name
}
data "azurerm_policy_set_definition" "aks_pod_security_baseline" {
  display_name = "Kubernetes cluster pod security baseline standards for Linux-based workloads"
}
resource "azurerm_resource_group_policy_assignment" "aks_pod_security_baseline" {
  name = "aks-pod-security-baseline"
  display_name = "Kubernetes cluster pod security baseline standards for Linux-based workloads"
  resource_group_id = data.azurerm_resource_group.aks.id
  policy_definition_id = data.azurerm_policy_set_definition.aks_pod_security_baseline.id
  parameters = jsonencode({
    effect = {
      value = "Deny"
    }
  })
}
output "aks_cluster_name" {
  description = "Name of the AKS cluster targeted by this policy assignment."
  value = var.aks_cluster_name
}
```

::: zone-end

::: zone pivot="azure-portal,terraform"

### Optional: Create and assign a custom policy definition

The custom policy definition section is informational and is outside the scope of this article. Custom policies allow you to define rules for using Azure. For example, you can enforce the following types of rules:

- Security practices.
- Cost management.
- Organization-specific rules, like naming conventions or locations.

Before creating a custom policy, check the [list of common patterns and samples](/en-us/azure/governance/policy/samples/) to see if your case is already covered.

Custom policy definitions are written in JSON. To learn more about creating a custom policy, see [Azure Policy definition structure](/en-us/azure/governance/policy/concepts/definition-structure) and [Create a custom policy definition](/en-us/azure/governance/policy/tutorials/create-custom-policy-definition).

Note

Azure Policy uses a property named *templateInfo* that you can use to define the source type for the constraint template. When you define *templateInfo* in policy definitions, you can't use *constraintTemplate* or *constraint* properties. You still need to define *apiGroups* and *kinds*. For more information, see [Understanding Azure Policy effects](/en-us/azure/governance/policy/concepts/effect-audit#audit-properties).

After you create your custom policy definition, see [Assign a policy definition](/en-us/azure/governance/policy/concepts/policy-for-kubernetes#assign-a-policy-definition) for a step-by-step walkthrough to assign the policy to your cluster.

::: zone-end

## Validate an Azure Policy is running

::: zone pivot="azure-portal"

Confirm the policy assignments are applied to your cluster by using the following `kubectl get` command.

```azurecli
kubectl get constrainttemplates
```

Note

Policy assignments can take [up to 20 minutes to sync](/en-us/azure/governance/policy/concepts/policy-for-kubernetes#assign-a-policy-definition) into each cluster.

Your output should be similar to the following example output:

```output
NAME                                     AGE
k8sazureallowedcapabilities              23m
k8sazureallowedusersgroups               23m
k8sazureblockhostnamespace               23m
k8sazurecontainerallowedimages           23m
k8sazurecontainerallowedports            23m
k8sazurecontainerlimits                  23m
k8sazurecontainernoprivilege             23m
k8sazurecontainernoprivilegeescalation   23m
k8sazureenforceapparmor                  23m
k8sazurehostfilesystem                   23m
k8sazurehostnetworkingports              23m
k8sazurereadonlyrootfilesystem           23m
k8sazureserviceallowedports              23m
```

### Validate rejection of a privileged pod

Test what happens when you schedule a pod with the security context of `privileged: true`. This security context escalates the pod's privileges. The initiative disallows privileged pods, so the request is denied, which results in the deployment being rejected.

1. Create a file named `nginx-privileged.yaml` and paste in the following YAML manifest.

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx-privileged
    spec:
      containers:
        - name: nginx-privileged
          image: mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine
          securityContext:
            privileged: true
    ```
2. Create the pod by using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command and specify the name of your YAML manifest.

    ```azurecli
    kubectl apply -f nginx-privileged.yaml
    ```

    As expected, the pod fails to be scheduled, as shown in the following example output:

    ```output
    Error from server ([denied by azurepolicy-container-no-privilege-00edd87bf80f443fa51d10910255adbc4013d590bec3d290b4f48725d4dfbdf9] Privileged container is not allowed: nginx-privileged, securityContext: {"privileged": true}): error when creating "privileged.yaml": admission webhook "validation.gatekeeper.sh" denied the request: [denied by azurepolicy-container-no-privilege-00edd87bf80f443fa51d10910255adbc4013d590bec3d290b4f48725d4dfbdf9] Privileged container is not allowed: nginx-privileged, securityContext: {"privileged": true}
    ```

    The pod doesn't reach the scheduling stage, so there are no resources to delete before you move on.

### Test creation of an unprivileged pod

In the previous example, the container image automatically tried to use root to bind `NGINX` to port 80. The policy initiative denies this request, so the pod fails to start. Now, try running that same `NGINX` pod without privileged access.

1. Create a file named `nginx-unprivileged.yaml` and paste the following YAML manifest into it.

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx-unprivileged
    spec:
      containers:
        - name: nginx-unprivileged
          image: mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine
    ```
2. Create the pod by using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command and specify the name of your YAML manifest.

    ```azurecli
    kubectl apply -f nginx-unprivileged.yaml
    ```
3. Check the status of the pod by using the [`kubectl get pods`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command.

    ```azurecli
    kubectl get pods
    ```

    Your output should be similar to the following example output, which shows the pod is successfully scheduled and has a status of *Running*:

    ```output
    NAME                 READY   STATUS    RESTARTS   AGE
    nginx-unprivileged   1/1     Running   0          18s
    ```

    This example shows the baseline initiative affecting only the deployments that violate policies in the collection. Allowed deployments continue to function.
4. Delete the `NGINX` unprivileged pod by using the [`kubectl delete`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#delete) command and specify the name of your YAML manifest.

    ```azurecli
    kubectl delete -f nginx-unprivileged.yaml
    ```

::: zone-end

::: zone pivot="terraform"

Use the following steps to assign a built-in Azure Policy initiative to your AKS cluster by using Terraform.

The Terraform configuration shown earlier retrieves the built-in initiative and assigns it to the resource group that contains the AKS cluster.

### Initialize the Terraform configuration

Run `terraform init` to initialize the Terraform working directory and download the required provider plugins.

```bash
terraform init
```

### Format and validate the configuration

Run `terraform fmt` to format the Terraform configuration.

```bash
terraform fmt
```

Run `terraform validate` to validate the Terraform configuration syntax.

```bash
terraform validate
```

### Apply the Terraform configuration

Before deploying the configuration, provide values for the following variables:

- `resource_group_name`
- `aks_cluster_name`

Run `terraform apply` to deploy the Azure Policy assignment.

```bash
terraform apply
```

When prompted, enter `yes` to confirm the deployment.

### Verify the Azure Policy installation

After deployment completes, verify that the Azure Policy components are running in the AKS cluster.

```bash
kubectl get pods -n kube-system
```

Verify that the Gatekeeper constraint templates were installed successfully.

```bash
kubectl get constrainttemplates
```

### Test the Azure Policy assignment

Create a file named `privileged-pod.yaml`.

```yaml
apiVersion: v1
kind: Pod
metadata:
 name: privileged-pod
spec:
 containers:
 - name: nginx
   image: nginx
   securityContext:
     privileged: true
```

Apply the manifest to the cluster.

```bash
kubectl apply -f privileged-pod.yaml
```

The deployment fails because the Azure Policy assignment denies privileged containers that violate the configured pod security baseline standards.

::: zone-end

::: zone pivot="azure-portal"

## Disable a policy or initiative

Remove the baseline initiative in the Azure portal by using the following steps:

1. Go to the **Policy** pane in the Azure portal.
2. Select **Assignments**.
3. Select the ellipsis (`...`) at the end of the line for **Kubernetes cluster pod security baseline standards for Linux-based workload** initiative.
4. Select **Delete assignment**.

To remove the Azure Policy add-on from your AKS cluster, see [Remove the add-on](/en-us/azure/governance/policy/concepts/policy-for-kubernetes#remove-the-add-on-from-aks).

::: zone-end

::: zone pivot="terraform"

## Disable a policy or initiative

Run `terraform destroy` from the directory that contains the Terraform configuration to remove the policy assignment created by the sample.

```bash
terraform destroy
```

To remove the Azure Policy add-on from your AKS cluster, see [Remove the add-on](/en-us/azure/governance/policy/concepts/policy-for-kubernetes#remove-the-add-on-from-aks).

::: zone-end