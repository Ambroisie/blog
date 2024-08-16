---
title: "Kd Tree Revisited"
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
