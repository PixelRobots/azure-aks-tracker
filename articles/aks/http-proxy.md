---
layout: Conceptual
title: Configure Azure Kubernetes Service (AKS) nodes with an HTTP proxy - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/http-proxy
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
description: Learn how to configure Azure Kubernetes Service (AKS) clusters to use an HTTP proxy for outbound internet access.
ms.subservice: aks-networking
ms.custom: devx-track-arm-template, devx-track-azurecli
author: allyford
ms.topic: how-to
ms.date: 2026-08-26T00:00:00.0000000Z
ms.author: allyford
zone_pivot_groups: arm-azure-cli
locale: en-us
document_id: 68d8ae2e-0c79-8c63-56e6-7a781fc39086
document_version_independent_id: 3deaf490-262a-84e4-427c-fe128a090b91
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/http-proxy.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/http-proxy
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/http-proxy.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 08063673-495e-3512-c571-6e6009830311
---

# Configure Azure Kubernetes Service (AKS) nodes with an HTTP proxy - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to configure Azure Kubernetes Service (AKS) clusters to use an HTTP proxy for outbound internet access.

AKS clusters deployed into managed or custom virtual networks have certain outbound dependencies that are necessary to function properly, which created problems in environments requiring internet access to be routed through HTTP proxies. Nodes had no way of bootstrapping the configuration, environment variables, and certificates necessary to access internet services.

The HTTP proxy feature adds HTTP proxy support to AKS clusters, exposing a straightforward interface that you can use to secure AKS-required network traffic in proxy-dependent environments. With this feature, both AKS nodes and pods are configured to use the HTTP proxy. The feature also enables installation of a trusted certificate authority onto the nodes as part of bootstrapping a cluster. More complex solutions might require creating a chain of trust to establish secure communications across the network.

## Limitations and considerations

The following scenarios are **not** supported:

- Different proxy configurations per node pool
- User/Password authentication
- Custom certificate authorities (CAs) for API server communication
- Specifying more than 20 trusted CA certificates. For new clusters, the CA certificate content can't exceed 35 KB.
- AKS clusters with Windows node pools
- Node pools using Virtual Machine Availability Sets (VMAS)
- Using \* as wildcard attached to a domain suffix for noProxy
- noProxy hosts must be RFC 1123 compliant

`httpProxy`, `httpsProxy`, and `trustedCa` have no value by default. Pods are injected with the following environment variables:

- `HTTP_PROXY`
- `http_proxy`
- `HTTPS_PROXY`
- `https_proxy`
- `NO_PROXY`
- `no_proxy`

To disable the injection of the proxy environment variables, you need to annotate the Pod with `"kubernetes.azure.com/no-http-proxy-vars":"true"`.

::: zone pivot="azure-cli"

## Before you begin

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

- Disable HTTP Proxy requires minimum CLI version 2.85.0.

::: zone-end

::: zone pivot="azure-cli"

## Create a configuration file with HTTP proxy values

Create a file and provide values for `httpProxy`, `httpsProxy`, and `noProxy`. If your environment requires it, provide a value for `trustedCa`.

The schema for the config file looks like this:

```json
{
  "httpProxy": "string",
  "httpsProxy": "string",
  "noProxy": [
    "string"
  ],
  "trustedCa": "string"
}
```

Review requirements for each parameter:

- `httpProxy`: A proxy URL to use for creating HTTP connections outside the cluster. The URL scheme must be `http`.
- `httpsProxy`: A proxy URL to use for creating HTTPS connections outside the cluster. If not specified, then `httpProxy` is used for both HTTP and HTTPS connections.
- `noProxy`: A list of destination domain names, domains, IP addresses, or other network CIDRs to exclude proxying.
- `trustedCa`: A string containing the base64 encoded alternative CA certificate content. Currently, only the `PEM` format is supported. You can include up to 20 certificates. For new clusters, the CA certificate content can't exceed 35 KB.

Important

For compatibility with Go-based components that are part of the Kubernetes system, the certificate **must** support `Subject Alternative Names(SANs)` instead of the deprecated Common Name certs.

