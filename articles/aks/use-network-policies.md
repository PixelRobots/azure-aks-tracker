---
layout: Conceptual
title: Secure Pod Traffic with Network Policies in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-network-policies
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
description: Learn how to implement network policies in AKS to control and secure pod traffic by restricting communication according to the principle of least privilege.
author: schaffererin
ms.author: schaffererin
ms.date: 2026-08-31T00:00:00.0000000Z
ms.subservice: aks-networking
ms.topic: how-to
ms.custom:
- devx-track-azurecli
- build-2025
- biannual
- aeo-round-2
zone_pivot_groups: azure-cli-or-terraform
locale: en-us
document_id: 063ca0dc-bd97-239a-ec30-bea24ffa4c18
document_version_independent_id: 4bc24888-164d-1644-ad92-931c433344c5
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-network-policies.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/use-network-policies
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-network-policies.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: b419f0fc-da6b-8de1-4731-fb573baf5dbd
---

# Secure Pod Traffic with Network Policies in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Important

Starting on **September 30, 2028**, Azure Kubernetes Service (AKS) no longer supports Azure Network Policy Manager (NPM) on **Linux** nodes. To avoid service disruptions, you need to [migrate AKS clusters running Linux nodes from NPM to Cilium Network Policy](migrate-from-npm-to-cilium-network-policy) by the end-of-support date. For more information on this retirement, see the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=500268). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

## Identify impacted clusters

To find AKS clusters with Linux node pools using Azure Network Policy Manager (NPM), run the [Azure Resource Graph query](https://portal.azure.com/?feature.customportal=false#blade/HubsExtension/ArgQueryBlade/query/Resources%20%0A%7C%20where%20type%20%3D%3D%20%22microsoft.containerservice%2Fmanagedclusters%22%20%0A%7C%20mv-expand%20agentPool%20%3D%20properties.agentPoolProfiles%20%0A%7C%20where%20agentPool.osType%20!%3D%20%22Windows%22%20%0A%7C%20extend%20netPol%20%3D%20tolower%28tostring%28properties.networkProfile.networkPolicy%29%29%20%0A%7C%20where%20netPol%20%3D%3D%20%22azure%22%20%0A%7C%20summarize%20by%20name%2C%20location%2C%20resourceGroup%2C%20netPol) that lists all AKS clusters where `agentPool.osType != "Windows"` and `properties.networkProfile.networkPolicy == "azure"`.

Important

Starting on **March 31, 2028**, Azure Kubernetes Service (AKS) no longer supports kubenet networking. To avoid service disruptions, [upgrade to Azure Container Networking Interface (CNI) Overlay networking](/en-us/azure/aks/update-azure-cni) before the end-of-support date. For more information on this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4859) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=485172). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Install a network policy engine and create Kubernetes network policies to control the flow of traffic between pods in AKS clusters by using the Azure CLI or Terraform.

## Overview of network policy

By default, all pods in an AKS cluster can send and receive traffic without limitations. To improve security, you can define rules that control the flow of traffic.

Network policy is a Kubernetes specification that defines access policies for communication between pods. When you use network policies, you define an ordered set of rules to send and receive traffic. You apply the rules to a collection of pods that match one or more label selectors.

You define the network policy rules as YAML manifests, and you can include them in wider manifests that also create a deployment or service.

## Network policy options in AKS

Azure provides three network policy engines for enforcing network policies:

