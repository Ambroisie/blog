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

### Insertion

To insert a new `key` into the tree, we identify which leaf position it should
be inserted at. We then generate the node's priority, insert it at this
position, and rotate the node upwards until the heap property is respected.

```python
type ChildField = Literal["left, right"]

def insert(self, key: K, value: V) -> bool:
    # Empty treap base-case
    if self._root is None:
        self._root = Node(key, value)
        # Signal that we're not overwriting the value
        return False
    # Keep track of the parent chain for rotation after insertion
    parents = []
    node = self._root
    while node is not None:
        # Insert a pre-existing key
        if node.key == key:
            node.value = value
            return True
        #  Go down the tree, keep track of the path through the tree
        field = "left" if key < node.key else "right"
        parents.append((node, field))
        node = getattr(node, field)
    #  Key wasn't found, we're inserting a new node
    child = Node(key, value)
    parent, field = parents[-1]
    setattr(parent, field, child)
    # Rotate the new node up until we respect the decreasing priority property
    self._rotate_up(child, parents)
    # Key wasn't found, signal that we inserted a new node
    return False

def _rotate_up(
    self,
    node: Node[K, V],
    parents: list[tuple[Node[K, V], ChildField]],
) -> None:
    while parents:
        parent, field = parents.pop()
        # If the parent has higher priority, we're done rotating
        if parent.priority >= node.priority:
            break
        # Check for grand-parent/root of tree edge-case
        if parents:
            # Update grand-parent to point to the new rotated node
            grand_parent, field = parents[-1]
            setattr(grand_parent, field, node)
        else:
            # Point the root to the new rotated node
            self._root = node
        other_field = "left" if field == "right" else "right"
        # Rotate the node up
        setattr(parent, field, getattr(node, other_field))
        setattr(node, other_field, parent)
```
