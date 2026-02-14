---
title: "Filesystem measurement"
pubDatetime: 2022-04-18T14:37:02+09:00
postSlug: filesystem_measurement
draft: false
tags:
  - filesystem
categories: [tec]
description: ""
---

# ファイルシステムを特徴づける項目は何か

ファイルシステムの特徴を述べるときに、どのような項目について述べたらよいかを考える必要がある。また、ファイルシステムを計測する際にも、それは必要である。ひとまず、列挙してみた。

## Wikipedia調べ

https://en.wikipedia.org/wiki/Comparison_of_file_systems

### Limits

- Maximum filename length
- Allowable characters in directory entries
- Maximum pathname length
- Maximum file size
- Maximum volume size
- Max number of files

いわゆる、性能上限である。数値的に計測可能なものであるから、計測というとこの辺りについて行うと思われる。Allowable characters in directory entriesは対応している文字コードがどれほどあるかである。Max number of filesはcreateできるファイル数の上限である。inodeを用いたファイルシステムの場合、inode領域をinitialize時に確保する都合上、ファイル数の上限 ≒ inode数となる。

### Metadata

- Stores file owner
- POSIX file permissions
- Creation timestamps
- Last access/read timestamps
- Last metadata change timestamps
- Last archive timestamps
- Access control lists
- Security/MAC labels
- Extended attributes/Alternate data streams/forks
- Metadata checksum/ECC

ファイルやディレクトリにどのようなメタデータを持たせることができるかということである。inodeを用いたファイルシステムでは以下のようなメタデータを持つ。

- File type
- Permissions
- Owner ID
- Group ID
- Size of file
- Time last accessed
- Time last modified
- Soft/Hard Links
- Access Control List (ACLs)

### File capabilities

- Hard links
- Symbolic links
- Block journaling
- Metadata-only journaling
- Case-sensitive
- Case-preserving
- File Change Log
- XIP

ファイルに関する機能である。例えば、journalingはファイルシステム上のデータを保護する重要な機能である。

### Block capabilities

- internal snapshotting/branching
- encryption
- deduplication
- Data checksum/ECC
- Persistent Cache
- Multiple Devices
- compression

ブロックに関する機能である。

### Resize capabilities

- Offline grow Online grow Offline shrink
- Online shrink
- add and remove physical volumes

リサイズに関する機能である。

### Allocation and layout policies

- Sparse files
- Block suballocation
- Tail packing
- Extents
- Variable file block size
- Allocate-on-flush
- Copy on write
- Trim support

ファイルやブロックをアロケートする際の機能や規則である。

### OS support

そのファイルシステムがどのOS上で動作するか、ということである。

## Windowsアプリ開発サイト調べ

https://docs.microsoft.com/ja-jp/windows/win32/fileio/filesystem-functionality-comparison

### 機能

- 作成時のタイムスタンプ
- 最終アクセスタイムスタンプ
- 最終変更時刻のタイムスタンプ
- 最後のアーカイブタイムスタンプ
- 大文字と小文字を区別する
- 大文字と小文字を区別する
- ハード リンク
- ソフト リンク
- スパース ファイル
- 名前付きストリーム
- oplock
- 拡張属性
- 代替データ ストリーム
- マウント ポイント

スパースファイルとは部分的に空を含むファイルを実際のファイルシステム上では、空の代わりにメタデータと呼ばれる小さな情報を書き込むことにより効率的に保存する仕組みのこと。

名前付きストリーム(Named Streams, Alternate Streams, Alternate Data Streams, ADS, 代替データストリーム)とは、デフォルトのファイルストリームに名前はついていないが、一つのファイルに複数ストリームを持たせようとしたときに、デフォルトのストリームと区別するために、名前をつける必要がある。そのストリームが名前付きストリームである。

参考: https://infosecwriteups.com/alternate-data-streams-ads-54b144a831f1

oplockはopportunistic lockingの言い換えである。ファイルのロッキング機能。

### 制限

- ファイル名の最大長
- パス名の最大長
- ファイルサイズの最大サイズ
- 最大ボリュームサイズ

### ジャーナルと変更ログ

- メタデータのみのジャーナル
- ファイル変更ログ

### ブロックの割り当て機能

- 末尾のパッキング
- Extents
- 変数ブロックサイズ

### Security

- ファイル所有者の追跡
- POSIXファイルのアクセス許可
- アクセス制御リスト
- ファイルシステムレベルの暗号化
- Checksum/ECC

### 圧縮

- 組み込みの圧縮

### クォータ

- ユーザーレベルのディスク領域
- ディレクトリレベルのディスク領域

自分はクォータという用語をCephで初めて知った。ファイルの数やバイト数を制限できる機能である。

参考: https://access.redhat.com/documentation/ja-jp/red_hat_ceph_storage/4/html/file_system_guide/ceph-file-system-quotas_fs

### 単一インスタンスストア

- ファイルレベル

単一インスタンスストア(SIS)は重複を最小限に抑えつつ、disk, cache, backupなどにstoreする技術である。
WindowsはSingle-instance store backupというAPIを持つ。
