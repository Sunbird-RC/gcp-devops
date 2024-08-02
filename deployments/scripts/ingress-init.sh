apt-get install jq wget -y
wget  -O deploy.yaml https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.1/deploy/static/provider/cloud/deploy.yaml
gcloud compute addresses describe $2  --region $1 --format json | jq -r ".address" | xargs -I '{}' sed -i -E 's@LoadBalancer@LoadBalancer\n  loadBalancerIP: {}@' deploy.yaml
kubectl apply -f deploy.yaml