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


## Usage

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repo as follows:

    helm repo add kustomization https://kube-components-stack.github.io/kustomization

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages.  You can then run `helm search repo
kustomization` to see the charts.

To install the kustomization chart:

    helm install my-kustomization kustomization/kustomization

To uninstall the chart:

    helm delete my-kustomization


## structure

```
.
├── manifests
│   ├── argocd-applicationset
│   │   ├── addons-apps.yaml
│   │   ├── addons-crds.yaml
│   │   ├── core-apps.yaml
│   │   └── core-crds.yaml
│   └── argocd-appproject
│       ├── addons-apps.yaml
│       ├── addons-crds.yaml
│       ├── core-apps.yaml
│       └── core-crds.yaml
├── rendered-manifests
│   ├── core
│   │   ├── apps
│   │   │   ├── namespace-01
│   │   │   │   ├── base
│   │   │   │   │   ├── helm-generator.yaml
│   │   │   │   │   ├── kustomization.yaml
│   │   │   │   │   └── namespace.yaml
│   │   │   │   └── overlays
│   │   │   │       ├── kind-dev
│   │   │   │       │   ├── kustomization.yaml
│   │   │   |       |   ├── secrets.yaml
│   │   │   │       │   └── values.yaml
│   │   │   │       └── kind-prod
│   │   │   │           ├── kustomization.yaml
│   │   │   |           ├── secrets.yaml
│   │   │   │           └── values.yaml
│   │   │   └── namespace-x
│   │   │       ├── base
│   │   │       │   ├── helm-generator.yaml
│   │   │       │   ├── kustomization.yaml
│   │   │       │   └── namespace.yaml
│   │   │       └── overlays
│   │   │           ├── kind-dev
│   │   │           |   ├── kustomization.yaml
│   │   │           |   ├── secrets.yaml
│   │   │           |   └── values.yaml
│   │   │           └── kind-prod
│   │   │               ├── kustomization.yaml
│   │   │               ├── secrets.yaml
│   │   │               └── values.yaml
│   │   └── crds
│   │       ├── crds-01
│   │       │   ├── base
│   │       │   │   └── kustomization.yaml
│   │       │   └── overlays
│   │       │       ├── kind-dev
│   │       │       │   └── kustomization.yaml
│   │       │       └── kind-prod
│   │       │           └── kustomization.yaml
│   │       └── crds-x
│   │           ├── base
│   │           │   └── kustomization.yaml
│   │           └── overlays
│   │               ├── kind-dev
│   │               │   └── kustomization.yaml
│   │               └── kind-prod
│   │                   └── kustomization.yaml
│   └── addons
│       ├── apps
│       │   ├── namespace-01
│       │   │   ├── base
│       │   │   │   ├── helm-generator.yaml
│       │   │   │   ├── kustomization.yaml
│       │   │   │   └── namespace.yaml
│       │   │   └── overlays
│       │   │       ├── kind-dev
│       │   │       │   ├── kustomization.yaml
│       │   |       |   ├── secrets.yaml
│       │   │       │   └── values.yaml
│       │   │       └── kind-prod
│       │   │           ├── kustomization.yaml
│       │   |           ├── secrets.yaml
│       │   │           └── values.yaml
│       │   └── namespace-x
│       │       ├── base
│       │       │   ├── helm-generator.yaml
│       │       │   ├── kustomization.yaml
│       │       │   └── namespace.yaml
│       │       └── overlays
│       │           ├── kind-dev
│       │           |   ├── kustomization.yaml
│       │           |   ├── secrets.yaml
│       │           |   └── values.yaml
│       │           └── kind-prod
│       │               ├── kustomization.yaml
│       │               ├── secrets.yaml
│       │               └── values.yaml
│       └── crds
│           ├── crds-addon-01
│           │   ├── base
│           │   │   └── kustomization.yaml
│           │   └── overlays
│           │       ├── kind-dev
│           │       │   └── kustomization.yaml
│           │       └── kind-prod
│           │           └── kustomization.yaml
│           └── crds-addon-x
│               ├── base
│               │   └── kustomization.yaml
│               └── overlays
│                   ├── kind-dev
│                   │   └── kustomization.yaml
│                   └── kind-prod
│                       └── kustomization.yaml
├── Makefile
├── README.md
├── scripts
│   └── tools
└── secrets
    ├── core
    │   ├── loki
    │   │   └── overlays
    │   │       ├── kind-dev
    │   │       │   └── kustomization.yaml
    │   │       ├── kind-prod
    │   │       │   ├── kustomization.yaml
    │   │       │   └── secrets
    │   │       │       └── bucket-s3.yaml
    │   │       └── plato-devncoargo
    │   │           ├── kustomization.yaml
    │   │           └── secrets
    │   │               └── bucket-s3.yaml
    │   └── vector
    │       └── overlays
    │           ├── kind-dev
    │           │   └── kustomization.yaml
    │           ├── kind-prod
    │           │   ├── kustomization.yaml
    │           │   └── secrets
    │           │       └── bucket-s3.yaml
    │           └── plato-devncoargo
    │               ├── kustomization.yaml
    │               └── secrets
    │                   └── bucket-s3.yaml
    ├── addons
    │   └── argocd
    │       └── overlays
    │           ├── kind-dev
    │           │   ├── kustomization.yaml
    │           │   └── secrets
    │           │       ├── argocd-secret.yaml
    │           │       └── grafana-secret.yaml
    │           ├── kind-prod
    │           │   ├── kustomization.yaml
    │           │   └── secrets
    │           │       ├── argocd-notifications-secret.yaml
    │           │       ├── argocd-secret.yaml
    │           │       ├── grafana-secret.yaml
    │           │       └── keycloak-ca.yaml
    │           └── plato-devncoargo
    │               ├── kustomization.yaml
    │               └── secrets
    │                   ├── argocd-notifications-secret.yaml
    │                   ├── argocd-secret.yaml
    │                   ├── grafana-secret.yaml
    │                   └── keycloak-ca.yaml
    ├── clusters
    │   ├── kind-dev
    │   |    └── sealed-secrets-private-key.yaml
    │   └── kind-prod
    │       └── sealed-secrets-private-key.yaml
    └── README.md
```

