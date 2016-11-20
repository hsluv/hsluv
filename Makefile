bin/husl.auto.js: haxe/src/husl/Husl.hx javascript/exports.js
	haxe -cp haxe/src husl.Husl -js bin/husl.auto.js -D shallow-expose

bin/husl.js: bin/husl.auto.js
	echo '(function() {\n' > bin/husl.js
	cat bin/husl.auto.js >> bin/husl.js
	cat javascript/exports.js >> bin/husl.js
	echo '})();\n' >> bin/husl.js

bin/husl.min.js: bin/husl.js
	closure-compiler --js_output_file=bin/husl.min.js --compilation_level ADVANCED bin/husl.js
