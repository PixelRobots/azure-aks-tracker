---
layout: Conceptual
title: Secure your workloads in Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/conceptual-secure-your-workloads
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
ms.date: 2026-08-28T00:00:00.0000000Z
ms.topic: concept-article
description: Guidance for securing workloads running on Azure Arc-enabled Kubernetes clusters, including application and container security.
locale: en-us
document_id: 18af8768-332b-0c47-cc52-b3e362d241aa
document_version_independent_id: 101bbe98-aa74-de7e-b3c9-a8971ffb3f0e
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/conceptual-secure-your-workloads.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/conceptual-secure-your-workloads
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/conceptual-secure-your-workloads.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 2f9be847-53d6-9d8c-ebcc-04d5f81e53f2
---

# Secure your workloads in Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn

Securing your workloads involves building, deploying, and running containers in ways that help reduce risk and align with industry standards. This article provides guidance on container security, pod security standards, and workload identity, helping you protect your applications from supply chain risks, unauthorized access, and runtime threats within and outside your clusters.

## Follow a secure container lifecycle as you acquire, catalog, and build your containers

Follow the [Microsoft Containers Secure Supply Chain framework](/en-us/azure/security/container-secure-supply-chain/articles/container-secure-supply-chain-implementation/containers-secure-supply-chain-overview) as you acquire, catalog, and build your workloads. This framework helps you better protect against untrusted sources, avoid compromised dependencies, and scan for vulnerabilities.

