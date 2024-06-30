---
title: "Trie"
date: 2024-06-30T11:07:49+01:00
draft: false # I don't care for draft mode, git has branches for that
description: "A cool map"
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

This time, let's talk about the [_Trie_][wiki], which is a tree-based mapping
structure most often used for string keys.

[wiki]: https://en.wikipedia.org/wiki/Trie

<!--more-->

## What does it do?

A _Trie_ can be used to map a set of string keys to their corresponding values,
without the need for a hash function. This also means you won't suffer from hash
collisions, though the tree-based structure will probably translate to slower
performance than a good hash table.

A _Trie_ is especially useful to represent a dictionary of words in the case of
spell correction, as it can easily be used to fuzzy match words under a given
edit distance (think [Levenshtein distance])

[Levenshtein distance]: https://en.wikipedia.org/wiki/Levenshtein_distance

## Implementation

This implementation will be in Python for exposition purposes, even though
it already has a built-in `dict`.

### Representation

Creating a new `Trie` is easy: the root node starts off empty and without any
mapped values.

```python
class Trie[T]:
    _children: dict[str, Trie[T]]
    _value: T | None

    def __init__(self):
        # Each letter is mapped to a Trie
        self._children = defaultdict(Trie)
        # If we match a full string, we store the mapped value
        self._value = None
```

We're using a `defaultdict` for the children for ease of implementation in this
post. In reality, I would encourage you exit early when you can't match a given
character.

The string key will be implicit by the position of a node in the tree: the empty
string at the root, one-character strings as its direct children, etc...
