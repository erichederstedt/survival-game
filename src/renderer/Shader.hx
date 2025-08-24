package renderer;

import haxe.Http;
import haxe.Signal;
import js.html.Console;

enum abstract ShaderType(Int) to Int {
	var Vertex = GL.VERTEX_SHADER;
	var Fragment = GL.FRAGMENT_SHADER;
}

class Shader {
	public final path:String;
	public final type:ShaderType;
	public final shader:js.html.webgl.Shader;
	public var status(default, null):Status;

	public var onSuccess:Signal<(shader:Shader) -> Void>;
	public var onError:Signal<(shader:Shader, msg:String) -> Void>;

	public function new(path:String, type:ShaderType, ?onSuccess:(shader:Shader) -> Void, ?onError:(shader:Shader, msg:String) -> Void) {
		this.path = path;
		this.type = type;
		this.shader = Renderer.gl.createShader(type);
		this.status = Status.Loading;
		this.onError = new Signal();
		this.onSuccess = new Signal();

		if (onSuccess != null)
			this.onSuccess += onSuccess;
		if (onError != null)
			this.onError += onError;

		final req = new Http(path);
		req.onData = (data:String) -> {
			trace(data);

			Renderer.gl.shaderSource(this.shader, data);
			Renderer.gl.compileShader(this.shader);
			if (!Renderer.gl.getShaderParameter(shader, GL.COMPILE_STATUS)) {
				final info = Renderer.gl.getShaderInfoLog(shader);
				Console.error('Shader failed to compile: ${info}');

				this.status = Status.Error;
				this.onError(this, info);
			} else {
				this.status = Status.Succesful;
				this.onSuccess(this);
			}
		};
		req.onError = (msg:String) -> {
			this.status = Status.Error;
			Console.error('Failed to load shader! Path: ${path}\n${msg}');

			this.onError(this, msg);
		};
		req.request(false);
	}
}
