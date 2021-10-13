---
title: "Magic Conversions in C++"
date: 2021-10-01T14:46:14+02:00
draft: false # I don't care for draft mode, git has branches for that
tags:
  - c++
  - design-pattern
categories:
  - programming
series:
favorite: false
disable_feed: false
---

One feature that I like a lot in [Rust][rust-lang] is return type polymorphism,
best exemplified with the following snippet of code:

```rust
use std::collections::HashSet;

fn main() {
    let vec: Vec<_> = (0..10).filter(|a| a % 2 == 0).collect();
    let set: HashSet<_> = (0..10).filter(|a| a % 2 == 0).collect();
    println!("vec: {:?}", vec);
    println!("set: {:?}", set); 
}
```

We have the same expression (`(0..10).filter(|a| a % 2 == 0).collect()`) that
results in two totally different types of values (a `Vec` and a `HashSet`)!

This is because Rust allows you to write a function which is generic in its
*return type*, which is a super-power that C++ does not have. But is there a way
to emulate this behaviour with some clever code?

[rust-lang]: https://rust-lang.org/
<!--more-->

## The problem

For the purposes of this article, the problem that I am trying to solve will be
the following:

```c++
void takes_small_array(std::array<char, 32> arr);
void takes_big_array(std::array<char, 4096> arr);

// How to define a `to_array` function so that the following works?
void test(std::string_view s) {
    takes_small_array(to_array(s));
    takes_big_array(to_array(s));
}
```

## First attempt

If we try to solve this in a way similar to Rust, we hit a problem in what the
language allows us to write:

```c++
std::array<char, 32> to_array(std::string_view s) {
    std::array<char, 32> ret;
    std::copy(s.begin(), s.end(), ret.begin());
    return ret;
}

std::array<char, 4096> to_array(std::string_view s) {
    std::array<char, 4096> ret;
    std::copy(s.begin(), s.end(), ret.begin());
    return ret;
}
```

The compiler complains with the following error:

```none
ambiguating new declaration of 'std::array<char, 4096> to_array(std::string_view)'
note: old declaration 'std::array<char, 32> to_array(std::string_view)'
```

That is because C++ does **not** allow you to write an overload set based on
*return type only*.

## Using templates

For our second try, we want to use *non-type template parameters* to solve the
issue. We write the following:

```c++
template <size_t N>
std::array<char, N> to_array(std::string_view s) {
    std::array<char, N> ret;
    std::copy(s.begin(), s.end(), ret.begin());
    return ret;
}
```

The compiler does not complain when we write this! We have also solved two minor
issues with the previous try: the size of the arrays are not hard-coded, and we
kept the code DRY.

However we have some trouble trying to use those functions as stated in the
beginning of the problem, with the following error message:

```none
error: no matching function for call to 'to_array(std::string_view&)'
      |     takes_small_array(to_array(s));
note: candidate: 'template<size_t N> std::array<char, N> to_array(std::string_view)'
      | std::array<char, N> to_array(std::string_view s) {
note:   template argument deduction/substitution failed:
note:   couldn't deduce template parameter 'N'
```

The compiler cannot deduce the size of the array we want to use! We could solve
the issue by explicitly giving a size when calling the function
(`to_array<32>(s)`) however this is unsatisfactory: we are not solving the
problem as stated initially, which could for example lead to needless churning
if we change the signature of `takes_small_array` to instead use
`std::array<char, 64>`).

Thankfully there is a way to use the compiler to our advantage, and have it
deduce it for us, but it involves some trickery.

## The solution

We want to write a function that resolves the previous two issues we
experienced:

* The non-type template parameter must be deduced by the end of the call to
`to_array`, but we can only deduce it once it is being consumed by
`takes_{small,big}_array` -- which is too late for the compiler.
* We cannot overload on the return type, which means we must return a single
type from the function.

The goal is to delay *when* the deduction of the array's size is happening,
which can be done by using a *templated conversion operator*.

So the solution to our problem is to do the following:

```c++
class ToArray {
    std::string_view s_;

public:
    ToArray(std::string_view s) : s_(s) {}

    template <size_t N>
    operator std::array<char, N>() const {
        std::array<char, N> ret;
        std::copy(s_.begin(), s_.end(), ret.begin());
        return ret;
    }
}

ToArray to_array(std::string_view s) {
    return ToArray{s};
}
```

The following steps happen when trying to call `takes_small_array(to_array(s))`:

* `to_array(s)` returns a `ToArray` value.
* the `ToArray` value is not an `array<char, 32>`, but has an implicit
conversion operator, which the compiler invokes.
* `takes_small_array` is called with the converted `array<char, 32>` value.

We now have a "magic" function which can convert a `string_view` to an
`std::array` of characters of any size. We could further improve this by
ensuring that the array is terminated with a `'\0'`, throwing an exception when
the array is too small for the given string, etc... This is left as an exercise
to the reader.
