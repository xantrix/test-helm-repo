ARCH := $(shell uname | tr '[:upper:]' '[:lower:]')
#k3s: https://hub.docker.com/r/rancher/k3s/tags?page=1
#k3d: https://github.com/rancher/k3d/tags
#kubectl: https://github.com/kubernetes/kubectl/tags
K3S_VERSION := v1.18.2-k3s1
KUBECTL_VERSION := v1.18.2
K3D_VERSION := 1.7.0
K3D_NAME := k3s-cluster-local

local-dev/kubectl:
	$(info downloading kubectl version $(KUBECTL_VERSION) for $(ARCH))
	curl -Lo local-dev/kubectl https://storage.googleapis.com/kubernetes-release/release/$(KUBECTL_VERSION)/bin/$(ARCH)/amd64/kubectl
	chmod a+x local-dev/kubectl

local-dev/k3d:
	$(info downloading k3d version $(K3D_VERSION) for $(ARCH))
	curl -Lo local-dev/k3d https://github.com/rancher/k3d/releases/download/v$(K3D_VERSION)/k3d-$(ARCH)-amd64
	chmod a+x local-dev/k3d

k3d: local-dev/k3d local-dev/kubectl 
	$(info starting k3d with name $(K3D_NAME))
	./local-dev/k3d ct
	./local-dev/k3d create --wait 0 --publish 18080:80 \
		--publish 18443:443 \
		--api-port 16643 \
		--name $(K3D_NAME) \
		--image docker.io/rancher/k3s:$(K3S_VERSION) \
		-x --no-deploy=traefik \
		--volume $$PWD/local-dev/k3d-nginx-ingress.yaml:/var/lib/rancher/k3s/server/manifests/k3d-nginx-ingress.yaml
	echo "$(K3D_NAME)" > $@

k3d-kubeconfig:
	export KUBECONFIG="$$(./local-dev/k3d get-kubeconfig --name=$$(cat k3d))"

# Stop and start cluster
.PHONY: k3d/stop-cluster
k3d/stop-cluster:
	./local-dev/k3d stop --name=$$(cat k3d) || true

.PHONY: k3d/start-cluster
k3d/start-cluster:
	./local-dev/k3d start --name=$$(cat k3d) || true

# Delete cluster
.PHONY: k3d/delete
k3d/delete: local-dev/k3d
	./local-dev/k3d delete --name=$$(cat k3d) || true
	rm -f k3d