There are differences in applications on how to comply with the environment variable `http_proxy`, `https_proxy`, and `no_proxy`. Curl and Python don't support CIDR in `no_proxy`, but Ruby does.

Example input:

```json
{
  "httpProxy": "http://myproxy.server.com:8080", 
  "httpsProxy": "https://myproxy.server.com:8080", 
  "noProxy": [
    "localhost",
    "127.0.0.1"
  ],
    "trustedCa": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUgvVENDQmVXZ0F3SUJB...S0tLS0="
}
```

## Create a cluster with an HTTP proxy configuration using the Azure CLI

You can configure an AKS cluster with an HTTP proxy configuration during cluster creation.

1. Use the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command and pass in your configuration as a JSON file.

    ```azurecli
    az aks create \
        --name $clusterName \
        --resource-group $resourceGroup \
        --http-proxy-config aks-proxy-config.json \
        --generate-ssh-keys
    ```

    Your cluster should initialize with the HTTP proxy configured on the nodes.
2. Verify the HTTP proxy configuration is on the pods and nodes by checking that the environment variables contain the appropriate values for `http_proxy`, `https_proxy`, and `no_proxy` using the `kubectl describe pod` command.

    ```bash
    kubectl describe {any pod} -n kube-system
    ```

    To validate proxy variables are set in pods, you can check the environment variables present on the nodes.

    ```bash
    kubectl get nodes
    kubectl node-shell {node name}
    cat /etc/environment
    ```

## Update an HTTP proxy configuration

You can update HTTP proxy configurations on existing clusters, including:

- Updating an existing cluster to enable HTTP proxy and adding a new HTTP proxy configuration.
- Updating an existing cluster to change an HTTP proxy configuration.

### HTTP proxy update considerations

The `--http-proxy-config` parameter should be set to a new JSON file with updated values for `httpProxy`, `httpsProxy`, `noProxy`, and `trustedCa` if necessary. The update injects new environment variables into pods with the new `httpProxy`, `httpsProxy`, or `noProxy` values. Pods must be rotated for the apps to pick it up, because the environment variable values are injected by a mutating admission webhook.

Note

If switching to a new proxy, the new proxy must already exist for the update to be successful. After the upgrade is completed, you can delete the old proxy.

### Update a cluster to update or enable HTTP proxy

1. Enable or update HTTP proxy configurations on an existing cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command.

    For example, let's say you created a new file with the base64 encoded string of the new CA cert called *aks-proxy-config-2.json*. You can update the proxy configuration on your cluster with the following command:

    ```azurecli
    az aks update --name $clusterName --resource-group $resourceGroup --http-proxy-config aks-proxy-config-2.json
    ```

Caution

AKS automatically reimages all node pools in the cluster when you update the proxy configuration on your cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command. You can use [Pod Disruption Budgets (PDBs)](operator-best-practices-scheduler) to safeguard disruption to critical pods during reimage.

1. Verify the HTTP proxy configuration is on the pods and nodes by checking that the environment variables contain the appropriate values for `http_proxy`, `https_proxy`, and `no_proxy` using the `kubectl describe pod` command.

    ```bash
    kubectl describe {any pod} -n kube-system
    ```

    To validate proxy variables are set in pods, you can check the environment variables present on the nodes.

    ```bash
    kubectl get nodes
    kubectl node-shell {node name}
    cat /etc/environment
    ```

## Disable HTTP proxy on an existing cluster

### Update cluster to disable HTTP proxy

1. Update your cluster to disable HTTP proxy using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with `--disable-http-proxy` flag.

    ```azurecli
    az aks update --name $clusterName --resource-group $resourceGroup --disable-http-proxy
    ```

Caution

AKS automatically reimages all node pools in the cluster when you update the proxy configuration on your cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command. You can use [Pod Disruption Budgets (PDBs)](operator-best-practices-scheduler) to safeguard disruption to critical pods during reimage.

