bin/husl.js: haxe/src/husl/Husl.hx javascript/exports.js
	haxe -cp haxe/src husl.Husl -js bin/husl.js -D shallow-expose
	cat javascript/exports.js >> bin/husl.js

bin/husl.min.js: bin/husl.js
	closure-compiler --js_output_file=bin/husl.min.js --compilation_level ADVANCED bin/husl.js
