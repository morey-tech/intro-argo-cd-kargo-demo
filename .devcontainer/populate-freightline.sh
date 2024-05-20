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
EOF

kubectl apply -f - <<EOF
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
EOF

kubectl apply -f - <<EOF
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

promote_freight_to_stages () {
  for stage in $1
  do
    PROMOTION=$(kargo promote --project kargo-demo --freight $2 --stage ${stage} -o jsonpath='{.metadata.name}')
    ## Until we get --wait in promotion we have to do the following: Track https://github.com/akuity/kargo/issues/1888
    kubectl wait --for jsonpath='{.status.phase}'=Succeeded promotions.kargo.akuity.io ${PROMOTION} -n kargo-demo --timeout=60s
    kubectl wait --for jsonpath='{.status.currentFreight.name}'=$2 stages.kargo.akuity.io ${stage} -n kargo-demo --timeout=60s
    PROMOTION_COUNTER=0
    PROMOTION_COUNTER_MAX=10
    PROMOTION_WAIT_SLEEP=10
    until [[ $(kubectl get freights.kargo.akuity.io -n kargo-demo $2 -o jsonpath='{.status.verifiedIn}' | grep -c ${stage}) -ne 0 ]]
    do
      [[ ${PROMOTION_COUNTER} -gt ${PROMOTION_COUNTER_MAX} ]] && echo "Promotion took too long to verify" && exit 13
      echo "sleeping for ${PROMOTION_WAIT_SLEEP}, waiting for promotion of ${FREIGHT} to ${stage} to be verified (${PROMOTION_COUNTER}/${PROMOTION_COUNTER_MAX})"
      PROMOTION_COUNTER=$((PROMOTION_COUNTER+1))
      sleep ${PROMOTION_WAIT_SLEEP}
      # Ensure stage is refreshed after sleep for next check.
      kargo refresh stage --project=kargo-demo ${stage}
    done
  done
}

## Promote 0.1.0 all the way to prod.
FREIGHT=$(kargo get freight --project kargo-demo -o jsonpath='{.metadata.name}' --alias flying-monkey)
promote_freight_to_stages 'test uat prod' ${FREIGHT}

## Promote 0.2.0 to test and uat.
FREIGHT=$(kargo get freight --project kargo-demo -o jsonpath='{.metadata.name}' --alias sprinting-chipmunk)
promote_freight_to_stages 'test uat' ${FREIGHT}

## Promote 0.3.0 to test.
FREIGHT=$(kargo get freight --project kargo-demo -o jsonpath='{.metadata.name}' --alias screaming-dolphin)
promote_freight_to_stages 'test' ${FREIGHT}