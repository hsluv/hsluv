dist/closure-compiler.jar:
	wget -P dist http://dl.google.com/closure-compiler/compiler-20161024.tar.gz
	tar -xf dist/compiler-20161024.tar.gz -C dist closure-compiler-v20161024.jar
	mv dist/closure-compiler-v20161024.jar dist/closure-compiler.jar

dist/husl.auto.js: haxe/src/husl/Husl.hx javascript/exports.js
	haxe -cp haxe/src husl.Husl -js dist/husl.auto.js -D shallow-expose

dist/husl.js: dist/husl.auto.js
	echo '(function() {\n' > dist/husl.js
	cat dist/husl.auto.js >> dist/husl.js
	cat javascript/exports.js >> dist/husl.js
	echo '})();\n' >> dist/husl.js

dist/husl.min.js: dist/husl.js dist/closure-compiler.jar
	java -jar dist/closure-compiler.jar --js_output_file=dist/husl.min.js --compilation_level ADVANCED dist/husl.js

dist/husl.xml: haxe/src/husl/Husl.hx
	haxe -cp haxe/src -D doc-gen --macro 'include("husl")' --no-output -xml dist/husl.xml

dist/doc: dist/husl.xml
	haxelib run dox -i dist/husl.xml -o dist/doc