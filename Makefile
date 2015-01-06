.PHONY: docker_build, docker_run, dist, deploy

docker_build:
	docker build -t husl-dev-environment .

docker_run:
	docker run -i -t -v $(shell pwd):/husl husl-dev-environment /bin/bash

dist/js/main.js: src/main.coffee
	coffee --compile --bare --output dist/js src/main.coffee

dist: dist/js/main.js
	coffee generate.coffee

deploy:
	aws s3 sync dist s3://husl.boronine.com
