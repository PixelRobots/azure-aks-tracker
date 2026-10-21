---
layout: Conceptual
title: Configure Tool Calling with an AI Inference Service using the AI Toolchain Operator on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/ai-toolchain-operator-tool-calling
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
description: Learn how to deploy an AI inference service that supports tool calling in Azure Kubernetes Service (AKS) by using the managed add-on for KAITO.
ms.topic: how-to
ms.author: schaffererin
author: schaffererin
ms.custom: aks-ai-ml
ms.date: 2025-10-01T00:00:00.0000000Z
locale: en-us
document_id: ef69c085-9362-55e0-28d2-f6c07444e59d
document_version_independent_id: 373fcd9b-7e45-35dc-8c3f-6bb352e24c2c
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/ai-toolchain-operator-tool-calling.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/ai-toolchain-operator-tool-calling
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/ai-toolchain-operator-tool-calling.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 2cda3da8-0583-f643-0937-d1a74cd7937b
---

# Configure Tool Calling with an AI Inference Service using the AI Toolchain Operator on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

In this article, you configure and deploy an AI toolchain operator (KAITO) inference workspace on Azure Kubernetes Service (AKS) with support for OpenAI-style tool calling. You also learn how to validate tool calling functionality using vLLM metrics and local function mocks.

## What is tool calling?

Tool calling enables large language models (LLMs) to interface with external functions, APIs, or services. Instead of just generating text, an LLM can decide:

- "I need to call a weather API."
- "I need to use a calculator."
- "I should search a database."

It does this by invoking a defined "tool" with parameters it chooses based on the user's request. Tool calling is useful for:

- Chatbots that book, summarize, or calculate.
- Enterprise LLM applications where hallucination must be minimized.
- Agent frameworks (AutoGen, LangGraph, LangChain, AgentOps, etc.).

In production environments, AI-enabled applications often demand more than natural language generation; they require the ability to take action based on user intent. Tool calling empowers LLMs to extend beyond text responses by invoking external tools, APIs, or custom logic in real time. This bridges the gap between language understanding and execution, enabling developers to build interactive AI assistants, agents, and automation workflows that are both accurate and useful. Instead of relying on static responses, LLMs can now access live data, trigger services, and complete tasks on behalf of users, both safely and reliably.

When deployed on AKS, tool calling becomes scalable, secure, and production ready. Kubernetes provides the flexibility to orchestrate inference workloads using high-performance runtimes like vLLM, while ensuring observability and governance of tool usage. With this pattern, AKS operators and app developers can more seamlessly update models or tools independently and deploy advanced AI features without compromising reliability.

As a result, tool calling on AKS is now a foundational pattern for building modern AI apps that are context-aware, action-capable, and enterprise-ready.

### Tool calling with KAITO

