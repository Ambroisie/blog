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
