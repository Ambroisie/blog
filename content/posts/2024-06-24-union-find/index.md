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

To kickoff the [series]({{< ref "/series/cool-algorithms/">}}) of posts about
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
