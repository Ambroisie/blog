---
title: "Git Basics"
date: 2020-12-07 18:54:31+0100
draft: false # I don't care for draft mode, git has branches for that
description: "The next step after the basics"
tags:
  - git 
  - cli
categories:
  - programming
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

Once you start using `git` for non-trivial projects, using some of the
practices that I aim to teach you, rewriting history will become your secret
weapon for productivity.

I have to insist on one point though, which is that re-writing history that was
published and used by other people is often seen as a *faux-pas*, or worse! You
should only use it on private branches, making sure to never rewrite published
history unless absolutely necessary.

### Picking cherries

The easiest way to manipulate history is the `cherry-pick` command. It allows
you to "*lift*" a commit any other place in history, and plop it down in your
current branch.

It's the easiest way to manipulate history, allowing you for example to pick a
commit which fixes a bug in another branch and apply it onto yours: simply do
`git cherry-pick <my-commit-with-the-bugfix>`.

It is however most likely not what you want to do if you later intend to merge
your branch with the one you lifted the commit from. Both sets of commits will
have the exact same change, and `git` will not be able to resolve the conflict.
In those cases, consider merging from a common branch whose purpose is applying
the fix. In that case, `git` will happily merge your branches later on without
making a fuss.

### All your rebase are belong to us

This is probably the single best command in all of `git` in my mind. Having the
access to `git rebase` allows you to commit as you work, without caring about
atomicity, commit messages, or even having working/compiling code.

Rebasing allows you to make various changes to your branch's history:

* Rewording a commit's message.
* Reordering commits
* Removing commits
* Squashing: merging a commit into another one

This tool allows you to work on your own, commit early and commit often as you
work on your changes, and keep a clean result before merging back into the main
branch.

#### Fixup, a practical example

A specific kind of squashing which I use frequently is the notion of `fixup`s.
Say you've committed a change (*A*), and later on notice that it is missing
a part of the changeset. You can decide to commit that missing part (*A-bis*)
and annotate it to mean that it is linked to *A*.

Let's say you have this history:

```none
42sh$ git log --oneline
* 787dd36 (HEAD -> master) Add README
* 8d08529 Add baz
* 7188fb1 Frobulate bar
* 961d8fb Fix foo
```

And notice that missed a change that belongs to `Add baz`. You can `add` it to
your staged changes, and issue `commit --fixup @~`. This will create a commit
named `fixup! Add baz`.

```none
42sh$ git log --oneline
* 92912ee (HEAD -> master) fixup! Add baz
* 787dd36 Add README
* 8d08529 Add baz
* 7188fb1 Frobulate bar
* 961d8fb Fix foo
```

If you then rebase using `-i --autosquash` will result in this interactive
rebase screen.

```none
pick 961d8fb Fix foo
pick 7188fb1 Frobulate bar
pick 8d08529 Add baz
fixup 92912ee fixup! Add baz
pick 787dd36 Add README
```

After applying the rebase, you find yourself with the complete change inside
`Add baz`, which can be confirmed with another `git log`

```none
* 0174e54 (HEAD -> master) Add README
* b0a47ae Add baz
* 7188fb1 Frobulate bar
* 961d8fb Fix foo
```

This is especially useful when you want to apply suggestion on a merge request
after it was reviewed. You can keep a clean history without those pesky `Apply
suggestion ...` commits being part of your history.

### Lost commits and the reflog

When doing this kind of history manipulation, you might end up making a mistake
and lose a commit that was **very important**.

Obviously, `git` has a way to save us in this situation. If we look at the man
page for `git reflog`, we can read the following sentence:

```none
Reference logs, or "reflogs", record when the tips of branches and other
references were updated in the local repository.
```

What does this mean exactly? Simply put, you can use it to checkout a previous
version of your repository, in the state it was in before you manipulated the
history. Let's illustrate with a small example.

#### Mapping lost commits: a practical example

Let's say you have this repository state at the beginning.

```none
42sh$ git log --oneline
* 524de22 (HEAD -> master) Documentation update
* d60ddb5 USELESS COMMIT
* e81b5fb Remove baz dependency
* 44cea7d VERY IMPORTANT COMMIT
* 58eb2d9 Use foo without bar
* dab7792 Simplify frobulation
```

