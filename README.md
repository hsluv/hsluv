[![Build Status](https://travis-ci.org/hsluv/hsluv.svg?branch=master)](https://travis-ci.org/hsluv/hsluv)
[![NPM package](https://img.shields.io/npm/v/hsluv.svg)](https://www.npmjs.com/package/hsluv)

# HSLuv - Human-friendly HSL

[Explanation, demo, ports etc.](http://www.hsluv.org)

The reference implementation is [written in Haxe](https://github.com/hsluv/hsluv/tree/master/haxe).

## Building

Requirements: [Nix package manage](http://nixos.org/nix/).

To run full test suite:

```sh
nix-build -A test
```

To build JavaScript distributions (server and client):

```sh
nix-build -A jsPublicNodePackage
nix-build -A jsPublicMin
```

To build Haxe documentation:

```sh
nix-build -A docs
```

To build website:

```sh
nix-build -A website
```

To build website and start localhost server:

```sh
(nix-build -A website && cd result && python3 -m http.server)
```

To deploy website (after building):

```sh
surge --project ./result
```

If you want to build without Nix you will require GNU Make, Haxe 3 and JDK 7+.
See `default.nix` for command line instructions.

## Versioning

Following [semantic versioning](http://semver.org/), the major version must be incremented 
whenever the color math changes. These changes can be tested for with snapshot files.
