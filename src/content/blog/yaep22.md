---
author: matac
pubDatetime: 2023-10-14T18:13:00.000Z
title: Yet Another Erlang Problems 22
slug: yaep22
featured: false
draft: false
tags:
  - tec
  - erlang
ogImage: ""
description: |
  Yet Another Erlang Problems 22 マージソート
_template: blog_post
---

最近はErlangのリハビリをしている。おとといはハノイの塔のプログラムを見たが、
今日はYet Another Erlang Problemsの問題を前回解き終えた33問目まで復習した。

ハノイの塔の時にも言ったが最近はアルゴリズムの講義を受けている。
そこでハノイの塔の次に出てきたのがマージソートだった。
YAEPでは問題22に出てくる。

これがマージソートのコードだ。

```erlang
merge_list(_, [], Ys) ->
    Ys;
merge_list(_, Xs, []) ->
    Xs;
merge_list(P, [X | Xs], [Y | Ys]) ->
    case P(X, Y) of
        true -> [X | merge_list(P, Xs, [Y | Ys])];
        false -> [Y | merge_list(P, [X | Xs], Ys)]
    end.

merge_sort(_, 0, _) ->
    [];
merge_sort(_, 1, [X | _]) ->
    [X];
merge_sort(P, 2, [X, Y | _]) ->
    case P(X, Y) of
        true -> [X, Y];
        false -> [Y, X]
    end;
merge_sort(P, N, Xs) ->
    M = N div 2,
    merge_list(
        P,
        merge_sort(P, M, Xs),
        merge_sort(P, N - M, drop(M, Xs))
    ).
```

`merge_list/3`は2つのソート済みのリストを1つのソート済みのリストにする関数だ。
Pは述語(booleanを返す関数)でPを用いて要素の大小比較をしている。
`merge_sort/3`でN=0つまりリストの長さが0の時は空のリストを返す。
N=1の時はその要素をそのままリストに入れて返す。
これが終了条件となる。つまりリストの長さが1になるまでリストの分割を繰り返す。
分割が最後まで終わると`merge_list/3`と述語Pでソートしながらマージして帰ってくる。

割と読んで写経してばかりだけどだいぶ感覚が戻ってきた。
そういえば目標はErlangで赤黒木を書くことだった気がする。
もう一度頑張ってみよう。
これからはまだ手をつけていないYAEPの問題を解いていこうと思う。
