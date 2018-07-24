using System;
using System.Collections;
using Amazon.Lambda.Core;

[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.Json.JsonSerializer))]

namespace test
{
    public class Function
    {
        public string FunctionHandler(object inputEvent, ILambdaContext context)
        {
            context.Logger.Log($"inputEvent: {inputEvent}");
            LambdaLogger.Log($"RemainingTime: {context.RemainingTime}");

            foreach (DictionaryEntry kv in Environment.GetEnvironmentVariables())
            {
                context.Logger.Log($"{kv.Key}={kv.Value}");
            }

            return "Hello World!";
        }
    }
}
