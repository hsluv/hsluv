#!/usr/bin/env bash

HSLUV_ROOT="$(dirname ${0})"
SCRIPT_DIR="$(nix-build -A ${1} --no-out-link ${HSLUV_ROOT}/default.nix)"
source "${HSLUV_ROOT}/secrets.txt"
exec "${SCRIPT_DIR}/bin/run.sh"
