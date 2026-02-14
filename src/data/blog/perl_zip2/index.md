---
title: "Pythonのzipに準ずるPerlのzip"
pubDatetime: 2022-04-04T00:48:06+09:00
postSlug: perl_zip2
draft: false
tags:
  - perl
categories: [tec]
description: ""
---

# やりたいこと

2つの配列を次のように処理したい。

```perl
[1, 2, 3, 4, 5]
[6, 7, 8, 9, 10]

to

[[1,6], [2,7], [3,8], [4,9], [5,10]]
```

# コード

## moduleを使う場合

[https://metacpan.org/pod/List::Zip](https://metacpan.org/pod/List::Zip)

```perl
use strict;
use warnings;
use utf8;
use Data::Dumper;
use List::Zip;

my @a = (1,2,3,4,5);
my @b = (6,7,8,9,10);
my @ab = zip(\@a, \@b);

print Dumper(\@ab);
```

## moduleを使わない場合

参考: [https://www.koikikukan.com/archives/2014/07/03-005555.php](https://www.koikikukan.com/archives/2014/07/03-005555.php)

```perl
use strict;
use warnings;
use utf8;
use Data::Dumper;

sub zip {
    my ($x, $y) = @_;
    my $len = @$x;
    my @aa;
    for (my $i = 0; $i < $len; $i++) {
        push @{$aa[$i]}, @$x[$i];
        push @{$aa[$i]}, @$y[$i];
    }
    return @aa;
}

my @a = (1,2,3,4,5);
my @b = (6,7,8,9,10);
my @ab = zip(\@a, \@b);

print Dumper(\@ab);
```

# 実行結果

```bash
$perl zip.pl
$VAR1 = [
          [
            1,
            6
          ],
          [
            2,
            7
          ],
          [
            3,
            8
          ],
          [
            4,
            9
          ],
          [
            5,
            10
          ]
        ];
```

# 面白い部分

moduleを使わない場合にて、zip関数の引数として`zip(\@a, \@b)`と、配列のリファレンスを渡している。
受け取り側は`my ($x, $y) = @_;`と、スカラで受け取る。
もしそのまま配列で渡し受けると、`@a`と`@b`がくっついて`(1,2,3,4,5,6,7,8,9,10)`が渡され、
受け取り側は`@x`が`(1,2,3,4,5,6,7,8,9,10)`、`@y`が`undef`となる。
