
# Summary

This repository contains the necessary files to set up a CI/CD pipeline for a Node.js application deployed on AWS ECS using Terraform. It is organized into three main folders:

- **application**: Contains Node.js files and a Dockerfile for the application.
- **terraform**: Holds all the `.tf` files for infrastructure provisioning using Terraform.
- **githubworkflows**: Contains YAML files for GitHub Actions workflows.

# Getting Started

## Prerequisites

Before getting started, ensure you have the following:

- An AWS account.
- Access Key ID and Secret Key of a user in AWS with Admin permissions (for proof of concept only, not for production).
- GitHub secrets to store the AWS Access Key ID and Secret values to be used in the workflows.
- An S3 bucket for remote storage of the Terraform state file.
- A DynamoDB table for state file locking.

## Steps

1. Clone this repository to your local machine.
2. Set up the required AWS credentials and secrets as GitHub secrets.
3. Configure the Terraform backend to use the S3 bucket and DynamoDB table.
4. Update the Terraform files with your desired configurations.
5. Trigger the GitHub Actions Terraform CI/CD workflow 1st to create the infrastructure , then run the the Application workflow by pushing changes to the repository or by manually triggering the workflow from the UI .

# Workflows
---

## Terraform CI/CD Workflow

This workflow is responsible for provisioning and managing the infrastructure. It consists of the following steps:

1. **Terraform Init**: Initializes Terraform.
2. **Terraform Validate**: Validates the Terraform configuration.
3. **Terraform Apply**: Applies the Terraform changes to create/update the infrastructure.
4. **Watch for Changes**: Listens for changes in the Terraform folder.

The resources created by this workflow include:
- ECR
- ECS Cluster
- ECS Task Definition
- ECS Service
- ECS Task Execution Role
- VPC
- Subnets
- Load Balancer
- Target Group
- Security Groups

### NOTE : at the end of the terraform apply job , the loadbalancer url is provided , copy and paste it in your browser to browse your application
---

## Application CI Workflow

This workflow handles Continuous Integration for the application. It performs the following steps:

1. **Lint Code**: Lints the application code.
2. **Build Image**: Builds a Docker image for the application.
3. **Push Image to ECR**: Pushes the built image to the Amazon ECR.
3. **Updates Image tag in ECS task definition in ecs.tf file in terraform folder**: it updates the ECS task definition in the Terraform files, adopting a GitOps approach. This triggers the Terraform workflow to update the ECS task definition with the newly created image tag.


**These workflows together facilitate CI/CD for both the infrastructure and the application. The CD for the application is also managed by the Terraform workflow.**
---

## Terraform destroy Workflow

This workflow handles destroying all the aws infrastructure .

---
## New Relic Integration

To integrate New Relic, follow these steps:

1. Sign up for a New Relic account and obtain the license key.
2. Follow the installation instructions in [this link](https://docs.newrelic.com/docs/infrastructure/elastic-container-service-integration/install-ecs-integration/#next-steps).
3. Download the task definition of the new relic container using the command `curl -O https://download.newrelic.com/infrastructure_agent/integrations/ecs/newrelic-infra-ecs-fargate-example-latest.json`.
4. Embed the JSON in your task definition in the `ecs.tf` file, replacing placeholders with the actual values of the ARNs of the resources created by any of the installation methods from the documentation.
