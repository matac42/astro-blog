---
author: matac
datetime: 2023-02-01T23:25:06+09:00
title: Try Certificate Authentication on MySQL(But I could not do it)
slug: ''
featured: false
draft: false
tags: []
ogImage: ''
description: I tried to setting up Certificate Authentication on MySQL, but could
  not do it.

---
MySQLに接続するときは、パスワード認証がよく用いられています。よりセキュアな接続方法としてSSH接続でプロキシするなどがあります。PostgreSQLにはクライアント認証の手段に [https://www.postgresql.org/docs/10/auth-methods.html#AUTH-CERT](https://www.postgresql.org/docs/10/auth-methods.html#AUTH-CERT "Certificate Authentication")が存在します。これと同じことがMySQLにおいて可能か調査しました。

結論は「できない」です。

MySQLにおいてクライアント認証の手段は認証プラグインとして提供されます。しかしながら、使用可能な認証プラグインに証明書を用いた認証を行うものがありませんでした。証明書を用いることで認証ではなく単に通信の暗号化とホストのなりすましを防止することは可能です。

[https://dev.mysql.com/doc/refman/8.0/ja/pluggable-authentication.html#pluggable-authentication-available-plugins](https://dev.mysql.com/doc/refman/8.0/ja/pluggable-authentication.html#pluggable-authentication-available-plugins "使用可能な認証プラグイン")

DBはそもそも外部公開しないのがセオリーで、DB以外のレイヤでセキュリティの確保を行います。しかしながら、開発用のDBなどは開発者が外部からアクセスするニーズがあると思います。そのときは通信の暗号化などをDBのレイヤで行うか、プロキシ用のマシンを間に設置するなどレイヤを追加する必要があります。(ex. Client - SSH - **VM** - DB)