.PHONY: deploy clean dist serve

clean:
	rm -rf dist/*

dist/images: generate.js
	mkdir -p dist/images
	node generate.js --images
	touch dist/images

dist:
	rm -rf dist/**.html
	mkdir -p dist
	rm -rf dist/static
	cp -r static dist/static
	node generate.js --html

serve:
	node_modules/.bin/http-server dist

deploy:
	node_modules/.bin/surge --project ./dist --domain www.husl-colors.org
