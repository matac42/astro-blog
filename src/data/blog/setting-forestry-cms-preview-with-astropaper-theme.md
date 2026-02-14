---
author: matac
pubDatetime: 2023-02-01T15:15:32.000Z
title: Setting FORESTRY CMS preview with AstroPaper theme
postSlug: "setting-forestry-cms-preview-with-astropaper-theme"
featured: false
draft: false
tags: []
ogImage: ""
description: I tried to setting preview on FORESTRY CMS
_template: blog_post
---

FORESTRY CMS にプレビュー機能があったので設定してみました。使用しているサイトジェネレーターは Astro でテーマは[AstroPaper](https://astro.build/themes/details/astro-paper/ "AstroPaper")です。

## 設定

- 環境は nodejs を選択する
- RELOAD THE PREVIEW TAB WHEN THE PREVIEW BUTTON IS CLICKED は画像では on になっていますが off にした方が preview への反映が速いです
- 依存パッケージをインストールするコマンド(npm install)を設定する
- ビルドコマンド(npm run dev)を設定する
- ビルドアウトプットのディレクトリ(dist)を設定する

![](/img/2023-02-02-0-15-28.png)

設定項目を入力したら、SAVE して preview サーバーを start します。

エディタ画面で目のマークのボタンを押すと preview を開くことができます。![](/img/2023-02-02-0-33-32.png)

実際の見た目が気になる場合はこのように preview の機能を使うと良いと思います。しかし、マークダウンで書く場合は実際の見た目をほぼ正確に想像できると思うのであまり使わない気もします。FORESTRY CMS は WISYWYG エディタがついているのでそれをみるだけでも十分に感じます。とはいえ、デプロイする前に実際の見た目を確認できるのはいいですね。
