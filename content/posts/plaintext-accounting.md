---
title: "Plaintext Accounting, beancount, and fava"
date: 2021-01-15T15:54:51+01:00
draft: false # I don't care for draft mode, git has branches for that
description: "Or the story of my fall into systematically logging my expenses"
tags:
  - accounting
  - cli
categories:
  - software
  - slice of life
series:
favorite: false
---

[Plain text accounting](https://plaintextaccounting.org/) is a way of tracking
your finances using simple text files and command line software.

Being about to work on my end-of-studies internship, and therefore enter the
*adult*, *professional* world, I decided that I needed a better way to track my
income, expenses, and net worth.

<!--more-->

## My accounting journey

I went through most of my life without having to account for my money
explicitly, making use of the "dad bank". I received small sums of money at
Christmas and for birthdays, most of which went straight to an envelop that my
dad kept for me. This is the money that I used to buy myself books, games, and
other small things during childhood. My father kept track of the money and told
me how much I had left whenever I asked him.

During high school, my parents opened a bank account for me, and handed me
a credit card to allow me to buy lunch, make gifts, and other discretionary
spendings without having to explicitly go through them. It was regularly checked
on by my parents to make sure I always had some amounts of money to my name in
case I needed it, which they did up and until my engineering school. At this
point I had a pretty good idea of how much I could spend and when I could spend
it. This information could fit entirely in my head without any problems.

Once I had spent a year at EPITA, I decided to apply to the team of teaching
assistants. Between the money that I earned during my internship and what I
was earning as an assistant, I was finally gaining some financial independence.
Until very recently I was still mostly keeping track of my spending in my head,
my student job allowing me to avoid explicitly budgeting my money.

## Why do I want an actual accounting solution?

As you can see from my history, I have spent my whole life until this point
without using any form of accounting. Some people keep going their whole life
without ever explicitly using any accounting solutions, having a ball-park idea
of how much they have spent and how much they can afford to spend later.

This, however, does not accommodate me anymore. I want to have more fine-grained
control over my money, and be able to track and analyse my spending. I also know
that I am somewhat of an air-head, and tracking my money explicitly will
probably allow me to avoid, or at least reduce, lifestyle inflation once
I finish school and enter the work-force.

To that end, some people use a spreadsheet and simply keep track of their
transactions as a row of in-n-out flow of money. This is also problematic to me:
it is bothersome to come up with a useful template for budgeting, easy to mess
up my reporting, especially with transactions that are harder to model using
a simple template. Furthermore, it is very hard to version a spreadsheet, being
a programmer, and lover of the command line, I want to be able to use `git` to
keep track of my budget through time.

The perfect system for me has to be:

* foolproof: it is hard to mess up my reporting, and easy to know when I make
  a mistake,
* exhaustive: I can use the same system to keep track of my money, my
  investments, my debts, and anything that I would like to track,
* data-oriented: it should allow me to process my data and do some powerful
  analysis on my past transactions: I want to be able to know how much money
  I have spent at my neighbourhood bakery in the last semester.
* have a pretty interface and export abilities: this allows me to talk with
  a banker or an accountant without them having to know how to use my accounting
  system,
* be [Free and Open-Source Software][foss]: I can tinker with the sources if
  something isn't to my liking, and more easily ensure that my data will still
  be usable 20 years down the line.

[foss]: https://en.wikipedia.org/wiki/Free_and_open-source_software

## Beancount

### What is it?

[`beancount`][beancount] is a tool to do [double-entry accounting][double-entry]
on the command line, using only plain text files. It is inspired by
[`ledger`][ledger] and [`hledger`][hledger], both respected tools in the [*plain
text accounting*][plain-text] community, from which `beancount` draws inspiration
both in their syntax and their philosophy.

The point of *plain text accounting* is to make it easier and more efficient to
use the double-entry-style of accounting. This translates both in the syntax of
the ledger files, as well as the simplifications made to double-entry accounting
to make it seem more intuitive and easier to use.

To be more specific about `beancount`, it is a tool written in Python, made to
be kept simple and effective by its author. It is both very powerful from
the get-go, and easy to extend thanks to a system of plug-ins using the dynamic
nature of Python.

[beancount]: https://beancount.github.io/
[double-entry]: https://en.wikipedia.org/wiki/Double-entry_bookkeeping
[ledger]: https://www.ledger-cli.org/
[hledger]: https://hledger.org/
[plain-text]: https://plaintextaccounting.org/

### Why did I choose it ?

There are many different accounting solutions which I could have used, from my
list of wanted features one can presume that I would naturally align myself with
a double-entry accounting system: they are very powerful and make mistakes
obvious.

Furthermore, my want for an easy way to version-control my ledger eliminates
candidates like [`GNUCash`][gnucash], which make use of XML or other
hard-to-version file format. The power of plain text accounting is that it is at
once easy to read, write, and version, but also that I can feel confident that
I will still be able to access my data in 20 years.

So, at this, point we're pretty much reduced to one of the *plain text
accounting* software offerings. So why did I go with `beancount` rather than
`ledger` or `hledger` ? There are three main factors which led me to this
decision:

* `beancount` has a wonderful documentation, specifically, I was first
  introduced to the idea of *double-entry accounting* in its
  [documentation][double-entry-beancount].
* I read the author's [reasoning for writing `beancount` instead of using
  `ledger` and `hledger`][why-beancount]: I found him very reasonable, and
  agreed with a lot of his ideas (especially about being simpler, stricter,
  and being independent of any transaction ordering)
