---
layout: Conceptual
title: 'Quickstart: Connect an existing Kubernetes cluster to Azure Arc - Azure Arc | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/quickstart-connect-cluster
breadcrumb_path: ../../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/146/azure-arc/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/5c778dec-0625-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: davidsmatlak
learn_banner_products:
- azure
ms.reviewer: davidsmatlak
ms.author: davidsmatlak
ms.service: azure-arc
ms.subservice: azure-arc-kubernetes
description: In this quickstart, you learn how to connect an Azure Arc-enabled Kubernetes cluster.
ms.topic: quickstart
ms.date: 2026-03-02T00:00:00.0000000Z
ms.custom: template-quickstart, mode-other, devx-track-azurecli, devx-track-azurepowershell
ms.devlang: azurecli
locale: en-us
document_id: df16df9a-a855-2512-5e26-baec15e3be88
document_version_independent_id: c77f255b-57c9-7e2d-2b10-98a8fe538376
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/quickstart-connect-cluster.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurepowershell
toc_rel: toc.json
asset_id: azure-arc/kubernetes/quickstart-connect-cluster
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/quickstart-connect-cluster.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://authoring-docs-microsoft.poolparty.biz/devrel/f7db5823-dfbf-4e94-9016-c24311b90d7e
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://authoring-docs-microsoft.poolparty.biz/devrel/a5ab72d9-1367-4994-84a6-d9964cd9936d
platformId: 409b9fa5-a995-595c-9ea1-9fb992ffeec1
---

# Quickstart: Connect an existing Kubernetes cluster to Azure Arc - Azure Arc | Microsoft Learn

Get started with Azure Arc-enabled Kubernetes by using Azure CLI or Azure PowerShell to connect an existing Kubernetes cluster to Azure Arc.

