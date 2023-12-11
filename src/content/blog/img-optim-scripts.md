---
author: matac
pubDatetime: 2023-12-11T22:25:26.000Z
title: ブログに載せる画像の変換スクリプト
postSlug: img-optim-scripts
featured: false
draft: false
tags:
  - random
ogImage: ""
description: |
  ブログに載せる画像の変換スクリプト
_template: blog_post
---

ブログに載せる画像はサイズを小さくし、動画はGIFに変換している。
これを毎回それぞれ別々のコマンドでやるのが面倒だったので、
スクリプトにした。ChatGPTに書いてもらったので5分くらいでできた。

```zsh
#!/bin/zsh

# ファイルの拡張子を取得
file_extension="${1##*.}"
base_name="${1%.*}"

# 拡張子に応じた処理を実行
case $file_extension in
    mp4)
        # MP4からGIFへの変換
        output_file="${base_name}.gif"
        ffmpeg -i "$1" -pix_fmt rgb8 -r 10 "$output_file" && gifsicle -O3 "$output_file" -o "$output_file"
        ;;
    jpg | jpeg)
        # JPEGのサイズダウン
        output_file="${base_name}_optimized.jpg"
        cp "$1" "$output_file"
        jpegoptim -s -m 85 "$output_file"
        ;;
    png)
        # PNGのサイズダウン
        output_file="${base_name}_optimized.png"
        cp "$1" "$output_file"
        optipng "$output_file"
        ;;
    *)
        echo "サポートされていないファイル形式です。"
        exit 1
        ;;
esac

# 変換したファイルを特定のディレクトリに送る
rsync -avP --ignore-existing "$output_file" $BLOG_IMGDIR

# rsyncの終了ステータスを確認
if [ $? -eq 0 ]; then
    echo "ファイルは正常に送信されました。"
else
    echo "エラー: 同名のファイルが送り先に存在します。"
    exit 1
fi
```

本当はAirDropで送ったら、自動で変換してブログのディレクトリにおいてくれるようにしたい。できるのかな。Automator使えばある程度はできそう。別にAirDropにこだわらなくても良いかも。

まあ、こういった細かい部分だけど、そういうところを自動化すると思った以上に捗るようになると思う。人間、意外と手間に慣れてしまうから気をつけたい。
