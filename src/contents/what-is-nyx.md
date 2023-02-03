---
author: matac
datetime: 2023-02-03T08:34:43+09:00
title: What is Nyx
slug: ''
featured: false
draft: false
tags:
- paper
ogImage: ''
description: 'This is a note from my reading of the paper "NyxCache: Flexible and
  Efficient Multi-tenant Persistent Memory Caching"'

---
今日は[NyxCache: Flexible and Efficient Multi-tenant Persistent Memory Caching](https://www.usenix.org/conference/fast22/presentation/wu "NyxCache: Flexible and Efficient Multi-tenant Persistent Memory Caching")を読んでいきます。Nyxとは何かを知ることをひとまずの目標とします。今回もちょっとしたメモの感覚で書きます。

# メモ

"NyxCache"なのでキャッシュの仕組みだろうか。Persistent Memoryを今一度確認しておこう。普通コンピュータのメモリといえば電源を切ったらデータが消えるやつで、永続化するときはディスクに保存しなければならない。しかしながら、Persistent Memoryというものはメモリの役割をはたしながら、データの永続化もしてしまう。そう聞くとあの磁力を利用したやつを思い浮かべる。MRAMだ。それとは違うのだろうか。

調べてみるとPersistent MemoryといえばIntel Optane Persistent Memoryみたいな風潮がある。2017年ごろにリリースされたらしい。DDR4互換とかあるようだ。今いくらくらいか気になったので見てみたら$2149らしい。DDR-Tとなっている。

persistent memoryは何となくわかったが、Multi-tenant PMとは？同一のシステムを無関係な複数のユーザーで共有することをマルチテナントというらしい。ということは複数の書き込み元からアクセスされるPMということか。

現状だとPMはDRAMと比べてマルチテナントキャッシュの有効性を低下させるらしい。マルチテナントキャッシュってCloudFrontみたいなもののことで当たっている？キャッシュインスタンスはいくつかあるキャッシュサーバーのうちの一つを指す言葉でいいだろうか。

PM使用量の推定とキャッシュインスタンス同士の干渉を測ることは困難だが、Nyxはそれを行うことで資源の分配を効率的に行う。

Nyxは計測から共有ポリシーの提供をまとめた、PMアクセスのフレームワーク。共有ポリシーが何かわかればNyxについておおまかには知ったことになりそう。

* resource limit
* QoS
* fair slowdown
* proportional resource allocation

これらのことをsharing policyと言っているみたい。ちょうど4章でそれらの説明をしている。どのようにして資源を分配するかという感じだろう。

今日はこの辺にしておきます。