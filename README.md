# Data Mesh Terraform module "Confluent Kafka to AWS S3"

This Terraform module provisions the necessary services to provide a data product on AWS.

![Overview](https://www.datamesh-architecture.com/images/terraform-dataproduct-confluent-kafka-to-aws-s3.png)

## Services

* Confluent Kafka
* AWS S3
* AWS Glue
* AWS Lambda

## Usage

```hcl
module "kafka_to_s3" {
  module = "git@github.com:datamesh-architecture/terraform-dataproduct-confluent-kafka-to-aws-s3.git"

  domain = "<data_product_domain>"
  name   = "<data_product_name>"
  input  = [
    {
      topic      = "<topic_name>"
      format     = "<format>"
      table_name = "<table_name>"
      schema     = "schema/<name_of_the_schema>.schema.json"
    }
  ]
  output = {
    grant_access = [ "<aws_account_id>" ]
  }
}
```

## Endpoint data

The module creates an RESTful endpoint via AWS lambda (e.g. https://xz9am9uu74.execute-api.eu-central-1.amazonaws.com/prod/). This endpoint can be used as an input for another data product or to retrieve information about this data product.

```json
{
    "domain": "<data_product_domain>",
    "name": "<data_product_name>",
    "output": {
        "glue_database": "<glue_database>",
        "location": "arn:aws:s3:::<s3_bucket_name>"
    }
}
```

## Examples

Examples, how to use this module, can be found in a separate [GitHub repository](https://github.com/datamesh-architecture/terraform-datamesh-dataproduct-examples).

## Authors

This terraform module is maintained by [André Deuerling](https://www.innoq.com/en/staff/andre-deuerling/), [Jochen Christ](https://www.innoq.com/en/staff/jochen-christ/), and [Simon Harrer](https://www.innoq.com/en/staff/dr-simon-harrer/).

## License

MIT License.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.56 |
| <a name="requirement_confluent"></a> [confluent](#requirement\_confluent) | >= 1.34 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.3.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.53.0 |
| <a name="provider_confluent"></a> [confluent](#provider\_confluent) | 1.24.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_apigatewayv2_api.lambda_info](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api) | resource |
| [aws_apigatewayv2_integration.lambda_info](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_integration) | resource |
| [aws_apigatewayv2_route.lambda_info](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_route) | resource |
| [aws_apigatewayv2_stage.lambda_info_prod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_stage) | resource |
| [aws_cloudwatch_log_group.lambda_info](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_glue_catalog_database.aws_glue_catalog_database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_database) | resource |
| [aws_glue_catalog_table.aws_glue_catalog_table_kafka](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_table) | resource |
| [aws_glue_schema.aws_glue_schema](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_schema) | resource |
| [aws_iam_role.lambda_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_kms_key.aws_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lambda_function.lambda_info](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.lambda_info](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket.aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.aws_s3_bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_policy.allow_access_from_another_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.aws_s3_bucket_server_side_encryption_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_object.archive_info_to_s3_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [confluent_api_key.app-consumer-kafka-api-key](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/api_key) | resource |
| [confluent_api_key.app-producer-kafka-api-key](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/api_key) | resource |
| [confluent_connector.sink](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/connector) | resource |
| [confluent_kafka_acl.app-connector-create-on-dlq-lcc-topics](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.app-connector-create-on-error-lcc-topics](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.app-connector-create-on-success-lcc-topics](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.app-connector-describe-on-cluster](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.app-connector-read-on-connect-lcc-group](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.app-connector-read-on-target-topic](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.app-connector-write-on-dlq-lcc-topics](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.app-connector-write-on-error-lcc-topics](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.app-connector-write-on-success-lcc-topics](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.app-consumer-read-on-group](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.app-consumer-read-on-topic](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.app-producer-write-on-topic](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_service_account.app-connector](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/service_account) | resource |
| [confluent_service_account.app-consumer](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/service_account) | resource |
| [confluent_service_account.app-producer](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/service_account) | resource |
| [local_file.lambda_info_to_s3](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [archive_file.archive_info_to_s3](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy_document.allow_access_from_another_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws"></a> [aws](#input\_aws) | AWS related information and credentials | <pre>object({<br>    region     = string<br>    access_key = string<br>    secret_key = string<br>  })</pre> | n/a | yes |
| <a name="input_confluent"></a> [confluent](#input\_confluent) | Confluent (Cloud) related credentials | <pre>object({<br>    cloud_api_key    = string<br>    cloud_api_secret = string<br>  })</pre> | n/a | yes |
| <a name="input_domain"></a> [domain](#input\_domain) | The domain of the data product | `string` | n/a | yes |
| <a name="input_input"></a> [input](#input\_input) | topic: Name of the Kafka topic which should be processed<br>format: Currently only 'JSON' is supported<br>table\_name: Name of the data catalog table, where data is stored<br>schema: Path to the JSON schema file which describes the messages received from Kafka and the table within the data catalog | <pre>list(object({<br>    topic      = string<br>    format     = string<br>    table_name = string<br>    schema     = string<br>  }))</pre> | n/a | yes |
| <a name="input_kafka"></a> [kafka](#input\_kafka) | Information and credentials about/from the Kafka cluster | <pre>object({<br>    environment = object({<br>      id = string<br>    })<br>    cluster = object({<br>      id            = string<br>      api_version   = string<br>      kind          = string<br>      rest_endpoint = string<br>    })<br>    credentials = object({<br>      api_key_id     = string<br>      api_key_secret = string<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the data product | `string` | n/a | yes |
| <a name="input_output"></a> [output](#input\_output) | grant\_access: "List of AWS account ids which should have access to the data product" | <pre>object({<br>    grant_access = list(string)<br>  })</pre> | <pre>{<br>  "grant_access": []<br>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
