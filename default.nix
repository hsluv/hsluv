rec {
  pkgsOriginal = import <nixpkgs> {};
  pkgsSrc = pkgsOriginal.fetchzip {
    url = "https://github.com/boronine/nixpkgs/archive/2aa021a0b1981ca35fa3b29d5cced7f97b55c93b.zip";
    sha256 = "1dmqwj45pn68g2d5ksys754gsissbangq1k7hzh7g1yri4f7p9zg";
  };
  pkgs = import (pkgsSrc) {};

  jre = pkgs.jre;
  jdk = pkgs.jdk;
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

  hxJavaZip = pkgs.fetchurl {
    url = "https://github.com/HaxeFoundation/hxjava/archive/0c4b993facf0c8be193e91ec8e5317f5e7dbc217.zip";
    sha256 = "14zsag9b7r0x88bzyi2q8mg9j1m3qrg7j3ihszlhiay1107qpbci";
  };

  hxCsZip = pkgs.fetchurl {
    url = "https://github.com/HaxeFoundation/hxcs/archive/1ba4ea2ce022774769f6ded94b154d38714a8ddd.zip";
    sha256 = "1k9ggkpwb0dan6a7r5dh5zqn3d9i5k902f4sc8clq2a87ax2zhk7";
  };

  pngJs = pkgs.fetchzip {
    url = "https://github.com/lukeapage/pngjs/archive/v3.0.0.zip";
    sha256 = "0yny8zq0pjy2qa6gzdl4h7h2mijg0c3s9xcmm6b1mzq9n04xgzsx";
  };

  mustacheJs = pkgs.fetchzip {
    url = "https://github.com/janl/mustache.js/archive/v2.3.0.zip";
    sha256 = "09gx8ra0m52bm0zdfbwb151b5ngvv7bq1367pizsgmh5r4sqigzk";
  };

  nodeModules = pkgs.stdenv.mkDerivation rec {
    name = "node-modules";
    inherit nodejs pngJs mustacheJs jsFullNodePackage;
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      PATH=$nodejs/bin:$PATH
      HOME=.
      npm install $pngJs
      npm install $mustacheJs
      npm install $jsFullNodePackage
      mkdir $out
      cp -R node_modules/* $out
    '';
  };

  websiteDemoImages = pkgs.stdenv.mkDerivation rec {
    name = "hsluv-website-demo-images";
    inherit nodejs nodeModules;
    generateImagesJs = ./website/generate-images.js;
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      export NODE_PATH=$nodeModules:$NODE_PATH
      mkdir $out
      $nodejs/bin/node $generateImagesJs $out
    '';
  };

  website = pkgs.stdenv.mkDerivation rec {
    name = "hsluv-website";
    inherit nodejs nodeModules jsFull websiteDemoImages;
    src = ./website;
    websiteRoot = ./website;
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      export NODE_PATH=$nodeModules:$NODE_PATH

      mkdir $out
      cp -R --no-preserve=mode,ownership $websiteRoot/static $out/static
      cp -R --no-preserve=mode,ownership $websiteDemoImages/* $out

      cp $jsFull $out/static/js/hsluv.full.js

      $nodejs/bin/node $websiteRoot/generate-html.js $out
      echo 'www.hsluv.org' > $out/CNAME
    '';
  };

  docs = pkgs.stdenv.mkDerivation rec {
    name = "docs";
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
      haxe -cp $haxeSrc/hsluv/Hsluv.hx -D doc-gen --macro 'include("hsluv")' --no-output -xml hsluv.xml
      haxelib run dox -i hsluv.xml -o $out
    '';
  };

  haxeJs = { targets, export } : pkgs.stdenv.mkDerivation rec {
    inherit haxe haxeSrc export;
    name = "hsluv-js";
    exportsJs = ./javascript/exports.js;
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      $haxe/bin/haxe -cp $haxeSrc ${targets} -js compiled.js -D js-classic -D js-unflatten

      echo '(function() {' > $out
      cat compiled.js | sed '/global/d' >> $out
      cat $export >> $out
      cat $exportsJs >> $out
      echo '})();' >> $out
    '';
  };

  haxePython = { targets } : pkgs.stdenv.mkDerivation rec {
    inherit haxe haxeSrc;
    name = "haxe-python";
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      $haxe/bin/haxe -cp $haxeSrc ${targets} -python $out
    '';
  };

  haxeLua = { targets } : pkgs.stdenv.mkDerivation rec {
    inherit haxe haxeSrc;
    name = "haxe-lua";
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      $haxe/bin/haxe -cp $haxeSrc ${targets} -lua $out
    '';
  };

  haxeJava = { targets } : pkgs.stdenv.mkDerivation rec {
    inherit haxe neko haxeSrc hxJavaZip jdk;
    name = "haxe-java";    
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      PATH=$haxe/bin:$neko/bin:$jdk/bin:$PATH
      export HAXELIB_PATH=`pwd`


      haxelib install $hxJavaZip

      haxe -cp $haxeSrc ${targets} -java $out
    '';
  };

  haxeCs = { targets } : pkgs.stdenv.mkDerivation rec {
    inherit haxe haxeSrc hxCsZip;
    name = "haxe-java";
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      PATH=$haxe/bin:$PATH
      HOME=.
      haxelib setup .
      haxelib install $hxCsZip

      mkdir $out

      haxe -cp $haxeSrc ${targets} -cs $out
    '';
  };

  haxeTest = pkgs.stdenv.mkDerivation rec {
    inherit haxe haxeSrc haxeTestSrc snapshotRev4;
    name = "hsluv-haxe-test";
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      $haxe/bin/haxe -cp $haxeSrc -cp $haxeTestSrc -main RunTests -resource $snapshotRev4@snapshot-rev4 --interp
      touch $out
    '';
  };

  snapshotJson = pkgs.stdenv.mkDerivation rec {
    inherit haxe haxeSrc haxeTestSrc;
    name = "hsluv-haxe-test";
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      $haxe/bin/haxe -cp $haxeSrc -cp $haxeTestSrc -main Snapshot --interp > $out
    '';
  };

  jsTest = jsFile : pkgs.stdenv.mkDerivation rec {
    inherit nodejs jsFile;
    name = "hsluv-js-test";
    testJs = ./javascript/test.js;
    builder = builtins.toFile "builder.sh" "
      source $stdenv/setup
      echo $testJs $jsFile
      $nodejs/bin/node $testJs $jsFile $snapshotRev4
      touch $out
    ";
  };

  test = pkgs.stdenv.mkDerivation rec {
    inherit jsPublic haxeTest;
    name = "super-test";
    jsPublicTest = jsTest jsPublic;
    builder = builtins.toFile "builder.sh" "
      source $stdenv/setup
      echo $jsPublicTest
      echo $haxeTest
      touch $out
    ";
  };

  jsNodePackage = jsFile : pkgs.stdenv.mkDerivation rec {
    inherit jsFile;
    name = "hsluv-js-node-package";
    packageJson = ./javascript/package.json;
    readme = ./javascript/README.md;
    builder = builtins.toFile "builder.sh" "
      source $stdenv/setup
      mkdir $out
      cp $jsFile $out/hsluv.js
      cp $packageJson $out/package.json
      cp $readme $out/README.md
    ";
  };

  jsPublic = haxeJs {
    targets = "hsluv.Hsluv";
    export = ./javascript/api-public.js;
  };
  jsFull = haxeJs {
    targets = "hsluv.Hsluv hsluv.Geometry hsluv.ColorPicker";
    export = ./javascript/api-full.js;
  };

  pythonBuild = haxePython { targets = "hsluv.Hsluv"; };
  javaBuild = haxeJava { targets = "hsluv.Hsluv"; };
  luaBuild = haxeLua { targets = "hsluv.Hsluv"; };
  csBuild = haxeCs { targets = "hsluv.Hsluv"; };

  # Final artifacts
  jsPublicNodePackage = jsNodePackage jsPublic;
  jsFullNodePackage = jsNodePackage jsFull;

  compileJs = jsFile : pkgs.stdenv.mkDerivation rec {
    inherit jre closureCompiler jsFile;
    name = "hsluv-js";
    builder = builtins.toFile "builder.sh" "
      source $stdenv/setup
      $jre/bin/java -jar $closureCompiler/share/java/compiler.jar \\
         --js_output_file=$out --compilation_level ADVANCED $jsFile
    ";
  };

  jsPublicMin = compileJs jsPublic;

}