---
author: matac
datetime: 2023-05-17T15:00:00.000Z
title: Yet Another Erlang Problems 31
slug: yaep31
tags:
  - erlang
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

解答は[こちら](http://www.nct9.ne.jp/m_hiroi/func/yaep02.html#ans31)で 2 種類あったが，ここでは高階関数バージョンについて考える．
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

## debug して流れを追う

解答を見てもすぐには理解できなかったし，F に何を入れれば良いのかわからなかった．
そこで，F を外して debugger を用いて流れを追うことにした．
F を外すとこんな感じに

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

`permutation(3, [a, b, c])`を debugger で流れを追ったところ，次のようになっていた．

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
よって，関数 F は次のようなものにするとわかりやすいと思った．単純に出力するだけである（本当は問題の出力例と揃えたい）．

```erlang
F = fun(X) -> io:format('[~p, ~p, ~p]~n', X) end.
yaep:permutation(F, 3, [a, b, c]).
```

肝心の実際の処理はどうなっているかというと，流れの通りなのだがこれを言葉で説明するのは難しい......
だが，一応頑張ってみる．

## 頑張って言葉で説明してみる

### permutation(2, [a, b])の場合

`permutation(3, [a, b, c])`をいきなり考えると難しいので，`permutation(2, [a, b])`を考える．

`Xs = [a, b]`からある順番で取り出して累積変数の`A`に押し込み，最後に reverse する．

まずは`a`を取り出して`A`に押し込む(`A = [a]`)．すると残りは`[b]`だけなのでそれも`A`に押し込む(`A = [b, a]`)．
この時 reverse して`[a, b]`が得られる．

次に`b`を取り出して`A`に押し込む(`A = [b]`)．すると残りは`[a]`だけなのでそれも`A`に押し込む(`A = [a, b]`)．
この時 reverse して`[b, a]`が得られ，`permutation(2, [a, b])`は`[[a, b], [b, a]]`となり順列が得られる．

### permutation(3, [a, b, c])の場合

`Xs = [a, b, c]`からある順番で取り出して累積変数の`A`に押し込み，最後に reverse する．

まずは`a`を取り出して`A`に押し込む(`A = [a]`)．すると残りは`[b, c]`のになる．
ここで，残りの`Xs = [b, c]`の場合についても考える．

- まずは`b`を取り出して`A`に押し込む(`A = [b, a]`)．すると残りは`[c]`だけなのでそれも`A`に押し込む(`A = [c, b, a]`)．この時 reverse して`[a, b, c]`が得られる．
- 次に`c`を取り出して`A`に押し込む(`A = [c, a]`)．すると残りは`[b]`だけなのでそれも`A`に押し込む(`A = [b, c, a]`)． この時 reverse して`[a, c, b]`が得られる．

図にするとこんな感じだと思う．

```
a ---- b ---- c
   |
   |-- c ---- b
```

これを`b`から始める場合と`c`から始める場合も行う．

```
b ---- a ---- c
   |
   |-- c ---- a

c ---- a ---- b
   |
   |-- b ---- a
```

`まずは~を取り出して`というのがプログラム上では以下の`lists:foreach`の部分に当たる．
`まずはXsからXを取り出して`と言った方がいいだろうか．

```
lists:foreach(
    fun(X) ->
        permutation(F, N - 1, lists:delete(X, Xs), [X | A])
    end,
    Xs
).
```

以下は処理の順番通りではないが，

<<<<見やすいように区切り>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

まずは`[a, b, c]`から`a`を取り出して~

まずは`[b, c]`から`b`を取り出して~ (1)

まずは`[c]`から`c`を取り出して~

<<<<見やすいように区切り>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

まずは`[a, b, c]`から`b`を取り出して~

まずは`[a, c]`から`a`を取り出して~ (1)

まずは`[c]`から`c`を取り出して~

<<<<見やすいように区切り>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

まずは`[a, b, c]`から`c`を取り出して~

まずは`[a, b]`から`a`を取り出して~ (1)

まずは`[b]`から`b`を取り出して~

<<<<見やすいように区切り>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

ここまでは`[a, b, c]`から

- `a`を最初に取り出した場合
- `b`を最初に取り出した場合
- `c`を最初に取り出した場合

について考えている．しかし，それを考えた時に新しく`[b, c]`，`[a, c]`，`[a, b]`が(1)のところで出てきているので
それについても場合わけを考える必要がある．

`[b, c]`から

- `b`を最初に取り出した場合
- `c`を最初に取り出した場合

`[a, c]`から

- `a`を最初に取り出した場合
- `c`を最初に取り出した場合

`[a, b]`から

- `a`を最初に取り出した場合
- `b`を最初に取り出した場合

というのを再帰で行っている．

## やっぱり言葉で説明するのは難しい

よく見たら上の図はただ出力を列挙してるだけで何の説明にもなっていない......

どうやって説明するのが良いのだろうか．
この処理を 10 行もないプログラムで表現できるのがすごいとも思った．
