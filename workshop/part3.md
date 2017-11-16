# Azure IoT WS - Part 3

> In this lab we will add an route to Event Hubs upon a rule that acts on alerts from the device. Once in Event Hubs we add a logic app to trigger and send a mail to the customer alerting her of high usage. We also use Device Twins to change the ingest rate for telemetry.

![picture alt](media/part3-architecture.png "Azure Architecture")

### Add Event Hubs and route

1. Create a new Event Hub account in your resource group.
1. Add an event hub to the namespace.
1. Optional: add a consumer group.
1. In the IoT Hub, add an Endpoint to the Event Hub you created above.
1. Add a Route to the endpoint, add a condition to route messages with a user property `usagealert='true'`.

### Simulator to send a property in the telemetry message
1. Option A: using the online simulator
1. Option B: using the Smart meter sample, see [Part 1](part1.md), Option B to set it up first.


#### Option A: Online simulator

1. Add a Message *property* `usagealert` with a value of `true` to a random or calculated message. 
_Note: Message properties are strings, so your condition needs to match to a string value._
1. Hint: change the `sendMessage` function to add a new property based on some rule.
1. Run the simulator to ingest telemetry. Make sure one of the messages triggers the property to be added to one or more messages.
1. Validate the Event Hub is receiving messages that match the condition (you can use the Metrics data for the Event Hub to get numbers of messages coming in). This should validate your route is working.

#### Option B: Smart meter simulator
1. If it's still running, stop the metersimulator app `Ctrl + C`.
2. In the file `app/controllers/home.js` you will find code posting telemetry (messages) to the IoT Hub. Add a simple rule to have a property added to the message.
```javascript
var message = new Message(data);
//Add an alert calculation/simulate an alert
if([yourrulehere]){
    message.properties.add('usagealert', 'true');
}
```
3. Start the simulator again.
4. Start telemetry.
5. Validate the Event Hub is receiving messages that match the condition (you can use the Metrics data for the Event Hub to get numbers of messages coming in). This should validate your route is working.

### Add a Logic App to alert customer

1. Create a new Logic app
1. Add a Trigger for messages coming from an Event Hub
1. Select your Event Hub (you'll need to go to advanced properties to add a Consumer group name if you created one)
1. By default the trigger will look for new messages every 3 minutes. During dev you can put this to 1 minute.
1. Add an action to send e-mail via Office 365 or another connector of your choice.
1. For the receiver, as this is for testing and we don't to spam anyone, enter your own e-mail address (static value).
1. For the message body, you can leverage the Dynamic content from the previous step. To retrieve the Message's body, use `[Content]` Dynamic property. Note: if you want to parse the Json you can add a step before this action to Parse JSON. For this you will need the schema of the message.
    1. Additionally the Message body is encoded so to parse the JSON you will need to go into code view of the logic app, and use the following expression in the Content field: `@{base64ToString(triggerBody()?['ContentData'])}`.
1. Enable the Logic App.
1. Run the Trigger. If there are messages in the Event Hub it should fire the trigger. You can verify runs by viewing the Trigger History. You should now get an e-mail in your inbox. 
1. Note: you might want to disable the Logic App to stop receiving e-mails.

### Device Twins

1. We'll use a device twin to change the rate on which telemetry messages are sent to the cloud.
1. Option A: using online tools
1. Option B: using Smart meter simulator and Agent console simulator.

#### Option A: use online tools

1. Use an app, the Device Explorer tool or the Azure Portal's device explorer to set the telemetry rate property. Use the Desired property for this.
1. In the Online simulator app, react to Device Twin change event and adapt the telemetry send rate to the value received. Hint: get some insights on Device Twins [here](https://docs.microsoft.com/en-us/azure/iot-hub/iot-hub-node-node-twin-how-to-configure).
1. Once the rate goes up, you should be able to see values at higher rate coming into Time Series Insights (Scenario is an operator will be able to dive into much more granular info).
1. Optional: use the Desired property again to set the rate back to every 10 seconds for example.

#### Option B: Smart meter and agent console
1. You'll use the Smart meter simulator (see [Part 1](part1.md) for setup) application, as well as the operator service console (which is another sample app in the same repo).
1. Go to the `serviceportal` directory. Open it in VS code `code .`.
1. Using a command line terminal, or within the Integrated Terminal in Visual Studio Code, start up the application by
    1. Run `npm install` to install the node packages
    1. Run `npm start` to start the application
    1. Browse to [http://localhost:3330/](http://localhost:3330/)
1. On the homepage, enter the connection string to your IoT Hub. You can find this in the Azure Portal, under the hub's Shared access policies. You'll need the iothubowner policy.
1. In the top right drop down you'll find a list of devices. Select the device you want.
1. Choose Device Twin > Desired in the top navigation bar.
1. Set the value of the messaging interval to 1000 and submit. 
1. Run `metersimulator` app in a new browser window if it was not already running, make sure you have the same device connected as above. This application will run on port 3300 by default.
1. Review the console log to watch for a desired property change that will now start sending telemetry at a new rate.

### End result 
1. You have received an e-mail with a warning from the Logic App.
1. Review the telemetry coming into Time Series Insights.
1. You should now see higher frequency telemetry.


### Optional: make it more real with a customer's e-mail address

You could leverage a custom function or Stream Analytics with reference data containing Customer information. Create a new Event with a message body that contains the customer e-mail and only then get the Logic App to run. In this case you can keep the Route's condition but you might be sending it to an Azure Function first instead of directly to the Logic App.

### Other parts in this lab

1. [Part 1](workshop/part1.md)
1. [Part 2](workshop/part2.md)
1. [Part 4](workshop/part4.md)