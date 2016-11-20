bin/husl.js: src/husl/Husl.hx exports.js
	haxe -cp src husl.Husl -js bin/husl.js -D shallow-expose
	cat exports.js >> bin/husl.js

bin/husl.min.js: bin/husl.js
	closure-compiler --js_output_file=bin/husl.min.js --compilation_level ADVANCED bin/husl.js
