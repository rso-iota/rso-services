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
helm dep up ./cert-manager
helm dep up ./traefik
```

Update your email in `./lets-encrypt-issuer.yaml` and then:

```shell
k apply  -f ./lets-encrypt-issuer.yaml
```

Install helm charts from the folders:

```shell
helm install --create-namespace --namespace=cert-manager cert-manager ./cert-manager
helm install --create-namespace --namespace=traefik traefik ./traefik
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
