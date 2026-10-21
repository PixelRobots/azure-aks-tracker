---
layout: Conceptual
title: Install and Use the Agentic CLI for Azure Kubernetes Service (AKS) (Preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/agentic-cli-for-aks-install
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
description: Learn how to install, configure, and use the agentic CLI for AKS to troubleshoot clusters and get intelligent insights by using natural language.
ms.topic: how-to
ms.date: 2025-10-20T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-developer
zone_pivot_groups: agentic-cli-deployment-mode
locale: en-us
document_id: 403eb60a-6292-aa24-55a0-5ee7ce917669
document_version_independent_id: b2c8c502-9937-df3a-5532-8795b38f4faf
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/agentic-cli-for-aks-install.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/agentic-cli-for-aks-install
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/agentic-cli-for-aks-install.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/8a6e4dad-7050-4ce7-83f9-eb4123577a54
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/0a5fc323-00ce-4c20-9095-41948f54c83f
platformId: 7a24eca3-e176-eb2d-f41b-71ce87727c38
---

# Install and Use the Agentic CLI for Azure Kubernetes Service (AKS) (Preview) - Azure Kubernetes Service | Microsoft Learn

This article shows you how to install, configure, and use the agentic CLI for Azure Kubernetes Service (AKS) in [client mode](agentic-cli-for-aks-overview#deployment-modes) or [cluster mode](agentic-cli-for-aks-overview#deployment-modes) to get AI-powered troubleshooting and insights for your AKS clusters.

For more information, see the [Agentic CLI for AKS overview](agentic-cli-for-aks-overview).

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Prerequisites

- Azure CLI version 2.76 or later. Check your version using the `az version` command. To install or update, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- Have a large language model (LLM) API key. You must bring your own API key from one of the supported providers:

    - Azure OpenAI (recommended)
    - OpenAI or other LLM providers compatible with OpenAPI specifications
- Set your active Azure subscription using the [`az account set`](/en-us/cli/azure/account#az-account-set) command.

    ```azurecli
    az account set --subscription "your-subscription-id-or-name"
    ```
- Version 1.0.0b16 or later of the `aks-agent` Azure CLI extension, which provides the agentic CLI for AKS functionality. You can install or update the extension using the Azure CLI.

::: zone pivot="client-mode"

- Docker installed and running on your local machine. For installation instructions, see [Get Started with Docker](https://www.docker.com/get-started/).
- Ensure the Docker daemon is started and running before proceeding with the installation.
- Ensure your Azure credentials are properly configured and you have the necessary permissions to access cluster resources.

::: zone-end

::: zone pivot="cluster-mode"

- Before installing, you need to [Create a required Kubernetes service account with RBAC permissions](agentic-cli-for-aks-service-account-workload-identity-setup). (Workload identity setup is optional.)
- You need write access to deploy to the Kubernetes namespace where the agent will be deployed.

::: zone-end

### Install the agentic CLI for AKS extension

1. Install the agentic CLI for AKS extension using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command. If the extension is already installed, you can update to the latest version with the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command. This step might take 5 to 10 minutes to complete.

    ```azurecli
    # Install the extension
    az extension add --name aks-agent --debug
    
    # Update the extension
    az extension update --name aks-agent --debug
    ```
2. Verify successful installation using the [`az extension list`](/en-us/cli/azure/extension#az-extension-list) command.

    ```azurecli
    az extension list
    ```

    Your output should include an entry for `aks-agent`.
3. Verify the agentic CLI for AKS commands are available using the [`az aks agent`][/cli/azure/aks#az-aks-agent] command with the `--help` parameter.

    ```azurecli
    az aks agent --help
    ```

    Your output should show the `aks-agent` with its version information in the `extensions` section. For example:

    ```output
    ...
    "extensions": {
    "aks-agent": "1.0.0b17",
    }
    ```

## Set up your LLM API key

Before proceeding with installation, you need to set up your LLM API key. We recommend using newer models such as *GPT-5* or *Claude Opus MINI* for better performance. Make sure to select a model with a high context size of at least *128,000 tokens* or higher.

### Azure OpenAI (recommended)

1. [Create an Azure OpenAI resource](/en-us/azure/foundry-classic/openai/how-to/create-resource?pivots=web-portal#create-a-resource).
2. [Deploy the model](/en-us/azure/ai-foundry/openai/how-to/create-resource?pivots=web-portal#deploy-a-model). For the deployment name, use the same name as the model name, such as *gpt-4o* or *gpt-4o-mini*, depending on the access. You can use any region where you have access and quota for the model. In the deployment, select a token-per-minute (TPM) limit as high as possible. We recommend upward of *1-million TPM* for good performance.
3. After the deployment completes, note your API base URL and API key. The API version isn't the model version. You can use any API version that's available and supported in [Azure OpenAI in Microsoft Foundry Models v1 API](/en-us/azure/ai-foundry/openai/api-version-lifecycle). The Azure API base refers to the Azure OpenAI endpoint (which usually ends in `openai.azure.com/`), not the target URI of the deployment in Foundry.

### Azure OpenAI with Microsoft Entra ID (keyless authentication)

When you select "Azure Open AI (Microsoft Entra ID)" as your LLM provider, you can configure keyless authentication using Microsoft Entra ID. With this option, you don't need to provide an API key. Instead, this authentication method requires the following role assignments:

- **Client mode**: The local Azure CLI credentials must be assigned the **Cognitive Services User** or **Azure AI User** role on the Azure OpenAI resource.
- **Cluster mode**: The workload identity must be assigned the **Cognitive Services User** or **Azure AI User** role on the Azure OpenAI resource.

### Other LLM providers

If you're using another OpenAI-compatible provider, follow their documentation for instructions on how to create an account and retrieve the API key.

::: zone pivot="client-mode"

## Verify Docker installation and start Docker daemon

1. Verify that Docker is installed and the Docker daemon is running using the following commands:

    ```bash
    docker --version
    docker ps
    ```
2. If you receive an error indicating that the Docker daemon isn't running, start the Docker service using the appropriate steps for your operating system:

    - **macOS / Windows**:

        - Launch Docker Desktop from your applications.
        - Wait for Docker to start.
    - **Linux**:

        - Start the Docker service using the following commands:

            ```bash
            sudo systemctl start docker
            sudo systemctl enable docker  # Enable Docker to start on boot
            ```
3. Verify Docker is running using the following command:

    ```bash
    docker info
    ```

    This command should return Docker system information without errors.

## Initialize client mode

1. Initialize the agentic CLI with client mode using the [`az aks agent-init`](/en-us/cli/azure/aks#az-aks-agent-init) command. Make sure to replace the placeholder values with your actual resource group and cluster name.

    ```azurecli
    az aks agent-init --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
    ```
2. When prompted to select a deployment mode, enter **2** for client mode.

    ```output
    🚀 Welcome to AKS Agent initialization!
    
    Please select the mode you want to use:
      1. Cluster mode - Deploys agent as a pod in your AKS cluster
         Uses service account and workload identity for secure access to cluster and Azure resources
      2. Client mode - Runs agent locally using Docker
         Uses your local Azure credentials and cluster user credentials for access
    
    Enter your choice (1 or 2): 2
    ```
3. Configure your LLM provider details. For example:

    ```output
    Welcome to AKS Agent LLM configuration setup. Type '/exit' to exit.
     1. Azure Open AI (API Key)
     1. Azure Open AI (Microsoft Entra ID)
     3. OpenAI
     4. Anthropic
     5. Gemini
     6. Openai Compatible
    Enter the number of your LLM provider: 1
    Your selected provider: azure
    Enter value for MODEL_NAME:  (Hint: should be consistent with your deployed name, e.g., gpt-4.1) gpt-4.1
    Enter your API key: 
    Enter value for AZURE_API_BASE:  (Hint: https://{your-custom-endpoint}.openai.azure.com/) https://test-example.openai.azure.com
    Enter value for AZURE_API_VERSION:  (Default: 2025-04-01-preview)
    LLM configuration setup successfully.
    ```

    Note

    The API key appears empty as you type for security. Make sure to enter the correct API key.
4. Verify the initialization was successful. The agent automatically pulls the necessary Docker images when you run your first command.

::: zone-end

::: zone pivot="cluster-mode"

## Initialize cluster mode

1. Initialize the agentic CLI with cluster mode using the [`az aks agent-init`](/en-us/cli/azure/aks#az-aks-agent-init) command. Make sure to replace the placeholder values with your actual resource group and cluster name.

    ```azurecli
    az aks agent-init --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
    ```
2. When prompted to select a deployment mode, enter **1** for cluster mode.

    ```output
    🚀 Welcome to AKS Agent initialization!
    
    Please select the mode you want to use:
      1. Cluster mode - Deploys agent as a pod in your AKS cluster
         Uses service account and workload identity for secure access to cluster and Azure resources
      2. Client mode - Runs agent locally using Docker
         Uses your local Azure credentials and cluster user credentials for access
    
    Enter your choice (1 or 2): 1
    ```
3. When prompted to specify the target namespace, enter the namespace where you created the service account. The following example uses `your-namespace` as a placeholder. Make sure to replace it with the actual namespace you used.

    ```output
    ✅ Cluster mode selected. This will set up the agent deployment in your cluster.
    
    Please specify the namespace where the agent will be deployed.
    
    Enter namespace (e.g., 'kube-system'): your-namespace
    ```
4. Configure your LLM provider details. For example:

    ```output
    📦 Using namespace: your-namespace
    No existing LLM configuration found. Setting up new configuration...
    Please provide your LLM configuration. Type '/exit' to exit.
     1. Azure OpenAI
     2. OpenAI
     3. Anthropic
     4. Gemini
     5. OpenAI Compatible
     6. For other providers, see https://aka.ms/aks/agentic-cli/init
    Please choose the LLM provider (1-5): 1
    ```
5. Provide service account details using the [Kubernetes service account](agentic-cli-for-aks-service-account-workload-identity-setup) you created for the agent deployment. The following example uses `aks-mcp` as a placeholder for the service account name. Make sure to replace it with the actual name of your service account.

    ```output
    👤 Service Account Configuration
    The AKS agent requires a service account with appropriate permissions in the 'your-namespace'
    namespace.
    Please ensure you have created the necessary Role and RoleBinding in your namespace for 
    this service account.
    
    Enter service account name: aks-mcp
    ```
6. Wait for deployment completion. The initialization deploys the agent using Helm.

    ```output
    🚀 Deploying AKS agent (this typically takes less than 2 minutes)...
    ✅ AKS agent deployed successfully!
    Verifying deployment status...
    ✅ AKS agent is ready and running!
    
    🎉 Initialization completed successfully!
    ```
7. Verify successful deployment and check the status of the agent using the [`az aks agent`](/en-us/cli/azure/aks#az-aks-agent) command with the `--status` parameter.

    ```azurecli
    az aks agent \
    --status \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --namespace $NAMESPACE
    ```

    Your output should indicate that the agent is ready and running, similar to the following:

    ```output
    📊 Checking AKS agent status...
    
    ✅ Helm Release: deployed
    
    📦 Deployments:
      • aks-agent: 1/1 ready
      • aks-mcp: 1/1 ready
    
    🐳 Pods:
      • aks-agent-xxxxx-xxxxx: Running ✓
      • aks-mcp-xxxxx-xxxxx: Running ✓
    
    📋 LLM Configurations:
      • azure/gpt-4o
        API Base: https://your-service.openai.azure.com/
        API Version: 2025-04-01-preview
    
    ✅ AKS agent is ready and running!
    ```

    Note

    You can also verify successful deployment by checking the pods and deployments in the target namespace using `kubectl`:

    ```bash
    kubectl get pods --namespace $NAMESPACE | grep aks-
    kubectl get deployment --namespace $NAMESPACE | grep aks-
    ```

::: zone-end

## Use the agentic CLI for AKS

Once initialized, you can use the agentic CLI for AKS to troubleshoot your clusters and get intelligent insights by using natural language queries. The command syntax and functionality are the same for both client mode and cluster mode, except for the `--mode` and `--namespace` parameters. Cluster mode is the default deployment mode, so you only need to specify `--mode client` when using client mode. For cluster mode, you need to specify the `--namespace` parameter with the namespace where the agent is deployed.

### Basic queries

Note

If you have multiple models set up, you can specify the model to use for each query using the `--model` parameter. For example, `--model=azure/gpt-4o`.

::: zone pivot="client-mode"

The following are examples of basic queries you can run with the agentic CLI for AKS in client mode:

```azurecli
az aks agent "How many nodes are in my cluster?" --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --mode client
az aks agent "What is the Kubernetes version on the cluster?" --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --mode client
az aks agent "Why is coredns not working on my cluster?" --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --mode client
az aks agent "Why is my cluster in a failed state?" --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --mode client
```

::: zone-end

::: zone pivot="cluster-mode"

The following are examples of basic queries you can run with the agentic CLI for AKS in cluster mode:

```azurecli
az aks agent "How many nodes are in my cluster?" --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --namespace $NAMESPACE
az aks agent "What is the Kubernetes version on the cluster?" --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --namespace $NAMESPACE
az aks agent "Why is coredns not working on my cluster?" --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --namespace $NAMESPACE
az aks agent "Why is my cluster in a failed state?" --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --namespace $NAMESPACE
```

::: zone-end

The experience uses interactive mode by default, so you can continue asking questions with retained context until you want to leave. To leave the experience, enter `/exit`.

### Command parameters

The `az aks agent` command has several parameters that allow you to customize the troubleshooting experience. The following table describes the key parameters you can use when running your queries:

| Parameter | Description |
| --- | --- |
| `--max-steps` | Maximum number of steps the LLM can take to investigate the issue. Default: 40. |
| `--mode` | The mode decides how the agent is deployed. Allowed values: `client`, `cluster`. Default: `cluster`. |
| `--model` | Specify the LLM provider and model or deployment to use for the AI assistant. |
| `--name`, `-n` | Name of the managed cluster. (Required) |
| `--namespace` | The Kubernetes namespace where the AKS Agent is deployed. Required for cluster mode. |
| `--no-echo-request` | Disable echoing back the question provided to AKS Agent in the output. |
| `--no-interactive` | Disable interactive mode. When set, the agent will not prompt for input and will run in batch mode. |
| `--refresh-toolsets` | Refresh the toolsets status. |
| `--resource-group`, `-g` | Name of resource group. (Required) |
| `--show-tool-output` | Show the output of each tool that was called. |
| `--status` | Show AKS agent configuration and status information. |

### Model specification

The `--model` parameter determines which LLM and provider analyzes your cluster. For example:

- **OpenAI**: Use the model name directly (for example, `gpt-4o`).
- **Azure OpenAI**: Use `azure/<deployment name>` (for example, `azure/gpt-4o`).
- **Anthropic**: Use `anthropic/claude-sonnet-4`.

### Interactive commands

The `az aks agent` has a set of subcommands that aid the troubleshooting experience. To access them, enter `/` inside the interactive mode experience.

The following table describes the available interactive commands:

| Command | Description |
| --- | --- |
| `/exit` | Leave the interactive mode. |
| `/help` | Show help messages with all commands. |
| `/clear` | Clear the screen and reset the conversation context. |
| `/tools` | Show available toolsets and their status. |
| `/auto` | Switch the display of tool outputs after responses. |
| `/last` | Show all tool outputs from the last response. |
| `/run` | Run a Bash command and optionally share it with LLM. |
| `/shell` | Drop into the interactive shell and then optionally share the session with LLM. |
| `/context` | Show the conversation context size and token count. |
| `/show` | Show the specific tool output in a scrollable view. |
| `/feedback` | Provide feedback on the agent's response. |

### Disable interactive mode

You can disable interactive mode using the `--no-interactive` flag with your command. For example:

::: zone pivot="client-mode"

```azurecli
az aks agent "How many pods are in the kube-system namespace" --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --mode client --model=azure/gpt-4o --no-interactive
az aks agent "Why are the pods in Crashloopbackoff in the kube-system namespace" --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --mode client --model=azure/gpt-4o --no-interactive --show-tool-output
```

::: zone-end

::: zone pivot="cluster-mode"

```azurecli
az aks agent "How many pods are in the kube-system namespace" --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --namespace $NAMESPACE --model=azure/gpt-4o --no-interactive
az aks agent "Why are the pods in Crashloopbackoff in the kube-system namespace" --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --namespace $NAMESPACE --model=azure/gpt-4o --no-interactive --show-tool-output
```

::: zone-end

### Toolsets

The agentic CLI for AKS includes prebuilt integrations for popular monitoring and observability tools through toolsets. Some integrations work automatically with Kubernetes. Other integrations require API keys or configuration.

For AKS, there are specific toolsets that help with the troubleshooting experience. These toolsets appear in the output at the start of the experience:

```output
...
✅ Toolset kubernetes/kube-prometheus-stack
✅ Toolset internet
✅ Toolset bash
✅ Toolset runbook
✅ Toolset kubernetes/logs
✅ Toolset kubernetes/core
✅ Toolset kubernetes/live-metrics
✅ Toolset aks/core
✅ Toolset aks/node-health
Using 37 datasources (toolsets). To refresh: use flag `--refresh-toolsets`
```

## AKS MCP server integration

The [AKS Model Context Protocol (MCP) server](https://github.com/Azure/aks-mcp) is enabled by default with the agentic CLI for AKS. This experience spins up the AKS MCP server locally (or in the cluster with cluster mode) and uses it as the source for telemetry.

## Clean up agentic CLI deployment

::: zone pivot="client-mode"

Clean up your client mode deployment using the [`az aks agent-cleanup`](/en-us/cli/azure/aks#az-aks-agent-cleanup) command with the `--mode client` parameter. This command removes the local configuration file and resets the agent configuration.

```azurecli
az aks agent-cleanup --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --mode client
```

::: zone-end

::: zone pivot="cluster-mode"

Clean up your cluster mode deployment using the [`az aks agent-cleanup`](/en-us/cli/azure/aks#az-aks-agent-cleanup) command. Make sure to specify the `--namespace` parameter with the namespace where the agent is deployed. This command removes the agent pod from the specified namespace and deletes the LLM configuration stored on the cluster.

```azurecli
az aks agent-cleanup --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --namespace $NAMESPACE
```

::: zone-end

### Verify successful cleanup

::: zone pivot="client-mode"

Check that the local configuration file and Docker images were removed using the following commands:

```bash
# Check if configuration file was removed
ls ~/.azure/aksAgent.config

# Check for remaining Docker images
docker images | grep aks-agent
```

::: zone-end

::: zone pivot="cluster-mode"

Check that the agent pod and related resources were removed from the cluster using the following commands with the appropriate namespace:

```bash
# Check if agent pod was removed
kubectl get pods --namespace $NAMESPACE

# Check if service account was removed
kubectl get serviceaccount --namespace $NAMESPACE

# Check if namespace was removed (if it was created during init)
kubectl get namespace $NAMESPACE
```

::: zone-end

## Remove the agentic CLI for AKS extension

Remove the agentic CLI for AKS extension using the [`az extension remove`](/en-us/cli/azure/extension#az-extension-remove) command.

```azurecli
az extension remove --name aks-agent --debug
```