# AWS API Gateway - Monitoring and Logging

Following the [set up logging][1] documentation for API Gateway, there are two two types of API logging in CloudWatch: execution logging and access logging.

#### Execution logging

Execution logging is managed by API Gateway via the `API-Gateway-Execution-Logs_{rest-api-id}/{stage_name}` log group format.

> The logged data includes errors or execution traces (such as request or response parameter values or payloads), data used by Lambda authorizers (formerly known as custom authorizers), whether API keys are required, whether usage plans are enabled, and so on.

#### Access logging

- Execution logging - 
- Access logging



[1]: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-logging.html#set-up-access-logging-permissions
