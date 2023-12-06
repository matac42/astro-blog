#!/bin/bash

DIRECTORY="src/content/blog"
TARGET_YEAR="2023"

# 月ごとのMarkdownリンクを格納するための連想配列
declare -A markdown_links

# 全ファイルを検索し、指定された年の月ごとにタイトルとスラッグを抽出
for file in "$DIRECTORY"/*.md; do
    # ドラフトの記事をチェック
    if grep -q 'draft: true' "$file"; then
        continue # ドラフトの記事はスキップ
    fi

    # タイトルを抽出
    title=$(sed -n 's/^title: \(.*\)/\1/p' "$file")

    # postSlugを抽出、空の場合はファイル名を使用
    slug=$(sed -n 's/^postSlug: \"\(.*\)\"/\1/p' "$file")
    if [ -z "$slug" ]; then
        slug=$(basename "$file" .md)
    fi

    # 発行年月を抽出し、指定された年と一致するか確認
    year_month=$(grep -o 'pubDatetime: [0-9]\{4\}-[0-9]\{2\}' "$file" | cut -d ' ' -f 2)
    if [[ "$year_month" == "$TARGET_YEAR-"* ]]; then
        # Markdownリンクをフォーマットして連想配列に追加
        if [ -n "$title" ]; then
            markdown_links["$year_month"]+="- [$title](/posts/$slug)\n"
        fi
    fi
done

# 連想配列のキー（年月）をソートして結果を出力
for year_month in $(printf "%s\n" "${!markdown_links[@]}" | sort | uniq); do
    # 月の先頭のゼロを取り除く（バッシュのパラメータ展開を使用）
    formatted_month=$(echo ${year_month:5:2} | sed 's/^0//')
    echo "## ${formatted_month}月"
    echo ""
    echo -e "${markdown_links[$year_month]}"
done

