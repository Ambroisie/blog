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

## Sampling one element

As an introduction, we'll first focus on fairly sampling one element from the
stream.

```python
def sample_one[T](stream: Iterable[T]) -> T:
    stream_iter = iter(stream)
    # Sample the first element
    res = next(stream_iter)
    for i, val in enumerate(stream_iter, start=1):
        j = random.randint(0, i)
        # Replace the sampled element with probability 1/(i + 1)
        if j == 0:
            res = val
    # Return the randomly sampled element
    return res
```

### Proof

Let's now prove that this algorithm leads to a fair sampling of the stream.

We'll be doing proof by induction.

#### Hypothesis $H_N$

After iterating through the first $N$ items in the stream,
each of them has had an equal $\frac{1}{N}$ probability of being selected as
`res`.

#### Base Case $H_1$

We can trivially observe that the first element is always assigned to `res`,
$\frac{1}{1} = 1$, the hypothesis has been verified.

#### Inductive Case

For a given $N$, let us assume that $H_N$ holds. Let us now look at the events
of loop iteration where `i = N` (i.e: observation of the $N + 1$-th item in the
stream).

`j = random.randint(0, i)` uniformly selects a value in the range $[0, i]$,
a.k.a $[0, N]$. We then have two cases:

* `j == 0`, with probability $\frac{1}{N + 1}$: we select `val` as the new
reservoir element `res`.

* `j != 0`, with probability $\frac{N}{N + 1}$: we keep the previous value of
`res`. By $H_N$, any of the first $N$ elements had a $\frac{1}{N}$ probability
of being `res` before at the start of the loop, each element now has a
probability $\frac{1}{N} \cdot \frac{N}{N + 1} = \frac{1}{N + 1}$ of being the
element.

And thus, we have proven $H_{N + 1}$ at the end of the loop.

## Sampling $k$ element

The code for sampling $k$ elements is very similar to the one-element case.

```python
def sample[T](stream: Iterable[T], k: int = 1) -> list[T]:
    stream_iter = iter(stream)
    # Retain the first 'k' elements in the reservoir
    res = list(itertools.islice(stream_iter, k))
    for i, val in enumerate(stream_iter, start=k):
        j = random.randint(0, i)
        # Replace one element at random with probability k/(i + 1)
        if j < k:
            res[j] = val
    # Return 'k' randomly sampled elements
    return res
```

### Proof

Let us once again do a proof by induction, assuming the stream contains at least
$k$ items.

#### Hypothesis $H_N$

After iterating through the first $N$ items in the stream, each of them has had
an equal $\frac{k}{N}$ probability of being sampled from the stream.

#### Base Case $H_k$

We can trivially observe that the first $k$ element are sampled at the start of
the algorithm, $\frac{k}{k} = 1$, the hypothesis has been verified.

#### Inductive Case

For a given $N$, let us assume that $H_N$ holds. Let us now look at the events
of the loop iteration where `i = N`, in order to prove $H_{N + 1}$.

`j = random.randint(0, i)` uniformly selects a value in the range $[0, i]$,
a.k.a $[0, N]$. We then have three cases:

* `j >= k`, with probability $1 - \frac{k}{N + 1}$: we do not modify the
sampled reservoir at all.

* `j < k`, with probability $\frac{k}{N + 1}$: we sample the new element to
replace the `j`-th element of the reservoir. Therefore for any element
$e \in [0, k[$ we can either have:
  * $j = e$: the element _is_ replaced, probability $\frac{1}{k}$.
  * $j \neq e$: the element is _not_ replaced, probability $\frac{k - 1}{k}$.

We can now compute the probability that a previously sampled element is kept in
the reservoir:
$1 - \frac{k}{N + 1} + \frac{k}{N + 1} \cdot \frac{k - 1}{k} = \frac{N}{N + 1}$.

By $H_N$, any of the first $N$ elements had a $\frac{k}{N}$ probability
of being sampled before at the start of the loop, each element now has a
probability $\frac{k}{N} \cdot \frac{N}{N + 1} = \frac{k}{N + 1}$ of being the
element.

We have now proven that all elements have a probability $\frac{k}{N + 1}$ of
being sampled at the end of the loop, therefore $H_{N + 1}$ has been verified.
