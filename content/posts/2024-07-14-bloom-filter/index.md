---
title: "Bloom Filter"
date: 2024-07-14T17:46:40+01:00
draft: false # I don't care for draft mode, git has branches for that
description: "Probably cool"
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

The [_Bloom Filter_][wiki] is a probabilistic data structure for set membership.

The filter can be used as an inexpensive first step when querying the actual
data is quite costly (e.g: as a first check for expensive cache lookups or large
data seeks).

[wiki]: https://en.wikipedia.org/wiki/Bloom_filter

<!--more-->

## What does it do?

A _Bloom Filter_ can be understood as a hash-set which can either tell you:

* An element is _not_ part of the set.
* An element _may be_ part of the set.

More specifically, one can tweak the parameters of the filter to make it so that
the _false positive_ rate of membership is quite low.

I won't be going into those calculations here, but they are quite trivial to
compute, or one can just look up appropriate values for their use case.

## Implementation

I'll be using Python, which has the nifty ability of representing bitsets
through its built-in big integers quite easily.

We'll be assuming a `BIT_COUNT` of 64 here, but the implementation can easily be
tweaked to use a different number, or even change it at construction time.

### Representation

A `BloomFilter` is just a set of bits and a list of hash functions.

```python
BIT_COUNT = 64

class BloomFilter[T]:
    _bits: int
    _hash_functions: list[Callable[[T], int]]

    def __init__(self, hash_functions: list[Callable[[T], int]]) -> None:
        # Filter is initially empty
        self._bits = 0
        self._hash_functions = hash_functions
```

### Inserting a key

To add an element to the filter, we take the output from each hash function and
use that to set a bit in the filter. This combination of bit will identify the
element, which we can use for lookup later.

```python
def insert(self, val: T) -> None:
    # Iterate over each hash
    for f in self._hash_functions:
        n = f(val) % BIT_COUNT
        # Set the corresponding bit
        self._bit |= 1 << n
```

### Querying a key

Because the _Bloom Filter_ does not actually store its elements, but some
derived data from hashing them, it can only definitely say if an element _does
not_ belong to it. Otherwise, it _may_ be part of the set, and should be checked
against the actual underlying store.

```python
def may_contain(self, val: T) -> bool:
    for f in self._hash_functions:
        n = f(val) % BIT_COUNT
        # If one of the bits is unset, the value is definitely not present
        if not (self._bit & (1 << n)):
            return False
    # All bits were matched, `val` is likely to be part of the set
    return True
```
