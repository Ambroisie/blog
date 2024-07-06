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
