#!/bin/bash
# Prerequisites
# - python 3.7
set -euo pipefail

pip3 install -U checkov > /dev/null 2>&1
export LOG_LEVEL=INFO
CHECK_STATUS=0

set +e

checkov --config-file ./scripts/checkov.yaml -d . --compact --quiet
if [ $? -ne 0 ]; then
   printf "=== FAILED ===\n\n"
   CHECK_STATUS=1
else
   printf "=== SUCCEEDED ===\n\n"
fi

exit $CHECK_STATUS
