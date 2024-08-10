---
title: "k-d Tree"
date: 2024-08-10T11:50:33+01:00
draft: false # I don't care for draft mode, git has branches for that
description: "Points in spaaaaace!"
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

The [_k-d Tree_][wiki] is a useful way to map points in space and make them
efficient to query.

I ran into them during my studies in graphics, as they are one of the
possible acceleration structures for [ray-casting] operations.

[wiki]: https://en.wikipedia.org/wiki/K-d_tree
[ray-casting]: https://en.wikipedia.org/wiki/Ray_casting

<!--more-->

## Implementation

As usual, this will be in Python, though its lack of proper discriminated enums
makes it more verbose than would otherwise be necessary.

### Pre-requisites

Let's first define what kind of space our _k-d Tree_ is dealing with. In this
instance $k = 3$ just like in the normal world.

```python
class Point(NamedTuple):
    x: float
    y: float
    z: float

class Axis(IntEnum):
    X = 0
    Y = 1
    Z = 2

    def next(self) -> Axis:
        # Each level of the tree is split along a different axis
        return Axis((self + 1) % 3)
```

### Representation

The tree is represented by `KdTree`, each of its leaf nodes is a `KdLeafNode`
and its inner nodes are `KdSplitNode`s.

For each point in space, the tree can also keep track of an associated value,
similar to a dictionary or other mapping data structure. Hence we will make our
`KdTree` generic to this mapped type `T`.

#### Leaf node

A leaf node contains a number of points that were added to the tree. For each
point, we also track their mapped value, hence the `dict[Point, T]`.

```python
class KdLeafNode[T]:
    points: dict[Point, T]

    def __init__(self):
        self.points = {}
```

#### Split node

An inner node must partition the space into two sub-spaces along a given axis
and mid-point (thus defining a plane). All points that are "to the left" of the
plane will be kept in one child, while all the points "to the right" will be in
the other. Similar to a [_Binary Search Tree_][bst]'s inner nodes.

[bst]: https://en.wikipedia.org/wiki/Binary_search_tree

```python
class KdSplitNode[T]:
    axis: Axis
    mid: float
    children: tuple[KdTreeNode[T], KdTreeNode[T]]

    # Convenience function to index into the child which contains `point`
    def _index(self, point: Point) -> int:
        return 0 if point[self.axis] <= self.mid else 1
```

#### Tree

The tree itself is merely a wrapper around its inner nodes.

Once annoying issue about writing this in Python is the lack of proper
discriminated enum types. So we need to create a wrapper type for the nodes
(`KdNode`) to allow for splitting when updating the tree.

```python
class KdNode[T]:
    # Wrapper around leaf/inner nodes, the poor man's discriminated enum
    inner: KdLeafNode[T] | KdSplitNode[T]

    def __init__(self):
        self.inner = KdLeafNode()

    # Convenience constructor used when splitting a node
    @classmethod
    def from_items(cls, items: Iterable[tuple[Point, T]]) -> KdNode[T]:
        res = cls()
        res.inner.points.update(items)
        return res

class KdTree[T]:
    _root: KdNode[T]

    def __init__(self):
        # Tree starts out empty
        self._root = KdNode()
```
