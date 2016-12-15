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
    inherit nodejs pngJs mustacheJs hsluvJsFullNodePackage;
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      PATH=$nodejs/bin:$PATH
      HOME=.
      npm install $pngJs
      npm install $mustacheJs
      npm install $hsluvJsFullNodePackage
      mkdir $out
      cp -R node_modules/* $out
    '';
  };

  hsluvWebsiteDemoImages = pkgs.stdenv.mkDerivation rec {
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

  hsluvWebsite = pkgs.stdenv.mkDerivation rec {
    name = "hsluv-website";
    inherit nodejs nodeModules hsluvJsFull hsluvWebsiteDemoImages;
    src = ./website;
    websiteRoot = ./website;
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      export NODE_PATH=$nodeModules:$NODE_PATH

      mkdir $out
      cp -R --no-preserve=mode,ownership $websiteRoot/static $out/static
      cp -R --no-preserve=mode,ownership $hsluvWebsiteDemoImages/* $out

      cp $hsluvJsFull $out/static/js/hsluv.full.js

      $nodejs/bin/node $websiteRoot/generate-html.js $out
      echo 'hsluv.org' > $out/CNAME
    '';
  };

  hsluvDocs = pkgs.stdenv.mkDerivation rec {
    name = "hsluvDocs";
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

  hsluvJs = { targets } : pkgs.stdenv.mkDerivation rec {
    inherit haxe haxeSrc;
    name = "hsluv-js";
    exportsJs = ./javascript/exports.js;
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      $haxe/bin/haxe -cp $haxeSrc ${targets} -js compiled.js -D js-classic

      echo '(function() {' > $out
      cat compiled.js >> $out
      cat $exportsJs >> $out
      echo '})();' >> $out
    '';
  };

  hsluvHaxeTest = pkgs.stdenv.mkDerivation rec {
    inherit haxe haxeSrc haxeTestSrc snapshotRev4;
    name = "hsluv-haxe-test";
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      $haxe/bin/haxe -cp $haxeSrc -cp $haxeTestSrc -main RunTests -resource $snapshotRev4@snapshot-rev4 --interp
      touch $out
    '';
  };

  hsluvJsTest = { jsFile } : pkgs.stdenv.mkDerivation rec {
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
    inherit hsluvJsPublic hsluvHaxeTest;
    name = "super-test";
    hsluvJsPublicTest = hsluvJsTest { jsFile = hsluvJsPublic; };
    builder = builtins.toFile "builder.sh" "
      source $stdenv/setup
      echo $hsluvJsPublicTest
      echo $hsluvHaxeTest
      touch $out
    ";
  };

  hsluvJsNodePackage = { jsFile } : pkgs.stdenv.mkDerivation rec {
    inherit jsFile;
    name = "hsluv-js-node-package";
    packageJson = ./javascript/package.json;
    builder = builtins.toFile "builder.sh" "
      source $stdenv/setup
      mkdir $out
      cp $jsFile $out/hsluv.js
      cp $packageJson $out/package.json
    ";
  };

  hsluvJsPublic = hsluvJs { targets = "hsluv.Hsluv"; };
  hsluvJsFull = hsluvJs { targets = "hsluv.Hsluv hsluv.Geometry hsluv.ColorPicker"; };

  # Final artifacts
  hsluvJsPublicNodePackage = hsluvJsNodePackage { jsFile = hsluvJsPublic; };
  hsluvJsFullNodePackage = hsluvJsNodePackage { jsFile = hsluvJsFull; };

  compileJs = jsFile : pkgs.stdenv.mkDerivation rec {
    inherit jre closureCompiler jsFile;
    name = "hsluv-js";
    builder = builtins.toFile "builder.sh" "
      source $stdenv/setup
      $jre/bin/java -jar $closureCompiler/share/java/compiler.jar \\
         --js_output_file=$out --compilation_level ADVANCED $jsFile
    ";
  };

}