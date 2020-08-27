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

## Branches and decentralised distribution

* Local/remote branch
* Remote-tracking branches?
  * Why doesn't my new `dev` branch push to the remote
* Multiple remotes
  * Example use-case: shared branches and local sandboxes
* `pull`/`fetch`
  * Our lord and savior: `git pull --rebase`

You should head to [Learn git branching][learn-branching] to practice those
notions with a nice visualization.

[learn-branching]: https://learngitbranching.js.org/
