---
author: matac
datetime: 2023-10-25T20:51:19.000Z
title: Raycastで引数付きのスクリプトを実行する
slug: raycast-param
featured: false
draft: false
tags:
  - tec
ogImage: 
description: >-
  Raycastで引数付きのスクリプトを実行する
_template: blog_post
---

昨日からブログを時間に30分の制限を設けることにしたため、ブログを書き出すまでの時間を短縮したい。
CMSなどを組み込んで書くのも悪くはないが(というかすでに組み込んではあるのだが)、
Raycastのスクリプト実行機能でさっとやる方が良いと思ったのでやってみることにした。

私はMarkdownで内容を書いてAstroで記事を生成している。
生成はpushすれば勝手にやってくれるので手元でやるべきはMarkdownを準備することだけだ。
AstroではMarkdownファイルの先頭にフロントマターというメタデータを記述する必要がある。
例えば今日の記事であればこんな感じの物を記述する。

```
---
author: matac
datetime: 2023-10-25T20:51:19.000Z
title: Raycastで引数付きのスクリプトを実行する
slug: raycast-param
featured: false
draft: false
tags:
  - tec
ogImage: 
description: >-
  Raycastで引数付きのスクリプトを実行する
_template: blog_post
---
```

スタティックなテンプレートから単純なコピーでこれを入れてあげるのでもいいが、
いくつか変動する部分があるのでそれを置き換えつつ入れ込むのが良いだろう。
今回の場合は

- datetime
- slug(md file name)

が変動し、かつ自動で挿入しておきたい部分となる。
titleとかは記事を書きながら考えるので初期段階では空白で良い。

スクリプトを書けば上記のことは実現できる。
以下のような物になるだろう。

```bash
blog_repo='/Users/matac/ws/src/github.com/matac42/astro-blog'
dt=`date '+%Y-%m-%dT%H:%M:%S.000Z'`

echo -e "---
author: matac
datetime: $dt
title:
slug: $1
featured: false
draft: false
tags:
  - beatmania
  - sound_game
  - random
  - existentialism
  - tec
  - terraform
  - philosophy
  - filesystem
  - infra
  - paper
  - network
  - erlang
ogImage: ""
description: >-
  説明文
_template: blog_post
---
" > "$blog_repo/src/contents/$1.md"

code -g "$blog_repo/src/contents/$1.md:4:8" $blog_repo
```

長く見えるが真ん中あたりはテンプレ文なので実質4行だ。
ただ、このスクリプトを毎回ターミナルを開いて打つのは面倒だ。
そこで出てくるのが[Raycast script-commandsのArguments](https://github.com/raycast/script-commands/blob/master/documentation/ARGUMENTS.md
)だ。


詳細は公式のドキュメントを参照して欲しいが、RaycastのScript Commandに引数を渡す方法だ。
最終的なスクリプトは以下のとおりだ。

```bash
#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title create blog
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "slug", "percentEncoded": true }

blog_repo='/Users/matac/ws/src/github.com/matac42/astro-blog'
dt=`date '+%Y-%m-%dT%H:%M:%S.000Z'`

echo -e "---
author: matac
datetime: $dt
title: 
slug: $1
featured: false
draft: false
tags:
  - beatmania
  - sound_game
  - random
  - existentialism
  - tec
  - terraform
  - philosophy
  - filesystem
  - infra
  - paper
  - network
  - erlang
ogImage: ""
description: >-
  説明文
_template: blog_post
---
" > "$blog_repo/src/contents/$1.md"
code -g "$blog_repo/src/contents/$1.md:4:8" $blog_repo
```

`Optional parameters`でslugを渡せるようにしている。

実行する様子はこんな感じだ。⌘+SpaceでRaycastを開きbと打ったあとTabでslugに移動し`slug-test`などのslugを入れる。

![](/img/raycast-arg.png)

スクリプトの最後に`code`コマンドを入れていて、自動でVSCodeが立ち上がるので書き始めまでがとてもスムーズになった。