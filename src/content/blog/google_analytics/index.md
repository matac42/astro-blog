---
title: "HugoのGitHub Pagesでブログのアクセス解析をしたい"
pubDatetime: 2022-04-08T02:02:37+09:00
draft: false
tags:
  - hugo
  - github_actions
  - google_analytics
categories: [tec]
description: ""
---

# アクセス解析できた

このように、ページごとの表示回数などが見れるようになった。他にもどの地域からのアクセスが多いかなども見ることができる。

![](/img/realtime_view.png)

# 方法

Google Analyticsを用いた。

参考: https://qiita.com/chikurin66/items/b776c9a2e5a8ebf0dd68

グローバルサイトタグの確認までは上記Qiitaの記事そのままなので説明を割愛する。
Hugoのindex.htmlはMarkdownから自動生成されるため、どこにグローバルサイトタグを入れるか少し悩んだ。
Hugoにおけるグローバルサイトタグの設定を説明する。

## Hugoにおけるグローバルサイトタグの設定

以下のようなグローバルサイトタグをHTMLの`<head>`セクションに挿入する必要がある。

```html
{{ if not .Site.IsServer }}
<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=<key>"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag() {
    dataLayer.push(arguments);
  }
  gtag("js", new Date());

  gtag("config", "<key>");
</script>
{{ end }}
```

themeを編集する必要があるが、私のブログのthemeはsubmoduleとして設定しているため直接の編集は避けたい。
Hugoはthemeを上書きする機能があるためそれを用いる。

まず、編集したいthemeのhtmlは`themes/even/layouts/partials/head.html`である。
`head.html`は生成されるindex.htmlの`<head>`部分に当たる。
これを上書きするためには、`layouts/partials/head.html`を作成する必要がある。

`mkdir -p layouts/partials`

`$cp themes/even/layouts/partials/head.html layouts/partials/head.html`

そうして`layouts/partials/head.html`にグローバルサイトタグを挿入する。
これでサイトを生成し、アクセスするとgoogle analyticsにPOSTが飛び、アクセス解析が行われるようになる。

# if not .Site.IsServer

グローバルサイトタグを`{{ if not .Site.IsServer }}`で挿入するかしないかの分岐をしている。
`.Site.IsServer`は`hugo server`でサイトを生成表示するとき`true`となる。
この分岐によって、Localで`hugo server`してサイトの見た目を確認するときなどに、google analyticsにPOSTが飛ばないようにしている。

参考: https://gohugo.io/variables/site/

# 終わりに

これでどれくらいの人がブログを見てくれたかわかるようになったので、少し嬉しい。
