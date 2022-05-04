# Creating the Elasticsearch domain
 
resource "aws_elasticsearch_domain" "es" {
  elasticsearch_version = var.elasticsearch_version
  domain_name           = var.domain

  cluster_config {
    instance_type = var.instance_type
    instance_count = 3
  }

  node_to_node_encryption {
    enabled = true
  }

  encrypt_at_rest{
    enabled = true
  }

  domain_endpoint_options {
    enforce_https = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }
  
  snapshot_options {
    automated_snapshot_start_hour = 23
  }
  ebs_options {
    ebs_enabled = var.ebs_volume_size > 0 ? true : false
    volume_size = var.ebs_volume_size
    volume_type = var.volume_type
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.cw_log_grp.arn
    log_type                 = "INDEX_SLOW_LOGS"
  }
    log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.cw_log_grp.arn
    log_type                 = "SEARCH_SLOW_LOGS"
  }
    log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.cw_log_grp.arn
    log_type                 = "ES_APPLICATION_LOGS"
  }

  tags = {
    Domain = var.tag_domain
  }
}

resource "aws_cloudwatch_log_group" "cw_log_grp" {
  name_prefix = "var.domain"
}

# Creating the AWS Elasticsearch domain policy
 
resource "aws_elasticsearch_domain_policy" "main" {
  domain_name = aws_elasticsearch_domain.es.domain_name
  access_policies = <<POLICIES
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "es:ESHttp*"
      ],
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": [
            "${var.allowed_ip}/32"
          ]
        }
      },
      "Resource": "${aws_elasticsearch_domain.es.arn}/*"
    }
  ]
}
POLICIES
}