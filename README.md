AWS VPC Setup
Prerequisites

To retrieve the SSL certificate thumbprint for an OpenID Connect (OIDC) identity provider from the AWS Management Console, follow these steps:
Steps to Retrieve the OIDC Thumbprint

    Sign in to AWS Management Console:
        Navigate to the AWS Management Console.

    Access IAM Service:
        In the search bar, type "IAM" and select Identity and Access Management (IAM).

    Navigate to Identity Providers:
        In the left-hand sidebar, under Access Management, click on Identity Providers.

    Locate Your OIDC Provider:
        In the Identity Providers list, find the OIDC provider for which you need the thumbprint. This could be for a service like GitHub Actions or another OIDC-enabled service.

    View OIDC Provider Details:
        Click on the name of the OIDC provider (e.g., GitHub Actions OIDC provider) to open its details page.

    Retrieve the Thumbprint:
        Under the Provider Details section, you’ll find the thumbprint which is a 40-character SHA-1 hash of the SSL certificate used by the provider. This thumbprint is required for the thumbprint_list in your Terraform configuration.

Steps in the Workflow

    Checkout: The code is checked out from the repository.
    Set up AWS Credentials: AWS OIDC credentials are configured for the session.
    Set OIDC Thumbprint: The OIDC thumbprint is passed to Terraform as an environment variable.
    Terraform Init: Initializes Terraform with the backend configuration, using GitHub secrets.
    Terraform Apply: Applies the Terraform configuration, using the specified .tfvars file (or default terraform.tfvars if no file is provided).

GitHub Secrets

Ensure that the following secrets are defined in your GitHub repository:

    AWS_ACCOUNT_ID: Your AWS account ID.
    AWS_OIDC_THUMBPRINT: The OIDC thumbprint for the identity provider (can be fetched from the AWS Console).
    TF_BACKEND_BUCKET: The name of the S3 bucket for storing the Terraform state.
    TF_BACKEND_KEY: The path to the state file within the S3 bucket.
    TF_REGION: The AWS region where resources will be deployed.

Triggering the Workflow Manually

After committing the changes to your repository, you can manually trigger the workflow:

    Go to the Actions tab in your repository.
    Select the Terraform Plan and Apply workflow.
    Click the Run workflow button.
    You can either use the default terraform.tfvars file or provide a custom .tfvars file when triggering the workflow.

If no input is provided for the .tfvars file, the workflow will default to terraform.tfvars. If a custom file is provided, it will be used for the Terraform apply step.
Example of Custom Input

When manually triggering the workflow, you can provide a custom .tfvars file, such as production.tfvars, by filling in the input field in the GitHub UI. If no input is provided, the default file terraform.tfvars will be used.

This provides flexibility, enabling both automated and manual control over the configuration values via .tfvars files.

############################################################################################

Running Terraform Locally

To run Terraform locally, follow these steps:
Prerequisites:

    Create a bucket manually in AWS Console for storing the state file.
    Add the oidc_thumbprint key and value in your .tfvars file.

1. Initialize Terraform

Run the following command to initialize Terraform (replace the bucket name, region, and dynamodb_table if applicable):

terraform init \
  -backend-config="bucket=${var.bucket}" \
  -backend-config="key=vpc/${var.vpc_name}/terraform.tfstate" \
  -backend-config="region=${var.region}"


Alternatively, if you are using DynamoDB for state locking:

terraform init \
  -backend-config="bucket=your-terraform-state-bucket" \
  -backend-config="region=us-east-1" \
  -backend-config="key=vpc/${var.vpc_name}/terraform.tfstate" \
  -backend-config="dynamodb_table=terraform-lock"

2. Plan and Apply

Run the following commands to apply the Terraform configuration:

terraform plan -var-file="uat-vpc.tfvars"
terraform apply -var-file="uat-vpc.tfvars"

Note: For remote state locking, ensure that dynamodb_table is configured in your backend.tf file:

dynamodb_table = var.dynamodb_table

3. GitHub Actions Configuration

In the deploy.yaml file for GitHub Actions, include the following in the init step:

run: terraform init -backend-config="bucket=${{ secrets.TF_BACKEND_BUCKET }}" -backend-config="key=${{ secrets.TF_BACKEND_KEY }}" -backend-config="region=${{ secrets.TF_REGION }}" -backend-config="dynamodb_table=terraform-lock"

This ensures that the Terraform configuration uses the correct S3 bucket and DynamoDB table for remote state management.