---
title: "Hello World"
date: 2020-07-14T18:07:56+02:00
draft: false
description: "Test post please ignore"
tags:
  - test
categories:
favorite: false
tikz: true
graphviz: true
mermaid: true
---

## Test post please ignore

Hello world, this is just to test the capabilities of [Hugo](https://gohugo.io/)

<!--more-->

### Syntax highlighting

#### Rust

```rust
fn main() {
    println!("Hello World!")
}
```

#### Shell

```sh
echo hello world | cut -d' ' -f 1
```

### TikZJax support

{{% tikz %}}
  \begin{tikzpicture}
    \draw (0,0) circle (1in);
  \end{tikzpicture}
{{% /tikz %}}

### Graphviz support

{{% graphviz %}}
  graph {
    a -- b
    b -- c
    c -- a
  }
{{% /graphviz %}}

### Mermaid support

{{% mermaid %}}
  graph TD
  A[Enter Chart Definition] --> B(Preview)
  B --> C{decide}
  C --> D[Keep]
  C --> E[Edit Definition]
  E --> B
  D --> F[Save Image and Code]
  F --> B
{{% /graphviz %}}

### Spoilers

{{% spoiler "Don't open me" %}}
Test 2

Test 3
{{% /spoiler %}}
