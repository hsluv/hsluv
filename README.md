# Husl
## Human-Friendly HSL color space library
## Port from [husl-java]

**Note** : this is a WIP small project. Expect things to break or change here and there.

## Testing

**Note**: this doesn't replace a standard testing procedure. An unit test has been ported from [husl-java] to make sure the library was working during development. I have tested on an Archlinux x64 with Haxe 3.3.0.

You can also test yourself the library by running `haxe tests.hxml`. It'll run with Haxe's built-in interpreter.



Seems to work on some targets. PHP seems to break on int parsing.
Tests working in:
- Interpreter (`--interp`)
- Python (found an issue with a divie by zero)    
- Lua (found an issue with integer parsing)

Tests not working in:
- PHP : Std.parseInt doesn't work with hexadecimal values.

*More to come...*

[husl-java]: https://github.com/husl-colors/husl-java
