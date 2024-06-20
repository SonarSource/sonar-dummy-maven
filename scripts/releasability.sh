#!/bin/bash
set -xeuo pipefail

description=$(echo "$OUTPUTS" | jq ".statuses[].description")

echo $description
