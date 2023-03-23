---
author: matac
datetime: 2023-03-23T18:10:00+09:00
title: ドメインの移管をした
slug: terraform-route53-apply-destroy
featured: false
draft: false
tags:
- tec
- terraform
ogImage: ''
description: ネームサーバー周りを繰り返しapply & destroyして遊んでいたら問題が発生したのでそれについて。

---
次のような流れのコードを書いていました。

- Hosted Zone登録
- レコード追加
- 証明書発行

これを繰り返しapply & destroyすると問題が発生します。通常の運用でドメイン周りを繰り返しapply & destroyすることはないですが、もしかしたらそういう運用もあるかもしれないということで、解決してみました。

問題が発生したのはNSレコード周りでした。NSレコードはHosted Zoneを登録するときに自動的に割り当てられます。
NSレコードはドメインの権威を持つネームサーバーを指定しますが、NSレコード以外にも指定する場所があります。
それはRegistered domainのName serversの設定です。NSレコードは`dig`コマンドで参照できるのに対し、
Registered domainのName serversは`whois`コマンドで参照できます。
それぞれどういうものなのかについては割愛しますが、問題はこの2つの情報がNSレコードの自動生成によりずれてしまうということです。

ずれると実際にどのような問題が発生するかというと、レコードを引くことができなくなります。
完全に引くことができなくなるわけではないですが、簡単に例を出すと単純な`dig`は返ってこなくなりますが、
Name serverを指定すれば返ってくるという感じです。

```
dig m4t4c.link # 返ってこない

dig m4t4c.link @ns-1143.awsdns-14.org # 返ってくる
```

`dig`はwhois情報からネームサーバーを引っ張ってきているということでしょうか。
とにかく、これら2つの情報を一致させてあげる必要がありそうです。

一致させるには単純に考えて3つのアプローチがありますね。

- Registered domainのName serversをNSレコードに合わせる
- NSレコードをRegistered domainのName serversに合わせる
- 両方を固定する

結論は`Registered domainのName serversをNSレコードに合わせる`です。
他の方法は全て失敗しました。

## Registered domainのName serversをNSレコードに合わせる

以下のようなコードを書きました。(まだforの使い方がよくわかっていない人のコード)

```
resource "aws_route53_zone" "m4t4c_link" {
  comment = "HostedZone created by Route53 Registrar"
  name    = "m4t4c.link"
}

resource "aws_route53domains_registered_domain" "m4t4c_link" {
  domain_name = "m4t4c.link"

  name_server {
    name = aws_route53_zone.m4t4c_link.name_servers[0]
  }
  name_server {
    name = aws_route53_zone.m4t4c_link.name_servers[1]
  }
  name_server {
    name = aws_route53_zone.m4t4c_link.name_servers[2]
  }
  name_server {
    name = aws_route53_zone.m4t4c_link.name_servers[3]
  }
}
```

`aws_route53_zone`でHosted Zoneの登録を行い、`aws_route53domains_registered_domain`で
Name serversを書き換えています。これで、NSレコードとRegistered domainのName serversは一致します。

## ダメだった方法

- NSレコードをRegistered domainのName serversに合わせる
- 両方を固定する

この２つは失敗しました。理由はNSレコードを書き換えたとしても、
実際の権威サーバーが変更されることはなく実態とレコードがずれてしまったことによります。
なので、NSレコードを編集するこの2つの方法はうまくいかなかったわけです。
NSレコードを書き換える場合は権威サーバーも変更されている必要があります。

実際に公式のドキュメントにもこのような記載があります。

> Amazon Route 53 によって、ホストゾーンと同じ名前のネームサーバー (NS) レコードが自動的に作成されます。これには、ホストゾーンの 4 つの正式なネームサーバーがリストされます。まれな状況を除き、このレコードのネームサーバーを追加、変更、または削除しないことをお勧めします。

[https://docs.aws.amazon.com/ja_jp/Route53/latest/DeveloperGuide/SOA-NSrecords.html#NSrecords](https://docs.aws.amazon.com/ja_jp/Route53/latest/DeveloperGuide/SOA-NSrecords.html#NSrecords "https://docs.aws.amazon.com/ja_jp/Route53/latest/DeveloperGuide/SOA-NSrecords.html#NSrecords")より

なので以上のこととドキュメントの内容を理解した上で、それでもNSレコードを変更する必要がある場合以外は
NSレコードを編集しないのがセオリーとなります。

## コード

最後にコード全体を載せておきます。

```
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
    key            = "matac.terraform.domain.tfstate"
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
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

# Domains
resource "aws_route53_zone" "m4t4c_link" {
  comment = "HostedZone created by Route53 Registrar"
  name    = "m4t4c.link"
}

resource "aws_route53domains_registered_domain" "m4t4c_link" {
  domain_name = "m4t4c.link"

  name_server {
    name = aws_route53_zone.m4t4c_link.name_servers[0]
  }
  name_server {
    name = aws_route53_zone.m4t4c_link.name_servers[1]
  }
  name_server {
    name = aws_route53_zone.m4t4c_link.name_servers[2]
  }
  name_server {
    name = aws_route53_zone.m4t4c_link.name_servers[3]
  }
}

# ACM
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

module "record_and_cert" {
  for_each = local.domains
  source   = "./record_and_cert"
  name     = each.key
  records  = each.value.records
  type     = each.value.type
  zone_id  = aws_route53_zone.m4t4c_link.zone_id
}
```