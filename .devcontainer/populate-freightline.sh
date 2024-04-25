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

## Promote 0.1.0 all the way to prod.
FREIGHT=$(kargo get freight --project kargo-demo -o jsonpath='{.metadata.name}' --alias flying-monkey)
for stage in test uat prod
do
	PROMOTION=$(kargo promote --project kargo-demo --freight ${FREIGHT} --stage ${stage} -o jsonpath='{.metadata.name}')
	kubectl wait --for jsonpath='{.status.phase}'=Succeeded promotions.kargo.akuity.io ${PROMOTION} -n kargo-demo --timeout=60s
	kubectl wait --for jsonpath='{.status.currentFreight.name}'=${FREIGHT} stages.kargo.akuity.io ${stage} -n kargo-demo --timeout=60s
	## Until we get --wait in promotion we have to do the following: Track https://github.com/akuity/kargo/issues/1888
	PROMOTION_COUNTER=0
	until [[ $(kubectl get freights.kargo.akuity.io -n kargo-demo ${FREIGHT} -o jsonpath='{.status.verifiedIn}' | grep -c ${stage}) -ne 0 ]]
	do
		[[ ${PROMOTION_COUNTER} -gt 6 ]] && echo "Promotion took too long to verify" && exit 13
		echo "waiting for promotion to be verified (${PROMOTION_COUNTER}/${PROMOTION_COUNTER_MAX})"
		PROMOTION_COUNTER=$((PROMOTION_COUNTER+1))
		sleep 5
	done
done

## Promote 0.2.0 to test and uat.
FREIGHT=$(kargo get freight --project kargo-demo -o jsonpath='{.metadata.name}' --alias sprinting-chipmunk)
for stage in test uat
do
	PROMOTION=$(kargo promote --project kargo-demo --freight ${FREIGHT} --stage ${stage} -o jsonpath='{.metadata.name}')
	kubectl wait --for jsonpath='{.status.phase}'=Succeeded promotions.kargo.akuity.io ${PROMOTION} -n kargo-demo --timeout=60s
	kubectl wait --for jsonpath='{.status.currentFreight.name}'=${FREIGHT} stages.kargo.akuity.io ${stage} -n kargo-demo --timeout=60s
	## Until we get --wait in promotion we have to do the following: Track https://github.com/akuity/kargo/issues/1888
	PROMOTION_COUNTER=0
  PROMOTION_COUNTER_MAX=6
	until [[ $(kubectl get freights.kargo.akuity.io -n kargo-demo ${FREIGHT} -o jsonpath='{.status.verifiedIn}' | grep -c ${stage}) -ne 0 ]]
	do
		[[ ${PROMOTION_COUNTER} -gt ${PROMOTION_COUNTER_MAX} ]] && echo "Promotion took too long to verify" && exit 13
		echo "waiting for promotion to be verified (${PROMOTION_COUNTER}/${PROMOTION_COUNTER_MAX})"
		PROMOTION_COUNTER=$((PROMOTION_COUNTER+1))
		sleep 5
	done
done

## Promote 0.3.0 to test and uat.
FREIGHT=$(kargo get freight --project kargo-demo -o jsonpath='{.metadata.name}' --alias screaming-dolphin)
kargo promote --project kargo-demo --freight ${FREIGHT} --stage test -o jsonpath='{.metadata.name}'