---
author: matac
pubDatetime: 2023-09-23T18:58:00.000Z
title: minicpgc ヒープ領域の確保
postSlug: minicpgc
featured: false
draft: false
tags:
  - tec
  - minicpgc
ogImage: ""
description: |
  なかなか書き始めていなかったminicpgcだが手始めにヒープ部分を書いた。
_template: blog_post
---

ソースコードはここ

- https://github.com/matac42/minicpgc

今週初め頃にminigcを書き始めるとはいっていたものの、今日まで全く手をつけていなかった。minigcのCopying GCバージョンであるminicpgcを書いていくのだがとりあえずヒープ領域を用意するところを書いた。

Copying GCはFrom領域とTo領域の2つのヒープ領域がある。ブロックをアロケートする際はFromに書き込む。GCはFrom領域からTo領域へブロックをコピーすることで行う。ルートから参照されていないブロックはコピーされないのでTo領域には参照されているブロックのみが残るという感じだ。

たくさんコピーをするので明らかに非効率的な部分があるのだがとりあえず動くは正義なので動くところまで書きたい。

今日は`heap_init`関数を追加した。ヒープ領域を準備する関数だ。ヒープ領域から作っているのは舞台がないとmalloc, free, gcを書こうにもなんだか難しいなと思ったからだ。ちゃんと設計をやればどこから書いても問題はないのだろうがまともに設計していないのでとりあえずヒープからという感じ。

```
void heap_init(size_t req_size) {
  void *p1, *p2;

  if (req_size < TINY_HEAP_SIZE)
    req_size = TINY_HEAP_SIZE;

  p1 = malloc(req_size + PTRSIZE + HEADER_SIZE);

  from_start = (Heap_Header *)ALIGN((size_t)p1, PTRSIZE);
  from_start->size = req_size;

  p2 = malloc(req_size + PTRSIZE + HEADER_SIZE);

  to_start = (Heap_Header *)ALIGN((size_t)p2, PTRSIZE);
  to_start->size = req_size;
}
```

やっていることはとても単純で`req_size`分のFromとToの領域をmallocしている。実際にはヒープ領域は`Heap_Header`をヘッダとして持っており、`ALIGN`を行うためmallocするサイズは`req_size + PTRSIZE + HEADER_SIZE`としている。

`from_start`と`to_start`で同じコードを2回繰り返していて冗長だが、今のところ2回しか使わないのでこれでいいということにしている。

`ALIGN`は以下のように定義され、`PTRSIZE`でアドレスをアラインメントしている。アラインメントをすると最大で`PTRSIZE - 1`だけヒープ領域のアドレスがずれる。なのでmallocする際に`PTRSIZE`を足してあげて、mallocした領域からヒープ領域がはみ出さないようにしている。

```
#define ALIGN(x, a) (((x) + (a - 1)) & ~(a - 1))
```

あとはDoxygenでドキュメンテーションコメントからHTMLのドキュメントを生成する設定を加えた。しっかりコメントを書いていこうという意思をとりあえず示している。

ヒープ領域は確保できたので次はmallocとfreeを実装していきたい。というかできれば明日中にgc部分まで書き進めたい。
