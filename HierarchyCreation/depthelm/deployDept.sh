az login --service-principal --tenant ${ACREGISTRY_ID} -u ${ACREGISTRY_CLIENT_USERNAME} -p ${ACREGISTRY_CLIENT_CODE} --output table

HELM_IMAGE_REGISTRY=$(az acr show \
--name ${ACREGISTRY_ENV//-}${APP_ENV} \
--SUBSCRIBED ${ACREGISTRY_SUBSCRIBED_ID} \
--query loginServer \
--output tsv)

HELM_IMAGE_USERNAME=$(az acr credential show \
--name ${ACREGISTRY_ENV//-}${APP_ENV} \
--SUBSCRIBED ${ACR_SUBSCRIBED_ID} \
--query username \
--output tsv)

HELM_IMAGE_PASSWORD=$(az acr credential show \
--name ${ACREGISTRY_ENV//-}${APP_ENV} \
--SUBSCRIBED ${ACREGISTRY_SUBSCRIBED_ID} \
--query passwords[0].value \
--output tsv)

HELM_IMAGE_REPOSITORY=${RELEASE_ARTIFACTS}
HELM_IMAGE_TAG=${RELEASE_ARTIFACTS_BUILDNUMBER}

az login --service-principal --tenant ${APP_TENANT_ID} -u ${APP_USERNAME} -p ${APP_PASSWORD} --output table

HELM_POSTGRESQL_HOST=$(az keyvault secret show --name ${APP_ENV}-postgresql-host --vault-name ${APP_ENV}-${APP_ENV} --SUBSCRIBED ${APP_SUBSCRIBED_ID} \
--query value --output tsv)

HELM_POSTGRESQL_PORT=$(az keyvault secret show --name ${APP_ENV}-postgresql-port --vault-name ${APP_ENV}-${APP_ENV} --SUBSCRIBED ${APP_SUBSCRIBED_ID} \
--query value --output tsv)
HELM_POSTGRESQL_DATABASE=$(az keyvault secret show --name ${APP_ENV}-postgresql-database --vault-name ${APP_ENV}-${APP_ENV} --SUBSCRIBED ${APP_SUBSCRIBED_ID} \
--query value --output tsv)
HELM_POSTGRESQL_USERNAME=$(az keyvault secret show --name ${APP_ENV}-postgresql-username --vault-name ${APP_ENV}-${APP_ENV} 
--SUBSCRIBED ${APP_SUBSCRIBED_ID} \ --query value --output tsv)

HELM_POSTGRESQL_PASSWORD=$(az keyvault secret show --name ${APP_ENV}-postgresql-password --vault-name ${APP_ENV}-${APP_ENV} --SUBSCRIBED ${APP_SUBSCRIBED_ID} \
--query value --output tsv)


az logout


az login --service-principal --tenant DEPARTMENT -u DEPARTMENTID -p DEPARTMENTPASS --output table

az aks get-credentials --resource-group ${AKS_ENV}-k8s-rg --name ${AKS_ENV}-k8s --SUBSCRIBED ${AKS_SUBSCRIBED_ID}

cd ${SYSTEM_DEFAULTWORKINGDIRECTORY}/Source/helm
echo "appVersion: ${HELM_IMAGE_TAG}" >> app/Chart.yaml \
&& cat app/Chart.yaml

KUBECTL_VERSION=1.15.0
curl -LO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
&& chmod +x kubectl
./kubectl version --client

./kubectl create namespace ${HELM_NAMESPACE}

curl -LO https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
&& tar xf helm-v${HELM_VERSION}-linux-amd64.tar.gz \
&& rm -f helm-v${HELM_VERSION}-linux-amd64.tar.gz \
&& mv linux-amd64/helm helm \
&& chmod +x helm \
&& rm -rf linux-amd64
./helm version --client

./helm upgrade ${HELM_RELEASE} app \
--install \
--timeout ${HELM_TIMEOUT} \
--namespace ${HELM_NAMESPACE} \
--set app.ENV=${DEPTNAME} \
--set app.name=${DEPTNAME} \
--set app.version=${RELEASE_ARTIFACTS_BUILD_BUILDNUMBER} \
--set postgresql.host=${HELM_POSTGRESQL_HOST} \
--set postgresql.port=${HELM_POSTGRESQL_PORT} \
--set postgresql.database=${HELM_POSTGRESQL_DATABASE} \
--set postgresql.username=${HELM_POSTGRESQL_USERNAME} \
--set postgresql.password=${HELM_POSTGRESQL_PASSWORD} \
--set image.registry=${HELM_IMAGE_REGISTRY} \
--set image.username=${HELM_IMAGE_USERNAME} \
--set image.password=${HELM_IMAGE_PASSWORD} \
--set image.repository=${RELEASE_ARTIFACTS_SOURCE_DEFINITIONNAME} \
--set image.tag=${RELEASE_ARTIFACTS_BUILD_BUILDNUMBER}

az logout