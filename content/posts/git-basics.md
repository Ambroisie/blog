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

## Branches and references

* Branches and merges
  * Decentralised
  * Merges are easy (assuming no conflicts)

* What HEAD is
  * Why guillotine
  * What ARE references anyway

* Relative references and other shortcuts

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