Track code provenance by obtaining or generating a Software Bill of Materials (SBOM). You can also configure [Microsoft Defender for Containers](/en-us/azure/defender-for-cloud/defender-for-containers-introduction#vulnerability-assessment) to help perform a vulnerability assessment of images in your container registry – see the [support matrix](/en-us/azure/defender-for-cloud/support-matrix-defender-for-containers?tabs=extva%2Cazurert%2Cazurespm%2Cawsnet#vulnerability-assessment-va-features) for which registries are supported at what level (preview or general availability).

More generally, we recommend you follow the [Security Development Lifecycle](https://www.microsoft.com/securityengineering/sdl) as you develop your workload application software.

See also [our guidance](conceptual-secure-your-operations#follow-a-secure-container-lifecycle-as-you-deploy-and-run-containers-with-azure-policy-for-kubernetes) on how to follow the Secure Supply Chain framework as you deploy and run your workloads.

### References

- [CIS Kubernetes Benchmark - Sections 1, 2, and 4](https://www.cisecurity.org/benchmark/kubernetes)
- [NIST Application Container Security Guide - Section 4.5.1-3](https://csrc.nist.gov/pubs/sp/800/190/final)
- [Kubernetes Security - OWASP Cheat Sheet Series – "Implement continuous vulnerability scanning"](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes_Security_Cheat_Sheet.html)

## Prepare your container images for hardened Kubernetes environments

To help promote the execution of container images with least privileges at runtime, author your container images to support nonroot execution of workloads.

Use distroless and purpose-built container images that narrowly satisfy the necessary runtime components. You can choose base images for your workloads from a reputable vendor such as from the [Microsoft Artifact Registry](https://mcr.microsoft.com/). Narrowing your runtime dependencies helps both reduce the potential attack surface on ancillary components and the maintenance burden resulting from security updates and bug fixes. Use multi-stage builds to further reduce the footprint of your runtime images.

Use [container signing](/en-us/azure/container-registry/container-registry-tutorial-sign-trusted-ca) to help ensure your workload images aren't accidentally or maliciously tampered with. Azure Pipelines and GitHub Actions provide various tooling in support of container signing. You can integrate container signing with your chosen Public Key Infrastructure (PKI).

### References

- [NSA Kubernetes Hardening Guidance – "Nonroot containers and rootless container engine" and æBuild secure container images"](https://media.defense.gov/2022/Aug/29/2003066362/-1/-1/0/CTR_KUBERNETES_HARDENING_GUIDANCE_1.2_20220829.PDF)
- [Kubernetes Security - OWASP Cheat Sheet Series – "Build Phase"](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes_Security_Cheat_Sheet.html)

## Follow pod security standards

Follow the Kubernetes [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/) for your pods, aiming for the restricted policy level where possible, and the baseline level otherwise. For example, your containers should run as a nonroot user and shouldn't mount host volumes, unless it's strictly necessary for their operation. See [our suggestions](conceptual-secure-your-operations#follow-a-secure-container-lifecycle-as-you-deploy-and-run-containers-with-azure-policy-for-kubernetes) about how you can help enforce these standards. Not all Microsoft-supplied extensions are themselves able to meet the most restricted policy level, due to the privileged operations they perform. They might require extra capabilities to be permitted when deployed.

In addition, consider [setting memory limits and CPU requests](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) for each pod (though not CPU limits which can lead to undesirable throttling). Also consider resource quotas for each namespace. These limits and quotas can prevent broader Denial of Service (DoS) attacks from a container that is compromised or otherwise misbehaving.

### References

- [Pod Security Standards | Kubernetes](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
- [Sections 5.2 of the CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes)
- [NSA Kubernetes Hardening Guidance – "Pod security enforcement" and "Resource Policies"](https://media.defense.gov/2022/Aug/29/2003066362/-1/-1/0/CTR_KUBERNETES_HARDENING_GUIDANCE_1.2_20220829.PDF)
- [Kubernetes Security - OWASP Cheat Sheet Series – "Apply security context" and "Limiting resource usage in a cluster"](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes_Security_Cheat_Sheet.html)

## Enforce extra Linux security standards

Consider using [extra Linux security hardening frameworks](https://kubernetes.io/docs/concepts/security/linux-kernel-security-constraints/) that offer further protections. SELinux or AppArmor require and enforce a more precise declaration of the access that each workload has to specific resources such as files and ports. These declarations go beyond the standard Linux permissions model. Further, [seccomp](https://kubernetes.io/docs/reference/node/seccomp/) restricts the system calls that each workload can make, and a default seccomp profile is required at the Restricted level of the Pod Security Standards. All these security hardening features come with default settings, but you can typically tailor things further to your specific application. For example, you can define a custom seccomp profile that allows only the precise syscalls your pods need.

### References

- [Section 4.4.3 of the NIST Application Container Security Guide](https://csrc.nist.gov/pubs/sp/800/190/final)
- [NSA Kubernetes Hardening Guidance – "Kubernetes Pod Security"](https://media.defense.gov/2022/Aug/29/2003066362/-1/-1/0/CTR_KUBERNETES_HARDENING_GUIDANCE_1.2_20220829.PDF)

## Use workload identity for accessing Azure resources

Your workloads should use [workload identity federation](/en-us/azure/azure-arc/kubernetes/workload-identity) to securely access your resources in Azure, such as a storage account. This approach helps you avoid creating and distributing separate secrets to authenticate the Entra ID identities used for authorization with Azure RBAC. Instead, this federation approach enables you to obtain a token for an Entra ID identity in the cloud directly from a Kubernetes service account token. Service accounts are Kubernetes' built-in identity for workloads.

Your cluster's service account token issuer creates and signs these service account tokens. The issuer's private key is a fundamental secret. You should restrict access to it and rotate it regularly.

If you're running AKS enabled by Azure Arc on Azure Local, this access control is automatically managed. Only the control plane nodes that run the API server, which includes the token issuer, can access the keys. The keys expire after 90 days, and they're rotated automatically every 45 days.

If you connect your own cluster via Arc-enabled Kubernetes, evaluate if your vendor's product offers similar capabilities. Check if they restrict access to the service account token issuer key and if they rotate it regularly.

## Configure TLS encryption and authentication within/to/from workloads

Use TLS for all connections that your workloads make, both inside and outside of the cluster. Using TLS may require you to generate certificates and distribute trust bundles for use in establishing these connections.

For TLS connections within a cluster, evaluate using a service mesh such as [Istio](https://istio.io/latest/about/service-mesh/) to maintain the TLS connections for you. A service mesh such as Istio, or an application runtime such as DAPR, can help generate its own self-signed workload certificates. For extra security, consider [configuring a cluster-local intermediate CA](https://istio.io/latest/docs/tasks/security/cert-management/plugin-ca-cert/) for use in signing these workload certificates. If you do so, then also consider issuing the certificate for this intermediate CA using your Public Key Infrastructure (PKI), where the root certificate itself remains secured in an offline HSM-backed vault.

For ingress TLS connections into the cluster, evaluate using one of the many products such as load balancers and ingress or gateway controllers that can help you securely manage incoming traffic. You might need to generate your own certificates for these endpoints to use. You might also need to distribute trust bundles for these certificates to external clients that need to authenticate their connection into the cluster. Again, consider issuing these certificates from your PKI. You can use [Certificate Management for Azure Arc](/en-us/azure/azure-arc/kubernetes/cert-manager-overview), based on the open-source [cert-manager](https://cert-manager.io/) and [trust-manager](https://cert-manager.io/docs/trust/trust-manager/) projects, to manage these certificates and distribute trust across namespaces within the clusters. Here's [how this request works](/en-us/azure/azure-arc/kubernetes/cert-manager-ingress) for Gateway API and NGINX ingress controllers. Or, if you only need a few certificates, you might create and rotate them manually in Azure Key Vault and sync them as Kubernetes secrets by using the [Azure Key Vault Secret Store extension for Kubernetes](/en-us/azure/azure-arc/kubernetes/secret-store-extension) ("SSE").

Once generated, these certificates and accompanying private keys are stored as secrets in the Kubernetes secret store. See this [guidance on protecting these secrets](conceptual-secure-your-data#protect-the-kubernetes-secrets-store).

You may also use service account tokens for TLS, instead of certificates for mTLS, for client-side authentication of connections within the cluster. If so, we recommend avoiding the use of the "default" service account for each namespace. Instead, create a dedicated service account identity for each separate workload or component. Doing so enables a least privilege approach as you configure authorization rules [for your services](conceptual-secure-your-workloads#configure-authorization-rules-for-accessing-workloadsservices) or [for your API server using Kubernetes RBAC](conceptual-secure-your-operations#control-who-can-deploy-to-your-cluster-with-role-based-access-control-rbac).

### References

- [Kubernetes Security - OWASP Cheat Sheet Series – "Implementing centralized policy management"](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes_Security_Cheat_Sheet.html)
- [NSA Kubernetes Hardening Guidance – "Protecting Pod servicer account tokens"](https://media.defense.gov/2022/Aug/29/2003066362/-1/-1/0/CTR_KUBERNETES_HARDENING_GUIDANCE_1.2_20220829.PDF)

## Configure authorization rules for accessing workloads/services

Aim to control traffic between your workloads by setting authorization rules about which workloads can send requests to your Kubernetes workloads (services).

If you use a service mesh such as [Istio](https://istio.io/latest/about/service-mesh/), it automatically issues identity credentials to each workload. Use these identities when [configuring authorization policies](https://istio.io/latest/docs/reference/config/security/authorization-policy/) to restrict access to Kubernetes services so only specified calling workloads can access them.

If you don't use a service mesh, configure your own credentials, such as certificates or service account tokens, and deploy a dedicated authorization engine like [OPA](https://www.openpolicyagent.org/). By using OPA with its [Envoy plug-in](https://www.openpolicyagent.org/docs/envoy/), you don't need to modify your workloads.

Also [consider enforcing traffic restrictions at the network layer](conceptual-secure-your-network#configure-kubernetes-network-policy-to-control-access-tofrom-your-workloads).

## Maintain and monitor workload telemetry and plug it into a security management (SIEM) solution

Send your workload telemetry to a monitoring solution where it can be analyzed for potential security issues, as well as product performance or debugging issues.

You can deploy [Azure Monitor extensions](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable) to your edge cluster. These extensions automatically send Prometheus metrics to your Azure Monitor workspace and/or Container Insights logs to your Log Analytics workspace. Prometheus metrics can be collected and analyzed at scale with Grafana dashboards. Container Insights logs and performance data can be collected and analyzed using prebuilt views and workbooks. As you set up this analysis, be aware of the [best practices for monitoring clusters](/en-us/azure/azure-monitor/containers/best-practices-containers) that cover reliability, cost optimization, performance, and security.

Further, the [Azure Monitor pipeline](/en-us/azure/azure-monitor/data-collection/pipeline-overview) extension offers other flexible options for telemetry collection in edge clusters. Its capabilities include scalable routing from edge to cloud, local data caching, and delayed cloud syncing, which helps ensure reliable monitoring even in network-segmented or offline environments. It can also receive telemetry data from a wider variety of remote sources and other agents using OpenTelemetry Protocol (OTLP) and syslog formats.

Once you have logs flowing into a Log Analytics workspace, you can also enable [Microsoft Sentinel](/en-us/azure/sentinel/overview?tabs=defender-portal) for cyberthreat detection, investigation, response, and proactive hunting.

### References

- [NSA Kubernetes Hardening Guidance – "Logging"](https://media.defense.gov/2022/Aug/29/2003066362/-1/-1/0/CTR_KUBERNETES_HARDENING_GUIDANCE_1.2_20220829.PDF)