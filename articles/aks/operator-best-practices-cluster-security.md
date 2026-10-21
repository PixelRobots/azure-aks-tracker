---
layout: Conceptual
title: Best Practices for Cluster Security in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/operator-best-practices-cluster-security
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
description: Learn cluster operator best practices for securing clusters and managing upgrades in Azure Kubernetes Service (AKS), including guidance for AKS Automatic and AKS Standard.
ms.topic: best-practice
ms.subservice: aks-security
ms.custom: linux-related-content
ms.date: 2026-06-04T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 201239e2-c1ae-989b-b279-9ea4838791d9
document_version_independent_id: d2ba1dbb-442a-c37a-f35e-9032606275bb
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/operator-best-practices-cluster-security.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,azurepowershell
toc_rel: toc.json
asset_id: aks/operator-best-practices-cluster-security
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/operator-best-practices-cluster-security.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/fcc3cd4a-59ea-47a2-9cc1-784142a5a25d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7a55faf-a992-4e27-aa3a-eadc9830e778
platformId: 1ddae540-9865-0f6d-d1b1-675fbd35ee73
---

# Best Practices for Cluster Security in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

**Applies to**: ✔️ AKS Automatic ✔️ AKS Standard

As you manage clusters in Azure Kubernetes Service (AKS), workload and data security is a key consideration. When you run multi-tenant clusters using logical isolation, you especially need to secure resource and workload access. Minimize the risk of attack by applying the latest Kubernetes and node OS security updates.

This article focuses on how to secure your AKS cluster. You learn how to:

- Use Microsoft Entra ID and Kubernetes role-based access control (Kubernetes RBAC) to secure API server access.
- Secure container access to node resources.
- Upgrade an AKS cluster to the latest Kubernetes version.
- Keep nodes up to date and automatically apply security patches.

You can also read the best practices for [container image management](operator-best-practices-container-image-management) and for [pod security](developer-best-practices-pod-security).

## AKS cluster mode security responsibilities

AKS supports two cluster modes: [**AKS Automatic**](intro-aks-automatic) and **AKS Standard**. Security objectives are the same in both modes, but implementation responsibility differs.

AKS Automatic includes a hardened baseline with more preconfigured controls in supported configurations. AKS Standard provides broader direct configuration control, which increases operator responsibility for baseline setup and ongoing operations.

| Area | AKS Automatic | AKS Standard |
| --- | --- | --- |
| Cluster authentication and authorization baseline | More preconfigured defaults in supported configurations | Commonly configured explicitly by operators |
| API server network hardening | More preconfigured baseline behavior in supported configurations | Explicit hardening choices by operators |
| Policy and baseline security controls | More preconfigured defaults in supported configurations | Explicit policy enablement and mode selection |
| Image hygiene controls | Baseline controls available in supported configurations | Explicit enablement and lifecycle ownership |
| System node pool operations | More service-managed behavior | More operator-managed behavior |
| Upgrade ownership | More managed upgrade defaults | Operator-selected strategy and rollout governance |

## Enable threat protection

> 
> **Best practice guidance**
> 
> You can enable [Defender for Containers](/en-us/azure/defender-for-cloud/defender-for-containers-introduction) to help secure your containers. Defender for Containers can assess cluster configurations and provide security recommendations, run vulnerability scans, and provide real-time protection and alerting for Kubernetes nodes and clusters.

This guidance applies to both modes. Even when AKS Automatic provides preconfigured security defaults, threat protection onboarding and alert-response workflows remain operational responsibilities for your team.

## Secure access to the API server and cluster nodes

> 
> **Best practice guidance**
> 
> One of the most important ways to secure your cluster is to secure access to the Kubernetes API server. To control access to the API server, integrate Kubernetes RBAC with Microsoft Entra ID. With these controls,you secure AKS the same way that you secure access to your Azure subscriptions.

The Kubernetes API server provides a single connection point for requests to perform actions within a cluster. To secure and audit access to the API server, limit access and provide the lowest possible permission levels. while this approach isn't unique to Kubernetes, it's especially important when you've logically isolated your AKS cluster for multi-tenant use.

Microsoft Entra ID provides an enterprise-ready identity management solution that integrates with AKS clusters. Since Kubernetes doesn't provide an identity management solution, you may be hard-pressed to granularly restrict access to the API server. With Microsoft Entra integrated clusters in AKS, you use your existing user and group accounts to authenticate users to the API server.

![Microsoft Entra integration for AKS clusters](media/operator-best-practices-cluster-security/aad-integration.png)

Using Kubernetes RBAC and Microsoft Entra ID-integration, you can secure the API server and provide the minimum permissions required to a scoped resource set, like a single namespace. You can grant different Microsoft Entra users or groups different Kubernetes roles. With granular permissions, you can restrict access to the API server and provide a clear audit trail of actions performed.

In AKS Automatic, authorization and security baselines are more preconfigured in supported configurations, so operators focus on validation, governance, and exception handling. In AKS Standard, operators commonly configure these controls directly and maintain their lifecycle posture.

For more information about Microsoft Entra integration, Kubernetes RBAC, and Azure RBAC, see [Best practices for authentication and authorization in AKS](concepts-identity).

## Restrict access to Instance Metadata API

> 
> **Best practice guidance**
> 
> Add a network policy in all user namespaces to block pod egress to the metadata endpoint.

Note

