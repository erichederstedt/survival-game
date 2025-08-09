package engine;

class Engine {
    public static var should_stop(default, null):Bool = true;

	public static function start() {
		should_stop = false;
		trace("Starting engine");
	}
	public static function stop() {
		should_stop = true;
		trace("Stopping engine");
	}
}