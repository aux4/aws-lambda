#!/bin/sh

PROFILE="prod-aux4-deployer"
REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --profile ${PROFILE} --query Account --output text)
ROLE="arn:aws:iam::${ACCOUNT_ID}:role/aux4-lambda-test-role"

COMMANDS="hello greet echo-stdin fail both"

for cmd in ${COMMANDS}; do
  NAME="aux4-lambda-test-${cmd}"
  echo "=== Building ${NAME} ==="
  aux4 aux4 lambda build ${cmd} --tag ${NAME} --dir test

  echo "=== Pushing ${NAME} ==="
  aux4 aux4 lambda push ${NAME} --repository ${NAME} --accountId ${ACCOUNT_ID} --profile ${PROFILE} --region ${REGION}

  echo "=== Deploying ${NAME} ==="
  aux4 aux4 lambda deploy ${NAME} --repository ${NAME} --accountId ${ACCOUNT_ID} --role ${ROLE} --profile ${PROFILE} --region ${REGION}

  echo ""
done

echo "Done. Run ./test/test.sh to invoke the functions."
