---
author: matac
datetime: 2023-10-08T20:44:00.000Z
title: Warpを試してみている
slug: warp
featured: false
draft: false
tags:
  - tec
ogImage: ""
description: >-
  Warpを試してみている
_template: blog_post
---

今までiTermを使っていたが[Warp](https://www.warp.dev/)というターミナルエミュレーターが良いらしいので使ってみている。

見た目はそれぞれこんな感じ。

### iTerm

![](/img/iterm.png)

### Warp

![](/img/warp.png)

色は揃えた。Warpは見た目がかっこいい。
iTermの時と大差なく使えているが個人的に不便だと感じている部分だけ説明しておく。
私は~/.zshrcにこんな設定を入れている。

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
bindkey '^]' peco-src
```

これは`^]`を打つと`~/ws/src`などの特定のディレクトリに置いているリポジトリを検索できるものだ。

- 参考: https://zenn.dev/obregonia1/articles/e82868e8f66793

これがWarpだと使えない。bindkeyがWarpに持って行かれてしまうからだと思われる。
これさえ使えれば若しくは同等のことができる何かがあれば私としては満足なのだが。
何かいい方法ないかなぁ。
