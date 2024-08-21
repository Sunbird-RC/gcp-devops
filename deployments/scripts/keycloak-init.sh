kubectl wait pod --all --for=jsonpath='{.status.phase}'=Running  -n registry
echo -n "$1" | xargs -I '{}' sed -i -E 's@DOMAIN_VALUE@{}@' deployments/configs/keycloak-init-job.yaml

kubectl apply -f deployments/configs/keycloak-init-job.yaml -n registry

kubectl rollout restart deploy registry-keycloak-service -n registry
kubectl rollout restart deploy registry -n registry
kubectl wait pod --all --for=jsonpath='{.status.phase}'=Running  -n registry
