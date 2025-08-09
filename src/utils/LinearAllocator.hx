package utils;

import thx.Assert;
import haxe.ds.Vector;

class LinearAllocator<T> {
	public var data(default, null):Vector<T>;
	public var length(default, null):Int;
	public var size(default, null):Int;

	public function new(size:Int, default_value:T = null) {
		this.data = new Vector(size, default_value);
		this.length = 0;
		this.size = size;
	}

	public function alloc() {
		Assert.isTrue(this.length < (this.size - 1));
		return this.data[this.length++];
	}

	public function reset() {
		this.length = 0;
	}
}
