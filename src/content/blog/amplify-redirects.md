---
author: matac
pubDatetime: 2023-11-19T20:45:18.000Z
title: 地味に面倒なドメイン変更
postSlug: amplify-redirects
featured: false
draft: false
tags:
  - tec
  - infra
ogImage: ""
description: |
  blog.matac.infoからmatac.infoへ移行した
_template: blog_post
---

私は常々このブログのドメイン`blog.matac.info`にダサさを感じていた。
`matac.info`の部分はまあいいとして、問題は頭についている`blog`だ。
好みの問題ではある。別にサブドメインを切ったって特に問題はない。
ただ、私はこの頭の`blog`が気に食わない。
一応理由をいくつか上げると、

- URLが長くなるから
- ブログではなく、ホームページとして扱いたいから

などがある。「URLが長くなる」はまあその通りだ。
短い方が打ちやすいし、見た目もすっきりする。
もう一つの「ブログではなく、ホームページとして扱いたいから」は、
将来的にブログだけでなく、ポートフォリオやリンク集などの機能を追加した時、
つまりホームページのようなものに成り変わった時のことを考えている。
もしその時、`blog`が頭についていると名が体を表しきれていない状態になる。

ということで、`blog`を取る作業をしていこう。よーし、DNSレコードを書き換えて終わり！
とはならない。ドメイン乃至、URLを変えるというのは案外難しい。

## 何が難しいのか

ドメイン変更の難しさは「リンク切れを起こしてはいけない」、
この一点がほぼ全てを占めると思う。
例えば`https://blog.matac.info/about/`があったとする。
ドメインを変更すると`https://matac.info/about/`に同じページが配置される。
しかし、単純にDNSレコードを書き換えて移行すると、
`https://blog.matac.info/about/`にアクセスできなくなる。
いわゆるリンク切れを起こしてしまう。

なので、リンク切れを起こさないように`https://blog.matac.info/about/`に来たアクセスを
`https://matac.info/about/`にリダイレクトする必要がある。

## もう1つの問題

旧ドメインから新ドメインにリダイレクトするだけならばたいして難しいことはない。
しかし、もう1つの問題があった。それは`matac.info`が旧ブログで使われていることだ。

実は、この[astro-paper](https://github.com/satnaing/astro-paper)のブログ以前に、
Hugoで作ったブログがあった。それが`matac.info`に置かれている。
なので、記事の移行をして旧ブログを閉鎖してからドメインを移行する必要がある。

幸運なことに、AstroもHugoも記事の元データは同じMarkdown形式のファイルだ。
なのでFrontmatterを適切に書き換えつつ、
現在のブログのMarkdownファイル置き場に置いてあげれば良い。
というかそういうことを想定してMarkdownから生成するシステムを採用したのだ。

よし、これでいけるぞ〜

とはならなかった。まだ問題がある。

## 最後の問題

実は旧ブログと新ブログで異なる点が１つある。
それはブログページが置かれるパスが違うことだ。
具体例を挙げる。

#### 旧ブログ

- `https://matac.info/post/existentialism_books/`

#### 新ブログ

- `https://blog.matac.info/posts/existentialism_books/`

差異は`post`か`posts`かだ。
揃えたつもりだった気もするが、この違いに気づかなかった。

この違いがあるとどのような問題が発生するか。もちろんリンク切れである。
なので、これも`post`から`posts`にリダイレクトしてあげる必要がある。

## さて、どうしようか

Nginxなどのミドルウェアを使っている場合はドメインもパスもリダイレクトの設定ができるはずだ。
だが、このブログは[AWS Amplify](https://aws.amazon.com/amplify/)を使用しているので、
AWSの方でどうにかするのが良いだろう。
ALBとか使うのかな。

調べてみると、
Amplifyには[Rewrites and redirects](https://docs.aws.amazon.com/amplify/latest/userguide/redirects.html)という、
アクセス時にURLのパスやドメイン名を書き換える機能がある。神か。
これでドメインとパスのリダイレクトが設定できそうだ。

## 設定

以下のように設定した。

| Source address              | Target address         | Type                       |
| --------------------------- | ---------------------- | -------------------------- |
| https://matac.info          | https://www.matac.info | 302 (Redirect - Temporary) |
| https://blog.matac.info     | https://www.matac.info | 301 (Redirect - Permanent) |
| https://www.blog.matac.info | https://www.matac.info | 301 (Redirect - Permanent) |
| /post/<\*>                  | /posts/<\*>            | 301 (Redirect - Permanent) |

これで`blog.matac.info`は`matac.info`に、`/post`は`/posts`にリダイレクトされる。
これが一画面で設定できる。超便利だ。こんなに簡単に設定できるとは思っていなかった。

一応いくつか説明する。
301と302の違いは検索エンジンがリダイレクト前後どちらのドメインを見るかだ。
検索エンジンは301であればリダイレクト後のドメインを、302であればリダイレクト前のドメインを見る。
今回、ブログは完全に`matac.info`に移ったので301を選択した。
ちなみに`www`をつけている理由はそんなにない。
一応CDNを考慮するとつけた方が良いらしい。

- [ドメインにwwwは必要？2021年版、最新のWebサイトURLの決め方講座](ドメインにwwwは必要？2021年版、最新のWebサイトURLの決め方講座)

## Amplify最高

ドメインやパスのリダイレクトが必要になってしまったのは、全て私のミスと言っていいだろう。
本来ならば、新ブログを立ち上げた時に旧ブログの移行もやってしまえばよかったのだ。
中途半端なことをするからこうなった。

Amplifyはこのようなミスも余裕でカバーしてくれた。ありがとう。Amplify最高。

今後サービスの移行をする機会があったら、リダイレクトの必要なく移行できるようにしたい。
それと、ドメインやパスは熟考して決めること。移行はできないことはないが地味に面倒だしお金もかかるかも。
