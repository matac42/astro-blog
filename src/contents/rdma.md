---
author: matac
datetime: 2023-02-05T23:02:22.000Z
title: RDMAとは何か？
slug: what-is-rdma
featured: false
draft: false
tags:
  - paper
ogImage: ""
description: >-
  This is a note from my reading of the paper "FORD: Fast One-sided RDMA-based
  Distributed Transactions for Disaggregated Persistent Memory".
_template: blog_post
---

タイトルを日本語にしました。URL が日本語になってしまうのが嫌だったのですが、`slug`を用いることで URL とタイトルを分離できることを知りました。

今日[FORD: Fast One-sided RDMA-based Distributed Transactions for Disaggregated Persistent Memory](https://www.usenix.org/conference/fast22/presentation/zhang-ming "FORD: Fast One-sided RDMA-based Distributed Transactions for Disaggregated Persistent Memory")を読みたいと思います。RDMA とは何かを理解することを目的とします。

# メモ

Abstract 冒頭で"Persistent memmory disaggregation"という言葉が出てくるがどういう意味だろうか。disaggregation は直訳すると「分解」になるが、PM の分解？

FORD のことを transaction system と言っている。ということは RDMA も transaction system?

> Memory disaggregation, which decouples the compute and memory resources from the traditional monolithic servers into independent compute and memory pools, \~

計算資源とメモリを分離するのが memory disaggregation のようだ。その利点というか意義は何だろうか。確かに分離することで、それぞれ必要な分だけ用意するといったことが可能になり、よりコスト効率が良いリソースの準備ができる。AWS などの大規模なクラウドサービスにおいてそのアーキテクチャはより大きな効果をもたらすことが予想できる。

現在の逸般の誤家庭はモノリシックなサーバーを使用していることが多い様に感じるが(モノリシックの使い方当たってる？)、これからは memory disaggregation architecture を採用したシステムを構築するのが流行るかも...？自分はそういうのを目標にやってみるか。面白そう。

> Fast networks, e.g., RDMA, \~

ネットワーク？memory disaggregation によって分離された資源を接続するために RDMA を用いるらしい。

abstract と introduction だけでは RDMA が何なのか具体的にはわからなかった。

RDMA とは Remote Direct Memory Access の略で、CPU を介さずにリモートからメモリに直接書き込むことができる機能のこと。CPU を介さないということは RDMA 専用のデバイスが必要になりそう。

[https://rdma.hatenablog.com/entry/2014/04/06/161737](https://rdma.hatenablog.com/entry/2014/04/06/161737 "https://rdma.hatenablog.com/entry/2014/04/06/161737")

RDMA 結構楽しそうだな。InfiniBand ってどこかで聞いたことあるな。RDMA で遊んでみよう。逸般の誤家庭界隈ではすでに色々知見がありそう。
