apt-get install dnsutils jq wget -y
 [ "$(curl --connect-timeout 5  -o /dev/null -s -w "%{http_code}" https://$1/auth/)" -eq 200 ] || exit 1
kubectl wait pod --all --for=jsonpath='{.status.phase}'=Running  -n registry
wget -O realm-export.json https://raw.githubusercontent.com/Sunbird-RC/sunbird-rc-core/main/imports/realm-export.json

admin_password=$(kubectl get secret keycloak  -o jsonpath="{.data}" | jq -r ".password" | base64 --decode)
admin_secret=$(kubectl get secret keycloak  -o jsonpath="{.data}" | jq -r ".secret" | base64 --decode)
admin_token=$(curl --location "https://$1/auth/realms/master/protocol/openid-connect/token" \
 --header "Content-Type: application/x-www-form-urlencoded" \
 --data-urlencode "client_id=admin-cli" \
 --data-urlencode "username=admin" \
 --data-urlencode "password=$admin_password" \
 --data-urlencode "grant_type=password" |  jq -r ".access_token")

echo -n "$admin_secret" | xargs -I '{}' sed -i -E 's@"secret": ".*",@"secret": "{}",@' realm-export.json

cat <<< $(jq --arg domain https://$1/auth '.attributes += {"frontendUrl": $domain}'  realm-export.json ) > realm-export.json


curl --location "https://$1/auth/admin/realms" --header "Authorization: Bearer ${admin_token}" \
 --data "@./realm-export.json" \
 --header 'Content-Type: application/json'



kubectl rollout restart deploy registry-keycloak-service -n registry
kubectl rollout restart deploy registry -n registry
