---
author: matac
pubDatetime: 2023-10-27T23:13:24.000Z
title: Cursor Code Editorを使ってみている
postSlug: cursor-editor
featured: false
draft: false
tags:
  - tec
ogImage: ""
description: |
  Cursor Code Editorを使ってみている
_template: blog_post
---

今日の研究室では[Cursor](https://cursor.sh/)というコードエディタが話題になった。
GitHub CopilotのようにAIがコード生成をしてくれるというのが主な機能だ。
Cursorの特徴はインターフェースがVSCode LikeでAI機能を標準搭載しているところだろう。
VSCode Likeとは言ったがほとんどVSCodeだ。
VSCodeの拡張機能もインストールできるし、設定すれば`code`コマンドで呼び出すこともできる。
Cursorを知らない人が見たらほぼ100%VSCodeだと思うだろう。

![](/img/cursor.png)

AIの正体はGPT4だ。
CodeBaseを持っているのでコード全体を把握しているし、`@test-code.c`のように特定のファイルを指定してそれについて問うことも可能だ。もちろんエディタ上でプロンプトを入力すればそれに沿ったコードを記述してくれるし、範囲選択しておけばその範囲についてバグを修正してもらったり追加でコードを書いてもらうことも可能だ。面白いのはターミナルで実行したコマンドがエラーを吐いたときは`Auto Debug`を押すことで修正案を出してくれる。この場合直接コードに書きにいってくれたりはしないのだが、`Auto Debug`と言っているのだからそのうちそこまでできるようになるのかもしれない。

一応無料でもGPT4が使えるが返答がとても遅く実用するにはちょっと辛い。
なのでやはり課金するのが良いと思う。OpenAIのAPI KeyをCursorに登録してあげて使うことも可能だ。
機能的にはVSCodeからCursorに乗り換えても全然問題なさそう。
ただその場合は課金してAIフル活用したいところ。

ちょっと不便なのは一部emacsキーバインドが反応しないところだろうか。
でもそのうち反応するようになりそうな気もする。
CursorからAI要素を抜いた部分、つまりVSCodeな部分では問題なくemacsキーバインドは反応するのでそんなに問題でもないか。

最後にCursorのAIでほとんどを記述した赤黒木のコードを載せておく。
一応コンパイルできて、insertができるところまではみてるがちゃんと動くかはわからない。

```c
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct Node {
  int data;
  struct Node *parent;
  struct Node *left;
  struct Node *right;
  int color;
} Node;

typedef struct RedBlackTree {
  Node *root;
  int (*compare)(int, int);
} RedBlackTree;

void rotateLeft(RedBlackTree *tree, Node *x) {
  Node *y = x->right;
  x->right = y->left;
  if (y->left != NULL)
    y->left->parent = x;
  y->parent = x->parent;
  if (x->parent == NULL)
    tree->root = y;
  else if (x == x->parent->left)
    x->parent->left = y;
  else
    x->parent->right = y;
  y->left = x;
  x->parent = y;
}

void rotateRight(RedBlackTree *tree, Node *x) {
  Node *y = x->left;
  x->left = y->right;
  if (y->right != NULL)
    y->right->parent = x;
  y->parent = x->parent;
  if (x->parent == NULL)
    tree->root = y;
  else if (x == x->parent->right)
    x->parent->right = y;
  else
    x->parent->left = y;
  y->right = x;
  x->parent = y;
}

void insertFix(RedBlackTree *tree, Node *x) {
  Node *parent = NULL;
  Node *grand_parent = NULL;

  while ((x != tree->root) && (x->color != 0) && (x->parent->color == 1)) {
    parent = x->parent;
    grand_parent = x->parent->parent;

    // Case : A. Parent of x is left child of Grand-parent of x
    if (parent == grand_parent->left) {
      Node *uncle = grand_parent->right;

      // Case : 1. The uncle of x is also red. Only Recoloring required
      if (uncle != NULL && uncle->color == 1) {
        grand_parent->color = 1;
        parent->color = 0;
        uncle->color = 0;
        x = grand_parent;
      } else {
        // Case : 2. x is right child of its parent. Left-rotation required
        if (x == parent->right) {
          rotateLeft(tree, parent);
          x = parent;
          parent = x->parent;
        }
        // Case : 3. x is left child of its parent. Right-rotation required
        rotateRight(tree, grand_parent);
        int temp_color = parent->color;
        parent->color = grand_parent->color;
        grand_parent->color = temp_color;
        x = parent;
      }
    } else {
      // Case : B. Parent of x is right child of Grand-parent of x
      Node *uncle = grand_parent->left;

      // Case : 1. The uncle of x is also red. Only Recoloring required
      if ((uncle != NULL) && (uncle->color == 1)) {
        grand_parent->color = 1;
        parent->color = 0;
        uncle->color = 0;
        x = grand_parent;
      } else {
        // Case : 2. x is left child of its parent. Right-rotation required
        if (x == parent->left) {
          rotateRight(tree, parent);
          x = parent;
          parent = x->parent;
        }
        // Case : 3. x is right child of its parent. Left-rotation required
        rotateLeft(tree, grand_parent);
        int temp_color = parent->color;
        parent->color = grand_parent->color;
        grand_parent->color = temp_color;
        x = parent;
      }
    }
  }
  tree->root->color = 0;
}

void deleteFix(RedBlackTree *tree, Node *x) {
  while (x != tree->root && x->color == 0) {
    if (x == x->parent->left) {
      Node *w = x->parent->right;
      if (w->color == 1) {
        w->color = 0;
        x->parent->color = 1;
        rotateLeft(tree, x->parent);
        w = x->parent->right;
      }
      if (w->left->color == 0 && w->right->color == 0) {
        w->color = 1;
        x = x->parent;
      } else {
        if (w->right->color == 0) {
          w->left->color = 0;
          w->color = 1;
          rotateRight(tree, w);
          w = x->parent->right;
        }
        w->color = x->parent->color;
        x->parent->color = 0;
        w->right->color = 0;
        rotateLeft(tree, x->parent);
        x = tree->root;
      }
    } else {
      // Mirror image of above code
      Node *w = x->parent->left;
      if (w->color == 1) {
        w->color = 0;
        x->parent->color = 1;
        rotateRight(tree, x->parent);
        w = x->parent->left;
      }
      if (w->right->color == 0 && w->right->color == 0) {
        w->color = 1;
        x = x->parent;
      } else {
        if (w->left->color == 0) {
          w->right->color = 0;
          w->color = 1;
          rotateLeft(tree, w);
          w = x->parent->left;
        }
        w->color = x->parent->color;
        x->parent->color = 0;
        w->left->color = 0;
        rotateRight(tree, x->parent);
        x = tree->root;
      }
    }
  }
  x->color = 0;
}

Node *createNode(int data) {
  Node *newNode = (Node *)malloc(sizeof(Node));
  newNode->data = data;
  newNode->left = NULL;
  newNode->right = NULL;
  newNode->parent = NULL;
  newNode->color = 1; // New nodes are always red in Red-Black Trees
  return newNode;
}

void insertNode(RedBlackTree *tree, int data) {
  Node *newNode = createNode(data);
  Node *current = tree->root;
  Node *parent = NULL;

  while (current != NULL) {
    parent = current;
    if (tree->compare(data, current->data) < 0)
      current = current->left;
    else
      current = current->right;
  }

  newNode->parent = parent;
  if (parent == NULL)
    tree->root = newNode;
  else if (tree->compare(data, parent->data) < 0)
    parent->left = newNode;
  else
    parent->right = newNode;

  // Fix the tree in case any of the red-black properties have been violated
  insertFix(tree, newNode);
}

Node *findNode(RedBlackTree *tree, int data) {
  Node *current = tree->root;
  while (current != NULL) {
    if (data == current->data)
      return current;
    else if (data < current->data)
      current = current->left;
    else
      current = current->right;
  }
  return NULL;
}

void deleteNode(RedBlackTree *tree, int data) {
  Node *nodeToDelete = findNode(tree, data);
  if (nodeToDelete == NULL) {
    printf("Node not found in the tree.\n");
    return;
  }
  deleteFix(tree, nodeToDelete);
  free(nodeToDelete);
}

RedBlackTree *createRedBlackTree(int (*compare)(int, int)) {
  RedBlackTree *tree = (RedBlackTree *)malloc(sizeof(RedBlackTree));
  tree->root = NULL;
  tree->compare = compare;
  return tree;
}

int main() {
  int (*compare)(int, int);
  RedBlackTree *tree = createRedBlackTree(compare);

  insertNode(tree, 10);
  assert(findNode(tree, 10) != NULL);

  return 0;
}
```
