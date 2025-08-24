package renderer;

import haxe.io.ArrayBufferView;
import renderer.Buffer.BufferType;

class VertexBuffer {
	final buffer:Buffer;
	final vertexArrayObject:js.html.webgl.VertexArrayObject;

	public function new(data:ArrayBufferView) {
		this.buffer = new Buffer(BufferType.Array, data);
		this.vertexArrayObject = Renderer.gl.createVertexArray();
	}

	public function bind() {
		Renderer.gl.bindVertexArray(vertexArrayObject);
		buffer.bind();
	}

	public function unbind() {
		Renderer.gl.bindVertexArray(null);
		this.buffer.unbind();
	}
}
