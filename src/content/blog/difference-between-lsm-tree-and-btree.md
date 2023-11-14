---
author: matac
pubDatetime: 2023-02-01T00:45:38.000Z
title: Difference between LSM-Tree and BTree
slug: "difference-between-lsm-tree-and-btree"
featured: false
draft: false
tags: []
ogImage: ""
description: |
  I have read a bit of The Log-Structured Merge-Tree (LSM-Tree) and these are my
  notes.
_template: blog_post
---

今日は[The Log-Structured Merge-Tree (LSM-Tree)](https://www.cs.umb.edu/~poneil/lsmtree.pdf)を少しだけ読みました。30 年前の論文ですが、LSM-Tree が気になったので。

LSM-Tree は B-Tree に対して、index の挿入速度に優位があるようです。

## 読んでる時のメモ

いつの論文かわからないですが、大体 1995 年とかだと思います。30 年前...LSM-Tree はインデック挿入を効率よく行うことができるらしい。メモリとディスクの両方がある前提の仕組みのようだ。B 木には I/O コストが 2 倍になる問題があるようだ。インデックスの変更を遅らせて実行することで効率的な変更ができる？ディスクアームの動きを減らすことができるらしいが、SSD や DRAM だとどうなるのか。30 年前ですでに real-time なシステムを想定して論文が書かれていた。今だったら何を想定する？分散システム？TPC-A ベンチマークは銀行が舞台のようだけど、今だったら SNS とかの方が処理が重いんじゃないだろうか。まあ、そんなに信頼性は必要ないかもしれないけど。信頼性が必要だと仮定した SNS でいいのではないだろうか。

## TPC とは

[https://www.weblio.jp/content/TPC](https://www.weblio.jp/content/TPC "https://www.weblio.jp/content/TPC")

> トランザクション処理システムの性能指標（ベンチマーク）

らしい。TPC-A,B,C,D,H,R,W というふうに 7 種類のベンチマークがあるみたいです(もっとありそう)。論文では TPC-A を例題として使っていました。TPC-A は database の update が激しいシステムを想定しているようです。([https://www.tpc.org/tpca/default5.asp](https://www.tpc.org/tpca/default5.asp "https://www.tpc.org/tpca/default5.asp"))

LSM-Tree は index の挿入に特化しているので、TPC-A でベンチマークすることで B-Tree に対する優位性を示すことができそうです。しかしながら、TPC-A は今ではあまり指標として用いられないらしいです。single transaction だからでしょうか。現在よくあるアプリケーションは multiple transaction なので用いられなくなったという感じだと思います(予想で適当なことを言っています)。
