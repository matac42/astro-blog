---
author: matac
pubDatetime: 2023-09-07T21:20:00.000Z
title: 「ガベージコレクションのアルゴリズムと実装」のPythonのGCを読んだ
postSlug: gc-python
featured: false
draft: false
tags:
  - tec
ogImage: ""
description: |
  ガベージコレクションのアルゴリズムと実装」の実装編のPythonのGCの章をを読んだ
_template: blog_post
---

以前[「ガベージコレクションのアルゴリズムと実装」のアルゴリズム部分を読んだ](/posts/gc-algo)にてアルゴリズム編を読んだ感想を書いたがその続きで次は実装編を読んだ感想である。といってもまだPythonのGCの章を読み終わっただけで続きはまだまだあるのだが平日少しずつ読んでいるというのもありちょっと読むのに時間がかかっているので忘れないように一旦軽くまとめておく。まあ日記みたいな感じだ。

## 結構古い

今現在Pythonの最新バージョンは3.11.5だが、この本で対象となっていたPythonのバージョンは3.0.1だった。もう13年前の本なので仕方がないが現状と大きく離れている可能性を頭の隅に置いておきながら読む必要があるだろう。

## ライトバリアが何なのかわかった

アルゴリズム編の時点ではよくわからなかった「ライトバリア」だがPython編の最後の方にちゃっかり説明が書かれていてそれで理解できてしまった。

> ライトバリアとは旧世代から新しい世代への参照を記録するための機構です。

なのでライトバリアが出てくるのは世代別GCの時であり、記憶集合がライトバリアの役割を果たしていることが理解できた。ちなみにPythonではライトバリアは登場しないようだ。

## 実装時のデメリット

Pythonは参照カウントをGCで用いていて実装の際には参照の所有権を意識しながらコーディングする必要がありそれは結構難しいことでバグを埋め込む原因になりやすいことがわかった。これはGCのアルゴリズム自体のデメリットではないが実装する上でのデメリットであり、よってアルゴリズムを選択する際はアルゴリズム自体とそれを実装する際のメリットデメリットを考える必要があることがわかった。

ちょっと話はそれるが「参照の所有権」という言葉をきいてやっぱりRustもやりたいなという気持ちになってきた。本の中で

> ちなみにオブジェクトには所有権という概念はありません。

と述べられていた。Rustの所有権はこの参照の所有権とはどう違うのか。10年以上前の話なので今はオブジェクトに所有権という概念があるかも知れない？やっぱりRust勉強したいし古いものだけ勉強するのは良くないと感じる。

## 細かい知見

テクニックとして覚えておくととても役立ちそうだと思ったことが2つあった。1つ目は「アラインメントとアドレスマスクによる先頭アドレスの取得」だ。この本ではプールを配置する時に出てきた手法だが一般的にも役立つやり方だと思った。2つ目は`gc.set_debug(gc.DEBUG_STATS)`だ。これをPythonプログラム内で呼び出すことでGCに関する情報が出力されるのでこれを元にパフォーマンスチューニングすることができる。まあこれ自体も役立つ知見なのだがどちらかというと言語にこういうフラグを立ててデバッグ情報を出力させる機能があることを知れたのが大きい。これはPythonでなくても使える知見なのではないだろうか。あまり特定の言語について詳しいとかがないのだが、こういうテクニックがあるのを知ると何かしらの言語について深く学んでおきたいなと感じる。

## 本があって助かる

この本の解説が無い状態でいきなりソースコードを読みに行くのはとても大変だろうと思う。この本があったおかげでたった2日でPythonのGCの全体像が何となくでもわかるようになったのだ。私がブログを書いているのはいつか書籍を出してみたいからというのが理由として挙げられるがこの本みたいな知の高速道路になる本を書けたらいいなぁと思った。
