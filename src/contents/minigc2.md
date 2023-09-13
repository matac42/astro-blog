---
author: matac
datetime: 2023-09-13T14:24:00.000Z
title: minigc読み(GCまとめ)
slug: minigc2
featured: false
draft: false
tags:
  - tec
ogImage: ""
description: >-
  「ガベージコレクションのアルゴリズムと実装」で紹介されていたminigcを読んでいる
  時間なくてまだ読み途中だがいくつかの記事に分けて書く
  今回はGC部分のまとめ
_template: blog_post
---

前回[minigc読み(アロケーションまとめ)](/posts/minigc1)にてアロケーション部分についてまとめた。今回はそれを踏まえて、GC部分をまとめる。

minigcのGCは`mini_gc_malloc`時に`garbage_collect`が呼ばれることで動作する。

```
void garbage_collect(void) {
  size_t i;

  /* marking machine context */
  gc_mark_register();
  gc_mark_stack();

  /* marking roots */
  for (i = 0; i < root_ranges_used; i++) {
    gc_mark_range(root_ranges[i].start, root_ranges[i].end);
  }

  /* sweeping */
  gc_sweep();
}
```
GCアルゴリズムはmark & sweep GCだ。マークするのはルートから参照できるオブジェクトだが、minigcの場合のルートは以下の通りである。

- レジスタ
- スタック
- root_ranges

`garbage_collect`は以下の関数を呼び出している。

- `gc_mark_register`
- `gc_mark_stack`
- `gc_mark_range`
- `gc_sweep`

`gc_mark_register`、`gc_mark_stack`
、`gc_mark_range`でブロックにマークする。これらの関数は最終的に`gc_mark`関数を呼び出している。

なのでまずは`gc_mark`とそれに関連する`gc_mark_range`を解説する。

### gc_mark

#### コード

```
static void gc_mark(void *ptr) {
  GC_Heap *gh;
  Header *hdr;

  /* (1) */
  /* mark check */
  if (!(gh = is_pointer_to_heap(ptr)))
    return;
  if (!(hdr = get_header(gh, ptr)))
    return;
  if (!FL_TEST(hdr, FL_ALLOC))
    return;
  if (FL_TEST(hdr, FL_MARK))
    return;

  /* (2) */
  /* marking */
  FL_SET(hdr, FL_MARK);
  DEBUG(printf("mark ptr : %p, header : %p\n", ptr, hdr));

  /* (3) */
  /* mark children */
  gc_mark_range((void *)(hdr + 1), (void *)NEXT_HEADER(hdr));
}
```

#### 解説

(1)ではマークする条件を確認している。条件は以下の通りだ。

- ヒープへのポインタがなければマークしない
- ヘッダがなければマークしない
- アロケートされたものでなければマークしない
- マークされていればマークしない

`is_pointer_to_heap`はポインタがヒープ内を指しているか確認している。ヒープ内を指していればそのヒープのアドレスを返す。`cache`にはヒープのアドレスが入る。おそらく次に`gc_mark`されるオブジェクトが同じヒープに存在する可能性が高いからだろう。

```
static GC_Heap *is_pointer_to_heap(void *ptr) {
  size_t i;

  if (hit_cache && ((void *)hit_cache->slot) <= ptr &&
      (size_t)ptr < (((size_t)hit_cache->slot) + hit_cache->size))
    return hit_cache;

  for (i = 0; i < gc_heaps_used; i++) {
    if ((((void *)gc_heaps[i].slot) <= ptr) &&
        ((size_t)ptr < (((size_t)gc_heaps[i].slot) + gc_heaps[i].size))) {
      hit_cache = &gc_heaps[i];
      return &gc_heaps[i];
    }
  }
  return NULL;
}
```

`get_header`関数はブロックのヘッダを`gh`ヒープ上から探して返している。

```
static Header *get_header(GC_Heap *gh, void *ptr) {
  Header *p, *pend, *pnext;

  pend = (Header *)(((size_t)gh->slot) + gh->size);
  for (p = gh->slot; p < pend; p = pnext) {
    pnext = NEXT_HEADER(p);
    if ((void *)(p + 1) <= ptr && ptr < (void *)pnext) {
      return p;
    }
  }
  return NULL;
}
```

