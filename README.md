# AWS API Gateway - Monitoring and Logging

Following the [set up logging][1] documentation, there are two types of logging for API Gateway:

- Execution logging
- Access logging

Check the documentation for details.

## Setup

Create your `.auto.tfvars` file from the template:

```sh
cp samples/sample.tfvars .auto.tfvars
```

The sample file has all of the logging configuration fully enabled.

Now, create the API Gateway infrastructure:

```sh
terraform init
terraform apply -auto-approve
```




[1]: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-logging.html#set-up-access-logging-permissions
