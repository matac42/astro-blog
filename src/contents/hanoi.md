---
author: matac
datetime: 2023-10-12T22:29:00.000Z
title: 久しぶりのErlangでハノイの塔
slug: hanoi
featured: false
draft: false
tags:
  - tec
  - erlang
ogImage: ""
description: >-
  ハノイの塔
_template: blog_post
---

2ヶ月前くらいは趣味でErlangを書いていたのだが最近全然書いてない。
以前一回だけブログに書いたものがある。

- [Yet Another Erlang Problems 31](yaep31)

これはYet Another Erlang ProblemsというErlangの練習問題集的なものの31問目を頑張ったという内容だ。
今の自分が読んでもあんまりよくわからない。

とりあえずなんか読み書きして使い方を思い出そうということでErlangでハノイの塔を書いた。
まあいつの日かの写経だが。
なぜハノイの塔かというと今期受けているのがアルゴリズムの講義でそこでハノイの塔が出てきたからなんとなく。

```erlang
-module(hanoi).
-export([hanoi/4]).

hanoi(1, From, To, _) -> io:write({From, to, To});
hanoi(N, From, To, Via) ->
  hanoi(N - 1, From, Via, To),
  io:write({From, to, To}),
  hanoi(N - 1, Via, To, From).
```

`hanoi/4`関数からも分かるようにハノイの塔はディスクの枚数Nと3つの棒(From, To, Via)からなる。
上記のコードは出力部分を除けば全て再帰で書かれていることがわかる。
ハノイの塔は一見複雑なコードになりそうだが実は再帰でシンプルに記述することができるアルゴリズムの代表だろう。
`hanoi(1, From, To, _)`で最後にディスクをFromからToに移して終了している。
こういう感じで終了条件を最初に書くとErlangしてる感じがして楽しい。

実際に実行するとこんな感じ。

```erlang
> hanoi:hanoi(3,f,t,v).
{f,to,t}{f,to,v}{t,to,v}{f,to,t}{v,to,f}{v,to,t}{f,to,t}ok
```

そういえばハノイの塔の名称の由来ってなんだろう。
Wikipediaによるとフランスの数学者エドゥアール・リュカが発売したゲーム『ハノイの塔』がルーツらしい。
ハノイは地名だがなぜハノイの塔としたかは作者ののみぞ知るといったところか。
ちなみに64枚のディスクを移動し終えると世界も終わるらしい。

ハノイの塔といえばバックアップ戦略にThe Tower of Hanoi rotation methodというものがある。
バックアップディスクを複数用意してそこにある決まった順序で差分バックアップをとっていく。
A, B, CがあればA -> B -> A -> C -> A -> B -> A -> C -> ...といった感じだ。
しかし、この順序などがゲームのハノイの塔と何か関係があるかと言われると特にないようだ。
動きがなんとなくハノイの塔に似ているのでそう名付けた気持ちはわかる。

Erlangはなるべく毎日書きたいところ。2ヶ月も空けちゃったのでだいぶ後退している気がする。
別にHaskellでもいいんだけどさ。
