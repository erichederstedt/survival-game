package engine;

class Engine {
	public static var should_stop(default, null):Bool = true;
	public static var delta_time(default, null):Float = 0.0;
	public static var frame_delta_time(default, null):Float = 0.0;
	static var _main_loop:() -> Void = null;

	public static function start(main_loop:() -> Void) {
		trace("Starting engine");
		should_stop = false;
		_main_loop = main_loop;
		Input.init();

		#if js
		var loop = null;
		loop = (_) -> {
			update();
			if (!should_stop)
				js.Browser.window.requestAnimationFrame(loop);
		};
		js.Browser.window.requestAnimationFrame(loop);
		#else
		while (!should_stop) {
			main_loop();
			Sys.sleep(1 / 60);
		}
		#end
	}

	public static function stop() {
		should_stop = true;
		trace("Stopping engine");
	}

	static var delta_time_record:Array<Float> = [];
	static var frame_delta_time_record:Array<Float> = [];

	static function update() {
		static var ts0:Float = 0.0;
		final ts1 = ts0;
		ts0 = Timer.sample();
		delta_time = ts0 - ts1;

		delta_time_record.push(delta_time);
		frame_delta_time_record.push(frame_delta_time);
		if (delta_time_record.length > 165) {
			var average_dt = 0.0;
			var average_fdt = 0.0;
			for (i in 0...delta_time_record.length) {
				average_dt += delta_time_record[i];
				average_fdt += frame_delta_time_record[i];
			}
			average_dt /= delta_time_record.length;
			average_fdt /= delta_time_record.length;
			trace("DT:" + average_dt);
			trace("FDT:" + average_fdt);
			delta_time_record = [];
			frame_delta_time_record = [];
		}

		if (_main_loop != null)
			_main_loop();

		Input.update();

		final ts2 = Timer.sample();
		frame_delta_time = ts2 - ts0;
	}
}