For a conceptual look at connecting clusters to Azure Arc, see [Azure Arc-enabled Kubernetes agent overview](conceptual-agent-overview). To try things out in a sample/practice experience, visit the [Azure Arc Jumpstart](https://azurearcjumpstart.com/azure_arc_jumpstart/azure_arc_k8s).

## Prerequisites

Important

In addition to these prerequisites, be sure to meet all [network requirements for Azure Arc-enabled Kubernetes](network-requirements).

# [Azure CLI](#tab/azure-cli)
- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- A basic understanding of [Kubernetes core concepts](/en-us/azure/aks/concepts-clusters-workloads).
- An [identity (user or service principal)](system-requirements#azure-ad-identity-requirements) that you can use to [sign in to Azure CLI](/en-us/cli/azure/authenticate-azure-cli) and connect your cluster to Azure Arc.
- The latest version of [Azure CLI](/en-us/cli/azure/install-azure-cli).
- The latest version of **connectedk8s** Azure CLI extension, installed by running the following command:

    ```azurecli
    az extension add --name connectedk8s
    ```
- A running Kubernetes cluster. If you don't have one, you can create a cluster by using one of these options:

    - [Kubernetes in Docker (KIND)](https://kind.sigs.k8s.io/)
    - Use Docker for [Linux](https://docs.docker.com/engine/install), [Mac](https://docs.docker.com/desktop/setup/install/mac-install/), or [Windows](https://docs.docker.com/desktop/setup/install/windows-install/)
    - Self-managed Kubernetes cluster using [Cluster API](https://cluster-api.sigs.k8s.io/user/quick-start.html)

        Note

        The cluster needs to have at least one node of operating system and architecture type `linux/amd64` and/or `linux/arm64`. See [Cluster requirements](system-requirements#cluster-requirements) for more about ARM64 scenarios.
- At least 850 MB free for the Arc agents that you deploy on the cluster, and capacity to use approximately 7% of a single CPU.
- A [kubeconfig file](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) and context pointing to your cluster. For more information, see [Configure access to multiple clusters](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/).

# [Azure PowerShell](#tab/azure-powershell)
- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- A basic understanding of [Kubernetes core concepts](/en-us/azure/aks/concepts-clusters-workloads).
- An [identity (user or service principal)](system-requirements#azure-ad-identity-requirements) that you can use to [sign in to Azure PowerShell](/en-us/powershell/azure/authenticate-azureps) and connect your cluster to Azure Arc.
- [Azure PowerShell version 6.6.0 or later](/en-us/powershell/azure/install-azure-powershell)
- The **Az.ConnectedKubernetes** Azure PowerShell module, installed by running the following command:

    ```azurepowershell
    Install-Module -Name Az.ConnectedKubernetes
    ```
- A running Kubernetes cluster. If you don't have one, you can create a cluster by using one of these options:

    - [Kubernetes in Docker (KIND)](https://kind.sigs.k8s.io/)
    - Use Docker for [Linux](https://docs.docker.com/engine/install), [Mac](https://docs.docker.com/desktop/setup/install/mac-install/), or [Windows](https://docs.docker.com/desktop/setup/install/windows-install/)
    - Self-managed Kubernetes cluster using [Cluster API](https://cluster-api.sigs.k8s.io/user/quick-start.html)

        Note

        The cluster needs to have at least one node of operating system and architecture type `linux/amd64` and/or `linux/arm64`. See [Cluster requirements](system-requirements#cluster-requirements) for more about ARM64 scenarios.
- At least 850 MB free for the Arc agents that you deploy on the cluster, and capacity to use approximately 7% of a single CPU.
- A [kubeconfig file](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) and context pointing to your cluster. For more information, see [Configure access to multiple clusters](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/).

---

## Register providers for Azure Arc-enabled Kubernetes

# [Azure CLI](#tab/azure-cli)
1. Enter the following commands:

    ```azurecli
    az provider register --namespace Microsoft.Kubernetes
    az provider register --namespace Microsoft.KubernetesConfiguration
    az provider register --namespace Microsoft.ExtendedLocation
    ```
2. Monitor the registration process. Registration can take up to 10 minutes.

    ```azurecli
    az provider show -n Microsoft.Kubernetes -o table
    az provider show -n Microsoft.KubernetesConfiguration -o table
    az provider show -n Microsoft.ExtendedLocation -o table
    ```

    When the registration finishes, the `RegistrationState` for these namespaces changes to `Registered`.

# [Azure PowerShell](#tab/azure-powershell)
1. Enter the following commands:

    ```azurepowershell
    Register-AzResourceProvider -ProviderNamespace Microsoft.Kubernetes
    Register-AzResourceProvider -ProviderNamespace Microsoft.KubernetesConfiguration
    Register-AzResourceProvider -ProviderNamespace Microsoft.ExtendedLocation
    ```
2. Monitor the registration process. Registration can take up to 10 minutes.

    ```azurepowershell
    Get-AzResourceProvider -ProviderNamespace Microsoft.Kubernetes
    Get-AzResourceProvider -ProviderNamespace Microsoft.KubernetesConfiguration
    Get-AzResourceProvider -ProviderNamespace Microsoft.ExtendedLocation
    ```

    When the registration finishes, the `RegistrationState` for these namespaces changes to `Registered`.

---

## Create a resource group

Run the following command to create a resource group for your Azure Arc-enabled Kubernetes cluster. In this example, the resource group is named AzureArcTest and is created in the EastUS region.

# [Azure CLI](#tab/azure-cli)
```azurecli
az group create --name AzureArcTest --location EastUS --output table
```

Output:

```output
Location    Name
----------  ------------
eastus      AzureArcTest
```

# [Azure PowerShell](#tab/azure-powershell)
```azurepowershell
New-AzResourceGroup -Name AzureArcTest -Location EastUS
```

Output:

```output
ResourceGroupName : AzureArcTest
Location          : eastus
ProvisioningState : Succeeded
Tags              :
ResourceId        : /subscriptions/aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e/resourceGroups/AzureArcTest
```

---

## Connect an existing Kubernetes cluster

Run the following command to connect your cluster. This command deploys the Azure Arc agents to the cluster and installs Helm v3.6.3 to the `.azure` folder of the deployment machine. This Helm 3 installation is only used for Azure Arc, and it doesn't remove or change any previously installed versions of Helm on the machine.

In this example, the cluster's name is AzureArcTest1.

# [Azure CLI](#tab/azure-cli)
```azurecli
az connectedk8s connect --name AzureArcTest1 --resource-group AzureArcTest
```

Output:

```output
Helm release deployment succeeded

    {
      "aadProfile": {
        "clientAppId": "",
        "serverAppId": "",
        "tenantId": ""
      },
      "agentPublicKeyCertificate": "xxxxxxxxxxxxxxxxxxx",
      "agentVersion": null,
      "connectivityStatus": "Connecting",
      "distribution": "gke",
      "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/AzureArcTest/providers/Microsoft.Kubernetes/connectedClusters/AzureArcTest1",
      "identity": {
        "principalId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
        "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
        "type": "SystemAssigned"
      },
      "infrastructure": "gcp",
      "kubernetesVersion": null,
      "lastConnectivityTime": null,
      "location": "eastus",
      "managedIdentityCertificateExpirationTime": null,
      "name": "AzureArcTest1",
      "offering": null,
      "provisioningState": "Succeeded",
      "resourceGroup": "AzureArcTest",
      "tags": {},
      "totalCoreCount": null,
      "totalNodeCount": null,
      "type": "Microsoft.Kubernetes/connectedClusters"
    }
```

Tip

If you don't specify the location parameter in the preceding command, the Azure Arc-enabled Kubernetes resource is created in the same location as the resource group. To create the Azure Arc-enabled Kubernetes resource in a different location, specify either `--location <region>` or `-l <region>` when running the `az connectedk8s connect` command.

# [Azure PowerShell](#tab/azure-powershell)
```azurepowershell
New-AzConnectedKubernetes -ClusterName AzureArcTest1 -ResourceGroupName AzureArcTest -Location eastus
```

Output:

```output
Location Name          Type
-------- ----          ----
eastus   AzureArcTest1 microsoft.kubernetes/connectedclusters
```

---

Important

If deployment fails due to a timeout error, see the [troubleshooting guide](troubleshooting#helm-timeout-error) for help with resolving the issue.

## Connect using an outbound proxy server

If your cluster is behind an outbound proxy server protects your cluster, route requests through the outbound proxy server.

# [Azure CLI](#tab/azure-cli)
1. On the deployment machine, set the environment variables needed for Azure CLI to use the outbound proxy server:

    ```bash
    export HTTP_PROXY=<proxy-server-ip-address>:<port>
    export HTTPS_PROXY=<proxy-server-ip-address>:<port>
    export NO_PROXY=<cluster-apiserver-ip-address>:<port>
    ```
2. On the Kubernetes cluster, run the connect command with the `--proxy-https` and `--proxy-http` parameters specified. If your proxy server is set up with both HTTP and HTTPS, be sure to use `--proxy-http` for the HTTP proxy and `--proxy-https` for the HTTPS proxy. If your proxy server only uses HTTP, you can use that value for both parameters.

    ```azurecli
    az connectedk8s connect --name <cluster-name> --resource-group <resource-group> --proxy-https https://<proxy-server-ip-address>:<port> --proxy-http http://<proxy-server-ip-address>:<port> --proxy-skip-range <excludedIP>,<excludedCIDR> --proxy-cert <path-to-cert-file>
    ```

    Note

    - Some network requests, such as the ones involving in-cluster service-to-service communication, need to be separated from the traffic that is routed via the proxy server for outbound communication. Use the `--proxy-skip-range` parameter to specify the CIDR range and endpoints in a comma-separated way so that any communication from the agents to these endpoints doesn't go via the outbound proxy. At a minimum, specify the CIDR range of the services in the cluster as the value for this parameter. For example, let's say `kubectl get svc -A` returns a list of services where all the services have ClusterIP values in the range `10.0.0.0/16`. Then the value to specify for `--proxy-skip-range` is `10.0.0.0/16,kubernetes.default.svc,.svc.cluster.local,.svc`.
    - Most outbound proxy environments expect `--proxy-http`, `--proxy-https`, and `--proxy-skip-range`. The `--proxy-cert` parameter is *only* required if you need to inject trusted certificates that the proxy expects into the trusted certificate store of agent pods.
    - The outbound proxy must be configured to allow websocket connections.

    For outbound proxy servers, if you're only providing a trusted certificate, run `az connectedk8s connect` with just the `--proxy-cert` parameter specified:

    ```azurecli
    az connectedk8s connect --name <cluster-name> --resource-group <resource-group> --proxy-cert <path-to-cert-file>
    ```

    If there are multiple trusted certificates, combine the certificate chain (Leaf cert, Intermediate cert, Root cert) into a single file which you pass in the `--proxy-cert` parameter.

    Tip

    - `--custom-ca-cert` is an alias for `--proxy-cert`. Use either parameter interchangeably. If you pass both parameters in the same command, the one passed last is honored.

# [Azure PowerShell](#tab/azure-powershell)
1. On the deployment machine, set the environment variables needed for Azure PowerShell to use the outbound proxy server:

    ```powershell
    $Env:HTTP_PROXY = "<proxy-server-ip-address>:<port>"
    $Env:HTTPS_PROXY = "<proxy-server-ip-address>:<port>"
    $Env:NO_PROXY = "<cluster-apiserver-ip-address>:<port>"
    ```
2. On the Kubernetes cluster, run the `connect` command with the proxy parameter specified:

    ```azurepowershell
    New-AzConnectedKubernetes -ClusterName <cluster-name> -ResourceGroupName <resource-group> -Location eastus -Proxy 'https://<proxy-server-ip-address>:<port>'
    ```

Azure PowerShell doesn't currently support passing in only the proxy certificate without proxy server endpoint details.

---

## Verify cluster connection

Verify that the cluster is connected to Azure by running the following command:

# [Azure CLI](#tab/azure-cli)
```azurecli
az connectedk8s list --resource-group AzureArcTest --output table
```

Output:

```output
Name           Location    ResourceGroup
-------------  ----------  ---------------
AzureArcTest1  eastus      AzureArcTest
```

# [Azure PowerShell](#tab/azure-powershell)
```azurepowershell
Get-AzConnectedKubernetes -ResourceGroupName AzureArcTest
```

Output:

```output
Location Name          Type
-------- ----          ----
eastus   AzureArcTest1 microsoft.kubernetes/connectedclusters
```

---

If the connection wasn't successful, see [Diagnose connection issues for Azure Arc-enabled Kubernetes clusters](diagnose-connection-issues) for troubleshooting steps.

Note

After onboarding the cluster, it can take up to ten minutes for cluster metadata (such as cluster version and number of nodes) to appear on the overview page of the Azure Arc-enabled Kubernetes resource in the Azure portal.

## View Azure Arc agents for Kubernetes

Azure Arc-enabled Kubernetes deploys several agents into the `azure-arc` namespace.

1. View these deployments and pods by using the following command:

    ```bash
    kubectl get deployments,pods -n azure-arc
    ```
2. Verify all pods are in a `Running` state.

    Output:

    ```output
     NAME                                        READY   UP-TO-DATE   AVAILABLE   AGE
     deployment.apps/cluster-metadata-operator   1/1     1            1           13d
     deployment.apps/clusterconnect-agent        1/1     1            1           13d
     deployment.apps/clusteridentityoperator     1/1     1            1           13d
     deployment.apps/config-agent                1/1     1            1           13d
     deployment.apps/controller-manager          1/1     1            1           13d
     deployment.apps/extension-manager           1/1     1            1           13d
     deployment.apps/flux-logs-agent             1/1     1            1           13d
     deployment.apps/kube-aad-proxy              1/1     1            1           13d
     deployment.apps/metrics-agent               1/1     1            1           13d
     deployment.apps/resource-sync-agent         1/1     1            1           13d
    
     NAME                                            READY   STATUS    RESTARTS   AGE
     pod/cluster-metadata-operator-9568b899c-2stjn   2/2     Running   0          13d
     pod/clusterconnect-agent-576758886d-vggmv       3/3     Running   0          13d
     pod/clusteridentityoperator-6f59466c87-mm96j    2/2     Running   0          13d
     pod/config-agent-7cbd6cb89f-9fdnt               2/2     Running   0          13d
     pod/controller-manager-df6d56db5-kxmfj          2/2     Running   0          13d
     pod/extension-manager-58c94c5b89-c6q72          2/2     Running   0          13d
     pod/flux-logs-agent-6db9687fcb-rmxww            1/1     Running   0          13d
     pod/kube-aad-proxy-67b87b9f55-bthqv             2/2     Running   0          13d
     pod/metrics-agent-575c565fd9-k5j2t              2/2     Running   0          13d
     pod/resource-sync-agent-6bbd8bcd86-x5bk5        2/2     Running   0          13d
    ```

For more information about these agents, see [Azure Arc-enabled Kubernetes agent overview](conceptual-agent-overview).

## Clean up resources

# [Azure CLI](#tab/azure-cli)
To delete the Azure Arc-enabled Kubernetes resource, along with any associated configuration resources and agents running on the cluster, use the following command:

```azurecli
az connectedk8s delete --name AzureArcTest1 --resource-group AzureArcTest
```

If the deletion process fails, use the following command to force deletion. Add `-y` to bypass the confirmation prompt:

```azurecli
az connectedk8s delete -n AzureArcTest1 -g AzureArcTest --force
```

Use this command if you experience problems when creating a new cluster deployment due to previously created resources that aren't completely removed.

Note

If you delete the Azure Arc-enabled Kubernetes resource in the Azure portal, you remove associated configuration resources, but agents running on the cluster aren't removed. For this reason, we recommend using `az connectedk8s delete` to delete the Azure Arc-enabled Kubernetes resource.

# [Azure PowerShell](#tab/azure-powershell)
You can delete the Azure Arc-enabled Kubernetes resource, any associated configuration resources, and any agents running on the cluster by using the following command:

```azurepowershell
Remove-AzConnectedKubernetes -ClusterName AzureArcTest1 -ResourceGroupName AzureArcTest
```

Note

If you delete the Azure Arc-enabled Kubernetes resource in the Azure portal, you remove associated configuration resources but agents running on the cluster aren't removed. For this reason, we recommend using `Remove-AzConnectedKubernetes` to delete the Azure Arc-enabled Kubernetes resource.

---