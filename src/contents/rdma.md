---
author: matac
datetime: 2023-02-06T08:02:22.000+09:00
title: RDMAとは何か？
slug: what-is-rdma
featured: false
draft: false
tags:
- paper
ogImage: ''
description: 'This is a note from my reading of the paper "FORD: Fast One-sided RDMA-based
  Distributed Transactions for Disaggregated Persistent Memory".'

---
タイトルを日本語にしました。URLが日本語になってしまうのが嫌だったのですが、`slug`を用いることでURLとタイトルを分離できることを知りました。

今日[FORD: Fast One-sided RDMA-based Distributed Transactions for Disaggregated Persistent Memory](https://www.usenix.org/conference/fast22/presentation/zhang-ming "FORD: Fast One-sided RDMA-based Distributed Transactions for Disaggregated Persistent Memory")を読みたいと思います。RDMAとは何かを理解することを目的とします。

# メモ

Abstract冒頭で"Persistent memmory disaggregation"という言葉が出てくるがどういう意味だろうか。disaggregationは直訳すると「分解」になるが、PMの分解？

FORDのことをtransaction systemと言っている。ということはRDMAもtransaction system?

> Memory disaggregation, which decouples the compute and memory resources from the traditional monolithic servers into independent compute and memory pools, \~

計算資源とメモリを分離するのがmemory disaggregationのようだ。その利点というか意義は何だろうか。確かに分離することで、それぞれ必要な分だけ用意するといったことが可能になり、よりコスト効率が良いリソースの準備ができる。AWSなどの大規模なクラウドサービスにおいてそのアーキテクチャはより大きな効果をもたらすことが予想できる。

現在の逸般の誤家庭はモノリシックなサーバーを使用していることが多い様に感じるが(モノリシックの使い方当たってる？)、これからはmemory disaggregation architectureを採用したシステムを構築するのが流行るかも...？自分はそういうのを目標にやってみるか。面白そう。

> Fast networks, e.g., RDMA, \~

ネットワーク？memory disaggregationによって分離された資源を接続するためにRDMAを用いるらしい。

abstractとintroductionだけではRDMAが何なのか具体的にはわからなかった。

RDMAとはRemote Direct Memory Accessの略で、CPUを介さずにリモートからメモリに直接書き込むことができる機能のこと。CPUを介さないということはRDMA専用のデバイスが必要になりそう。

[https://rdma.hatenablog.com/entry/2014/04/06/161737](https://rdma.hatenablog.com/entry/2014/04/06/161737 "https://rdma.hatenablog.com/entry/2014/04/06/161737")

RDMA結構楽しそうだな。InfiniBandってどこかで聞いたことあるな。RDMAで遊んでみよう。逸般の誤家庭界隈ではすでに色々知見がありそう。