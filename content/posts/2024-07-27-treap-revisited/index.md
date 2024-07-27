---
title: "Treap, revisited"
date: 2024-07-27T14:12:27+01:00
draft: false # I don't care for draft mode, git has branches for that
description: "An even simpler BST"
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
---

My [last post]({{< relref "../2024-07-20-treap/index.md" >}}) about the _Treap_
showed an implementation using tree rotations, as is commonly done with [AVL
Trees][avl] and [Red Black Trees][rb].

But the _Treap_ lends itself well to a simple and elegant implementation with no
tree rotations. This makes it especially easy to implement the removal of a key,
rather than the fiddly process of deletion using tree rotations.

[avl]: https://en.wikipedia.org/wiki/AVL_tree
[rb]: https://en.wikipedia.org/wiki/Red%E2%80%93black_tree

<!--more-->
