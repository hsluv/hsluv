#!/usr/bin/env bash

scripts=`dirname ${0}`
root=`dirname ${scripts}`

# Use OpenSSL from nixpkgs if available
if [ -x "$(command -v nix-shell)" ];
then
    default="${root}/default.nix"
    openssl=`nix-build -A openssl --no-out-link ${default}`
    PATH="${openssl}/bin:$PATH"
fi

opensslBin="$(command -v openssl)"
if [ -x "${opensslBin}" ];
then
    echo "Using openssl: ${opensslBin}"
else
    echo "ERROR: Could not find openssl binary"
    exit 1
fi

secretsTxt="${root}/secrets.txt"
symmetricEnc="${root}/secrets/symmetric.enc.txt"
secretsEnc="${root}/secrets/secrets.enc.txt"

command="$1"
if [ "${command}" = "--encrypt" ];
then
    echo "Generating symmetric key  ..."
    symmetric=`openssl rand -hex 32`

    echo "Encrypting symmetric key  ..."
    echo "${symmetric}" \
        | openssl rsautl -encrypt -inkey ${root}/secrets/public/boronine.pem -pubin \
        | openssl enc -base64 \
        > ${symmetricEnc}

    echo "Encrypting secrets.txt    ..."
    cat ${secretsTxt} \
        | openssl enc -aes-256-cbc -salt -pass pass:${symmetric} \
        | openssl enc -base64 \
        > ${secretsEnc}

    echo "Symmetric key:  ${symmetricEnc}"
    echo "Secrets:        ${secretsEnc}"
elif [ "${command}" = "--decrypt" ];
then
    privateKey="$2"
    if [ -f "${privateKey}" ];
    then
        echo "Decrypting symmetric key ..."
        symmetric=$(cat ${symmetricEnc} \
            | openssl enc -base64 -d \
            | openssl rsautl -inkey ${privateKey} -decrypt)
        echo "Decrypting secrets.txt ..."
        cat ${secretsEnc} \
            | openssl enc -base64 -d \
            | openssl enc -d -aes-256-cbc -pass pass:${symmetric} \
            > ${secretsTxt}

    else
        echo "ERROR: Missing or invalid PRIVATE_KEY"
        exit 1
    fi

else
    echo "ERROR: Missing command: --encrypt or --decrypt PRIVATE_KEY"
    exit 1
fi
