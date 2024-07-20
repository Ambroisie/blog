---
title: "Treap"
date: 2024-07-20T14:12:27+01:00
draft: false # I don't care for draft mode, git has branches for that
description: "A simpler BST"
tags:
  - algorithms
  - data structures
  - python
categories:
  - programming
series:
  - Cool algorithms
favorite: false
disable_feed: false
graphviz: true
---

The [_Treap_][wiki] is a mix between a _Binary Search Tree_ and a _Heap_.

Like a _Binary Search Tree_, it keeps an ordered set of keys in the shape of a
tree, allowing for binary search traversal.

Like a _Heap_, it associates each node with a priority, making sure that a
parent's priority is always higher than any of its children.

[wiki]: https://en.wikipedia.org/wiki/Treap

<!--more-->
