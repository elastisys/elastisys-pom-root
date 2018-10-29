#!/bin/bash

set -e

BASE_POM_REPO_ID="oss-repo"
BASE_POM_REPO="https://oss.sonatype.org/service/local/staging/deploy/maven2/"

cd $(dirname $0)

echo "Making sure git repo is up-to-date ..."
git pull

version=$(mvn --quiet -Dexec.executable=echo -Dexec.args='${project.version}' --non-recursive exec:exec)
echo -n "New version (current: ${version}): "
read new_version
mvn versions:set -DnewVersion=${new_version} --quiet

# Tag and push changes to remote
git add -p
git commit -m "Bump from ${version} to ${new_version}"
git push
git tag ${new_version}
git push origin ${new_version}


# Deploy POMs!

echo -n "GPG key passphrase: "
read -s gpg_passphrase

mvn -Dgpg.passphrase=${gpg_passphrase} clean package gpg:sign \
  deploy -DaltDeploymentRepository=${BASE_POM_REPO_ID}::default::${BASE_POM_REPO}
