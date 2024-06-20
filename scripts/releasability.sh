#!/bin/bash
set -xeuo pipefail

outputs="$1"

description=$(echo "$outputs" | jq ".statuses[].description")

echo $description
