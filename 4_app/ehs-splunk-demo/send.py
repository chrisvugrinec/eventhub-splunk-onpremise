import time
import os
from azure.eventhub import EventHubClient, EventData, EventHubSharedKeyCredential


HOSTNAME = os.environ['EVENT_HUB_HOSTNAME']  # <mynamespace>.servicebus.windows.net
EVENT_HUB = os.environ['EVENT_HUB_NAME']
USER = os.environ['EVENT_HUB_SAS_POLICY']
KEY = os.environ['EVENT_HUB_SAS_KEY']

client = EventHubClient(host=HOSTNAME, event_hub_path=EVENT_HUB, credential=EventHubSharedKeyCredential(USER, KEY),
                        network_tracing=False)
producer = client.create_producer(partition_id="0")

start_time = time.time()
counter = 10
with producer:
    for i in range(counter):
        ed = EventData("GoodNight world nr: {} ".format(i))
        print("Sending message: {}".format(i))
        producer.send(ed)
print("Send {} messages in {} seconds".format(counter, time.time() - start_time))
