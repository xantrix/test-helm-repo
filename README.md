# test-helm-repo

helm repo add test-helm-repo https://xantrix.github.io/test-helm-repo
helm repo list

helm install test1 test-helm-repo/app1

./local-dev/kubectl get all

helm uninstall test1

# use GH_PAT
