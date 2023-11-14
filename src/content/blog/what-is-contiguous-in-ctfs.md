---
author: matac
pubDatetime: 2023-02-03T23:56:13.000Z
title: What is contiguous in ctFS
slug: "what-is-contiguous-in-ctfs"
featured: false
draft: false
tags:
  - paper
ogImage: ""
description: |
  This is a note from my reading of the paper "ctFS: Replacing File Indexing
  with Hardware Memory Translation through Contiguous File Allocation for
  Persistent Memory".
_template: blog_post
---

今日は[ctFS: Replacing File Indexing with Hardware Memory Translation through Contiguous File Allocation for Persistent Memory](https://www.usenix.org/conference/fast22/presentation/li "ctFS: Replacing File Indexing with Hardware Memory Translation through Contiguous File Allocation for Persistent Memory")を読んでいきたいと思います。ctFS における contiguous とは何かを理解することを目標にします。

# メモ

contiguous とは

- 隣接する、近接する
- 〔時間的に〕連続的な、切れ目のない

ctFS 自体は persistent memory におけるファイルシステムのインデキシングにおけるオーバーヘッドを取り除くために考えられたもの。

byte-addressable とは、バイト単位でアクセスできることを指す。

"contiguous file allocation"というものがあって、それは file indexing の代わりになるものらしい。ctFS はファイルを仮想メモリ上に"連続的に"アロケートするものらしい。ということで、ctFS における contiguous はファイルがメモリ上に連続的にアロケートされることを意味していた。今日の目標は達成したが、もう少し読んでいく。

contiguous file allocation の問題点は fragmentation やファイルの移動コストがかかること。利点はオフセットの計算だけでファイルのアドレスが求まること。ctFS は buddy memory allocation と同じような仕組みを用いてフラグメンテーションの軽減をしているらしい。

今日はこのあたりで終わりにする。たまには 1 つの論文をもっと深く読む回があっても良いかもしれない。

追記：buddy memory allocation の説明をしてる記事があった。何となくだが理解できた。

- [https://codezine.jp/article/detail/9325](https://codezine.jp/article/detail/9325 "https://codezine.jp/article/detail/9325")
