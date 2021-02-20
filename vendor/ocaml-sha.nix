# Source: https://gist.github.com/tyrion/48592c673760c9dfe2b2618529290750
{ buildDunePackage, fetchFromGitHub }:

buildDunePackage rec {
  pname = "sha";
  version = "1.13";

  useDune2 = true;
  
  src = fetchFromGitHub {
    owner = "djs55";
    repo = "ocaml-sha";
    rev = "v${version}";
    sha256 = "0z1mrc4rvxvrgahxc4si6mcm5ap45fsxzmpdifylaxavdfcaqz1b";
  };

}
