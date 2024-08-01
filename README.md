# Sunbird RC 2.0, one-click deployment on GCP

![dcs-lz](./assets/dcs-lz.png)

## Introduction

Sunbird RC 2.0 is an interoperable and unified registry infrastructure that needs to be established to enable "live," "reusable," and "trustworthy" registries as a "single source of truth" to address the three core issues mentioned. To learn more about Sunbird RC, please visit [SunbirdRC 2.0](https://docs.sunbirdrc.dev/).

## Deployment Approach

Deployment uses the following tools:

- **Terraform for GCP** - Infrastructure deployment
- **Helm chart** - Application/Microservices deployment
- **Cloud Build** - YAML scripts which acts as a wrapper around Terraform Deployment scripts

The entrie Terraform deployment is divided into 3 stages -

- **Pre-Config** stage
  - Create the required infra for RC deployment
- **Setup** Stage
  - Deploy the Core RC services
- **Post-Config** Stage
  - Perform all post configurations like realm import and keycloak secret generation
  
### Pre-requisites

- ### [Install the gcloud CLI](https://cloud.google.com/sdk/docs/install)

- #### Alternate

  - #### [Run gcloud commands with Cloud Shell](https://cloud.google.com/shell/docs/run-gcloud-commands)
  
- [**Install kubectl**](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl#apt)

  ```bash
  sudo apt-get update
  sudo apt-get install kubectl
  kubectl version --client
  
  sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin
  ```
  
- [**Install Helm**](https://helm.sh/docs/intro/install/)

  ```bash
  curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
  
  sudo apt-get install apt-transport-https --yes
  
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
  
  sudo apt-get update
  sudo apt-get install helm
  
  helm version --client
  ```

### Workspace - Folder structure

- **(***Root Folder***)**
  - **assets**
    - images
    - architetcure diagrams
    - ...(more)
  - **builds**
    - **apps** - Deploy/Remove all Application services
    - **infra** - Deploy/Remove all Infrastructure components end to end
    - **post-setup** - Configure keycloak with realms and configure secrets
  - **deployments -** Store config files required for deployment
    - **configs**
      - Store config files required for deployment
    - **schemas**
      - Store RC schemas which needs to be mounted to registry
    - **scripts**
      - Shell scripts required to deploy services
  - **terraform-scripts**
      - Deployment files for end to end Infrastructure deployment
  - **terraform-variables**
    - **dev**
      - **pre-config**
        - **pre-config.tfvars**
          - Actual values for the variable template defined in **variables.tf** to be passed to **pre-config.tf** 
      
### Infrastructure Deployment

![deploy-approach](./assets/deploy-approach.png)

## Step-by-Step guide

#### Setup CLI environment variables

```bash
PROJECT_ID=
OWNER=
GSA=$PROJECT_ID-sa@$PROJECT_ID.iam.gserviceaccount.com
GSA_DISPLAY_NAME=$PROJECT_ID-sa
REGION=asia-south1
ZONE=asia-south1-a
CLUSTER=
DOMAIN_NAME=
EMAIL_ID=
alias k=kubectl
```

#### Authenticate user to gcloud

```bash
gcloud auth login
gcloud auth list
gcloud config set account $OWNER
```

#### Setup current project

```bash
gcloud config set project $PROJECT_ID

gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable servicenetworking.googleapis.com
gcloud services enable cloudkms.googleapis.com
gcloud services enable certificatemanager.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable secretmanager.googleapis.com
gcloud services enable servicenetworking.googleapis.com

gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE
```

#### Setup Service Account

Current authenticated user will handover control to a **Service Account** which would be used for all subsequent resource deployment and management

```bash
gcloud iam service-accounts create $GSA_DISPLAY_NAME --display-name=$GSA_DISPLAY_NAME
gcloud iam service-accounts list

# Make SA as the owner
gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:$GSA --role=roles/owner

# ServiceAccountUser role for the SA
gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:$GSA --role=roles/iam.serviceAccountUser

# ServiceAccountTokenCreator role for the SA
gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:$GSA --role=roles/iam.serviceAccountTokenCreator
```

#### Deploy Infrastructure using Terraform

#### Teraform State management

```bash
# Maintains the Terraform state for deployment
gcloud storage buckets create gs://$PROJECT_ID-tfs-stg --project=$PROJECT_ID --default-storage-class=STANDARD --location=$REGION --uniform-bucket-level-access

# List all Storage buckets in the project to check the creation of the new one
gcloud storage buckets list --project=$PROJECT_ID
```

#### Pre-Config

##### Prepare Landing Zone

```bash
cd $BASEFOLDERPATH

# One click of deployment of infrastructure
gcloud builds submit --config="./builds/infra/deploy-script.yaml" \
--project=$PROJECT_ID --substitutions=_PROJECT_ID_=$PROJECT_ID,\
_SERVICE_ACCOUNT_=$SERVICE_ACCOUNT,_LOG_BUCKET_=$PROJECT_ID-tfs-stg

# Remove/Destroy infrastructure
/*
gcloud builds submit --config="./builds/infra/destroy-script.yaml" \
---project=$PROJECT_ID --substitutions=_PROJECT_ID_=$PROJECT_ID,\
_SERVICE_ACCOUNT_=$SERVICE_ACCOUNT,_LOG_BUCKET_=$PROJECT_ID-tfs-stg
*/
```

##### Output
```
...
Apply complete! Resources: 36 added, 0 changed, 0 destroyed.

Outputs:

lb_public_ip = "**.93.6.**"
ngw_public_ip = "**.200.133.**"
sql_public_ip = "**.125.196.**"
```

_**Before moving to the next step, you need to create domain/sub-domain and create a DNS `A` type record pointing to `lb_public_ip`**_

_`deployments/schemas/*` contains sample schemas which will be mounted to registry services. You can add your custom schemas in this directory._


#### Deploy service

##### Deploy Landing Zone

```bash
cd $BASEFOLDERPATH

# One click of deployment of services
gcloud builds submit --config="./builds/apps/deploy-script.yaml" \
--region=$REGION --project=$PROJECT_ID --substitutions=_PROJECT_ID_=$PROJECT_ID,\
_REGION_="$REGION",_LOG_BUCKET_=$PROJECT_ID-tfs-stg,_EMAIL_ID_=$EMAIL_ID,_DOMAIN_=$DOMAIN,_SERVICE_ACCOUNT_=$SERVICE_ACCOUNT

# Remove/Destroy 
/*
gcloud builds submit --config="./builds/apps/destroy-script.yaml" \
--region=$REGION --project=$PROJECT_ID --substitutions=_PROJECT_ID_=$PROJECT_ID,\
_REGION_="$REGION",_LOG_BUCKET_=$PROJECT_ID-tfs-stg,_EMAIL_ID_=$EMAIL_ID,_DOMAIN_=$DOMAIN,_SERVICE_ACCOUNT_=$SERVICE_ACCOUNT
*/
```

_**After successfully deploying the services you can check if you're able to access keycloak using your domain. Ex: https://$DOMAIN/auth/**_

_Please note that issuing of ssl certificate and DNS mapping might take some time_

_Only if you're able to access the keycloak UI, proceed to next steps_

#### Connect to the Cluster through bastion host

```bash
gcloud compute instances list
gcloud compute ssh functional-registry-ops-vm --zone=$ZONE
gcloud container clusters get-credentials functional-registry-cluster --project=$PROJECT_ID --region=$REGION

kubectl get nodes
kubectl get pods -n registry
kubectl get svc -n ingress-nginx
kubectl get pods -n vault
```


#### Post-Config

##### Configure Landing Zone

```bash
cd $BASEFOLDERPATH


# Post setup configuring keycloak service
gcloud builds submit --config="./builds/post-setup/deploy-script.yaml" \
--region=$REGION --project=$PROJECT_ID --substitutions=_PROJECT_ID_=$PROJECT_ID,\
_REGION_="$REGION",_LOG_BUCKET_=$PROJECT_ID-tfs-stg,_DOMAIN_=$DOMAIN,_SERVICE_ACCOUNT_=$SERVICE_ACCOUNT

```


### Steps to access keycloak UI
- Run the below command in bastion host to get the keycloak secret,
```bash
kubectl get secret keycloak  -o jsonpath="{.data}" | jq -r ".password" | base64 --decode
```
- Goto https://DOMAIN/auth/
- Username: admin

### Steps to connect to Psql
- Run the below command in bastion host
- Install psql client
```bash
sudo apt-get update
sudo apt-get install postgresql-client
```
- Run below command to access psql password
```bash
gcloud secrets versions access latest --secret registry
```
- Run below command to get private ip of sql
```bash
 gcloud sql instances describe functional-registry-pgsql --format=json  | jq -r ".ipAddresses"
```
- Connect to psql
```bash
psql "sslmode=require hostaddr=PRIVATE_IP user=registry dbname=registry"
```

### DEMO
In this repo a sample Institute and Student schema has been provided for quick reference and testing purpose.

A sample postman collection (along with env config) has been provided in `postman_collections` directory. Import both the files to try out the APIs.

Before executing the APIs a super admin user needs to be created in keycloak. Follow the below steps to create the user in keycloak:
- Login to keycloak, https://DOMAIN/auth/admin/master/console/#/realms/sunbird-rc
- To access keycloak admin password, follow the steps provided earlier
- Goto `Users` section and click on `Add User`
- Create user with username: super-admin and click Save
- Goto `Credentials` section and set password `Ex: 123` with `Temporary` switch turned off
- Goto `Roles Mappings` and select `admin` role from `Available Roles` and click on `Add selected`
- You can go back to postman to continue further

Open postman and import both the collection and environment collections

- Select the `rc` environment from the dropdown and modify host to point to your specific domain
- You can trigger `get credentials schemas` to get all the schemas registed
- Next trigger `create template` api to create certificate template
- Modify `get admin token` request with the super-admin details created before
- The next set of apis will create an Institute admin and issue a Student VC.
- A student should be able to login via his credentials and should be able to fetch his details and also download the VC as certificate




## References

- [GKE Cluster](https://cloud.google.com/kubernetes-engine/docs)
- [Cloud SQL for PostgreSQL](https://cloud.google.com/sql/docs/postgres)
- [Secret Manager](https://cloud.google.com/secret-manager/docs)
