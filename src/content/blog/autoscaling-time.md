---
author: matac
pubDatetime: 2023-09-20T20:31:00.000Z
title: EC2 Auto Scalingの待ち時間の設定
slug: autoscaling-time
featured: false
draft: false
tags:
  - tec
  - infra
ogImage: ""
description: |
  EC2 Auto Scalingを設定する時いくつかの「待ち時間」の設定があるのでまとめてみる
_template: blog_post
---

EC2 Auto Scalingを設定する際、いくつかの待ち時間に関する設定が存在する。

- warmup
- cool down
- Health check grace period
- instance lifetime

## warmup

インスタンスが起動してからAuto Scaling用のメトリクス収集が行われるまでの時間だ。新たにインスタンスが起動した時、この時間だけ待機してからインスタンスのメトリクス収集が始まるので起動後のスパイクなどがAuto Scalingに影響しない。

### 参考

- https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-default-instance-warmup.html

## cool down

前回のAuto Scalingアクティビティが終了してから次のAuto Scalingによるインスタンスの起動を実際に開始するまでの時間だ。インスタンス起動後の処理などが終わる前に次のインスタンスがどんどん立ち上がってしまうのを防ぐ。

### 参考

- https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-scaling-cooldowns.html

## instance lifetime

この時間だけインスタンスが生きる。たとえば86400s(1日)に設定するとインスタンスが起動してから1日が経過した時に新しいインスタンスに置き換えられる。定期的にインスタンス入れ替えをしたい時に設定する。

### 参考

- https://dev.classmethod.jp/articles/asg-max-instance-lifetime/

## Health check grace period

インスタンスがヘルスチェックに不合格した場合、そのインスタンスを維持する時間だ。例えば5sに設定するとヘルスチェックに不合格してから5s経つまではインスタンスを維持する。5s経つ前に再びヘルスチェックに合格すれば何も起こらない。不合格のまま5s経つとインスタンスは終了され、新しい代わりのインスタンスを起動する。

### 参考

- https://docs.aws.amazon.com/autoscaling/ec2/userguide/health-check-grace-period.html

## あとがき

この辺りの待ち時間とCodeDeployのタイミングなどはLifecycle hooksの設定で調整可能らしい。Auto Scaling設定すると自動的に生成されるやつくらいの認識しかなかったのでちょっと調べてみようと思う。

- https://docs.aws.amazon.com/autoscaling/ec2/userguide/lifecycle-hooks-overview.html
