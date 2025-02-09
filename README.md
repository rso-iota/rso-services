# Configuration

**Some notes**

- `k` is an alias for kubectl
- `DO` is an abbreviation for Digital Ocean
- `helm` version 3 is used
- `doctl` is a Digital Ocean CLI
- You need to have 3 registered subdomains for this setup to work: `rso`, `rso-keycloak`, `rso-traefik`

## Guide

Firs install custom CRDs needed for cert-manager:

```shell
k apply --namespace=cert-manager -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.2/cert-manager.crds.yaml
```

Create a k8s secret `lets-encrypt-do-dns` in the `cert-manager` namespace with the Digital Ocean API token in the `access-token` field.

Update helm deps:

```shell
helm dep up ./services/keycloak
helm dep up ./services/cert-manager
helm dep up ./services/traefik
helm dep up ./services/argocd
helm dep up ./services/kong
helm dep up ./services/monitoring
helm dep up ./services/nats
```

Update your email in `./lets-encrypt-issuer.yaml` and then:

```shell
k apply  -f ./lets-encrypt-issuer.yaml
```

Install helm charts from the folders:

```shell
helm install --create-namespace --namespace=cert-manager cert-manager ./services/cert-manager
helm install --create-namespace --namespace=traefik traefik ./services/traefik
helm install --create-namespace --namespace=argocd argocd ./services/argocd
helm install --create-namespace --namespace=metrics metrics ./services/metrics
helm install --create-namespace --namespace=monitoring monitoring ./services/monitoring
helm install --create-namespace --namespace=keycloak keycloak ./services/keycloak
helm install --create-namespace --namespace=nats nats ./services/nats

helm upgrade monitoring ./services/monitoring --namespace=monitoring
helm upgrade keycloak ./services/keycloak --namespace=keycloak
```

Wait for the `traefik` pod ta setup DO LB:

```shell
kubectl get -n traefik all
```

Copy external IP of the traefik service and then config DO networking. You need a TL domain and 3 subdomains: `rso`, `rso-keycloak`, `rso-traefik`.

```sh
doctl compute domain create <YOUR_DOMAIN>

doctl compute domain records create <YOUR_DOMAIN> --record-name rso --record-type A --record-data <EXTERNAL_IP>
doctl compute domain records create <YOUR_DOMAIN> --record-name rso-keycloak --record-type CNAME --record-data rso.<YOUR_DOMAIN>.
doctl compute domain records create <YOUR_DOMAIN> --record-name rso-traefik --record-type CNAME --record-data rso.<YOUR_DOMAIN>.

dig @ns1.digitalocean.com +noall +answer +domain=<YOUR_DOMAIN> rso rso-keycloak rso-traefik
```

Don't forget to set NS in external domain provider to DO NS if you aren't using DO DNS

For actual apps to work you need to ron the following:

```shell
cd services && k apply -f applcations-cd.yaml
```