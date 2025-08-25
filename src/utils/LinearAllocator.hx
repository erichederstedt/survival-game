package utils;

import haxe.Constraints.Constructible;
import haxe.ds.Vector;
import thx.Assert;

@:generic
class LinearAllocator<T> {
	public var data(default, null):Vector<T>;
	public var length(default, null):Int;
	public var size(default, null):Int;

	final _constructor:() -> T;

	public function new(size:Int, _constructor:() -> T) {
		this.data = new Vector(size, null);
		this.length = 0;
		this.size = size;
		this._constructor = _constructor;
	}

	public function alloc():T {
		Assert.isTrue(this.length < (this.size - 1));
		if (this.data[this.length] == null)
			this.data[this.length] = this._constructor();
		return this.data[this.length++];
	}

	public function reset() {
		this.length = 0;
	}
}
