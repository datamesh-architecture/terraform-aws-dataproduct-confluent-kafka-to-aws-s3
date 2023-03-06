locals {
  kafka_topics = [ for input in var.input: input.topic ]
}

resource "confluent_service_account" "app-consumer" {
  display_name = "app-consumer"
  description  = "Service account to consume from 'var.kafka_topics[0]' topic of 'var.kafka.cluster.id' Kafka cluster"
}

resource "confluent_api_key" "app-consumer-kafka-api-key" {
  display_name = "app-consumer-kafka-api-key"
  description  = "Kafka API Key that is owned by 'app-consumer' service account"
  owner {
    id          = confluent_service_account.app-consumer.id
    api_version = confluent_service_account.app-consumer.api_version
    kind        = confluent_service_account.app-consumer.kind
  }

  managed_resource {
    id          = var.kafka.cluster.id
    api_version = var.kafka.cluster.api_version
    kind        = var.kafka.cluster.kind

    environment {
      id = var.kafka.environment.id
    }
  }
}

resource "confluent_kafka_acl" "app-producer-write-on-topic" {
  count = length(local.kafka_topics)

  kafka_cluster {
    id = var.kafka.cluster.id
  }
  resource_type = "TOPIC"
  resource_name = local.kafka_topics[count.index]
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-producer.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = var.kafka.cluster.rest_endpoint
  credentials {
    key    = var.kafka.credentials.api_key_id
    secret = var.kafka.credentials.api_key_secret
  }
}

resource "confluent_service_account" "app-producer" {
  display_name = "app-producer"
  description  = "Service account to produce to 'var.kafka_topics[0]' topic of 'var.kafka.cluster.id' Kafka cluster"
}

resource "confluent_api_key" "app-producer-kafka-api-key" {
  display_name = "app-producer-kafka-api-key"
  description  = "Kafka API Key that is owned by 'app-producer' service account"
  owner {
    id          = confluent_service_account.app-producer.id
    api_version = confluent_service_account.app-producer.api_version
    kind        = confluent_service_account.app-producer.kind
  }

  managed_resource {
    id          = var.kafka.cluster.id
    api_version = var.kafka.cluster.api_version
    kind        = var.kafka.cluster.kind

    environment {
      id = var.kafka.environment.id
    }
  }
}

// Note that in order to consume from a topic, the principal of the consumer ('app-consumer' service account)
// needs to be authorized to perform 'READ' operation on both Topic and Group resources:
// confluent_kafka_acl.app-consumer-read-on-topic, confluent_kafka_acl.app-consumer-read-on-group.
// https://docs.confluent.io/platform/current/kafka/authorization.html#using-acls
resource "confluent_kafka_acl" "app-consumer-read-on-topic" {
  count = length(local.kafka_topics)

  kafka_cluster {
    id = var.kafka.cluster.id
  }
  resource_type = "TOPIC"
  resource_name = local.kafka_topics[count.index]
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-consumer.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = var.kafka.cluster.rest_endpoint
  credentials {
    key    = var.kafka.credentials.api_key_id
    secret = var.kafka.credentials.api_key_secret
  }
}

resource "confluent_kafka_acl" "app-consumer-read-on-group" {
  kafka_cluster {
    id = var.kafka.cluster.id
  }
  resource_type = "GROUP"
  // The existing values of resource_name, pattern_type attributes are set up to match Confluent CLI's default consumer group ID ("confluent_cli_consumer_<uuid>").
  // https://docs.confluent.io/confluent-cli/current/command-reference/kafka/topic/confluent_kafka_topic_consume.html
  // Update the values of resource_name, pattern_type attributes to match your target consumer group ID.
  // https://docs.confluent.io/platform/current/kafka/authorization.html#prefixed-acls
  resource_name = "confluent_cli_consumer_"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app-consumer.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = var.kafka.cluster.rest_endpoint
  credentials {
    key    = var.kafka.credentials.api_key_id
    secret = var.kafka.credentials.api_key_secret
  }
}

resource "confluent_service_account" "app-connector" {
  display_name = "app-connector"
  description  = "Service account of S3 Sink Connector to consume from 'orders' topic of 'inventory' Kafka cluster"
}

resource "confluent_kafka_acl" "app-connector-describe-on-cluster" {
  kafka_cluster {
    id = var.kafka.cluster.id
  }
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-connector.id}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  rest_endpoint = var.kafka.cluster.rest_endpoint
  credentials {
    key    = var.kafka.credentials.api_key_id
    secret = var.kafka.credentials.api_key_secret
  }
}

resource "confluent_kafka_acl" "app-connector-read-on-target-topic" {
  count = length(local.kafka_topics)

  kafka_cluster {
    id = var.kafka.cluster.id
  }
  resource_type = "TOPIC"
  resource_name = local.kafka_topics[count.index]
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-connector.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = var.kafka.cluster.rest_endpoint
  credentials {
    key    = var.kafka.credentials.api_key_id
    secret = var.kafka.credentials.api_key_secret
  }
}

