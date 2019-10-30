# create auth policy
az eventhubs eventhub authorization-rule create -g eh-splunk-demo --namespace-name eh-splunk-demo-eh-ns --eventhub-name eh-splunk-demo-eh-ns -n eh-splunk-demo-policy --rights {Send,Listen}

# get kv name and eh connect string
eh_conn_str=$(az eventhubs eventhub authorization-rule keys list -g eh-splunk-demo --namespace-name eh-splunk-demo-eh-ns --eventhub-name eh-splunk-demo-eh-ns --name eh-splunk-demo-policy --query primaryConnectionString -o tsv)
kv=$(az keyvault  list -g eh-splunk-demo --query [].name -o tsv)

# get public ip of splunk
splunk_host=$(az network public-ip list -g eh-splunk-demo --query [].ipAddress -o tsv)

# get kv url
kv_uri=$(az keyvault list -g eh-splunk-demo --query [0].properties.vaultUri -o tsv)

# insert connect string in kv 
az keyvault secret set --vault-name $kv -n eh-conn-str --value $eh_conn_str
az keyvault secret set --vault-name $kv -n splunk-host --value $splunk_host
az keyvault secret set --vault-name $kv -n kv-uri --value $kv_uri

export VAULT_URL=$kv_uri
