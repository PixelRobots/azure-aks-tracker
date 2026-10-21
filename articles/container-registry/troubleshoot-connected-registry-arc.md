---
layout: Conceptual
title: 'Known issues: Connected Registry Arc Extension - Azure Container Registry | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/troubleshoot-connected-registry-arc
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/62/azure-container-registry/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/180a533d-0d25-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: KumudD
learn_banner_products:
- azure
manager: kumud
ms.reviewer: kumud
ms.author: kumud
ms.service: azure-container-registry
description: Learn how to troubleshoot the most common problems for a Connected Registry Arc Extension and resolve issues with ease.
ms.topic: troubleshooting-known-issue
ms.date: 2024-05-09T00:00:00.0000000Z
ms.custom: sfi-ropc-nochange
locale: en-us
document_id: 89e145a6-bdce-8655-1d98-1ccb3b0902ca
document_version_independent_id: c9332aaa-f792-984b-60e9-ebd64f2864fd
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/troubleshoot-connected-registry-arc.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/troubleshoot-connected-registry-arc
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/troubleshoot-connected-registry-arc.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: c8974a13-8155-8043-9c68-fe7c5361a76b
---

# Known issues: Connected Registry Arc Extension - Azure Container Registry | Microsoft Learn

This article describes common error messages that you might receive when you install or update the connected registry extension for Arc-enabled Kubernetes clusters.

## Check extension and pod status

The connected registry extension is a Helm chart. All components of the connected registry extension are installed in the *connected-registry* namespace. Use the following commands to check the extension status.

```bash
# get the extension status 
az k8s-extension show --name <extension-name>  
# check status of all pods of connected registry extension 
kubectl get pod -n connected-registry    
# get events of the extension 
kubectl get events -n connected-registry   --sort-by='.lastTimestamp'
```

## Troubleshoot extension installation or updates

Use the following suggestions to resolve errors you might encounter when installing or updating the connected registry extension.

### Error: can't reuse a name that is still in use

This error message means the extension name you specified already exists. Use a different name for the extension.

The connected registry name must start with a letter and contain only alphanumeric characters. It must be 5 to 40 characters long.

### Error: unable to create new content in namespace *connected-registry* because it's being terminated

This error message occurs when an uninstallation operation isn't finished, and another installation operation starts. Run the `az k8s-extension show` command to check the provisioning status of the extension. Make sure the extension is uninstalled before taking other actions.

### Error: failed in download the Chart path not found

This error message occurs when you specify an extension version that doesn't exist. Update your command to use a valid version. To use the latest extension version, don't specify `--version`.

### Installation fails without an error message

If the extension generates an error message when you create or update it, check where the creation failed by running the `az k8s-extension list` command.

```bash
az k8s-extension list \ 
--resource-group <my-resource-group-name> \ 
--cluster-name <my-cluster-name> \ 
--cluster-type connectedClusters
```

To resolve this problem, try restarting the cluster, and make sure the KubernetesConfiguration service provider is registered. Or, delete and reinstall the connected registry extension.

### Extension creation stuck in running state

One reason for this problem is due to issues with Persistent Volume Claim (PVC). Check the status of the connected registry PVC by running the following command:

```bash
kubectl get pvc -n connected-registry -o yaml connected-registry-pvc
```

The value of `phase` under `status` should be `bound`. If it doesn't change from `pending, delete the extension and try again.

Check whether the desired storage class is in your list of storage classes:

```bash
kubectl get storageclass --all-namespaces
```

If it's not, recreate the extension and add:

```bash
--config pvc.storageClassName=”standard”` 
```

If you need more space for the PVC, try recreating the extension with this parameter:

```bash
--config pvc.storageRequest="250Gi"` 
```

The extension can also get stuck due to a bad connection string. Check the logs for the connected registry pod:

```bash
kubectl get pod -n connected-registry
```

Copy the name of the connected registry pod (for example, `connected-registry-xxxxxxxxx-xxxxx`) and paste it into the following command:

```bash
kubectl logs -n connected-registry connected-registry-xxxxxxxxx-xxxxx
```

If you see the following error message, the connected registry's connection string is bad:

```bash
Response: '{"errors":[{"code":"UNAUTHORIZED","message":"Incorrect Password","detail":"Please visit https://aka.ms/acr#UNAUTHORIZED for more information."}]}' 
```

To resolve this problem, ensure that a protected-settings-extension.json file is created:

```bash
cat protected-settings-extension.json
```

If needed, regenerate protected-settings-extension.json.

```bash
cat << EOF > protected-settings-extension.json  
{ 
"connectionString": "$(az acr connected-registry get-settings \ 
--name myconnectedregistry \ 
--registry myacrregistry \ 
--parent-protocol https \ 
--generate-password 1 \ 
--query ACR_REGISTRY_CONNECTION_STRING --output tsv --yes)" 
} 
EOF
```

Then update the extension to include the new connection string.

```bash
az k8s-extension update \ 
--cluster-name <myarck8scluster> \ 
--cluster-type connectedClusters \ 
--name <myconnectedregistry> \ 
-g <myresourcegroup> \ 
--config-protected-file protected-settings-extension.json
```

### Extension created, but connected registry isn't in **Online** state

This scenario commonly happens when you delete a previous connected registry extension and create a new one for the same connected registry.

Check the logs for the connected registry pod:

```bash
kubectl get pod -n connected-registry
```

Copy the name of the connected registry pod (for example, `connected-registry-xxxxxxxxx-xxxxx`) and paste it into the following command:

```bash
kubectl logs -n connected-registry connected-registry-xxxxxxxxx-xxxxx
```

If you see the following error message, deactivate the connected registry:

`Response: '{"errors":[{"code":"ALREADY_ACTIVATED","message":"Failed to activate the connected registry as it is already activated by another instance. Only one instance is supported at any time.","detail":"Please visit https://aka.ms/acr#ALREADY_ACTIVATED for more information."}]}'`

Run the following command to deactivate:

```azurecli
az acr connected-registry deactivate -n <myconnectedregistry> -r <mycontainerregistry>
```

If successful, after a few minutes, the connected registry pod is recreated, and the error should no longer occur.

## Enable logging

Run the `az acr connected-registry update` command to update the connected registry extension with the debug log level:

```azurecli
az acr connected-registry update --registry mycloudregistry --name myacrregistry --log-level debug
```

Apply the following log levels to help troubleshoot problems:

- **Debug** provides detailed information for debugging purposes.
- **Information** provides general information for debugging purposes.
- **Warning** indicates potential problems that aren't yet errors but might become errors if no action is taken.
- **Error** logs errors that prevent an operation from completing.
- **None** turns off logging, so no log messages are written.

Adjust the log levels as needed to troubleshoot the problem further.

The connected registry log level is specific to the connected registry's operations and determines the severity of messages that the connected registry handles. Use this setting to manage the logging behavior of the connected registry itself.

**--log-level** sets the log level on the instance. The log level determines the severity of messages that the logger handles. By setting the log level, you can filter out messages that are below a certain severity. For example, if you set the log level to `warning`, the logger handles warnings, errors, and critical messages, but it ignores information and debug messages.

The Azure CLI log level controls the verbosity of the output messages during the operation of the Azure CLI. The Azure CLI (`az`) provides several verbosity options for log levels, which you can adjust to control the amount of output information during its operation:

**--verbose** increases the verbosity of the logs. It provides more detailed information than the default setting, which can be useful for identifying problems.

**--debug** enables full debug logs. Debug logs provide the most detailed information, including all the information provided at the `verbose` level plus more details intended for diagnosing problems.