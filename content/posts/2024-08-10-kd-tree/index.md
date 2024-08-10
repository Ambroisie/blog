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

### Closest points

Now to look at the most interesting operation one can do on a _k-d Tree_:
querying for the objects which are closest to a given point (i.e: the [Nearest
neighbour search][nns].

This is a more complicated algorithm, which will also need some modifications to
current _k-d Tree_ implementation in order to track just a bit more information
about the points it contains.

[nns]: https://en.wikipedia.org/wiki/Nearest_neighbor_search

#### A notion of distance

To search for the closest points to a given origin, we first need to define
which [distance](https://en.wikipedia.org/wiki/Distance) we are using in our
space.

For this example, we'll simply be using the usual definition of [(Euclidean)
distance][euclidean-distance].

[euclidean-distance]: https://en.wikipedia.org/wiki/Euclidean_distance

```python
def dist(point: Point, other: Point) -> float:
    return sqrt(sum((a - b) ** 2 for a, b in zip(self, other)))
```

#### Tracking the tree's boundaries

To make the query efficient, we'll need to track the tree's boundaries: the
bounding box of all points contained therein. This will allow us to stop the
search early once we've found enough points and can be sure that the rest of the
tree is too far away to qualify.

For this, let's define the `AABB` (Axis-Aligned Bounding Box) class.

```python
class Point(NamedTuple):
    # Convenience function to replace the coordinate along a given dimension
    def replace(self, axis: Axis, new_coord: float) -> Point:
        coords = list(self)
        coords[axis] = new_coord
        return Point(coords)

class AABB(NamedTuple):
    # Lowest coordinates in the box
    low: Point
    # Highest coordinates in the box
    high: Point

    # An empty box
    @classmethod
    def empty(cls) -> AABB:
        return cls(
            Point(*(float("inf"),) * 3),
            Point(*(float("-inf"),) * 3),
        )

    # Split the box into two along a given axis for a given mid-point
    def split(axis: Axis, mid: float) -> tuple[AABB, AABB]:
        assert self.low[axis] <= mid <= self.high[axis]
        return (
            AABB(self.low, self.high.replace(axis, mid)),
            AABB(self.low.replace(axis, mid), self.high),
        )

    # Extend a box to contain a given point
    def extend(self, point: Point) -> None:
        low = NamedTuple(*(map(min, zip(self.low, point))))
        high = NamedTuple(*(map(max, zip(self.high, point))))
        return AABB(low, high)

    # Return the shortest between a given point and the box
    def dist_to_point(self, point: Point) -> float:
        deltas = (
            max(self.low[axis] - point[axis], 0, point[axis] - self.high[axis])
            for axis in Axis
        )
        return dist(Point(0, 0, 0), Point(*deltas))
```

And do the necessary modifications to the `KdTree` to store the bounding box and
update it as we add new points.

```python
class KdTree[T]:
    _root: KdNode[T]
    # New field: to keep track of the tree's boundaries
    _aabb: AABB

    def __init__(self):
        self._root = KdNode()
        # Initialize the empty tree with an empty bounding box
        self._aabb = AABB.empty()

    def insert(self, point: Point, val: T) -> bool:
        # Extend the AABB for our k-d Tree when adding a point to it
        self._aabb = self._aabb.extend(point)
        return self._root.insert(point, val, Axis.X)
```

#### `MaxHeap`

Python's builtin [`heapq`][heapq] module provides the necessary functions to
create and interact with a [_Priority Queue_][priority-queue], in the form of a
[_Binary Heap_][binary-heap].

Unfortunately, Python's library maintains a _min-heap_, which keeps the minimum
element at the root. For this algorithm, we're interested in having a
_max-heap_, with the maximum at the root.

Thankfully, one can just reverse the comparison function for each element to
convert between the two. Let's write a `MaxHeap` class making use of this
library, with a `Reverse` wrapper class to reverse the order of elements
contained within it (similar to [Rust's `Reverse`][reverse]).

[binary-heap]: https://en.wikipedia.org/wiki/Binary_heap
[heapq]: https://docs.python.org/3/library/heapq.html
[priority-queue]: https://en.wikipedia.org/wiki/Priority_queue
[reverse]: https://doc.rust-lang.org/std/cmp/struct.Reverse.html

```python
# Reverses the wrapped value's ordering
@functools.total_ordering
class Reverse[T]:
    value: T

    def __init__(self, value: T):
        self.value = value

    def __lt__(self, other: Reverse[T]) -> bool:
        return self.value > other.value

    def __eq__(self, other: Reverse[T]) -> bool:
        return self.value == other.value

class MaxHeap[T]:
    _heap: list[Reverse[T]]

    def __init__(self):
        self._heap = []

    def __len__(self) -> int:
        return len(self._heap)

    def __iter__(self) -> Iterator[T]:
        yield from (item.value for item in self._heap)

    # Push a value on the heap
    def push(self, value: T) -> None:
        heapq.heappush(self._heap, Reverse(value))

    # Peek at the current maximum value
    def peek(self) -> T:
        return self._heap[0].value

    # Pop and return the highest value
    def pop(self) -> T:
        return heapq.heappop(self._heap).value

    # Pushes a value onto the heap, pops and returns the highest value
    def pushpop(self, value: T) -> None:
        return heapq.heappushpop(self._heap, Reverse(value)).value
```

#### The actual Implementation

Now that we have written the necessary building blocks, let's tackle the
Implementation of `closest` for our _k-d Tree_.

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
        # Create the output heap
        res = MaxHeap()
        # Recurse onto the root node
        self._root.closest(point, res, n, self._aabb)
        # Return the resulting list, from closest to farthest
        return sorted(res)

class KdNode[T]:
    def closest(
        self,
        point: Point,
        out: MaxHeap[ClosestPoint[T]],
        n: int,
        bounds: AABB,
    ) -> None:
        # Forward to the wrapped node
        self.inner.closest(point, out, n, bounds)

class KdLeafNode[T]:
    def closest(
        self,
        point: Point,
        out: MaxHeap[ClosestPoint[T]],
        n: int,
        bounds: AABB,
    ) -> None:
        # At the leaf, simply iterate over all points and add them to the heap
        for p, val in self.points.items():
            item = ClosestPoint(p, val, dist(p, point))
            if len(out) < n:
                # If the heap isn't full, just push
                out.push(item)
            elif out.peek().distance > item.distance:
                # Otherwise, push and pop to keep the heap at `n` elements
                out.pushpop(item)

class KdSplitNode[T]:
    def closest(
        self,
        point: Point,
        out: list[ClosestPoint[T]],
        n: int,
        bounds: AABB,
    ) -> None:
        index = self._index(point)
        children_bounds = bounds.split(self.axis, self.mid)
        # Iterate over the child which contains the point, then its neighbour
        for i in (index, 1 - index):
            child, bounds = self.children[i], children_bounds[i]
            # `min_dist` is 0 for the first child, and the minimum distance of
            # all points contained in the second child
            min_dist = bounds.dist_to_point(point)
            # If the heap is at capacity and the child to inspect too far, stop
            if len(out) == n and min_dist > out.peek().distance:
                return
            # Otherwise, recurse
            child.closest(point, out, n, bounds)
```
