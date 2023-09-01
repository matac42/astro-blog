---
author: matac
datetime: 2023-08-31T22:23:00.000Z
title: Block-free concurrent GCとは何か
slug: block-free-cgc
featured: false
draft: false
tags:
  - tec
  - paper
ogImage: ""
description: >-
  論文を読みながらBlock-free concurrent GCを理解する。
_template: blog_post
---

久しぶりに論文読みのブログだ。しばらくはメモリの管理、とくにガベージコレクションについて調査する。詳細は述べないが研究室では信頼性の観点から Copying GC を使うのが良いのではないかというアタリをつけているので GC の中でも Copying GC に絞って調査したいところ。ノリに乗って実装までサッとできたら嬉しい感じだがとりあえず読む。論文読みばかりだとバランスが悪いのでコードリーディングとライティングもやっていきたいなぁ。

これからは論文を読むにあたって論文読みを支援する AI を有効活用していこうと思う。今回読む論文を見つけるにあたって使用したのは[scispace](https://typeset.io)である。これに関してはしばらく使ってみてからまた別でブログにしようと思う。

今回は「[Block-free concurrent GC: stack scanning and copying](http://welf.se/files/OL16.pdf)」を読んでみようと思う。一応目標は Block-free concurrent GC とは何か、どのような問題を解決しているのか理解することとする。以前と同様ここにメモを書きながら理解していく。ただのメモなので文章の流れは無く、自分が後で振り返ることを目的としているので読める物ではない。

## on-the-fly GC とは

ChatGPT によると

> "On-the-fly Garbage Collection"（オンザフライガベージコレクション、略して OTF GC）は、プログラムの実行を中断することなくガベージコレクション（不要なメモリの解放）を行う手法です。通常のガベージコレクションでは、メモリ解放のためにプログラムの実行を一時的に停止（ストップ・ザ・ワールド）することが多いですが、オンザフライガベージコレクションではそのような中断を極力避けます。
> この手法はリアルタイムシステムや、高可用性を必要とするシステムで有用です。ストップ・ザ・ワールド型のガベージコレクションでは、コレクションが行われる間はアプリケーションが応答しなくなる可能性があるため、オンザフライガベージコレクションが用いられる場合があります。

要するに application thread(mutator?)と並行して GC することか。ストップ・ザ・ワールドは厨二病感すごいな。

話はそれるかもしれないが Golang の GC は 1.4 までは単純な STW GC だったが 1.5 から Concurrent Mark & Sweep が導入されたらしい。この記事結構参考にできそうだな。次読むのはこれかもしれない。

- [Golang の GC を追う](https://deeeet.com/writing/2016/05/08/gogc-2016/)

## blocking handshakes とは

この論文では blocking handshakes を置き換える non-blocking handshakes を提案しているがそもそも GC における blocking handshakes とは何か。通信プロトコルにおいては例えば暗号鍵の交換や認証が終わるまでデータの送受信をブロックすることを指すが GC においてはどのような意味を持つのだろうか。

ChatGPT によると

> リソースのロック: 複数のスレッドが同じリソース（例えば、メモリ、ファイル、ネットワークソケットなど）にアクセスする際には、同期を取る必要があります。この場合、一つのスレッドがリソースをロック（ブロック）し、他のスレッドがそのリソースの使用が終わるのを待つことがあります。

> 条件変数: スレッドが特定の条件を満たすまで実行を停止する必要がある場合、そのスレッドは条件変数によってブロックされることがあります。

> セマフォやミューテックス: これらの同期プリミティブを使用する際も、一つ以上のスレッドが他のスレッドの動作を待つ（ブロックする）ことがあります。

> スレッド間通信: スレッドがメッセージを交換する場合、送信側または受信側が他方の操作を待つ必要があります。このときにブロッキング・ハンドシェイクのような同期手法が使用される場合があります。

> スレッドの生成と終了: スレッドが生成されるときや終了するときに、親スレッドと子スレッドの間で同期を取る必要がある場合もあります。

大雑把に理解するとシステムの状態が特定の条件になるまでスレッドを待ち状態にすることか。non-blocking handshakes はこれらのブロッキングが必要なくなる手法ということか。まあ読み進めればその辺りも分かりそうだな。

## Copying Algolithm とは

確かに GC する際、特にフラグメンテーションの解消をする際はコピー操作が発生するのでその時にどのようにコピーするかを示していると予想する。この論文では FieldPinningProtocol(FPP)と Deferred Field Pinning (DFP)が登場する。全然なんでもない話だけど Algorithm と Protocol ってなんか似てるな。

## stack scanning とは

スキャンというだけで重そうな処理だなと思ってしまうが実際はどうなんだろう。ヒープ領域への参照がスタック上にあるか、つまりプログラムがそのメモリ領域を参照しているかを確認するために行う。GC はこの結果を元にあるメモリ領域を解放できるか否か判断する。

## block-freedom とは

論文より

> DEFINITION 1. An operation is block-free iff any of its active oper- ation instances will progress if it remains active for a finite number of system-wide steps taken by the active processors, independently of inactive operation instances. This holds even if any active oper- ation instance can become inactive at any point.

らしい。よくわかんないけど OS が動いてる間操作を実行継続できればその操作は block-free ということらしい。non-preemptive lock がカーネルの処理で発生する操作は block-free ではないらしい。まだ理解できてない。

## Block-Free Handshakes とは

動作は以下のようにする

1. requesting a hand- shake to responder threads
2. getting their execution states, i.e., their register contents and references to the top stack frames
3. replying using these execution states

responder って何。ChatGPT によると

> 何らかの入力や刺激に対して反応を返すもの

らしい。

## VM とは

この論文の文脈では Virtual Memory と思われる。途中まで Virtual Machine だと思って読んでたからわけがわからなかった。ちくしょーーー(cv. 小梅大夫)

## Handshakes とは

ChatGPT によると

> ハンドシェイクの種類
>
> Stop-The-World（STW）: すべてのアプリケーションスレッドが停止する。これが最も単純だが、最もコストの高いハンドシェイクの一つです。
>
> Incremental GC: ガベージコレクションが逐次的に行われ、アプリケーションスレッドと頻繁に短いハンドシェイクを行います。これは、レイテンシを低減する一方で、GC の複雑性が高まる場合があります。
>
> Concurrent GC: ガベージコレクションがアプリケーションスレッドと並行して行われる。この場合でも、一部の段階で短いハンドシェイクが必要な場合があります。
>
> On-The-Fly GC: アプリケーションスレッドが特定の段階で短いハンドシェイクを行いながら、ガベージコレクタと並行して実行されます。

アプリケーションスレッドと GC が協調・同期するための仕組みのことを指すようだ。

## yieldpoints とは

スレッドが CPU の制御を OS に返すポイントのこと。プログラムでは return とかがそのポイントになるらしい。それはコンパイラが決める。CbC の場合は CodeGear が DataGear を output したところが yieldpoints になるだろうか。

## スレッドの状態を示すもの達

スレッドの状態というものが定義されているらしく`schedctl`とか`thread_get_info`とかで取得できるらしい。active, inactive が取得できるようだが実際のところはコードを読めばわかるだろう。論文では`active (OS state) and managed (VM state)`といった状態が登場するのでこれを理解しておきたい。

## XNU kernel とは

XNU kernel に新しく独自のスレッド状態を取得できる system call を追加するとのことだがそもそも XNU kernel はなんだ。まあ他の kernel でもその system call は追加可能とのことだからどの kernel でも良いんだろうけど。調べてみたら Apple が開発した OS kernel らしい。

X is Not UNIX で XNU

ソースが公開されている

- https://github.com/apple/darwin-xnu

現行の MacOS でも動作しているんだろうか。

## block-free copying of objects and stack scanning

この論文の最も重要な部分、つまり提案手法は

- block-free copying
- stack scanning

だ。

Field Pinning Protocol(FPP)からアイデアを得ている。これはオブジェクトに 3 つの状態を持たせて管理する手法である。大雑把に初期状態が copy-white、コピー中の物が copy-gray、コピー完了が copy-black という感じ。これに関しても non-blocking copy であるが提案手法との違いはなんだろうか。完全に理解は難しいが`mprotect`を使用すると block-free の要件を破ってしまうのでそれを使用している FPP は block-free でないということらしい。

scispace copilot より

> スタックスキャンでブロックフリーハンドシェイクを使用すると、スレッドの実行がスケジュールされていなくても、ガベージコレクターはスレッドのプライベート状態 (レジスターや実行スタックなど) にアクセスできます。

スケジュールされていない非アクティブなスレッドは GC の処理を妨げる可能性があるということか。
非アクティブだとそもそも GC のチェックポイントに到達しない場合があってその時処理を妨げるようだ。提案手法ではスケジューリングされていなくてもプライベート状態にアクセスできるためそういう意味で non-blocking な進行が可能である。

## まとめ

まだ理解できてない。block-free がそもそもまだわかってないのでその概念を理解するためにもう少し調査したい。一応今の所は「スケジュラーに依存せずに GC を進行できるようになる」つまり block-free な handshakes 手法であるという理解だ。肝心なところがまだわかってないのでもう一回読んでもいいかも。そういえばこれは Copying GC についての論文ではなくて GC における Copy の手法についての論文だったな。まあいいか。
