---
author: matac
pubDatetime: 2023-02-02T23:34:43.000Z
title: What is Nyx
postSlug: "what-is-nyx"
featured: false
draft: false
tags:
  - paper
ogImage: ""
description: |
  This is a note from my reading of the paper "NyxCache: Flexible and Efficient
  Multi-tenant Persistent Memory Caching"
_template: blog_post
---

今日は[NyxCache: Flexible and Efficient Multi-tenant Persistent Memory Caching](https://www.usenix.org/conference/fast22/presentation/wu "NyxCache: Flexible and Efficient Multi-tenant Persistent Memory Caching")を読んでいきます。Nyx とは何かを知ることをひとまずの目標とします。今回もちょっとしたメモの感覚で書きます。

# メモ

"NyxCache"なのでキャッシュの仕組みだろうか。Persistent Memory を今一度確認しておこう。普通コンピュータのメモリといえば電源を切ったらデータが消えるやつで、永続化するときはディスクに保存しなければならない。しかしながら、Persistent Memory というものはメモリの役割をはたしながら、データの永続化もしてしまう。そう聞くとあの磁力を利用したやつを思い浮かべる。MRAM だ。それとは違うのだろうか。

調べてみると Persistent Memory といえば Intel Optane Persistent Memory みたいな風潮がある。2017 年ごろにリリースされたらしい。DDR4 互換とかあるようだ。今いくらくらいか気になったので見てみたら$2149 らしい。DDR-T となっている。

persistent memory は何となくわかったが、Multi-tenant PM とは？同一のシステムを無関係な複数のユーザーで共有することをマルチテナントというらしい。ということは複数の書き込み元からアクセスされる PM ということか。

現状だと PM は DRAM と比べてマルチテナントキャッシュの有効性を低下させるらしい。マルチテナントキャッシュって CloudFront みたいなもののことで当たっている？キャッシュインスタンスはいくつかあるキャッシュサーバーのうちの一つを指す言葉でいいだろうか。

PM 使用量の推定とキャッシュインスタンス同士の干渉を測ることは困難だが、Nyx はそれを行うことで資源の分配を効率的に行う。

Nyx は計測から共有ポリシーの提供をまとめた、PM アクセスのフレームワーク。共有ポリシーが何かわかれば Nyx についておおまかには知ったことになりそう。

- resource limit
- QoS
- fair slowdown
- proportional resource allocation

これらのことを sharing policy と言っているみたい。ちょうど 4 章でそれらの説明をしている。どのようにして資源を分配するかという感じだろう。

今日はこの辺にしておきます。
