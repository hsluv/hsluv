rec {
  pkgsOriginal = import <nixpkgs> {};
  pkgsSrc = pkgsOriginal.fetchzip {
    url = "https://github.com/NixOS/nixpkgs/archive/29ce1d9e5ac201462c0ae26eacf9ca9127d05767.zip";
    sha256 = "1fwh3l771jbdxvlv40qv1js0xvwm661h52q9s84fyi7bf21ayjpa";
  };
  pkgs = import (pkgsSrc) {};

  jre = pkgs.jre;
  zip = pkgs.zip;
  git = pkgs.git;
  haxe = pkgs.haxe;
  neko = pkgs.neko;
  nodejs = pkgs.nodejs;
  haxeSrc = ./haxe/src;
  haxeTestSrc = ./haxe/test;
  snapshotRev4 = ./snapshots/snapshot-rev4.json;
  closureCompiler = pkgs.closurecompiler;

  # Latest
  luaSrc = pkgs.fetchzip {
    url = "https://github.com/hsluv/hsluv-lua/archive/406d9d531d764224651aca6e8ee29fdc3f769596.zip";
    sha256 = "1xqz8z32h53qg4vf0wm24g6p1as5rmvb0izh5ym0h8wsf4sbj4pa";
  };

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

  luaRock = pkgs.stdenv.mkDerivation rec {
    name = "lua-rock";
    inherit luaSrc git;
    luarocks = pkgs.luarocks;
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      PATH=$git/bin:$PATH
      $luarocks/bin/luarocks pack $luaSrc/hsluv-0.1-0.rockspec
      ls
    '';
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
    inherit neko haxe haxeSrc doxZip;
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

  haxelibZip = pkgs.stdenv.mkDerivation rec {
    name = "haxelib";
    inherit zip haxe;
    haxeRoot = ./haxe;
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      mkdir $out
      (cd $haxeRoot && $zip/bin/zip -r $out/hsluv.zip .)
      echo "$haxe/bin/haxelib submit hsluv.zip" > $out/submit.sh
    '';
  };

  haxeJs = { targets, export } : pkgs.stdenv.mkDerivation rec {
    inherit haxe haxeSrc export;
    name = "hsluv-js";
    exportsJs = ./javascript/exports.js;
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      $haxe/bin/haxe -cp $haxeSrc ${targets} -js compiled.js -D js-classic

      echo '(function() {' > $out
      cat compiled.js >> $out
      cat $export >> $out
      cat $exportsJs >> $out
      echo '})();' >> $out
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