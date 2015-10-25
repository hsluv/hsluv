.PHONY: deploy

dist/js/main.js: src/main.coffee
	node_modules/.bin/coffee --compile --bare --output dist/js src/main.coffee

dist/img/demo: generate.coffee
	mkdir -p dist/img/demo
	node_modules/.bin/coffee generate.coffee
	touch dist/img/demo

dist: dist/js/main.js dist/img/demo
	touch dist

deploy:
	node_modules/.bin/surge --project ./dist --domain husl.surge.sh
