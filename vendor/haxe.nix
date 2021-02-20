# Source: https://gist.github.com/tyrion/48592c673760c9dfe2b2618529290750
{ stdenv, fetchFromGitHub, coreutils, ocamlPackages, zlib, pcre, neko, mbedtls
  , ocaml-sha # put this into ocamlPackages
}:


stdenv.mkDerivation rec {
  pname = "haxe";
  version = "4.1.5";

  src = fetchFromGitHub {
    owner = "HaxeFoundation";
    repo = "haxe";
    rev = version;
    sha256 = "0rns6d28qzkbai6yyws08yzbyvxfn848nj0fsji7chdi0y7pzzj0";
    fetchSubmodules = true;
  };

  dontStrip = true;


  makeFlags = [
    "INSTALL_DIR=$(out)"
    "BRANCH=HEAD"
    "COMMIT_DATE=20201231082044"
    "COMMIT_SHA=5e33a78aa"
    "all"
    "tools"
  ];
  
  buildInputs = with ocamlPackages; [
    ocaml
    findlib
    camlp5
    dune_2
    xml-light
    sedlex_2
    ocaml_extlib
    ptmap
    ocaml-migrate-parsetree
    ppx_tools_versioned
    ocaml-sha
  ] ++ [
    zlib
    pcre
    neko
    mbedtls
  ];
}
