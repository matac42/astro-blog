---
author: matac
pubDatetime: 2023-09-25T23:20:00.000Z
title: minicpgc copying
postSlug: minicpgc3
featured: false
draft: false
tags:
  - tec
  - minicpgc
ogImage: ""
description: |
  昨日はヒープにブロックを配置するところまで書いた。今日はCopying GCの部分を書いた。
_template: blog_post
---

ソースコードはここ

- https://github.com/matac42/minicpgc

今日は主にFrom領域からTo領域へブロックをコピーする`copying()`を書いた。

```c
void copying(void) {
  Block_Header *p;
  void *pfree = (void *)to_start + 1;

  for (p = (Block_Header *)from_start + 1; (size_t)p < (size_t)from_start->end;
       p = NEXT_HEADER(p)) {
    if (p->flags == FL_ALLOC) {
      copy(p, pfree);
    }
  }

  swap();
}
```

From領域のブロックを頭から全部見ていき、`FL_ALLOC`フラグが立っている、つまりアロケートされて使用されているブロックのみをTo領域へコピーしている。その際`pfree`がカーソルとなってTo領域にブロックを詰めて配置するいわゆるコンパクションが行われる。コピーする関数`copy()`は次の通り。

```c
Block_Header *copy(Block_Header *from_block, void *pfree) {
  Block_Header *to_block;

  to_block = memcpy(pfree, from_block, BLOCK_HEADER_SIZE + from_block->size);
  pfree = (void *)(pfree + BLOCK_HEADER_SIZE + from_block->size);

  return to_block;
}
```

コピーは`memcpy()`で行う。`pfree`の位置に`from_block`を配置する。配置後は`pfree`を配置したブロックのすぐ後ろに設定する。コピーした後はFrom領域とTo領域を入れ替える必要がある。それは`swap()`で行う。

```c
void swap() {
  Heap_Header *tmp;

  tmp = from_start;
  from_start = to_start;
  to_start = tmp;

  free_list = NULL;
}
```

`swap()`は単純に`from_start`と`to_start`を入れ替えているだけである。

ここまでみるととても単純な仕組みになっていることがわかるが、機能が全然足りていない。というかGCとしては機能していない。
現状はfreeされたブロックを無視してTo領域にブロックをコピーすることでコンパクションは実現されているが、ルートからの参照の有無でオブジェクトをGCの対象とするか否かの処理が入っていない。なのでまずはルートを作る必要がある。Copying GCの場合は「保守的なGC」ではダメで「正確なGC」を行う必要がある。

保守的なGCに対して正確なGCとはポインタと非ポインタを完全に区別できるGCのことである。ちょっとまだ正確に理解はできてなくて実装しながら理解していくつもりだが、全てのブロックをある特定の型におさめる必要がありそうだ。具体的にはint型のブロックとかString型のブロックとかを実装していく感じになるか。いや間違っているかもしれない。どちらかといえば全てのオブジェクトへの参照を持ったマップを用意するのが正解か。もうちょっとお勉強する必要がありそうだ。

なので次にやることはルート、いわゆる全てのブロックへの参照を持っているオブジェクトを作り上げることだ。

他にも

- ヒープオーバーフローのチェック
- free_listからのアロケート
- テストが少なすぎるので増やす

などのやることがあるが、とりあえず正確なGCとして完成させたいところ。

実はこのminicpgcの取り組みはサブプロジェクトで本命は別にある。CbCでRedBlackTreeを用いた実装というやつなのだがそれに繋がるようにやっていきたい。
