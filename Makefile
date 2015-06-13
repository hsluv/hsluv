.PHONY: dist, deploy

dist/js/main.js: src/main.coffee
	coffee --compile --bare --output dist/js src/main.coffee

dist: dist/js/main.js
	mkdir -p dist/img
	coffee generate.coffee

deploy:
	aws s3 sync dist s3://www.husl-colors.org