To implement Network Policy, include the attribute `--network-policy azure` when creating the AKS cluster. Use the following command to create the cluster: `az aks create -g myResourceGroup -n myManagedCluster --network-plugin azure --network-policy azure --generate-ssh-keys`

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: restrict-instance-metadata
spec:
  podSelector:
    matchLabels: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: 10.10.0.0/0#example
        except:
        - 169.254.169.254/32
```

In AKS Standard, make sure your selected network model and policy engine support this policy path. In AKS Automatic, apply equivalent namespace-level egress restrictions where supported in your cluster configuration.

## Secure container access to resources

> 
> **Best practice guidance**
> 
> Limit access to actions that containers can perform. Provide the least number of permissions, and avoid the use of root access or privileged escalation.

In the same way that you should grant users or groups the minimum privileges required, you should also limit containers to only necessary actions and processes. To minimize the risk of attack, avoid configuring applications and containers that require escalated privileges or root access.

Using user-namespaces, you improve the host isolation and limit the lateral movement in case of container breakouts. These improvements are significant whether the pod is running as root or not.

For even more granular control of container actions, you can also use built-in Linux security features such as *AppArmor* and *seccomp*.

Even when AKS Automatic provides hardened defaults, workload-level security controls remain application and platform team responsibilities.

For more information, see [Secure container access to resources](secure-container-access).

## Regularly update to the latest version of Kubernetes

> 
> **Best practice guidance**
> 
> To stay current on new features and bug fixes, regularly upgrade the Kubernetes version in your AKS cluster.

Kubernetes releases new features at a quicker pace than more traditional infrastructure platforms. Kubernetes updates include:

- New features
- Bug or security fixes

New features typically move through *alpha* and *beta* status before they become *stable*. Once stable, are generally available and recommended for production use. Kubernetes new feature release cycle allows you to update Kubernetes without regularly encountering breaking changes or adjusting your deployments and templates.

AKS supports three minor versions of Kubernetes. Once a new minor patch version is introduced, the oldest minor version and patch releases supported are retired. Minor Kubernetes updates happen on a periodic basis. To stay within support, ensure you have a governance process to check for necessary upgrades. For more information, see [Supported Kubernetes versions AKS](supported-kubernetes-versions).

In AKS Automatic, upgrade-related behavior is more preconfigured in supported configurations, and operators should focus on workload readiness validation and release governance. In AKS Standard, operators choose and govern upgrade strategy and rollout timing more directly.

# [Azure CLI](#tab/azure-cli)
To check the versions that are available for your cluster, use the [`az aks get-upgrades`](/en-us/cli/azure/aks#az-aks-get-upgrades) command as shown in the following example:

```azurecli
az aks get-upgrades --resource-group myResourceGroup --name myAKSCluster --output table
```

You can then upgrade your AKS cluster using the [`az aks upgrade`](/en-us/cli/azure/aks#az-aks-upgrade) command. The upgrade process safely:

- Cordons and drains one node at a time.
- Schedules pods on remaining nodes.
- Deploys a new node running the latest OS and Kubernetes versions.

# [Azure PowerShell](#tab/azure-powershell)
To check the versions that are available for your cluster, use the [`Get-AzAksUpgradeProfile`](/en-us/powershell/module/az.aks/get-azaksupgradeprofile) cmdlet as shown in the following example:

```azurepowershell
Get-AzAksUpgradeProfile -ResourceGroupName myResourceGroup -ClusterName myAKSCluster |
Select-Object -Property Name, ControlPlaneProfileKubernetesVersion -ExpandProperty ControlPlaneProfileUpgrade |
Format-Table -Property *
```

You can then upgrade your AKS cluster using the [`Set-AzAksCluster`](/en-us/powershell/module/az.aks/set-azakscluster) cmdlet. The upgrade process safely:

- Cordons and drains one node at a time.
- Schedules pods on remaining nodes.
- Deploys a new node running the latest OS and Kubernetes versions.

---

Important

Test new minor versions in a dev test environment and validate that your workload remains healthy with the new Kubernetes version.

Kubernetes might deprecate APIs (like in version 1.16) that your workloads rely on. When bringing new versions into production, consider using [multiple node pools on separate versions](create-node-pools) and upgrade individual pools one at a time to progressively roll the update across a cluster. If running multiple clusters, upgrade one cluster at a time to progressively monitor for impact or changes.

For more information about upgrades in AKS, see [Supported Kubernetes versions in AKS](supported-kubernetes-versions) and [Upgrade an AKS cluster](upgrade-cluster).

## Process Linux node updates

Each evening, Linux nodes in AKS get security patches through their distro update channel. This behavior is automatically configured as the nodes are deployed in an AKS cluster. To minimize disruption and potential impact to running workloads, nodes are not automatically rebooted if a security patch or kernel update requires it. For more information about how to handle node reboots, see [Apply security and kernel updates to nodes in AKS](node-updates-kured).

In AKS Automatic, node update behavior is more preconfigured in supported configurations. In AKS Standard, operators commonly define patch and reboot governance with explicit operational controls.

### Node image upgrades

Unattended upgrades apply updates to the Linux node OS, but the image used to create nodes for your cluster remains unchanged. If a new Linux node is added to your cluster, the original image is used to create the node. This new node will receive all the security and kernel updates available during the automatic check every night but will remain unpatched until all checks and restarts are complete. You can use node image upgrade to check for and update node images used by your cluster. For more information on node image upgrade, see [Azure Kubernetes Service (AKS) node image upgrade](node-image-upgrade).

## Process Windows Server node updates

For Windows Server nodes, regularly perform a node image upgrade operation to safely cordon and drain pods and deploy updated nodes.