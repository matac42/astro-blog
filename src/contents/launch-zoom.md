---
author: matac
datetime: 2023-11-07T21:12:06.000Z
title: ZoomのミーティングをRaycastで起動する
slug: launch-zoom
featured: false
draft: false
tags:
  - tec
ogImage: 
description: >-
  ZoomのミーティングをRaycastで起動する
_template: blog_post
---

アプリケーションランチャーの[Raycast](https://www.raycast.com/)はとても便利で愛用している。
Macユーザーであればぜひ使ってもらいたいランチャーだ。普段やっている何気ない動作をより効率的に行うことができるようになる。今回はZoomのミーティングを始める動作を効率化できた。

私はミーティングやゼミの時などはZoomを使っている。使う時はZoomを起動してから新規ミーティングを作成してURLをコピーしてそれを共有するという流れだが、Raycastによってこの動作がショートカットキーひとつで済む。

## 設定方法

- まずRaycastの[Zoom Extension](https://www.raycast.com/raycast/zoom)をインストールする
- Raycastの設定でZoomのStart Meeting Commandにショートカットキーを割り当てる
- Zoomの設定で「ミーティングの開始時に招待のリンクをコピー」にチェックを入れる

この設定をすることでショートカットキーを入力するだけで新規ミーティングが立ち上がり、招待URLがコピーされる。

「ミーティングの開始時に招待のリンクをコピー」は以前から設定していたがショートカットキーを設定することでより素早くミーティングを開始することができるようになった。小さいことではあるが結構快適になったと思う。
Zoomだとこういう感じだが多分他のアプリケーションでもこういうことができるようなExtensionsがあって、色々試してみたい。難しいのは効率化できる部分に気づくことではあるのだが......