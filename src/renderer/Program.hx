package renderer;

import js.html.Console;

class Program {
	final vertexShader:Shader;
	final fragmentShader:Shader;

	public final program:js.html.webgl.Program;

	public var status(default, null):Status;

	public function new(vertexShader:Shader, fragmentShader:Shader) {
		this.vertexShader = vertexShader;
		this.fragmentShader = fragmentShader;
		this.program = Renderer.gl.createProgram();
		this.status = Status.Loading;

		final linkProgram = () -> {
			Renderer.gl.attachShader(this.program, vertexShader.shader);
			Renderer.gl.attachShader(this.program, fragmentShader.shader);
			Renderer.gl.linkProgram(this.program);
			if (!Renderer.gl.getProgramParameter(this.program, GL.LINK_STATUS) && false) {
				final info = Renderer.gl.getProgramInfoLog(this.program);
				Console.error('Could not compile WebGL program. \n\n${info}');
			} else if (this.status != Status.Error) {
				this.status = Status.Succesful;
			}
		}
		if (vertexShader.status == Status.Succesful && fragmentShader.status == Status.Succesful) {
			linkProgram();
		} else {
			vertexShader.onSuccess += (shader) -> {
				if (this.fragmentShader.status == Status.Succesful) {
					linkProgram();
				}
			};
			fragmentShader.onSuccess += (shader) -> {
				if (this.vertexShader.status == Status.Succesful) {
					linkProgram();
				}
			};

			vertexShader.onError += (shader, msg) -> {
				this.status = Status.Error;
			};
			fragmentShader.onError += (shader, msg) -> {
				this.status = Status.Error;
			};
		}
	}

	public function bind() {
		Renderer.gl.useProgram(program);
	}
}
