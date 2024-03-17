# Learning Project: Terraform with CI/CD Automation

## Introduction
This repository contains a learning project focused on infrastructure as code (IaC) using Terraform. The project demonstrates automated deployment through CI/CD using GitHub Actions. It's designed as a hands-on project to understand and implement various AWS services and Terraform configurations.

Take a look at it in: https://coffeecard-brewer.dev

## Services Involved
The project integrates several AWS services, ensuring a comprehensive learning experience in managing cloud resources. The services include:

- **IAM (Identity and Access Management):** For managing access and permissions.
- **CloudWatch:** Utilized for monitoring and observability.
- **S3 (Simple Storage Service):** Object storage used for web hosting.
- **DynamoDB:** NoSQL database for storing structured data.
- **Lambda:** Serverless computing service to run code in response to events.
- **API Gateway:** For creating, publishing, and securing APIs.
- **Cloudfront:** Enabling HTTPS and Origin Access Control.
- **Route 53:** Domain and DNS management.
- **Certificate Manager:** Certificate creation and validation.

## CI/CD with GitHub Actions
The deployment of the infrastructure is fully automated using GitHub Actions, providing a seamless CI/CD pipeline. This automation ensures that the infrastructure is consistently deployed and managed through code changes in the repository.

## Release Versions

### 0.3.0 
**Release Date:** 10/03/2024 
 
**Description:** 
- Added domain from Porkbun.
- Created and configurated Route 53 hosted zone, added and validated SSL/TLS certificate.

### 0.2.0
**Release Date:** 01/02/2023

**Description:**
- Created bucket for web application files
- Configured bucket with Cloudfront distribution, enabled OAC

### 0.1.0
**Release Date:** 03/12/2023

**Description:**
- Project initialization.
- Added the 'Daily Coffee Request' feature.
- Automated creation of a DynamoDB table and data insertion.

---
