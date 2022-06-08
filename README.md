# kustomization

## tree
Git Generator: Files

├── apps
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



mkdir -p {overlays/{dev,prod},base}
mkdir -p {overlays/{dev,prod},base}