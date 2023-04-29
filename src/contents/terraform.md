---
author: matac
datetime: 2023-03-15T11:07:42.000Z
title: Terraformでドメインと証明書取得をしたい
slug: terraform-domain-cert
featured: false
draft: false
tags:
  - tec
  - terraform
ogImage: ""
description: TerraformでAWS Route53のドメインとACM Certificateの取得をしてみました。
_template: blog_post
---

AWS にてドメインレコードを作成したり、そのドメインの証明書を取得したりするのはよくある作業だと思います。なので Terraform を用いて、なるべく簡単にこの作業ができるようにしました。

Terraform にはモジュール機能があります。今回はドメインレコードの作成と証明書の取得を行うモジュールを作成します。以下にモジュールのコードを載せます。

    variable "name" {
    }
    variable "records" {
    }
    variable "type" {
    }
    variable "zone_id" {
    }

    # レコード作成
    resource "aws_route53_record" "m4t4c_link" {
      name    = var.name
      records = var.records
      ttl     = 300
      type    = var.type
      zone_id = var.zone_id
    }

    # 証明書発行
    resource "aws_acm_certificate" "m4t4c_link_cert" {
      domain_name       = var.name
      validation_method = "DNS"
    }

    # ドメイン検証
    resource "aws_route53_record" "m4t4c_link_cert" {
      for_each = {
        for dvo in aws_acm_certificate.m4t4c_link_cert.domain_validation_options : dvo.domain_name => {
          name   = dvo.resource_record_name
          record = dvo.resource_record_value
          type   = dvo.resource_record_type
        }
      }
      allow_overwrite = true
      name            = each.value.name
      records         = [each.value.record]
      ttl             = 60
      type            = each.value.type
      zone_id         = var.zone_id
    }
    resource "aws_acm_certificate_validation" "cert" {
      certificate_arn         = aws_acm_certificate.m4t4c_link_cert.arn
      validation_record_fqdns = [for record in aws_route53_record.m4t4c_link_cert : record.fqdn]
    }

    output "domain_and_cert" {
      value = "Domain ${var.name} issued"
    }

このモジュールは以下のように使用します。

    locals {
      domains = {
        "blog.m4t4c.link" = {
          "records" = ["main.d27qi54rrqckxi.amplifyapp.com"],
          "type"    = "CNAME"
        },
        "hoge.m4t4c.link" = {
          "records" = ["blog.m4t4c.link"],
          "type"    = "CNAME"
        }
      }
    }

    module "aws_record_and_cert" {
      for_each = local.domains
      source   = "./modules"
      name     = each.key
      records  = each.value.records
      type     = each.value.type
      zone_id  = aws_route53_zone.m4t4c_link.zone_id
    }

最初はモジュール化せずに for や for_each を使用してどうにかしようとしましたが、コードが複雑化しとてもメンテナンスできるものではありませんでした。ループで回すにしても、回す対象をモジュール化する方がコードとしては簡単になったのでそちらを採用しました。local.domains にレコード情報を列挙し`aws_record_and_cert`
に食わせています。
