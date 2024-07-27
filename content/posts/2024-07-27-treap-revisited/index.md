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

## Implementation

All operations on the tree will be implemented in terms of two fundamental
operations: `split` and `merge`.

We'll be reusing the same structures as in the last post, so let's skip straight
to implementing those fundaments, and building on them for `insert` and
`delete`.

### Split

Splitting a tree means taking a key, and getting the following output:

* a `left` node, root of the tree of all keys lower than the input.
* an extracted `node` which corresponds to the input `key`.
* a `right` node, root of the tree of all keys higher than the input.

```python
type OptionalNode[K, V] = Node[K, V] | None

class SplitResult(NamedTuple):
    left: OptionalNode
    node: OptionalNode
    right: OptionalNode

def split(root: OptionalNode[K, V], key: K) -> SplitResult:
    # Base case, empty tree
    if root is None:
        return SplitResult(None, None, None)
    # If we found the key, simply extract left and right
    if root.key == key:
        left, right = root.left, root.right
        root.left, root.right = None, None
        return SplitResult(left, root, right)
    # Otherwise, recurse on the corresponding side of the tree
    if root.key < key:
        left, node, right = split(root.right, key)
        root.right = left
        return SplitResult(root, node, right)
    if key < root.key:
        left, node, right = split(root.left, key)
        root.left = right
        return SplitResult(left, node, root)
    raise RuntimeError("Unreachable")
```

### Merge

Merging a `left` and `right` tree means (cheaply) building a new tree containing
both of them. A pre-condition for merging is that the `left` tree is composed
entirely of nodes that are lower than any key in `right` (i.e: as in `left` and
`right` after a `split`).

```python
def merge(
    left: OptionalNode[K, V],
    right: OptionalNode[K, V],
) -> OptionalNode[K, V]:
    # Base cases, left or right being empty
    if left is None:
        return right
    if right is None:
        return left
    # Left has higher priority, it must become the root node
    if left.priority >= right.priority:
        # We recursively reconstruct its right sub-tree
        left.right = merge(left.right, right)
        return left
    # Right has higher priority, it must become the root node
    if left.priority < right.priority:
        # We recursively reconstruct its left sub-tree
        right.left = merge(left, right.left)
        return right
    raise RuntimeError("Unreachable")
```

### Insertion

Inserting a node into the tree is done in two steps:

1. `split` the tree to isolate the middle insertion point
2. `merge` it back up to form a full tree with the inserted key

```python
def insert(self, key: K, value: V) -> bool:
    # `left` and `right` come before/after the key
    left, node, right = split(self._root, key)
    was_updated: bool
    # Create the node, or update its value, if the key was already in the tree
    if node is None:
        node = Node(key, value)
        was_updated = False
    else:
        node.value = value
        was_updated = True
    # Rebuild the tree with a couple of merge operations
    self._root = merge(left, merge(node, right))
    # Signal whether the key was already in the key
    return was_updated
```

### Removal

Removing a key from the tree is similar to inserting a new key, and forgetting
to insert it back: simply `split` the tree and `merge` it back without the
extracted middle node.

```python
def remove(self, key: K) -> bool:
    # `node` contains the key, or `None` if the key wasn't in the tree
    left, node, right = split(self._root, key)
    # Put the tree back together, without the extract node
    self._root = merge(left, right)
    # Signal whether `key` was mapped in the tree
    return node is not None
```
