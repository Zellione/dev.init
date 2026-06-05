#!/usr/bin/env bash
# Wrapper: Linux has no setup scripts (runs/ is empty).
set -euo pipefail

export DEV_ENV="$(cd "$(dirname "$0")" && pwd)/linux"
source "$(dirname "$0")/run.sh"
run_scripts ""
