---
author: matac
pubDatetime: 2023-02-13T02:19:47.000Z
title: QLCドライブの寿命に関わってくるものはなにか
postSlug: life-of-a-qlc-drive
featured: false
draft: false
tags:
  - paper
ogImage: ""
description: |
  This is a note from my reading of the paper "Improving the Reliability of Next
  Generation SSDs using WOM-v Codes".
_template: blog_post
---

今日は[Improving the Reliability of Next Generation SSDs using WOM-v Codes](https://www.usenix.org/conference/fast22/presentation/jaffer "Improving the Reliability of Next Generation SSDs using WOM-v Codes")を読みます。QLC drives の寿命に関わる要素は何か、また QLC drives とはなにかの理解が目標です。

# メモ

QLC は High density SSD らしい。SSD の一種。なんか色々あるみたい。

- SLC (single level cells)
- MLC (multi level cells)
- TLC (triple level cells)

cell にいくつ bit を保持できるかということ。SSD は multi-bit とのこと。この流れで行くと QLC は quattro level? PLC というのもあるらしい。

P/E cycles とは？フラッシュに bit を書き込むまでの 1 連のプロセスのこと。調べると P/E サイクルを「フラッシュの書き換え回数」と言っているところもあるし、「1 回書き込むまでのプロセス」のことを言っているところもある。どっちが正解だろうか。lifecycle ともいうし...

論文では以下の様に説明されてるので、「フラッシュの書き換え可能回数」と読めば良さそう。

> limiting their endurance and hence usability

QLC drives の寿命に関わってくるもののうちに、P/E cycles があることがわかった。ということであれば、タイトルの WOM-v はその辺りを改善するものと予想する。予想も何も*Abstract*に書かれてるよ。

erase block とは。SSD はセル単位ではなくあるブロック単位でデータの消去を行う。そのブロックのことを erase block と言っている。erase block にまだ有効なデータが残っている場合はそれを別の場所に移動してから erase するといった処理をしている(重たそう？)。

WOM-v(Voltage-Based Write-Once-Memory)

データを複数世代持っておくことでデータの消去をせずにセルに書き込みを行うことができるような仕組み？

お昼〜
