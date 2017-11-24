#r "Newtonsoft.Json"

using System;
using System.Threading.Tasks;
using Microsoft.Azure.Devices;
using Newtonsoft.Json;

static string connectionString = GetEnvironmentVariable("Azure_IoT_ConnectionString");


public static async Task Run(string queueMsg, TraceWriter log)
{
    log.Info($"C# ServiceBus queue trigger - raw message received: {queueMsg}");

    var queueItem = JsonConvert.DeserializeObject<MyMessage>(queueMsg);

   try{
       await SendDMessage(queueItem.DeviceId, log);
       log.Info($"Direct Method called 'shutdownUsage'");
   }
   catch (Exception exception)
   {
      log.Info($"Exception: {exception}");
   }
   
}


static async Task SendDMessage(string deviceId, TraceWriter log)
{
    // create IoT Hub connection.
    var serviceClient = ServiceClient.CreateFromConnectionString(connectionString, Microsoft.Azure.Devices.TransportType.Amqp);
    var methodInvocation = new CloudToDeviceMethod("stop") { ResponseTimeout = TimeSpan.FromSeconds(10) };

    log.Info($"Ready to send DM to device {deviceId}");
    //send DM
    var response = await serviceClient.InvokeDeviceMethodAsync(deviceId, methodInvocation);
    
}


class MyMessage
{
    public string DeviceId { get; set; }
    public double AverageConsumption { get; set; }
    public double MaxConsumption { get; set; }
    public double OverTimeInSeconds { get; set; }
    public int HowManyTimes { get; set; }
    public DateTime ProjectedTime { get; set; }
}

public static string GetEnvironmentVariable(string name)
{
    return System.Environment.GetEnvironmentVariable(name, EnvironmentVariableTarget.Process);
}
