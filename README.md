# kustomization

This repository represents how implement a Kubernetes DevOps Workflow which simplifies evolve bricks of a DevOps infrastructure.

Who have never got the temptation to fork a helm chart repository in order to add some functionalities ? Me first ...

This workflow try bring closer the state of the art using the better of DevOps tools: `Package Management (Helm) >> Config Management (Kustomize) >> GitOps (ArgoCD) >> Admission Controller (kyverno)`

This implementation is based on following publictions:
- [Workflow for Kubernetes DevOps](https://faun.pub/workflow-for-kubernetes-devops-15f0dbb560ff)
- [Helm Is Not Enough, You Also Need Kustomize](https://itnext.io/helm-is-not-enough-you-also-need-kustomize-82bae896816e)

Some killer features:
- based on App Of Apps Pattern & ArgoCD Applicationset
- ArgoCD manages itself ... Chicken or the egg ?
- Custom Ressource Definitions management
- Performing Async Actions using Hooks
- Pre-installed Unified Grafana Dashboards (logging/monitoring) + ArgoCD notifications correlation
- Backup of ingress's logs into an object storage using a low level tool (fast, memory efficient, and designed to handle the most demanding workloads) 
- Backup of app's logs into an object storage
- ArgoCD notifications ready: slack or teams
- Private key encryption of passwords
- Pod Security Standards implemented as Kyverno policies
- extra policies: Best Practices, mitigates CVE

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
addon=keycloak
cluster=kind
namespace=keycloak

mkdir -p cluster-addons/$addon/{overlays/$cluster-{dev,prod},base}
touch cluster-addons/$addon/{base/{helm-generator.yaml,kustomization.yaml,namespace.yaml},overlays/$cluster-{dev,prod}/{kustomization.yaml,values.yaml}}

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
EOF
```

## copy an existing environment

```zsh
cluster=plato
env=devncoargo

cd cluster-addons
for dir in $(find $PWD -type d -regex '.*/kind-prod'); do cp -ra $dir $(dirname $dir)/$cluster-$env; done
cd ../crds
for dir in $(find $PWD -type d -regex '.*/kind-prod'); do cp -ra $dir $(dirname $dir)/$cluster-$env; done
cd ../secrets/cluster-addons
for dir in $(find $PWD -type d -regex '.*/kind-prod'); do cp -ra $dir $(dirname $dir)/$cluster-$env; done
cd ../clusters
for dir in $(find $PWD -type d -regex '.*/kind-prod'); do cp -ra $dir $(dirname $dir)/$cluster-$env; done
```

## create a sealed-secrets certificate

```zsh
openssl req -days 3650 -x509 -nodes -newkey rsa:4096 -keyout "tls.key" -out "tls.crt" -subj "/CN=sealed-secret/O=sealed-secret"

cluster=plato
env=devncoargo
mkdir -p secrets/clusters/$cluster-$env
cat > secrets/clusters/$cluster-$env/sealed-secrets-private-key.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  generateName: sealed-secrets-key
  labels:
    sealedsecrets.bitnami.com/sealed-secrets-key: active
  name: sealed-secrets-key
  namespace: kube-system
type: kubernetes.io/tls
data:
EOF
crt=`cat tls.crt|base64 -w 0`
key=`cat tls.key|base64 -w 0`
echo "  tls.crt: $crt" >> secrets/clusters/$cluster-$env/sealed-secrets-private-key.yaml
echo "  tls.key: $key" >> secrets/clusters/$cluster-$env/sealed-secrets-private-key.yaml
rm -Rf tls.crt tls.key
```

## sign secret with certificate

edit Makefile, in target "create-secrets:" adjust cluster & env vars and use command: `make create-secrets`