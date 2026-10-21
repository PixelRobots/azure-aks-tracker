---
layout: Conceptual
title: Monitor and troubleshoot Certificate Management for Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/cert-manager-monitor-troubleshoot
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
ms.topic: how-to
description: Learn how to monitor the health of the Certificate Management for Azure Arc extension and troubleshoot problems.
locale: en-us
document_id: 294f76fd-030b-7da0-ad2e-6da1b7245932
document_version_independent_id: 23761060-935b-918c-1b27-50ee17ae3d9b
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/cert-manager-monitor-troubleshoot.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/cert-manager-monitor-troubleshoot
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/cert-manager-monitor-troubleshoot.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 37df316d-1910-e744-fc9c-faba6ae0941e
---

# Monitor and troubleshoot Certificate Management for Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn

This article explains how to monitor extension status, check the health of cert-manager and trust-manager, and troubleshoot problems related to Certificate Management for Azure Arc extension.

## Confirm successful extension installation

In the Azure portal, go to your Arc-enabled Kubernetes cluster. In the service menu, under **Settings**, select **Extensions**. You should see the Certificate Management for Azure Arc extension, using either the name you provided or **microsoft.certmanagement**.

Ensure that the extension status is **Installed** or **Succeeded**. If the status shows **Failed**, try reinstalling the extension, or check your Azure Activity log for possible errors.

## Confirm that pods and components are running

First, run this kubectl command to list the pods in the `cert-manager` namespace:

```bash
kubectl get pods -n cert-manager
```

You should see the following pods running:

- `cert-manager`: The main cert-manager controller.
- `cert-manager-webhook`: Used for Certificate CRD webhooks.
- `cert-manager-cainjector`: Helper for injecting CA into webhooks.
- `trust-manager`: The trust bundle manager.

You might also see additional pods. For example, you might see output similar to the following example:

```output
NAME                                      READY   STATUS    RESTARTS   AGE
cert-manager-xxxxxxxx-xxxxx               2/2     Running   0          1m
cert-manager-cainjector-xxxxxxxx-xxxxx    2/2     Running   0          1m
cert-manager-webhook-xxxxxxxx-xxxxx       2/2     Running   0          1m
trust-manager-xxxxxxxx-xxxxx              2/2     Running   0          1m
```

If the cert-manager and trust-manager pods aren't running:

- Run `kubectl describe pod <name> -n cert-manager` to see events. For example, a webhook pod might fail if it can't obtain a certificate for itself due to network policies or firewall blocking the necessary connectivity.
- Check container logs and look for any errors:

    ```bash
    kubectl logs deployment/cert-manager -n cert-manager
    kubectl logs deployment/cert-manager-webhook -n cert-manager
    kubectl logs deployment/cert-manager-cainjector -n cert-manager
    kubectl logs deployment/trust-manager -n cert-manager
    ```

After confirming that pods are running, run the following kubectl command to confirm that the Custom Resource Definitions (CRDs) for cert-manager and trust-manager are installed:

```bash
kubectl get crds | grep cert-manager
```

This command should list CRDs such as `certificates.cert-manager.io`, `issuers.cert-manager.io`, `clusterissuers.cert-manager.io`, and `bundles.trust.cert-manager.io`. For example:

```output

bundles.trust.cert-manager.io                          2025-08-14T15:11:27Z
certificaterequests.cert-manager.io                    2025-08-14T15:11:27Z
certificates.cert-manager.io                           2025-08-14T15:11:27Z
challenges.acme.cert-manager.io                        2025-08-14T15:11:27Z
clusterissuers.cert-manager.io                         2025-08-14T15:11:27Z
issuers.cert-manager.io                                2025-08-14T15:11:27Z
orders.acme.cert-manager.io                            2025-08-14T15:11:27Z
```

These CRDs indicate that the API for managing certificates and trust bundles is available in your cluster, and you can start issuing and managing certificates.

## Troubleshoot certificates not being issued

If a certificate isn't getting issued (secret not created, or status of certificate remains **False**), check the following:

- Run `kubectl describe certificate <name>` to see events. You might see a message explaining the reason, such as "Issuer not ready" or "Waiting on certificate approval."
- Ensure the referenced Issuer/ClusterIssuer exists and is ready by running `kubectl get issuer,clusterissuer -A` to list issuers. If the issuer isn't ready, run `kubectl describe` to get more information. For example, this could be caused by a missing or misnamed backing secret for a Certificate A issuer, or an Automatic Certificate Management Environment (ACME) issuer failing an HTTP-01 challenge.
- If using an ACME issuer such as Let's Encrypt, run `kubectl get challenge,order -A` for ACME challenge objects and describe them for details (which could show problems such as "DNS record not found for DNS-01" or "Ingress not reachable for HTTP-01").
- Check cert-manager controller logs by running `kubectl logs deploy/cert-manager -n cert-manager` around the time of the request. Logs might include warnings explaining why a certificate couldn't be issued.

## Troubleshoot trust bundles not propagating

If trust bundles aren't propagating as expected, check the following:

- Run `kubectl describe bundle <name> -n <ns>` and check the status section. For example, you might see that the source secret or configmap couldn't be found.
- Confirm that you used the correct namespace and name for the source secret or configmap specified in the bundle.
- Run `kubectl logs deploy/trust-manager -n cert-manager` to check the trust-manager logs for messages regarding bundles.
- Verify if the ConfigMap in target namespaces is created or updated. If not, trust-manager might not have the necessary permissions. By default, the extension sets up the needed ClusterRole that allows trust-manager to create ConfigMaps cluster-wide, but it's possible that the permissions were modified.

## Resolve common errors in Certificate Management for Azure Arc-enabled Kubernetes

### Error due to resource already existing in your cluster

This error occurs when you try to install the extension on a cluster that already has cert-manager or trust-manager components installed.

To resolve this error, you can either uninstall the existing cert-manager and trust-manager components from your cluster before installing the extension, or choose a different cluster that doesn't have these components installed. For more information, see [Migrate from open source cert-manager and trust-manager](cert-manager-deploy#migrate-from-open-source-cert-manager-and-trust-manager).

### Certificate signed by unknown authority

If you see "x509: certificate signed by unknown authority" errors in your application logs, your application doesn't trust the issuer that signed a certificate. Use trust-manager to distribute the relevant certification authority (CA), or configure the application to trust the CA.

For example, if using a self-signed ClusterIssuer, ensure that all clients trust that self-signed root.

### Issuer is not ready

If you see "Issuer is not ready (Error: secret not found)", fix the `spec.ca.secretName` value in the issuer to point to the correct secret that contains the CA's key pair.

### ACME HTTP-01 challenge failed

If you use an ACME issuer and see an HTTP-01 challenge failed error, ensure that an appropriate ingress controller is in place and that the HTTP challenge ingress can be reached. Normally, cert-manager creates a temporary ingress to serve a token at `http://<yourdomain>/.well-known/acme-challenge/`. If that doesn't happen, or if your cluster can't be reached, the challenge fails. If so, consider using DNS-01 challenge (requires access to DNS provider API) or use another method.

To check challenge resource status, run `kubectl describe challenge <name>` to look for reasons, such as a 404 error on the URL or DNS TXT not found.

### Certificate renewed but secret not updated in pod

Kubernetes updates volume mounts with new secret content, but some processes might not notice. For example, Java applications might need a restart or a specific signal to reload keystores.

To resolve this problem, update your application so that it's prepared to reload certificates if necessary. Some applications use sidecars or cert-reloader processes for this purpose.