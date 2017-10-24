# Azure IoT WS - Part 1

    In this section we will create an Azure IoT Hub, Time Series Insights and setup ingestion from a device simulator.

### Create Azure resources

1. Create a new Resource Group. We recommend giving it a clear prefix like `initials-datedigits`. For example `kdg-10247`.
1. Create an Azure IoT Hub - choose Free tier if you don't have one already in your subscription (only one Free allowed). Choose S1 if you cannot create a free one. You can use the default settings.
1. Create a Time Series Insights account
1. One your IoT Hub is created, go to Endpoints > Built-in Endpoints > Events. 
    1. Add a consumer group name `timeseries`.
1. Add a device to your IoT Hub. You can use the Device Explorer pane in the IoT Hub. 
    Optional: use IoT Hub ***Device Explorer*** tool (see pre-requisites) or the CLI tool ***iothub-explorer*** to create your device instead.
1. Go to your Time Series account. Add a data source to consume data from the IoT Hub, and make sure to use the `timeseries` consumer group.

### The simulator for ingestion of telemetry

1. Leverage a simulator to ingest sensor telemetry into IoT Hub.
1. You can use the Raspberry Pi online simulator for this if you like: https://docs.microsoft.com/en-us/azure/iot-hub/iot-hub-raspberry-pi-web-simulator-get-started
1. After ingesting telemetry you should be able to dive into the telemetry data using your Time Series Insights account.

TODO: add simulator app 


