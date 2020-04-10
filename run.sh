#!/usr/bin/env bash
# Usage:
#  ./run.sh build TARGET
#  ./run.sh run TARGET

set -e
source "secrets.txt"

COMMAND=$1
NIX_TARGET=$2

if [ "$HSLUV_RUNTIME" == "docker" ]; then
  # Docker wrapper, always begin by rebuilding image
  docker build -t hsluv .

  if [ "$COMMAND" == "build" ]; then
    docker build -t hsluv .
    echo "Deleting $PWD/result_docker"
    sudo rm -rf result_docker
    docker run -it --mount src="$PWD",target=/home/nix/hsluv,type=bind hsluv bash -c "nix-build -A $NIX_TARGET && cp -R -L result result_docker"
    echo "Built: $PWD/result_docker"
  fi

  if [ "$COMMAND" == "run" ]; then
    docker build -t hsluv .
    docker run -it -p 8000:8000 --mount src="$PWD",target=/home/nix/hsluv,type=bind hsluv bash -c "./run.sh run $NIX_TARGET"
  fi
else
  # Native Nix runtime
  if [ "$COMMAND" == "build" ]; then
    nix-build -A "$NIX_TARGET"
  fi

  if [ "$COMMAND" == "run" ]; then
    # This is a special Nix target that outputs a bash script
    nix-build -A "$NIX_TARGET"
    exec "result/bin/script.sh"
  fi
fi
