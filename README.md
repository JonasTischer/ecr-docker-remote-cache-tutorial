# ecr-docker-remote-cache-tutorial

This repository is part of a blog post about building Docker images and pushing them to AWS ECR (Elastic Container Registry) using remote caching to optimize the build process.

The repository contains the following files and folders:

- `terraform/`: This folder contains the Terraform configuration to set up the necessary AWS resources, including an Github OICD provider for GitHub Actions to assume, the necessary permissions and an ECR repository.
- `.github/build-and-push-ecr.yaml`: This is the GitHub Actions workflow that builds and pushes the Docker image to the ECR repository, leveraging the remote caching feature.
- `Dockerfile`: A simple Dockerfile that just prints "Hello, World!" when the container is run.


The main idea is to use the remote caching feature provided by AWS ECR to speed up the Docker build process in the GitHub Actions workflow. This is achieved by using the `cache-from` and `cache-to` options in the `docker/build-push-action@v5` action, which allows the builder to use the remote cache stored in the ECR repository and export the cache back to the same repository.

By using this approach, the GitHub Actions workflow can benefit from faster build times, as the remote cache in Amazon ECR will be used to speed up the build process.
