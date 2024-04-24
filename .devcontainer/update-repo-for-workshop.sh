#!/bin/bash
workspace="/workspaces/$(basename ${GITHUB_REPOSITORY})"

## Check to see if you're in the right path
## This protects against updating the template while working on the template repo.
## TODO: This will fail if users are doing this "outside" of GitHub. Need a way to "normalize it"
if [[ ! -d ${workspace} ]] ; then
    echo "FATAL: Unable to verify current working directory"
    exit 3
fi

## Check to see if the ${GITHUB_REPOSITORY} env is set (best effort)
## TODO: This will fail if users are doing this "outside" of GitHub. Need a way to "normalize it"
if [[ -z ${GITHUB_REPOSITORY} ]] ; then
    echo "FATAL: The GITHUB_REPOSITORY env var is not set"
    exit 3
fi

## Search for <repo> and replace it with 
find ${workspace} -name '*.yaml' -type f -exec grep -l '<repo>' {} \; | while read file
do
    sed -i "s?<repo>?${GITHUB_REPOSITORY}?g" ${file}
done

## Now that the files are updated, we commit it and push it up. Best effort :cross_fingers_emoji:
cd ${workspace}
git add .
git commit -am "updated source to point to ${GITHUB_REPOSITORY}"
git push origin main

## Update the freight placeholders
COMMIT_SHA=$(git rev-parse HEAD)

kubectl apply -f - <<EOF
alias: flying-monkey
apiVersion: kargo.akuity.io/v1alpha1
commits:
- branch: main
  id: ${COMMIT_SHA}
  message: 'updated source to point to ${GITHUB_REPOSITORY}'
  repoURL: https://github.com/${GITHUB_REPOSITORY}
images:
- digest: sha256:57f27650e10ae33978bc14c80c90b7688ecad3950b308d1ec157c9495ebcefc4
  repoURL: quay.io/akuity/argo-cd-learning-assets/guestbook
  tag: 0.1.0
kind: Freight
metadata:
  labels:
    kargo.akuity.com/v0.5-compatible: "true"
    kargo.akuity.io/alias: flying-monkey
  name: placeholder-0.1.0
  namespace: kargo-demo
warehouse: kargo-demo
---
alias: sprinting-chipmunk
apiVersion: kargo.akuity.io/v1alpha1
commits:
- branch: main
  id: ${COMMIT_SHA}
  message: 'updated source to point to ${GITHUB_REPOSITORY}'
  repoURL: https://github.com/${GITHUB_REPOSITORY}
images:
- digest: sha256:57f27650e10ae33978bc14c80c90b7688ecad3950b308d1ec157c9495ebcefc4
  repoURL: quay.io/akuity/argo-cd-learning-assets/guestbook
  tag: 0.2.0
kind: Freight
metadata:
  labels:
    kargo.akuity.com/v0.5-compatible: "true"
    kargo.akuity.io/alias: sprinting-chipmunk
  name: placeholder-0.2.0
  namespace: kargo-demo
warehouse: kargo-demo
---
alias: screaming-dolphin
apiVersion: kargo.akuity.io/v1alpha1
commits:
- branch: main
  id: ${COMMIT_SHA}
  message: 'updated source to point to ${GITHUB_REPOSITORY}'
  repoURL: https://github.com/${GITHUB_REPOSITORY}
images:
- digest: sha256:57f27650e10ae33978bc14c80c90b7688ecad3950b308d1ec157c9495ebcefc4
  repoURL: quay.io/akuity/argo-cd-learning-assets/guestbook
  tag: 0.3.0
kind: Freight
metadata:
  labels:
    kargo.akuity.com/v0.5-compatible: "true"
    kargo.akuity.io/alias: screaming-dolphin
  name: placeholder-0.3.0
  namespace: kargo-demo
warehouse: kargo-demo
EOF

## Exit with 0 for the post-start script
exit 0
