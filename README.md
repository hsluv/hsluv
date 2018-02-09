[![Build Status](https://travis-ci.org/hsluv/hsluv.svg?branch=master)](https://travis-ci.org/hsluv/hsluv)
[![NPM package](https://img.shields.io/npm/v/hsluv.svg)](https://www.npmjs.com/package/hsluv)

# HSLuv - Human-friendly HSL

[Explanation, demo, ports etc.](http://www.hsluv.org)

The reference implementation is [written in Haxe](https://github.com/hsluv/hsluv/tree/master/haxe). 

## Building

Requirements: [Nix package manage](http://nixos.org/nix/). If you want to build without Nix,
see `default.nix` for dependencies and command line instructions.

The necessary mathematical equations are solved in [Maxima](http://maxima.sourceforge.net/). 
See `/math` directory for the equations and run the following to verify the solutions:

```
nix-build -A maximaOutput
```

To run full test suite:

```
nix-build -A test
```

To build JavaScript distributions (Node.js and browser):

```
nix-build -A nodePackageDist
nix-build -A browserDist
```

To build website:

```
nix-build -A website
```

To build website and start localhost server:

```
./run.sh server
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

For publishing packages and website you will need access to our shared credentials.

```bash
./run.sh publishPypi
./run.sh publishNpmJs
./run.sh publishNpmSass
./run.sh publishLua
./run.sh publishWebsite
./run.sh publishRuby
./run.sh publishNuget
./scripts/publish-maven.sh
```

## Versioning

Following [semantic versioning](http://semver.org/), the major version must be incremented 
whenever the color math changes. These changes can be tested for with snapshot files.