- **Cilium** (for AKS clusters using [Azure CNI Powered by Cilium](azure-cni-powered-by-cilium))
- **Azure Network Policy Manager (NPM)**
- **Calico** (an open-source network and network security solution founded by [Tigera](https://www.tigera.io/))

We recommend using Cilium, which provides robust support for Kubernetes-native policies, extended features such as [Layer 7 policy](container-network-security-l7-policy-concepts) and [FQDN filtering](container-network-security-fqdn-filtering-concepts), and an eBPF-based dataplane that offers better performance, scalability, and security compared to *IPTables*-based solutions.

To enforce the specified policies, Azure NPM uses *IPTables* for Linux nodes. Policies are translated into sets of allowed and disallowed IP pairs. The system programs these pairs as `IPTable` filter rules.

## Differences between network policy engines: Cilium, Azure NPM, and Calico

| Network policy engine | Supported platforms | Supported networking options | Kubernetes specification compliance | Other features | Support |
| --- | --- | --- | --- | --- | --- |
| Cilium | Linux | Azure CNI | Supports all policy types | [FQDN](container-network-security-fqdn-filtering-concepts), L3/4, [L7](container-network-security-l7-policy-concepts) | Azure support and engineering team |
| Azure NPM | Linux | Azure CNI | Supports all policy types | N/A | Azure support and engineering team |
| Calico | Linux, Windows Server 2019, Windows Server 2022 | Azure CNI (Linux, Windows Server 2019, Windows Server 2022) and kubenet (Linux) | Supports all policy types | AKS doesn't test or support features beyond enforcement of `networking.k8s.io` policies. | Azure support and engineering team |

## Azure Network Policy Manager limitations

Azure NPM has the following limitations:

- Scaling beyond *250 nodes* and *20,000 pods* isn't supported. If you attempt to scale beyond these limits, you might experience *Out of Memory (OOM)* errors. For better scalability and IPv6 support, we recommend using or upgrading to [Azure CNI Powered by Cilium](update-azure-cni) for your network policy engine.
- IPv6 isn't supported. Otherwise, it fully supports the network policy specifications in Linux.
- Starting on September 30, 2026, Azure Kubernetes Service (AKS) no longer supports Azure Network Policy Manager (NPM) on Windows nodes.

## Known issues with Azure Network Policy Manager

You might experience temporary connectivity issues for new connections to/from pods on impacted nodes when either editing or deleting a "large enough" network policy. Hitting this race condition never impacts active connections.

If this race condition occurs for a node, the Azure NPM pod on that node enters a state where it can't update security rules, which might lead to unexpected connectivity for new connections to/from pods on the impacted node. To mitigate the issue, the Azure NPM pod automatically restarts ~15 seconds after entering this state. While Azure NPM is rebooting on the impacted node, it deletes all security rules, then reapplies security rules for all network policies. While all the security rules are being reapplied, there's a chance of temporary, unexpected connectivity for new connections to/from pods on the impacted node.

To limit the chance of hitting this race condition, you can reduce the size of the network policy. This issue is most likely to happen for a network policy with several `ipBlock` sections. A network policy with *four or fewer*`ipBlock` sections is less likely to hit the issue.

## Calico limitations

- AKS doesn't support running AKS-managed Calico alongside Calico Cloud or Calico Enterprise, as this combination can cause conflicts and unintended behavior. If you use Calico Cloud or Enterprise, Microsoft strongly recommends disabling AKS-managed Calico. Contact Tigera for support with those products.
- AKS-managed Calico only supports `networking.k8s.io` network policies. If you intend to use `projectcalico.org/v3` policies, consider migrating to a self-hosted solution, such as Calico Cloud, Calico Enterprise, or BYOCNI.

## Load balancer services and network policies

Kubernetes service routing for both inbound and outbound services often involves rewriting the source and destination IPs on traffic that's being processed, including traffic that comes into the cluster from a `LoadBalancer` service. This rewrite behavior means that the network policies might not properly process traffic being received from or sent to an external service. For more information, see the [Kubernetes Network Policies documentation](https://kubernetes.io/docs/concepts/services-networking/network-policies/).

To restrict what sources can send traffic to a load balancer service, use `spec.loadBalancerSourceRanges` to configure traffic blocking that applies before any rewrites occur. For more information, see the [AKS Standard load balancer documentation](/en-us/azure/aks/load-balancer-standard#restrict-inbound-traffic-to-specific-ip-ranges).

## Before you begin

::: zone pivot="azure-cli"

You need the Azure CLI version 2.0.61 or later installed and configured. Find the version using the `az --version` command. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

Instead of using a system-assigned identity, you can also use a user-assigned identity. For more information, see [Use managed identities](use-managed-identity).

::: zone-end

::: zone pivot="terraform"

- [Terraform installed](https://developer.hashicorp.com/terraform/install), version 1.6 or later.
- Azure CLI installed and authenticated. Find the version using the `az --version` command. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli). You use the Azure CLI to connect to the cluster after Terraform creates it.
- [kubectl](https://kubernetes.io/releases/download/) installed. You can install it locally using the [`az aks install-cli`](/en-us/cli/azure/aks#az-aks-install-cli) command. You use `kubectl` to verify the network policy behavior.

::: zone-end

::: zone pivot="azure-cli"

## Create an AKS cluster with Azure Network Policy Manager (Linux)

1. Set environment variables for the resource group name, cluster name, and location. Replace the values as needed.

    ```bash
    export RESOURCE_GROUP=myResourceGroup
    export CLUSTER_NAME=myAKSCluster
    export LOCATION=eastus
    ```
2. Create the resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    az group create --resource-group $RESOURCE_GROUP --location $LOCATION
    ```
3. Create an AKS cluster using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) and specify `azure` for the `network-plugin` and `network-policy`.

    ```azurecli
    az aks create \
        --resource-group $RESOURCE_GROUP \
        --name $CLUSTER_NAME \
        --node-count 1 \
        --network-plugin azure \
        --network-policy azure \
        --generate-ssh-keys
    ```

Caution

Azure Network Policy Manager (NPM) for Linux nodes will be retired on September 30, 2028. For new deployments, we recommend using [Azure CNI Powered by Cilium](azure-cni-powered-by-cilium) with Cilium Network Policy. To migrate existing clusters, see [Migrate from NPM to Cilium Network Policy](migrate-from-npm-to-cilium-network-policy).

## Create an AKS cluster with Calico

Create an AKS cluster by using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command. Specify `--network-plugin azure` and `--network-policy calico`. When you specify `--network-policy calico`, you enable Calico on both Linux and Windows node pools.

If you plan to add Windows node pools to your cluster, include the `windows-admin-username` and `windows-admin-password` parameters that meet the [Windows Server password requirements](/en-us/windows/security/threat-protection/security-policy-settings/password-must-meet-complexity-requirements#reference). To create a username to use as administrator credentials for your Windows Server containers on your cluster, the following command prompts you for a username. Set it to WINDOWS\_USERNAME.

```bash
echo "Please enter the username to use as administrator credentials for Windows Server containers on your cluster: " && read WINDOWS_USERNAME
```

Important

At this time, using Calico network policies with Windows nodes is available on new clusters using Kubernetes version 1.20 or later with Calico 3.17.2 and requires that you use Azure CNI networking. Windows nodes on AKS clusters with Calico enabled also have Floating IP enabled by default.

For clusters with only Linux node pools running Kubernetes 1.20 with earlier versions of Calico, the Calico version automatically upgrades to 3.17.2.

## Install Azure Network Policy Manager or Calico on an existing cluster

Warning

Keep the following information in mind when installing Azure NPM or Calico on an existing cluster:

- The upgrade process triggers each node pool to be reimaged simultaneously. Upgrading each node pool separately isn't supported.
- Within each node pool, nodes follow the same reimaging process as standard Kubernetes version upgrade operations. This behavior means that buffer nodes are temporarily added to minimize disruption to running applications during the node reimaging process. Any disruptions that might occur are similar to what you might encounter during a node image upgrade or [Kubernetes version upgrade](upgrade-cluster).

The following information applies to upgrades from kubenet with Calico to Azure CNI Overlay with Calico:

- In kubenet clusters with Calico enabled, Calico is used as both a CNI and network policy engine.
- In Azure CNI clusters, Calico is used only for network policy enforcement, not as a CNI. This can cause a short delay between when the pod starts and when Calico allows outbound traffic from the pod.

Update an existing cluster to install Azure NPM or Calico using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command and specifying `azure` or `calico` for the `--network-policy` parameter. The following example command shows how to install either Azure NPM:

```azurecli
az aks update \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --network-policy azure
```

## Upgrade an existing cluster with Azure NPM or Calico to Cilium

For clusters that already use Azure CNI, update the network data plane to Cilium. Kubenet clusters must first migrate to Azure CNI Overlay and then update the network data plane to Cilium as a separate operation. Review the prerequisites and follow the steps in [Upgrade an existing cluster to Azure CNI Powered by Cilium](upgrade-aks-ipam-and-dataplane).

## Connect to the AKS cluster

Configure `kubectl` to connect to your cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command. This command downloads credentials and configures the Kubernetes CLI to use them.

```azurecli
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
```

## Verify network policy setup

To begin verification of network policy, you create a sample application and set traffic rules.

1. Create a namespace named `demo` to run the sample pods using the `kubectl create namespace` command.

    ```bash
    kubectl create namespace demo
    ```
2. Create a pod named `server` to serve on TCP port 80 using the `kubectl run` command.

    ```bash
    kubectl run server -n demo --image=k8s.gcr.io/e2e-test-images/agnhost:2.33 --labels="app=server" --port=80 --command -- /agnhost serve-hostname --tcp --http=false --port "80"
    ```
3. Create a pod named `client` to run Bash using the `kubectl run` command.

    ```bash
    kubectl run -it client -n demo --image=k8s.gcr.io/e2e-test-images/agnhost:2.33 --command -- bash
    ```

    Note

    If you want to schedule the client or server on a particular node, add the following bit before the `--command` argument in the pod creation [`kubectl run`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#run) command: `--overrides='{"spec": { "nodeSelector": {"kubernetes.io/os": "linux|windows"}}}'`.
4. In a separate window, get the IP address of the `server` pod using the `kubectl get pod` command.

    ```bash
    kubectl get pod --output=wide -n demo
    ```

    Your output should resemble the following example output:

    ```output
    NAME     READY   STATUS    RESTARTS   AGE   IP            NODE             NOMINATED NODE   READINESS GATES
    server   1/1     Running   0          30s   10.224.0.72   akswin22000001   <none>           <none>
    ```

## Test connectivity with network policies

Tip

To test connectivity without network policies, run the following command in the client shell: `/agnhost connect <server-ip>:80 --timeout=3s --protocol=tcp`. Replace `<server-ip>` with the IP address of the server pod. If the connection is successful, there's no output.

1. Create a file named `demo-policy.yaml` and paste the following YAML manifest:

    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: demo-policy
      namespace: demo
    spec:
      podSelector:
        matchLabels:
          app: server
      ingress:
      - from:
        - podSelector:
            matchLabels:
              app: client
        ports:
        - port: 80
          protocol: TCP
    ```
2. Apply the network policy manifest using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command.

    ```bash
    kubectl apply -f demo-policy.yaml
    ```
3. In the client shell, verify connectivity with the server using the following `/agnhost` command:

    ```bash
    /agnhost connect <server-ip>:80 --timeout=3s --protocol=tcp
    ```

    Connectivity with traffic is blocked because the server is labeled with `app=server`, but the client isn't labeled. Your output should resemble the following example output:

    ```output
    TIMEOUT
    ```
4. Label the `client` and verify connectivity with the server using the `kubectl label` command.

    ```bash
    kubectl label pod client -n demo app=client
    ```

    If the connection is successful, there's no output.

## Migrate to self-managed Calico

AKS only supports Calico for standard Kubernetes network policies and doesn't test other features. If you want to move to self-managed Calico, follow the Tigera instructions at [Migrate from Azure-managed Calico to self-managed Calico](https://docs.tigera.io/calico/latest/getting-started/kubernetes/managed-public-cloud/aks-migrate). The Tigera documentation mentions that for self-managed Calico you set `--network-policy none` like in the uninstall section.

## Uninstall Azure Network Policy Manager or Calico

Note

Keep the following information in mind when uninstalling Azure NPM or Calico from a cluster:

- The uninstall process **doesn't remove** Custom Resource Definitions (CRDs) and Custom Resources (CRs) used by Calico. These CRDs and CRs all have names ending with either *projectcalico.org* or *tigera.io*. You can manually remove these CRDs and associated CRs *after* successfully uninstalling Calico.
- The upgrade doesn't remove any network policy resources in the cluster, but the policies are no longer enforced after the uninstall process.

Remove Azure Network Policy Manager or Calico from an existing cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command and specifying `none` for the `--network-policy` parameter.

```azurecli
az aks update \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --network-policy none
```

## Change cluster network policy

The following steps show how to change a cluster's existing network policy to Calico. The procedure requires that the network policy is changed to `none` and then changed to `calico`.

The commands use variables specified earlier in this article Create an AKS cluster with Azure Network Policy Manager (Linux). Otherwise, replace `$RESOURCE_GROUP` and `$CLUSTER_NAME` with your cluster's resource group and name.

1. Run the following command to show the cluster's existing network policy.

    ```azurecli
    az aks show \
      --resource-group $RESOURCE_GROUP \
      --name $CLUSTER_NAME \
      --query "networkProfile" \
      --output table
    ```
2. Run the following command to set the network policy to `none`.

    ```azurecli
    az aks update --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --network-policy none
    ```
3. Run the following command to set the network policy to `calico`.

    ```azurecli
    az aks update --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --network-policy calico
    ```

## Clean up resources

In this article, you created a namespace and two pods and applied a network policy. If you no longer need these resources, you can delete them.

Delete the resources using the [`kubectl delete`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#delete) command.

```bash
kubectl delete namespace demo
```

If you followed this article's steps to create an AKS cluster, use the [`az group delete`](/en-us/cli/azure/group#az-group-delete) command to delete the AKS resource group and its related resource group with a name that begins with `MC_`.

```azurecli
az group delete --resource-group $RESOURCE_GROUP --no-wait --yes
```

::: zone-end

::: zone pivot="terraform"

## Create an AKS cluster with Cilium network policy using Terraform

This section shows how to use Terraform to deploy an AKS cluster that uses [Azure CNI Powered by Cilium](azure-cni-powered-by-cilium) for networking and network policy enforcement, and then use a Kubernetes `NetworkPolicy` resource to control pod-to-pod traffic.

Note

The sample code for this section is located in the [Azure Terraform GitHub repo](https://github.com/Azure/terraform/tree/master/quickstart/101-aks-network-policy-cilium). You can view the log file containing the [test results from current and previous versions of Terraform](https://github.com/Azure/terraform/tree/master/quickstart/101-aks-network-policy-cilium/TestRecord.md).

See more [articles and sample code showing how to use Terraform to manage Azure resources](/en-us/azure/terraform).

This sample deploys:

- A resource group.
- An AKS cluster that uses Azure CNI Overlay networking with Cilium as the network policy engine and network dataplane.

1. Create a directory to test and run the sample Terraform code, and make it the current directory.
2. Create a file named `main.tf`, and insert the following code:

    ```terraform
    terraform {
      required_version = ">= 1.6.0"
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~> 4.0"
        }
      }
    }
    
    provider "azurerm" {
      features {}
    }
    
    resource "azurerm_resource_group" "example" {
      name     = "rg-aks-network-policy-example"
      location = "eastus"
    }
    
    resource "azurerm_kubernetes_cluster" "example" {
      name                = "aks-network-policy-example"
      location            = azurerm_resource_group.example.location
      resource_group_name = azurerm_resource_group.example.name
      dns_prefix          = "aksnetpolicyexample"
    
      default_node_pool {
        name       = "default"
        node_count = 1
        vm_size    = "Standard_D2s_v3"
    
        upgrade_settings {
          drain_timeout_in_minutes      = 0
          max_surge                     = "10%"
          node_soak_duration_in_minutes = 0
        }
      }
    
      identity {
        type = "SystemAssigned"
      }
    
      network_profile {
        network_plugin      = "azure"
        network_plugin_mode = "overlay"
        network_policy      = "cilium"
        network_data_plane  = "cilium"
        load_balancer_sku   = "standard"
      }
    }
    ```
3. Initialize Terraform by running the [`terraform init`](https://www.terraform.io/docs/commands/init.html) command. This command downloads the Azure provider required to manage Azure resources with Terraform.

    ```console
    terraform init
    ```
4. Format and validate the configuration by running the `terraform fmt` and `terraform validate` commands.

    ```console
    terraform fmt
    terraform validate
    ```
5. Create a Terraform execution plan by running the [`terraform plan`](https://www.terraform.io/docs/commands/plan.html) command. This command shows you the resources that Terraform creates or modifies in your Azure subscription.

    ```console
    terraform plan
    ```
6. Apply the Terraform execution plan by running the [`terraform apply`](https://www.terraform.io/docs/commands/apply.html) command. This command creates the resources defined in your `main.tf` file in your Azure subscription.

    ```console
    terraform apply
    ```

## Connect to the AKS cluster using Terraform

1. Install the Kubernetes command-line tool by running the [`az aks install-cli`](/en-us/cli/azure/aks#az-aks-install-cli) command, and then verify the installation.

    ```azurecli
    az aks install-cli
    kubectl version --client
    ```
2. Configure `kubectl` to connect to your cluster by running the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command. This command downloads credentials and configures the Kubernetes CLI to use them.

    ```azurecli
    az aks get-credentials \
        --resource-group rg-aks-network-policy-example \
        --name aks-network-policy-example
    ```
3. Verify the cluster is running by running the `kubectl get nodes` command.

    ```bash
    kubectl get nodes
    ```

## Verify network policy setup using Terraform

To verify the network policy setup, create a sample application and set traffic rules.

1. Create a namespace named `demo` to run the sample pods by using the `kubectl create namespace` command.

    ```bash
    kubectl create namespace demo
    ```
2. Create a pod named `server` to serve on TCP port 80 by running the [`kubectl run`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#run) command.

    ```bash
    kubectl run server \
      -n demo \
      --image=k8s.gcr.io/e2e-test-images/agnhost:2.33 \
      --labels="app=server" \
      --port=80 \
      --command -- /agnhost serve-hostname --tcp --http=false --port "80"
    ```
3. Create a pod named `client` to run Bash by using the `kubectl run` command.

    ```bash
    kubectl run -it client \
      -n demo \
      --image=k8s.gcr.io/e2e-test-images/agnhost:2.33 \
      --command -- bash
    ```
4. In a separate window, get the IP address of the `server` pod by using the `kubectl get pod` command.

    ```bash
    kubectl get pod --output=wide -n demo
    ```

    Use the `server` pod IP address when you test connectivity from the `client` shell in the next section.

## Test connectivity with network policies using Terraform

The sample includes a Kubernetes `NetworkPolicy` manifest that allows ingress traffic to pods labeled `app=server` only from pods labeled `app=client` on TCP port 80.

1. Create a file named `network-policy.yaml`, and insert the following code:

    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: demo-policy
      namespace: demo
    spec:
      podSelector:
        matchLabels:
          app: server
      policyTypes:
        - Ingress
      ingress:
        - from:
            - podSelector:
                matchLabels:
                  app: client
          ports:
            - protocol: TCP
              port: 80
    ```
2. Apply the network policy by using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command.

    ```bash
    kubectl apply -f network-policy.yaml
    ```
3. In the `client` shell, test connectivity to the server by using the following `/agnhost` command:

    ```bash
    /agnhost connect <server-ip>:80 --timeout=3s --protocol=tcp
    ```

    Connectivity is blocked because the server is labeled with `app=server`, but the client isn't labeled. Your output should resemble the following example output:

    ```output
    TIMEOUT
    ```
4. Label the `client` and verify connectivity with the server by using the `kubectl label` command.

    ```bash
    kubectl label pod client -n demo app=client
    ```
5. In the `client` shell, test connectivity to the server again by using the same `/agnhost` command:

    ```bash
    /agnhost connect <server-ip>:80 --timeout=3s --protocol=tcp
    ```

    If the connection is successful, there's no output.
6. Verify the network policy by using the `kubectl get networkpolicy` and `kubectl describe networkpolicy` commands.

    ```bash
    kubectl get networkpolicy -n demo
    kubectl describe networkpolicy demo-policy -n demo
    ```

    The output shows that pods labeled `app=server` are selected, ingress traffic is allowed on TCP port 80, and only pods labeled `app=client` can initiate connections.

## Clean up resources by using Terraform

In this section, you created a namespace, two pods, and a network policy. If you no longer need these Kubernetes resources, delete them before you remove the underlying Azure infrastructure.

Use the [`kubectl delete`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#delete) command to delete the resources.

```bash
kubectl delete namespace demo
```

Warning

The following command removes the resource group, the AKS cluster, and all other resources associated with the resource group created for this sample. If you deployed other resources inside this resource group, the command deletes them too.

Remove the Azure resources by using the [`terraform destroy`](https://www.terraform.io/docs/commands/destroy.html) command.

```console
terraform destroy
```

::: zone-end