{ inputs, lib, stdenv, crystal }:

stdenv.mkDerivation {
  pname = "nixpkgs-script";
  version = "20250118";

  src = ./nixpkgs-script.cr;
  dontUnpack = true;

  nativeBuildInputs = [ crystal ];

  buildPhase = ''
    sed $src -e 's,@NIXPKGS_PATH@,${inputs.nixpkgs},' > nixpkgs.cr
    crystal build --release nixpkgs.cr
  '';

  installPhase = ''
    install -D nixpkgs $out/bin/nixpkgs
  '';
}
