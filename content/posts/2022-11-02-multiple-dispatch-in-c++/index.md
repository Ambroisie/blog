---
title: "Multiple Dispatch in C++"
date: 2022-11-02T16:36:53+01:00
draft: false # I don't care for draft mode, git has branches for that
description: "A Lisp super-power in C++"
tags:
  - c++
  - design-pattern
categories:
  - programming
series:
favorite: false
disable_feed: false
---

A great feature that can be used in more dynamic languages is *multiple
dispatch*. Here's an example in [Julia][julia-lang] taken from the [Wikipedia
article][wiki-multiple-dispatch].

```julia
abstract type SpaceObject end

struct Asteroid <: SpaceObject
    # Asteroid fields
end
struct Spaceship <: SpaceObject
    # Spaceship fields
end

collide_with(::Asteroid, ::Spaceship) = # Asteroid/Spaceship collision
collide_with(::Spaceship, ::Asteroid) = # Spaceship/Asteroid collision
collide_with(::Spaceship, ::Spaceship) = # Spaceship/Spaceship collision
collide_with(::Asteroid, ::Asteroid) = # Asteroid/Asteroid collision

collide(x::SpaceObject, y::SpaceObject) = collide_with(x, y)
```

The `collide` function calls `collide_with` which, at runtime, will inspect the
types of its arguments and *dispatch* to the appropriate implementation.

Julia was created with multiple dispatch as a first-class citizen, it is used
liberally in its ecosystem. C++ does not have access to such a feature natively,
but there are alternatives that I will be presenting in this article, and try to
justify there uses and limitations.

[julia-lang]: https://julialang.org/
[wiki-multiple-dispatch]: https://en.wikipedia.org/wiki/Multiple_dispatch
<!--more-->

## Single dispatch

The native way to perform dynamic dispatch in C++ is through the
use of *virtual methods*, which allows an object to *override* the behaviour of
one of its super-classes' method.

Invoking a virtual method will perform *single dispatch*, on the dynamic type
of the object who's method is being called.

Here is an example:

```cpp
struct SpaceObject {
    virtual ~SpaceObject() = default;

    // Pure virtual method, which must be overridden by non-abstract sub-classes
    virtual void impact() = 0;
};

struct Asteroid : SpaceObject {
    // Override the method for asteroid impacts
    void impact() override {
        std::cout << "Bang!\n";
    }
};

struct Spaceship : SpaceObject {
    // Override the method for spaceship impacts
    void impact() override {
        std::cout << "Crash!\n";
    }
};

int main() {
    std::unique_ptr<SpaceObject> object = std::make_unique<Spaceship>();
    object->impact(); // Prints "Crash!"

    object = std::make_unique<Asteroid>();
    object->impact(); // Prints "Bang!"
}
```

Virtual methods are great when you want to represent a common set of behaviour
(an *interface*), and be able to substitute various types with their specific
implementation.

For example, a dummy file-system interface might look like the following:

```cpp
struct Filesystem {
    virtual void write(std::string_view filename, std::span<char> data) = 0;
    virtual std::vector<char> read(std::string_view filename) = 0;
    virtual void delete(std::string_view filename) = 0;
};
```

You can then write `PosixFilesystem` which makes use of the POSIX API and
interact with actual on-disk data, `MockFilesystem` which only works in-memory
and can be used for testing, etc...

## Double dispatch through the Visitor pattern

Sometimes single dispatch is not enough, such as in the collision example at the
beginning of this article. In cases where a computation depends on the dynamic
type of *two* of its values, we can make use of double-dispatch by leveraging
the Visitor design pattern. This is done by calling a virtual method on the
first value, which itself will call a virtual method on the second value.

Here's a commentated example:

