kubectl delete clusterrolebinding cluster-admin-binding
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.1/deploy/static/provider/cloud/deploy.yaml
kubectl delete ns vault
kubectl delete secret vault
kubectl delete secret keycloak
kubectl delete secret letsencrypt-prod
kubectl delete ns registry
kubectl delete ns cert-manager
