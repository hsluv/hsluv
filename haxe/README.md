# Husl-Haxe
## Human-Friendly HSL color space library for Haxe 3
## Port from [husl-java]

**Note** : this is a WIP small project. Expect things to break or change here and there.

## Usage
Once imported, use the library by importing Husl. Here's an example:

```haxe
package;
import husl.Husl;

public class Main {
    public static function main() {
        trace(Husl.rgbToHex([1,1,1])); // Will print "#FFFFFF"
    }
}
```

### Color values ranges
- RGB values are ranging in [0;1]
- Husl and Huslp values have different ranging for their components
    - H : [0;360]
    - S and L : [0;100]
- LUV has different ranging for their components
    - L* : [0;100]
    - u* and v* : [-100;100]
- LCH has different ranging for their components
    - L* : [0;100]
    - C* : [0; ?] Upper bound varies depending on L* and H*
    - H* : [0; 360]
- XYZ values are ranging in [0;1]

### API functions

#### Note
The passing/returning values, when not `String` are `Array<Float>` containing each component of the given color space/system in the name's order :
- RGB : [red, blue, green]
- XYZ : [X, Y, Z]
- LCH : [L, C, H]
- LUV : [L, u, v]
- Husl/HuslP : [H, S, L]

#### Function listing
- `xyzToRgb(tuple:Array<Float>)`
- `rgbToXyz(tuple:Array<Float>)`
- `xyzToLuv(tuple:Array<Float>)`
- `luvToXyz(tuple:Array<Float>)`
- `luvToLch(tuple:Array<Float>)`
- `lchToLuv(tuple:Array<Float>)`
- `huslToLch(tuple:Array<Float>)`
- `lchToHusl(tuple:Array<Float>)`
- `huslpToLch(tuple:Array<Float>)`
- `lchToHuslp(tuple:Array<Float>)`
- `lchToRgb(tuple:Array<Float>)`
- `rgbToLch(tuple:Array<Float>)`
- `huslToRgb(tuple:Array<Float>)`
- `rgbToHusl(tuple:Array<Float>)`
- `huslpToRgb(tuple:Array<Float>)`
- `rgbToHuslp(tuple:Array<Float>)`
- `huslToHex(tuple:Array<Float>)`
- `huslpToHex(tuple:Array<Float>)`
- `hexToHusl(s:String)`
- `hexToHuslp(s:String)`
- `rgbToHex(tuple:Array<Float>)`
- `hexToRgb(hex:String)`

## Testing

```sh
# Prefered way : Haxe's builtin interpreter. Doesn't require any external libs to execute the tests.
haxe -cp src -cp test -main RunTests -resource test/resources/snapshot-rev4.json@snapshot-rev4 --interp
# Neko
haxe -cp src -cp test -main RunTests -resource test/resources/snapshot-rev4.json@snapshot-rev4 -x bin/neko/RunTests.n
# CPP Linux
haxe -cp src -cp test -main RunTests -resource test/resources/snapshot-rev4.json@snapshot-rev4 -cpp bin/cpp -cmd bin/cpp/RunTests
# CPP Windows
haxe -cp src -cp test -main RunTests -resource test/resources/snapshot-rev4.json@snapshot-rev4 -cpp bin/cpp -cmd bin/cpp/RunTests.exe
# C# Linux
haxe -cp src -cp test -main RunTests -resource test/resources/snapshot-rev4.json@snapshot-rev4 -cs bin/cs -cmd mono bin/cs/RunTests.exe
# C# Windows
haxe -cp src -cp test -main RunTests -resource test/resources/snapshot-rev4.json@snapshot-rev4 -cs bin/cs -cmd bin/cs/RunTests.exe
#  Java
haxe -cp src -cp test -main RunTests -resource test/resources/snapshot-rev4.json@snapshot-rev4 -java bin/java -cmd java -jar bin/java/RunTests.jar
#  PHP
haxe -cp src -cp test -main RunTests -resource test/resources/snapshot-rev4.json@snapshot-rev4 -php bin/php -cmd php bin/php/index.php
#  NodeJS
haxe -cp src -cp test -main RunTests -resource test/resources/snapshot-rev4.json@snapshot-rev4 -js bin/js/RunTests.js -cmd node bin/js/RunTests.js
#  Python
haxe -cp src -cp test -main RunTests -resource test/resources/snapshot-rev4.json@snapshot-rev4 -python bin/python/RunTests.py -cmd python bin/python/RunTests.py
#  Lua
haxe -cp src -cp test -main RunTests -resource test/resources/snapshot-rev4.json@snapshot-rev4 -lua bin/lua/RunTests.lua -cmd lua bin/lua/RunTests.lua
# And so on...
```


# Notes
**Note**: An unit test has been ported from [husl-java] to make sure the library was working during development.

Husl-haxe seems to work on some targets. Here are the tests that couldn't pass on my computer :
- PHP : PHP7 parseInt function doesn't convert hexadecimal values anymore.

Tests to do:
- SWF
- Windows and Mac

[husl-java]: https://github.com/husl-colors/husl-java
