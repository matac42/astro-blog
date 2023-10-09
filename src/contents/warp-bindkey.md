---
author: matac
datetime: 2023-10-09T11:30:00.000Z
title: Warpでbindkeyが使えない問題のWorkaround
slug: warp-bindkey
featured: false
draft: false
tags:
  - tec
ogImage: ""
description: >-
  Warpでbindkeyが使えない問題のWorkaround
_template: blog_post
---

昨日発見してしまったWarpの不便な点についてだ。

前回の記事
- [Warpを試してみている](/posts/warp)

最近[Warp](https://www.warp.dev/)というターミナルエミュレーターを使ってみている。
デザインがモダンな感じでなんかAI機能も搭載されていて面白いなと思っている。
しかし1つだけ不便に感じている部分がある。それは`.zshrc`の設定の`bindkey`が使えないというものだ。

Warpのリポジトリのissueとしても上がっている。

- https://github.com/warpdotdev/warp/issues/537

とは言っても私が`bindkey`を使用しているのは以下の部分のみだ。

```
# ghq with peco
function peco-src () {
  local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-src
bindkey '^T' peco-src

# history with peco
function peco-history-selection() {
    BUFFER=`history -n 1 | tail -r  | awk '!a[$0]++' | peco`
    CURSOR=$#BUFFER
    zle reset-prompt
}

zle -N peco-history-selection
bindkey '^R' peco-history-selection
```

`peco-src`は[ghq](https://github.com/x-motemen/ghq)で管理しているリポジトリを[peco](https://peco.github.io/)で検索して`cd`する。`peco-history-selection`はコマンド履歴を[peco](https://peco.github.io/)で検索して実行する。

`peco-history-selection`に関してはWarpがデフォルトで同等の機能を提供しているのでそっちに乗り換えれば問題ない。
しかし、`peco-src`のような機能はWarpにない。`bindkey`を使用せずに同じようなことはできるか。

## 解決方法

ごめんなさい。Workaroundってほどのものでもない。結構ダサい。

```
# ghq with peco (no bindkey)
function g () {
  local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    cd ${selected_dir}
  fi
}
```

`g`関数を作成した。実行するときは`g`コマンドを打つ。
実行する時に打つキーはgとEnterの２つだけなので「実質キーバインド」みたいな感じ。
意外と不便ではない。まあいいんじゃないかな。

これでiTermの時とほぼ同じように使えるようになった。
そもそもの話、ターミナルソフト使わずにVSCodeで全部頑張るのが良いかもしれないがそれはそのうち。
おそらくVSCodeにはリポジトリを検索できる拡張機能あるんじゃなかろうか。
この辺とか。
- https://marketplace.visualstudio.com/items?itemName=hadenlabs.ghq-project-manager