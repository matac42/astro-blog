---
author: matac
datetime: 2023-03-03T14:37:32.000Z
title: EC2インスタンスを増やしたり減らしたりしたい
slug: apply-ec2-instance-with-tf-up-down
featured: false
draft: false
tags:
  - terraform
  - tec
ogImage: ""
description: misskey.ioの影響を受けてリソースの増減を簡単にやってみたくなりました。
_template: blog_post
---

なんか色々前置きとかの文章を書いてましたが、鳥になってどこかへ飛んでいってしまったようなので省略して主な結果だけ書きます！

Terraform 使って EC2 を増やしたり減らしたりしました。まず tf コード全文。

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
        key            = "matac.terraform.ec2s.tfstate"
        encrypt        = true
        dynamodb_table = "matac-terraform-state-lock"
      }
      # backend "local" {
      #    path   = "terraform.tfstate"
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

    data "aws_ami" "ubuntu" {
      most_recent = true

      filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
      }

      filter {
        name   = "virtualization-type"
        values = ["hvm"]
      }

      owners = ["099720109477"] # Canonical
    }

    resource "aws_instance" "matac-ec2s" {
      count         = 31
      ami           = data.aws_ami.ubuntu.id
      instance_type = "t2.micro"

      tags = {
        Name = "matac-ec2s-${count.index}"
      }
    }

大事なのは count の部分です。以下に全文から説明部分の抜粋を載せます。

    resource "aws_instance" "matac-ec2s" {
      count         = 31 # ここ
      ami           = data.aws_ami.ubuntu.id
      instance_type = "t2.micro"

      tags = {
        Name = "matac-ec2s-${count.index}"
      }
    }

count の数字を変更して terraform apply することでインスタンス数を増減できます。本当にそれだけなので、AWS EC2 のリソース以外でも Terraform を使えばリソースの増減を簡単に行えるはずです。リミッターを解除すれば 100 個でも 1000 個でもインスタンスを立ち上げることができるし、そこから何個減らすということもできます。

便利だ！以上！