(1)の条件をクリアしたブロックに対し(2)でマークする。(3)では`gc_mark_range`を呼び出し、子ブロックに対しても`gc_mark`を行う。`gc_mark_range`関数は以下のとおりだ。

```
static void gc_mark_range(void *start, void *end) {
  void *p;

  for (p = start; p < end; p++) {
    gc_mark(*(void **)p);
  }
}
```

ブロック内のアドレス全て(startからendまでの範囲)に対して`gc_mark`を実行することで子ブロックを探し出している。


次に`gc_mark_register`と`gc_mark_stack`を開設する。

### gc_mark_register

#### コード

```
static void gc_mark_register(void) {
  jmp_buf env;
  size_t i;

  setjmp(env);
  for (i = 0; i < sizeof(env); i++) {
    gc_mark(((void **)env)[i]);
  }
}
```

#### 解説

これも最終的に`gc_mark`を呼び出している。`setjmp`関数は呼び出し環境を保存する関数で呼び出し元に戻ってくるためにつかう。呼び出し環境に戻るためには`longjmp`関数を使うが、コードのどこにも`longjmp`が見当たらない。ではここでの`setjmp`がなんのために実行されているかというと、レジスタの値を取るためである。レジスタはGCにおけるルートなのでここから参照されるブロックをマークする必要があるのだ。

<!-- `(void **)env`というふうにポインタのポインタになっているのはレジスタを直接いじることができないからだろう。だとしたらポインタのポインタにいつヘッダーをつけているのだろうか。 -->

### gc_mark_stack

#### コード

```
static void gc_mark_stack(void) {
  set_stack_end();
  if (stack_start > stack_end) {
    gc_mark_range(stack_end, stack_start);
  } else {
    gc_mark_range(stack_start, stack_end);
  }
}
```

#### 解説

最初に`set_stack_end`している。

```
static void set_stack_end(void) {
  void *tmp;
  long dummy;

  /* referenced bdw-gc mark_rts.c */
  dummy = 42;

  stack_end = (void *)&dummy;
}
```

`stack_end`は`set_stack_end`でセットされるが`set_stack_start`は`gc_init`でセットされている。

```
void gc_init(void) {
  long dummy;

  /* referenced bdw-gc mark_rts.c */
  dummy = 42;

  /* check stack grow */
  stack_start = ((void *)&dummy);
}
```

bdw-gcを参考にしているらしい。この辺はまた別で調べようと思う。`gc_mark_stack`は最終的に`gc_mark_range`経由で`gc_mark`している。動きとしてはスタックのブロック自体とそこから参照されるブロックをマークしている。

ここまでがmark phaseの解説だ。次はsweep phaseの解説である。

### sweep

#### コード

```
static void gc_sweep(void) {
  size_t i;
  Header *p, *pend, *pnext;

  for (i = 0; i < gc_heaps_used; i++) {
    pend = (Header *)(((size_t)gc_heaps[i].slot) + gc_heaps[i].size);
    for (p = gc_heaps[i].slot; p < pend; p = NEXT_HEADER(p)) {
      if (FL_TEST(p, FL_ALLOC)) {
        if (FL_TEST(p, FL_MARK)) {
          DEBUG(printf("mark unset : %p\n", p));
          FL_UNSET(p, FL_MARK);
        } else {
          mini_gc_free(p + 1);
        }
      }
    }
  }
}
```

#### 解説

とても短いコードだ。`gc_heaps`から一個ずつヒープを取り出して処理している。取り出したヒープは`NEXT_HEADER`でヘッダをたどりながらブロックの`flags`をを確認している。アロケートされていてかつ、マークされているものはマークを外す。そうでないものは`mini_gc_free`する。`mini_gc_free`はデータの位置を引数に渡すのでp+1してヘッダ分ずらしている。

## これから

まだわからない部分もいくつかあるがとりあえずまとまったminigc読みは一旦終了する。間違った理解やあたらしい発見があればまた別の記事を書くと思う。次は自分のminigcを書いていく。このコードに追加するか最初から全部書くかはこれから考える。