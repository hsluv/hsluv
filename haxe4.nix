# Source: https://discourse.nixos.org/t/latest-haxe-version/8592
{ pkgs ? import <nixpkgs> {},

}:

let
 sha = pkgs.stdenv.mkDerivation rec {
   version = "1.13";

   name = "sha";

   src = pkgs.fetchFromGitHub {
     owner = "djs55";
     repo = "ocaml-sha";
     rev = "v${version}";
     sha256 = "0z1mrc4rvxvrgahxc4si6mcm5ap45fsxzmpdifylaxavdfcaqz1b";
   };

   buildInputs = with pkgs.ocamlPackages; [ findlib dune_2 ocaml ];

   preBuild = ''
     substituteInPlace Makefile \
       --replace "build --dev" "build" \
       --replace "dune install" "dune install --prefix=$out"
   '';

   buildPhase = ''
     runHook preBuild
     dune build -p ${name}
     runHook postBuild
   '';

   installPhase = ''
     runHook preInstall
     ${pkgs.opaline}/bin/opaline -prefix $out -libdir $OCAMLFIND_DESTDIR
     runHook postInstall
   '';
 };

 haxe = pkgs.stdenv.mkDerivation rec {
   name = "haxe";
   version = "4.0.5";

   src = pkgs.fetchgit {
     url = https://github.com/HaxeFoundation/haxe.git;
     rev = version;
     sha256 = "0f534pchdx0m057ixnk07ab4s518ica958pvpd0vfjsrxg5yjkqa";
     fetchSubmodules = true;
   };

   buildInputs = with pkgs.ocamlPackages; with pkgs; [
     ocaml findlib ocaml_extlib camlp5 sedlex_2 xml-light ptmap sha

     zlib pcre neko
   ];

   preInstall = ''
     substituteInPlace Makefile \
       --replace "/usr/local" "$out"
   '';
 };
in haxe