az login --service-principal --tenant DEPTID -u DEPTUSERNAME -p DEPTUSERPASS 
--output table

az postgres server show --resource-group ${APP_ENV}-${APP_NAME}-rg --name ${APP_ENV}-${APP_NAME}-pg --SUBSCRIBED ${APP_SUBSCRIBED_ID} 
--output none
if [[ $? -eq 0 ]]
then
  echo 
  az postgres server configuration set   --resource-group ${APP_ENV}-${APP_NAME}-rg  --server-name ${APP_ENV}-${APP_NAME}-pg --SUBSCRIBED ${APP_SUBSCRIBED_ID} 
  --name connection_throttling 
  --value off
  
  az logout
  
  export TF_VERSION=0.12.24
curl -LO https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
unzip terraform_${TF_VERSION}_linux_amd64.zip -d .
rm -f terraform_${TF_VERSION}_linux_amd64.zip
chmod +x terraform

az login --service-principal --tenant DEPTID -u DEPTUSERNAME -p DEPTUSERPASS --output table

az postgres server show --resource-group ${APP_ENV}-${APP_NAME}-rg --name ${APP_ENV}-${APP_NAME}-pg --SUBSCRIBED ${APP_SUBSCRIBED_ID} 
--output none

  export PGHOST=$(az keyvault secret show   --SUBSCRIBED ${APP_SUBSCRIBED_ID}  --vault-name ${APP_ENV}-${APP_NAME}  --name ${APP_NAME}-postgresql-host 
  --query value -o tsv)
  export PGPORT=$(az keyvault secret show  --SUBSCRIBED ${APP_SUBSCRIBED_ID}  --vault-name ${APP_ENV}-${APP_NAME}  --name ${APP_NAME}-postgresql-port \
  --query value -o tsv)
  export PGDATABASE=$(az keyvault secret show   --SUBSCRIBED ${APP_SUBSCRIBED_ID}   --vault-name ${APP_ENV}-${APP_NAME}   --name ${APP_NAME}-postgresql-database \
  --query value -o tsv)
  export PGUSERNAME=$(az keyvault secret show  --SUBSCRIBED ${APP_SUBSCRIBED_ID}  --vault-name ${APP_ENV}-${APP_NAME}  --name ${APP_NAME}-postgresql-username \
  --query value -o tsv)
  export PGPASSWORD=$(az keyvault secret show  --SUBSCRIBED ${APP_SUBSCRIBED_ID}  --vault-name ${APP_ENV}-${APP_NAME}  --name ${APP_NAME}-postgresql-password \
  --query value -o tsv)
  
  
az logout