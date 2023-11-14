---
author: matac
pubDatetime: 2023-09-10T18:18:00.000Z
title: minigc読み
slug: minigc
featured: false
draft: false
tags:
  - tec
ogImage: ""
description: |
  「ガベージコレクションのアルゴリズムと実装」で紹介されていたminigcを読んでいる
  時間なくてまだ読み途中だがいくつかの記事に分けて書く
_template: blog_post
---

(追記)この記事あまりにも適当すぎるので書き直した。描き直したバージョンは[こっち](/posts/minigc1)。

ソースは[これ](https://github.com/matac42/minigc)。本家からフォークした。適当に読んで予想で解釈しているので間違いだらけだと思う。

## アロケーター部分

まずは構造体から見ていく。

### Header

flags

- FL_ALLOC, FL_MARKといったフラグを保持する

size

- データ部分のサイズ

header \*next_free

- 同ヒープ上の次のデータのヘッダのポインタ

header型のnext_freeによってヘッダーがシングルリンクになっていることがわかる

GC_Heap
\*slot

- ヘッダー？

size

- ヒープのサイズ

## flagsのマクロなど

#define FL_ALLOC 0x1

- アロケートされている

#define FL_MARK 0x2

- マークされている

#define FL_SET(x, f) (((Header \*)x)->flags |= f)

- フラグfをor演算でHeader型のxのflagsメンバに割り当てる
- つまりflagsにフラグを割り当てる

#define FL_UNSET(x, f) (((Header \*)x)->flags &= ~(f))

- flagsからフラグfを取り除く

#define FL_TEST(x, f) (((Header \*)x)->flags & f)

- フラグの確認をする

## その他のマクロなど

#define TINY_HEAP_SIZE 0x4000

- 小さい方のヒープのサイズ
- 16KB

#define PTRSIZE ((size_t)sizeof(void \*))

- ポインタのサイズ

#define HEADER_SIZE ((size_t)sizeof(Header))

- ヘッダのサイズ

#define HEAP_LIMIT 10000

- ヒープの最大サイズ

#define ALIGN(x, a) (((x) + (a - 1)) & ~(a - 1))

- アラインメントできる

#define NEXT_HEADER(x) ((Header \*)((size_t)(x + 1) + x->size))

- 次のヘッダ位置を求める
- ex. 101000 & 110000 = 111000

size_tとは

- コンパイラが32bitだろうが64bitだろうがいい感じでメモリのサイズを表すために必要なサイズを選んでくれる
- https://detail.chiebukuro.yahoo.co.jp/qa/question_detail/q10119811170

static Header \*free_list;

- フリーリスト
- 死んだオブジェクトの回収先

static GC_Heap gc_heaps[HEAP_LIMIT];

- ヒープのリスト

static size_t gc_heaps_used = 0;

- 使用されているヒープの数

アロケーター関数とでもしておこう
add_heap
mini_gc_malloc
mini_gc_free
gc処理が含まれている

ポインタの型はvoidなんだな

## add_heap

```
if (gc_heaps_used >= HEAP_LIMIT) {
  fputs("OutOfMemory Error", stderr);
  abort();
}
```

ヒープの数がリミットを超えたらエラー

```
if (req_size < TINY_HEAP_SIZE)
    req_size = TINY_HEAP_SIZE;
```

ヒープの最小サイズに合わせる

```
p = malloc(req_size + PTRSIZE + HEADER_SIZE);
  if (!p)
    return NULL;
```

ボディサイズ+ポインタサイズ+ヘッダサイズをアロケートする
PTRSIZEを足しているのはアラインメントした時に終端が溢れないようにするため。
ヒープ領域に対してもHeaderが付与されている。

```
align_p = gc_heaps[gc_heaps_used].slot = (Header *)ALIGN((size_t)p, PTRSIZE);
  req_size = gc_heaps[gc_heaps_used].size = req_size;
  align_p->size = req_size;
  align_p->next_free = align_p;
  gc_heaps_used++;
```

ヘッダを初期化している

`align_p = gc_heaps[gc_heaps_used].slot = (Header *)ALIGN((size_t)p, PTRSIZE);`
これは

`align_p->next_free = align_p;`なのでヘッダーのリンクリストの終端は終端自身を指していることがわかる。

## grow

growとは？

- ヒープを追加して拡張している

構造体のアドレス + 1をすると構造体の直後のアドレス、この場合はボディの部分が指される。

## mini_gc_malloc

```
if ((prevp = free_list) == NULL) {
    if (!(p = add_heap(TINY_HEAP_SIZE))) {
      return NULL;
    }
    prevp = free_list = p;
  }
```

free_listがNULLだったら作る？

```
else {
        /* too big */
        p->size -= (req_size + HEADER_SIZE);
        p = NEXT_HEADER(p);
        p->size = req_size;
```

sizeが大きすぎる場合、一個前のブロックまで戻ってそこで次のヘッダを探す。で、そこのヘッダのブロックのsizeをreq_sizeにしてあげることでjust fitさせる。

prevpは今から割り当てるブロックの前のブロックを表している。なのでprevp->next_freeが次に割り当てされるブロックのヘッダを指している。

```
free_list = prevp;
FL_SET(p, FL_ALLOC);
return (void *)(p + 1);
```

prevpをfree_listに入れているのはなんでだ？

malloc時にGCしていることがわかる
もっと詳しくいうとfree_listを辿り切った時(freeがなかった時)にGCする

```
if (p == free_list) {
      if (!do_gc) {
        garbage_collect();
        do_gc = 1;
      } else if ((p = grow(req_size)) == NULL)
        return NULL;
    }
```

free_listの扱いについてはmini_gc_freeを読むと理解できるはずだ。

## mini_gc_free

target, hit

- free_listに入れるデータとfree_listに入れる位置を示すhit

```
target = (Header *)ptr - 1;
```

\*ptrはデータの先頭部分を指している
-1することでデータのヘッダ部分を指すようにしている

```
for (hit = free_list; !(target > hit && target < hit->next_free); hit = hit->next_free)
```

free_listはソートされている
のでtargeを入れる場所をfree_listから探している
hitとhit->next_freeの間もしくは終端にtargetが入る

| hit | hit->next_free |

| hit | target | hit->next_free |
| hit | target |

```
if (hit >= hit->next_free && (target > hit || target < hit->next_free)
```

free_listは双方向循環リスト？
だからこの条件でリストの終端がわかる

そもそもなんでmergeしているかというとおそらくfragmentationを防ぐため。
