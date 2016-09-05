.PHONY: deploy

dist: generate.js
	mkdir -p dist/img/demo
	node generate.js
	touch dist

deploy:
	node_modules/.bin/surge --project ./dist --domain www.husl-colors.org
