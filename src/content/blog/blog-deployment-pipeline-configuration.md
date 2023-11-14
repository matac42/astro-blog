---
author: matac
pubDatetime: 2023-01-30T20:09:24.000Z
title: Blog Deployment Pipeline Configuration
postSlug: ""
featured: false
draft: false
tags: []
ogImage: ""
description: I have set it up so that I can deploy Astro static sites with GitHub Actions.
_template: blog_post
---

# Workflow ファイルの作成

    name: Build React on S3
    on:
      push:
          branches:
            - main
    jobs:
      build:
        runs-on: ubuntu-latest
        steps:
          - name: Checkout
            uses: actions/checkout@main

          - name: Install Dependencies
            run: npm install

          - name: Build
            run: npm run build

          - name: Deploy
            env:
              AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
              AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
            run: aws s3 cp --recursive --region ap-northeast-1 dist s3://matac.info/

[https://github.com/matac42/astro-blog/blob/main/.github/workflows/main.yml](https://github.com/matac42/astro-blog/blob/main/.github/workflows/main.yml "https://github.com/matac42/astro-blog/blob/main/.github/workflows/main.yml")

やったのはこれだけです。GitHub のリポジトリシークレットに AWS のキーをセットしてあげて aws s3 cp で送ってあげます。
