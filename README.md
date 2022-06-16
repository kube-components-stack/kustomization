# kustomization

## structure
```
.
├── cluster-addons
│   ├── ingress-nginx
│   │   ├── base
│   │   │   ├── helm-generator.yaml
│   │   │   ├── kustomization.yaml
│   │   │   └── namespace.yaml
│   │   └── overlays
│   │       ├── kind-dev
│   │       │   ├── kustomization.yaml
│   │       │   └── values.yaml
│   │       └── kind-prod
│   │           ├── kustomization.yaml
│   │           └── values.yaml
│   └── metallb
│       ├── base
│       │   ├── helm-generator.yaml
│       │   ├── kustomization.yaml
│       │   └── namespace.yaml
│       └── overlays
│           ├── kind-dev
│           │   ├── kustomization.yaml
│           │   └── values.yaml
│           └── kind-prod
│               ├── kustomization.yaml
│               └── values.yaml
└── kube-components-stack.yaml
```

## declare vars and create directory structure and files
```zsh
addon=kyverno
cluster=kind
namespace=kyverno

mkdir -p cluster-addons/$addon/{overlays/$cluster-{dev,prod},base}
touch cluster-addons/$addon/{base/{helm-generator.yaml,kustomization.yaml,namespace.yaml},overlays/$cluster-{dev,prod}/{kustomization.yaml,secrets.yaml,values.yaml}}

cat << EOF > cluster-addons/$addon/base/helm-generator.yaml
apiVersion: builtin
kind: HelmChartInflationGenerator
metadata:
  name: $addon-helm-chart
name: &name $addon
version: ""
repo: ""
releaseName: *name
namespace: $namespace
includeCRDs: false
valuesFile: values.yaml
valuesMerge: override                 # merge, override or replace
valuesInline: {}
EOF

cat << EOF > cluster-addons/$addon/base/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: $namespace
EOF

cat << EOF > cluster-addons/$addon/base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: $namespace
resources:
- namespace.yaml
EOF

cat << EOF > cluster-addons/$addon/overlays/$cluster-{dev,prod}/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: $namespace
generators:
- ../../base/helm-generator.yaml
resources:
- ../../base
- secrets.yaml
EOF
```

```zsh
kustomize --enable-alpha-plugins --enable-helm --load-restrictor LoadRestrictionsNone build cluster-addons/cert-manager/overlays/kind-prod | yq -ojson | jq -s | jq '. | sort_by(.kind, .metadata.name)' | jq --sort-keys | yq e -P > bad.yaml

| grep cert-manager-cainjector:leaderelection -A1

yq e ".valuesInline" cluster-addons/cert-manager/base/helm-generator.yaml > /tmp/values.yaml
helm template \
--kube-context kind-pclinux003 \
--namespace cert-manager \
--values /tmp/values.yaml \
--version v1.6.1 \
--disable-openapi-validation \
--set prometheus.servicemonitor.enabled=false \
cert-manager cert-manager/cert-manager | yq -ojson | jq -s | jq '. | sort_by(.kind, .metadata.name)' | jq --sort-keys | yq e -P > good.yaml
```

kustomize --enable-alpha-plugins --enable-helm --load-restrictor LoadRestrictionsNone build cluster-addons/cert-manager/overlays/kind-prod | yq -ojson | jq -s | jq '. | sort_by(.kind, .metadata.name)' | jq --sort-keys | yq e -P | grep cert-manager-cainjector:leaderelection -A1