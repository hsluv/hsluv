rec {
  pkgs = import (pkgsSrc) {};
  pkgsOriginal = import <nixpkgs> {};
  imagemagick = pkgs.imagemagick;

  pkgsSrc = pkgsOriginal.fetchzip {
    # branch: 21.11-fixneko
    url = "https://github.com/boronine/nixpkgs/archive/d9c74264bd9948885292537ca22bdb9b07020584.zip";
    sha256 = "0yy9638x86565vbc3mz747myzkgsbf9rqlz81anq044j8b5qprah";
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
