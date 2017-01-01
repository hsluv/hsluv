#!/usr/bin/env bash

scripts=`dirname ${0}`
root=`dirname ${scripts}`
default="${root}/default.nix"
nuget=`nix-build -A nuget --no-out-link ${default}`
python3=`nix-build -A python3 --no-out-link ${default}`
csharpDist=`nix-build -A csharpDist --no-out-link ${default}`

PATH="${nuget}/bin:$PATH"
PATH="${python3}/bin:$PATH"

source "${root}/secrets.txt"

# Nuget fails with absolute path: https://github.com/NuGet/Home/issues/2167
csharpDist=$(python3 -c "import os.path; print(os.path.relpath('${csharpDist}'))")

nuget push -ApiKey "${NUGET_API_KEY}" /${csharpDist}/*.nupkg
