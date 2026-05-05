# aux4/aws-lambda

A complete workflow for building, publishing, and deploying aux4 Lambda functions to AWS. This package wraps `aux4/docker` and `community/registry-aws` to provide a streamlined build-push-deploy pipeline for container-based Lambda functions.

## Prerequisites

- **AWS CLI** must be installed and configured with valid credentials (`aws configure`).
- **Docker** must be installed and running.
- An AWS account with ECR and Lambda permissions.
- An IAM role with Lambda execution permissions (for creating new functions).

## Installation

```bash
aux4 aux4 pkger install aux4/aws-lambda
```

## System Dependencies

This package requires the AWS CLI and Docker. If they are not installed, aux4 will attempt to install them using one of the following system installers:

- [brew](/r/public/packages/aux4/system-installer-brew) (macOS): `awscli`, `docker`
- Linux package managers: `awscli`, `docker`

For more details, see [system-installer](/r/public/packages/aux4/pkger/commands/aux4/pkger/system).

## Quick Start

Build, push, and deploy a Lambda function in three steps:

```bash
# Set environment variables
export AWS_ACCOUNT_ID=123456789012
export AWS_REGION=us-west-2

# 1. Build the Lambda Docker image
aux4 aux4 lambda build "my-command" --tag myapp-lambda --mode HTTP

# 2. Push the image to ECR
aux4 aux4 lambda push myapp-lambda --repository myapp-lambda --imageTag v1.0.0

# 3. Deploy the Lambda function
aux4 aux4 lambda deploy my-function \
  --repository myapp-lambda \
  --imageTag v1.0.0 \
  --role arn:aws:iam::123456789012:role/lambda-execution-role
```

## Environment Variables

You can set these environment variables to avoid passing flags on every command:

- `AWS_REGION` -- AWS region (default: `us-east-1`)
- `AWS_ACCOUNT_ID` -- AWS account ID
- `AWS_PROFILE` -- AWS CLI profile name

```bash
export AWS_REGION=us-west-2
export AWS_ACCOUNT_ID=123456789012
export AWS_PROFILE=production

# Now you can omit --region, --accountId, and --profile
aux4 aux4 lambda push myapp-lambda --repository myapp-lambda
```

## Commands

### aux4 lambda build

Build a Lambda Docker image using `aux4/docker`. The `command` argument specifies the aux4 command the Lambda will execute at runtime.

```bash
aux4 aux4 lambda build "my-command" --tag myapp-lambda
aux4 aux4 lambda build "my-command" --tag myapp-lambda --mode HTTP
aux4 aux4 lambda build "my-command" --tag myapp-lambda --packages "aux4/config,community/registry-aws"
aux4 aux4 lambda build "my-command" --tag myapp-lambda --dir ./my-project
```

| Flag | Description | Default |
|------|-------------|---------|
| `command` | The aux4 command to execute (positional) | -- |
| `--tag` | The Docker image tag | -- |
| `--mode` | The Lambda execution mode (`RAW`, `HTTP`, `STEP_FUNCTIONS`) | -- |
| `--packages` | aux4 packages to install, separated by commas | -- |
| `--dir` | The directory to build from | `.` |

### aux4 lambda push

Create an ECR repository (if it does not exist) and push the Docker image to it. This command handles ECR authentication automatically.

```bash
aux4 aux4 lambda push myapp-lambda --repository myapp-lambda --accountId 123456789012
aux4 aux4 lambda push myapp-lambda --repository myapp-lambda --imageTag v1.0.0 --accountId 123456789012
```

| Flag | Description | Default | Env |
|------|-------------|---------|-----|
| `tag` | The local image tag to push (positional) | -- | -- |
| `--repository` | The ECR repository name | -- | -- |
| `--imageTag` | The image tag for ECR | `latest` | -- |
| `--region` | AWS region | `us-east-1` | `AWS_REGION` |
| `--accountId` | AWS account ID | -- | `AWS_ACCOUNT_ID` |
| `--profile` | AWS CLI profile | -- | `AWS_PROFILE` |

### aux4 lambda deploy

Create or update a Lambda function from an ECR image. If the function already exists, it updates the function code with the new image. If it does not exist, it creates a new function using the provided IAM role.

