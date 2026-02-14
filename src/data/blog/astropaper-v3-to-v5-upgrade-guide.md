---
author: matac
pubDatetime: 2026-02-14T12:00:00.000Z
title: AstroPaper v3 → v5 アップグレード完全ガイド（Astro 5 + Tailwind v4 移行）
postSlug: "astropaper-v3-to-v5-upgrade-guide"
featured: false
draft: false
tags:
  - astro
  - tailwindcss
  - niko
ogImage: ""
description: |
  AstroPaper v3（Astro 3 + Tailwind v3）から v5（Astro 5 + Tailwind v4）へのアップグレード手順と、移行時に遭遇したハマりポイント・解決策をまとめました。Content Collections 新API、Pagefind 検索移行、React コンポーネントの Astro 化など。
---

## はじめに

このブログは [AstroPaper](https://github.com/satnaing/astro-paper) テーマをベースにした Astro 製の静的サイトで、AWS Amplify にデプロイしています。今回、AstroPaper v3（Astro 3 + Tailwind CSS v3）から **AstroPaper v5（Astro 5 + Tailwind CSS v4）** にアップグレードしました。

468件のブログ記事を抱えた状態での大型移行でしたが、無事に完了できたのでその手順とハマりポイントを共有します。

## 主な変更点サマリー

| 項目 | Before (v3) | After (v5) |
|---|---|---|
| Astro | 3.x | 5.x |
| Tailwind CSS | 3.x | 4.x |
| 検索 | Fuse.js + React | Pagefind |
| Content Collections | `type: "content"` | `loader: glob()` |
| View Transitions | `<ViewTransitions />` | `<ClientRouter />` |
| CSS 設定 | `tailwind.config.cjs` + `base.css` | `@theme inline` + `global.css` |
| ESLint | `.eslintrc.js`（legacy config） | `eslint.config.js`（flat config） |
| インポートパス | `@utils/`, `@components/` 等 | `@/*` に統一 |

## Step 1: package.json の更新

### 削除したパッケージ

```
@astrojs/tailwind → @tailwindcss/vite に置き換え
@astrojs/react, react, react-dom → Pagefind 移行で不要に
fuse.js → Pagefind に置き換え
```

**注意**: OG 画像生成（Satori）で JSX を使っている場合、`react` と `@types/react` は引き続き必要です。ビルド時に `react/jsx-runtime` が解決できないエラーが出ます。

### 追加したパッケージ

```
@tailwindcss/vite → Tailwind v4 の Vite プラグイン
pagefind, @pagefind/default-ui → 検索機能
```

### build スクリプトの変更

```json
"build": "astro check && astro build && pagefind --site dist && cp -r dist/pagefind public/"
```

`pagefind --site dist` でビルド後のHTMLからインデックスを生成し、`cp -r dist/pagefind public/` で開発サーバー用にコピーしています。

## Step 2: astro.config.ts の更新

```typescript
// Before
import tailwind from "@astrojs/tailwind";
import react from "@astrojs/react";

export default defineConfig({
  integrations: [tailwind({ applyBaseStyles: false }), react(), sitemap()],
  markdown: {
    shikiConfig: { theme: "one-dark-pro", wrap: true },
  },
  scopedStyleStrategy: "where",
});

// After
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  integrations: [sitemap()],
  markdown: {
    shikiConfig: {
      themes: { light: "min-light", dark: "night-owl" },
      wrap: true,
    },
  },
  vite: {
    plugins: [tailwindcss()],
    optimizeDeps: { exclude: ["@resvg/resvg-js"] },
  },
});
```

ポイント:
- `@astrojs/tailwind` と `react()` integration を削除
- Tailwind は `vite.plugins` に `@tailwindcss/vite` として追加
- Shiki のテーマ設定が `theme` → `themes: { light, dark }` に変更（デュアルテーマ対応）
- `scopedStyleStrategy: "where"` は v5 で不要に

## Step 3: Content Collections 移行

Astro 5 では Content Collections の API が大幅に変わりました。

### config ファイルの移動

```
src/content/config.ts → src/content.config.ts
```

### loader の変更

```typescript
// Before
const blog = defineCollection({
  type: "content",
  schema: ({ image }) => z.object({ ... }),
});

// After
import { glob } from "astro/loaders";

const blog = defineCollection({
  loader: glob({ pattern: "**/[^_]*.md", base: "./src/data/blog" }),
  schema: ({ image }) => z.object({ ... }),
});
```

### 記事ディレクトリの移動

```
src/content/blog/ → src/data/blog/
```

468件の記事ファイルを移動しました。`glob` loader は `src/data/` 配下を参照します。

### render() の変更

```typescript
// Before
const { Content } = await post.render();

// After
import { render } from "astro:content";
const { Content } = await render(post);
```

## Step 4: Tailwind CSS v4 移行

これが最もハマりポイントが多かった部分です。

### tailwind.config.cjs の削除

Tailwind v4 では設定ファイルが不要になり、CSS 内の `@theme` ディレクティブで設定します。

```css
/* src/styles/global.css */
@import "tailwindcss";
@import "./typography.css";

@custom-variant dark (&:where([data-theme=dark], [data-theme=dark] *));

:root,
html[data-theme="light"] {
  --color-fill: 251, 254, 251;
  --color-text-base: 40, 39, 40;
  --color-accent: 0, 108, 172;
  /* ... */
}

@theme inline {
  --font-mono: "Noto Sans JP", sans-serif;
  --color-skin-fill: rgb(var(--color-fill));
  --color-skin-text-base: rgb(var(--color-text-base));
  --color-skin-accent: rgb(var(--color-accent));
  /* ... */
}
```

### withOpacity() ヘルパーの廃止

v3 では `rgba(var(--color), opacity)` のために `withOpacity()` ヘルパーが必要でしたが、v4 では不要です。Tailwind v4 の opacity modifier（`bg-skin-accent/70` など）をそのまま使えます。

### @apply でのハマり: scoped style と @reference

**これが最大のハマりポイントでした。**

Tailwind v4 では、Astro コンポーネントの `<style>` ブロック内で `@apply` を使う場合、`@reference` ディレクティブが必要です。

```astro
<style>
@reference "../styles/global.css";
  .my-class {
    @apply flex items-center max-w-4xl;
  }
</style>
```

`@reference` がないと `Cannot apply unknown utility class` エラーになります。

### scoped style の詳細度問題

Astro のスコープ付きスタイルは `[data-astro-cid-xxx]` 属性セレクタで詳細度が上がります。そのため、要素の `class` 属性に書いた Tailwind ユーティリティ（例: `sm:flex`）がスコープ付きスタイルの `@apply grid` に負けてしまいます。

```astro
<!-- このケースでは sm:flex がスコープ付きの grid に負ける -->
<ul class="sm:flex">...</ul>

<style>
@reference "../styles/global.css";
  nav ul {
    @apply grid grid-cols-2;
    /* sm:flex をここに書く必要がある */
    @apply sm:flex;
  }
</style>
```

**対策**: レスポンシブ切り替えを含むスタイルは、`class` 属性ではなくスコープ付き `<style>` 内にまとめて書く。

### 廃止されたユーティリティ

`border-opacity-50` などの個別 opacity ユーティリティは v4 で削除されました。代わりに modifier を使います。

```css
/* Before */
@apply prose-blockquote:border-l-accent prose-blockquote:border-opacity-50;

/* After */
@apply prose-blockquote:border-l-accent/50;
```

## Step 5: 検索の Pagefind 移行

React + Fuse.js のクライアントサイド検索から、ビルド時インデックス生成の Pagefind に移行しました。

```astro
---
import "@pagefind/default-ui/css/ui.css";
---

<div id="pagefind-search" transition:persist></div>

<script>
  function initSearch() {
    const onIdle = window.requestIdleCallback || (cb => setTimeout(cb, 1));
    onIdle(async () => {
      const { PagefindUI } = await import("@pagefind/default-ui");
      new PagefindUI({
        element: "#pagefind-search",
        showImages: false,
        showSubResults: true,
      });
    });
  }
  initSearch();
  document.addEventListener("astro:after-swap", initSearch);
</script>
```

Pagefind の CSS 変数でサイトのデザインに合わせたスタイリングが可能です。

## Step 6: React コンポーネントの Astro 化

`Card.tsx` と `Datetime.tsx` を `.astro` ファイルに変換しました。これらはサーバーサイドレンダリングのみで十分なため、React が不要でした。

JSX の `className` → Astro の `class` への変更と、`viewTransitionName` の設定方法が異なる点に注意。

```astro
<!-- Astro での view-transition-name 設定 -->
<h2 style={`view-transition-name: ${slugifyStr(title)}`}>
  {title}
</h2>
```

## Step 7: slugify の注意点

AstroPaper v5 では `slugify` npm パッケージを使用していますが、**日本語タイトルが空文字になる**問題があります。`slugify` パッケージは非ラテン文字を削除するためです。

日本語ブログの場合は `github-slugger` をそのまま使うのが安全です。

```typescript
import { slug as slugger } from "github-slugger";

// github-slugger は日本語をそのまま保持する
slugger("日本語タイトル"); // → "日本語タイトル"

// slugify パッケージは日本語を削除してしまう
slugify("日本語タイトル"); // → ""
```

## Step 8: AWS Amplify デプロイ

既存のビルドスペック（`npm ci` + `npm run build`）はそのまま動作しました。

- **Node.js バージョン**: 20.9.0 のカスタムイメージで Astro 5 に対応
- **ビルドスクリプト**: `npm run build` に Pagefind のインデックス生成が含まれるため、ビルドスペックの変更は不要

## まとめ

移行の難易度は中〜高で、特に Tailwind CSS v4 の scoped style 周りのハマりポイントが多かったです。主なハマりポイント:

1. **`@reference` ディレクティブ** - Astro の `<style>` 内で `@apply` を使うには必須
2. **scoped style の詳細度** - ユーティリティクラスより高くなるため、レスポンシブ切り替えは scoped style 側に書く
3. **`slugify` パッケージと日本語** - 日本語タイトルが空文字になるため `github-slugger` を使う
4. **Satori の JSX** - React を削除しても OG 画像生成のために `react` + `@types/react` が必要
5. **廃止ユーティリティ** - `border-opacity-*` 等は modifier 形式に置き換え

468件の記事を持つブログでも問題なく移行でき、ビルド・デプロイまで一発で成功しました。
