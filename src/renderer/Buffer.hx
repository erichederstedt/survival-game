package renderer;

import haxe.io.ArrayBufferView;

enum abstract BufferType(Int) to Int {
	var Array = GL.ARRAY_BUFFER;
	var ElementArray = GL.ELEMENT_ARRAY_BUFFER;
}

class Buffer {
	final buffer:js.html.webgl.Buffer;
	final target:BufferType;

	public function new(target:BufferType, data:ArrayBufferView) {
		this.buffer = Renderer.gl.createBuffer();
		this.target = target;

		updateData(data);
	}

	public function bind() {
		Renderer.gl.bindBuffer(this.target, buffer);
	}

	public function unbind() {
		Renderer.gl.bindBuffer(this.target, null);
	}

	public function updateData(data:ArrayBufferView) {
		bind();
		Renderer.gl.bufferData(this.target, data.getData(), GL.STATIC_DRAW);
	}
}
