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

* some people use their head
  * I used to do that for a long time
  * I want more fine-grained control and analysis of my habits
  * I'm somewhat of a airhead, suffer from one-click-purchase-syndrome
* some people use a spreadsheet
  * bothersome
  * easy to mess up
  * hard to version
    * I like `git`
* I want
  * foolproof
  * exhaustive
  * powerful analysis, and trivia
    * how much have I spent at my neighbourhood bakery in the last semester ?
  * pretty interface
  * FLOSS and forward compatible

## Beancount

### What is it?

* python
* inspired by ledger, hledger
* simple
* *double entry accounting*

### Why did I choose it ?

* plain text accounting
* wonderful documentation
  * first real introduction to double-entry accounting
* author's comparison with ledger and hledger
* I *grok* python

### So how do I use it?

* backlog of transactions
* fava
* simple makefile and git hooks
* mobile phone app

## What's next?

* not accurately tracking my taxes from my pay check
* not tracking my livret A, PEE, future PEL and AV
