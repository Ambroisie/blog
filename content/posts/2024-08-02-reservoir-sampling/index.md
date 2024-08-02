---
title: "Reservoir Sampling"
date: 2024-08-02T18:30:56+01:00
draft: false # I don't care for draft mode, git has branches for that
description: "Elegantly sampling a stream"
tags:
  - algorithms
  - python
categories:
  - programming
series:
  - Cool algorithms
favorite: false
disable_feed: false
mathjax: true
---

[_Reservoir Sampling_][reservoir] is an [online][online], probabilistic
algorithm to uniformly sample $k$ random elements out of a stream of values.

It's a particularly elegant and small algorithm, only requiring $\Theta(k)$
amount of space and a single pass through the stream.

[reservoir]: https://en.wikipedia.org/wiki/Reservoir_sampling
[online]: https://en.wikipedia.org/wiki/Online_algorithm

<!--more-->
