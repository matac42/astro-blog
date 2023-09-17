---
author: matac
datetime: 2023-09-17T22:56:00.000Z
title: GCのコーディングを始めた
slug: gc-coding-start
featured: false
draft: false
tags:
  - tec
ogImage: ""
description: >-
  GCのコーディングを始めた
_template: blog_post
---

ちょっと今日はネタがないというかブログを書く時間がないので短めに。

以前よりminigcを読んでいたがこれからは書いていこうと思う。リポジトリは[これ](https://github.com/matac42/minicpgc)だ。minigcはmark & sweep GCだったが私はCopying GCでminigcを実装してみようと思う。おそらくmark & sweep GCより実装難易度が上がるがチャレンジだ。とりあえず設計を考えて構造体から作る感じかなぁ。まあ頑張る。来週中に動いたらいいなぁ。