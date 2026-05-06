#!/bin/sh

PROFILE="prod-aux4-deployer"
REGION="us-east-1"

echo "=== Test 1: single param (hello) ==="
aux4 aux4 lambda invoke aux4-lambda-test-hello --name David --profile ${PROFILE} --region ${REGION}
echo ""

echo "=== Test 2: multiple params (greet) ==="
aux4 aux4 lambda invoke aux4-lambda-test-greet --firstName David --lastName Gouvea --profile ${PROFILE} --region ${REGION}
echo ""

echo "=== Test 3: stdin passthrough (echo-stdin) ==="
echo '{"message": "from stdin"}' | aux4 aux4 lambda invoke aux4-lambda-test-echo-stdin --profile ${PROFILE} --region ${REGION}
echo ""

echo "=== Test 4: stderr / failure (fail) ==="
aux4 aux4 lambda invoke aux4-lambda-test-fail --profile ${PROFILE} --region ${REGION}
echo ""

echo "=== Test 5: stdout and stderr (both) ==="
aux4 aux4 lambda invoke aux4-lambda-test-both --profile ${PROFILE} --region ${REGION}
echo ""
