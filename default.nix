rec {
  pkgsOriginal = import <nixpkgs> {};
  pkgsSrc = pkgsOriginal.fetchzip {
    url = "https://github.com/NixOS/nixpkgs/archive/1beb9e6d1e3bbafa3c953903813b1526fb81c622.zip";
    sha256 = "139b4q6q1nprg5k3n17p357qjl94r7dnzvafpnh6x6fg2s2m2zvb";
  };
  pkgs = import (pkgsSrc) {};

  jre = pkgs.jre;
  haxe = pkgs.haxe;
  neko = pkgs.neko;
  nodejs = pkgs.nodejs;
  haxeSrc = ./haxe/src;
  haxeTestSrc = ./haxe/test;
  closureCompiler = pkgs.closurecompiler;
  snapshotRev4 = ./snapshots/snapshot-rev4.json;

  doxZip = pkgs.fetchurl {
    url = "https://github.com/HaxeFoundation/dox/archive/a4dd456418a4a540fe1d25a764927119bb892f72.zip";
    sha256 = "14p96nidbbv4afphsl7sy2qhzrs4mc7hf960wbbd4dp0cg7lij1s";
  };

  huslDocs = pkgs.stdenv.mkDerivation rec {
    name = "huslDocs";
    inherit neko;
    inherit haxe;
    inherit haxeSrc;
    inherit doxZip;
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      PATH=$haxe/bin:$neko/bin:$PATH
      HOME=.
      mkdir $out

      haxelib setup .
      haxelib install $doxZip
      haxe -cp $haxeSrc/husl/Husl.hx -D doc-gen --macro 'include("husl")' --no-output -xml husl.xml
      haxelib run dox -i husl.xml -o $out
    '';
  };

  huslMinJs = pkgs.stdenv.mkDerivation rec {
    inherit jre haxe closureCompiler haxeSrc haxeTestSrc nodejs snapshotRev4;
    name = "husl-min-js";

    apiPublic = ./javascript/api-public.js;
    exports = ./javascript/exports.js;
    testJs = ./javascript/test.js;
    builder = builtins.toFile "builder.sh" "
      source $stdenv/setup
      PATH=$haxe/bin:$jre/bin:$nodejs/bin:$PATH
      mkdir $out

      haxe -cp $haxeSrc -cp $haxeTestSrc -main RunTests -resource $snapshotRev4@snapshot-rev4 --interp

      # Full dead code elimination, leaving only public API behind
      haxe -cp $haxeSrc husl.Husl -js raw.js -D js-classic -dce full
      sed -i -e '/global/d' raw.js
      echo '(function() {\n' > wrapped.js
      cat raw.js >> wrapped.js
      cat $apiPublic >> wrapped.js
      cat $exports >> wrapped.js
      echo '})();\n' >> wrapped.js
      java -jar $closureCompiler/share/java/compiler.jar \\
        --js_output_file=$out/husl.min.js --compilation_level ADVANCED wrapped.js

      node $testJs $out/husl.min.js $snapshotRev4
    ";
  };

  huslFullMinJs = pkgs.stdenv.mkDerivation rec {
    name = "husl-full-min-js";
    inherit jre;
    inherit haxe;
    inherit closureCompiler;
    inherit haxeSrc;
    apiFull = ./javascript/api-full.js;
    exports = ./javascript/exports.js;
    builder = builtins.toFile "builder.sh" "
      source $stdenv/setup
      mkdir $out

      # Standard dead code elimination, keeping all of our code
      $haxe/bin/haxe -cp $haxeSrc husl.ColorPicker -js raw.js -D js-classic
      sed -i -e '/global/d' raw.js
      echo '(function() {\n' > wrapped.js
      cat raw.js >> wrapped.js
      cat $apiFull >> wrapped.js
      cat $exports >> wrapped.js
      echo '})();\n' >> wrapped.js

      $jre/bin/java -jar $closureCompiler/share/java/compiler.jar \\
        --js_output_file=$out/husl.full.min.js --compilation_level SIMPLE wrapped.js
    ";
  };
}

