---
author: matac
datetime: 2023-02-02T07:45:31+09:00
title: What is Double-Logging problem on RDBs with LSM-tree
slug: ''
featured: false
draft: false
tags: []
ogImage: ''
description: This is a note from my reading of the paper "Removing Double-Logging
  with Passive Data Persistence in LSM-tree based Relational Databases".

---
Double-Logging problemとは何かを論文を読みながら理解していきたいと思います。読む論文は[Removing Double-Logging with Passive Data Persistence in LSM-tree based Relational Databases](https://www.usenix.org/conference/fast22/presentation/huang "Removing Double-Logging with Passive Data Persistence in LSM-tree based Relational Databases")です。メモ感覚でやります。

# メモ

PASVという手法でLSM-Tree baseのRDBsにおけるdouble-logging problemに対処するらしい。

LSM-Tree base RDBsはクエリの処理やトランザクションなどの複雑な処理を行うRDB層と実際にデータの保存などを行うストレージエンジン層の2つに分けられる。しかしそこには重複した処理が存在し、Double-Logging problemもそのような処理に当たるということだろうか。

RDB systemはbinlogの機能を持っている。システムがクラッシュした時にbinlogをたどって処理を行うことでデータの回復をする。

LSM-treeはWrite-ahead Logの機能を持っている。これも処理のログを残したものである。

つまり、LSM-Tree base RDBsはbinlogとWALの二つのログを持っていて、どちらも同じようにシステムがクラッシュした時に回復するために存在する。同様のlogを二つ持ってしまっていて、システムパフォーマンスのオーバーヘッドとなっている。これがdouble-logging problemだ。

double-logging problemとは違うが、log-on-log problemというのがあるらしい。log-on-logは同じ構造上にlogが別々のものに書き込まれるというもの。double-loggingは全く別の構造上に関連性なく2つのログが存在するというもの。大雑把に考えるとdouble-loggingは単一のログと比べ、2倍くらいストレージを食ってしまうのではないだろうか。

そうしたら、どちらかのログを取り除けばいいのではないかと単純に考えるけど違うのかな。

大体TPC-Cで性能評価するよね。

単純にWALを取り除くとSQLとKVの操作に協調性がなくなるらしい。

とりあえずDouble-Logging problemがどんなものかわかったので目標達成。