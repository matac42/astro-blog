---
author: matac
pubDatetime: 2023-09-24T14:57:00.000Z
title: minicpgc mallocとfree
slug: minicpgc2
featured: false
draft: false
tags:
  - tec
  - minicpgc
ogImage: ""
description: |
  昨日書いたヒープ領域上にブロックを配置、解放するコードを書いた。
_template: blog_post
---

ソースコードはここ

- https://github.com/matac42/minicpgc

今日はmallocとfreeに当たる処理を書いた。

## mini_cpgc_malloc

```
void *mini_cpgc_malloc(size_t req_size) {
  Object_Header *p;

  req_size = ALIGN(req_size, PTRSIZE);
  if (req_size <= 0) {
    return NULL;
  }

  p = (Object_Header *)from_start->current;
  p->size = req_size;
  from_start->current = from_start->current + req_size;

  return (void *)(p + 1);
}
```

mallocするにあたってヒープ領域上で使用されている部分とそうでない部分の境界を表す`current`メンバを追加した。
なので動作としてはヒープの先頭から順番にアロケートしていく感じだ。ブロックに関してもALIGNしている。

## mini_cpgc_free

```
void mini_cpgc_free(void *ptr) {
  Object_Header *target, *hit;

  target = (Object_Header *)ptr - 1;

  if (free_list == NULL) {
    free_list = target;
    target->next_free = target;

    return;
  }

  /* search join point of target to free_list */
  for (hit = free_list; !(target > hit && target < hit->next_free);
       hit = hit->next_free)
    /* heap end? And hit(search)? */
    if (hit >= hit->next_free && (target > hit || target < hit->next_free))
      break;

  if (NEXT_HEADER(target) == hit->next_free) {
    /* merge */
    target->size += (hit->next_free->size + OBJECT_HEADER_SIZE);
    target->next_free = hit->next_free->next_free;
  } else {
    /* join next free block */
    target->next_free = hit->next_free;
  }
  if (NEXT_HEADER(hit) == target) {
    /* merge */
    hit->size += (target->size + OBJECT_HEADER_SIZE);
    hit->next_free = target->next_free;
  } else {
    /* join before free block */
    hit->next_free = target;
  }
  free_list = hit;
}
```

本家のminigcとほとんど同じである。
`free_list`に連結されたブロックは解放されたものとみなすやり方だ。
ただ今の所のコードだと`free_list`を初期化する部分がなかったので`free_list == NULL`だった場合はtargetをそのまま入れる処理を追加している。

まだまだ全然機能が足りてないような気がするが練習なのでとりあえず動くことが大事。
この記事を書いてる時に気づいたけど、ObjectとBlockが混同しているな。Blockに揃えるべき。
せっかく`free_list`を作っているのでmalloc時に活用できるようにしたい。

最低限の機能で進んでとりあえずGC部分まで辿り着きたい。
