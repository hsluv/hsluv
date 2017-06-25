import haxe.unit.TestRunner;

class RunTests {    
    static public function main () {
        var runner = new TestRunner();
        runner.add(new ColorConverterTest());
        runner.run();
        var result = runner.result;
        if (!result.success) {
            #if sys
                Sys.exit(1);
            #end
        }
    }
}