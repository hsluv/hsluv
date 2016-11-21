[![Build Status](https://travis-ci.org/husl-colors/husl.svg?branch=master)](https://travis-ci.org/husl-colors/husl)
[![NPM package](https://img.shields.io/npm/v/husl.svg)](https://www.npmjs.com/package/husl)

# HUSL - Human-friendly HSL

[Explanation, demo, ports etc.](http://www.husl-colors.org)

The reference implementation is [written in Haxe](https://github.com/husl-colors/husl/tree/master/haxe).

## Building

Requirements: GNU Make, Haxe 3, JDK 7+.

To build the JavaScript version:

```sh
make javascript/dist/husl.min.js
```

To build Haxe documentation:

```sh
make dist/doc
```

## Versioning

Following [semantic versioning](http://semver.org/), the major version must be incremented 
whenever the color math changes. These changes can be tested for with snapshot files.
