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

* gifts
* credit card during high-school/CPGE
* joining the YAKA-ACU team

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
