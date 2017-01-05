#!/usr/bin/env bash
set -e
# Make sure gpg-agent is killed even if the script fails
function cleanup {
    echo "Killing gpg-agent ..."
    gpgconf --kill gpg-agent
}
trap cleanup EXIT

scripts=`dirname ${0}`
root=`dirname ${scripts}`
default="${root}/default.nix"
maven=`nix-build -A maven --no-out-link ${default}`
gnupg=`nix-build -A gnupg --no-out-link ${default}`
javaSrc=`nix-build -A javaSrc --no-out-link ${default}`

PATH="${maven}/bin:${gnupg}/bin:$PATH"

tmpDir=`mktemp -d`
cp -R ${javaSrc}/* "${tmpDir}"

source "${root}/secrets.txt"

export GNUPGHOME="${tmpDir}"
echo "Starting gpg-agent ..."
eval "$(gpg-agent --daemon --quiet)"

echo "Importing shared GPG keys ..."
gpg2 --batch --import "${root}/secrets/hsluvcontributors_pub.gpg"
gpg2 --batch --passphrase "${GPG_KEY_PASSPHRASE}" --import "${root}/secrets/hsluvcontributors_sec.gpg"

settingsFile="${tmpDir}/settings.xml"
settings="<settings>
    <profiles>
        <profile>
            <id>ossrh</id>
            <activation>
                <activeByDefault>true</activeByDefault>
            </activation>
            <properties>
                <gpg.executable>${gnupg}/bin/gpg2</gpg.executable>
                <gpg.keyname>381DF082</gpg.keyname>
                <gpg.passphrase>${GPG_KEY_PASSPHRASE}</gpg.passphrase>
            </properties>
        </profile>
    </profiles>
    <servers>
        <server>
            <id>ossrh</id>
            <username>${SONATYPE_USERNAME}</username>
            <password>${SONATYPE_PASSWORD}</password>
        </server>
    </servers>
</settings>"

echo "${settings}" > "${settingsFile}"

cd "${tmpDir}"

mvn --global-settings "${settingsFile}" clean deploy
mvn --global-settings "${settingsFile}" nexus-staging:release
