# Husl
## Human-Friendly HSL color space library
## Port from [husl-java]

**Note** : this is a WIP small project. Expect things to break or change here and there.

## Testing

**Note**: this doesn't replace a standard testing procedure. An unit test has been ported from [husl-java] to make sure the library was working during development. I have tested on an Archlinux x64 with Haxe 3.3.0.

You can also test yourself the library by running `haxe tests.hxml`. It'll run with Haxe's built-in interpreter.

Seems to work on some targets. Here are the tests that couldn't pass on my computer :
- PHP : PHP7 parseInt function doesn't convert hexadecimal values anymore.

Tests to do:
- SWF
- Windows and Mac

[husl-java]: https://github.com/husl-colors/husl-java
