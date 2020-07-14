.PHONY: all
all: build

.PHONY: build
build: build-dev

.PHONY: build-dev
build-dev:
	hugo -D

.PHONY: build-prod
build-prod:
	HUGO_ENV=production hugo

.PHONY: serve
serve: serve-dev

.PHONY: serve-dev
serve-dev:
	hugo server -D

.PHONY: serve-prod
serve-prod:
	hugo server

.PHONY: clean
clean:
	$(RM) -r public
