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

## Testing

```sh
# Unit testing (with haxe's built-in compiler)
haxe -cp src -cp test -main RunTests -resource test/resources/snapshot-rev4.json@snapshot-rev4 --interp
# For specific targets, replace --interp by the matching compilation flags for your target.
#  (Java)
haxe -cp src -cp test -main RunTests -resource test/resources/snapshot-rev4.json@snapshot-rev4 -java bin/java -cmd java -jar bin/java/RunTests.jar
# (CPP)
haxe -cp src -cp test -main RunTests -resource test/resources/snapshot-rev4.json@snapshot-rev4 -cpp bin/cpp -cmd bin/cpp/RunTests
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
