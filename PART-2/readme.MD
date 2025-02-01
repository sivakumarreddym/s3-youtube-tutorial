# S3 IAM and Bucket Policies

We can control access to S3 buckets through 2 ways.
1. IAM policies
2. S3 Bucket Policies, which is resource based policy

It is important to combine both. So let us understand how these works.

**Use Case:**
Imagine we are creating infra to a project which have 
* 3 EC2 instances named mysql, backend and frontend

**Pre-requisites:**
* AWS account
* EC2 instance running with terraform installed.
* S3 bucket to store remote state

For better security reasons we will have a dedicated EC2 instance running with terraform installed in your AWS account. We will assign a role to this instance which have permissions.
* A Full EC2 access to create instances.
* S3 Bucket access to store remote state.

Refer [iam-policy-terraform](iam-policy-terraform.json).

clone this repo and create infrastructure.

Here there is one catch, anyone in this account can use the role you created with the policy to create infrastrucutre. So we need to restrict only instances from our VPC CIDR can create infrastructure. IAM policies can't do this. We need bucket policy with VPC CIDR condition






