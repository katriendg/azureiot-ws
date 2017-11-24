# Azure IoT WS - Part 2

> In this lab we leverage IoT Hub Routes and endpoints to automatically store all telemetry messages coming in into Storage Blobs. When you use Routes, you also need to add a route for the default 'Events' endpoint if you want to keep receiving messages into it.

![picture alt](media/part2-architecture.png "Azure Architecture")

### Add a Storage account
1. Create a new Storage account in your resource group. It can be a locally redundant storage.
1. Once the account is created, go to Blobs to create a new container named `telemetryarchive`. You will need this in the next step.

### Add the routes in IoT Hub

1. In your Iot Hub, add an Endpoint to the newly created Storage account. This will serve as the destination of telemetry message for cold storage.
1. Make sure you refer to the previsouly created storage container `telemetryarchive`.
1. Go to the Routes section and add a route to deliver all 'Device Messages' to the newly created Storage endpoint. For now we want to store all telemetry so leave the condition empty. 
1. Add a second route to route all 'Device Messages' to the built-in endpoint named Events. This is required otherwise the already configured consumer group to deliver messages to Time Series Insights will stop receiving telemetry. 
    1. To do this, in the Routes pane, add a new route. 
    1. For 'Data Source', choose Device Messages.
    1. For 'Endpoint', choose 'events'. This is the built-in endpoint.
    1. Leave the Query string empty to prevent filtering any of the messages.


### End result 

1. Using the online simulator make sure you have ingest of telemetry.
1. Go to your Storage account and validate you are getting all telemetry stored into blobs. The format will be Apache Avro.
1. Validate also that you are still getting the ingest into Time Series Insights.


## Other parts in this lab

1. [Part 1](part1.md)
1. [Part 3](part3.md)
1. [Part 4](part4.md)