And decide to drop `c581d4d` (**`USELESS COMMIT`**), but inadvertently drop
`377921c` (**`VERY IMPORTANT COMMIT`**) at the same time. For this example,
I simply `dropped` both commits in a `rebase` operation.

I notice now that I am missing my **`VERY IMPORTANT COMMIT`** in my history:

```none
42sh$ git log --oneline
* ec8508b (HEAD -> master) Documentation update
* 3866067 Remove baz dependency
* 58eb2d9 Use foo without bar
* dab7792 Simplify frobulation
```

If I now use try to see what happened to my `HEAD` reference using `reflog`,
I can find the last update I did before starting my `rebase` to cancel the
whole operation.

```none
42sh$ git reflog
ec8508b (HEAD -> master) HEAD@{0}: rebase (finish): returning to refs/heads/master
ec8508b (HEAD -> master) HEAD@{1}: rebase (pick): Documentation update
3866067 HEAD@{2}: rebase (pick): Remove baz dependency
58eb2d9 HEAD@{3}: rebase: fast-forward
dab7792 HEAD@{4}: rebase: fast-forward
612e6f5 HEAD@{5}: rebase (start): checkout 612e6f5a055280aac1d7608af2dd2443aed6875c
524de22 HEAD@{6}: commit: Documentation update
d60ddb5 HEAD@{7}: commit: USELESS COMMIT
e81b5fb HEAD@{8}: commit: Remove baz dependency
44cea7d HEAD@{9}: commit: VERY IMPORTANT COMMIT
58eb2d9 HEAD@{10}: commit: Use foo without bar
dab7792 HEAD@{11}: commit (initial): Simplify frobulation
```

By reading the `reflog`, I can see that my `rebase` started at `HEAD@{5}`
(reads: *`HEAD`'s fifth prior value*). If I want to return to the state of my
repository before starting that rebase, I can simply do `git checkout HEAD@6`
which will take me back to the state prior to the `rebase`.

```none
42sh$ git checkout HEAD@{6} # Checkout my `HEAD`'s 6th prior value
42sh$ git log --oneline # Are we back before the rebase?
* 524de22 (HEAD) Documentation update
* d60ddb5 USELESS COMMIT
* e81b5fb Remove baz dependency
* 44cea7d VERY IMPORTANT COMMIT
* 58eb2d9 Use foo without bar
* dab7792 Simplify frobulation
```

Now, I want to make sure that I have my `master` branch back to that state too,
and not simply my disembodied `HEAD`.

```none
42sh$ git branch -f master # Change where `master` is pointing at
42sh$ git checkout master # Checkout `master` branch
42sh$ git log --oneline # Is everything in order?
* 524de22 (HEAD -> master) Documentation update
* d60ddb5 USELESS COMMIT
* e81b5fb Remove baz dependency
* 44cea7d VERY IMPORTANT COMMIT
* 58eb2d9 Use foo without bar
* dab7792 Simplify frobulation
```

And voila! I can now try my `rebase` again, and be careful not to lose **`VERY
IMPORTANT COMMIT`** this time.

## Tips and tricks

Here are some basic pieces of knowledge which don't really belong to any other
section, which I think needs to be said.

### The importance of small commits

You might have noticed that people keep saying that commits should be kept
**atomic**. What does that mean and why should it matter?

Keeping commits atomic means that you should strive to commit your changes in
the smallest unit of work possible. Instead of making one commit named *WIP: add
stuff* at the end of the day, you should instead try to cut your work up into
small units: `add tests for frobulator`, `account for foo in bar processing`,
etc...

This way of working has multiple things going for it once you start taking
advantage of `git`'s power: you can more easily reason about a line of code by
using `blame`, you can more easily squash bugs using `revert`, you can more
easily review the changes in an MR and keep its scope narrow.

One very useful command you can add to your tool belt is `git add -p`, which
prompts you interactively for each patch in your working directory : you can
easily choose which parts of your changes should end up in the same commit.

### Miscellaneous commands

Here's a list of commands that you should read-up on, but I won't be presenting
further:

* `git bisect`
* `git rerere`
* `git stash`
* and more...

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
