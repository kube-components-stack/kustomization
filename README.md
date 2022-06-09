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
addon=ingress-nginx
cluster=kind

mkdir -p cluster-addons/$addon/{overlays/$cluster-{dev,prod},base}
touch cluster-addons/$addon/{base/{helm-generator.yaml,kustomization.yaml,namespace.yaml},overlays/$cluster-{dev,prod}/{kustomization.yaml,values.yaml}}

cat << EOF > cluster-addons/$addon/base/helm-generator.yaml
apiVersion: builtin
kind: HelmChartInflationGenerator
metadata:
  name: $addon-helm-chart
name: $addon
version: ""
repo: ""
releaseName: $addon
valuesFile: values.yaml
valuesInline: {}
valuesMerge: override                 # merge, override or replace
includeCRDs: false
EOF

cat << EOF > cluster-addons/$addon/base/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: $addon
EOF

cat << EOF > cluster-addons/$addon/base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: $addon
resources:
- namespace.yaml
EOF

cat << EOF > cluster-addons/$addon/overlays/$cluster-{dev,prod}/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
bases:
- ../../base
generators:
- ../../base/helm-generator.yaml
EOF
```