{ stdenv, pkgs, fetchzip, fetchpatch, fetchgit, fetchurl }:
stdenv.mkDerivation {
  name = "dragino-lht65";

  src = ./.;
  buildInputs = with pkgs;
  [ ats2
  ];

}
