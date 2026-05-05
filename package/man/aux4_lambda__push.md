#### Description

The `push` command publishes a local Docker image to an AWS ECR repository. Before pushing, it ensures the ECR repository exists by calling `aux4 registry aws create`. If the repository already exists, the create step succeeds without changes (idempotent). It then delegates to `aux4 registry aws push`, which handles ECR authentication, tagging, and pushing.

The `tag` argument (positional) is the local Docker image tag to push. The `--repository` flag specifies the target ECR repository name. If `--imageTag` is not provided, it defaults to `latest`.

AWS credentials are resolved from flags, environment variables, or the AWS CLI profile in this order:

- `--region` / `AWS_REGION` (default: `us-east-1`)
- `--accountId` / `AWS_ACCOUNT_ID`
- `--profile` / `AWS_PROFILE`

#### Usage

```bash
aux4 aux4 lambda push <tag> --repository <name> [--imageTag <tag>] [--region <region>] --accountId <account-id> [--profile <profile>]
```

tag          The local Docker image tag to push (positional, required)
--repository The ECR repository name (required)
--imageTag   The image tag for ECR (default: latest)
--region     AWS region (default: us-east-1, env: AWS_REGION)
--accountId  AWS account ID (required, env: AWS_ACCOUNT_ID)
--profile    AWS CLI profile (env: AWS_PROFILE)

#### Example

```bash
aux4 aux4 lambda push order-processor --repository order-processor --imageTag v1.0.0 --accountId 123456789012
```

```text
Login Succeeded
The push refers to repository [123456789012.dkr.ecr.us-east-1.amazonaws.com/order-processor]
v1.0.0: digest: sha256:abc123... size: 1234
```
