[![Build Status](https://travis-ci.org/hsluv/hsluv.svg?branch=master)](https://travis-ci.org/hsluv/hsluv)
[![NPM package](https://img.shields.io/npm/v/hsluv.svg)](https://www.npmjs.com/package/hsluv)

# HSLuv - Human-friendly HSL

[Explanation, demo, ports etc.](http://www.hsluv.org)

The reference implementation is [written in Haxe](https://github.com/hsluv/hsluv/tree/master/haxe).

## Building

Requirements: [Nix package manage](http://nixos.org/nix/). If you want to build without Nix you 
will require GNU Make, Haxe 3 and JDK 7+. See `default.nix` for command line instructions.

To run full test suite:

```
nix-build -A test
```

To build JavaScript distributions (Node.js and browser):

```
nix-build -A jsPublicNodePackage
nix-build -A jsPublicMin
```

To build Haxe documentation:

```
nix-build -A docs
```

To build website:

```
nix-build -A website
```

To build website and start localhost server:

```
./scripts/serve-website.sh
```

## Testing

The snapshot file is stored for regression testing. If a backwards-incompatible change is made,
a new snapshot file can be generated as follows:

```
nix-build -A snapshotJson
```

The format of the file is as follows:

```
{
  "#000000": {
    rgb: [ 0, 0, 0 ],
    xyz: [ 0, 0, 0 ],
    luv: [ 0, 0, 0 ],
    lch: [ 0, 0, 0 ],
    hsluv: [ 0, 0, 0 ],
    hpluv: [ 0, 0, 0 ]
  },
  ...
}
```

## Deploying

See `/scripts` for automated deployments.

You will need access to our shared credentials.

## Versioning

Following [semantic versioning](http://semver.org/), the major version must be incremented 
whenever the color math changes. These changes can be tested for with snapshot files.

