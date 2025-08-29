package renderer;

import haxe.io.UInt32Array;
import renderer.Buffer.BufferType;

class IndexBuffer {
	final buffer:Buffer;

	public final length:Int;

	public function new(data:UInt32Array) {
		this.buffer = new Buffer(BufferType.ElementArray, data.get_view());
		this.length = data.length;
	}

	public function bind() {
		buffer.bind();
	}
}