* finally, I *grok* python: I can dive in the source code to understand what is
  being done and why, I can write a few lines and submit a PR if I feel like
  something is missing from the base package, I can write a plug-in to customize
  it my exact liking.

[gnucash]: https://www.gnucash.org/
[double-entry-beancount]: https://beancount.github.io/docs/the_double_entry_counting_method.html
[why-beancount]: https://beancount.github.io/docs/a_comparison_of_beancount_and_ledger_hledger.html

### So how do I use it?

I have only recently started using `beancount`, after having it been on my TODO
list for 6 months. As a New Year's resolution, I finally decided to bite the
bullet and start seriously using it.

The first step was importing a backlog of transactions: I opened accounts to
represent my checking account, my cash on hand, my scrooge account (a special
service used by the TAs to trade money between each other and buy snacks), and
typed up how much money I had in each one. Importing the backlog allows me to
both give some context to the amount of money I am currently holding, and have
a representative set of transactions to open expense accounts and start
categorising my spending.

The second step was setting up [`fava`][fava], which is a web-UI for
`beancount`. This allows me to check on my accounts from any point on Earth.
This meant that I had to setup syncing for my ledger file between devices, for
which I am using [`syncthing`][syncthing]. I have also had to make sure nobody
could access the `fava` interface, I have accomplished the task with the help of
[`Authelia`][authelia], which I had already deployed on my server to access the
`syncthing` interface securely.

Finally I setup a `git` repository, added a [`git hook`][git-hook] to make sure
my ledger was [balanced][bean-check-hook], as well as a custom hook to make sure
that it was formatted.

I am now able to input my transactions on the go using the [`beancount` android
app][beancount-android], and regularly using my computer to tidy them up and
commit them to the repository.

[fava]: https://github.com/beancount/fava/
[syncthing]: https://syncthing.net/
[authelia]: https://www.authelia.com/
[git-hook]: https://git-scm.com/docs/githooks
[bean-check-hook]: https://github.com/d6e/beancount-check/
[beancount-android]: https://github.com/xuhcc/beancount-mobile

## What's next?

After all this work, the journey is still not done. It turns out that accounting
is kind of addictive. I am yet to be accounting for my taxes from my pay slips,
and still need to start tracking my *Livret A* opened by my parents, *PEE*
opened by EPITA, and other future investments.

Finally, I will never be done with accounting, as there are only two things in
life that are for certain: *death* and *taxes*, and only one of them is
a one-time-thing.
