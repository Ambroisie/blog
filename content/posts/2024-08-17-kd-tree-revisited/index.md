---
title: "k-d Tree Revisited"
date: 2024-08-17T14:20:22+01:00
draft: false # I don't care for draft mode, git has branches for that
description: "Simplifying the nearest neighbour search"
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

After giving it a bit of thought, I've found a way to simplify the nearest
neighbour search (i.e: the `closest` method) for the `KdTree` I implemented in
[my previous post]({{< relref "../2024-08-10-kd-tree/index.md" >}}).

<!--more-->

## The improvement

That post implemented the nearest neighbour search by keeping track of the
tree's boundaries (through `AABB`), and each of its sub-trees (through
`AABB.split`), and testing for the early exit condition by computing the
distance of the search's origin to each sub-tree's boundaries.

Instead of _explicitly_ keeping track of each sub-tree's boundaries, we can
implicitly compute it when recursing down the tree.

To check for the distance between the queried point and the splitting plane of
inner nodes: we simply need to project the origin onto that plane, thus giving
us a minimal bound on the distance of the points stored on the other side.

This can be easily computed from the `axis` and `mid` values which are stored in
the inner nodes: to project the node on the plane we simply replace its
coordinate for this axis by `mid`.

## Simplified search

With that out of the way, let's now see how `closest` can be implemented without
needing to track the tree's `AABB` at the root:

```python
# Wrapper type for closest points, ordered by `distance`
@dataclasses.dataclass(order=True)
class ClosestPoint[T](NamedTuple):
    point: Point = field(compare=False)
    value: T = field(compare=False)
    distance: float

class KdTree[T]:
    def closest(self, point: Point, n: int = 1) -> list[ClosestPoint[T]]:
        assert n > 0
        res = MaxHeap()
        # Instead of passing an `AABB`, we give an initial projection point,
        # the query origin itself (since we haven't visited any split node yet)
        self._root.closest(point, res, n, point)
        return sorted(res)

class KdNode[T]:
    def closest(
        self,
        point: Point,
        out: MaxHeap[ClosestPoint[T]],
        n: int,
        projection: Point,
    ) -> None:
        # Same implementation
        self.inner.closest(point, out, n, bounds)

class KdLeafNode[T]:
    def closest(
        self,
        point: Point,
        out: MaxHeap[ClosestPoint[T]],
        n: int,
        projection: Point,
    ) -> None:
        # Same implementation
        for p, val in self.points.items():
            item = ClosestPoint(p, val, dist(p, point))
            if len(out) < n:
                out.push(item)
            elif out.peek().distance > item.distance:
                out.pushpop(item)

class KdSplitNode[T]:
    def closest(
        self,
        point: Point,
        out: MaxHeap[ClosestPoint[T]],
        n: int,
        projection: Point,
    ) -> None:
        index = self._index(point)
        self.children[index].closest(point, out, n, projection)
        # Project onto the splitting plane, for a minimum distance to its points
        projection = projection.replace(self.axis, self.mid)
        # If we're at capacity and can't possibly find any closer points, exit
        if len(out) == n and dist(point, projection) > out.peek().distance:
            return
        # Otherwise recurse on the other side to check for nearer neighbours
        self.children[1 - index].closest(point, out, n, projection)
```

As you can see, the main difference is in `KdSplitNode`'s implementation, where
we can quickly compute the minimum distance between the search's origin and all
potential points in that subspace.
