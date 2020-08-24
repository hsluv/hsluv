[![Build Status](https://travis-ci.org/hsluv/hsluv.svg?branch=master)](https://travis-ci.org/hsluv/hsluv)
[![NPM package](https://img.shields.io/npm/v/hsluv.svg)](https://www.npmjs.com/package/hsluv)

# HSLuv - Human-friendly HSL

[Explanation, demo, ports etc.](https://www.hsluv.org)

The reference implementation is [written in Haxe](https://github.com/hsluv/hsluv/tree/master/haxe). 

## Build system

HSLuv uses [Nix package manager](http://nixos.org/nix/). If you want to build without Nix,
see `default.nix` for dependencies and command line instructions.

Linux, Windows 10 (WSL), macOS:
 - Install [Nix](http://nixos.org/nix/)
 - Use: `./run.sh <COMMAND> <TARGET>`

A Docker wrapper is available for Windows 10 (native), or anyone who finds it more convenient:
 - Install [Docker](https://www.docker.com/)
 - Use: `HSLUV_RUNTIME=docker ./run.sh <COMMAND> <TARGET>`

The necessary mathematical equations are solved in [Maxima](http://maxima.sourceforge.net/). 
See `/math` directory for the equations and run the following to verify the solutions:

```
./run.sh build maximaOutput
```

To run full test suite:

```
./run.sh build test
```

To build JavaScript distributions (Node.js and browser):

```
./run.sh build nodePackageDist
./run.sh build browserDist
```

To build website:

```
./run.sh build website
```

To build website and start localhost server:

```
./run.sh run server
```

## Testing

The snapshot file is stored for regression testing. If a backwards-incompatible change is made,
a new snapshot file can be generated as follows:

```
./run.sh build snapshotJson
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
./run.sh run publishPypi
./run.sh run publishNpmJs
./run.sh run publishNpmSass
./run.sh run publishLua
./run.sh run publishWebsite
./run.sh run publishRuby
./run.sh run publishNuget
./scripts/publish-maven.sh
```

## Versioning

Following [semantic versioning](http://semver.org/), the major version must be incremented 
whenever the color math changes. These changes can be tested for with snapshot files.

