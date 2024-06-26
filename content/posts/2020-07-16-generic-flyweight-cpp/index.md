---
title: "Generic Flyweight in C++"
date: 2020-07-16T14:28:52+02:00
draft: false # I don't care for draft mode, git has branches for that
description: "A no-boilerplate flyweight pattern"
tags:
  - design pattern
  - C++
categories:
  - programming
series:
  - Generic flyweight
favorite: false
---

The flyweight is a well-known
[GoF](https://en.wikipedia.org/wiki/Design_Patterns) design pattern.

Its intent is to minimize memory usage by reducing the number of instantiations
of a given object.

I will show you how to implement a robust flyweight in C++, as well as a way to
make it templatable for easy use with no boiler-plate.

<!--more-->

## Flyweight

The [flyweight pattern](https://en.wikipedia.org/wiki/Design_Patterns) minimizes
memory usage by sharing a maximum amount of memory.

The classic example, as outlined on Wikipedia, is the representation of glyphs
in a word processor. Most characters will be instantiated multiple times, it
would lead to a ludicrous amount of memory usage to instantiate an object with
its full metadata for each character onscreen.

What you can do instead is to instantiate the object once when you first
encounter it, and then each time you need an identical object, you just refer to
the first copy that you already had.

### Implementation

Most tutorials that I have seen online use an `std::vector` with a small amount
of objects, and each flyweight holds on to an index inside the `vector`.

```cpp
class GlyphMetadata { /* implementation */ };

class FlyweightImpl {
    static inline std::vector<GlyphMetadata> instances_{};

public:
    static size_t glyphIndex(char c) {
        size_t ret = 0;
        // Linear scan to find the glyph's index if we already have it
        for (const auto& g : instances_)
            if (g.char() == c)
                return ret;
            else
                ++ret;

        // We didn't find it, add it at the end
        instances_.emplace_back(c);
        return ret; // Return the newly added element's index
    }

    // Getters etc...
};

class Glyph {
    const size_t index_;

public:
    Glyph(char c) : index_(FlyweightImpl::glyphIndex(c)) // Reference the index
    {}

    /* implementation, using the index to reference metadata */
};

// Etc...
```

However, this is not a robust solution, a large amount of objects will lead to
longer checks for equality as you scan the whole length of the array. You
cannot keep the `vector` sorted to do binary searches and insertion, because
the flyweights rely on their index inside the vector being stable.

Instead, I'd recommend you use an `std::set` for the following reasons:

- its semantic implies an ordering relationship, without duplication
- it has an (asymptotically) efficient insertion.
- it has stable iterators/pointers on insertion: a flyweight can just refer to
  a pointer to the object contained inside the `std::set`.

That last bullet point is the reason why I'd recommend using a `set` instead of
a sorted `vector`.

Here's the same example using this technique:

```cpp
// Same GlyphMetadata class

// No need for a FlyweightImpl class

class Glyph {
    static inline std::set<GlyphMetadata>  instances_{};
    GlyphMetadata* meta_;

public:
    Glyph(char c) : meta_(&(*instances_.emplace(c))) {}
};
```

The little `&(*instances_.emplace(c))` does all the work for us:

- `instances_.emplace(c)` creates the corresponding metadata only if it isn't in
  the set already.
- We get an iterator back to the inserted element from this operation
- We dereference it (`*<IT>`) to get a `GlyphMetadata&`
- We take the address of that reference for our flyweight (`&(<REF>)`).

### Templating

This scheme with an `std::set` is easily templatable: indeed we can imagine a
class `Unique<T>` which enables us to flyweight *any* `T`.

```cpp
// Templated on both the type T and the comparison functor used for total order
// Most of the time, 'std::less' is good enough
template <typename T, typename Cmp = std::less<T>>
class Unique {
    static inline std::set<T, Cmp>  instances_{};
    T* instance_;

    // Construct our Unique from a given T
    Unique(T value) : instances_(&(*instances_.emplace(std::move(value)))) {}

    // Other methods, e.g: implicit conversion to T&, copy assignment, etc...
};
```

You can then create new flyweight by simply inheriting from the `Unique` class:

```cpp
// A flyweight string, e.g: when we have lots of duplication
class LightStrings : public Unique<std::string> {
    // Flyweight pattern for free from inherited Unique

    // Implementation...
};
```

## Conclusion

This is an easy, generic flyweight implementation without any boilerplate. On
the next post I'll show you how to use the same scheme with a polymorphic base
class in our flyweight.

I first discovered this pattern while working on EPITA's [Tiger
Compiler](https://assignments.lrde.epita.fr/), a full-featured compiler written
in modern C++, whose goal is to help teach C++ techniques to students and
illustrate the use of design patterns in a big code base.
