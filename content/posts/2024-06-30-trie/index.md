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

### Search

An exact match look-up is easily done: we go down the tree until we've exhausted
the key. At that point we've either found a mapped value or not.

```python
def get(self, key: str) -> T | None:
    # Have we matched the full key?
    if not key:
        # Store the `T` if mapped, `None` otherwise
        return self._value
    # Otherwise, recurse on the child corresponding to the first letter
    return self._children[key[0]].get(key[1:])
```

### Insertion

Adding a new value to the _Trie_ is similar to a key lookup, only this time we
store the new value instead of returning it.

```python
def insert(self, key: str, value: T) -> bool:
    # Have we matched the full key?
    if not key:
        # Check whether we're overwriting a previous mapping
        was_mapped = self._value is None
        # Store the corresponding value
        self._value = value
        # Return whether we've performed an overwrite
        return was_mapped
      # Otherwise, recurse on the child corresponding to the first letter
      return self._children[key[0]].insert(key[1:], value)
```

### Removal

Removal should also look familiar.

```python
def remove(self, key: str) -> bool:
    # Have we matched the full key?
    if not key:
        was_mapped = self._value is None
        # Remove the value
        self._value = None
        # Return whether it was mapped
        return was_mapped
    # Otherwise, recurse on the child corresponding to the first letter
    return self._children[key[0]].remove(key[1:])
```

### Fuzzy matching

Fuzzily matching a given word is where the real difficulty is: the key is to
realize we can use the prefix-tree nature of a _Trie_ to avoid doing wasteful
work.

By leveraging the prefix visit order of the tree, we can build an iterative
Levenshtein distance matrix, in much the same way one would do so in its
[Dynamic Programming] implementation (see the [Wagner-Fisher algorithm]).

[Dynamic Programming]: https://en.wikipedia.org/wiki/Dynamic_programming
[Wagner-Fisher algorithm]: https://en.wikipedia.org/wiki/Wagner%E2%80%93Fischer_algorithm

```python
class FuzzyResult[T](NamedTuple):
    distance: int
    key: str
    value: T


def get_fuzzy(self, key: str, max_distance: int = 0) -> Iterator[FuzzyResult[T]]:
    def helper(
        current_word: str,
        node: Trie[T],
        previous_row: list[int],
    ) -> Iterator[tuple[int, T]]:
        # Iterative Levenshtein
        current_row = [previous_row[0] + 1]
        current_char = current_word[-1]
        for column, key_char in enumerate(key, start=1):
            insertion = current_row[column - 1] + 1
            deletion = previous_row[column] + 1
            replacement = previous_row[column - 1] + (key_char != current_char)
            current_row.append(min(insertion, deletion, replacement))

        # If we are under the max distance, match this node
        if (distance := current_row[-1]) <= max_distance and node._value != None:
            # Only if it has a value of course
            yield FuzzyResult(distance, current_word, node._value)

        # If we can potentially still match children, recurse
        if min(current_row) <= max_distance:
            for c, child in node._children.items():
                yield from helper(current_word + c, child, current_row)

    # Build the first row -- the edit distance from the empty string
    row = list(range(len(key) + 1))

    # Base case for the empty string
    if (distance := row[-1]) <= max_distance and self._value != None:
        yield FuzzyResult(distance, "", self._value)
    for c, child in self._children.items():
        yield from helper(c, child, row)
```
