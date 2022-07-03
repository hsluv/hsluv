# This file contains legacy automation scripts for reference as we move to GitHub Actions automation
rec {
  pkgs = import (pkgsSrc) {};
  pkgsOriginal = import <nixpkgs> {};

  pkgsSrc = pkgsOriginal.fetchzip {
    # branch: 21.11-fixneko
    url = "https://github.com/boronine/nixpkgs/archive/d9c74264bd9948885292537ca22bdb9b07020584.zip";
    sha256 = "0yy9638x86565vbc3mz747myzkgsbf9rqlz81anq044j8b5qprah";
  };

  python = pkgs.python39.withPackages (ps: with ps; [ setuptools wheel twine ]);
  jre = pkgs.jre;
  zip = pkgs.zip;
  neko = pkgs.neko;
  haxe = pkgs.haxe;
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

  # v5.0.2
  pythonSrc = pkgs.fetchzip {
    url = "https://github.com/hsluv/hsluv-python/archive/cb90bbd5cab268175a327197e23aa79899cd4a0a.zip";
    sha256 = "0r0w8ycjwfg3pmzjghzrs0lkam93fzvgiqvrwh3nl9jnqlpw7v7j";
  };

  # v0.1-1
  luaSrc = pkgs.fetchzip {
    url = "https://github.com/hsluv/hsluv-lua/archive/ff1bcf087b2b352ed5903d6d407b5e394b7a0496.zip";
    sha256 = "1nqnyrym0vyf8fal6gj4nxk7pxpl2jyg5536dax0zg2nkdkzahms";
  };

  # 2.0.1
  sassSrc = pkgs.fetchzip {
    url = "https://github.com/hsluv/hsluv-sass/archive/062c73ef7a8413d97aa527f629103bb22d6aadda.zip";
    sha256 = "06fmd6zdnv77p9liz0y0fyak5xkc6wc88yick39mwvy062dhsdg0";
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

  rubyDist = pkgs.stdenv.mkDerivation rec {
    name = "ruby-dist";
    inherit ruby rubySrc;
    buildInputs = [ruby];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      mkdir $out
      cd $out
      gem build $rubySrc/hsluv.gemspec
    '';
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
      python3 setup.py sdist bdist_wheel
      mkdir $out
      cp dist/* $out
    '';
  };

  doxZip = pkgs.fetchurl {
    url = "https://github.com/HaxeFoundation/dox/archive/a4dd456418a4a540fe1d25a764927119bb892f72.zip";
    sha256 = "14p96nidbbv4afphsl7sy2qhzrs4mc7hf960wbbd4dp0cg7lij1s";
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
      cd $haxeRoot
      zip -r $out/hsluv.zip .
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

  # ------------------------------------------------------------------------------------------
  # Scripts

  publishPypi = pkgs.writeShellScriptBin "script.sh" ''
    ${python}/bin/twine upload --username $PYPI_USERNAME --password $PYPI_PASSWORD ${pythonDist}/*
  '';

  publishPypiTest = pkgs.writeShellScriptBin "script.sh" ''
    ${python}/bin/twine upload --username $PYPI_TEST_USERNAME --password $PYPI_TEST_PASSWORD --repository testpypi ${pythonDist}/*
  '';

  publishLua = pkgs.writeShellScriptBin "script.sh" ''
    export LUA_PATH="${luaSrc}/?.lua"
    ${luarocks}/bin/luarocks upload ${luaSrc}/*.rockspec --api-key=$LUAROCKS_API_KEY
  '';

  publishRuby = pkgs.writeShellScriptBin "script.sh" ''
    # It used to be possible to pipe in credentials as follows, but it no longer works
    # echo -e "$RUBYGEMS_EMAIL\n$RUBYGEMS_PASSWORD\n" |
    ${ruby}/bin/gem push ${rubyDist}/hsluv-1.0.0.gem
  '';

  # Segmentation fault
  publishHaxe = pkgs.writeShellScriptBin "script.sh" ''
    ${haxe}/bin/haxelib submit ${haxelibZip}/hsluv.zip
  '';

  # Fails to build
  publishNuget = pkgs.writeShellScriptBin "script.sh" ''
      # Nuget fails with absolute path: https://github.com/NuGet/Home/issues/2167
      dist=$(${python}/bin/python3 -c "import os.path; print(os.path.relpath('${csharpDist}'))")
      ${nuget}/bin/nuget push -ApiKey "$NUGET_API_KEY" /"$dist"/*.nupkg
  '';

  publishWebsite = pkgs.writeShellScriptBin "script.sh" ''
    ${awscli}/bin/aws s3 cp --recursive ${website} s3://www.hsluv.org
  '';
}
