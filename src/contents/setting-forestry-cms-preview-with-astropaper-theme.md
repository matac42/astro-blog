---
author: matac
datetime: 2023-02-02T00:15:32+09:00
title: Setting FORESTRY CMS preview with AstroPaper theme
slug: ''
featured: false
draft: false
tags: []
ogImage: ''
description: I tried to setting preview on FORESTRY CMS

---
FORESTRY CMSにプレビュー機能があったので設定してみました。使用しているサイトジェネレーターはAstroでテーマは[AstroPaper](https://astro.build/themes/details/astro-paper/ "AstroPaper")です。

## 設定

* 環境はnodejsを選択する
* RELOAD THE PREVIEW TAB WHEN THE PREVIEW BUTTON IS CLICKEDは画像ではonになっていますがoffにした方がpreviewへの反映が速いです
* 依存パッケージをインストールするコマンド(npm install)を設定する
* ビルドコマンド(npm run dev)を設定する
* ビルドアウトプットのディレクトリ(dist)を設定する

![](/img/2023-02-02-0-15-28.png)

設定項目を入力したら、SAVEしてpreviewサーバーをstartします。

エディタ画面で目のマークのボタンを押すとpreviewを開くことができます。![](/img/2023-02-02-0-33-32.png)

実際の見た目が気になる場合はこのようにpreviewの機能を使うと良いと思います。しかし、マークダウンで書く場合は実際の見た目をほぼ正確に想像できると思うのであまり使わない気もします。FORESTRY CMSはWISYWYGエディタがついているのでそれをみるだけでも十分に感じます。とはいえ、デプロイする前に実際の見た目を確認できるのはいいですね。