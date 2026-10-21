---
layout: Conceptual
title: Configure External Identity Providers with AKS Structured Authentication (Preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/external-identity-provider-authentication-configure
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
description: Learn how to configure external identity providers for Azure Kubernetes Service (AKS) using structured authentication and JWT authenticators.
author: shashankbarsin
ms.author: shasb
ms.topic: how-to
ms.subservice: aks-security
ms.custom: preview, devx-track-azurecli
ms.date: 2025-11-04T00:00:00.0000000Z
zone_pivot_groups: external-idp-authn-type
locale: en-us
document_id: f998df54-1994-4255-a9eb-a88012da6efb
document_version_independent_id: fdfbce84-36cb-2196-3da8-273d0c4e782c
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/external-identity-provider-authentication-configure.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/external-identity-provider-authentication-configure
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/external-identity-provider-authentication-configure.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/c77bc83e-f0b0-4b63-836e-6630e606bf7c
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/b98eda1f-6af8-444f-bbfb-7f2366948cbc
platformId: d7ab8c88-106c-80b9-56d3-50526af17283
---

# Configure External Identity Providers with AKS Structured Authentication (Preview) - Azure Kubernetes Service | Microsoft Learn

This article shows you how to configure GitHub and Google Identity external identity providers for Azure Kubernetes Service (AKS) control plane authentication using structured authentication. You learn how to create JSON Web Token (JWT) authenticators, configure claim validation and mapping, and test the authentication flow.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Prerequisites

- Read the [conceptual overview](external-identity-provider-authentication-overview) for authentication to AKS using external identity provider.

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

- This article requires version 2.77.0 or later of the Azure CLI. If you're using Azure Cloud Shell, the latest version is already installed there. To install or update the Azure CLI on your local machine, see [Install the Azure CLI](/en-us/cli/azure/install-azure-cli).
- You need to install the `aks-preview` Azure CLI extension version 18.0.0b41 or later to use structured authentication features.

    - If you don't already have the `aks-preview` extension, install it using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command.

        ```azurecli
        az extension add --name aks-preview
        ```
    - If you already have the `aks-preview` extension, update it to make sure you have the latest version using the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command.

        ```azurecli
        az extension update --name aks-preview
        ```
    - Verify you have the required version of the `aks-preview` extension using the [`az extension show`](/en-us/cli/azure/extension#az-extension-show) command.

        ```azurecli
        az extension show --name aks-preview --query version
        ```
- An AKS cluster running Kubernetes version 1.30 or later. To create an AKS cluster, see [Deploy an Azure Kubernetes Service (AKS) cluster using Azure CLI](learn/quick-kubernetes-deploy-cli).
- `kubectl` command-line tool to interact with your Kubernetes cluster. `kubectl` is already installed if you use Azure Cloud Shell. You can install `kubectl` locally using the [`az aks install-cli`](/en-us/cli/azure/aks#az-aks-install-cli) command.

    ```azurecli
    az aks install-cli
    ```
- An external identity provider that supports OpenID Connect (OIDC).
- Network connectivity from cluster nodes to your identity provider.
- If you plan to use the `kubelogin` plugin, install it by following the instructions in the [kubelogin setup guide](https://github.com/int128/kubelogin?tab=readme-ov-file#setup).

## Set environment variables

- Set the following environment variables for your resource group and cluster name:

    ```bash
    export RESOURCE_GROUP="<your-resource-group-name>"
    export CLUSTER_NAME="<your-cluster-name>"
    ```

## Register the `JWTAuthenticatorPreview` feature

1. Register the `JWTAuthenticatorPreview` feature using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

    ```azurecli
    az feature register --name JWTAuthenticatorPreview --namespace Microsoft.ContainerService
    ```
2. Check the registration status of the feature using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command.

    ```azurecli
    az feature show --name JWTAuthenticatorPreview --namespace Microsoft.ContainerService
    ```
3. When the status shows `Registered`, refresh the resource provider registration for `Microsoft.ContainerService` using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace Microsoft.ContainerService
    ```

::: zone pivot="github"

## Set up GitHub Actions OIDC authentication

1. Ensure your GitHub Actions workflows have the necessary permissions.
2. Configure the `id-token: write` permission in your workflow files. For example:

    ```yaml
    permissions:
      id-token: write
      contents: read
    ```
3. Set up appropriate repository and organization settings for OIDC token access. Configure [repository OIDC settings](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure) and organization security policies for token usage.

::: zone-end

::: zone pivot="google-identity"

## Set up Google Identity OAuth 2.0 authentication

1. Navigate to the [Google Cloud Console](https://console.cloud.google.com/).
2. [Create or select a project](https://developers.google.com/workspace/guides/create-project).
3. [Create OAuth 2.0 credentials](https://developers.google.com/identity/protocols/oauth2/).
4. Note your client ID and client secret for later use.

::: zone-end

::: zone pivot="github"

## Create JWT authenticator configuration for GitHub Actions OIDC

- Create a file named `jwt-config.json` with the following configuration:

    ```json
    {
      "issuer": {
          "url": "https://token.actions.githubusercontent.com",
          "audiences": [
              "my-api"
          ]
      },
      "claimValidationRules": [
          {
              "expression": "has(claims.sub)",
              "message": "must have sub claim"
          }
      ],
      "claimMappings": {
          "username": {
              "expression": "'aks:jwt:github:' + claims.sub"
          }
      },
      "userValidationRules": [
          {
              "expression": "has(user.username)",
              "message": "must have username"
          },
          {
              "expression": "!user.username.startsWith('aks:jwt:github:system')",
              "message": "username must not start with 'aks:jwt:github:system'"
          }
      ]
    }
    ```

::: zone-end

::: zone pivot="google-identity"

## Create JWT authenticator configuration for Google Identity

- Create a file named `jwt-config.json` with the following configuration:

    ```json
    {
        "issuer": {
            "url": "https://accounts.google.com",
            "audiences": [
                "your-client-id.apps.googleusercontent.com"
            ]
        },
        "claimValidationRules": [
            {
                "expression": "has(claims.sub)",
                "message": "must have sub claim"
            }
        ],
        "claimMappings": {
            "username": {
                "expression": "'aks:jwt:google:' + claims.sub"
            },
            "groups": {
                "expression": "has(claims.groups) ? claims.groups.split(',').map(g, 'aks:jwt:' + g) : []"
            }
        },
        "userValidationRules": [
            {
                "expression": "has(user.username)",
                "message": "must have username"
            },
            {
                "expression": "!user.username.startsWith('aks:jwt:google:system')",
                "message": "username must not start with 'aks:jwt:google:system'"
            }
        ]
    }
    ```

::: zone-end

## JWT authenticator configuration elements

The JWT authenticator configuration includes the following key elements: `issuer`, `claimValidationRules`, `claimMappings`, and `userValidationRules`. Each element serves a specific purpose in defining how AKS validates and processes JWT tokens from the external identity provider.

### Issuer configuration

The following table describes the key elements of the `issuer` configuration:

| Issuer configuration element | Description |
| --- | --- |
| `url` | The OIDC issuer URL that must match the `iss` claim in JWTs. |
| `audiences` | List of audiences that JWTs must be issued for (checked against `aud` claim). |

### Claim validation rules configuration

The following table describes the key elements of the `claimValidationRules` configuration:

| Claim validation rule element | Description |
| --- | --- |
| `expression` | CEL expression that defines the validation logic to apply to JWT claims. The expression must evaluate to true for the token to be accepted. |
| `message` | Error message returned when the validation rule fails. |

### Claim mappings configuration

The following table describes the key elements of the `claimMappings` configuration:

| Claim mappings element | Description |
| --- | --- |
| `username` | CEL expression that defines how to construct the Kubernetes username from JWT claims. **Must include the `aks:jwt:` prefix to prevent conflicts with other authentication methods**. |
| `groups` | CEL expression that defines how to construct Kubernetes group memberships from JWT claims. **Must include the `aks:jwt:` prefix to prevent conflicts with other authentication methods**. |
| `uid` | Optional CEL expression that defines a unique identifier for the user. |
| `extra` | Optional map of additional user attributes defined by CEL expressions. |

### User validation rules configuration

The following table describes the key elements of the `userValidationRules` configuration:

| User validation rule element | Description |
| --- | --- |
| `expression` | CEL expression that defines additional validation logic to apply to the final mapped user information. The expression must evaluate to true for the user to be accepted. |
| `message` | Error message returned when the user validation rule fails. |

## Create the JWT authenticator

- Add the JWT authenticator to your AKS cluster using the [`az aks jwtauthenticator add`](/en-us/cli/azure/aks/jwtauthenticator#az-aks-jwtauthenticator-add) command.

    ```azurecli
    az aks jwtauthenticator add \
        --resource-group $RESOURCE_GROUP \
        --cluster-name $CLUSTER_NAME \
        --name external-auth \
        --config-file jwt-config.json
    ```

## Manage JWT authenticators

### List all JWT authenticators

- List all JWT authenticators on your cluster using the [`az aks jwtauthenticator list`](/en-us/cli/azure/aks/jwtauthenticator#az-aks-jwtauthenticator-list) command.

    ```azurecli
    az aks jwtauthenticator list \
        --resource-group $RESOURCE_GROUP \
        --cluster-name $CLUSTER_NAME
    ```

### Get details for a specific JWT authenticator

- Get details for a specific JWT authenticator using the [`az aks jwtauthenticator show`](/en-us/cli/azure/aks/jwtauthenticator#az-aks-jwtauthenticator-show) command.

    ```azurecli
    az aks jwtauthenticator show \
        --resource-group $RESOURCE_GROUP \
        --cluster-name $CLUSTER_NAME \
        --name external-auth
    ```

::: zone pivot="github"

## Set up GitHub Actions OIDC for authentication

1. Create environment variables for and set the following required repository secrets in your GitHub repository:

    - `AKS_SERVER_URL`: Your AKS cluster's API server URL.
    - `AKS_CA_DATA`: Base64-encoded certificate authority data for your AKS cluster.
2. Create a workflow that obtains an OIDC token and uses it to authenticate with your AKS cluster. The following example workflow gets all pods running on the cluster:

    Note

    The audience value `my-api` should match the audience configured in your JWT authenticator configuration.

    ```yaml
    name: AKS Access with GitHub OIDC
    on:
      workflow_dispatch:
      push:
        branches: [main]
    
    permissions:
      id-token: write
      contents: read
    
    jobs:
      aks-access:
        runs-on: ubuntu-latest
        steps:
          - name: Checkout code
            uses: actions/checkout@v4
    
          - name: Install kubectl
            uses: azure/setup-kubectl@v3
            with:
              version: 'latest'
    
          - name: Get GitHub OIDC token
            id: get_token
            run: |
              TOKEN=$(curl -H "Authorization: Bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" \
                "$ACTIONS_ID_TOKEN_REQUEST_URL&audience=my-api" | \
                jq -r '.value')
              echo "::add-mask::$TOKEN"
              echo "oidc_token=$TOKEN" >> $GITHUB_OUTPUT
    
          - name: Create kubeconfig with OIDC token
            run: |
              cat <<EOF > kubeconfig
              apiVersion: v1
              kind: Config
              clusters:
              - cluster:
                  certificate-authority-data: ${{ secrets.AKS_CA_DATA }}
                  server: ${{ secrets.AKS_SERVER_URL }}
                name: aks-cluster
              contexts:
              - context:
                  cluster: aks-cluster
                  user: github-oidc-user
                name: aks-context
              current-context: aks-context
              users:
              - name: github-oidc-user
                user:
                  token: ${{ steps.get_token.outputs.oidc_token }}
              EOF
    
          - name: List all pods in the cluster
            run: |
              export KUBECONFIG=./kubeconfig
              kubectl get pods --all-namespaces
    ```

## Get cluster information for JWT authenticator configuration

1. Get the API server URL for your cluster using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```bash
    az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --query "fqdn" -o tsv | \
      awk '{print "https://" $0 ":443"}'
    ```
2. Get the base64-encoded certificate authority data for your cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```bash
    # Get CA data (base64 encoded)
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --file - --format exec | \
      grep certificate-authority-data | awk '{print $2}'
    ```

::: zone-end

::: zone pivot="google-identity"

## Set up Google Identity OAuth 2.0 for authentication

You can set up Google Identity authentication using either the `kubelogin` plugin or by directly using a static token.

# [Use kubelogin plugin](#tab/use-kubelogin-plugin)
- Add a new user context to your kubeconfig file. For example:

    ```yaml
    users:
    - name: external-user
      user:
        exec:
          apiVersion: client.authentication.k8s.io/v1beta1
          command: kubectl
          args:
          - oidc-login
          - get-token
          - --oidc-issuer-url=https://accounts.google.com
          - --oidc-client-id=your-client-id.apps.googleusercontent.com
          - --oidc-client-secret=your-client-secret
    ```

# [Use static token](#tab/use-static-token)
- If you have a JWT token, you can use it directly. For example:

    ```yaml
    users:
    - name: external-user
      user:
        token: eyJhbGciOiJSUzI1NiIs...
    ```

---

::: zone-end

## Test authentication

::: zone pivot="github"

1. Trigger the workflow either by **pushing to the main branch** or **manually triggering it from the Actions tab** in your repository.
2. Monitor the workflow execution in the Actions tab to verify authentication is working.

    Expected output for first-time setup before Role-Based Access Control (RBAC) configuration:

    ```output
    Error from server (Forbidden): nodes is forbidden: User "aks:jwt:github:your-sub" cannot list resource "nodes" in API group "" at the cluster scope
    ```

    This error indicates successful authentication but lack of authorization.

::: zone-end

::: zone pivot="google-identity"

- Test the authentication using the `kubectl get nodes` command with the `--user` flag to specify the user context you created for Google Identity authentication. For example:

    ```bash
    kubectl get nodes --user external-user
    ```

    Expected output for first-time setup before Role-Based Access Control (RBAC) configuration:

    ```output
    Error from server (Forbidden): nodes is forbidden: User "aks:jwt:google:your-subject" cannot list resource "nodes" in API group "" at the cluster scope
    ```

    This error indicates successful authentication but lack of authorization.

::: zone-end

## Configure Kubernetes Role-Based Access Control (RBAC)

Create appropriate RBAC bindings for your external users, and use the cluster admin credentials to apply these configurations.

::: zone pivot="github"

1. Create a file named `rbac-config.yaml` to configure RBAC bindings for external users. For example:

    ```yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: external-user-role
    rules:
    - apiGroups: [""]
      resources: ["pods", "services", "nodes"]
      verbs: ["get", "list"]
    - apiGroups: ["apps"]
      resources: ["deployments", "replicasets"]
      verbs: ["get", "list"]
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: external-user-binding
    subjects:
    - kind: User
      # This matches the username expression in claim mappings for GitHub; example of GitHub subject is "repo:<organization-name>/<repository-name>:ref:refs/heads/main"
      name: aks:jwt:github:your-github-sub
      apiGroup: rbac.authorization.k8s.io
    roleRef:
      kind: ClusterRole
      name: external-user-role
      apiGroup: rbac.authorization.k8s.io
    ```
2. Apply the RBAC configuration using the `kubectl apply` command:

    ```bash
    kubectl apply -f rbac-config.yaml
    ```

::: zone-end

::: zone pivot="google-identity"

1. Create a file named `rbac-config.yaml` to configure RBAC bindings for external users. For example:

    ```yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: external-user-role
    rules:
    - apiGroups: [""]
      resources: ["pods", "services", "nodes"]
      verbs: ["get", "list"]
    - apiGroups: ["apps"]
      resources: ["deployments", "replicasets"]
      verbs: ["get", "list"]
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: external-user-binding
    subjects:
    - kind: User
      # This matches the username expression in claim mappings for Google
      name: aks:jwt:google:your-subject-claim
      apiGroup: rbac.authorization.k8s.io
    roleRef:
      kind: ClusterRole
      name: external-user-role
      apiGroup: rbac.authorization.k8s.io
    ```
2. Apply the RBAC configuration using the `kubectl apply` command:

    ```bash
    kubectl apply -f rbac-config.yaml
    ```

::: zone-end

## Verify access with RBAC

- Verify the external user can now access resources according to the RBAC permissions you configured using the `kubectl get nodes` and `kubectl get pods` commands with the `--user` flag. For example:

    ```bash
    kubectl get nodes --user external-user
    kubectl get pods --user external-user
    ```

## Remove JWT authenticator

- When you no longer need the JWT authenticator, remove it from your AKS cluster using the [`az aks jwtauthenticator delete`](/en-us/cli/azure/aks/jwtauthenticator#az-aks-jwtauthenticator-delete) command.

    ```azurecli
    az aks jwtauthenticator delete \
        --resource-group $RESOURCE_GROUP \
        --cluster-name $CLUSTER_NAME \
        --name external-auth
    ```