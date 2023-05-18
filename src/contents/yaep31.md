---
author: matac
datetime: 2023-05-17T15:00:00.000Z
title: Yet Another Erlang Problems 31
slug: yaep31
description: Yet Another Erlang Problems 問題31 順列の問題を解いた
---

## 問題

問題は[こちら](http://www.nct9.ne.jp/m_hiroi/func/yaep02.html#p31)から

リスト Xs から N 個の要素を選ぶ順列を求める関数 permutation(N, Xs) を定義してください。なお、生成した順列はリストに格納して返すものとします。

```
> yaep:permutation(3, [a, b, c]).
[[a,b,c],[a,c,b],[b,a,c],[b,c,a],[c,a,b],[c,b,a]]
```

## 解答

解答は[こちら](http://www.nct9.ne.jp/m_hiroi/func/yaep02.html#ans31)で2種類あったが，ここでは高階関数バージョンについて考える．
ネタバレになるが以下が高階関数バージョンの解答になる．読みやすいように改行やインデントを増やしている．

```erlang
permutation(F, 0, _, A) ->
    F(lists:reverse(A));
permutation(F, N, Xs, A) ->
    lists:foreach(
        fun(X) ->
            permutation(F, N - 1, lists:delete(X, Xs), [X | A])
        end,
        Xs
    ).
permutation(F, N, Xs) when N > 0 -> permutation(F, N, Xs, []).
```

## debugして流れを追う

解答を見てもすぐには理解できなかったし，Fに何を入れれば良いのかわからなかった．
そこで，Fを外してdebuggerを用いて流れを追うことにした．
Fを外すとこんな感じに

```erlang
permutation(0, _, A) ->
    lists:reverse(A);
permutation(N, Xs, A) ->
    lists:foreach(
        fun(X) ->
            permutation(N - 1, lists:delete(X, Xs), [X | A])
        end,
        Xs
    ).
permutation(N, Xs) when N > 0 -> permutation(N, Xs, []).
```

`permutation(3, [a, b, c])`をdebuggerで流れを追ったところ，次のようになっていた．

```
permutation(3, [a, b, c], [a]) X = a
    permutation(2, [b, c], [a]) X = b
        permutation(1, [c], [b, a]) X = c
            permutation(0, [], [c, b, a]) -> [a, b, c]
    permutation(2, [b, c], [a]) X = c
        permutation(1, [b], [c, a]) X = b
            permutation(0, [], [b, c, a]) -> [a, c, b]
permutation(3, [a, b, c], []) X = b
    permutation(2, [a, c], [b]) X = a
        permutation(1, [c], [a, b]) X = c
            permutation(0, [], [c, a, b]) -> [b, a, c]
    permutation(2, [a, c], [b]) X = c
        permutation(1, [a], [c, b]) X = a
            permutation(0, [], [a, c, b]) -> [b, c, a]
permutation(3, [a, b, c], []) X = c
    permutation(2, [a, b], [c]) X = a
        permutation(1, [b], [a, c])
            permutation(0, [], [b, a, c]) -> [c, a, b]
    permutation(2, [a, b], [c]) X = b
        permutation(1, [a], [b, c])
            permutation(0, [], [a, b, c]) -> [c, b, a]
```

`permutation(0, _, A)`(流れの中でインデントが一番深い部分)が順列の要素を返している．
よって，関数Fは次のようなものにするとわかりやすいと思った．単純に出力するだけ．

```erlang
F = fun(X) -> io:format('[~p, ~p, ~p]~n', X) end.
yaep:permutation(F, 3, [a, b, c]). 
```

肝心の実際の処理はどうなっているかというと，
