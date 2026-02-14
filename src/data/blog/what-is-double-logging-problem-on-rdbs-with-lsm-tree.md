---
author: matac
pubDatetime: 2023-02-01T22:45:31.000Z
title: What is Double-Logging problem on RDBs with LSM-tree
postSlug: "what-is-double-logging-problem-on-rdbs-with-lsm-tree"
featured: false
draft: false
tags:
  - paper
ogImage: ""
description: |
  This is a note from my reading of the paper "Removing Double-Logging with
  Passive Data Persistence in LSM-tree based Relational Databases".
_template: blog_post
---

Double-Logging problem とは何かを論文を読みながら理解していきたいと思います。読む論文は[Removing Double-Logging with Passive Data Persistence in LSM-tree based Relational Databases](https://www.usenix.org/conference/fast22/presentation/huang "Removing Double-Logging with Passive Data Persistence in LSM-tree based Relational Databases")です。メモ感覚でやります。

# メモ

PASV という手法で LSM-Tree base の RDBs における double-logging problem に対処するらしい。

LSM-Tree base RDBs はクエリの処理やトランザクションなどの複雑な処理を行う RDB 層と実際にデータの保存などを行うストレージエンジン層の 2 つに分けられる。しかしそこには重複した処理が存在し、Double-Logging problem もそのような処理に当たるということだろうか。

RDB system は binlog の機能を持っている。システムがクラッシュした時に binlog をたどって処理を行うことでデータの回復をする。

LSM-tree は Write-ahead Log の機能を持っている。これも処理のログを残したものである。

つまり、LSM-Tree base RDBs は binlog と WAL の二つのログを持っていて、どちらも同じようにシステムがクラッシュした時に回復するために存在する。同様の log を二つ持ってしまっていて、システムパフォーマンスのオーバーヘッドとなっている。これが double-logging problem だ。

double-logging problem とは違うが、log-on-log problem というのがあるらしい。log-on-log は同じ構造上に log が別々のものに書き込まれるというもの。double-logging は全く別の構造上に関連性なく 2 つのログが存在するというもの。大雑把に考えると double-logging は単一のログと比べ、2 倍くらいストレージを食ってしまうのではないだろうか。

そうしたら、どちらかのログを取り除けばいいのではないかと単純に考えるけど違うのかな。

大体 TPC-C で性能評価するよね。

単純に WAL を取り除くと SQL と KV の操作に協調性がなくなるらしい。

とりあえず Double-Logging problem がどんなものかわかったので目標達成。
