---
author: matac
pubDatetime: 2023-01-31T22:30:16.000Z
title: Try AWS Amplify
slug: "try-aws-amplify"
featured: false
draft: false
tags: []
ogImage: ""
description: |
  I received an AWS S3 email saying "AWS Free Tier usage limit alerting via AWS
  Budgets", so I'm going to use AWS Amplify instead.
_template: blog_post
---

昨日 AWS から"AWS Free Tier usage limit alerting via AWS Budgets"のメールが来ました。Amazon S3 の無料枠は 2000 リクエストまでらしい。ブログを S3 で公開すると、2000 リクエストはすぐに到達してしまうみたいです。貴重な無料枠が...

最近 BMAX の MiniPC と Beatmania のコントローラーを買ってしまった僕の財布は寂しいので、S3 以外のブログ公開方法を探しました。見つけたのが AWS Amplify というサービスです。

ブログのリポジトリはすでに GitHub に置いていたので、Amplify の画面に従ってリポジトリを登録し、Build 設定を Astro 用に少しだけ直して Deploy しました。忘れないうちに S3 に Deploy する workflow ファイルを削除して作業は終了です。本来はこのあと、ドメインを割り当て、SSL 化するなどの手順があると思いますが、ドメインを準備していないのでひとまずここで終了です。とっても簡単でした。

枠はそれぞれこんな感じのようです。S3 はすぐに上限に到達しそうですね。  
![](/img/amplify.png)![](/img/s3.png)

無料枠が終わるとストレージあたりで課金もされるので、だんだん料金が増えていく感じになるみたいですね。やっぱり自宅サーバー欲しいね。静的サイトくらいなら今自分が持ってるリソース+グローバル IP くらいでできてしまいそうだけども。

AWS はいろんなサービスがあってとても便利に使うことができるとは思うけど、お金がたくさん必要ですね。それだけ便利ってことですが。個人的にはセルフホストの方が学びが色々ある気がして好きです。
