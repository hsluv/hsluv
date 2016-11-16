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
# Global language test (You have to install the libraries to set up the languages' compilation workflow.)
haxe tests.hxml
# Specific language.
haxe -cp src -cp test -main RunTests --interp
# Replace --interp by your prefered compilation flags such as
#  (Java)
haxe -cp src -cp test -main RunTests --java bin/java -cmd java bin/java/RunTests.jar
# (CPP)
haxe -cp src -cp test -main RunTests --cpp bin/cpp -cmd java bin/cpp/RunTests
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
