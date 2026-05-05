#### Description

The `build` command creates a Lambda-compatible Docker image for an aux4 command. It delegates to `aux4 aux4 docker build lambda`, which uses a Lambda-specific Dockerfile to package your aux4 command into a container image that can run on AWS Lambda.

The `command` argument (positional) specifies the aux4 command the Lambda will execute at runtime. The `--tag` flag sets the local Docker image tag. The `--mode` flag controls how the Lambda processes events:

- **RAW** -- passes the raw Lambda event to the command
- **HTTP** -- processes API Gateway HTTP events
- **STEP_FUNCTIONS** -- processes Step Functions events

Use `--packages` to include additional aux4 packages in the image (comma-separated). The `--dir` flag specifies the build context directory.

#### Usage

```bash
aux4 aux4 lambda build <command> --tag <tag> [--mode <RAW|HTTP|STEP_FUNCTIONS>] [--packages <packages>] [--dir <path>]
```

command     The aux4 command to execute at runtime (positional, required)
--tag       The Docker image tag (required)
--mode      The Lambda execution mode (RAW, HTTP, STEP_FUNCTIONS)
--packages  aux4 packages to install, separated by commas
--dir       The directory to build from (default: .)

#### Example

```bash
aux4 aux4 lambda build "process-orders" --tag order-processor --mode HTTP --packages "aux4/config"
```

```text
[+] Building 12.3s (15/15) FINISHED
 => => naming to docker.io/library/order-processor
```
