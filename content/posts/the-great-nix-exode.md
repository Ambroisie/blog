---
title: "The Great Nix Exode"
date: 2021-02-09T20:38:51+01:00
draft: false # I don't care for draft mode, git has branches for that
tags:
  - self-hosting
  - nix
categories:
  - software
series:
favorite: false
disable_feed: false
---

After reading up on [NixOS][nixos] and its package manager, [Nix][nix], I have
finally taken the plunge and migrated my website and various services to it.

[nixos]: https://nixos.org/
[nix]: https://nixos.wiki/wiki/Nix

<!--more-->

This is a very simple blog post to mark the event, I have finally graduated from
my pile of `docker-compose` that needed massaging every time I wanted to bring
up all my services at once.

You can find the relevant configurations files on this [repository][nix-config]

[nix-config]: https://gitea.belanyi.fr/ambroisie/nix-config
