---
title: "Gap Buffer"
date: 2024-07-06T21:27:19+01:00
draft: false # I don't care for draft mode, git has branches for that
description: "As featured in GNU Emacs"
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

The [_Gap Buffer_][wiki] is a popular data structure for text editors to
represent files and editable buffers. The most famous of them probably being
[GNU Emacs][emacs].

[wiki]: https://en.wikipedia.org/wiki/Gap_buffer
[emacs]: https://www.gnu.org/software/emacs/manual/html_node/elisp/Buffer-Gap.html

<!--more-->

## What does it do?

A _Gap Buffer_ is simply a list of characters, similar to a normal string, with
the added twist of splitting it into two side: the prefix and suffix, on either
side of the cursor. In between them, a gap is left to allow for quick
insertion at the cursor.

Moving the cursor moves the gap around the buffer, the prefix and suffix getting
shorter/longer as required.

## Implementation

I'll be writing a sample implementation in Python, as with the rest of the
[series]({{< ref "/series/cool-algorithms/">}}). I don't think it showcases the
elegance of the _Gap Buffer_ in action like a C implementation full of
`memmove`s would, but it does makes it short and sweet.

### Representation

We'll be representing the gap buffer as an actual list of characters.

Given that Python doesn't _have_ characters, let's settle for a list of strings,
each representing a single character...

```python
Char = str

class GapBuffer:
    # List of characters, contains prefix and suffix of string with gap in the middle
    _buf: list[Char]
    # The gap is contained between [start, end) (i.e: buf[start:end])
    _gap_start: int
    _gap_end: int

    # Visual representation of the gap buffer:
    # This is a very  [                     ]long string.
    # |<----------------------------------------------->| capacity
    # |<------------>|                       |<-------->| string
    #                 |<------------------->|             gap
    # |<------------>|                                    prefix
    #                                        |<-------->| suffix
    def __init__(self, initial_capacity: int = 16) -> None:
        assert initial_capacity > 0
        # Initialize an empty gap buffer
        self._buf = [""] * initial_capacity
        self._gap_start = 0
        self._gap_end = initial_capacity
```

### Accessors

I'm mostly adding these for exposition, and making it easier to write `assert`s
later.

```python
@property
def capacity(self) -> int:
  return len(self._buf)

@property
def gap_length(self) -> int:
  return self._gap_end - self._gap_start

@property
def string_length(self) -> int:
  return self.capacity - self.gap_length

@property
def prefix_length(self) -> int:
  return self._gap_start

@property
def suffix_length(self) -> int:
  return self.capacity - self._gap_end
```
