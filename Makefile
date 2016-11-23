dist/closure-compiler.jar:
	wget -P dist http://dl.google.com/closure-compiler/compiler-20161024.tar.gz
	tar -xf dist/compiler-20161024.tar.gz -C dist closure-compiler-v20161024.jar
	mv dist/closure-compiler-v20161024.jar dist/closure-compiler.jar

dist/husl.public.js: haxe/src/husl/Husl.hx haxe/src/husl/Geometry.hx javascript/exports.js
	# Full dead code elimination, leaving only public API behind
	haxe -cp haxe/src husl.Husl -js dist/husl.public.raw.js -D js-classic -dce full
	sed -i -e '/global/d' dist/husl.public.raw.js
	echo '(function() {\n' > dist/husl.public.js
	cat dist/husl.public.raw.js >> dist/husl.public.js
	cat javascript/api-public.js >> dist/husl.public.js
	cat javascript/exports.js >> dist/husl.public.js
	echo '})();\n' >> dist/husl.public.js

dist/husl.full.js: haxe/src/husl/Husl.hx haxe/src/husl/Geometry.hx haxe/src/husl/ColorPicker.hx javascript/exports.js
    # Standard dead code elimination, keeping all of our code
	haxe -cp haxe/src husl.ColorPicker -js dist/husl.full.raw.js -D js-classic
	sed -i -e '/global/d' dist/husl.full.raw.js
	echo '(function() {\n' > dist/husl.full.js
	cat dist/husl.full.raw.js >> dist/husl.full.js
	cat javascript/api-full.js >> dist/husl.full.js
	cat javascript/exports.js >> dist/husl.full.js
	echo '})();\n' >> dist/husl.full.js

javascript/dist/husl.min.js: dist/husl.public.js dist/closure-compiler.jar
	java -jar dist/closure-compiler.jar --js_output_file=javascript/dist/husl.min.js --compilation_level ADVANCED dist/husl.public.js

javascript/dist/husl.full.min.js: dist/husl.full.js dist/closure-compiler.jar
	java -jar dist/closure-compiler.jar --js_output_file=javascript/dist/husl.full.min.js --compilation_level SIMPLE dist/husl.full.js

dist/husl.xml: haxe/src/husl/Husl.hx
	haxe -cp haxe/src -D doc-gen --macro 'include("husl")' --no-output -xml dist/husl.xml

dist/doc: dist/husl.xml
	haxelib run dox -i dist/husl.xml -o dist/doc