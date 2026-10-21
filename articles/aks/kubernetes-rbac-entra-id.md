---
layout: Conceptual
title: Use Microsoft Entra ID and Kubernetes RBAC for clusters - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/kubernetes-rbac-entra-id
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
description: Learn how to use Microsoft Entra group membership to restrict access to cluster resources using Kubernetes role-based access control (Kubernetes RBAC) in Azure Kubernetes Service (AKS).
ms.topic: how-to
ms.author: shasb
author: shashankbarsin
ms.subservice: aks-integration
ms.custom: devx-track-azurecli, devx-track-terraform, annual
ms.date: 2026-08-31T00:00:00.0000000Z
zone_pivot_groups: azure-cli-or-terraform
locale: en-us
document_id: 5a827157-01c8-08f7-b4bd-8facf1d0dc31
document_version_independent_id: abd764b3-7457-c7e9-3b92-0a7e69021ba3
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/kubernetes-rbac-entra-id.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/kubernetes-rbac-entra-id
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/kubernetes-rbac-entra-id.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/57eae307-c3a1-4cac-b645-1a899934bac8
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/1433a524-c01f-4b87-beab-670c040dea4f
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/ee561821-1ac7-45a8-9409-6ba5eb7a5b97
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/312f1f05-a431-4193-8a4d-e6245d5966de
platformId: 5b41d30b-e5a8-7b9e-eba0-943607267426
---

# Use Microsoft Entra ID and Kubernetes RBAC for clusters - Azure Kubernetes Service | Microsoft Learn

Azure Kubernetes Service (AKS) can be configured to use Microsoft Entra ID for user authentication. In this configuration, you sign in to an AKS cluster using a Microsoft Entra authentication token. Once authenticated, you can use the built-in Kubernetes role-based access control (RBAC) to manage access to namespaces and cluster resources based on a user's identity or group membership.

This article shows you how to:

- Control access using Kubernetes RBAC in an AKS cluster based on Microsoft Entra group membership.
- Create example groups and users in Microsoft Entra ID.
- Create Roles and RoleBindings in an AKS cluster granting the appropriate permissions, such as to create and view resources.

## Prerequisites

