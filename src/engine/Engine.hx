package engine;

class Engine {
    public var test:Int;

    public function new() {
        test = 42;
    }
}

// top-level function, procedural style
function start(engine:Engine) {
    trace("Engine test value: " + engine.test);
}