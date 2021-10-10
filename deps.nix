rec {
  pkgs = import (pkgsSrc) {};
  pkgsOriginal = import <nixpkgs> {};
  imagemagick = pkgs.imagemagick;

  pkgsSrc = pkgsOriginal.fetchzip {
    url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/21.05.zip";
    sha256 = "1ckzhh24mgz6jd1xhfgx0i9mijk6xjqxwsshnvq789xsavrmsc36";
  };

  mustacheJs = pkgs.fetchzip {
    url = "https://github.com/janl/mustache.js/archive/v2.3.0.zip";
    sha256 = "09gx8ra0m52bm0zdfbwb151b5ngvv7bq1367pizsgmh5r4sqigzk";
  };

  python = pkgs.python39.withPackages (ps: with ps; [ setuptools wheel twine ]);

  # For some reason if we don't trigger this from Docker build, Docker insists on downloading more packages when running
  buildTest = pkgs.stdenv.mkDerivation rec {
    name = "build-test";
    inherit imagemagick;
    buildInputs = [imagemagick];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      touch $out
    '';
  };
}