## declare vars and create directory structure and files
```zsh
addon=aws-efs-csi-driver
declare clusters=("plato-devncoargo")
namespace=kube-system
type=core

mkdir -p rendered-manifests/$type/namespaces/$addon/base
cat << EOF > rendered-manifests/$type/namespaces/$addon/base/helm-chart-$addon.yaml
apiVersion: builtin
kind: HelmChartInflationGenerator
metadata:
  name: helm-chart-$addon
name: &name $addon
version: ""
repo: ""
releaseName: *name
namespace: $namespace
includeCRDs: false
valuesFile: values-$addon.yaml
valuesMerge: override                 # merge, override or replace
valuesInline: {}
EOF

cat << EOF > rendered-manifests/$type/namespaces/$addon/base/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: $namespace
EOF

cat << EOF > rendered-manifests/$type/namespaces/$addon/base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: $namespace
resources:
- namespace.yaml
EOF

for c in $clusters; do 
  mkdir -p rendered-manifests/$type/namespaces/$addon/overlays/$c
  touch rendered-manifests/$type/namespaces/$addon/overlays/$c/{kustomization.yaml,values-$addon.yaml}
  cat << EOF > rendered-manifests/$type/namespaces/$addon/overlays/$c/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: $namespace
generators:
- ../../base/helm-chart-$addon.yaml
resources:
- ../../base
EOF
done

```

## copy an existing environment

```zsh
current_path=$PWD
cluster=plato
env=devncoargo

cd rendered-manifests/addons/namespaces
for dir in $(find $PWD -type d -regex '.*/kind-prod'); do cp -ra $dir $(dirname $dir)/$cluster-$env; done
cd ../crds
for dir in $(find $PWD -type d -regex '.*/kind-prod'); do cp -ra $dir $(dirname $dir)/$cluster-$env; done
cd ../../core/namespaces
for dir in $(find $PWD -type d -regex '.*/kind-prod'); do cp -ra $dir $(dirname $dir)/$cluster-$env; done
cd ../crds
for dir in $(find $PWD -type d -regex '.*/kind-prod'); do cp -ra $dir $(dirname $dir)/$cluster-$env; done
cd $current_path
cd secrets/addons
for dir in $(find $PWD -type d -regex '.*/kind-prod'); do cp -ra $dir $(dirname $dir)/$cluster-$env; done
cd ../core
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

## create keycloak cert without openssl

### for ingress
edit ingress values like this
```yaml
ingress:
  enabled: true
  hostname: keycloak-nco.admin.plato-devncoargo.dev-sbr.com
  tls: true
  selfSigned: true
```

generate template, catch secret, extract datas, store them into a file and create, ca, crt and key files.
```zsh
kustomize build --enable-alpha-plugins --enable-helm --load-restrictor LoadRestrictionsNone rendered-manifests/addons/namespaces/keycloak/overlays/plato-devncoargo|yq -ojson|jq -s|jq '.[]|select(.kind == "Secret")|select(.metadata.name == "keycloak-nco.admin.plato-devncoargo.dev-sbr.com-tls")'|jq -s '.[0].data|{"ca.crt": .["ca.crt"]|@base64d,"tls.crt": .["tls.crt"]|@base64d,"tls.key": .["tls.key"]|@base64d}' > secrets/addons/keycloak/overlays/plato-devncoargo/secrets/tls.json

cd secrets/addons/keycloak/overlays/plato-devncoargo/secrets
cat tls.json| jq -r '.["ca.crt"]' > ca.crt
cat tls.json| jq -r '.["tls.crt"]' > tls.crt
cat tls.json| jq -r '.["tls.key"]' > tls.key
rm tls.json
cd $OLDPWD
```

### for service
edit ingress values like this
```yaml
tls: 
  enabled: true
  autoGenerated: true
  existingSecret: ""
```

generate template, catch secret, extract datas, store them into a file and create, ca, crt and key files.
```zsh
kustomize build --enable-alpha-plugins --enable-helm --load-restrictor LoadRestrictionsNone rendered-manifests/addons/namespaces/keycloak/overlays/plato-devncoargo|yq -ojson|jq -s|jq '.[]|select(.kind == "Secret")|select(.metadata.name == "keycloak-crt")'|jq -s '.[0].data|{"ca.crt": .["ca.crt"]|@base64d,"tls.crt": .["tls.crt"]|@base64d,"tls.key": .["tls.key"]|@base64d}' > secrets/addons/keycloak/overlays/plato-devncoargo/secrets/tls.json

cd secrets/addons/keycloak/overlays/plato-devncoargo/secrets
cat tls.json| jq -r '.["ca.crt"]' > ca.crt
cat tls.json| jq -r '.["tls.crt"]' > tls.crt
cat tls.json| jq -r '.["tls.key"]' > tls.key
rm tls.json
cd $OLDPWD
```