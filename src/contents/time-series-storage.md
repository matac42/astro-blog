---
author: matac
datetime: 2023-02-08T06:31:59+09:00
title: Time Series Storageとは
slug: what-is-time-series-storage
featured: false
draft: false
tags:
- paper
ogImage: ''
description: 'This is a note from my reading of the paper "TVStore: Automatically
  Bounding Time Series Storage via Time-Varying Compression".'

---
今日は[TVStore: Automatically Bounding Time Series Storage via Time-Varying Compression](https://www.usenix.org/conference/fast22/presentation/an "TVStore: Automatically Bounding Time Series Storage via Time-Varying Compression")を読みます。いつもタイトルから適当に決めてますが、目標はTime Series Storageにはどういう特徴があって、どういう問題があるのか知ることです。

# メモ

Time Series Dataはそのまま時系列順に並んだデータのことだと思うが、そのStorageってどんなものだろうか。TVStoreというデータの保存方法について書かれている。時系列データは時系列に並んでいて、それを生かしたデータの保存方式があるのだろう。時系列データは時間が経つにつれてどんどん増加していくということと、重要性が落ちてくることがあるという特徴がある。

時系列データは時間で増加していくが、より多く保存するためにどこかのタイミングでデータを圧縮する必要がある。圧縮するものが新しすぎると、解凍の必要が増えてしまうので圧縮するタイミングが大事である。

時系列データをデータの重要性とか圧縮とかのタイミングを考慮したりして、効率的に保存する仕組みを持ったのがTime Series Storageである。

もう少し読むべきですが今日は文字が頭に入ってこないのでこの辺で終了します...