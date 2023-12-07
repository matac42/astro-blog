---
author: matac
pubDatetime: 2023-12-07T23:45:23.000Z
title: SplitTrieとは
postSlug: split-trie
featured: false
draft: false
tags:
  - reading
  - tec
  - paper
  - network
ogImage: ""
description: |
  SplitTrieとは
_template: blog_post
---

アルゴリズムの講義で論文紹介をする必要があるので、アルゴリズム系の論文を探して読んでいる。
結局、選んだのは[SplitTrie: A Fast Update Packet Classification Algorithm with Trie Splitting](https://www.mdpi.com/2079-9292/11/2/199)だ。SplitTrieはネットワークスイッチなどが行うパケットのルールマッチング構造のアップデートを高速化する。
トライ木をfield type vectorを元に分割してサイズを抑えることでアップデート時の計算量を抑える。
一旦field type vectorによるインデックスを作成する感じだと理解している。
SDNなどのルールセットが複雑なネットワーク環境において、より効果を発揮する。
