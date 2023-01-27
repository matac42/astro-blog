---
title: "Multipass"
datetime: 2022-04-22T12:05:27+09:00
draft: false
tags: 
  - infra
categories: [tec]
---

# Multipass使ってみた

M1 MacbookでVMを動作させることができるソフトウェアで、Multipassというものがあるのを知った。
Ubuntu Onlyのようだが、試しに使ってみた。

## インストールなど

[https://multipass.run/](https://multipass.run/)に書いてあるとおり。

## VMの起動

`multipass`コマンドが使える。次のように、VMを作成起動する。imageのダウンロードなどを行っていると思われるので、少々時間がかかる。

```
$multipass launch --name matac
Launched: matac 
```

## その他のコマンド

VMの一覧を見る。Ubuntu 20.04 LTSで起動していることや、IPアドレスが振られていることがわかる。

```
$multipass list
Name                    State             IPv4             Image
matac                   Running           192.168.64.2     Ubuntu 20.04 LTS
```

VMにLoginする。Ubuntuだ(当たり前)。

```
$multipass shell matac
Welcome to Ubuntu 20.04.4 LTS (GNU/Linux 5.4.0-109-generic aarch64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Fri Apr 22 11:38:53 JST 2022

  System load:             0.33
  Usage of /:              27.2% of 4.68GB
  Memory usage:            19%
  Swap usage:              0%
  Processes:               102
  Users logged in:         0
  IPv4 address for enp0s1: 192.168.64.2
  IPv6 address for enp0s1: fd5c:1e16:54b0:6f8:5054:ff:fe24:7793


0 updates can be applied immediately.


To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@matac:~$ 
```

情報を見る。デフォルトではディスク容量が4.7GB、メモリが970MBのようだ。

```
$multipass info matac 
Name:           matac
State:          Running
IPv4:           192.168.64.2
Release:        Ubuntu 20.04.4 LTS
Image hash:     039c9c950da5 (Ubuntu 20.04 LTS)
Load:           0.00 0.00 0.00
Disk usage:     1.3G out of 4.7G
Memory usage:   143.4M out of 970.0M
Mounts:         --
```

execしてみる。なんかコンテナっぽい感じで使える。

```
$multipass exec matac -- lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 20.04.4 LTS
Release:	20.04
Codename:	focal
```

helpしてみる。かなりシンプルなコマンドだと思う。

```
$multipass help                        
Usage: multipass [options] <command>
Create, control and connect to Ubuntu instances.

This is a command line utility for multipass, a
service that manages Ubuntu instances.

Options:
  -h, --help     Displays help on commandline options.
  --help-all     Displays help including Qt specific options.
  -v, --verbose  Increase logging verbosity. Repeat the 'v' in the short option
                 for more detail. Maximum verbosity is obtained with 4 (or more)
                 v's, i.e. -vvvv.

Available commands:
  alias     Create an alias
  aliases   List available aliases
  delete    Delete instances
  exec      Run a command on an instance
  find      Display available images to create instances from
  get       Get a configuration setting
  help      Display help about a command
  info      Display information about instances
  launch    Create and start an Ubuntu instance
  list      List all available instances
  mount     Mount a local directory in the instance
  networks  List available network interfaces
  purge     Purge all deleted instances permanently
  recover   Recover deleted instances
  restart   Restart instances
  set       Set a configuration setting
  shell     Open a shell on a running instance
  start     Start instances
  stop      Stop running instances
  suspend   Suspend running instances
  transfer  Transfer files between the host and instances
  umount    Unmount a directory from an instance
  unalias   Remove an alias
  version   Show version details
```

# cloud-init

以下のように、cloud-initでコンフィグファイルを読み込ませて、VMを作成することもできる。
KVMのxmlとか、DockerのDockerfileみたいな感じだろう。

参考: https://ubuntu.com/blog/using-cloud-init-with-multipass

# まとめ

Ubuntuをパソコンみたいに使いたい時はmultipass便利だと思う。サーバーとして扱うならVMでなく、コンテナを使うだろう。