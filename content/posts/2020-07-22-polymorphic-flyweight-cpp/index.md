---
title: "Polymorphic Flyweight in C++"
date: 2020-07-22T16:16:39+0200
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

Coming back from our last post about [generic flyweights in C++]({{< relref
"../2020-07-16-generic-flyweight-cpp/index.md" >}}), we can write a flyweight
that can be used with any abstract base classes.

<!--more-->

## Motivation

I was writing a raytracer in C++, and used an abstract base class to represent
textures. Having to potentially instantiate numerous identical textures, I
wanted to avoid that problem and instead use a flyweight for my textures.

I first thought about using the generic flyweight scheme that I presented last
time, however to do so I need a way to store and compare my objects.

I needed some infrastructure to extend the technique to be useful for my new
use case.

## RTTI and order

My textures' interface are the way I want to manipulate them in my raytracer,
I cannot have access to the underlying type, and do not want to have to juggle
their types outside of the implementation.

I also want to use RAII effectively, to avoid the headache of juggling
lifetimes.

To this effect, I need to store some `std::unique_ptr<TextureInterface>` inside
my set. However, to do so I need to come up with a way to totally order my
values behind the `TextureInterface`.

[std::type_info](https://en.cppreference.com/w/cpp/types/type_info) comes to
the rescue: more specifically its sibling class
[std::type_index](https://en.cppreference.com/w/cpp/types/type_info/before).

I could order my textures by their `std::type_index` to order them first by
chunks of types, and then sort the values inside the chunks by calling an
ordering method on my polymorphic objects.

## Implementation

The abstract class looked like this:

```cpp
class AbstractTexture {
    // Abstract method to compare two instances of the same class
    virtual bool less_than(const AbstractTexture& other) = 0;

public:
    virtual ~AbstractTexture() = default; // Abstract class => virtual destructor

    friend operator<(const AbstractTexture& lhs, const AbstractTexture& rhs) {
        const std::type_index lhs_i(lhs);
        const std::type_index rhs_i(rhs);
        if (lhs_i != rhs_i)
            returh lhs_i < rhs_i;
        // We are now assured that both classes have the same type
        return less_than(rhs);
    }
};
```

And one of its children should be implemented like this:

```cpp
class UniformTexture : public AbstractTexture {
    Color color_;

    bool less_than(const AbstractTexture& other) override {
        // We are assured that 'other' is of the same type at this point
        const auto& rhs = dynamic_cast<const UniformTexture&>(other);
        return color_ < rhs.color_; // Return appropriate order
    }
};
```

We can now create a flyweight texture class by doing:

```cpp
// Nice alias for a pointer to AbstractTexture
using texture_ptr = std::unique_ptr<AbstractTexture>;

// An implementation of the 'less_than' comparison for 'texture_ptr'
class TextureCmp {
    bool operator()(const texture_ptr& lhs, const texture_ptr& rhs) {
        return *lhs < *rhs; // Proxy to operator< for AbstractTexture
    }
}

class Texture : Unique<texture_ptr, TextureCmp> {
    // Implement using the underlying AbstractTexture interface
};
```

## Conclusion

I have now showed you this technique to implement a flyweight for any abstract
class you might want to use it for. Having neither seen anybody use an `std::set`
to store flyweights, nor anybody writing tutorials about storing polymorphic
objects in flyweights, I had a blast trying to figure out an elegant solution to
this problem.

My first implementation was complicated by the use of `std::type_info`
directly, basically re-implementing `std::type_index` because I had missed it
while reading the docs.

We could specialise our `Unique` class to avoid the double dereferencing when
storing pointers in our set (instead of having the Unique store a pointer to
the stored smart-pointer). We could also automatise the use of a comparison
functor similar to the `TextureCmp` class defined above when storing
pointer-like values in the set. Both of those are left as an exercise to the
reader :winking_face:
