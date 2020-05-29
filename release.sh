#!/bin/bash

set -e

helm lint charts/app1
helm lint charts/app2
helm package charts/app1
helm package charts/app2

helm repo index . --url https://xantrix.github.io/test-helm-repo
