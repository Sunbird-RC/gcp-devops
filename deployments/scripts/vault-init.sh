apt-get install jq -y
kubectl -n vault wait --for=jsonpath='{.status.phase}'=Running pod/vault-0 pods/vault-1 pods/vault-2
#kubectl exec -n vault vault-0 -- vault status
cluster_keys=""
cluster_keys=$(kubectl exec -n vault vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json)
sleep 10
VAULT_UNSEAL_KEY=$(echo "$cluster_keys" | jq -r ".unseal_keys_b64[]")
kubectl exec -n vault vault-0 -- vault operator unseal "$VAULT_UNSEAL_KEY"
#kubectl exec -n vault vault-0 -- vault status
CLUSTER_ROOT_TOKEN=$(echo "$cluster_keys" | jq -r ".root_token")
kubectl exec -n vault vault-0 -- vault login "$CLUSTER_ROOT_TOKEN"
kubectl exec -n vault vault-0 -- vault operator raft list-peers
kubectl exec -n vault vault-1 -- vault operator raft join http://vault-0.vault-internal:8200
kubectl exec -n vault vault-1 -- vault operator unseal "$VAULT_UNSEAL_KEY"
kubectl exec -n vault vault-2 -- vault operator raft join http://vault-0.vault-internal:8200
kubectl exec -n vault vault-2 -- vault operator unseal "$VAULT_UNSEAL_KEY"
kubectl exec -n vault vault-0 -- vault operator raft list-peers
kubectl get pods -n vault

echo -e "\nSet vault enable kubernetes\n"

kubectl exec -n vault vault-0 -n vault -- vault auth enable kubernetes
echo -e "\nvault set secret path\n"

kubectl exec -n vault vault-0 -n vault -- vault secrets enable -path=kv kv-v2

echo -e "\nVault setup completed successfully!!!"

kubectl create secret generic vault --from-literal=token="$CLUSTER_ROOT_TOKEN"
