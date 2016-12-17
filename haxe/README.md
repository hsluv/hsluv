# Reference implementation

## Usage
Once imported, use the library by importing Hsluv. Here's an example:

```haxe
package;
import hsluv.Hsluv;

public class Main {
    public static function main() {
        trace(Hsluv.rgbToHex([1,1,1])); // Will print "#FFFFFF"
    }
}
```

### Color values ranges
- RGB values are ranging in [0;1]
- HSLuv and HPLuv values have different ranging for their components
    - H : [0;360]
    - S and L : [0;100]
- LUV has different ranging for their components
    - L* : [0;100]
    - u* and v* : [-100;100]
- LCh has different ranging for their components
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
- HSLuv/HPLuv : [H, S, L]

#### Function listing
- `xyzToRgb(tuple:Array<Float>)`
- `rgbToXyz(tuple:Array<Float>)`
- `xyzToLuv(tuple:Array<Float>)`
- `luvToXyz(tuple:Array<Float>)`
- `luvToLch(tuple:Array<Float>)`
- `lchToLuv(tuple:Array<Float>)`
- `hsluvToLch(tuple:Array<Float>)`
- `lchToHsluv(tuple:Array<Float>)`
- `hpluvToLch(tuple:Array<Float>)`
- `lchToHpluv(tuple:Array<Float>)`
- `lchToRgb(tuple:Array<Float>)`
- `rgbToLch(tuple:Array<Float>)`
- `hsluvToRgb(tuple:Array<Float>)`
- `rgbToHsluv(tuple:Array<Float>)`
- `hpluvToRgb(tuple:Array<Float>)`
- `rgbToHpluv(tuple:Array<Float>)`
- `hsluvToHex(tuple:Array<Float>)`
- `hpluvToHex(tuple:Array<Float>)`
- `hexToHsluv(s:String)`
- `hexToHpluv(s:String)`
- `rgbToHex(tuple:Array<Float>)`
- `hexToRgb(hex:String)`

## Testing

```sh
# Prefered way : Haxe's builtin interpreter. Doesn't require any external libs to execute the tests.
haxe -cp src -cp test -main RunTests -resource ../snapshots/snapshot-rev4.json@snapshot-rev4 --interp
# Neko
haxe -cp src -cp test -main RunTests -resource ../snapshots/snapshot-rev4.json@snapshot-rev4 -x bin/neko/RunTests.n
# CPP Linux
haxe -cp src -cp test -main RunTests -resource ../snapshots/snapshot-rev4.json@snapshot-rev4 -cpp bin/cpp -cmd bin/cpp/RunTests
# CPP Windows
haxe -cp src -cp test -main RunTests -resource ../snapshots/snapshot-rev4.json@snapshot-rev4 -cpp bin/cpp -cmd bin/cpp/RunTests.exe
# C# Linux
haxe -cp src -cp test -main RunTests -resource ../snapshots/snapshot-rev4.json@snapshot-rev4 -cs bin/cs -cmd mono bin/cs/RunTests.exe
# C# Windows
haxe -cp src -cp test -main RunTests -resource ../snapshots/snapshot-rev4.json@snapshot-rev4 -cs bin/cs -cmd bin/cs/RunTests.exe
# Java
haxe -cp src -cp test -main RunTests -resource ../snapshots/snapshot-rev4.json@snapshot-rev4 -java bin/java -cmd java -jar bin/java/RunTests.jar
# PHP
haxe -cp src -cp test -main RunTests -resource ../snapshots/snapshot-rev4.json@snapshot-rev4 -php bin/php -cmd php bin/php/index.php
# NodeJS
haxe -cp src -cp test -main RunTests -resource ../snapshots/snapshot-rev4.json@snapshot-rev4 -js bin/js/RunTests.js -cmd node bin/js/RunTests.js
# Python
haxe -cp src -cp test -main RunTests -resource ../snapshots/snapshot-rev4.json@snapshot-rev4 -python bin/python/RunTests.py -cmd python bin/python/RunTests.py
# Lua
haxe -cp src -cp test -main RunTests -resource ../snapshots/snapshot-rev4.json@snapshot-rev4 -lua bin/lua/RunTests.lua -cmd lua bin/lua/RunTests.lua
# And so on...
```

# Notes

This code work on some targets, but here are some tests that couldn't pass on my computer:
- PHP : PHP7 parseInt function doesn't convert hexadecimal values anymore.

Tests to do:
- SWF
- Windows and Mac
