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

  colorspacesJs = pkgs.fetchzip {
    url = "https://github.com/boronine/colorspaces.js/archive/v0.1.4.zip";
    sha256 = "042lzvz34026dlny5a2zlpxs3g8jna8lks2yhc6kknpibwv4ishx";
  };

  mustacheJs = pkgs.fetchzip {
    url = "https://github.com/janl/mustache.js/archive/v2.3.0.zip";
    sha256 = "09gx8ra0m52bm0zdfbwb151b5ngvv7bq1367pizsgmh5r4sqigzk";
  };

  huslJs601 = pkgs.fetchzip {
    url = "https://github.com/husl-colors/husl/archive/v6.0.1.zip";
    sha256 = "1vvvwcxmk52vpw9z46d2724whf5q6n704g6ab3jlw83xc6rzk1k3";
  };

  nodeModules = pkgs.stdenv.mkDerivation rec {
    name = "node-modules";
    inherit nodejs pngJs colorspacesJs mustacheJs huslJs601;
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      PATH=$nodejs/bin:$PATH
      HOME=.
      npm install $pngJs
      npm install $colorspacesJs
      npm install $mustacheJs
      npm install $huslJs601
      mkdir $out
      mv node_modules/* $out
    '';
  };

  huslWebsite = pkgs.stdenv.mkDerivation rec {
    name = "husl-website";
    inherit nodejs nodeModules;
    src = ./website;
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      export PATH=$nodejs/bin:$PATH
      export NODE_PATH=$nodeModules:$NODE_PATH
      cp -R $src website

      mkdir $out
      cp -R $src/static $out/static
      node website/generate-images.js $out
      node website/generate-html.js $out
      echo 'husl-colors.org\n' > $out/CNAME
    '';
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

  huslJs = { targets } : pkgs.stdenv.mkDerivation rec {
    inherit haxe haxeSrc haxeTestSrc snapshotRev4;
    name = "husl-js";
    builder = builtins.toFile "builder.sh" "
      source $stdenv/setup
      $haxe/bin/haxe -cp $haxeSrc -cp $haxeTestSrc -main RunTests -resource $snapshotRev4@snapshot-rev4 --interp
      $haxe/bin/haxe -cp $haxeSrc ${targets} -js $out -D js-classic -dce full
    ";
  };

  huslJsPublic = huslJs { targets = "husl.Husl"; };
  huslJsFull = huslJs { targets = "husl.Husl husl.Geometry husl.ColorPicker"; };

  huslJsModuleLegacy = pkgs.stdenv.mkDerivation rec {
    inherit jre haxe closureCompiler haxeSrc haxeTestSrc nodejs snapshotRev4 huslJsPublic;
    name = "closure";
    apiPublic = ./javascript/api-public.js;
    exports = ./javascript/exports.js;
    builder = builtins.toFile "builder.sh" "
      source $stdenv/setup
      echo '(function() {\n' > $out
      cat $huslJsPublic >> $out
      cat $apiPublic >> $out
      cat $exports >> $out
      echo '\n})();\n' >> $out
    ";
  };

  compileJs = jsFile : pkgs.stdenv.mkDerivation rec {
    inherit jre closureCompiler jsFile;
    name = "husl-js";
    builder = builtins.toFile "builder.sh" "
      source $stdenv/setup
      $jre/bin/java -jar $closureCompiler/share/java/compiler.jar \\
         --js_output_file=$out --compilation_level ADVANCED $jsFile
    ";
  };

  huslJsModuleLegacyDist = pkgs.stdenv.mkDerivation rec {
    inherit nodejs snapshotRev4;
    huslJsModuleLegacyMin = compileJs huslJsModuleLegacy;
    name = "husl-js-legacy-dist";
    testJs = ./javascript/test.js;
    packageJson = ./javascript/package.json;
    builder = builtins.toFile "builder.sh" "
      source $stdenv/setup
      mkdir $out
      $nodejs/bin/node $testJs $huslJsModuleLegacyMin $snapshotRev4
      cp $huslJsModuleLegacyMin $out/husl.min.js
      cp $packageJson $out/package.json
    ";
  };

  huslJsModuleFull = pkgs.stdenv.mkDerivation rec {
    name = "husl-full-min-js";
    inherit huslJsFull;
    exports = ./javascript/exports.js;
    builder = builtins.toFile "builder.sh" "
      source $stdenv/setup

      echo '(function() {\n' > $out
      cat $huslJsFull >> $out
      echo '\nvar exportObject = husl;\n' >> $out
      cat $exports >> $out
      echo '})();\n' >> $out
    ";
  };
}

