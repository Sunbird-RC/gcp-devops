apt-get install jq uuid-runtime -y
db_pass=$(gcloud secrets versions access latest --secret $2)
keycloak_admin_password=$(openssl rand -hex 12)
echo -n "$db_pass" | base64 -w 0 | xargs -I '{}' sed -i -E 's@DB_PASSWORD.*@DB_PASSWORD: {}@' values.yaml
echo -n "$keycloak_admin_password" | base64 -w 0 | xargs -I '{}' sed -i -E 's@KEYCLOAK_ADMIN_PASSWORD:.*@KEYCLOAK_ADMIN_PASSWORD: {}@' values.yaml
kubectl get secret vault -o jsonpath='{.data}' | jq -r '.token' | xargs -I '{}' sed -i -E 's@VAULT_SECRET_TOKEN:.*@VAULT_SECRET_TOKEN: {}@' values.yaml
gcloud sql instances describe $3 --format=json  | jq -r ".ipAddresses[0].ipAddress" | xargs -I '{}' echo -n "postgres://registry:$db_pass@{}:5432/credentials" | base64 -w 0 | xargs -I '{}' sed -i -E 's@CREDENTIALS_DB_URL:.*@CREDENTIALS_DB_URL: {}@' values.yaml
gcloud sql instances describe $3 --format=json  | jq -r ".ipAddresses[0].ipAddress" | xargs -I '{}' echo -n "postgres://registry:$db_pass@{}:5432/credential-schema" | base64 -w 0 | xargs -I '{}' sed -i -E 's@CREDENTIAL_SCHEMA_DB_URL:.*@CREDENTIAL_SCHEMA_DB_URL: {}@' values.yaml
gcloud sql instances describe $3 --format=json  | jq -r ".ipAddresses[0].ipAddress" | xargs -I '{}' echo -n "postgres://registry:$db_pass@{}:5432/identity" | base64 -w 0 | xargs -I '{}' sed -i -E 's@IDENTITY_DB_URL:.*@IDENTITY_DB_URL: {}@' values.yaml
gcloud sql instances describe $3 --format=json  | jq -r ".ipAddresses[0].ipAddress" | xargs -I '{}' sed -i -E 's@host: "10.9.0.7".*@host: {}@' values.yaml
gcloud sql instances describe $3 --format=json  | jq -r ".ipAddresses[0].ipAddress" | xargs -I '{}' sed -i -E 's@db:5432@{}:5432@' values.yaml
sed -i -E 's@http://vault:@http://vault.vault:@' values.yaml


admin_secret=$(uuidgen)
echo -n "$admin_secret" | base64 -w 0 | xargs -I '{}' sed -i -E 's@KEYCLOAK_ADMIN_CLIENT_SECRET:.*@KEYCLOAK_ADMIN_CLIENT_SECRET: {}@' values.yaml
kubectl create secret generic keycloak --from-literal=password="$keycloak_admin_password" --from-literal=secret="$admin_secret"

echo -n $1 | xargs -I '{}' sed -i -E 's@sunbird_sso_url: .*@sunbird_sso_url: https://{}/auth@' charts/config/templates/configmap.yaml