- You have an existing AKS cluster with Microsoft Entra integration enabled. If you need an AKS cluster with this configuration, see [Integrate Microsoft Entra ID with AKS](managed-azure-ad).
- Kubernetes RBAC is enabled by default during AKS cluster creation. To upgrade an existing cluster with Microsoft Entra integration and Kubernetes RBAC, see [Enable Microsoft Entra integration on your existing AKS cluster](managed-azure-ad#use-an-existing-cluster).
- Make sure that Azure CLI version 2.0.61 or later is installed and configured. To find the version, run `az --version`. To install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

Use the Azure portal or Azure CLI to verify Microsoft Entra integration with Kubernetes RBAC is enabled.

# [Azure portal](#tab/portal)
To verify using the Azure portal:

1. Sign-in to the [Azure portal](https://portal.azure.com) and navigate to your AKS cluster resource.
2. In the service menu, under **Settings**, select **Security configuration**.
3. Under the **Authentication and Authorization** section, verify the **Microsoft Entra authentication with Kubernetes RBAC** option is selected.

# [Azure CLI](#tab/azure-cli)
You can verify using the Azure CLI `az aks show` command. Replace the value *myResourceGroup* with the resource group name hosting your AKS cluster resource, and replace *myAKSCluster* with the actual name of your AKS cluster.

```azurecli
az aks show --resource-group myResourceGroup --name myAKSCluster
```

If you're using Microsoft Entra authentication with Kubernetes RBAC (and not Azure RBAC), the output value for `enableAzureRbac` is `false`.

---

::: zone pivot="terraform"

If you plan to use Terraform to configure Kubernetes RBAC for this article, you also need:

- [Terraform](/en-us/azure/developer/terraform/overview) version 1.6.0 or later installed.
- [kubectl](https://kubernetes.io/docs/reference/kubectl/) installed and configured to connect to your AKS cluster. `kubectl` is automatically installed when you run `az aks install-cli` or as part of the [Azure Cloud Shell](https://shell.azure.com).
- Permission to create Azure role assignments at the scope of your AKS cluster, and permission to manage Kubernetes resources on the cluster.
- Two existing Microsoft Entra groups and, optionally, two existing Microsoft Entra test users to validate access with. If you don't have these resources yet, complete Create groups in Microsoft Entra ID and Create users in Microsoft Entra ID before continuing. However, skip the `az role assignment create` command in that section, since the Terraform configuration in this article creates the role assignments for you.

Note

If you don't already have an AKS cluster with Microsoft Entra integration and Kubernetes RBAC enabled to test with, this article's Terraform sample includes a `prequisite` configuration that creates one for you. For more information, see Deploy the prerequisite AKS cluster with Terraform.

::: zone-end

## Create groups in Microsoft Entra ID

This section teaches you how to create two user roles to show how Kubernetes RBAC and Microsoft Entra ID control access cluster resources. The following two example roles are:

- **Application developer**

    - A user named *aksdev* that's part of the *appdev* group.
- **Site reliability engineer** (SRE)

    - A user named *akssre* that's part of the *opssre* group.

In production environments, you can use existing users and groups within a Microsoft Entra tenant.

# [App Dev](#tab/appdev)
1. First, get the resource ID of your AKS cluster using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command. Then, assign the resource ID to a variable named *AKS\_ID* so it can be referenced in other commands.

    ```azurecli
    AKS_ID=$(az aks show \
        --resource-group myResourceGroup \
        --name myAKSCluster \
        --query id -o tsv)
    ```
2. Create the first example group in Microsoft Entra ID for the application developers using the [`az ad group create`](/en-us/cli/azure/ad/group#az-ad-group-create) command. The following example creates a group named *appdev*:

    ```azurecli
    APPDEV_ID=$(az ad group create --display-name appdev --mail-nickname appdev --query id -o tsv)
    ```
3. Create an Azure role assignment for the *appdev* group using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command. This assignment lets any member of the group use `kubectl` to interact with an AKS cluster by granting them the *Azure Kubernetes Service Cluster User* Role.

::: zone pivot="azure-cli"

    ```azurecli
    az role assignment create \
      --assignee $APPDEV_ID \
      --role "Azure Kubernetes Service Cluster User Role" \
      --scope $AKS_ID
    ```

Important

The role name you specify must exactly match the Azure role definition name, including capitalization and spacing.

Tip

If you receive an error such as `Principal 35bfec9328bd4d8d9b54dea6dac57b82 doesn't exist in the directory a5443dcd-cd0e-494d-a387-3039b419f0d5.`, wait a few seconds for the Microsoft Entra group object ID to propagate through the directory then try the `az role assignment create` command again.

::: zone-end

::: zone pivot="terraform"

Skip this command. The Terraform configuration in Deploy Kubernetes RBAC with Terraform creates this role assignment for you.

::: zone-end

# [SRE](#tab/sre)
1. Create an example group for SREs named *opssre*.

    ```azurecli
    OPSSRE_ID=$(az ad group create --display-name opssre --mail-nickname opssre --query id -o tsv)
    ```
2. Create an Azure role assignment to grant members of the group the **Azure Kubernetes Service Cluster User** Role.

::: zone pivot="azure-cli"

    ```azurecli
    az role assignment create \
      --assignee $OPSSRE_ID \
      --role "Azure Kubernetes Service Cluster User Role" \
      --scope $AKS_ID
    ```

::: zone-end

::: zone pivot="terraform"

Skip this command. The Terraform configuration in Deploy Kubernetes RBAC with Terraform creates this role assignment for you.

::: zone-end

---

## Create users in Microsoft Entra ID

After you create the example Microsoft Entra ID groups for application developers and SREs, the next step is to create two corresponding user accounts. These users are used to sign in to the AKS cluster and validate the Kubernetes RBAC integration described later in this article.

Before you begin, you must set the user principal name (UPN) and password for the application developers. The UPN must include the verified domain name of your tenant. For example, an application developer user, `aksdev@contoso.com`. In order to figure out (or set) the verified domain names in your tenant, see [Managing custom domain names in your Microsoft Entra ID](/en-us/entra/identity/users/domains-manage).

The following command prompts you for the UPN and sets it to *AAD\_DEV\_UPN* so it can be used in a later command:

```azurecli
echo "Please enter the UPN for application developers: " && read AAD_DEV_UPN
```

The following command prompts you for the password and sets it to *AAD\_DEV\_PW* for use in a later command:

```azurecli
echo "Please enter the secure password for application developers: " && read AAD_DEV_PW
```

### Create user accounts

# [App Dev](#tab/appdev)
1. Create the first user account in Microsoft Entra ID using the [`az ad user create`](/en-us/cli/azure/ad/user#az-ad-user-create) command. The following example creates a user with the display name *AKS Dev*, the UPN, and secure password using the values in *AAD\_DEV\_UPN* and *AAD\_DEV\_PW*:

    ```azurecli
    AKSDEV_ID=$(az ad user create \
      --display-name "AKS Dev" \
      --user-principal-name $AAD_DEV_UPN \
      --password $AAD_DEV_PW \
      --query id -o tsv)
    ```
2. Add the user to the *appdev* group created in the previous section using the [`az ad group member add`](/en-us/cli/azure/ad/group/member#az-ad-group-member-add) command:

    ```azurecli
    az ad group member add --group appdev --member-id $AKSDEV_ID
    ```

# [SRE](#tab/sre)
1. Set the UPN and password for SREs. The UPN must include the verified domain name of your tenant. For example, an SRE user, `akssre@contoso.com`. The following command prompts you for the UPN and sets it to *AAD\_SRE\_UPN* for use in a later command:

    ```azurecli
    echo "Please enter the UPN for SREs: " && read AAD_SRE_UPN
    ```
2. The following command prompts you for the password and sets it to *AAD\_SRE\_PW* for use in a later command:

    ```azurecli
    echo "Please enter the secure password for SREs: " && read AAD_SRE_PW
    ```
3. Create a second user account. The following example creates a user with the display name *AKS SRE* and the UPN and secure password using the values in *AAD\_SRE\_UPN* and *AAD\_SRE\_PW*:

    ```azurecli
    # Create a user for the SRE role
    AKSSRE_ID=$(az ad user create \
      --display-name "AKS SRE" \
      --user-principal-name $AAD_SRE_UPN \
      --password $AAD_SRE_PW \
      --query id -o tsv)
    
    # Add the user to the opssre Entra ID group
    az ad group member add --group opssre --member-id $AKSSRE_ID
    ```

---

## Create AKS cluster resources

We have our Microsoft Entra groups, users, and Azure role assignments created. Now, you configure the AKS cluster to allow these different groups access to specific resources.

::: zone pivot="azure-cli"

# [App Dev](#tab/appdev)
1. Get the cluster admin credentials using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command. In one of the following sections, you get the regular *user* cluster credentials to see the Microsoft Entra authentication flow in action.

    ```azurecli
    az aks get-credentials --resource-group myResourceGroup --name myAKSCluster --admin
    ```
2. Create a namespace in the AKS cluster using the [`kubectl create namespace`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#create) command. The following example creates a namespace name *dev*:

    ```console
    kubectl create namespace dev
    ```

    Note

    In Kubernetes, *Roles* define the permissions to grant, and *RoleBindings* apply them to desired users or groups. These assignments can be applied to a given namespace, or across the entire cluster. For more information, see [Using Kubernetes RBAC authorization](concepts-identity#kubernetes-rbac).

    If the user you grant the Kubernetes RBAC binding for is in the same Microsoft Entra tenant, assign permissions based on the **UPN**. If the user is in a different Microsoft Entra tenant, query for and use the *objectId* property instead.
3. Create a Role for the *dev* namespace, which grants full permissions to the namespace. In production environments, you can specify more granular permissions for different users or groups. Create a file named `role-dev-namespace.yaml` and paste the following YAML manifest:

    ```yaml
    kind: Role
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: dev-user-full-access
      namespace: dev
    rules:
    - apiGroups: ["", "extensions", "apps"]
      resources: ["*"]
      verbs: ["*"]
    - apiGroups: ["batch"]
      resources:
      - jobs
      - cronjobs
      verbs: ["*"]
    ```
4. Create the Role using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command and specify the filename of your YAML manifest.

    ```console
    kubectl apply -f role-dev-namespace.yaml
    ```
5. Get the resource ID for the *appdev* group using the [`az ad group show`](/en-us/cli/azure/ad/group#az-ad-group-show) command. This group is set as the subject of a RoleBinding in the next step.

    ```azurecli
    az ad group show --group appdev --query id -o tsv
    ```
6. Create a RoleBinding for the *appdev* group to use the previously created Role for namespace access. Create a file named `rolebinding-dev-namespace.yaml` and paste the following YAML manifest. On the last line, replace *groupObjectId* with the group object ID output from the previous command.

    ```yaml
    kind: RoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: dev-user-access
      namespace: dev
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: dev-user-full-access
    subjects:
    - kind: Group
      # Replace the placeholder below with the group's objectId (GUID)
      name: groupObjectId
    ```

    Tip

    If you want to create the RoleBinding for a single user, specify *kind: User* and replace *groupObjectId* with the UPN in the previous sample.
7. Create the RoleBinding using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command and specify the filename of your YAML manifest:

    ```console
    kubectl apply -f rolebinding-dev-namespace.yaml
    ```

# [SRE](#tab/sre)
1. Create a namespace for the *SRE* using the [`kubectl create namespace`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#create) command:

    ```console
    kubectl create namespace sre
    ```
2. Create a file named `role-sre-namespace.yaml` and paste the following YAML manifest:

    ```yaml
    kind: Role
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: sre-user-full-access
      namespace: sre
    rules:
    - apiGroups: ["", "extensions", "apps"]
      resources: ["*"]
      verbs: ["*"]
    - apiGroups: ["batch"]
      resources:
      - jobs
      - cronjobs
      verbs: ["*"]
    ```
3. Create the Role using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command and specify the filename of your YAML manifest:

    ```console
    kubectl apply -f role-sre-namespace.yaml
    ```
4. Get the resource ID for the *opssre* group using the [az ad group show](/en-us/cli/azure/ad/group#az-ad-group-show) command:

    ```azurecli
    az ad group show --group opssre --query id -o tsv
    ```
5. Create a RoleBinding for the *opssre* group to use the previously created Role for namespace access. Create a file named `rolebinding-sre-namespace.yaml` and paste the following YAML manifest. On the last line, replace *groupObjectId* with the group object ID output from the previous command:

    ```yaml
    kind: RoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: sre-user-access
      namespace: sre
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: sre-user-full-access
    subjects:
    - kind: Group
      # Replace the placeholder below with the group's objectId (GUID)
      name: groupObjectId
    ```
6. Create the RoleBinding using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command and specify the filename of your YAML manifest:

    ```console
    kubectl apply -f rolebinding-sre-namespace.yaml
    ```

---

::: zone-end

::: zone pivot="terraform"

### Review the Terraform code

Note

The sample code for this article is located in the [Azure Terraform GitHub repo](https://github.com/Azure/terraform/tree/master/quickstart/101-aks-entra-k8s-rbac). You can view the log file containing the [test results from current and previous versions of Terraform](https://github.com/Azure/terraform/tree/master/quickstart/101-aks-entra-k8s-rbac/TestRecord.md).

See more [articles and sample code showing how to use Terraform to manage Azure resources](/en-us/azure/developer/terraform/).

The sample uses two Terraform configurations, each in its own directory with its own state:

- The `prequisite` configuration creates a resource group and an AKS cluster with Microsoft Entra integration and Kubernetes RBAC enabled, which the repository's own end-to-end tests use to validate the scenario configuration against a real cluster. If you already have an AKS cluster that meets this article's prerequisites, skip this configuration and use your own resource group name, cluster name, and Microsoft Entra group object IDs with the scenario configuration instead.
- The scenario configuration, in the root of the sample, assigns the *Azure Kubernetes Service Cluster User Role* to the *appdev* and *opssre* groups at the cluster scope. It also creates the *dev* and *sre* Kubernetes namespaces with namespace-scoped Roles and RoleBindings that grant each group access only to its own namespace.

Terraform authenticates by using your Azure CLI sign-in context. Before you continue, ensure you're signed in by using `az login` and have selected the correct subscription by using `az account set --subscription <subscription-id>`.

### Deploy the prerequisite AKS cluster with Terraform

Note

This stage is optional. Complete it only if you don't already have an AKS cluster with Microsoft Entra integration and Kubernetes RBAC enabled, and Azure RBAC for Kubernetes Authorization disabled, to test with.

1. Create a directory named `prequisite` and make it your current directory.
2. Create a file named `versions.tf` and insert the following code:

    ```terraform
    terraform {
      required_version = ">= 1.6.0"
    
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~> 4.0"
        }
        random = {
          source  = "hashicorp/random"
          version = "~> 3.6"
        }
      }
    }
    
    provider "azurerm" {
      features {
        resource_group {
          prevent_deletion_if_contains_resources = false
        }
      }
    }
    ```
3. Create a file named `variables.tf` and add the following code:

    ```terraform
    variable "location" {
      type        = string
      default     = "eastus"
      description = "Location of the resources."
    }
    
    variable "node_count" {
      type        = number
      default     = 1
      description = "Number of nodes in the default node pool of the AKS cluster."
    }
    ```
4. Create a file named `main.tf` and add the following code:

    ```terraform
    data "azurerm_client_config" "current" {}
    
    resource "random_string" "suffix" {
      length  = 6
      special = false
      upper   = false
    }
    
    resource "azurerm_resource_group" "rg" {
      location = var.location
      name     = "rg-101-aks-entra-k8s-rbac-${random_string.suffix.result}"
    }
    
    resource "azurerm_kubernetes_cluster" "aks" {
      location            = azurerm_resource_group.rg.location
      name                = "aks-101-entra-k8s-rbac-${random_string.suffix.result}"
      resource_group_name = azurerm_resource_group.rg.name
      dns_prefix          = "aks-${random_string.suffix.result}"
      # Kubernetes RBAC is required by the example, Azure RBAC for Kubernetes
      # Authorization must stay disabled.
      role_based_access_control_enabled = true
    
      default_node_pool {
        name       = "agentpool"
        node_count = var.node_count
        vm_size    = "Standard_D2s_v3"
      }
    
      identity {
        type = "SystemAssigned"
      }
    
      azure_active_directory_role_based_access_control {
        azure_rbac_enabled = false
        tenant_id          = data.azurerm_client_config.current.tenant_id
      }
    }
    ```
5. Create a file named `outputs.tf` and insert the following code:

    ```terraform
    output "resource_group_name" {
      description = "Name of the resource group that contains the AKS cluster."
      value       = azurerm_resource_group.rg.name
    }
    
    output "aks_cluster_name" {
      description = "Name of the AKS cluster with Microsoft Entra integration and Kubernetes RBAC enabled."
      value       = azurerm_kubernetes_cluster.aks.name
    }
    
    output "appdev_group_object_id" {
      description = "Object ID of the existing test principal used for developer access."
      value       = data.azurerm_client_config.current.object_id
    }
    
    output "opssre_group_object_id" {
      description = "Object ID of the existing test principal used for SRE access."
      value       = azurerm_kubernetes_cluster.aks.identity[0].principal_id
    }
    ```
6. Initialize, format, and validate the configuration.

    ```console
    terraform init
    terraform fmt
    terraform validate
    ```
7. Review and apply the configuration.

    ```console
    terraform plan -out main.tfplan
    terraform apply main.tfplan
    ```
8. Get the outputs. You use these values as input for the scenario configuration in the next section.

    ```console
    terraform output -raw resource_group_name
    terraform output -raw aks_cluster_name
    terraform output -raw appdev_group_object_id
    terraform output -raw opssre_group_object_id
    ```

Important

The `appdev_group_object_id` and `opssre_group_object_id` outputs from the `prequisite` configuration are test principal IDs, not real Microsoft Entra groups. They resolve to the object ID of your currently signed-in Azure CLI account and the AKS cluster's managed identity principal ID, and exist only so the repository's automated tests can validate that the scenario configuration applies successfully. To test the Microsoft Entra group and user experience described in this article, use the group object IDs from Create groups in Microsoft Entra ID instead.

### Deploy Kubernetes RBAC with Terraform

1. Create a new directory, separate from `prequisite`, and make it your current directory. This configuration has its own Terraform state and doesn't manage or depend on the state of the `prequisite` configuration.
2. Create a file named `main.tf` and add the following code:

    ```terraform
    terraform {
      required_version = ">= 1.6.0"
    
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~> 4.0"
        }
        kubernetes = {
          source  = "hashicorp/kubernetes"
          version = "~> 2.30"
        }
      }
    }
    
    provider "azurerm" {
      features {}
    }
    
    variable "resource_group_name" {
      type        = string
      description = "Name of the resource group that contains the existing AKS cluster."
    }
    
    variable "aks_cluster_name" {
      type        = string
      description = "Name of the existing AKS cluster with Microsoft Entra integration and Kubernetes RBAC enabled."
    }
    
    variable "appdev_group_object_id" {
      type        = string
      description = "Object ID of an existing Microsoft Entra group used for developer access to the dev namespace."
    }
    
    variable "opssre_group_object_id" {
      type        = string
      description = "Object ID of an existing Microsoft Entra group used for SRE access to the sre namespace."
    }
    
    data "azurerm_kubernetes_cluster" "aks" {
      name                = var.aks_cluster_name
      resource_group_name = var.resource_group_name
    }
    
    provider "kubernetes" {
      host                   = data.azurerm_kubernetes_cluster.aks.kube_admin_config[0].host
      client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_admin_config[0].client_certificate)
      client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_admin_config[0].client_key)
      cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_admin_config[0].cluster_ca_certificate)
    }
    
    resource "azurerm_role_assignment" "appdev_cluster_user" {
      scope                = data.azurerm_kubernetes_cluster.aks.id
      role_definition_name = "Azure Kubernetes Service Cluster User Role"
      principal_id         = var.appdev_group_object_id
    }
    
    resource "azurerm_role_assignment" "opssre_cluster_user" {
      scope                = data.azurerm_kubernetes_cluster.aks.id
      role_definition_name = "Azure Kubernetes Service Cluster User Role"
      principal_id         = var.opssre_group_object_id
    }
    
    resource "kubernetes_namespace" "dev" {
      metadata {
        name = "dev"
      }
    }
    
    resource "kubernetes_namespace" "sre" {
      metadata {
        name = "sre"
      }
    }
    
    resource "kubernetes_role" "dev_full_access" {
      metadata {
        name      = "dev-user-full-access"
        namespace = kubernetes_namespace.dev.metadata[0].name
      }
    
      rule {
        api_groups = ["", "extensions", "apps"]
        resources  = ["*"]
        verbs      = ["*"]
      }
    
      rule {
        api_groups = ["batch"]
        resources  = ["jobs", "cronjobs"]
        verbs      = ["*"]
      }
    }
    
    resource "kubernetes_role" "sre_full_access" {
      metadata {
        name      = "sre-user-full-access"
        namespace = kubernetes_namespace.sre.metadata[0].name
      }
    
      rule {
        api_groups = ["", "extensions", "apps"]
        resources  = ["*"]
        verbs      = ["*"]
      }
    
      rule {
        api_groups = ["batch"]
        resources  = ["jobs", "cronjobs"]
        verbs      = ["*"]
      }
    }
    
    resource "kubernetes_role_binding" "dev_user_access" {
      metadata {
        name      = "dev-user-access"
        namespace = kubernetes_namespace.dev.metadata[0].name
      }
    
      role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind      = "Role"
        name      = kubernetes_role.dev_full_access.metadata[0].name
      }
    
      subject {
        kind      = "Group"
        name      = var.appdev_group_object_id
        api_group = "rbac.authorization.k8s.io"
      }
    }
    
    resource "kubernetes_role_binding" "sre_user_access" {
      metadata {
        name      = "sre-user-access"
        namespace = kubernetes_namespace.sre.metadata[0].name
      }
    
      role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind      = "Role"
        name      = kubernetes_role.sre_full_access.metadata[0].name
      }
    
      subject {
        kind      = "Group"
        name      = var.opssre_group_object_id
        api_group = "rbac.authorization.k8s.io"
      }
    }
    ```
3. Create a file named `terraform.tfvars` and provide the resource group name and cluster name for the AKS cluster you want to configure, and the object IDs of the *appdev* and *opssre* groups.

    ```hcl
    resource_group_name    = "<resource-group-name>"
    aks_cluster_name       = "<aks-cluster-name>"
    appdev_group_object_id = "<appdev-group-object-id>"
    opssre_group_object_id = "<opssre-group-object-id>"
    ```
4. Initialize, format, and validate the configuration.

    ```console
    terraform init
    terraform fmt
    terraform validate
    ```
5. Review and apply the configuration.

    ```console
    terraform plan -out main.tfplan
    terraform apply main.tfplan
    ```

    The configuration creates the Azure role assignments for both groups, the *dev* and *sre* Kubernetes namespaces, and namespace-scoped Roles and RoleBindings that grant the *appdev* group access to *dev* and the *opssre* group access to *sre*.

### Verify namespace access

1. Get the cluster admin credentials by using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --resource-group myResourceGroup --name myAKSCluster --admin
    ```
2. Verify that both namespaces exist by using the [`kubectl get namespaces`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command.

    ```console
    kubectl get namespaces
    ```

    The output shows the *dev* and *sre* namespaces, along with the default namespaces created for the cluster.

To test that the *appdev* and *opssre* groups can access only their assigned namespace, continue to Access AKS cluster resources with Microsoft Entra identities.

### Clean up Terraform resources

Important

Destroy the scenario configuration before the `prequisite` configuration. The scenario configuration's Kubernetes provider needs the AKS cluster to still exist so Terraform can remove the namespaces, Roles, and RoleBindings it created.

1. From the scenario configuration directory, remove the Azure role assignments, namespaces, Roles, and RoleBindings it created.

    ```console
    terraform destroy
    ```
2. If you deployed the `prequisite` AKS cluster only to test this sample and no longer need it, remove it from the `prequisite` directory after the scenario configuration finishes destroying its resources.

    ```console
    terraform destroy
    ```

::: zone-end

## Access AKS cluster resources with Microsoft Entra identities

Now, test that the expected permissions work when you create and manage resources in an AKS cluster. In these examples, you schedule and view pods in the user's assigned namespace, and try to schedule and view pods outside of the assigned namespace.

1. Reset the *kubeconfig* context using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command. In a previous section, you set the context using the cluster admin credentials. The admin user bypasses Microsoft Entra sign-in prompts. Without the `--admin` parameter, the user context is applied that requires all requests to be authenticated using Microsoft Entra ID.

    ```azurecli
    az aks get-credentials --resource-group myResourceGroup --name myAKSCluster --overwrite-existing
    ```
2. Schedule a basic NGINX pod using the [`kubectl run`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#run) command in the *dev* namespace:

    ```console
    kubectl run nginx-dev --image=mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine --namespace dev
    ```
3. Enter the credentials for the *appdev* group account (enter *your* own credentials) at the sign-in prompt. Once you're successfully signed in, the account token is cached for future `kubectl` commands. The NGINX is successfully scheduled as shown in the following example output:

    ```console
    $ kubectl run nginx-dev --image=mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine --namespace dev
    
    To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code B24ZD6FP8 to authenticate.
    
    pod/nginx-dev created
    ```
4. Use the [`kubectl get pods`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command to view pods in the *dev* namespace:

    ```console
    kubectl get pods --namespace dev
    ```
5. Ensure the status of the NGINX pod is *Running*. The output looks like the following output:

    ```console
    $ kubectl get pods --namespace dev
    
    NAME        READY   STATUS    RESTARTS   AGE
    nginx-dev   1/1     Running   0          4m
    ```

### Test SRE access to AKS cluster resources

To confirm that our Microsoft Entra group membership and Kubernetes RBAC work correctly between different users and groups, try the previous commands when signed in as the *akssre* user.

1. Reset the *kubeconfig* context using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command that clears the previously cached authentication token for the *aksdev* user.

    ```azurecli
    az aks get-credentials --resource-group myResourceGroup --name myAKSCluster --overwrite-existing
    ```
2. Schedule and view pods in the assigned *SRE* namespace. When prompted, sign in with the *opssre* group account credentials (enter *your* own credentials).

    ```console
    kubectl run nginx-sre --image=mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine --namespace sre
    kubectl get pods --namespace sre
    ```

    As shown in the following example output, you can successfully create and view the pods:

    ```console
    $ kubectl run nginx-sre --image=mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine --namespace sre
    ```
3. To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code BM4RHP3FD to authenticate.

    ```console
    pod/nginx-sre created
    
    $ kubectl get pods --namespace sre
    
    NAME        READY   STATUS    RESTARTS   AGE
    nginx-sre   1/1     Running   0
    ```
4. Try to view or schedule pods outside of assigned SRE namespace.

    ```console
    kubectl get pods --all-namespaces
    kubectl run nginx-sre --image=mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine --namespace dev
    ```

    These `kubectl` commands fail, as shown in the following example output. The user's group membership and Kubernetes Role and RoleBindings don't grant permissions to create or manager resources in other namespaces.

    ```console
    $ kubectl get pods --all-namespaces
    Error from server (Forbidden): pods is forbidden: User "akssre@contoso.com" cannot list pods at the cluster scope
    
    $ kubectl run nginx-sre --image=mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine --namespace dev
    Error from server (Forbidden): pods is forbidden: User "akssre@contoso.com" cannot create pods in the namespace "dev"
    ```

### Create and view cluster resources outside of the assigned namespace

To view pods outside of the *dev* namespace. Use the [`kubectl get pods`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command using `--all-namespaces`:

```console
kubectl get pods --all-namespaces
```

The user's group membership doesn't have a Kubernetes Role that allows this action, as shown in the following example output:

```console
Error from server (Forbidden): pods is forbidden: User "aksdev@contoso.com" cannot list resource "pods" in API group "" at the cluster scope
```

In the same way, schedule a pod in a different namespace, such as the *SRE* namespace. The user's group membership doesn't align with a Kubernetes Role and RoleBinding to grant these permissions, as shown in the following example output:

```console
$ kubectl run nginx-dev --image=mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine --namespace sre

Error from server (Forbidden): pods is forbidden: User "akssre@contoso.com" cannot create resource "pods" in API group "" in the namespace "sre"
```

### Clean up cluster resources

To clean up all of the resources, run the following commands.

::: zone pivot="azure-cli"

Get the admin kubeconfig context and delete the *dev* and *sre* namespaces. This action also deletes the pods, Roles, and RoleBindings.

```azurecli
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster --admin

kubectl delete namespace dev
kubectl delete namespace sre
```

::: zone-end

::: zone pivot="terraform"

If you used Terraform to create the *dev* and *sre* namespaces, Roles, and RoleBindings, see Clean up Terraform resources instead of running `kubectl delete namespace`.

::: zone-end

Delete the Microsoft Entra ID user accounts for aksdev and akssre.

```azurecli
az ad user delete --upn-or-object-id $AKSDEV_ID
az ad user delete --upn-or-object-id $AKSSRE_ID
```

Delete the Microsoft Entra ID groups for appdev and opssre. This action also deletes any remaining Azure role assignments.

```azurecli
az ad group delete --group appdev
az ad group delete --group opssre
```