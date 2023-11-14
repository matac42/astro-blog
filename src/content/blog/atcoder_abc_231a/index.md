---
title: "AtCoder ABC 231Aのコード削ってみた"
pubDatetime: 2022-04-05T03:16:05+09:00
draft: false
tags:
  - perl
  - atcoder
categories: [tec]
description: ""
---

提出した後そのコードをどれだけ削れるかをやりたくなるのだが、これはとても短くなった。

# 最初に提出したコード

こんな感じでAC

```perl
use 5.10.0;
use strict;
use warnings;
use utf8;

chomp(my $d = <>);

my $answer = $d / 100;

say $answer;
```

# 削っていく

まず入力を変数化する必要がないので

```perl
use 5.10.0;
use strict;
use warnings;
use utf8;

my $answer = <>/100;

say $answer;
```

$answerも必要ないので

```perl
use 5.10.0;
use strict;
use warnings;
use utf8;


say <>/100;
```

ACのためだけならuseもいらないので

```perl
use 5.10.0;

say <>/100;
```

sayのためのuseが残ったがprintを使えば省略でき、改行しなくてもAtCoderは見てくれるので

```perl
print <>/100;
```

これだけで良かったのか...

A問題であれば大体どの問題も1行で終わるのではないか。

# ちなみに

`chomp(my $d = <>);`も最近知った。`my $d = <>`ごとchompで囲むことでchompできる。
