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
