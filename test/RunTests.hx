import haxe.unit.TestRunner;

class RunTests {    
    static public function main () {
        var runner = new TestRunner();
        runner.add(new ColorConverterTest());
        runner.run();
    }
}