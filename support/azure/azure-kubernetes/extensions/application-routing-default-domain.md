---
layout: Conceptual
title: Troubleshoot the application routing default domain feature in AKS - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/application-routing-default-domain
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: kaushika-msft
ms.author: kaushika
ms.topic: troubleshooting
description: Learn how to troubleshoot the application routing default domain feature in AKS. Fix a certificate that isn't ready or a domain that doesn't resolve.
ms.date: 2026-10-14T00:00:00.0000000Z
ms.reviewer: nshankar, kingoliver
ms.service: azure-kubernetes-service
ms.custom: sap:Extensions, Policies and Add-Ons
ai-usage: ai-assisted
locale: en-us
document_id: a7eb2de1-70c5-1397-3a8d-72f0e7c0912c
document_version_independent_id: a7eb2de1-70c5-1397-3a8d-72f0e7c0912c
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/application-routing-default-domain.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/application-routing-default-domain
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/application-routing-default-domain.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 5d6c0020-92a6-c190-f836-a12d50b9de6c
---

# Troubleshoot the application routing default domain feature in AKS - Azure | Microsoft Learn

## Summary

This article helps you troubleshoot the application routing default domain feature in Azure Kubernetes Service (AKS) so that you can fix a Transport Layer Security (TLS) certificate that isn't ready or a domain that doesn't resolve.

When you enable the feature, AKS provisions a managed `*.<id>.<region>.aksapp.io` domain for your cluster. AKS also issues a trusted, publicly signed TLS certificate for that domain and publishes the Domain Name System (DNS) records for it.

The feature has two parts that can fail independently:

- **TLS certificate** - AKS issues the certificate and reconciles it into a Kubernetes secret through a `DefaultDomainCertificate` custom resource.
- **DNS** - A managed `external-dns` instance, which is defined by a `default-domain-dns``ClusterExternalDNS` custom resource, publishes the address (A) records for the domain to the managed zone.

## Prerequisites

You need `kubectl` access to the cluster.

Note

The certificate and DNS paths are independent. The certificate can be ready while DNS still fails, and DNS can resolve while the certificate isn't ready. Be sure to check both.

## Verify that the default domain feature is enabled

Before you troubleshoot a specific symptom, confirm that the default domain feature is enabled on the cluster. If you don't enable the feature, the cluster doesn't create a certificate or DNS resources.

Use Azure CLI to run the following command.

```azurecli
az aks show --resource-group <resource-group> --name <cluster-name> --query ingressProfile.webAppRouting.defaultDomain.enabled
```

If the command returns `true`, the feature is enabled. If it returns `false` or `null`, enable it. Run the following command.

```azurecli
az aks approuting update --resource-group <resource-group> --name <cluster-name> --enable-default-domain
```

## Step 1: Check the DefaultDomainCertificate custom resource for certificate issues

The `DefaultDomainCertificate` custom resource holds the status of the managed certificate. Its `Available` condition tells you whether the certificate is ready and applied to a secret.

Run the following command to list the custom resource and its status.

```bash
kubectl get defaultdomaincertificate -A
```

Then, describe the resource to read its `Available` condition and events. Run the following command.

```bash
kubectl describe defaultdomaincertificate <name> -n <namespace>
```

Look at the `Available` condition in the `Status` section.

The following list explains the possible values of the `Available` condition and their meanings:

- If the `Status` value of the `Available` condition is `True`, and the `Reason` value is `CertificateSecretApplied`, the certificate is ready and applied to the target secret. The certificate path is healthy. Continue to Step 2: Check the default domain external-dns for DNS resolution issues to troubleshoot DNS.
- If the `Status` value of the `Available` condition is `False`, use the following table to map the `Reason` value to its cause and resolution.

The following table maps the `Reason` values to their causes and resolutions.

