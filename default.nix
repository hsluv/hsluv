rec {
  pkgs = import (pkgsSrc) {};
  pkgsOriginal = import <nixpkgs> {};
  pkgsSrc = pkgsOriginal.fetchzip {
    url = "https://github.com/NixOS/nixpkgs/archive/866717d75b64cb07cab16d0357edfd00cf339c20.zip";
    sha256 = "0ikz6m801gfmgzd4q0la5pcivl46yiviad5gvz0qba0pa7wc8g0g";
  };

  jre = pkgs.jre;
  zip = pkgs.zip;
  haxe = pkgs.haxe;
  neko = pkgs.neko;
  mono = pkgs.mono;
  nodejs = pkgs.nodejs;
  gnupg = pkgs.gnupg;
  luarocks = pkgs.luarocks;
  ruby = pkgs.ruby;
  maven = pkgs.maven;
  awscli = pkgs.awscli;
  nuget = pkgs.dotnetPackages.Nuget;
  maxima = pkgs.maxima;
  openssl = pkgs.openssl;
  haxeSrc = ./haxe/src;
  haxeTestSrc = ./haxe/test;
  snapshotRev4 = ./snapshots/snapshot-rev4.json;
  closureCompiler = pkgs.closurecompiler;

  python = pkgs.python36.withPackages (ps: with ps; [ setuptools wheel ]);

  # v0.0.2
  pythonSrc = pkgs.fetchzip {
    url = "https://github.com/hsluv/hsluv-python/archive/287439082df640fe469a1af5b683bcd7a14c4b54.zip";
    sha256 = "18528f20s9r54inh0gczxsjsg6jhckms5f900c8ryaankjbkzmd4";
  };

  # v0.1-0
  luaSrc = pkgs.fetchzip {
    url = "https://github.com/hsluv/hsluv-lua/archive/406d9d531d764224651aca6e8ee29fdc3f769596.zip";
    sha256 = "1xqz8z32h53qg4vf0wm24g6p1as5rmvb0izh5ym0h8wsf4sbj4pa";
  };

  # 1.0.0
  sassSrc = pkgs.fetchzip {
    url = "https://github.com/hsluv/hsluv-sass/archive/da6c6435376c5d0f8d5829212023efe31965e8c6.zip";
    sha256 = "1ambxi06gs51k2r5dw34mwlb82mx40z1qqx4zxhrqaggip45wq0x";
  };

  # 1.0.2
  csharpSrc = pkgs.fetchzip {
    url = "https://github.com/hsluv/hsluv-csharp/archive/ad9e0cc28853eb8d7c8722217727022a9dfb4a04.zip";
    sha256 = "180wf3bfjjliixbdpswmm3ni70drj7ik4myf5pj1s8ma2vbanm31";
  };

  # 0.1
  javaSrc = pkgs.fetchzip {
    url = "https://github.com/hsluv/hsluv-java/archive/120c049bc904c754584457c349060b1066426509.zip";
    sha256 = "0m3ddskmi9kd8smzbkpz3qrvhrlnfsbn1871i3g0b30cms43g1zh";
  };

  # 1.0.0
  rubySrc = pkgs.fetchzip {
    url = "https://github.com/hsluv/hsluv-ruby/archive/263f7e4aa6b1390bb7a49e8555e301af78341f11.zip";
    sha256 = "13wsrq61zg0z3pxd6qc3gxn5d3p83fqrjy8bjqnyzxbvxll4yknz";
  };

  maximaOutput = pkgs.stdenv.mkDerivation rec {
    name = "maxima-build";
    inherit maxima;
    buildInputs = [maxima];
    mathSrc = ./math;
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      install $mathSrc/* .
      mkdir $out
      maxima --quiet --init-mac=init.mac -b cie.mac > $out/cie.txt
      maxima --quiet --init-mac=init.mac -b hsluv.mac > $out/hsluv.txt
      maxima --quiet --init-mac=init.mac -b contrast.mac > $out/contrast.txt
    '';
  };

  # Errors out: Access to the path "/var/empty/.config" is denied
  csharpDist = pkgs.stdenv.mkDerivation rec {
    name = "csharp-dist";
    inherit mono nuget csharpSrc;
    buildInputs = [mono nuget];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      cp -R --no-preserve=mode,ownership $csharpSrc/* .
      mcs -target:library Hsluv/Hsluv.cs
      # mkdir -p ./.config/NuGet
      # echo "<?xml version="1.0" encoding="utf-8"?><configuration></configuration>" > ./.config/NuGet/NuGet.Config
      nuget pack Hsluv/Hsluv.nuspec
      mkdir $out
      cp *.nupkg $out
    '';
  };

  pythonDist = pkgs.stdenv.mkDerivation rec {
    name = "python-dist";
    inherit python pythonSrc;
    buildInputs = [python];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      export SOURCE_DATE_EPOCH=315532800
      cp -R --no-preserve=mode,ownership $pythonSrc/* .
      python setup.py sdist bdist_wheel
      mkdir $out
      cp dist/* $out
    '';
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

  nodeModules = pkgs.stdenv.mkDerivation rec {
    name = "node-modules";
    inherit nodejs pngJs mustacheJs nodePackageInternal;
    buildInputs = [nodejs];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      HOME=.
      npm install $pngJs
      npm install $mustacheJs
      npm install $nodePackageInternal
      mkdir $out
      cp -R node_modules/* $out
    '';
  };

  websiteDemoImages = pkgs.stdenv.mkDerivation rec {
    name = "hsluv-website-demo-images";
    inherit nodejs nodeModules;
    generateImagesJs = ./website/generate-images.js;
    buildInputs = [nodejs];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      export NODE_PATH=$nodeModules:$NODE_PATH
      mkdir $out
      node $generateImagesJs --website $out
    '';
  };

  avatar = pkgs.stdenv.mkDerivation rec {
    name = "hsluv-avatar";
    inherit nodejs nodeModules;
    generateImagesJs = ./website/generate-images.js;
    buildInputs = [nodejs];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      export NODE_PATH=$nodeModules:$NODE_PATH
      mkdir $out
      node $generateImagesJs --avatar $out/avatar.png
    '';
  };

  pickerJs = pkgs.stdenv.mkDerivation rec {
    name = "picker-js";
    hsluvJsFull = haxeJsCompile "hsluv.Hsluv hsluv.Geometry hsluv.ColorPicker";
    pickerJs = ./website/picker.js;
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      cat $hsluvJsFull >> $out
      cat $pickerJs >> $out
    '';
  };

  website = pkgs.stdenv.mkDerivation rec {
    name = "hsluv-website";
    inherit nodejs nodeModules websiteDemoImages pickerJsMin;
    src = ./website;
    buildInputs = [nodejs];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      export NODE_PATH=$nodeModules:$NODE_PATH

      mkdir $out
      cp -R --no-preserve=mode,ownership $src/static $out/static
      cp -R --no-preserve=mode,ownership $websiteDemoImages/* $out
      cp $pickerJsMin $out/static/picker.min.js

      node $src/generate-html.js $out
      echo 'www.hsluv.org' > $out/CNAME
    '';
  };

  # haxelib causes segmentation fault
  docs = pkgs.stdenv.mkDerivation rec {
    name = "docs";
    inherit neko haxe haxeSrc doxZip;
    buildInputs = [neko haxe];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      export HOME=.
      mkdir $out

      # haxelib setup .
      # haxelib install $doxZip
      # haxe -cp $haxeSrc/hsluv/Hsluv.hx -D doc-gen --macro 'include("hsluv")' --no-output -xml hsluv.xml
      # haxelib run dox -i hsluv.xml -o $out
    '';
  };

  haxelibZip = pkgs.stdenv.mkDerivation rec {
    name = "haxelib";
    inherit zip;
    haxeRoot = ./haxe;
    buildInputs = [zip];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      mkdir $out
      (cd $haxeRoot && zip -r $out/hsluv.zip .)
    '';
  };

  haxeJsCompile = targets : pkgs.stdenv.mkDerivation rec {
    inherit haxe haxeSrc;
    name = "hsluv-js-compile";
    buildInputs = [haxe];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      haxe -cp $haxeSrc ${targets} -js $out -D js-classic -D js-unflatten
    '';
  };

  haxePyCompile = targets : pkgs.stdenv.mkDerivation rec {
    inherit haxe haxeSrc;
    name = "hsluv-python";
    buildInputs = [haxe];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      haxe -cp $haxeSrc ${targets} -python $out
    '';
  };

  haxeTest = pkgs.stdenv.mkDerivation rec {
    inherit haxe haxeSrc haxeTestSrc snapshotRev4;
    name = "hsluv-haxe-test";
    buildInputs = [haxe];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      haxe -cp $haxeSrc -cp $haxeTestSrc -main RunTests -resource $snapshotRev4@snapshot-rev4 --interp
      touch $out
    '';
  };

  snapshotJson = pkgs.stdenv.mkDerivation rec {
    inherit haxe haxeSrc haxeTestSrc;
    name = "hsluv-haxe-test";
    buildInputs = [haxe];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      haxe -cp $haxeSrc -cp $haxeTestSrc -main Snapshot --interp > $out
    '';
  };

  testBrowserJs = pkgs.stdenv.mkDerivation rec {
    inherit nodejs browserDist;
    name = "test-browser-js";
    testJs = ./javascript/test.js;
    buildInputs = [nodejs];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      echo "const window = {};" > ./test.js
      cat $browserDist >> ./test.js
      echo "const hsluv = window.hsluv;" >> ./test.js
      cat $testJs >> ./test.js
      node ./test.js
      touch $out
    '';
  };

  test = pkgs.stdenv.mkDerivation rec {
    inherit browserDist haxeTest testBrowserJs;
    name = "super-test";
    builder = builtins.toFile "builder.sh" "
      source $stdenv/setup
      echo $testBrowserJs
      echo $haxeTest
      touch $out
    ";
  };

  makeNodePackage = { jsFile, exportFile } : pkgs.stdenv.mkDerivation rec {
    inherit jsFile exportFile;
    name = "js-node-package";
    packageJson = ./javascript/package.json;
    readme = ./javascript/README.md;
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      mkdir $out
      cat $jsFile > $out/hsluv.js
      cat $exportFile >> $out/hsluv.js
      echo -e "\nmodule.exports = root;" >> $out/hsluv.js
      install $packageJson $out/package.json
      install $readme $out/README.md
    '';
  };

  makeBrowserModule = jsFile : pkgs.stdenv.mkDerivation rec {
    inherit jsFile;
    name = "js-browser-module";
    export = ./javascript/api-public.js;
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      cat $jsFile > $out
      cat $export >> $out
      echo -e "\nwindow['hsluv'] = root;" >> $out
    '';
  };

  minifyJs = jsFile : pkgs.stdenv.mkDerivation rec {
    inherit jre closureCompiler jsFile;
    name = "hsluv-js";
    buildInputs = [closureCompiler];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      closure-compiler --output_wrapper "(function() {%output%})();" \
                       --js_output_file=$out \
                       --compilation_level ADVANCED $jsFile
    '';
  };

  # Internal use
  nodePackageInternal = makeNodePackage {
    jsFile = haxeJsCompile "hsluv.Hsluv hsluv.Geometry hsluv.ColorPicker hsluv.Contrast";
    exportFile = ./javascript/api-full.js;
  };
  pickerJsMin = minifyJs pickerJs;

  # Public releases
  nodePackageDist = makeNodePackage {
    jsFile = haxeJsCompile "hsluv.Hsluv";
    exportFile = ./javascript/api-public.js;
  };
  browserDist = minifyJs (makeBrowserModule (haxeJsCompile "hsluv.Hsluv"));

}