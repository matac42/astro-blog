---
title: "Journaling Filesystem"
datetime: 2022-04-18T14:41:26+09:00
draft: false
tags: 
  - filesystem
categories: [tec]
---

# journaling filesystem

[Linux System Administrators Guide](https://tldp.org/LDP/sag/html/index.html)5.10.3 Which filesystem should be used?にて、

> Currently, ext3 is the most popular filesystem, because it is a journaled filesystem. 

という記述がある。今であればext4を選ぶだろう。この本は2000年ごろに原著が出たので、その頃の話ではあるが、journaled filesystemであることはファイルシステムを選ぶ上で重要な項目のようだ。確かに、NTFS、APFS、Ext4などの現在主に使われているファイルシステムはjournalingしている。よって、もはや当たり前の機能だと思われる。

# APFSのジャーナリング　いいえ

ジャーナリングしていないのか？
![](/img/journaling.png)

ジャーナリングに準ずるファイル保護機能が標準で搭載されている。よって、ジャーナリングとは違うものであるので、「ジャーナリング　いいえ」になっている。

https://discussions.apple.com/thread/251656537