1. Verify HTTP proxy is disabled by validating the HTTP proxy configuration isn't set on the pods and nodes using the `kubectl describe pod` command.

    ```bash
    kubectl describe {any pod} -n kube-system
    ```

    To validate proxy variables aren't set in pods, you can check the environment variables present on the nodes.

    ```bash
    kubectl get nodes
    kubectl node-shell {node name}
    cat /etc/environment
    ```

### Re-enable HTTP proxy on an existing cluster

When you create a cluster, HTTP proxy is enabled by default. Once you disable HTTP proxy on a cluster, the proxy configuration is saved in the database but the proxy variables are removed from the pods and nodes.

To re-enable HTTP proxy on an existing cluster, use the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--enable-http-proxy` flag.

```azurecli
az aks update --name $clusterName --resource-group $resourceGroup --enable-http-proxy
```

Caution

AKS automatically reimages all node pools in the cluster when you update the proxy configuration on your cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command. You can use [Pod Disruption Budgets (PDBs)](operator-best-practices-scheduler) to safeguard disruption to critical pods during reimage.

Important

If you had an HTTP proxy configuration on your cluster before disabling, the existing HTTP proxy configuration automatically applies when you re-enable HTTP proxy on that cluster. We recommend verifying the configuration to ensure it meets your current requirements before proceeding. If you want to change your HTTP proxy configuration after re-enabling HTTP proxy, follow the steps to Update the HTTP proxy configuration on an existing cluster.

::: zone-end

::: zone pivot="arm"

## Configure an HTTP proxy configuration using an Azure Resource Manager (ARM) template

You can deploy an AKS cluster with an HTTP proxy using an ARM template.

1. Review requirements for each parameter:

    - `httpProxy`: A proxy URL to use for creating HTTP connections outside the cluster. The URL scheme must be `http`.
    - `httpsProxy`: A proxy URL to use for creating HTTPS connections outside the cluster. If not specified, then `httpProxy` is used for both HTTP and HTTPS connections.
    - `noProxy`: A list of destination domain names, domains, IP addresses, or other network CIDRs to exclude proxying.
    - `trustedCa`: A string containing the base64 encoded alternative CA certificate content. Currently, only the `PEM` format is supported. For new clusters, the CA certificate content can't exceed 35 KB.

    Important

    For compatibility with Go-based components that are part of the Kubernetes system, the certificate **must** support `Subject Alternative Names (SANs)` instead of the deprecated Common Name certs.

    There are differences in applications on how to comply with the environment variable `http_proxy`, `https_proxy`, and `no_proxy`. Curl and Python don't support CIDR in `no_proxy`, but Ruby does.
2. Create a template with HTTP proxy parameters. In your template, provide values for `httpProxy`, `httpsProxy`, and `noProxy`. If necessary, provide a value for `trustedCa`. The same schema used for CLI deployment exists in the `Microsoft.ContainerService/managedClusters` definition under `"properties"`, as shown in the following example:

    ```json
    "properties": {
        ...,
        "httpProxyConfig": {
          "enabled": "true",
            "httpProxy": "string",
            "httpsProxy": "string",
            "noProxy": [
                "string"
            ],
            "trustedCa": "string"
        }
    }
    ```
3. Deploy your ARM template with the HTTP Proxy configuration. Your cluster should initialize with your HTTP proxy configured on the nodes.

## Update an HTTP proxy configuration

You can update HTTP proxy configurations on existing clusters, including:

- Updating an existing cluster to enable HTTP proxy and adding a new HTTP proxy configuration.
- Updating an existing cluster to change an HTTP proxy configuration.

### HTTP proxy update considerations

The `--http-proxy-config` parameter should be set to a new JSON file with updated values for `httpProxy`, `httpsProxy`, `noProxy`, and `trustedCa` if necessary. The update injects new environment variables into pods with the new `httpProxy`, `httpsProxy`, or `noProxy` values. Pods must be rotated for the apps to pick it up, because the environment variable values are injected by a mutating admission webhook.

Note

If switching to a new proxy, the new proxy must already exist for the update to be successful. After the upgrade is completed, you can delete the old proxy.

### Update an ARM template to configure HTTP proxy

1. In your template, provide new values for `httpProxy`, `httpsProxy`, and `noProxy`. If necessary, provide a value for `trustedCa`.

    The same schema used for CLI deployment exists in the `Microsoft.ContainerService/managedClusters` definition under `"properties"`, as shown in the following example:

    ```json
    "properties": {
        ...,
        "httpProxyConfig": {
            "enabled": "true",
            "httpProxy": "string",
            "httpsProxy": "string",
            "noProxy": [
                "string"
            ],
            "trustedCa": "string"
        }
    }
    ```
2. Deploy your ARM template with the updated HTTP Proxy configuration.

Caution

AKS automatically reimages all node pools in the cluster when you update the proxy configuration on your cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command. You can use [Pod Disruption Budgets (PDBs)](operator-best-practices-scheduler) to safeguard disruption to critical pods during reimage.

1. Verify the HTTP proxy configuration is on the pods and nodes by checking that the environment variables contain the appropriate values for `http_proxy`, `https_proxy`, and `no_proxy` using the `kubectl describe pod` command.

    ```bash
    kubectl describe {any pod} -n kube-system
    ```

    To validate proxy variables are set in pods, you can check the environment variables present on the nodes.

    ```bash
    kubectl get nodes
    kubectl node-shell {node name}
    cat /etc/environment
    ```

## Disable HTTP proxy on an existing cluster using an ARM template

### Update cluster to disable HTTP proxy

1. Update your cluster ARM template to disable HTTP proxy by setting `enabled` to `false`. The same schema used for CLI deployment exists in the `Microsoft.ContainerService/managedClusters` definition under `"properties"`, as shown in the following example:

    ```json
    "properties": {
        ...,
        "httpProxyConfig": {
           "enabled": "false",
        }
    }
    ```
2. Deploy your ARM template with HTTP Proxy disabled.

Caution

AKS automatically reimages all node pools in the cluster when you update the proxy configuration on your cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command. You can use [Pod Disruption Budgets (PDBs)](operator-best-practices-scheduler) to safeguard disruption to critical pods during reimage.

1. Verify HTTP proxy is disabled by validating that the HTTP Proxy configuration isn't set on the pods and nodes using the `kubectl describe pod` command.

    ```bash
    kubectl describe {any pod} -n kube-system
    ```

    To validate proxy variables aren't set in pods, you can check the environment variables present on the nodes.

    ```bash
    kubectl get nodes
    kubectl node-shell {node name}
    cat /etc/environment
    ```

### Re-enable HTTP proxy on an existing cluster

When you create a cluster, HTTP proxy is enabled by default. Once you disable HTTP proxy on a cluster, you can no longer add HTTP proxy configurations to that cluster.

If you want to re-enable HTTP proxy, follow the steps to Update an HTTP proxy configuration using an ARM template.

::: zone-end

## Istio add-on HTTP proxy for External Services

If you're using the [Istio-based service mesh add-on for AKS](istio-about), you must create a Service Entry to enable your applications in the mesh to access noncluster or external resources via the HTTP proxy.

For example:

```yaml
apiVersion: networking.istio.io/v1
kind: ServiceEntry
metadata:
    name: proxy
spec:
    hosts:
    - my-company-proxy.com # ignored
    addresses:
    - $PROXY_IP/32
    ports:
    - number: $PROXY_PORT
        name: tcp
        protocol: TCP
    location: MESH_EXTERNAL
```

1. Create a file and provide values for `PROXY_IP` and `PROXY_PORT`.
2. You can deploy the Service Entry using:

    ```bash
    kubectl apply -f service_proxy.yaml
    ```

## Monitoring add-on configuration

HTTP proxy with the monitoring add-on supports the following configurations:

- Outbound proxy without authentication
- Outbound proxy with trusted cert for Log Analytics endpoint

The following configuration isn't supported:

- Custom Metrics and Recommended Alerts features when using a proxy with trusted certificates