# Attack on nix cache

```
# to fetch the source
$ simple-http-server -p 8042
# check that the derivation looks honest in default.nix
$ nix-build
$ ./result/bin/honestpackage
I am malicious >:-|
```