| Reason | Cause | Resolution |
| --- | --- | --- |
| `CertificateNotReady` | The certificate isn't issued yet. AKS is still provisioning it. | Wait a few minutes. Provisioning takes single-digit minutes in normal conditions. If the resource stays in this state for more than 30 minutes, [open a support request](https://ms.portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade/overview?DMC=troubleshoot). |
| `ConflictingSecretExists` | The target secret already exists but isn't managed by the default domain feature. The feature doesn't overwrite a secret that it doesn't own. | Delete or rename the conflicting secret in the same namespace, or point the `DefaultDomainCertificate``spec.target.secret` field to a different secret name. |
| `ApplyingCertificateSecretFailed` | The operator couldn't write the certificate secret. A cluster policy or an admission webhook usually blocks the write. | Run `kubectl describe defaultdomaincertificate <name> -n <namespace>`, and read the warning event. Check your admission webhooks and policies for a rule that blocks secret creation in the namespace. |

After the certificate is `Available`, the target secret holds the certificate. Confirm that the secret exists. Run the following command.

```bash
kubectl get secret <target-secret> -n <namespace>
```

The `<target-secret>` value is the name in the `spec.target.secret` field of the `DefaultDomainCertificate` resource.

## Step 2: Check the default domain external-dns for DNS resolution issues

The default domain DNS records are published by a managed `external-dns` instance. AKS defines it with a `ClusterExternalDNS` custom resource that's named `default-domain-dns` in the `app-routing-system` namespace. If this instance is unhealthy, the domain doesn't resolve, and new records aren't published.

### Check the ClusterExternalDNS resource status

Run the following command to inspect the resource and its events.

```bash
kubectl describe clusterexternaldns default-domain-dns -n app-routing-system
```

Review the events at the end of the output. A `FailedUpdateOrCreateExternalDNSResources` warning event points to an identity or configuration problem. If the events are clean, continue to check the pod stability and logs.

### Check the external-dns pod stability

The managed `external-dns` instance runs as a deployment in the `app-routing-system` namespace. Confirm that its pods are running and aren't restarting.

Run the following command.

```bash
kubectl get pods -n app-routing-system -l app.kubernetes.io/name=default-domain-dns-external-dns
```

The following scenarios indicate the stability of the `external-dns` pods:

- If a pod shows a `Running` status with no restarts, the instance is stable. Continue to Check the external-dns pod logs.
- If a pod shows a `CrashLoopBackOff` status, or a high restart count, describe it to see why. Run the following command.

    ```bash
    kubectl describe pod -n app-routing-system -l app.kubernetes.io/name=default-domain-dns-external-dns
    ```

    A pod that's `Pending` usually can't be scheduled. Check the node capacity of the cluster. A pod that restarts often usually fails to authenticate. Check the logs in the next section.

### Check the external-dns pod logs

The pod logs show whether `external-dns` publishes records or fails to authenticate to Azure DNS.

Run the following command.

```bash
kubectl logs -n app-routing-system deploy/default-domain-dns-external-dns
```

Use the following table to map a log pattern to its cause.

| Log pattern | Cause | Resolution |
| --- | --- | --- |
| Lines that contain `Desired change: CREATE` or `UPDATE`, followed by success | The instance publishes records normally. If the domain still doesn't resolve, wait for public DNS propagation. See the following note. |  |
| `AADSTS` authentication errors | The managed identity that you federated to the `default-domain-sa` service account can't get a token. This condition is a platform configuration problem. | [Open a support request](https://ms.portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade/overview?DMC=troubleshoot). |
| `AuthorizationFailed` on a DNS zone | The managed identity is missing the required role on the managed DNS zone. This condition is a platform configuration problem. | [Open a support request](https://ms.portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade/overview?DMC=troubleshoot). |
| No record lines at all, but the pod is healthy | The instance runs but sees no hostnames to publish. Your `Ingress` resources don't set a `host` value, or they don't use the application routing ingress class. | Add a `host` value to your `Ingress` or `Gateway` resource. |

Note

After `external-dns` publishes a record, public DNS propagation adds a short delay. Testing with `curl` or `nslookup` can fail for the first few minutes even when the record is correct.

## References

- [Configure ingress with the application routing add-on](/en-us/azure/aks/app-routing)
- [Troubleshoot the Application Routing Gateway API Implementation](application-routing-gateway-api)
- [Troubleshoot Azure DNS and TLS integration for the application routing Gateway API implementation](application-routing-gateway-api-dns-tls)