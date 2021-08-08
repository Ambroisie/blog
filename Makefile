.PHONY: all
all: build-dev

.PHONY: build-dev
build-dev:
	HUGO_BASEURL=https://dev.belanyi.fr hugo -D -F

.PHONY: build-prod
build-prod:
	HUGO_ENV=production hugo --minify

.PHONY: serve
serve:
	hugo server -D -F

.PHONY: clean
clean:
	$(RM) -r public