resource "confluent_kafka_acl" "app-connector-create-on-dlq-lcc-topics" {
  kafka_cluster {
    id = var.kafka.cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "dlq-lcc"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app-connector.id}"
  host          = "*"
  operation     = "CREATE"
  permission    = "ALLOW"
  rest_endpoint = var.kafka.cluster.rest_endpoint
  credentials {
    key    = var.kafka.credentials.api_key_id
    secret = var.kafka.credentials.api_key_secret
  }
}

resource "confluent_kafka_acl" "app-connector-write-on-dlq-lcc-topics" {
  kafka_cluster {
    id = var.kafka.cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "dlq-lcc"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app-connector.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = var.kafka.cluster.rest_endpoint
  credentials {
    key    = var.kafka.credentials.api_key_id
    secret = var.kafka.credentials.api_key_secret
  }
}

resource "confluent_kafka_acl" "app-connector-create-on-success-lcc-topics" {
  kafka_cluster {
    id = var.kafka.cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "success-lcc"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app-connector.id}"
  host          = "*"
  operation     = "CREATE"
  permission    = "ALLOW"
  rest_endpoint = var.kafka.cluster.rest_endpoint
  credentials {
    key    = var.kafka.credentials.api_key_id
    secret = var.kafka.credentials.api_key_secret
  }
}

resource "confluent_kafka_acl" "app-connector-write-on-success-lcc-topics" {
  kafka_cluster {
    id = var.kafka.cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "success-lcc"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app-connector.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = var.kafka.cluster.rest_endpoint
  credentials {
    key    = var.kafka.credentials.api_key_id
    secret = var.kafka.credentials.api_key_secret
  }
}

resource "confluent_kafka_acl" "app-connector-create-on-error-lcc-topics" {
  kafka_cluster {
    id = var.kafka.cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "error-lcc"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app-connector.id}"
  host          = "*"
  operation     = "CREATE"
  permission    = "ALLOW"
  rest_endpoint = var.kafka.cluster.rest_endpoint
  credentials {
    key    = var.kafka.credentials.api_key_id
    secret = var.kafka.credentials.api_key_secret
  }
}

resource "confluent_kafka_acl" "app-connector-write-on-error-lcc-topics" {
  kafka_cluster {
    id = var.kafka.cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "error-lcc"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app-connector.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = var.kafka.cluster.rest_endpoint
  credentials {
    key    = var.kafka.credentials.api_key_id
    secret = var.kafka.credentials.api_key_secret
  }
}

resource "confluent_kafka_acl" "app-connector-read-on-connect-lcc-group" {
  kafka_cluster {
    id = var.kafka.cluster.id
  }
  resource_type = "GROUP"
  resource_name = "connect-lcc"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app-connector.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = var.kafka.cluster.rest_endpoint
  credentials {
    key    = var.kafka.credentials.api_key_id
    secret = var.kafka.credentials.api_key_secret
  }
}

resource "confluent_connector" "sink" {
  environment {
    id = var.kafka.environment.id
  }
  kafka_cluster {
    id = var.kafka.cluster.id
  }

  // Block for custom *sensitive* configuration properties that are labelled with "Type: password" under "Configuration Properties" section in the docs:
  // https://docs.confluent.io/cloud/current/connectors/cc-s3-sink.html#configuration-properties
  config_sensitive = {
    "aws.access.key.id"     = var.aws.access_key
    "aws.secret.access.key" = var.aws.secret_key
  }

  // Block for custom *nonsensitive* configuration properties that are *not* labelled with "Type: password" under "Configuration Properties" section in the docs:
  // https://docs.confluent.io/cloud/current/connectors/cc-s3-sink.html#configuration-properties
  config_nonsensitive = {
    "topics"                   = join(", ", local.kafka_topics)
    "input.data.format"        = "JSON"
    "s3.bucket.name"           = aws_s3_bucket.aws_s3_bucket.bucket
    "connector.class"          = "S3_SINK"
    "name"                     = "S3_SINKConnector_0"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.app-connector.id
    "output.headers.format"    = "JSON"
    "tasks.max"                = "1"
    "time.interval"            = "DAILY"
  }

  depends_on = [
    confluent_kafka_acl.app-connector-describe-on-cluster,
    confluent_kafka_acl.app-connector-read-on-target-topic,
    confluent_kafka_acl.app-connector-create-on-dlq-lcc-topics,
    confluent_kafka_acl.app-connector-write-on-dlq-lcc-topics,
    confluent_kafka_acl.app-connector-create-on-success-lcc-topics,
    confluent_kafka_acl.app-connector-write-on-success-lcc-topics,
    confluent_kafka_acl.app-connector-create-on-error-lcc-topics,
    confluent_kafka_acl.app-connector-write-on-error-lcc-topics,
    confluent_kafka_acl.app-connector-read-on-connect-lcc-group,
  ]
}
