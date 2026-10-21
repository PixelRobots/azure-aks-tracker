---
layout: Conceptual
title: Deploy AWS event-driven workflow (EDW) workload to Azure - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/eks-edw-deploy
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
description: Learn how to deploy an AWS EDW workflow to Azure and how to validate your deployment.
ms.topic: how-to
ms.date: 2024-06-20T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: aks-migration
locale: en-us
document_id: f45d3289-a037-4491-46df-eec75f1aa2cf
document_version_independent_id: 22d85733-3e59-a013-cb27-5deafc2ff270
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/eks-edw-deploy.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/eks-edw-deploy
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/eks-edw-deploy.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/54918a83-0404-4863-9c91-715186c1f582
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/b26f5f7a-0913-4a95-8337-ed7543902f2d
platformId: 87a2786b-0910-c536-f0c5-06b62c4df668
---

# Deploy AWS event-driven workflow (EDW) workload to Azure - Azure Kubernetes Service | Microsoft Learn

In this article, you will deploy an [AWS EDW workload](eks-edw-overview) to Azure.

## Sign in to Azure

1. Sign in to Azure using the [`az login`](/en-us/cli/azure/authenticate-azure-cli-interactively#interactive-login) command.

    ```azurecli
    az login
    ```
2. If your Azure account has multiple subscriptions, make sure to select the correct subscription. List the names and IDs of your subscriptions using the [`az account list`](/en-us/cli/azure/account#az-account-list) command.

    ```azurecli
    az account list --query "[].{id: id, name:name }" --output table
    ```
3. Select a specific subscription using the [`az account set`](/en-us/cli/azure/account#az-account-set) command.

    ```azurecli
    az account set --subscription $subscriptionId
    ```

## EDW workload deployment script

Review the environment variables in the file `deployment/environmentVariables.sh` and then you use the `deploy.sh` script in the `deployment/infra/` directory of the [GitHub repository](https://github.com/Azure-Samples/aks-event-driven-replicate-from-aws) to deploy the application to Azure.

The script first checks that all of the [prerequisite tools](eks-edw-overview#prerequisites) are installed. If not, the script terminates and displays an error message letting you know which prerequisites are missing. If this happens, review the prerequisites, install any missing tools, and then run the script again. The [Node autoprovisioning (NAP) for AKS](node-autoprovision) feature flag must be registered on your Azure subscription. If it isn't already registered, the script executes an Azure CLI command to register the feature flag.

The script records the state of the deployment in a file called `deploy.state`, which is located in the `deployment` directory. You can use this file to set environment variables when deploying the app.

As the script executes the commands to configure the infrastructure for the workflow, it checks that each command executes successfully. If any issues occur, an error message is displayed, and the execution stops.

The script displays a log as it runs. You can persist the log by redirecting the log information output and saving it to the `install.log` file in the `logs` directory using the following commands:

```bash
mkdir ./logs
./deployment/infra/deploy.sh | tee ./logs/install.log
```

For more information, see the `./deployment/infra/deploy.sh` script in our [GitHub repository](https://github.com/Azure-Samples/aks-event-driven-replicate-from-aws).

### Workload resources

The deployment script creates the following Azure resources:

- **Azure resource group**: The [Azure resource group](/en-us/azure/azure-resource-manager/management/overview) that stores the resources created by the deployment script.
- **Azure Storage account**: The Azure Storage account that contains the queue where messages are sent by the producer app and read by the consumer app, and the table where the consumer app stores the processed messages.
- **Azure container registry**: The container registry provides a repository for the container that deploys the refactored consumer app code.
- **Azure Kubernetes Service (AKS) cluster**: The AKS cluster provides Kubernetes orchestration for the consumer app container and has the following features enabled:

    - **Node autoprovisioning (NAP)**: The implementation of the [Karpenter](https://karpenter.sh) node autoscaler on AKS.
    - **Kubernetes Event-driven Autoscaling (KEDA)**: [KEDA](https://keda.sh) enables pod scaling based on events, such as exceeding a specified queue depth threshold.
    - **Workload identity**: Allows you to attach role-based access policies to pod identities for enhanced security.
    - **Attached Azure container registry**: This feature allows the AKS cluster to pull images from repositories on the specified ACR instance.
- **Application and system node pool**: The script also creates an application and system node pool in the AKS cluster that has a taint to prevent application pods from being scheduled in the system node pool.
- **AKS cluster managed identity**: The script assigns the `acrPull` role to this managed identity, which facilitates access to the attached Azure container registry for pulling images.
- **Workload identity**: The script assigns the **Storage Queue Data Contributor** and **Storage Table Data Contributor** roles to provide role-based access control (RBAC) access to this managed identity, which is associated with the Kubernetes service account used as the identity for pods on which the consumer app containers are deployed.
- **Two federated credentials**: One credential enables the managed identity to implement pod identity, and the other credential is used for the KEDA operator service account to provide access to the KEDA scaler to gather the metrics needed to control pod autoscaling.

## Validate deployment and run the workload

Once the deployment script completes, you can deploy the workload on the AKS cluster.

1. Set the source for gathering and updating the environment variables for `./deployment/environmentVariables.sh` using the following command:

    ```bash
    source ./deployment/environmentVariables.sh
    ```
2. You need the information in the `./deployment/deploy.state` file to set environment variables for the names of the resources created in the deployment. Display the contents of the file using the following `cat` command:

    ```bash
    cat ./deployment/deploy.state
    ```

    Your output should show the following variables:

    ```output
    SUFFIX=
    RESOURCE_GROUP=
    AZURE_STORAGE_ACCOUNT_NAME=
    AZURE_QUEUE_NAME=
    AZURE_COSMOSDB_TABLE=
    AZURE_CONTAINER_REGISTRY_NAME=
    AKS_MANAGED_IDENTITY_NAME=
    AKS_CLUSTER_NAME=
    WORKLOAD_MANAGED_IDENTITY_NAME=
    SERVICE_ACCOUNT=
    FEDERATED_IDENTITY_CREDENTIAL_NAME=
    KEDA_SERVICE_ACCT_CRED_NAME=
    ```
3. Read the file and create environment variables for the names of the Azure resources created by the deployment script using the following commands:

    ```bash
    while IFS= read -r; line do \
    echo "export $line" \
    export $line; \
    done < ./deployment/deploy.state
    ```
4. Get the AKS cluster credentials using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME
    ```
5. Verify that the KEDA operator pods are running in the `kube-system` namespace on the AKS cluster using the [`kubectl get`](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_get/) command.

    ```bash
    kubectl get pods --namespace kube-system | grep keda
    ```

    Your output should look similar to the following example output:

    ![Screenshot showing an example response from the command to verify that KEDA operator pods are running.](media/eks-edw-deploy/sample-keda-response.png)

## Generate simulated load

Now, you generate simulated load using the producer app to populate the queue with messages.

1. In a separate terminal window, navigate to the project directory.
2. Set the environment variables using the steps in the previous section. 1. Run the producer app using the following command:

    ```python
    python3 ./app/keda/aqs-producer.py
    ```
3. Once the app starts sending messages, switch back to the other terminal window.
4. Deploy the consumer app container onto the AKS cluster using the following commands:

    ```bash
    chmod +x ./deployment/keda/deploy-keda-app-workload-id.sh
    ./deployment/keda/deploy-keda-app-workload-id.sh
    ```

    The deployment script (`deploy-keda-app-workload-id.sh`) performs templating on the application manifest YAML specification to pass environment variables to the pod. Review the following excerpt from this script:

    ```bash
    cat <<EOF | kubectl apply -f -
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: $AQS_TARGET_DEPLOYMENT
      namespace: $AQS_TARGET_NAMESPACE
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: aqs-reader
      template:
        metadata:
          labels:
            app: aqs-reader
            azure.workload.identity/use: "true"
        spec:
          serviceAccountName: $SERVICE_ACCOUNT
          containers:
          - name: keda-queue-reader
            image: ${AZURE_CONTAINER_REGISTRY_NAME}.azurecr.io/aws2azure/aqs-consumer
            imagePullPolicy: Always
            env:
            - name: AZURE_QUEUE_NAME
              value: $AZURE_QUEUE_NAME
            - name: AZURE_STORAGE_ACCOUNT_NAME
              value: $AZURE_STORAGE_ACCOUNT_NAME
            - name: AZURE_TABLE_NAME
              value: $AZURE_TABLE_NAME
            resources:
              requests:
                memory: "64Mi"
                cpu: "250m"
              limits:
                memory: "128Mi"
                cpu: "500m"
    EOF
    ```

    The `azure.workload.identity/use` label in the `spec/template` section is the pod template for the deployment. Setting the label to `true` specifies that you're using workload identity. The `serviceAccountName` in the pod specification specifies the Kubernetes service account to associate with the workload identity. While the pod specification contains a reference for an image in a private repository, there's no `imagePullSecret` specified.
5. Verify that the script ran successfully using the [`kubectl get`](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_get/) command.

    ```bash
    kubectl get pods --namespace $AQS_TARGET_NAMESPACE
    ```

    You should see a single pod in the output.
6. Verify that a Karpenter node pool was created. Do this using the `kubectl get nodepool` command. The command response will look like this:

    [![Screenshot showing an example of the Karpenter node pool creation.](media/eks-edw-deploy/sample-karpenter-node.png)](media/eks-edw-deploy/sample-karpenter-node.png#lightbox)

    Verify that the default node pool is a Karpenter node pool using the `kubectl describe nodepool` command. In the command response, you can verify that the node pool is a Karpenter node pool. You should see something like this:

    [![Screenshot showing the node pool response, including API version noted as karpenter.](media/eks-edw-deploy/sample-response-nodepool.png)](media/eks-edw-deploy/sample-response-nodepool.png#lightbox)

## Monitor scale out for pods and nodes with k9s

You can use various tools to verify the operation of apps deployed to AKS, including the Azure portal and k9s. For more information on k9s, see the [k9s overview](https://k9scli.io/).

1. Install k9s on your AKS cluster using the appropriate guidance for your environment in the [k9s installation overview](https://k9scli.io/topics/install/).
2. Create two windows, one with a view of the pods and the other with a view of the nodes in the namespace you specified in the `AQS_TARGET_NAMESPACE` environment variable (default value is `aqs-demo`) and start k9s in each window.

    You should see something similar to the following:

    [![Screenshot showing an example of the K9s view across two windows.](media/eks-edw-deploy/sample-k9s-view.png)](media/eks-edw-deploy/sample-k9s-view.png#lightbox)
3. After you confirm that the consumer app container is installed and running on the AKS cluster, install the `ScaledObject` and trigger authentication used by KEDA for pod autoscaling by running the scaled object installation script (`keda-scaleobject-workload-id.sh`). using the following commands:

    ```bash
    chmod +x ./deployment/keda/keda-scaleobject-workload-id.sh
    ./deployment/keda/keda-scaleobject-workload-id.sh
    ```

    The script also performs templating to inject environment variables where needed. Review the following excerpt from this script:

    ```bash
    cat <<EOF | kubectl apply -f -
    apiVersion: keda.sh/v1alpha1
    kind: ScaledObject
    metadata:
      name: aws2az-queue-scaleobj
      namespace: ${AQS_TARGET_NAMESPACE}
    spec:
      scaleTargetRef:
        name: ${AQS_TARGET_DEPLOYMENT}     #K8s deployement to target
      minReplicaCount: 0  # We don't want pods if the queue is empty nginx-deployment
      maxReplicaCount: 15 # We don't want to have more than 15 replicas
      pollingInterval: 30 # How frequently we should go for metrics (in seconds)
      cooldownPeriod:  10 # How many seconds should we wait for downscale
      triggers:
      - type: azure-queue
        authenticationRef:
          name: keda-az-credentials
        metadata:
          queueName: ${AZURE_QUEUE_NAME}
          accountName: ${AZURE_STORAGE_ACCOUNT_NAME}
          queueLength: '5'
          activationQueueLength: '20' # threshold for when the scaler is active
          cloud: AzurePublicCloud
    ---
    apiVersion: keda.sh/v1alpha1
    kind: TriggerAuthentication
    metadata:
      name: keda-az-credentials
      namespace: $AQS_TARGET_NAMESPACE
    spec:
      podIdentity:
        provider: azure-workload
        identityId: '${workloadManagedIdentityClientId}'
    EOF
    ```

    The manifest describes two resources: the **`TriggerAuthentication` object**, which specifies to KEDA that the scaled object is using pod identity for authentication, and the **`identityID` property**, which refers to the managed identity used as the workload identity.

    When the scaled object is correctly installed and KEDA detects the scaling threshold is exceeded, it begins scheduling pods. If you're using k9s, you should see something like this:

    [![Screenshot showing an example of the K9s view with scheduling pods.](media/eks-edw-deploy/sample-k9s-scheduling-pods.png)](media/eks-edw-deploy/sample-k9s-scheduling-pods.png#lightbox)

    If you allow the producer to fill the queue with enough messages, KEDA might need to schedule more pods than there are nodes to serve. To accommodate this, Karpenter will kick in and start scheduling nodes. If you're using k9s, you should see something like this:

    [![Screenshot showing an example of the K9s view with scheduling nodes.](media/eks-edw-deploy/sample-k9s-scheduling-nodes.png)](media/eks-edw-deploy/sample-k9s-scheduling-nodes.png#lightbox)

    In these two images, notice how the number of nodes whose names contain `aks-default` increased from one to three nodes. If you stop the producer app from putting messages on the queue, eventually the consumers will reduce the queue depth below the threshold, and both KEDA and Karpenter will scale in. If you're using k9s, you should see something like this:

    [![Screenshot showing an example of the K9s view with reduced queue depth.](media/eks-edw-deploy/sample-k9s-reduce.png)](media/eks-edw-deploy/sample-k9s-reduce.png#lightbox)
4. Finally, you can view Karpenter autoscaling activity using the `kubectl get events` command as shown here:

    [![Screenshot showing an example of the kubectl command.](media/eks-edw-deploy/sample-kubectl-command.png)](media/eks-edw-deploy/sample-kubectl-command.png#lightbox)

## Clean up resources

You can use the cleanup script (`/deployment/infra/cleanup.sh`) in our [GitHub repository](https://github.com/Azure-Samples/aks-event-driven-replicate-from-aws) to remove all the resources you created.