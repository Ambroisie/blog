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
[series]({{< ref "/series/cool-algorithms/" >}}). I don't think it showcases the
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

### Growing the buffer

I've written this method in a somewhat non-idiomatic manner, to make it closer
to how it would look in C using `realloc` instead.

It would be more efficient to use slicing to insert the needed extra capacity
directly, instead of making a new buffer and copying characters over.

```python
def grow(self, capacity: int) -> None:
    assert capacity >= self.capacity
    # Create a new buffer with the new capacity
    new_buf = [""] * capacity
    # Move the prefix/suffix to their place in the new buffer
    added_capacity = capacity - len(self._buf)
    new_buf[: self._gap_start] = self._buf[: self._gap_start]
    new_buf[self._gap_end + added_capacity :] = self._buf[self._gap_end :]
    # Use the new buffer, account for added capacity
    self._buf = new_buf
    self._gap_end += added_capacity
```

### Insertion

Inserting text at the cursor's position means filling up the gap in the middle
of the buffer. To do so we must first make sure that the gap is big enough, or
grow the buffer accordingly.

Then inserting the text is simply a matter of copying its characters in place,
and moving the start of the gap further right.

```python
def insert(self, val: str) -> None:
    # Ensure we have enough space to insert the whole string
    if len(val) > self.gap_length:
        self.grow(max(self.capacity * 2, self.string_length + len(val)))
    # Fill the gap with the given string
    self._buf[self._gap_start : self._gap_start + len(val)] = val
    self._gap_start += len(val)
```

### Deletion

Removing text from the buffer simply expands the gap in the corresponding
direction, shortening the string's prefix/suffix. This makes it very cheap.

The methods are named after the `backspace` and `delete` keys on the keyboard.

```python
def backspace(self, dist: int = 1) -> None:
    assert dist <= self.prefix_length
    # Extend gap to the left
    self._gap_start -= dist

def delete(self, dist: int = 1) -> None:
    assert dist <= self.suffix_length
    # Extend gap to the right
    self._gap_end += dist
```

### Moving the cursor

Moving the cursor along the buffer will shift letters from one side of the gap
to the other, moving them across from prefix to suffix and back.

I find Python's list slicing not quite as elegant to read as a `memmove`, though
it does make for a very small and efficient implementation.

```python
def left(self, dist: int = 1) -> None:
    assert dist <= self.prefix_length
    # Shift the needed number of characters from end of prefix to start of suffix
    self._buf[self._gap_end - dist : self._gap_end] = self._buf[
        self._gap_start - dist : self._gap_start
    ]
    # Adjust indices accordingly
    self._gap_start -= dist
    self._gap_end -= dist

def right(self, dist: int = 1) -> None:
    assert dist <= self.suffix_length
    # Shift the needed number of characters from start of suffix to end of prefix
    self._buf[self._gap_start : self._gap_start + dist] = self._buf[
        self._gap_end : self._gap_end + dist
    ]
    # Adjust indices accordingly
    self._gap_start += dist
    self._gap_end += dist
```
