terraform {
  backend "s3" {
    bucket = "aramis-aws-terraform-remote-state-dev"
    key    = "ec2/ec2provider.tfstate"
    region = "us-east-2"
  }
}




provider "aws" {
  region = "${var.region}"
}



# Criando topico e assinatura SNS na AWS

resource "aws_sns_topic" "Monitoramento_criacao_remocao_recursos" {
  name = "Monitoramento_atividades"
  
}

resource "aws_sns_topic_subscription" "assinatura_email" {
  topic_arn = aws_sns_topic.Monitoramento_criacao_remocao_recursos.arn
  protocol = "email"
  endpoint = "aramisoliveira@live.com"
}






# Criando um event bridge


