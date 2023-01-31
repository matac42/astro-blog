---
author: matac
datetime: 2023-01-31T22:30:16Z
title: Try AWS Amplify
slug: ''
featured: false
draft: false
tags: []
ogImage: ''
description: I received an AWS S3 email saying "AWS Free Tier usage limit alerting
  via AWS Budgets", so I'm going to use AWS Amplify instead.

---
昨日AWSから"AWS Free Tier usage limit alerting via AWS Budgets"のメールが来ました。Amazon S3の無料枠は2000リクエストまでらしい。ブログをS3で公開すると、2000リクエストはすぐに到達してしまうみたいです。貴重な無料枠が...

最近BMAXのMiniPCとBeatmaniaのコントローラーを買ってしまった僕の財布は寂しいので、S3以外のブログ公開方法を探しました。見つけたのがAWS Amplifyというサービスです。

ブログのリポジトリはすでにGitHubに置いていたので、Amplifyの画面に従ってリポジトリを登録し、Build設定をAstro用に少しだけ直してDeployしました。忘れないうちにS3にDeployするworkflowファイルを削除して作業は終了です。本来はこのあと、ドメインを割り当て、SSL化するなどの手順があると思いますが、ドメインを準備していないのでひとまずここで終了です。とっても簡単でした。

枠はそれぞれこんな感じのようです。S3はすぐに上限に到達しそうですね。  
![](/img/amplify.png)![](/img/s3.png)

無料枠が終わるとストレージあたりで課金もされるので、だんだん料金が増えていく感じになるみたいですね。やっぱり自宅サーバー欲しいね。静的サイトくらいなら今自分が持ってるリソース+グローバルIPくらいでできてしまいそうだけども。

AWSはいろんなサービスがあってとても便利に使うことができるとは思うけど、お金がたくさん必要ですね。それだけ便利ってことですが。個人的にはセルフホストの方が学びが色々ある気がして好きです。