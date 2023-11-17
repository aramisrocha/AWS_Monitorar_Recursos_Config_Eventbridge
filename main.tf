terraform {
  backend "s3" {
    bucket = "aramis-aws-terraform-remote-state-dev"
    key    = "ec2/ec2provider.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  region = var.region
}

# Criando tópico e assinatura SNS na AWS
resource "aws_sns_topic" "Monitoramento_criacao_remocao_recursos" {
  name = "Monitoramento_atividades"
}

resource "aws_sns_topic_subscription" "assinatura_email" {
  topic_arn = aws_sns_topic.Monitoramento_criacao_remocao_recursos.arn
  protocol  = "email"
  endpoint  = "aramisoliveira@live.com"
}

# Criando um EventBridge
resource "aws_cloudwatch_event_rule" "Monitor_config" {
  name        = "MinhaRegraEventBridge"
  description = "Regra para eventos de alteração de Configuração"

  event_pattern = <<PATTERN
{
  "source": ["aws.config"],
  "detail-type": ["Config Configuration Item Change"],
  "detail": {
    "messageType": ["ConfigurationItemChangeNotification"],
    "configurationItem": {
      "configurationItemStatus": ["ResourceDiscovered", "ResourceDeleted"]
    }
  }
}
PATTERN
}

# Definindo como os recursos serao entregues para o destinario
resource "aws_cloudwatch_event_target" "monitor" {
  arn  = aws_sns_topic.Monitoramento_criacao_remocao_recursos.arn
  rule = aws_cloudwatch_event_rule.Monitor_config.id

  input_transformer {
    input_paths = {
      awsAccountId = "$.detail.configurationItem.awsAccountId",
      awsRegion    = "$.detail.configurationItem.awsRegion",
      status       = "$.detail.configurationItem.configurationItemStatus",
      resourceId   = "$.detail.configurationItem.resourceId",
      resourceType = "$.detail.configurationItem.resourceType",
      eventName    = "$.detail.eventName",
      configurationItemCaptureTime: "$.detail.configurationItem.configurationItemCaptureTime",
      userName     = "$.detail.userIdentity.userName"
    }
    input_template = "\"O recurso <resourceId> foi <status> na hora <configurationItemCaptureTime> na conta <awsAccountId> na região <awsRegion>\""
  }
}

