k delete clusterrolebinding cluster-admin-binding
k delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.1/deploy/static/provider/cloud/deploy.yaml
k delete ns vault
k delete secret vault
k delete secret keycloak
k delete secret letsencrypt-prod
k delete ns registry
k delete ns cert-manager
