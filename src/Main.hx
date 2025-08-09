package;

import engine.*;

class Main {
	public static function main() {
		Engine.start();

		#if js
		var loop = null;
		loop = (_) -> {
			mainLoop();
			if (!Engine.should_stop)
				js.Browser.window.requestAnimationFrame(loop);
		};
		js.Browser.window.requestAnimationFrame(loop);
		#else
		while (!Engine.should_stop) {
			mainLoop();
			Sys.sleep(1 / 60);
		}
		#end
	}

	public static function mainLoop() {
		trace("fuck");
	}
}
