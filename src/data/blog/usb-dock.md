---
author: matac
pubDatetime: 2023-09-05T17:54:00.000Z
title: USB Dockを買ってみた
postSlug: usb-dock
featured: false
draft: false
tags:
  - random
  - tec
ogImage: ""
description: |
  OWC Thunderbolt dockを買ってデスク環境の改善を図る
_template: blog_post
---

ついに念願のUSB Dockを買ったのでそれについて色々書こうと思う。私が家で作業をする時はまずMacBookにMagSafe、ディスプレイのHDMI、Ethernet、イヤホンを接続するのだがこれを毎回やるのがとてもとてもとても面倒くさい。この現状は私の理想とは遠く離れており以前よりどうにかしたいと考えていた。

![](/img/usb-dock/IMG_7132.jpg)

私の理想がどういうものかというと全て無線で完結することなのだが今それを実現するには難しい点がいくつかある。1つは電源である。iPhoneであれば一応Qiでワイヤレス充電が可能だがMacBookにおいてはそういうものは現状ないだろう。というかQiも所定の位置にiPhoneを置かなければならないので私の理想とは少し違う。もう1つはネットワーク接続だが安定性と速度の点でWiFiではなくEthernetケーブルで接続したい。別にWiFiでも200Mbpsほど出るので問題はないのだがここはロマンで1Gbps近く出る有線を使いたいのだ。ということで現状では全てを無線にすることはできない、もしくはしたくないのでそれに対応する何かが必要となる。

それに対応した何かとは何かを考えていたら以前YouTuberの瀬戸弘司さんがUSB Dockの話をしていたことを思い出した。この動画である。

<div class="iframe-aspect">
<iframe width="560" height="315" src="https://www.youtube.com/embed/hofDlGTjrlo?si=yFytA_L5sOalPr3h" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
</div>

Thunderboltケーブルを1本MacBookに挿すだけディスプレイ2枚とオーディオインターフェースが接続される環境を作ったという動画だがこれが自分の環境にも合うのではないかと思った。ということで瀬戸さんが動画で取り上げたものと同じ「[OWC Thunderbolt Dock](https://amzn.asia/d/dhpRcs6)」を買って使ってみた。Dock本体のスペックなどの話は瀬戸さんの動画をみる方がわかりやすいので省き気味でお送りする。

## 外装と内容物

箱はこんな感じ。ちょっと角が潰れているような気もするが気にしない。動けばよし。

![](/img/usb-dock/IMG_7128.jpg)

緩衝材とか取り除いて内容物を並べるとこんな感じ。本体とThunderbolt4のケーブルと電源ケーブルが入っている。本体より電源ケーブルの方が体積大きそう。写真に入ってないがマニュアルなどがあるサイトに飛ぶQRコードが印刷されたカードも入っていた。

![](/img/usb-dock/IMG_7130.jpg)

## 電源を繋いでみる

早速使ってみようということで電源を繋いだらロゴが光った！電源供給されている状態では白く光るがMacBookと繋いで認識されると青く光る。ちゃんと繋がってることがわかるのは良いかもしれない。本体は反射する素材で指紋がたくさんつきそうなのが気になるがそんなに触るものでもないのでいいだろう。

![](/img/usb-dock/IMG_7131.jpg)

## ドライバー的なソフトウェアをインストール

[OWC Dock Ejector](https://software.owc.com/support/faq/dock-ejector-install-apple-silicon/)を入れておく必要がある。基本的にはマニュアル通りにやれば大丈夫だが1点つまづいた部分があったので紹介しておく。

上記ソフトウェアをインストール後、Thunderbolt4ケーブルをMacBookに接続すれば認識されるはずなのだが私の環境では認識されなかった。原因はよくわかっていないが同じ症状に悩まされている人たちはいたらしく[AppleのCommunityページ](https://discussions.apple.com/thread/254415650?answerId=258274818022#258274818022)にて解決策は見つかった。

解決方法は以下の通りである。

1. power down the dock and connected devices.
2. shut down the M1 MacBook Air with the Thunderbolt cable disconnected.
3. plug in the thunderbolt cable.
4. power up macbook air
5. power up dock and attached devices.

MacBookとUSB Dockの電源を落とした状態でThunderboltケーブルを接続し、MacBookを起動後USB Dockを起動する。この解決方法を突き止めてくれたApple Communityの737SNAPilotさんありがとう。どうやらMacOS Ventura以降で発生する現象らしいのでファームウェアアップデートとかすると治るかもしれない。一応もう一度再起動後普通にThunderboltケーブルを接続してみたが問題なく認識されたのでこれは最初の1回だけやれば良いようだ。

## MacBookと接続してみる

接続するとロゴが青く光りOWC Dock Ejectorからも認識される。
充電が始まるまでに3s、ディスプレイが表示されるまでに7sほどかかるが実用上問題はないだろう。

![](/img/usb-dock/IMG_7133.jpg)

## 最終的にこうなった

机のさらに奥の方にちょっとしたスペースがあって色々置いているのだが元々あったMiniPCとIX2207にはちょっと横によってもらって空いたところにDockを置いてMacBookと接続する感じで配置した。Dock自体にはディスプレイと接続するHDMIケーブル、Ethernetケーブルを接続している。イヤホンは繋いでいない。若干距離が遠いからそうなってしまっているのでもっと近い位置にDockを置きたかったが机の面積が足りないし他に置く場所もない。しかもイヤホンは持ち歩きのために毎回取り外しているのでDockに繋ごうがMacBookに繋ごうが関係なかった。固定のヘッドフォンなどがあるとこのイヤホンジャックポートが役に立つだろう。

![](/img/usb-dock/IMG_7135.jpg)

## 動作はどんなかんじか

ディスプレイは遅延などは特に気にならなかった。そもそも遅延にシビアなゲームなどはこの環境ではしないのであんまり気にならないというのもあるが以前と同様に使えている感じだ。通信速度も計測してみたところ特にボトルネックになっている様子もなかった。1個面倒だと感じたのはThunderboltケーブルをMacBookから引き抜く時で、USBメモリなどが刺さった状態の時はeject操作をする必要がある。しかしこれはMacBookに直接USBメモリをさした場合も同様なのでこれが嫌ならWindowsを使えということになるか。

![](/img/usb-dock/eject.png)

あとはこういった集線装置でよく問題になる発熱だがこれに関してはちょっとぬくいくらいで問題にはならないレベルだと思った。

## 改善点

このDockに関しては概ね満足である。まあ結構な値段したのでこれで満足できなかったらとても悲しい。実はポート数的に結構オーバースペックで、Thunderbolt4は2ポート、USB3.2が3ポート空いている状態だ。まあ将来的にディスプレイやらなんやらを追加する予定だし余裕があることは良いことだろう。

前から足りないと思っていたがそろそろ机周りのスペースが本格的に足りなくなってきたので大きな机を導入したい。ディスプレイは2枚は欲しいがこのままではディスプレイを追加することができない。できれば自動昇降のやつにしてBeatmaniaのプレイも快適にできるようにしたい。さらにイヤホンをワイヤレスにするとより手間が省けるだろう。

金が欲しい。
