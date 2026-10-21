---
layout: Conceptual
title: Build and Push Container Images of the Java Spring Boot App - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-java-quickstart
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
description: Learn to build and push a containerized Java Spring Boot app to the Azure Container Registry using Maven and Jib plugin.
ms.date: 2023-10-31T00:00:00.0000000Z
ms.topic: quickstart
ms.custom: devx-track-java, devx-track-azurecli, mode-api, devx-track-extended-java
locale: en-us
document_id: f7bb4890-22e2-2c12-b368-b0aff3001b5c
document_version_independent_id: 772fc69b-5148-2e53-c19e-fc145ec804e1
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-java-quickstart.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-java-quickstart
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-java-quickstart.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 71a2baf3-6813-5f6f-a1d3-289edab7b007
---

# Build and Push Container Images of the Java Spring Boot App - Azure Container Registry | Microsoft Learn

You can use this Quickstart to build container images of Java Spring Boot app and push it to Azure Container Registry using Maven and Jib. Maven and Jib are one way of using developer tooling to interact with an Azure container registry.

## Prerequisites

- An Azure subscription; Sign up for a [free Azure account](https://azure.microsoft.com/pricing/free-trial) or activate [MSDN subscriber benefits](https://azure.microsoft.com/pricing/member-offers/msdn-benefits-details) if you don't already have an Azure subscription.
- A supported Java Development Kit (JDK); For more information on available JDKs when developing on Azure, see [Java support on Azure and Azure Stack](/en-us/azure/developer/java/fundamentals/java-support-on-azure).
- The [Azure CLI](/en-us/cli/azure/overview).
- The Apache's [Maven](http://maven.apache.org) build tool (Version 3 or above).
- A [Git](https://git-scm.com) client.
- A [Docker](https://www.docker.com) client.
- The [ACR Docker credential helper](https://github.com/Azure/acr-docker-credential-helper).

## Create and build a Spring Boot application on Docker

The following steps walk you through building a containerized Java Spring Boot web application and testing it locally.

1. From the command prompt, use the following command to clone the [Spring Boot on Docker Getting Started](https://github.com/spring-guides/gs-spring-boot-docker) sample project.

    ```bash
    git clone https://github.com/spring-guides/gs-spring-boot-docker.git
    ```
2. Change directory to the complete project.

    ```bash
    cd gs-spring-boot-docker/complete
    ```
3. Use Maven to build and run the sample app.

    ```bash
    mvn package spring-boot:run
    ```
4. Test the web app by browsing to `http://localhost:8080`, or with the following `curl` command:

    ```bash
    curl http://localhost:8080
    ```

You should see the following message displayed: **Hello Docker World**

## Create an Azure Container Registry using the Azure CLI

Next, you'll create an Azure resource group and your ACR using the following steps:

1. Log in to your Azure account by using the following command:

    ```azurecli
    az login
    ```
2. Specify the Azure subscription to use:

    ```azurecli
    az account set -s <subscription ID>
    ```
3. Create a resource group for the Azure resources used in this tutorial. In the following command, be sure to replace the placeholders with your own resource name and a location such as `eastus`.

    ```azurecli
    az group create \
        --name=<your resource group name> \
        --location=<location>
    ```
4. Create a private Azure container registry in the resource group, using the following command. Be sure to replace the placeholders with actual values. The tutorial pushes the sample app as a Docker image to this registry in later steps.

    ```azurecli
    az acr create \
        --resource-group <your resource group name> \
        --location <location> \
        --name <your registry name> \
        --sku Basic
    ```

## Push your app to the container registry via Jib

Finally, you'll update your project configuration and use the command prompt to build and deploy your image.

Note

To log in the Azure container registry that you just created, you will need to have the Docker daemon running. To install Docker on your machine, [here is the official Docker documentation](https://docs.docker.com/install/).

1. Log in to your Azure Container Registry from the Azure CLI using the following command. Be sure to replace the placeholder with your own registry name.

    ```azurecli
    az config set defaults.acr=<your registry name>
    az acr login
    ```

    The `az config` command sets the default registry name to use with `az acr` commands.
2. Navigate to the completed project directory for your Spring Boot application (for example, "*C:\SpringBoot\gs-spring-boot-docker\complete*" or "*/users/robert/SpringBoot/gs-spring-boot-docker/complete*"), and open the *pom.xml* file with a text editor.
3. Update the `<properties>` collection in the *pom.xml* file with the following XML. Replace the placeholder with your registry name, and add a `<jib-maven-plugin.version>` property with value `2.2.0`, or a newer version of the [jib-maven-plugin](https://github.com/GoogleContainerTools/jib/tree/master/jib-maven-plugin).

    ```xml
    <properties>
       <docker.image.prefix><your registry name>.azurecr.io</docker.image.prefix>
       <java.version>1.8</java.version>
       <jib-maven-plugin.version>2.2.0</jib-maven-plugin.version>
    </properties>
    ```
4. Update the `<plugins>` collection in the *pom.xml* file so that the `<plugin>` element contains and an entry for the `jib-maven-plugin`, as shown in the following example. Note that we are using a base image from the Microsoft Container Registry (MCR): `mcr.microsoft.com/openjdk/jdk:11-ubuntu`, which contains an officially supported JDK for Azure. For other MCR base images with officially supported JDKs, see [Install the Microsoft Build of OpenJDK.](/en-us/java/openjdk/install)

    ```xml
    <plugin>
      <artifactId>jib-maven-plugin</artifactId>
      <groupId>com.google.cloud.tools</groupId>
      <version>${jib-maven-plugin.version}</version>
      <configuration>
         <from>
             <image>mcr.microsoft.com/openjdk/jdk:11-ubuntu</image>
         </from>
         <to>
             <image>${docker.image.prefix}/${project.artifactId}</image>
         </to>
      </configuration>
    </plugin>
    ```
5. Navigate to the complete project directory for your Spring Boot application and run the following command to build the image and push the image to the registry:

    ```azurecli
    az acr login && mvn compile jib:build
    ```

Note

For security reasons, the credential created by `az acr login` is valid for 1 hour only. If you receive a *401 Unauthorized* error, you can run the `az acr login -n <your registry name>` command again to reauthenticate.

## Verify your container image

Congratulations! Now you have your containerized Java App build on Azure supported JDK pushed to your ACR. You can now test the image by deploying it to Azure App Service, or pulling it to local with command (replacing the placeholder):

```bash
docker pull <your registry name>.azurecr.io/gs-spring-boot-docker
```