---
title: "Wireshark"
pubDatetime: 2022-04-22T11:29:06+09:00
postSlug: wireshark
draft: false
tags:
  - infra
categories: [tec]
description: ""
---

# Wireshark使ってみた

便利そうなUser's Guideがある。これをもとにインストールなどした。

https://www.wireshark.org/docs/wsug_html_chunked/

とりあえず起動すると、画面にキャプチャしたパケットの情報ぽいものがたくさん流れた。
多すぎるので、フィルタリングする必要がある。
フィルタリングは、[ここ](https://wiki.wireshark.org/DisplayFilters)を見れば大体できそう。
一番使いそうな、destinationとsourceのアドレス指定は、以下のような記述をfilterの入力欄に入力する。

```md
ip.src==192.168.0.0/16 and ip.dst==192.168.0.0/16
```

# パケットキャプチャの仕組み

パケットキャプチャしてパケットの内容を見ることができるWiresharkだが、そもそもどのようにパケットキャプチャしているのか知っておかないと、調査等に使うことができない。

少し調べると、WiresharkはUIを提供している感じで、実際にはlibpcapなどのパケットキャプチャドライバを用いているようだ。また、パケットキャプチャドライバはNICのプロミスキャストモードを用いている。プロミスキャプチャモードは自分のMACアドレス宛以外のパケットも読み取ることができるモードである。

自分が今ネットワークに接続しているNICに流れてくるパケットをキャプチャしているということだ。
正確には、Wireshark起動後に選択したNICのパケットをキャプチャする。やろうと思えばBluetoothのパケットキャプチャなどもできるらしい。

## libpcap

C/C++のライブラリ

https://www.tcpdump.org/

https://github.com/the-tcpdump-group/libpcap
