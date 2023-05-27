---
author: matac
datetime: 2023-05-27T15:00:00.000Z
title: トランザクションの評価手法TPC-Cの調査
slug: tpc-c
tags:
  - transaction
  - tpc
draft: true
description: TPC-Cがどういうものなのか理解したい
---

トランザクションを評価する方法を知りたくて論文などを読んでいると、
"TPC-C"という手法を用いている所をよく見かける。
今回は[TPC-C のドキュメント](https://www.tpc.org/TPC_Documents_Current_Versions/pdf/tpc-c_v5.11.0.pdf)を読んでみる。以下にメモを残す。

## メモ

### Clause 0

OLTP とは？

- Online Transaction Processing
- > OLTP とは、コンピュータシステムの処理方式の一種で、互いに関連する複数の処理を一体化して確実に実行するトランザクション処理を、端末などからの要求に基づいて即座に実行する方式。
  - https://e-words.jp/w/OLTP.html より
  - 銀行の入出金とか

business throughput とは？

transaction-per-minute-C(tpm-C)とは？

- 単位？
- 他にも price-per-tpmC とか watts-per-cpmC とかがある。
- ということは TPC-C はトランザクションの価格的側面とエネルギー的側面も計測することになりそう。

logical data structures とは？

- Array
- List
- Stack
- Queue
- etc...

benchmark special にならないように実装する

### Clause 1

### Clause 2

### Clause 3

### Clause 4

### Clause 5

### Clause 6

SUT とは
