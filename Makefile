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

create-secrets: ## create-secrets
create-secrets:
	cluster=kind-prod
	privatekey=secrets/clusters/$${cluster}/sealed-secrets-private-key.yaml

# initialize temp directory
# define TMP as global thanks declare
	declare TMP=$$(mktemp --directory /tmp/kind.XXXXXXXXXX)
# remove directory thanks signals
	trap "rm -Rf $$TMP" SIGINT SIGTERM ERR EXIT
# export TMP in order to use it in subprocess
	export TMP

	for app in secrets/cluster-addons/*; do
		tempfile=$$(mktemp $${TMP:-/tmp}/hosts.XXXXXXXXXX)
		trap "rm -Rf $$tempfile" 0 2 3 15
		app=$$(basename $$app)
		build=$$(kustomize build secrets/cluster-addons/$${app}/overlays/$${cluster}/ | yq -ojson | jq -s | jq '.[] | select(.kind == "Secret")' | jq -s | jq -c )
		for row in $$(echo "$$build" | jq -rc '.[]'); do
			echo "$$row" | yq e -P | kubeseal --cert <(yq '.data."tls.crt"' $${privatekey} | base64 -d) --format yaml >> $$tempfile
			echo "---" >> $$tempfile
		done

		sed -i '$$d' $$tempfile
		cat "$$tempfile" > cluster-addons/$${app}/overlays/$${cluster}/secrets.yaml
	done
