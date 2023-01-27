---
title: "Perlの出力関数printとsayの違い"
datetime: 2022-04-05T00:31:20+09:00
draft: false
tags: 
  - perl
categories: [tec]
---

# 出力関数printとsay

Perlにはprintとよく似たsayという出力関数がある。
最近Perlの勉強のためにAtCoderをやっているのだが、printでなくsayを用いている人がいて気になった。
[say - Perldoc Browser](https://perldoc.perl.org/functions/say)ではprintとの違いを次のように説明している。

> Just like print, but implicitly appends a newline at the end of the LIST instead of any value $\ might have. 

printで改行をつけて出力するときは`print 'matac\n';`と記述するが、sayでは`say 'matac';`と改行文字無しで改行をつけてくれる。
ただし使うときには以下のどれかを行う必要がある。

- `CORE::say`とする
- `use feature 'say';`する
- `use 5.10.0;`する(5.10.0以上であればなんでも)

`CORE::say 'matac';`のように使う。もしくは、`use feature 'say';`でsay機能を有効化する。
`use feature`はPerlの新しい機能を有効化する。sayは`use 5.10.0;`とすることでも有効化されるらしい。
Perldocのfeatureのページによると、sayはRaku由来のようだ。

[feature - Perl pragma to enable new features](https://perldoc.perl.org/feature)

# $\

sayとprintの違いを説明する部分で`$\`という記号が出てきているが、これは出力の際にprintに設定されているアウトプットレコードの区切り文字を表している。
`$\`にセットされている値が区切り文字として用いられ、デフォルトはundefである。であるから、次のように書くと改行される。

```perl
use strict;
use warnings;
use utf8;

local $\ = "\n";
print "matac";
```

出力
```sh
$perl test.pl
matac
```

# どちらを使うべきか

区切り文字の違いしか無さそうなので、どちらでも良さそう。
`say`の方が実行するときに勢いを感じられて好きかもしれない。