```cpp
struct Asteroid;
struct Spaceship;

struct SpaceObject {
    virtual ~SpaceObject() = default;

    // Only used to kick-start the double-dispatch process
    virtual void collide_with(SpaceObject& other) = 0;

    // The actual dispatching methods
    virtual void collide_with(Asteroid& other) = 0;
    virtual void collide_with(Spaceship& other) = 0;
};

struct Asteroid : SpaceObject {
    void collide_with(SpaceObject& other) override {
        // `*this` is an `Asteroid&` which kick-starts the double-dispatch
        other.collide_with(*this);
    };

    void collide_with(Asteroid& other) override { /* Asteroid/Asteroid */ };
    void collide_with(Spaceship& other) override { /* Asteroid/Spaceship */ };
};

struct Spaceship : SpaceObject {
    void collide_with(SpaceObject& other) override {
        // `*this` is a `Spaceship&` which kick-starts the double-dispatch
        other.collide_with(*this);
    };

    void collide_with(Asteroid& other) override { /* Spaceship/Asteroid */ };
    void collide_with(Spaceship& other) override { /* Spaceship/Spaceship */ };
};

void collide(SpaceObject& first, SpaceObject& second) {
    first.collide_with(second);
};

int main() {
    auto asteroid = std::make_unique<Asteroid>();
    auto spaceship = std::make_unique<Spaceship>();

    collide(*asteroid, *spaceship);
    // Calls in order:
    // - Asteroid::collide_with(SpaceObject&)
    // - Spaceship::collide_with(Asteroid&)

    collide(*spaceship, *asteroid);
    // Calls in order:
    // - Spaceship::collide_with(SpaceObject&)
    // - Asteroid::collide_with(Spaceship&)

    asteroid->collide_with(*spaceship);
    // Only calls Asteroid::collide_with(Spaceship&)

    spaceship->collide_with(*asteroid);
    // Only calls Spaceship::collide_with(Asteroid&)
}
```

Double dispatch is pattern is most commonly used with the *visitor pattern*, in
which a closed class hierarchy (the data) is separated from an open class
hierarchy (the algorithms acting on that data). This is especially useful in
e.g: compilers, where the AST class hierarchy represents the data *only*, and
all compiler stages and optimization passes are programmed by a series of
visitors.

## Multiple dispatch on a closed class hierarchy

When even double dispatch is not enough, there is a way to do multiple dispatch
in standard C++, included in the STL since C++17. However unlike the previous
methods I showed, this one relies on using [`std::variant`][variant-cppref] and
[`std::visit`][visit-cppref].

[variant-cppref]: https://en.cppreference.com/w/cpp/utility/variant
[visit-cppref]: https://en.cppreference.com/w/cpp/utility/variant/visit

The limitation of `std::variant` is that you are limited to the types you can
select at *compile-time* for the values used during your dispatch operation.
You have a *closed* hierarchy of classes, which is the explicit list of types in
your `variant`.

Nonetheless, if you can live with that limitation, then you have a great amount
of power available to you. I have used `std::visit` in the past to mimic the
effect of pattern matching.

In this example, I re-create the double-dispatch from the previous section:

```cpp
// No need to inherit from a `SpaceObject` base class
struct Asteroid {};
struct Spaceship {};

// But the list of possible runtime *must* be enumerated at compile-time
using SpaceObject = std::variant<Asteroid, Spaceship>;

void collide(SpaceObject& first, SpaceObject& second) {
    struct CollideDispatch {
        void operator()(Asteroid& first, Asteroid& second) {
            // Asteroid/Asteroid
        }
        void operator()(Asteroid& first, Spaceship& second) {
            // Asteroid/Spaceship
        }
        void operator()(Spaceship& first, Asteroid& second) {
            // Spaceship/Asteroid
        }
        void operator()(Spaceship& first, Spaceship& second) {
            // Spaceship/Spaceship
        }
    };

    std::visit(CollideDispatch(), first, second);
}

int main() {
    SpaceObject asteroid = Asteroid();
    SpaceObject spaceship = Spaceship();

    collide(asteroid, spaceship);
    // Calls CollideDispatch::operator()(Asteroid&, Spaceship&)

    collide(spaceship, asteroid);
    // Calls CollideDispatch::operator()(Spaceship&, Asteroid&)
}
```
