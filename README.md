[![CI](https://github.com/hsluv/hsluv/actions/workflows/ci.yml/badge.svg)](https://github.com/hsluv/hsluv/actions/workflows/ci.yml)

# HSLuv - Human-friendly HSL

This website is hosted on [https://www.hsluv.org](https://www.hsluv.org)

The reference implementation is [written in Haxe](https://github.com/hsluv/hsluv-haxe).

To build website:

```
npm run build
```

To start localhost server:

```
npm run serve
```

## Shared credentials

We are using public key cryptography to share credentials. Contributors' public keys are
stored in PEM format in `secrets/public`. A plaintext `secrets.txt` file, which is ignored
by git, is encrypted using each of these public keys and stored in the repo in its encrypted
form. It can be decrypted by anyone posessing a private key that corresponds to one of the
shared public keys.

To decrypt secrets (overwriting `secrets.txt`):

```bash
./secrets.sh --decrypt ~/.ssh/myprivatekey secrets/symmetric/myusername.enc.txt
```

After updating `secrets.txt` or adding a new PEM file to `secrets/public`, secrets need to be
re-encrypted. To encrypt secrets:

```bash
./secrets.sh --encrypt
```

Don't forget to commit re-encrypted secrets after running the command above.

### PEM files

To generate PEM file from public key:

```bash
ssh-keygen -f ~/.ssh/id_rsa.pub -e -m PKCS8 > myusername.pem
```

### GPG key

To create signed packages (e.g. for Maven Central) we need a GPG key. A GPG key shared by all
the contributors is located in `secrets`. The private key is protected by a passphrase which
can be found in `secrets.txt`. Our shared key is set to expire in 1 year.

Generating GPG key:

```bash
gpg --gen-key
gpg --list-keys
gpg --output hsluvcontributors_pub.gpg --armor --export 381DF082
gpg --output hsluvcontributors_sec.gpg --armor --export-secret-key 381DF082
```
