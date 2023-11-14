---
author: matac
pubDatetime: 2023-10-30T22:02:25.000Z
title: ブログの執筆をより快適にしたい
postSlug: blog-timer
featured: false
draft: false
tags:
  - random
ogImage: ""
description: |
  ブログの執筆をより快適にしたい。
  今回は時間計測の自動化とデプロイ状況の通知を設定した。
_template: blog_post
---

最近ブログは30分以内に書くという縛りを設けた。なので30分のタイマーを設定する必要があるのだが、毎回設定するのが面倒になったのでそこも自動でやってくれるようにした。別にそこまで厳密にやらなくてもいいじゃないかとも思うが、厳密にやらないと緊迫感がないし習慣として定着させることもできなくなりそうなのでちゃんと測りたいのだ。

## 時間計測の自動化

以前[Raycastで引数付きのスクリプトを実行する](/posts/raycast-param)でブログページの元となるMarkdownファイルを自動で作成してくれるスクリプトを書いてそれを使っているので、そこに時間計測のスクリプトを追記してあげると良さそうだ。ということで以下を追記した。

```
osascript -e 'display notification "ブログ作成開始"';
sleep 600; osascript -e 'display notification "10分経過"' -e 'beep 10';
sleep 600; osascript -e 'display notification "20分経過"' -e 'beep 10';
sleep 600; osascript -e 'display notification "終了"' -e 'beep 10';
```

osascriptの`display notification`で指定した文言をMacOSの通知に表示することができる。この場合は「ブログ作成開始」の通知が出る。その後は一定時間経過すると同じように「10分経過」、「20分経過」、「終了」というように通知を出す。単純だがこれでやりたいことはできた。osascriptを使ってみたついでに普通のタイマーも作ってみた。

```
#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title timer
# @raycast.mode compact

# Optional parameters:
# @raycast.icon ⌛️
# @raycast.argument1 { "type": "text", "placeholder": "second", "percentEncoded": true }

sleep $1

# 音を非同期で再生
afplay /Users/matac/Music/amacha/seishishitauchu.mp3 &

# ダイアログを表示
result=$(osascript -e 'display dialog "時間が経過しました。音を停止しますか？" buttons {"続行", "停止"} default button "停止"')

# ユーザーが「停止」ボタンを押したか確認
if [[ $result == *"停止"* ]]; then
  # 音を停止
  pkill afplay
fi
```

osascriptの`display dialog`で以下のようなダイアログを表示することができる。afplayで指定したmp3を再生し、音を停止する時はpkillしている。

![](/img/dialog.png)

## デプロイ状況の通知

今まではデプロイが終わるまでの時間をなんとなくで待ってから投稿されていることを確認していたが、それではデプロイ失敗したときに気付けなかったりまだデプロイ完了していないのに確認したりと時間のロスが発生してしまう。なのでデプロイ状況を通知したい。本当はホスティングしたときに同時に通知設定までするのが礼儀かもしれない。これからはそうする。

私はAmplifyでブログをホスティングしている。なので[Amplify Hostingのビルド結果をAWS ChatbotでSlackに通知](https://zenn.dev/ibaraki/articles/1da11379e528b5)を参考にSlackへの通知をするようにした。そのまんまその通りやっただけで設定できた。

通知が来るだけでかなり快適になった気がする。待ち時間が減るというのはとても気持ちが良いものだ。少しだけ不満をいうならばSlackに通知しなくてはいけないところだろうか。もっと柔軟に色々なサービスに通知できるようにして欲しい。まあそういう時はAWS lambdaを使えば良いのかもしれない。

結構快適になった。でもまだまだ改善できそう。
