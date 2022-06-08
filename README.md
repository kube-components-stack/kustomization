# kustomization

## tree
Git Generator: Files

├── cluster-addons
|   ├── metallb
|   |   ├── base
|   |   └── overlays
|   |       ├── kind-dev
|   |       |   ├── kustomization.yaml
|   |       |   └── values.yaml
|   |       └── kind-prod
|   |           ├── kustomization.yaml
|   |           └── values.yaml
|   └── ingress-nginx
|       ├── base
|       └── overlays
|           ├── kind-dev
|           |   ├── kustomization.yaml
|           |   └── values.yaml
|           └── kind-prod
|               ├── kustomization.yaml
|               └── values.yaml
└── kube-components-stack.yaml


addon=ingress-nginx
suffix=kind

mkdir -p cluster-addons/$addon/{overlays/$suffix-{dev,prod},base}

touch cluster-addons/$addon/{base/{helm-generator.yaml,kustomization.yaml,namespace.yaml},overlays/$suffix-{dev,prod}/{kustomization.yaml,values.yaml}}