---
title: "Git Basics"
date: 2020-08-27T16:22:07+02:00
draft: false # I don't care for draft mode, git has branches for that
description: ""
tags:
  - git 
  - cli
categories:
  - programming
series:
  - Git basics
favorite: false
---

[Git][git] is a distributed version control system. Originally written by
[Linus Torvalds][linus] to be used with the development of the [Linux
kernel][kernel], it has now become the go-to way to share work between multiple
developers.

In this article I will summarise what I feel to be the *next-step
basics* of `git`, explaining each notion along the way.

[git]: https://git-scm.com/
[linus]: https://en.wikipedia.org/wiki/Linus_Torvalds
[kernel]: https://www.kernel.org/linux.html

<!--more-->

I assume at least passing knowledge of `git`, and will therefore skip the
justifications for using `git` instead of flinging tarballs at one another.
I will also be skipping the explanation for the basic workflow of `git add`,
`git commit`, and `git push`. You can consider this guide to be aimed at 3rd
year students at EPITA, who have used `git` for a whole year to submit their
project but have not explored some of its more powerful features.

## Starting out with branches and references

To me, this is the most essential thing you need to remember when you using
`git`. It is part of what makes it special, and will be used though-out your
career.

### Why you should use branches in `git`

What makes `git` so useful, and so powerful, is the fact that it was conceived
from the ground up to operate in a decentralised manner, to accommodate the
Linux kernel programming workflow.

That model de facto means that branching must be a lightweight operation, and
merging should not be hassle. Indeed, as soon as you start having people work
in parallel on a decentralised system, you end up creating "hidden branches":
each person's development tree is a branch on its own.

If you try merging branches that do not have any conflict, the operation is
basically instantaneous: to take advantage of that fact I encourage you to use
branches in your workflow when using git.

### Where is my HEAD

The notion of `HEAD` in `git` can seem strange. You might first have encountered
it when checking out an older commit. `git status` helpfully tells you that you
have been guillotined: `HEAD detached at 78f604b`.

To make it short, `HEAD` is a reference pointing to the commit that you are
currently working on top of. It usually points to a branch name (e.g: `main` or
`master`), but can also point to a specific commit (such as in the `checkout`
scenario I just mentioned).

### Revisions

Most of the commands I will show you need you to provide them with what `git`
calls a revision. This is usually means a way to specify a commit.

There are multiple ways to specify a `revision`, you should know at least two
of them: `refname` and `describeOutput` which loosely correspond to branch
names and git tags respectively. Note that `@` is a shortcut for referring to
`HEAD`.

You can also specify the `sha1` commit hash directly, or relative revisions.
A relative revision allows you to select the parent of a specific commit,
you can use the following revisions specifiers:

* `~`: select the first-parent commit
* `^`: select the nth-parent commit (useful for merge commits)

You can append numbers to those two specifiers, they differ in how they handle
merges. If you are applying them to a merge commit, `~2` will give you the
grand-parent of your commit, following the "*first parent*", whereas `^2` will
give you the "*second parent*" of your commit.

## History manipulation

* Cherry-picking
  * Easy to do
  * Most likely not what you want
    * CONFLICTS

* The power of the rebase, Luke
  * Work on your own
  * Commit early, commit often
  * Clean-up merge requests

* Lost? Here's a map
  * History manipulation can lose commits and other work
  * `reflog` can help you find it again

## Tips and tricks

Here are some basic pieces of knowledge which don't really belong to any other
section, which I think needs to be said.

### The importance of small commits

* Small commits
  * Why they're useful
    * Blame
    * Revert
    * Review & scope
  * `git add -p`

* Stubborn rebase
  * Example from `42sh`
  * `git rerere`

* Splitting a file with `blame` history
  * Give attribution to `Old New Thing`

* Binary search for a regression
  * `bissect`

## Going further

I advise you to check out [Learn git branching][learn-branching] to practice a
few of the notions I just wrote about, with a nice visualization of the commit
graph to explain what you are doing along the way.

Furthermore, the [Pro Git book][pro-git] is available online for free, and
contains a lot of great content. You can read it whole, but I especially
recommend checking out chapter 7 (*Git Tools*) and chapter 8 (*Git
Configuration*). If you want to learn about the inner workings of `git` and how
it stores the repository on your hard-drive, checkout chapter 10 (*Git
Internals*).

[learn-branching]: https://learngitbranching.js.org/
[pro-git]: https://www.git-scm.com/book/en/v2