To streamline this deployment model, the AI toolchain operator (KAITO) add-on for AKS provides a managed solution for running inference services with [tool calling support](https://kaito-project.github.io/kaito/docs/tool-calling/). By leveraging KAITO inference workspaces, you can quickly spin up scalable, GPU-accelerated model endpoints with built-in support for tool calling and OpenAI-compatible APIs. This eliminates the operational overhead of configuring runtimes, managing dependencies, or scaling infrastructure manually.

## Prerequisites

- This article assumes that you have an existing AKS cluster. If you don't have a cluster, create one by using the [Azure CLI](learn/quick-kubernetes-deploy-cli), [Azure PowerShell](learn/quick-kubernetes-deploy-powershell), or the [Azure portal](learn/quick-kubernetes-deploy-portal).
- Your AKS cluster is running on Kubernetes version `1.33` or higher. To upgrade your cluster, see [Upgrade your AKS cluster](upgrade-aks-cluster).
- Install and configure Azure CLI version `2.77.0` or later. To find your version, run `az --version`. To install or update, see [Install the Azure CLI](/en-us/cli/azure/install-azure-cli).
- The [AI toolchain operator add-on enabled](ai-toolchain-operator) on your cluster.
- A deployed KAITO inference workspace that supports tool calling. Refer to the official [KAITO tool calling](https://kaito-project.github.io/kaito/docs/tool-calling/) documentation for the tool calling supported models with vLLM.
- You deployed the `workspace‑phi‑4-mini-toolcall`[KAITO workspace](https://github.com/kaito-project/kaito/blob/main/examples/inference/kaito_workspace_tool_calling.yaml) with the default configuration.

## Confirm the KAITO inference workspace is running

- Monitor your workspace deployment with the `kubectl get` command.

    ```bash
    kubectl get workspace workspace‑phi‑4‑mini-toolcall -w
    ```

    In the output, you want to verify the resource (`ResourceReady`) and inference (`InferenceReady`) are ready and the workspace succeeded (`WorkspaceSucceeded` being `true`).

## Confirm the inference API is ready to serve

1. Once the workspace is ready, find the service endpoint using the `kubectl get` command.

    ```bash
    kubectl get svc workspace‑phi‑4-mini-toolcall
    ```

    Note

    The output might be a `ClusterIP` or internal address. Check which port(s) the service listens on. The default KAITO inference API is on port `80` for HTTP. If it's only internal, you can port‑forward locally.
2. Port-forward the inference service for testing using the `kubectl port-forward` command.

    ```bash
    kubectl port-forward svc/workspace‑phi‑4‑mini-toolcall 8000:80
    ```
3. Check the `/v1/models` endpoint to confirm the LLM is available using `curl`.

    ```bash
    curl http://localhost:8000/v1/models
    ```

    To ensure the LLM is deployed, and the API is working, your output should be similar to the following:

    ```output
    ...
    {
      "object": "list",
      "data": [
        {
          "id": "phi‑4‑mini‑instruct",
          ...
          ...
        }
      ]
    }
    ...
    ```

## Test the named function tool‐calling

In this example, the `workspace‑phi‑4‑mini-toolcall` workspace supports named function tool-calling by default, so we can confirm the LLM accepts a "tool" spec in OpenAI‑style requests and returns a "function call" structure.

The Python snippet we use in this section is from the [KAITO documentation](https://kaito-project.github.io/kaito/docs/tool-calling/#examples) and uses an OpenAI‑compatible client.

- Confirm the LLM accepts a "tool" spec in OpenAI‑style requests and returns a "function call" structure. This example:

    - Initializes the OpenAI-compatible client to talk to a local inference server. The server is assumed to be running at `http://localhost:8000/v1` and accepts OpenAI-style API calls.
    - Simulates the backend logic for a tool called `get_weather`. (In a real scenario, this would call a weather API.)
    - Describes the tool interface; the `Phi-4-mini` LLM will see this tool and decide whether to use it based on the user's input.
    - Sends a sample chat message to the model and provides the tool spec. The setting `tool_choice="auto"` allows the LLM to decide if it should call a tool based on the prompt.
    - In this case, the user's request was relevant to the `get_weather` tool, so we simulate the execution of the tool, calling the local function with the model's chosen arguments.

    ```python
    from openai import OpenAI
    import json
    
    # local server
    client = OpenAI(base_url="http://localhost:8000/v1", api_key="dummy")
    
    def get_weather(location: str, unit: str) -> str:
        return f"Getting the weather for {location} in {unit}..."
    
    tool_functions = {"get_weather": get_weather}
    
    tools = [{
        "type": "function",
        "function": {
            "name": "get_weather",
            "description": "Get the current weather in a given location",
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {"type": "string"},
                    "unit": {"type": "string", "enum": ["celsius", "fahrenheit"]}
                },
                "required": ["location", "unit"]
            }
        }
    }]
    
    response = client.chat.completions.create(
        model="phi‑4‑mini‑instruct",   # or client.models.list().data[0].id
        messages=[{"role": "user", "content": "What's the weather like in San Francisco?"}],
        tools=tools,
        tool_choice="auto"
    )
    
    # Inspect response
    tool_call = response.choices[0].message.tool_calls[0].function
    args = json.loads(tool_call.arguments)
    print("Function called:", tool_call.name)
    print("Arguments:", args)
    print("Result:", tool_functions[tool_call.name](**args))
    ```

    Your output should look similar to the following:

    ```output
    Function called: get_weather
    Arguments: {"location": "San Francisco, CA", "unit": "fahrenheit"}
    Result: Getting the weather for San Francisco, CA in fahrenheit...
    ```

    The "tool\_calls" field comes back, meaning the `Phi-4-mini` LLM decided to invoke the function. Now, a sample tool call has been successfully parsed and executed based on the model's decision to confirm end-to-end tool calling behavior with the KAITO inference deployment.

## Troubleshooting

### Model preset doesn't support tool calling

If you pick a model that isn't on the supported list, tool calling might not work. Make sure you [review the KAITO documentation](https://kaito-project.github.io/kaito/docs/tool-calling/), which explicitly lists which presets support tool calling.

### Misaligned runtime

The KAITO inference must use [vLLM runtime for tool calling](https://kaito-project.github.io/kaito/docs/tool-calling/#supported-inference-runtimes) (HuggingFace Transformers runtime generally doesn't support tool calling in KAITO).

### Network / endpoint issues

If port-forwarding, ensure the service ports are correctly forwarded. If the external MCP server is unreachable, will error out.

### Timeouts

External MCP server calls might take time. Make sure the adapter or client timeout is sufficiently high.

### Authentication

If the external MCP server requires authentication (API key, header, etc.), ensure you supply correct credentials.