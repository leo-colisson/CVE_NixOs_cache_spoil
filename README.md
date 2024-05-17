# Attack on nix cache

We provide in this repository an example of the security issue that I suggested/described in https://github.com/NixOS/ofborg/issues/68#issuecomment-2082789441 and https://github.com/NixOS/nix/issues/969. I communicated this to the security team and started the process of creating a CVE, but it still seems that the potential impact of this is overestimated. This repository is an effort to make this issue more visible, hopefully motivating time and efforts to fix it in a timely manner. I believe (and I have support on this from the security team) that publishing this publicly will not harm further the security of Nix since it is fairly simple to come up with this example given the wide discussions that are already happening in GitHub.

## First attack

The first attack is described in `./example_with_fetchurl.nix`. This innocent looking derivation installs arbitrary malicious code (no worry, the malicious code in this repository is fairly harmless):

```
# to fake a remove web server containing the source
$ nix-shell -p simple-http-server
$ simple-http-server -p 8042
# check that the derivation looks honest in default.nix
$ nix-build
$ ./result/bin/honestpackage
I am malicious >:-|
```

## Second attack

Some users suggested to use `fetchurl` that is supposedly "more secure" than `fetchzip` since it incorporates the name and version of the package in the hash (and there is a PR to implement this on fetchzip as well https://github.com/NixOS/nixpkgs/pull/49862). Yet, my claim is that this brings not much additional security, as it is fairly easy to fool it as shown in `example_with_fetchurl.nix`:

```
# to fake a remove web server containing the source
$ nix-shell -p simple-http-server
$ simple-http-server -p 8042
# check that the derivation looks honest in example_with_fetchurl.nix
$ nix-build example_with_fetchurl.nix
$ ./result/bin/honestpackage.sh
I am malicious >:-|
```

Adding warnings when the name is changed in a `fetchurl`, again, can easily be bypassed by re-implementing `fetchurl` using regular fixed output derivations.

## How to fix this

A way to fix this seems to improve Nix with a `derivation -> hash` table that asserts that `derivation` evaluates to `hash`. This map should ideally be shared by caches in order to prevent users from re-downloading the source every time they want to use a pre-built package. This is discussed in https://github.com/NixOS/nix/issues/969
