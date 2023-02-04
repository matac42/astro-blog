---
author: matac
datetime: 2023-02-04T08:56:13+09:00
title: What is contiguous in ctFS?
slug: ''
featured: false
draft: false
tags:
- paper
ogImage: ''
description: 'This is a note from my reading of the paper "ctFS: Replacing File Indexing
  with Hardware Memory Translation through Contiguous File Allocation for Persistent
  Memory".'

---
今日は[ctFS: Replacing File Indexing with Hardware Memory Translation through Contiguous File Allocation for Persistent Memory](https://www.usenix.org/conference/fast22/presentation/li "ctFS: Replacing File Indexing with Hardware Memory Translation through Contiguous File Allocation for Persistent Memory")を読んでいきたいと思います。ctFSにおけるcontiguousとは何かを理解することを目標にします。

# メモ

contiguousとは

* 隣接する、近接する
* 〔時間的に〕連続的な、切れ目のない

ctFS自体はpersistent memoryにおけるファイルシステムのインデキシングにおけるオーバーヘッドを取り除くために考えられたもの。

byte-addressableとは、バイト単位でアクセスできることを指す。

"contiguous file allocation"というものがあって、それはfile indexingの代わりになるものらしい。ctFSはファイルを仮想メモリ上に"連続的に"アロケートするものらしい。ということで、ctFSにおけるcontiguousはファイルがメモリ上に連続的にアロケートされることを意味していた。今日の目標は達成したが、もう少し読んでいく。

contiguous file allocationの問題点はfragmentationやファイルの移動コストがかかること。利点はオフセットの計算だけでファイルのアドレスが求まること。ctFSはbuddy memory allocationと同じような仕組みを用いてフラグメンテーションの軽減をしているらしい。

今日はこのあたりで終わりにする。たまには1つの論文をもっと深く読む回があっても良いかもしれない。