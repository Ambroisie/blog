---
title: "Union Find"
date: 2024-06-24T21:07:49+01:00
draft: false # I don't care for draft mode, git has branches for that
description: "My favorite data structure"
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

To kickoff the [series]({{< ref "/series/cool-algorithms/" >}}) of posts about
algorithms and data structures I find interesting, I will be talking about my
favorite one: the [_Disjoint Set_][wiki]. Also known as the _Union-Find_ data
structure, so named because of its two main operations: `ds.union(lhs, rhs)` and
`ds.find(elem)`.

[wiki]: https://en.wikipedia.org/wiki/Disjoint-set_data_structure

<!--more-->

## What does it do?

The _Union-Find_ data structure allows one to store a collection of sets of
elements, with operations for adding new sets, merging two sets into one, and
finding the representative member of a set. Not only does it do all that, but it
does it in almost constant (amortized) time!

Here is a small motivating example for using the _Disjoint Set_ data structure:

```python
def connected_components(graph: Graph) -> list[set[Node]]:
    # Initialize the disjoint set so that each node is in its own set
    ds: DisjointSet[Node] = DisjointSet(graph.nodes)
    # Each edge is a connection, merge both sides into the same set
    for (start, dest) in graph.edges:
        ds.union(start, dest)
    # Connected components share the same (arbitrary) root
    components: dict[Node, set[Node]] = defaultdict(set)
    for n in graph.nodes:
        components[ds.find(n)].add(n)
    # Return a list of disjoint sets corresponding to each connected component
    return list(components.values())
```

## Implementation

I will show how to implement `UnionFind` for integers, though it can easily be
extended to be used with arbitrary types (e.g: by mapping each element
one-to-one to a distinct integer, or using a different set representation).

### Representation

Creating a new disjoint set is easy enough:

```python
class UnionFind:
    _parent: list[int]
    _rank: list[int]

    def __init__(self, size: int):
        # Each node is in its own set, making it its own parent...
        self._parents = list(range(size))
        # ... And its rank 0
        self._rank = [0] * size
```

We represent each set through the `_parent` field: each element of the set is
linked to its parent, until the root node which is its own parent. When first
initializing the structure, each element is in its own set, so we initialize
each element to be a root and make it its own parent (`_parent[i] == i` for all
`i`).

The `_rank` field is an optimization which we will touch on in a later section.

### Find

A naive Implementation of `find(...)` is simple enough to write:

```python
def find(self, elem: int) -> int:
    # If `elem` is its own parent, then it is the root of the tree
    if (parent := self._parent[elem]) == elem:
        return elem
    # Otherwise, recurse on the parent
    return self.find(parent)
```

However, going back up the chain of parents each time we want to find the root
node (an `O(n)` operation) would make for disastrous performance. Instead we can
do a small optimization called _path splitting_.

```python
def find(self, elem: int) -> int:
    while (parent := self._parent[elem]) != elem:
        # Replace each parent link by a link to the grand-parent
        elem, self._parent[elem] = parent, self._parent[parent]
    return elem
```

This flattens the chain so that each node links more directly to the root (the
length is reduced by half), making each subsequent `find(...)` faster.

Other compression schemes exist, along the spectrum between faster shortening
the chain faster earlier, or updating `_parent` fewer times per `find(...)`.

### Union

A naive implementation of `union(...)` is simple enough to write:

```python
def union(self, lhs: int, rhs: int) -> int:
    # Replace both element by their root parent
    lhs = self.find(lhs)
    rhs = self.find(rhs)
    # arbitrarily merge one into the other
    self._parent[rhs] = lhs
    # Return the new root
    return lhs
```

Once again, improvements can be made. Depending on the order in which we call
`union(...)`, we might end up creating a long chain from the leaf of the tree to
the root node, leading to slower `find(...)` operations. If at all possible, we
would like to keep the trees as shallow as possible.

To do so, we want to avoid merging taller trees into smaller ones, so as to keep
them as balanced as possible. Since a higher tree will result in a slower
`find(...)`, keeping the trees balanced will lead to increased performance.

This is where the `_rank` field we mentioned earlier comes in: the _rank_ of an
element is an upper bound on its height in the tree. By keeping track of this
_approximate_ height, we can keep the trees balanced when merging them.

```python
def union(self, lhs: int, rhs: int) -> int:
    lhs = self.find(lhs)
    rhs = self.find(rhs)
    # Bail out early if they already belong to the same set
    if lhs == rhs:
      return lhs
    # Always keep `lhs` as the taller tree
    if (self._rank[lhs] < self._rank[rhs])
        lhs, rhs = rhs, lhs
    # Merge the smaller tree into the taller one
    self._parent[rhs] = lhs
    # Update the rank when merging trees of approximately the same size
    if self._rank[lhs] == self._rank[rhs]:
        self._rank[lhs] += 1
    return lhs
```
