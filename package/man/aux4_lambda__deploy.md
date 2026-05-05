#### Description

The `deploy` command creates or updates a Lambda function from a container image stored in ECR. It first checks whether the function already exists by calling `aws lambda get-function`. If the function exists, it updates the function code with the new image using `aws lambda update-function-code`. If the function does not exist, it creates a new one using `aws lambda create-function`.

The `functionName` argument (positional) is the Lambda function name. The `--repository` flag specifies the ECR repository containing the image, and `--imageTag` specifies which image tag to deploy (defaults to `latest`).

The `--role` flag provides the IAM role ARN for the Lambda function. This is required when creating a new function but is ignored when updating an existing one (the existing role is preserved).

AWS credentials are resolved from flags, environment variables, or the AWS CLI profile:

- `--region` / `AWS_REGION` (default: `us-east-1`)
- `--accountId` / `AWS_ACCOUNT_ID`
- `--profile` / `AWS_PROFILE`

#### Usage

```bash
aux4 aux4 lambda deploy <functionName> --repository <name> [--imageTag <tag>] [--region <region>] --accountId <account-id> [--role <role-arn>] [--profile <profile>]
```

functionName  The Lambda function name (positional, required)
--repository  The ECR repository name (required)
--imageTag    The image tag (default: latest)
--region      AWS region (default: us-east-1, env: AWS_REGION)
--accountId   AWS account ID (required, env: AWS_ACCOUNT_ID)
--role        The IAM role ARN for the Lambda function (required for new functions)
--profile     AWS CLI profile (env: AWS_PROFILE)

#### Example

Creating a new function:

```bash
aux4 aux4 lambda deploy order-processor \
  --repository order-processor \
  --imageTag v1.0.0 \
  --accountId 123456789012 \
  --role arn:aws:iam::123456789012:role/lambda-execution-role
```

Updating an existing function:

```bash
aux4 aux4 lambda deploy order-processor \
  --repository order-processor \
  --imageTag v1.1.0 \
  --accountId 123456789012
```
