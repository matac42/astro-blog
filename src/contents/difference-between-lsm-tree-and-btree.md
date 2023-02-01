---
author: matac
datetime: 2023-02-01T09:45:38+09:00
title: Difference between LSM-Tree and BTree
slug: ''
featured: false
draft: false
tags: []
ogImage: ''
description: I have read a bit of The Log-Structured Merge-Tree (LSM-Tree) and these
  are my notes.

---
今日は[The Log-Structured Merge-Tree (LSM-Tree)](https://www.cs.umb.edu/\~poneil/lsmtree.pdf)を少しだけ読みました。30年前の論文ですが、LSM-Treeが気になったので。

LSM-TreeはB-Treeに対して、indexの挿入速度に優位があるようです。

## 読んでる時のメモ

いつの論文かわからないですが、大体1995年とかだと思います。30年前...LSM-Treeはインデック挿入を効率よく行うことができるらしい。メモリとディスクの両方がある前提の仕組みのようだ。B木にはI/Oコストが2倍になる問題があるようだ。インデックスの変更を遅らせて実行することで効率的な変更ができる？ディスクアームの動きを減らすことができるらしいが、SSDやDRAMだとどうなるのか。30年前ですでにreal-timeなシステムを想定して論文が書かれていた。今だったら何を想定する？分散システム？TPC-Aベンチマークは銀行が舞台のようだけど、今だったらSNSとかの方が処理が重いんじゃないだろうか。まあ、そんなに信頼性は必要ないかもしれないけど。信頼性が必要だと仮定したSNSでいいのではないだろうか。

## TPCとは

[https://www.weblio.jp/content/TPC](https://www.weblio.jp/content/TPC "https://www.weblio.jp/content/TPC")

> トランザクション処理システムの性能指標（ベンチマーク）

らしい。TPC-A,B,C,D,H,R,Wというふうに7種類のベンチマークがあるみたいです(もっとありそう)。論文ではTPC-Aを例題として使っていました。TPC-Aはdatabaseのupdateが激しいシステムを想定しているようです。([https://www.tpc.org/tpca/default5.asp](https://www.tpc.org/tpca/default5.asp "https://www.tpc.org/tpca/default5.asp"))

LSM-Treeはindexの挿入に特化しているので、TPC-AでベンチマークすることでB-Treeに対する優位性を示すことができそうです。しかしながら、TPC-Aは今ではあまり指標として用いられないらしいです。single transactionだからでしょうか。現在よくあるアプリケーションはmultiple transactionなので用いられなくなったという感じだと思います(予想で適当なことを言っています)。