# Make defaults
.DEFAULT_GOAL := help
.SILENT: update-charts grafana-patch-dashboard create-secrets
SHELL := bash
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
.ONESHELL:
MAKEFLAGS += --no-print-directory

# Make variables
SHELL := /bin/bash
ENVFILE := .env

help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'

kyverno-update-crds: ## kyverno-update-crds
kyverno-update-crds:
	version=2.5.0
	curl -L https://raw.githubusercontent.com/kyverno/kyverno/kyverno-chart-v$${version}/charts/kyverno/templates/crds.yaml | sed -r "/^\{\{/d" > crds/kyverno/base/crds.yaml

grafana-update-dashboard: ## grafana-update-dashboard
grafana-update-dashboard:
	set -e
	cd $(ROOT_DIR)
	source scripts/tools
# 	update default kube-prometheus-stack dashboards & patch them
	render_dashboards_from_helm_template
# 	ArgoCD
	dl_dashboard --id=14584 --revision=1 --tags=gitops --argocd-notifications
#	Kubernetes - kube-dns
	dl_dashboard --id=12321 --revision=2 --tags=Prometheus --argocd-notifications
#	Logs / App
	dl_dashboard --id=13639 --revision=2 --tags=Loki --tags=Prometheus --tags=logs --tags=app --argocd-notifications
#	Node Overview
	dl_dashboard --id=13824 --revision=2 --tags=Prometheus --argocd-notifications
#	Container resources
	dl_dashboard --id=14678 --revision=1 --tags=Prometheus --argocd-notifications
#	kube-state-metrics-v2
	dl_dashboard --id=13332 --revision=12 --tags=Prometheus --argocd-notifications
#	NGINX Ingress controller
	dl_dashboard --id=9614 --revision=1 --tags=Prometheus --argocd-notifications
#	Kubernetes Nginx Ingress Prometheus NextGen
	dl_dashboard --id=14314 --revision=2 --tags=Prometheus --argocd-notifications
#	cert-manager
	dl_dashboard --id=11001 --revision=1 --tags=Prometheus --argocd-notifications
#	Loki & Promtail
	dl_dashboard --id=10880 --revision=1 --tags=Prometheus --argocd-notifications
#	Promtail 2.4.x
	dl_dashboard --id=15443 --revision=2 --tags=Prometheus --argocd-notifications
#	Loki Dashboard quick search
	dl_dashboard --id=12019 --revision=2 --tags=Loki --tags=Prometheus --argocd-notifications
#	Loki stack monitoring (Promtail, Loki)
	dl_dashboard --id=14055 --revision=5 --tags=Loki --tags=Prometheus --argocd-notifications
#	Analytics - NGINX / LOKI v2+ Data Source / Promtail v2+ Tool
	dl_dashboard --id=13865 --revision=6 --tags=Loki --tags=Prometheus --argocd-notifications
#	Troubleshooting Kubernetes (simple and fast view)
	dl_dashboard --id=15196 --revision=3 --tags=Loki --tags=Prometheus --argocd-notifications
#	Trivy Vulnerabilities
	dl_dashboard --id=12330 --revision=1 --tags=trivy --argocd-notifications
	dl_dashboard --id=12331 --revision=1 --tags=trivy --argocd-notifications
	dl_dashboard --id=16742 --revision=1 --tags=trivy --argocd-notifications


create-secrets: ## create-secrets
create-secrets:
	set -e
	cd $(ROOT_DIR)

	cluster=plato
	env=devncoargo
	
	privatekey=secrets/clusters/$${cluster}-$${env}/sealed-secrets-private-key.yaml

# initialize temp directory
# define TMP as global thanks declare
	declare TMP=$$(mktemp --directory /tmp/kind.XXXXXXXXXX)
# remove directory thanks signals
	trap "rm -Rf $$TMP" SIGINT SIGTERM ERR EXIT
# export TMP in order to use it in subprocess
	export TMP

	for namespace in secrets/cluster-addons/*; do
		namespace=$$(basename $$namespace)
		build=$$(kustomize --load-restrictor LoadRestrictionsNone build secrets/cluster-addons/$${namespace}/overlays/$${cluster}-$${env}/ | yq -ojson | jq -s | jq '.[] | select(.kind == "Secret")' | jq -s | jq -c )
		rows=$$(echo "$$build" | jq -rc '.[]')
		if [[ -n "$$rows" ]]; then
			tempfile=$$(mktemp $${TMP:-/tmp}/hosts.XXXXXXXXXX)
			trap "rm -Rf $$tempfile" 0 2 3 15
			for row in $$rows; do
				echo "$$row" | yq e -P | kubeseal --cert <(yq '.data."tls.crt"' $${privatekey} | base64 -d) --format yaml >> $$tempfile
				echo "---" >> $$tempfile
			done
			sed -i '$$d' $$tempfile
			sed -i '/^$$/d' $$tempfile
			cat "$$tempfile" > cluster-addons/$${namespace}/overlays/$${cluster}-$${env}/secrets.yaml
			cd cluster-addons/$${namespace}/overlays/$${cluster}-$${env}
			kustomize edit add resource secrets.yaml
			cd $$OLDPWD
		fi
	done

renovate: ## renovate
renovate:
	owner=$$(git config --get remote.origin.url|sed -r "s/^[^:]+:\/\/[^\/]+\/([^\/]+).*/\1/"|sed -r "s/^[^:]+:([^\/]+).*/\1/")
	repo=$$(git config --get remote.origin.url|sed -r "s/^[^:]+:\/\/[^\/]+\/[^\/]+\/([^\.]+).*/\1/"|sed -r "s/^[^:]+:[^\/]+\/([^\.]+).*/\1/")
	docker run \
		--rm \
		-e RENOVATE_TOKEN=$${GITHUB_PERSONAL_ACCESS_TOKEN} \
		-e RENOVATE_GIT_AUTHOR="$$(git config --get user.name) <$$(git config --get user.email)>" \
		-e RENOVATE_DRY_RUN=full \
		-e RENOVATE_PLATFORM=github \
		-e RENOVATE_REPOSITORIES=$${owner}/$${repo} \
		-e LOG_LEVEL=debug \
		-it renovate/renovate
