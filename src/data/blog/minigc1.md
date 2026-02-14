---
author: matac
pubDatetime: 2023-09-11T18:00:00.000Z
title: minigc読み(アロケーションまとめ)
postSlug: minigc1
featured: false
draft: false
tags:
  - tec
ogImage: ""
description: |
  「ガベージコレクションのアルゴリズムと実装」で紹介されていたminigcを読んでいる
  時間なくてまだ読み途中だがいくつかの記事に分けて書く
  今回はアロケーション部分のまとめ
_template: blog_post
---

昨日[minigc読み](/posts/minigc)でアロケーション部分についてざっくりと書いたがざっくりすぎた。minigcのアロケーション部分の解説をもう一度試みる。ソースは本家からフォークして[ここ](https://github.com/matac42/minigc)を遊び場としている。

先に全体の構造から説明しておく

- ヒープ上にブロックがアロケートされる
- ブロックはヘッダ部分とデータ部分を持つ
- ヒープもヘッダを持つ
- 空きブロックを`free_list`に保持している

では、次に構造体を説明していく。

## 構造体

### Header

```c
typedef struct header {
  size_t flags;
  size_t size;
  struct header *next_free;
} Header;
```

flagsはFL_ALLOC, FL_MARKといったデータの状態を表すフラグを保持する。sizeはヘッダを除いたデータのサイズを保持する。Headerはnext_freeメンバで接続されたリンクリストとなっている。

ブロックは以下のような形でデータに対して`Header`がつく。

```md
+----------+-----------+
| Header | data |
+----------+-----------+
```

### GC_Heap

```c
typedef struct gc_heap {
  Header *slot;
  size_t size;
} GC_Heap;
```

slotはヘッダのリンクリストを保持する。sizeはヒープ領域のサイズを保持する。

## 関数

アロケーション部分は次の4つの関数から成る。それぞれを説明していく。

- add_heap
- grow
- mini_gc_malloc
- mini_gc_free

### add_heap

#### コード

```c
static Header *add_heap(size_t req_size) {
  void *p;
  Header *align_p;

  /* (1) */
  if (gc_heaps_used >= HEAP_LIMIT) {
    fputs("OutOfMemory Error", stderr);
    abort();
  }

  /* (2) */
  if (req_size < TINY_HEAP_SIZE)
    req_size = TINY_HEAP_SIZE;

  /* (3) */
  p = malloc(req_size + PTRSIZE + HEADER_SIZE);
  if (!p)
    return NULL;

  /* (4) */
  /* address alignment */
  align_p = gc_heaps[gc_heaps_used].slot = (Header *)ALIGN((size_t)p, PTRSIZE);
  req_size = gc_heaps[gc_heaps_used].size = req_size;
  align_p->size = req_size;
  align_p->next_free = align_p;
  gc_heaps_used++;

  return align_p;
}
```

#### 解説

ヒープとはプログラムが使用するメモリ領域のことだ。プログラムがデータをメモリに配置する、つまりブロックをアロケーションをするにはまずヒープ領域を確保する必要がある。`add_heap`はヒープの要求サイズ`heap_size`を受け取り、`Header`型構造体のポインタを返す関数である。

(1)でヒープの数が`HEAP_LIMIT`を超えていないか確認する。超えていた場合はエラーを出力する。(2)ではヒープの最小サイズを`TINY_HEAP_SIZE`としている。なのでこれより小さいヒープ領域は存在しないことになる。(3)では実際にヒープ領域をアロケートしている。`PTRSIZE`を足しているのはアラインメントした時に終端が溢れないようにするためだ。ちなみに`PTRSIZE`はポインタ型のサイズを表しており、32bitアーキテクチャなら4バイト、64bitアーキテクチャなら8バイトになる。また、ヒープ領域に対しても`Header`が付与されるため`HEADER_SIZE`を足している。なのでヒープ領域は以下のような形になる。

```md
+------------------------------+---------------------+--------------------------+
| Header(HEADER_SIZE) | heap(req_size) | padding(< PTRSIZE) |
+------------------------------+---------------------+--------------------------+
```

(4)ではヒープ領域自体のアラインメントとヒープのヘッダへのポインタを`gc_heaps`リストに追加し、ヒープヘッダの初期化をしている。

`ALIGN`マクロは以下のように定義される。例えば`x = 5, a = 4`でALIGNすると8となる。

```c
#define ALIGN(x, a) (((x) + (a - 1)) & ~(a - 1))
```

### grow

#### コード

```c
static Header *grow(size_t req_size) {
  Header *cp, *up;

  if (!(cp = add_heap(req_size)))
    return NULL;

  up = (Header *)cp;
  mini_gc_free((void *)(up + 1));
  return free_list;
}
```

#### 解説

`grow`は`add_heap`関数を用いて新しくヒープ領域を確保する関数だ。ヒープの要求サイズ`heap_size`を受け取り、`Header`型構造体のポインタを返す。`up`にはヒープ領域のヘッダーのポインタが入る。新しく確保したヒープ領域に対して`mini_gc_free`を行っているのは`free_list`の整合性を取るためだ。

### mini_gc_free

`grow`で`mini_gc_free`が出てきたので先に解説する。

#### コード

```c
void mini_gc_free(void *ptr) {
  Header *target, *hit;

  /* (1) */
  target = (Header *)ptr - 1;

  /* (2) */
  /* search join point of target to free_list */
  for (hit = free_list; !(target > hit && target < hit->next_free);
       hit = hit->next_free)
    /* heap end? And hit(search)? */
    if (hit >= hit->next_free && (target > hit || target < hit->next_free))
      break;

  /* (3) */
  if (NEXT_HEADER(target) == hit->next_free) {
    /* merge */
    target->size += (hit->next_free->size + HEADER_SIZE);
    target->next_free = hit->next_free->next_free;
  } else {
    /* join next free block */
    target->next_free = hit->next_free;
  }
  if (NEXT_HEADER(hit) == target) {
    /* merge */
    hit->size += (target->size + HEADER_SIZE);
    hit->next_free = target->next_free;
  } else {
    /* join before free block */
    hit->next_free = target;
  }
  free_list = hit;
  target->flags = 0;
}
```

#### 解説

mini_gc_freeはヒープ上のブロックを解放する。解放とはつまり`free_list`に追加するということだ。解放対象のブロックのポインタ`ptr`を受け取り`free_list`に解放領域を接続する。`target`は`free_list`に入れるデータ、`hit`は`target`を`free_list`に入れる位置を表す。

(1)では`ptr`のブロックの`Header`のポインタを`target`に入れている。(2)では`free_list`から`target`を入れる位置を探している。`free_list`はソートされているので`targe`を入れる場所を`free_list`から探している。最終的には`hit`と`hit->next_free`の間もしくは終端に`target`が入る。`free_list`の終端は終端自身を指しているので条件でリストの終端がわかる。(3)以降で`free_list`に`target`を入れている。入れ方としてmergeとjoinの2つ方法がある。`target`の直後や直前にフリーブロックがあれば`target`とそのフリーブロックをmergeする。無ければそのままjoinする。最後に`free_list`の更新と`target`のフラグの初期化をしている。

`NEXT_HEADER`マクロの定義は以下の通りで、ヘッダのサイズ(x + 1)とデータのサイズ(x->size)を足して次のヘッダのアドレスとして返している。

```c
#define NEXT_HEADER(x) ((Header *)((size_t)(x + 1) + x->size))
```

### mini_gc_malloc

#### コード

```c
void *mini_gc_malloc(size_t req_size) {
  Header *p, *prevp;
  size_t do_gc = 0;

  /* (1) */
  req_size = ALIGN(req_size, PTRSIZE);

  if (req_size <= 0) {
    return NULL;
  }

  /* (2) */
  if ((prevp = free_list) == NULL) {
    if (!(p = add_heap(TINY_HEAP_SIZE))) {
      return NULL;
    }
    prevp = free_list = p;
  }

  /* (3) */
  for (p = prevp->next_free;; prevp = p, p = p->next_free) {
    if (p->size >= req_size) {
      if (p->size == req_size)
        /* just fit */
        prevp->next_free = p->next_free;
      else {
        /* too big */
        p->size -= (req_size + HEADER_SIZE);
        p = NEXT_HEADER(p);
        p->size = req_size;
      }
      free_list = prevp;
      FL_SET(p, FL_ALLOC);
      return (void *)(p + 1);
    }
    if (p == free_list) {
      if (!do_gc) {
        garbage_collect();
        do_gc = 1;
      } else if ((p = grow(req_size)) == NULL)
        return NULL;
    }
  }
}
```

#### 解説

ヒープ領域にブロックをアロケートする。`mini_gc_malloc`はデータの要求サイズ`heap_size`を受け取り、データへのポインタを返す関数である。

(1)で`ALIGN`して`req_size`からアラインメント後の実際の`req_size`を求める。(2)では`prevp`がNULLだった場合にヒープ領域を作成して`prevp`にそのヘッダのポインタを入れている。その時同時に`free_list`も更新する。(3)`free_list`を走査して要求サイズ以上のフリーブロックを探し、要求サイズぴったしならそのまま割り当てる。大きすぎる場合はフリーブロックの後ろから必要な分(`req_size` + `HEADER_SIZE`)だけ切り取って割り当てる。その後`free_list`を更新しフラグをセットしデータへのポインタを返す。もし適切なサイズのブロックが見つからなかった場合は`garbage_collect`が実行される。minigcにおいてGCが実行されるのは`mini_gc_malloc`時にヒープ領域の空きが足りなかった場合と、この関数が直接呼び出された場合のみとなる。`if (p == free_list)`は`free_list`を一周したことを表している。

## これから

次から本命のGC部分を読んでいこうと思う。
