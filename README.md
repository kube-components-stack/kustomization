# kustomization

## structure
```
.
├── cluster-addons.yaml
├── cluster-addons
│   ├── addon-01
│   │   ├── base
│   │   │   ├── helm-generator.yaml
│   │   │   ├── kustomization.yaml
│   │   │   └── namespace.yaml
│   │   └── overlays
│   │       ├── kind-dev
│   │       │   ├── kustomization.yaml
│   │       │   ├── secrets.yaml
│   │       │   └── values.yaml
│   │       └── kind-prod
│   │           ├── kustomization.yaml
│   │           ├── secrets.yaml
│   │           └── values.yaml
│   ...
│   │
│   └── addon-0x
│       ├── base
│       │   ├── helm-generator.yaml
│       │   ├── kustomization.yaml
│       │   └── namespace.yaml
│       └── overlays
│           ├── kind-dev
│           │   └── kustomization.yaml
│           └── kind-prod
│               ├── kustomization.yaml
│               ├── secrets.yaml
│               └── values.yaml
├── crd.yaml
├── crds
│   ├── crd-01
│   │   ├── base
│   │   │   └── kustomization.yaml
│   │   └── overlays
│   │       ├── kind-dev
│   │       │   └── kustomization.yaml
│   │       └── kind-prod
│   │           └── kustomization.yaml
│   ...
│   └── crd-0x
│       ├── base
│       │   └── kustomization.yaml
│       └── overlays
│           ├── kind-dev
│           │   └── kustomization.yaml
│           └── kind-prod
│               └── kustomization.yaml
├── Makefile
├── README.md
├── scripts
│   └── tools
└── secrets
    ├── clusters
    │   └── kind-prod
    │       └── sealed-secrets-private-key.yaml
    └── README.md
```

## declare vars and create directory structure and files
```zsh
addon=sealed-secrets
cluster=kind
namespace=kube-system

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
