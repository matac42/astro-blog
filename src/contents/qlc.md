---
author: matac
datetime: 2023-02-13T11:19:47+09:00
title: QLCドライブの寿命に関わってくるものはなにか
slug: life-of-a-qlc-drive
featured: false
draft: false
tags:
- paper
ogImage: ''
description: This is a note from my reading of the paper "Improving the Reliability
  of Next Generation SSDs using WOM-v Codes".

---
今日は[Improving the Reliability of Next Generation SSDs using WOM-v Codes](https://www.usenix.org/conference/fast22/presentation/jaffer "Improving the Reliability of Next Generation SSDs using WOM-v Codes")を読みます。QLC drivesの寿命に関わる要素は何か、またQLC drivesとはなにかの理解が目標です。

# メモ

QLCはHigh density SSDらしい。SSDの一種。なんか色々あるみたい。

* SLC (single level cells)
* MLC (multi level cells)
* TLC (triple level cells)

cellにいくつbitを保持できるかということ。SSDはmulti-bitとのこと。この流れで行くとQLCはquattro level? PLCというのもあるらしい。

P/E cyclesとは？フラッシュにbitを書き込むまでの1連のプロセスのこと。調べるとP/Eサイクルを「フラッシュの書き換え回数」と言っているところもあるし、「1回書き込むまでのプロセス」のことを言っているところもある。どっちが正解だろうか。lifecycleともいうし...

論文では以下の様に説明されてるので、「フラッシュの書き換え可能回数」と読めば良さそう。

> limiting their endurance and hence usability

QLC drivesの寿命に関わってくるもののうちに、P/E cyclesがあることがわかった。ということであれば、タイトルのWOM-vはその辺りを改善するものと予想する。予想も何も_Abstract_に書かれてるよ。

erase blockとは。SSDはセル単位ではなくあるブロック単位でデータの消去を行う。そのブロックのことをerase blockと言っている。erase blockにまだ有効なデータが残っている場合はそれを別の場所に移動してからeraseするといった処理をしている(重たそう？)。

WOM-v(Voltage-Based Write-Once-Memory)

データを複数世代持っておくことでデータの消去をせずにセルに書き込みを行うことができるような仕組み？

お昼〜