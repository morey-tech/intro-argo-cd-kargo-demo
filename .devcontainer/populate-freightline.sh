## Pre-populate the freightline

## Get previous commit sha (which should be the one with the repo url update).
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
- digest: sha256:35c9e5211be0b107e4d6b443878d5175689bd136566fecd482a7b30c49a14b84
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
- digest: sha256:a54aeaf135e4f14b3ffbc3e843663e4e8e26fe16d1af7bd82828a458325a74d6
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