```bash
aux4 aux4 lambda deploy my-function \
  --repository myapp-lambda \
  --imageTag v1.0.0 \
  --accountId 123456789012 \
  --role arn:aws:iam::123456789012:role/lambda-execution-role
```

| Flag | Description | Default | Env |
|------|-------------|---------|-----|
| `functionName` | The Lambda function name (positional) | -- | -- |
| `--repository` | The ECR repository name | -- | -- |
| `--imageTag` | The image tag | `latest` | -- |
| `--region` | AWS region | `us-east-1` | `AWS_REGION` |
| `--accountId` | AWS account ID | -- | `AWS_ACCOUNT_ID` |
| `--role` | The IAM role ARN for the Lambda function | -- | -- |
| `--profile` | AWS CLI profile | -- | `AWS_PROFILE` |
| `--s3Bucket` | S3 bucket to mount via S3 Files | -- | -- |
| `--s3MountPath` | Local mount path for S3 Files | `/var/task` | -- |
| `--s3KeyPrefix` | S3 key prefix to mount | -- | -- |

**Note:** The `--role` flag is only required when creating a new function. When updating an existing function, the role is preserved from the original configuration.

## Full Workflow Example

This example demonstrates the complete build-push-deploy cycle for a Lambda function.

```bash
# Set AWS credentials
export AWS_ACCOUNT_ID=123456789012
export AWS_REGION=us-west-2

# Step 1: Build the Docker image
# This creates a container image with your aux4 command packaged for Lambda
aux4 aux4 lambda build "process-orders" \
  --tag order-processor \
  --mode HTTP \
  --packages "aux4/config"

# Step 2: Push to ECR
# Creates the ECR repository if it doesn't exist, then pushes the image
aux4 aux4 lambda push order-processor \
  --repository order-processor \
  --imageTag v1.0.0

# Step 3: Deploy to Lambda
# Creates the function if new, or updates the image if it already exists
aux4 aux4 lambda deploy order-processor \
  --repository order-processor \
  --imageTag v1.0.0 \
  --role arn:aws:iam::123456789012:role/lambda-execution-role
```

### Updating an existing function

When deploying a new version of an existing Lambda function, only the build-push-deploy steps are needed. The `--role` flag can be omitted since the function already has a role assigned:

```bash
# Build new version
aux4 aux4 lambda build "process-orders" --tag order-processor --mode HTTP

# Push with new tag
aux4 aux4 lambda push order-processor \
  --repository order-processor \
  --imageTag v1.1.0

# Update the function
aux4 aux4 lambda deploy order-processor \
  --repository order-processor \
  --imageTag v1.1.0
```

## S3 Files Integration

Instead of baking the `.aux4` file into the Docker image, you can use [Amazon S3 Files](https://docs.aws.amazon.com/lambda/latest/dg/s3-files.html) to mount an S3 bucket directly into the Lambda filesystem. Reads and writes are synced automatically.

Upload your `.aux4` and any supporting files to S3, then deploy with the S3 Files flags:

```bash
# Upload .aux4 and config files to S3
aws s3 sync ./config/ s3://my-bucket/my-function/

# Build the image without baking .aux4 (it comes from S3)
aux4 aux4 lambda build "process-orders" --tag order-processor --mode HTTP

# Push to ECR
aux4 aux4 lambda push order-processor --repository order-processor

# Deploy with S3 Files mount
aux4 aux4 lambda deploy order-processor \
  --repository order-processor \
  --role arn:aws:iam::123456789012:role/lambda-execution-role \
  --s3Bucket my-bucket \
  --s3KeyPrefix my-function/
```

The S3 bucket is mounted at `/var/task` by default, making the `.aux4` file available where aux4 expects it. Use `--s3MountPath` to change the mount location.

Commands can reference files from the S3 mount using `${packageDir}`:

```json
{
  "name": "process-orders",
  "execute": [
    "cat ${packageDir}/templates/email.html",
    "echo 'processed' > ./result.txt"
  ]
}
```

Files written to the mount path are synced back to S3 automatically.

## License

Apache-2.0. See [LICENSE](./LICENSE) for details.
