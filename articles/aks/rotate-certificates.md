---
layout: Conceptual
title: Manage and Rotate Certificates in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/rotate-certificates
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
description: Learn how to manage and rotate certificates in Azure Kubernetes Service (AKS) clusters to maintain secure communication between components and ensure compliance.
author: schaffererin
ms.author: schaffererin
ms.topic: how-to
ms.subservice: aks-security
ms.custom: devx-track-azurecli
ms.date: 2026-07-13T00:00:00.0000000Z
locale: en-us
document_id: 6b63c252-19a0-3f05-3fee-5181f57a1333
document_version_independent_id: 9fc11581-c8fa-428a-6487-dcb61f38594d
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/rotate-certificates.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/rotate-certificates
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/rotate-certificates.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 1499f63f-484a-f136-5cde-a85bfd040e70
---

# Manage and Rotate Certificates in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article explains how to manage and rotate certificates in Azure Kubernetes Service (AKS) clusters to maintain secure communication between components and ensure compliance.

## Prerequisites

- Azure CLI version 2.0.77 or later. Check your version by using the `az --version` command. To install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

## Check cluster certificate authority (CA) certificate expiration date

Check the expiration date of the cluster CA certificate using the `kubectl config view` command.

```bash
kubectl config view --raw -o jsonpath="{.clusters[?(@.name == '')].cluster.certificate-authority-data}" | base64 -d | openssl x509 -text | grep -A2 Validity
```

## Check API server certificate expiration date

Check the expiration date of the API server certificate using the following `curl` command:

```bash
curl https://{apiserver-fqdn} -k -v 2>&1 | grep expire
```

## Check VMSS agent node certificate expiration date

Check the expiration date of the virtual machine scale set agent node certificate using the [`az vmss run-command invoke`](/en-us/cli/azure/vmss#az-vmss-run-command-invoke) command.

```azurecli
az vmss run-command invoke \
    --resource-group <node-resource-group> \
    --name <vmss-name> \
    --command-id RunShellScript \
    --instance-id 1 \
    --scripts "openssl x509 -in  /var/lib/kubelet/pki/kubelet-client-current.pem -noout -enddate" \
    --query "value[0].message"
```

## Check standalone VM certificate expiration date

Check the expiration date of a standalone VM using the [`az vm run-command invoke`](/en-us/cli/azure/vm#az-vm-run-command-invoke) command.

```azurecli
az vm run-command invoke \
    --resource-group <resource-group> \
    --name <vm-name> \
    --command-id RunShellScript \
    --scripts "openssl x509 -in /var/lib/kubelet/pki/kubelet-client-current.pem -noout -enddate" \
    --query "value[0].message"
```

## Manually rotate cluster CA certificates

When you rotate the cluster CA certificate, the following child certificates are also refreshed:

- Service account (SA) tokens
- API server certificates
- Kubelet client certificates
- Kubelet server certificates (if kubelet serving certificate rotation is enabled on the cluster)

Warning

Rotating your certificates using [`az aks rotate-certs`](/en-us/cli/azure/aks#az-aks-rotate-certs) recreates all of your nodes, virtual machine scale sets, and disks. This process can cause *up to 30 minutes of downtime* for your AKS cluster. If the command fails before completing, use the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command to verify the status of the cluster shows *Certificate Rotating*. If the cluster is in a failed state, rerun [`az aks rotate-certs`](/en-us/cli/azure/aks#az-aks-rotate-certs) to rotate your certificates again.

1. Connect to your cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az_aks_get_credentials) command.

    ```azurecli
    az aks get-credentials --resource-group <resource-group> --name <cluster-name>
    ```
2. Rotate all certificates, CAs, and SAs on your cluster using the [`az aks rotate-certs`](/en-us/cli/azure/aks#az_aks_rotate_certs) command.

    ```azurecli
    az aks rotate-certs --resource-group <resource-group> --name <cluster-name>
    ```
3. Verify the old certificates are no longer valid using any `kubectl` command, such as `kubectl get nodes`.

    ```bash
    kubectl get nodes
    ```

    If you didn't update the certificates used by `kubectl`, you see an error similar to the following example output:

    ```output
    Unable to connect to the server: x509: certificate signed by unknown authority (possibly because of "crypto/rsa: verification error" while trying to verify candidate authority certificate "ca")
    ```

## Update `kubectl` client certificates

1. Update the `kubectl` client certificate using the [`az aks get-credentials`](/en-us/cli/azure/aks#az_aks_get_credentials) command with the `--overwrite-existing` flag.

    ```azurecli
    az aks get-credentials --resource-group <resource-group> --name <cluster-name> --overwrite-existing
    ```
2. Verify the certificates are updated using the [`kubectl get`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command.

    ```bash
    kubectl get nodes
    ```

    Note

    If you have any services that run on top of AKS, you might need to update their certificates.

## Verify kubelet serving certificate rotation is enabled

Each node with the feature enabled is automatically given the label `kubernetes.azure.com/kubelet-serving-ca=cluster`. Verify the labels are set by using the `kubectl get nodes -L kubernetes.azure.com/kubelet-serving-ca` command.

```bash
kubectl get nodes -L kubernetes.azure.com/kubelet-serving-ca
```

### Verify kubelet goes through TLS bootstrapping process

When you enable this feature, each kubelet running your nodes goes through the serving [TLS bootstrapping process](https://kubernetes.io/docs/reference/access-authn-authz/kubelet-tls-bootstrapping/#certificate-rotation).

Verify the bootstrapping process is taking place using the [`kubectl get`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command to get the current CSR objects within your cluster.

```bash
kubectl get csr --field-selector=spec.signerName=kubernetes.io/kubelet-serving
```

All serving CSRs are in the `Approved,Issued` state, which indicates the CSR was approved and issued a signed certificate. Serving CSRs have a signer name of `kubernetes.io/kubelet-serving`. For example:

```output
NAME        AGE    SIGNERNAME                                    REQUESTOR                    REQUESTEDDURATION   CONDITION
csr-1ab2c   113s   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcd1e      none              Approved,Issued
csr-defgh   111s   kubernetes.io/kubelet-serving                 system:node:akswinp1000000   none              Approved,Issued
csr-ij3kl   46m    kubernetes.io/kubelet-serving                 system:node:akswinp2000000   none              Approved,Issued
csr-mn4op   46m    kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:ab1cde      none              Approved,Issued
```

## Verify kubelet is using a certificate obtained from server TLS bootstrapping

Confirm whether the node's kubelet is using a serving certificate signed by the cluster CA using the [`kubectl debug`][kubectl-debug] command to examine the contents of the kubelet's PKI directory.

```bash
kubectl debug node/<node> -ti --image=mcr.microsoft.com/azurelinux/base/core:3.0 -- ls -l /host/var/lib/kubelet/kubelet-server-current.pem
```

If a `kubelet-server-current.pem` symlink exists, the kubelet bootstraps and rotates its own serving certificate through the TLS bootstrapping process and is signed by the cluster CA.

## Disable kubelet serving certificate rotation

1. Disable kubelet serving certificate rotation by updating the node pool using the [`az aks nodepool update`](/en-us/cli/azure/aks#az-aks-update) command and specify the tag `aks-disable-kubelet-serving-certificate-rotation=true`.

    ```azurecli
    az aks nodepool update \
        --cluster-name <cluster-name> \
        --resource-group <resource-group> \
        --name <node-pool-name> \
        --tags aks-disable-kubelet-serving-certificate-rotation=true
    ```
2. Reimage your nodes using a [node image upgrade](node-image-upgrade) or by scaling the pool to *zero* instances and then back up to the desired value.