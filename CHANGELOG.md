## 0.1.0 (2022-12-05)

### Feat

- create patch-crds-finalizers job
- deploy app thanks chart
- remove cluster role after job
- prepare argocd deployment thanks helm chart

### Refactor

- use cronjob instead job
- add configmap
- deploy app
- change hook
- add ns
- rbac
- add volumeMounts
- create job
- prepare helm chart

## 0.0.2 (2022-12-02)

### Refactor

- **SemVer**: add commitizen and use conventional commits

## 0.0.1 (2022-12-02)

### Feat

- external dns for devncoargo domain
- prepare multiple ingress nginx
- add trivy

### Fix

- annotations.kubernetes.io/ingress.class: Invalid value: "ingress-nginx-admin": can not be set when the class field is also set.
- use raw github file
