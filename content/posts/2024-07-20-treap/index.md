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

## What does it do?

By randomizing the priority value of each key at insertion time, we ensure a
high likelihood that the tree stays _roughly_ balanced, avoiding degenerating to
unbalanced O(N) height.

Here's a sample tree created by inserting integers from 0 to 250 into the tree:

{{< graphviz file="treap.gv" />}}

## Implementation

I'll be keeping the theme for this [series] by using Python to implement the
_Treap_. This leads to somewhat annoying code to handle the rotation process,
which is easier to do in C using pointers.

[series]: {{< ref "/series/cool-algorithms/" >}}

### Representation

Creating a new `Treap` is easy: the tree starts off empty, waiting for new nodes
to insert.

Each `Node` must keep track of the `key`, the mapped `value`, and the node's
`priority` (which is assigned randomly). Finally it must also allow for storing
two children (`left` and `right`).

```python
class Node[K, V]:
    key: K
    value: V
    priority: float
    left: Node[K, V] | None
    righg: Node[K, V] | None

    def __init__(self, key: K, value: V):
        # Store key and value, like a normal BST node
        self.key = key
        self.value = value
        # Priority is derived randomly
        self.priority = random()
        self.left = None
        self.right = None

class Treap[K, V]:
    _root: Node[K, V] | None

    def __init__(self):
        # The tree starts out empty
        self._root = None
```

### Search

Searching the tree is the same as in any other _Binary Search Tree_.

```python
def get(self, key: K) -> T | None:
    node = self._root
    # The usual BST traversal
    while node is not None:
        if node.key == key:
            return node.value
        elif node.key < key:
            node = node.right
        else:
            node = node.left
    return None
```
