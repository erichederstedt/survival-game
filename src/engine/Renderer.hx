package engine;

import engine.Format.FormatInfo;
import haxe.io.Float32Array;
import haxe.io.ArrayBufferView;
import js.html.Console;
import haxe.Http;
import js.lib.Uint8Array;
import js.html.webgl.Texture;
import js.html.Image;
import utils.LinearAllocator;
import VectorMath;
import js.Browser;
import js.html.CanvasElement;
import js.html.webgl.WebGL2RenderingContext;
import haxe.Signal;

@:structInit
class Quad {
	public var pos:Vec2;
	public var size:Vec2;
}

function quad():Quad {
	return {
		pos: vec2(0.0),
		size: vec2(0.0),
	};
}

@:structInit
class Texture {
	public var path:String;
	public var image:Image;
	public var gl_texture:js.html.webgl.Texture;
}

function texture():Texture {
	return {
		path: '',
		image: new Image(),
		gl_texture: Renderer.gl.createTexture()
	};
}

typedef GL = WebGL2RenderingContext;

enum abstract ShaderType(Int) to Int {
	var Vertex = GL.VERTEX_SHADER;
	var Fragment = GL.FRAGMENT_SHADER;
}

enum abstract Status(Int) {
	var Loading;
	var Succesful;
	var Error;
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
		this.onError = new Signal<(shader:Shader, msg:String) -> Void>();
		this.onSuccess = new Signal<(shader:Shader) -> Void>();

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

@:structInit
class InputElementDesc {
	public final attributeName:String;
	public final format:Format;

	public function new(attributeName:String, format:Format) {
		this.attributeName = attributeName;
		this.format = format;
	}
}

class InputLayout {
	final layout:Array<InputElementDesc>;
	final offsets:Array<Int>;
	final vertexSize:Int;

	public function new(layout:Array<InputElementDesc>) {
		this.layout = layout.copy();
		this.offsets = [];
		var vertexSize:Int = 0;
		for (i in 0...layout.length) {
			this.offsets.push(vertexSize);
			vertexSize += FormatInfo[layout[i].format].totalSize;
		}
		this.vertexSize = vertexSize;
	}

	public function bind(program:Program) {
		for (i in 0...layout.length) {
			final element:InputElementDesc = layout[i];
			final elementFormat = FormatInfo[element.format];
			final attributeLocation:Int = Renderer.gl.getAttribLocation(program.program, element.attributeName);

			if (attributeLocation == -1) {
				Console.warn('Attribute ${element.attributeName} not found!');
				continue;
			}

			Renderer.gl.enableVertexAttribArray(attributeLocation);

			final isInteger = (elementFormat.webglType == GL.BYTE
				|| elementFormat.webglType == GL.UNSIGNED_BYTE
				|| elementFormat.webglType == GL.SHORT
				|| elementFormat.webglType == GL.UNSIGNED_SHORT
				|| elementFormat.webglType == GL.INT
				|| elementFormat.webglType == GL.UNSIGNED_INT)
				&& elementFormat.webglType != GL.FLOAT
				&& elementFormat.webglType != GL.HALF_FLOAT;

			if (isInteger) {
				Renderer.gl.vertexAttribIPointer(attributeLocation, // Attribute location
					elementFormat.elementCount, // Element count
					elementFormat.webglType, // Type
					this.vertexSize, // Stride
					this.offsets[i] // Offset
				);
			} else {
				Renderer.gl.vertexAttribPointer(attributeLocation, // Attribute location
					elementFormat.elementCount, // Element count
					elementFormat.webglType, // Type
					false, // Normalized
					this.vertexSize, // Stride
					this.offsets[i] // Offset
				);
			}
		}
	}
}

class Renderer {
	public static final quadsToDraw:LinearAllocator<Quad> = new LinearAllocator<Quad>(2048, quad());
	public static final canvas:CanvasElement = getCanvasElement('webgl');
	public static final gl:GL = canvas.getContextWebGL2();
	public static final mainProgram:Program = new Program(new Shader('vertex.glsl', ShaderType.Vertex), new Shader('fragment.glsl', ShaderType.Fragment));
	public static final triangle:VertexBuffer = new VertexBuffer(Float32Array.fromArray([
		// X,    Y,    Z,    U,    V   (Vertex 1)
		0.0,
		0.5,
		0.0,
		0.5,
		1.0,
		// X,    Y,    Z,    U,    V   (Vertex 2)
		- 0.5,
		-0.5,
		0.0,
		0.0,
		0.0,
		// X,    Y,    Z,    U,    V   (Vertex 3)
		0.5,
		-0.5,
		0.0,
		1.0,
		0.0,
	]).view);
	public static final inputLayout:InputLayout = new InputLayout([
		new InputElementDesc('a_position', Format.RGB32_FLOAT),
		new InputElementDesc('a_uv', Format.RG32_FLOAT)
	]);

	public static function getCanvasElement(id:String):CanvasElement {
		var element = Browser.document.getElementById(id);
		if (element == null)
			return null;

		return cast(element, CanvasElement);
	}

	public static function drawQuad(pos:Vec2, size:Vec2) {
		var quad = quadsToDraw.alloc();
		quad.pos = pos;
		quad.size = size;
	}

	public static function loadTexture(path:String, generate_mip_maps:Bool = true):Texture {
		final texture = texture();
		texture.path = path;

		gl.bindTexture(GL.TEXTURE_2D, texture.gl_texture);
		gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, 1, 1, 0, GL.RGBA, GL.UNSIGNED_BYTE, new Uint8Array([0, 0, 255, 255]));

		texture.image.src = path;
		texture.image.addEventListener('load', () -> {
			gl.bindTexture(GL.TEXTURE_2D, texture.gl_texture);
			gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, texture.image);
			if (generate_mip_maps)
				gl.generateMipmap(GL.TEXTURE_2D);
		});

		return texture;
	}

	public static function resize() {
		if (canvas.width != canvas.clientWidth || canvas.height != canvas.clientHeight) {
			canvas.width = canvas.clientWidth;
			canvas.height = canvas.clientHeight;
		}
	}

	public static function render() {
		resize();

		gl.clearColor(0, 0, 0, 1);
		gl.clear(GL.COLOR_BUFFER_BIT);

		if (mainProgram.status != Status.Succesful) {
			quadsToDraw.reset();
			return;
		}

		mainProgram.bind();
		triangle.bind();
		inputLayout.bind(mainProgram);
		gl.drawArrays(GL.TRIANGLES, 0, 3);

		/*
			gl.enable(GL.SCISSOR_TEST);
			gl.clearColor(1, 0, 0, 1);
			for (quad in quadsToDraw.data) {
				gl.scissor(Std.int(quad.pos.x), Std.int(quad.pos.y), Std.int(quad.size.x), Std.int(quad.size.y));
				gl.clear(GL.COLOR_BUFFER_BIT);
			}
			gl.disable(GL.SCISSOR_TEST);
		 */

		quadsToDraw.reset();
	}
}
