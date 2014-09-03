husl.js: husl.coffee
	coffee --compile husl.coffee

husl.min.js: husl.js
	uglifyjs husl.js > husl.min.js
