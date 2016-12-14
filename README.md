[![Build Status](https://travis-ci.org/husl-colors/husl.svg?branch=master)](https://travis-ci.org/husl-colors/husl)
[![NPM package](https://img.shields.io/npm/v/husl.svg)](https://www.npmjs.com/package/husl)

# HUSL - Human-friendly HSL

[Explanation, demo, ports etc.](http://www.husl-colors.org)

The reference implementation is [written in Haxe](https://github.com/husl-colors/husl/tree/master/haxe).

## Building

Requirements: [Nix package manage](http://nixos.org/nix/).

To build JavaScript version, running full test suite:

```sh
nix-build -A huslJsLegacyDist
```

To build Haxe documentation:

```sh
nix-build -A huslDocs
```

To build website:

```sh
nix-build -A huslWebsite
```

To deploy website:

```sh
surge --project ./result --domain www.husl-colors.org
```

If you want to build without Nix you will require GNU Make, Haxe 3 and JDK 7+.
See `default.nix` for command line instructions.

## Versioning

Following [semantic versioning](http://semver.org/), the major version must be incremented 
whenever the color math changes. These changes can be tested for with snapshot files.
