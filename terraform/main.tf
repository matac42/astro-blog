terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.50"
    }
  }
  backend "s3" {
    bucket         = "matac-terraform-backend"
    region         = "ap-northeast-1"
    key            = "astro-blog.terraform.tfstate"
    encrypt        = true
    dynamodb_table = "matac-terraform-state-lock"
  }
  # backend "local" {
  #   path = "terraform.tfstate"
  # }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = "ap-northeast-1"
  allowed_account_ids = [
    "954039864504"
  ]
  profile = "matac"
}

resource "aws_vpc" "ab-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    "Name" = "ab-vpc"
  }
  tags_all = {
    "Name" = "ab-vpc"
  }
}

resource "aws_subnet" "ab-subnet1" {
  assign_ipv6_address_on_creation = false
  availability_zone               = "ap-northeast-1c"
  cidr_block                      = "10.0.0.0/24"
  tags = {
    "Name" = "ab-subnet1"
  }
  tags_all = {
    "Name" = "ab-subnet1"
  }
  vpc_id = aws_vpc.ab-vpc.id
}

resource "aws_subnet" "ab-subnet2" {
  assign_ipv6_address_on_creation = false
  availability_zone               = "ap-northeast-1a"
  cidr_block                      = "10.0.10.0/24"
  tags = {
    "Name" = "ab-subnet2"
  }
  tags_all = {
    "Name" = "ab-subnet2"
  }
  vpc_id = aws_vpc.ab-vpc.id
}

resource "aws_subnet" "ab-subnet3" {
  assign_ipv6_address_on_creation = false
  availability_zone               = "ap-northeast-1c"
  cidr_block                      = "10.0.20.0/24"
  tags = {
    "Name" = "ab-subnet3"
  }
  tags_all = {
    "Name" = "ab-subnet3"
  }
  vpc_id = aws_vpc.ab-vpc.id
}

resource "aws_subnet" "ab-subnet4" {
  assign_ipv6_address_on_creation = false
  availability_zone               = "ap-northeast-1a"
  cidr_block                      = "10.0.30.0/24"
  tags = {
    "Name" = "ab-subnet4"
  }
  tags_all = {
    "Name" = "ab-subnet4"
  }
  vpc_id = aws_vpc.ab-vpc.id
}

resource "aws_internet_gateway" "ab-igw" {
  tags = {
    "Name" = "ab-igw"
  }
  tags_all = {
    "Name" = "ab-igw"
  }
  vpc_id = aws_vpc.ab-vpc.id
}

resource "aws_route_table" "ab-route-table" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ab-igw.id
  }
  tags = {
    "Name" = "ab-route-table"
  }
  tags_all = {
    "Name" = "ab-route-table"
  }
  vpc_id = aws_vpc.ab-vpc.id
}

resource "aws_route_table_association" "dev1" {
  subnet_id      = aws_subnet.ab-subnet1.id
  route_table_id = aws_route_table.ab-route-table.id
}

resource "aws_route_table_association" "dev2" {
  subnet_id      = aws_subnet.ab-subnet2.id
  route_table_id = aws_route_table.ab-route-table.id
}

resource "aws_security_group" "ab-sg" {
  name        = "ab-sg"
  description = "Allow developers access to the development environment"
  vpc_id      = aws_vpc.ab-vpc.id
}

resource "aws_security_group_rule" "ssh" {
  cidr_blocks       = ["111.107.12.138/32"]
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.ab-sg.id
}

resource "aws_security_group_rule" "mysql" {
  cidr_blocks       = ["111.107.12.138/32"]
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.ab-sg.id
}

resource "aws_security_group_rule" "http" {
  cidr_blocks       = ["111.107.12.138/32"]
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.ab-sg.id
}

resource "aws_security_group_rule" "all" {
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ab-sg.id
}

resource "aws_key_pair" "ab" {
  key_name   = "ab"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDXL6pktlr/gkn7b0J8BzYEwN+sWuyeWffgutG4JJG9H7QHbGTi/2ZlR25m2DXFUv5Y4bH7iUKlIjVeNNw9NC5jXG0OgNALAb81KRf1zrMcSyd/gznG8vC37M8ypqEg9m8isD4RT9hz9Z/DGTr7EOoGzpRMgOB7dPCLIWMqplIJOIt5SgLxMWgXbzjYd+ZUIe3Z+m1y4sFwwxDsgh9qum3aKANLWEUp4bnm2VfTGs9iqS4vrRgsIUApGnc6QSGBVgl76QAy44fHkUEFS4I4Ad92utlK+WdCapOBYtCc2yO8zz6PZgpvL29VTBUciq96ZCWvX18WPr/a5ZbHqPcKwDrn e185742@matac.local"
}

resource "aws_ecs_cluster" "ab" {
  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT",
  ]
  name = "astro-blog"
  tags = {
    "ecs:cluster:createdFrom" = "ecs-console-v2"
  }
  tags_all = {
    "ecs:cluster:createdFrom" = "ecs-console-v2"
  }

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }

  service_connect_defaults {
    namespace = "arn:aws:servicediscovery:ap-northeast-1:954039864504:namespace/ns-s4bsl53yrj2z4c4m"
  }

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecs_task_definition" "ab" {
  container_definitions = jsonencode(
    [
      {
        cpu              = 0
        environment      = []
        environmentFiles = []
        essential        = true
        image            = "docker.io/matac/astro-blog"
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-create-group  = "true"
            awslogs-group         = "/ecs/astro-blog"
            awslogs-region        = "ap-northeast-1"
            awslogs-stream-prefix = "ecs"
          }
        }
        mountPoints = []
        name        = "astro-blog"
        portMappings = [
          {
            appProtocol   = "http"
            containerPort = 80
            hostPort      = 80
            name          = "astro-blog-80-tcp"
            protocol      = "tcp"
          },
        ]
        volumesFrom = []
      },
    ]
  )
  cpu                = "1024"
  execution_role_arn = "arn:aws:iam::954039864504:role/ecsTaskExecutionRole"
  family             = "astro-blog"
  memory             = "3072"
  network_mode       = "awsvpc"
  requires_compatibilities = [
    "FARGATE",
  ]
  tags = {
    "ecs:taskDefinition:createdFrom" = "ecs-console-v2"
  }
  tags_all = {
    "ecs:taskDefinition:createdFrom" = "ecs-console-v2"
  }

  ephemeral_storage {
    size_in_gib = 21
  }

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
}
