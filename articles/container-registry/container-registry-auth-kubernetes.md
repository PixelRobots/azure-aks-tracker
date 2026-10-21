---
layout: Conceptual
title: Kubernetes Pull Secret for ACR Authentication - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-auth-kubernetes
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/62/azure-container-registry/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/180a533d-0d25-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: KumudD
learn_banner_products:
- azure
manager: kumud
ms.reviewer: kumud
ms.author: kumud
ms.service: azure-container-registry
description: Learn how to provide a Kubernetes cluster with access to images in your Azure container registry by creating a pull secret using a service principal
ms.topic: concept-article
ms.date: 2023-10-31T00:00:00.0000000Z
ms.custom:
- devx-track-azurecli
- sfi-ropc-nochange
locale: en-us
document_id: 0b775c99-7231-2bfa-1af2-c40852c591aa
document_version_independent_id: 499f8091-28e4-b6c5-4dd1-b5fac9632769
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-auth-kubernetes.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-auth-kubernetes
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-auth-kubernetes.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/57eae307-c3a1-4cac-b645-1a899934bac8
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/ee561821-1ac7-45a8-9409-6ba5eb7a5b97
platformId: aa646579-3003-0384-8bdf-ce93f404bc13
---

# Kubernetes Pull Secret for ACR Authentication - Azure Container Registry | Microsoft Learn

