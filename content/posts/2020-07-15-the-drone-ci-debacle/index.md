---
title: "The Drone CI debacle"
date: 2020-07-15T11:04:45+02:00
draft: false # I don't care for draft mode, git has branches for that
tags:
  - hugo
  - drone
  - docker
  - CI/CD
categories:
  - story
favorite: false
---

I wanted to deploy this small website to post small blog posts as the
inspiration would come. Because I'm stubborn, I wanted to self-host it, however
I also wanted the process to publish to my website to be as stream-lined as it
could be. Therefore, I decided to have it continuously delivered so that
pushing a new commit to my server would automatically build the changes and
serve them.

<!--more-->

## Drone

### The problem

I had wanted to install [Drone CI](https://drone.io/) on my server for a while.
I already have a plethora of self-hosted services on my server, and after
reading the docs I thought it would be deployed and ready to use in no time.

Instead it took me a few hours over a week before I got it working. I would run
the container in `docker-compose`, it would display its logs happily, but
nothing happened if I tried to connect to it.

### Debugging

My service definition looked something like this :

```yaml
drone-server:
  image: drone/drone:1
  container_name: drone-server
  restart: unless-stopped
  env_file:
    - ./drone/drone.env
    - ./drone/drone.env.secret
  volumes:
    - ./drone:/data
  ports:
    - 8080:8080 # Exposed for debugging purposes
  depends_on:
    - gitea # My self-hosted Gitea instance
  user: 1000:1000
```

I tried everything on port `8080`, `firefox` did not show anything, neither
did `wget`. I even tried to execute `wget` inside the `drone-server` container,
to no avail!

I tried listing the open ports, both outside and inside the container. I tried
activating the debug logging, and I could not see anything out of the ordinary.

I then tried launching the container directly on the command line, instead of
using a `docker-compose` service. Here's the command I used:

```sh
docker run --rm \
    --publish=8080:80 \
    --name=drone \
    --env-file shipyard/drone/drone.env \
    -v `pwd`/drone/:/data \
    drone/drone:1
```

Navigating to port `8080` now redirected me to my `Gitea` login page, as it
should be!

I was puzzled, as I could not see *any* difference between my service definition
and the command line I was launching.

### Resolution

The keen-eyed among you might have already seen the difference between those
two container instances... A single option was missing in my `docker run`
command which, had I included it, would have kept it from working too.

Have you found it yet? It's the `user: ...` line. I felt like a fool when
I finally spotted the difference. I removed it, and my service was now up and
running.

The logs showed no difference, nothing was complaining about the rights on
disk, the SQLite database was still created either way. But this line was the
difference between a working instance and a non-working one.
