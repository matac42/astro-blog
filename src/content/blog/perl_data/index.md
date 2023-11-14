---
title: "Perlの__DATA__"
pubDatetime: 2022-04-13T23:58:32+09:00
draft: false
tags:
  - perl
categories: [tec]
description: ""
---

# とある日のPerlスクリプト

このようなPerlスクリプトを見かけた

```perl
use strict;
use warnings;
use JSON::PP;

my @users;

while (my $line = <DATA>) {
  if ($line =~/^(@\w+)/) {
    push(@users, {id => $1, done => \0});
  }
}

print encode_json(\@users);


__DATA__

@e18....
 -
matac
e18....@ie.u-ryukyu.ac.jp
...
```

`__DATA__`というリテラルがあって、それ以降の文字列はコードではなくただのテキストのようだ。なんとなく読んでみると、これは`__DATA__`以降のテキストを1行ずつ読み込んで、正規表現でマッチした部分を使ってjsonを生成しているように思える。`__DATA__`以降は標準入力になるような感じだろうか。

# **DATA**とは何か

[perldoc](https://perldoc.perl.org/perldata#Special-Literals)によるとこれはSpecial Literalsの一種である。Special Literalsには他に`__FILE__`、`__LINE__`、`__PACKAGE__`、`__SUB__`がある。これらを出力してみる。

```perl
use 5.16.0;
use strict;
use warnings;
use utf8;

sub matac {
    return __SUB__;
}

say __FILE__;
say __LINE__;
say __PACKAGE__;
say matac;
say <DATA>;

__DATA__
hoge
```

```
$perl test.pl
test.pl
12
main
CODE(0x123025570)
hoge
```

# 何に使うか

たしか、Pythonを授業で習ったときにもこういった特殊な変数みたいなのがあったはずだ。それは、以下のようなものだった。モジュールによって処理を切り分けたいときに使う。

```python
if __name__ == "__main__":
```

`__PACKAGE__`や`__LINE__`、`__FILE__`もきっと同じような感じで使うのだろう。
`__DATA__`に関しては、実装と入力を一つのファイルにすることで、そのスクリプトの使い方を察しやすくするとか、標準入力に毎回コピペするの面倒な時に使えるかもしれない。スクリプトはそれ単体になってしまうと、スクリプトを読める人がいない限り使い方がわからなくなってしまう問題があるので、スクリプトの中にどのようなものを渡したら良いかが、置いてあるのは良いかもしれない。しかしながら、実際スクリプトを作るときはREADMEも一緒に置いておくのが正解だろう。