You can use an Azure container registry as a source of container images with any Kubernetes cluster, including "local" Kubernetes clusters such as [minikube](https://minikube.sigs.k8s.io/) and [kind](https://kind.sigs.k8s.io/). This article shows how to create a Kubernetes pull secret using credentials for an Azure container registry. Then, use the secret to pull images from an Azure container registry in a pod deployment.

This example creates a pull secret using Microsoft Entra [service principal credentials](container-registry-auth-service-principal). You can optionally scope the service principal's pull permissions to specific repositories in the registry by using [Microsoft Entra-based repository permissions](container-registry-rbac-abac-repository-permissions).

You can also configure a pull secret using other Azure container registry credentials, such as using [non-Microsoft Entra token-based repository permissions](container-registry-token-based-repository-permissions).

Note

While pull secrets are commonly used, they bring additional management overhead. If you're using [Azure Kubernetes Service](/en-us/azure/aks/intro-kubernetes), we recommend [other options](authenticate-kubernetes-options) such as using the cluster's managed identity or service principal to securely pull the image without an additional `imagePullSecrets` setting on each pod.

## Prerequisites

This article assumes you already created a private Azure container registry. You also need to have a Kubernetes cluster running and accessible via the `kubectl` command-line tool.

## Create a service principal

To create a service principal with access to your container registry, run the following script in the [Azure Cloud Shell](/en-us/azure/cloud-shell/overview) or a local installation of the [Azure CLI](/en-us/cli/azure/install-azure-cli). The script is formatted for the Bash shell.

Before running the script, update the `ACR_NAME` variable with the name of your container registry. The `SERVICE_PRINCIPAL_NAME` value must be unique within your Microsoft Entra tenant. If you receive an "`'http://acr-service-principal' already exists.`" error, specify a different name for the service principal.

You can optionally modify the `--role` value in the [az ad sp create-for-rbac](/en-us/cli/azure/ad/sp#az-ad-sp-create-for-rbac) command to grant different permissions. For a complete list of roles, see [Azure Container Registry Entra permissions and roles overview](container-registry-rbac-built-in-roles-overview).

After you run the script, take note of the service principal's **ID** and **password**. Once you have its credentials, you can configure your applications and services to authenticate to your container registry as the service principal.

```azurecli
#!/bin/bash
# This script requires Azure CLI version 2.25.0 or later. Check version with `az --version`.

# Modify for your environment.
# ACR_NAME: The name of your Azure Container Registry
# SERVICE_PRINCIPAL_NAME: Must be unique within your AD tenant
ACR_NAME=$containerRegistry
SERVICE_PRINCIPAL_NAME=$servicePrincipal

# Obtain the full registry ID
ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query "id" --output tsv)
# echo $registryId

# Create the service principal with rights scoped to the registry.
# Default permissions are for docker pull access. Modify the '--role'
# argument value as desired:
# acrpull:     pull only
# acrpush:     push and pull
# owner:       push, pull, and assign roles
PASSWORD=$(az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME --scopes $ACR_REGISTRY_ID --role acrpull --query "password" --output tsv)
USER_NAME=$(az ad sp list --display-name $SERVICE_PRINCIPAL_NAME --query "[].appId" --output tsv)

# Output the service principal's credentials; use these in your services and
# applications to authenticate to the container registry.
echo "Service principal ID: $USER_NAME"
echo "Service principal password: $PASSWORD"
```

### Use an existing service principal

To grant registry access to an existing service principal, you must assign a new role to the service principal. As with creating a new service principal, you must perform role assignments to grant permissions to the service principal. See [Azure Container Registry Entra permissions and roles overview](container-registry-rbac-built-in-roles-overview).

The following script uses the [az role assignment create](/en-us/cli/azure/role/assignment#az-role-assignment-create) command to grant pull permissions to a service principal you specify in the `SERVICE_PRINCIPAL_ID` variable. Adjust the `--role` value if you'd like to grant a different level of access.

```azurecli
#!/bin/bash
# Modify for your environment. The ACR_NAME is the name of your Azure Container
# Registry, and the SERVICE_PRINCIPAL_ID is the service principal's 'appId' or
# one of its 'servicePrincipalNames' values.
ACR_NAME=$containerRegistry
SERVICE_PRINCIPAL_ID=$servicePrincipal

# Populate value required for subsequent command args
ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query id --output tsv)

# Assign the desired role to the service principal. Modify the '--role' argument
# value as desired:
# acrpull:     pull only
# acrpush:     push and pull
# owner:       push, pull, and assign roles
az role assignment create --assignee $SERVICE_PRINCIPAL_ID --scope $ACR_REGISTRY_ID --role acrpull
```

If you don't save or remember the service principal password, you can reset it with the [az ad sp credential reset](/en-us/cli/azure/ad/sp/credential#az-ad-sp-credential-reset) command:

```azurecli
az ad sp credential reset  --name http://<service-principal-name> --query password --output tsv
```

This command returns a new, valid password for your service principal.

## Create an image pull secret

Kubernetes uses an *image pull secret* to store information needed to authenticate to your registry. To create the pull secret for an Azure container registry, you provide the service principal ID, password, and the registry URL.

Create an image pull secret with the following `kubectl` command:

```console
kubectl create secret docker-registry <secret-name> \
    --namespace <namespace> \
    --docker-server=<container-registry-name>.azurecr.io \
    --docker-username=<service-principal-ID> \
    --docker-password=<service-principal-password>
```

where:

| Value | Description |
| --- | --- |
| `secret-name` | Name of the image pull secret, for example, *acr-secret* |
| `namespace` | Kubernetes namespace to put the secret into  Only needed if you want to place the secret in a namespace other than the default namespace |
| `container-registry-name` | Name of your Azure container registry, for example, *myregistry*The `--docker-server` is the fully qualified name of the registry login server |
| `service-principal-ID` | ID of the service principal that will be used by Kubernetes to access your registry |
| `service-principal-password` | Service principal password |

## Use the image pull secret

Once you've created the image pull secret, you can use it to create Kubernetes pods and deployments. Provide the name of the secret under `imagePullSecrets` in the deployment file. For example:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-awesome-app-pod
  namespace: awesomeapps
spec:
  containers:
    - name: main-app-container
      image: myregistry.azurecr.io/my-awesome-app:v1
      imagePullPolicy: IfNotPresent
  imagePullSecrets:
    - name: acr-secret
```

In the preceding example, `my-awesome-app:v1` is the name of the image to pull from the Azure container registry, and `acr-secret` is the name of the pull secret you created to access the registry. When you deploy the pod, Kubernetes automatically pulls the image from your registry, if it is not already present on the cluster.