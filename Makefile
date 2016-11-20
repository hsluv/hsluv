bin/closure-compiler.jar:
	wget -P bin http://dl.google.com/closure-compiler/compiler-20161024.tar.gz
	tar -xf bin/compiler-20161024.tar.gz -C bin closure-compiler-v20161024.jar
	mv bin/closure-compiler-v20161024.jar bin/closure-compiler.jar

bin/husl.auto.js: haxe/src/husl/Husl.hx javascript/exports.js
	haxe -cp haxe/src husl.Husl -js bin/husl.auto.js -D shallow-expose

bin/husl.js: bin/husl.auto.js
	echo '(function() {\n' > bin/husl.js
	cat bin/husl.auto.js >> bin/husl.js
	cat javascript/exports.js >> bin/husl.js
	echo '})();\n' >> bin/husl.js

bin/husl.min.js: bin/husl.js bin/closure-compiler.jar
	java -jar bin/closure-compiler.jar --js_output_file=bin/husl.min.js --compilation_level ADVANCED bin/husl.js
