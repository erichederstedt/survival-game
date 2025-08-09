package engine;

#if js
import js.Browser;
#else
import haxe.Timer;
#end

class Timer {
	public static function sample():Float {
		#if js
		return Browser.window.performance.now();
		#else
		return Timer.stamp();
		#end
	}
}
