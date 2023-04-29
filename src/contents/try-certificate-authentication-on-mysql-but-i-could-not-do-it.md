---
author: matac
datetime: 2023-02-01T14:25:06.000Z
title: Try Certificate Authentication on MySQL(But I could not do it)
slug: ""
featured: false
draft: false
tags: []
ogImage: ""
description: >-
  I tried to setting up Certificate Authentication on MySQL, but could not do
  it.
_template: blog_post
---

MySQL に接続するときは、パスワード認証がよく用いられています。よりセキュアな接続方法として SSH 接続でプロキシするなどがあります。PostgreSQL にはクライアント認証の手段に [https://www.postgresql.org/docs/10/auth-methods.html#AUTH-CERT](https://www.postgresql.org/docs/10/auth-methods.html#AUTH-CERT "Certificate Authentication")が存在します。これと同じことが MySQL において可能か調査しました。

結論は「できない」です。

MySQL においてクライアント認証の手段は認証プラグインとして提供されます。しかしながら、使用可能な認証プラグインに証明書を用いた認証を行うものがありませんでした。証明書を用いることで認証ではなく単に通信の暗号化とホストのなりすましを防止することは可能です。

[https://dev.mysql.com/doc/refman/8.0/ja/pluggable-authentication.html#pluggable-authentication-available-plugins](https://dev.mysql.com/doc/refman/8.0/ja/pluggable-authentication.html#pluggable-authentication-available-plugins "使用可能な認証プラグイン")

DB はそもそも外部公開しないのがセオリーで、DB 以外のレイヤでセキュリティの確保を行います。しかしながら、開発用の DB などは開発者が外部からアクセスするニーズがあると思います。そのときは通信の暗号化などを DB のレイヤで行うか、プロキシ用のマシンを間に設置するなどレイヤを追加する必要があります。(ex. Client - SSH - **VM** - DB)
