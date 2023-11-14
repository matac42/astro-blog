---
author: matac
pubDatetime: 2023-11-14T17:30:39.000Z
title: AmplifyでNode.js18のAstroをデプロイする
postSlug: astro-amplify-node18
featured: false
draft: false
tags:
  - tec
ogImage: ""
description: |
  AmplifyでNode.js18のAstroをデプロイする
_template: blog_post
---

今日はこのブログのテーマをアップデートしたのだが、Amplifyでデプロイする時に問題が発生した。以下のようなWarningが出力され、Non-Zero Exit Codeで終了してしまったのだ。

```
EBADENGINE Unsupported engine {
npm WARN EBADENGINE   package: 'astro@3.1.3',
npm WARN EBADENGINE   required: { node: '>=18.14.1', npm: '>=6.14.0' },
npm WARN EBADENGINE   current: { node: 'v16.19.0', npm: '8.19.3' }
npm WARN EBADENGINE }
```

どうやら現在のAstroはnode v18.14.1以上を要求するらしい。Amplifyのdefault build imageのAmazon Linux2を使用する場合、現状はnode v16.19.0のようなのでこれではビルドできない。ただしバージョンを上げることは可能だ。Amplifyのbuild image settingsには`Live package updates`機能があるのでこれでv18を指定すればビルド時間がは伸びるもののnodeのバージョンアップが走る。ということでnodeのバージョンを18に指定して再度デプロイを試みる。しかしまたWarningを吐いてその後Non-Zero Exit Codeしてしまった。

```
2023-11-14T07:32:38.097Z [WARNING]: node: /lib64/libm.so.6: version `GLIBC_2.27' not found (required by node)
2023-11-14T07:32:38.097Z [WARNING]: node: /lib64/libc.so.6: version `GLIBC_2.28' not found (required by node)
```

glibcのバージョン2.27, 2.28が見つからないと言っている。Amazon Linux2はglibc2.26までしか対応していないらしくバージョンアップも難しそうだ。

- [Packages for glibc, gcc, and binutils](https://docs.aws.amazon.com/linux/al2023/ug/compare-with-al2.html#glibc-gcc-and-binutils)
- [glibc 2.27+ on Amazon Linux 2](https://repost.aws/questions/QUrXOioL46RcCnFGyELJWKLw/glibc-2-27-on-amazon-linux-2)

なのでdefaultイメージを使うのではなくカスタムイメージを使うことにした。
カスタムといってもDocker Hubで公開されている[Node.jsのイメージ](https://hub.docker.com/_/node)を指定するだけだ。イメージに`docker.io/library/node:18`を指定する。

![](/img/build-image.png)

これでビルドが通った。ただ、Astroのテーマのバージョン上げたしビルドの速度改善するかなと思ったらもっと遅くなって悲しい気持ちである。なんかテーマに画像などの圧縮のプロセスが入ってその分時間がかかっているみたい。こんな出力がされていた。

```bash
 Summary
╔═══════════╤════════════╤═══════════╤════════════╤═══════════╗
║ Action    │ Compressed │  Original │ Compressed │      Gain ║
╟───────────┼────────────┼───────────┼────────────┼───────────╢
║ svg->svg  │      1 / 1 │  24.39 KB │   19.45 KB │  -4.94 KB ║
║ jpg->jpg  │    23 / 24 │  43.80 MB │   17.48 MB │ -26.32 MB ║
║ png->webp │    24 / 24 │   8.64 MB │    2.62 MB │  -6.02 MB ║
║ png->jpg  │      2 / 2 │   8.08 MB │  314.97 KB │  -7.77 MB ║
║ .css      │     8 / 10 │ 519.15 KB │  516.88 KB │  -2.26 KB ║
║ .js       │    13 / 38 │   4.54 MB │    4.54 MB │  -1.38 KB ║
║ .svg      │      3 / 3 │  32.46 KB │   25.36 KB │  -7.10 KB ║
║ .html     │  154 / 154 │   3.63 MB │    3.56 MB │ -72.90 KB ║
║ .jpg      │    26 / 28 │  44.58 MB │   21.28 MB │ -23.30 MB ║
║ .png      │  150 / 151 │  19.25 MB │   16.46 MB │  -2.79 MB ║
║ .webp     │      1 / 1 │  26.68 KB │   25.27 KB │  -1.40 KB ║
║ .txt      │      0 / 1 │  121.00 B │   121.00 B │           ║
║ .xml      │      0 / 3 │  52.56 KB │   52.56 KB │           ║
║ .JPG      │      0 / 1 │   2.66 MB │    2.66 MB │           ║
╟───────────┼────────────┼───────────┼────────────┼───────────╢
║ Total     │  405 / 441 │ 135.83 MB │   69.53 MB │ -66.30 MB ║
╚═══════════╧════════════╧═══════════╧════════════╧═══════════╝
```

jampackを使っているようだ。画像などを事前に圧縮して置いてjampackの処理はスキップするのが望ましいかもしれない。
ちなみに後からNode.js 20も試したが問題なかった。

### 追記

jampackをスキップしたらデプロイ時間が7m21sから2m35になった。これはテーマのバージョンを上げる以前よりも速くなっている。
毎日書くので絶対こっちの方が良い。
