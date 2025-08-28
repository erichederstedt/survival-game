package utils;

@:forward(iterator)
abstract Range(Array<Int>) to (Array<Int>) {
	public function new(min:Int, max:Int) {
		this = if (max > min) {
			[for (i in min...max) i];
		} else if (min > max) {
			final result = [];
			var i = min;
			while (i > max) {
				result.push(i);
				i--;
			}
			result;
		} else {
			[];
		}
	}
}
