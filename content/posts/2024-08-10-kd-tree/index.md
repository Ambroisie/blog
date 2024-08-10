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

### Inserting a point

To add a point to the tree, we simply recurse from node to node, similar to a
_BST_'s insertion algorithm. Once we've found the correct leaf node to insert
our point into, we simply do so.

If that leaf node goes over the maximum number of points it can store, we must
then split it along an axis, cycling between `X`, `Y`, and `Z` at each level of
the tree (i.e: splitting along the `X` axis on the first level, then `Y` on the
second, then `Z` after that, and then `X`, etc...).

```python
# How many points should be stored in a leaf node before being split
MAX_CAPACITY = 32

def median(values: Iterable[float]) -> float:
    sorted_values = sorted(values)
    mid_point = len(sorted_values) // 2
    if len(sorted_values) % 2 == 1:
        return sorted_values[mid_point]
    a, b = sorted_values[mid_point], sorted_values[mid_point + 1]
    return a + (b - a) / 2

def partition[T](
    pred: Callable[[T], bool],
    iterable: Iterable[T]
) -> tuple[list[T], list[T]]:
    truths, falses = [], []
    for v in iterable:
        (truths if pred(v) else falses).append(v)
    return truths, falses

def split_leaf[T](node: KdLeafNode[T], axis: Axis) -> KdSplitNode[T]:
    # Find the median value for the given axis
    mid = median(p[axis] for p in node.points)
    # Split into left/right children according to the mid-point and axis
    left, right = partition(lambda kv: kv[0][axis] <= mid, node.points.items())
    return KdSplitNode(
        split_axis,
        mid,
        (KdNode.from_items(left), KdNode.from_items(right)),
    )

class KdTree[T]:
    def insert(self, point: Point, val: T) -> bool:
        # Forward to the root node, choose `X` as the first split axis
        return self._root.insert(point, val, Axis.X)

class KdLeafNode[T]:
    def insert(self, point: Point, val: T, split_axis: Axis) -> bool:
        # Check whether we're overwriting a previous value
        was_mapped = point in self.points
        # Store the corresponding value
        self.points[point] = val
        # Return whether we've performed an overwrite
        return was_mapped

class KdSplitNode[T]:
    def insert(self, point: Point, val: T, split_axis: Axis) -> bool:
        # Find the child which contains the point
        child = self.children[self._index(point)]
        # Recurse into it, choosing the next split axis
        return child.insert(point, val, split_axis.next())

class KdNode[T]:
    def insert(self, point: Point, val: T, split_axis: Axis) -> bool:
        # Add the point to the wrapped node...
        res = self.inner.insert(point, val, split_axis)
        # ... And take care of splitting leaf nodes when necessary
        if (
            isinstance(self.inner, KdLeafNode)
            and len(self.inner.points) > MAX_CAPACITY
        ):
            self.inner = split_leaf(self.inner, split_axis)
        return res
```

### Searching for a point

Looking for a given point in the tree look very similar to a _BST_'s search,
each leaf node dividing the space into two sub-spaces, only one of which
contains the point.

```python
class KdTree[T]:
    def lookup(self, point: Point) -> T | None:
        # Forward to the root node
        return self._root.lookup(point)

class KdNode[T]:
    def lookup(self, point: Point) -> T | None:
        # Forward to the wrapped node
        return self.inner.lookup(point)

class KdLeafNode[T]:
    def lookup(self, point: Point) -> T | None:
        # Simply check whether we've stored the point in this leaf
        return self.points.get(point)

class KdSplitNode[T]:
    def lookup(self, point: Point) -> T | None:
        # Recurse into the child which contains the point
        return self.children[self._index(point)].lookup(point)
```
