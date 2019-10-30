import asyncio
import logging
import os
import json
from azure.eventhub.aio import EventHubClient
from azure.eventhub import EventPosition
from azure.eventhub.aio.eventprocessor import EventProcessor, PartitionProcessor
from azure.eventhub.aio.eventprocessor import SamplePartitionManager
from splunk_handler import SplunkHandler
from azure.keyvault import KeyVaultClient, KeyVaultAuthentication, KeyVaultId
from azure.common.credentials import ServicePrincipalCredentials

RECEIVE_TIMEOUT = 5  
RETRY_TOTAL = 3 
VAULT_URL = os.environ['VAULT_URL']

logging.basicConfig(level=logging.WARNING)


def auth_callback(server, resource, scope):
    credentials = ServicePrincipalCredentials(
        client_id = os.environ['TF_VAR_CLIENT_ID'],
        secret = os.environ['TF_VAR_CLIENT_SECRET'],
        tenant = os.environ['TF_VAR_TENANT_ID'],
        resource = "https://vault.azure.net"
    )
    token = credentials.token
    return token['token_type'], token['access_token']

def init():
    client = KeyVaultClient(KeyVaultAuthentication(auth_callback))
    SPLUNK_HOST = client.get_secret(VAULT_URL, 'splunk-host',secret_version=KeyVaultId.version_none).value
    SPLUNK_TOKEN = client.get_secret(VAULT_URL, 'splunk-token',secret_version=KeyVaultId.version_none).value
    EH_CONNECTION_STR = client.get_secret(VAULT_URL, 'eh-conn-str',secret_version=KeyVaultId.version_none).value
    splunk = SplunkHandler(
        host= SPLUNK_HOST,
        port='8088',
        token= SPLUNK_TOKEN,
        index='main',
        verify=False
    )
    init.ehclient = EventHubClient.from_connection_string(EH_CONNECTION_STR, receive_timeout=RECEIVE_TIMEOUT, retry_total=RETRY_TOTAL)
    logging.getLogger('').addHandler(splunk)



async def write_to_splunk(event):
    content = event.body_as_str()
    # Check if load is json
    try:
        data = json.loads(content)
    except:
        print("non json...exiting, content was: {}".format(content))
        logging.warning(content)
        return        
    # Load is json, see if load contains expected fields
    # This should be rewritten using FLUENTD/ LOGSTASH or something similar
    try:      
        for p in data['records']:

            operationName =  p['operationName']
            resourceId =  p['resourceId']
            result = p['resultType']
            logmessage = "operation: {} on resource {}, was: {}".format(operationName, resourceId, result)
            print(logmessage)
            logging.warning(logmessage)
    except:
        #print("ignoring, does not contain expected content, message was {}".format(content))
        print("ignoring, does not contain expected content, expecting operationName and Result in json")
    

class SplunkPartitionProcessor(PartitionProcessor):
    async def process_events(self, events, partition_context):
        if events:
            await asyncio.gather(*[write_to_splunk(event) for event in events])
            await partition_context.update_checkpoint(events[-1].offset, events[-1].sequence_number)
        else:
            print("no events received", "partition:", partition_context.partition_id)


init()
if __name__ == '__main__':
    consumer_group = "logging-events"
    loop = asyncio.get_event_loop()
    partition_manager = SamplePartitionManager(":memory:")
    event_processor = EventProcessor(init.ehclient, consumer_group, SplunkPartitionProcessor, partition_manager, polling_interval=1)
    try:
        loop.run_until_complete(event_processor.start())
    except KeyboardInterrupt:
        loop.run_until_complete(event_processor.stop())
    finally:
        loop.stop()
