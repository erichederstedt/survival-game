package renderer;

import glm.Mat2;
import glm.Mat3;
import glm.Mat4;
import glm.Vec2;
import glm.Vec3;
import glm.Vec4;
import js.html.Console;
import js.html.webgl.UniformLocation;
import utils.Range;

class VertexAttrib {
	public final name:String;
	public final size:Int;
	public final type:Int;
	public final location:Int;

	public function new(name:String, size:Int, type:Int, location:Int) {
		this.name = name;
		this.size = size;
		this.type = type;
		this.location = location;
	}
}

class Uniform {
	public final name:String;
	public final type:Int;
	public final size:Int;
	public final blockIndex:Int;
	public final offset:Int;
	public final location:UniformLocation;

	public function new(name:String, type:Int, size:Int, blockIndex:Int, offset:Int, location:UniformLocation) {
		this.name = name;
		this.type = type;
		this.size = size;
		this.blockIndex = blockIndex;
		this.offset = offset;
		this.location = location;
	}
}

class Program {
	final vertexShader:Shader;
	final fragmentShader:Shader;
	final vertexAttribMap:Map<String, VertexAttrib>;
	final uniformMap:Map<String, Uniform>;

	public final program:js.html.webgl.Program;

	public var status(default, null):Status;

	public function new(vertexShader:Shader, fragmentShader:Shader) {
		this.vertexShader = vertexShader;
		this.fragmentShader = fragmentShader;
		this.vertexAttribMap = new Map();
		this.uniformMap = new Map();
		this.program = Renderer.gl.createProgram();
		this.status = Status.Loading;

		final linkProgram = () -> {
			Renderer.gl.attachShader(this.program, vertexShader.shader);
			Renderer.gl.attachShader(this.program, fragmentShader.shader);
			Renderer.gl.linkProgram(this.program);
			if (!Renderer.gl.getProgramParameter(this.program, GL.LINK_STATUS)) {
				final info = Renderer.gl.getProgramInfoLog(this.program);
				Console.error('Could not compile WebGL program. \n\n${info}');
			} else if (this.status != Status.Error) {
				this.status = Status.Succesful;

				for (i in 0...Renderer.gl.getProgramParameter(program, GL.ACTIVE_ATTRIBUTES)) {
					final attrib = Renderer.gl.getActiveAttrib(program, i);
					trace('Attribute: ${attrib.name}, Size: ${attrib.size}, Type: ${GL.glEnumToString(attrib.type)}');
					vertexAttribMap[attrib.name] = new VertexAttrib(attrib.name, attrib.size, attrib.type, Renderer.gl.getAttribLocation(program, attrib.name));
				}

				final uniformCount = Renderer.gl.getProgramParameter(program, GL.ACTIVE_UNIFORMS);
				final uniformRange = new Range(0, uniformCount);
				final uniformBlocks:Array<Int> = Renderer.gl.getActiveUniforms(program, uniformRange, GL.UNIFORM_BLOCK_INDEX);
				final uniformOffsets:Array<Int> = Renderer.gl.getActiveUniforms(program, uniformRange, GL.UNIFORM_OFFSET);
				for (i in uniformRange) {
					final uniformInfo = Renderer.gl.getActiveUniform(program, i);
					if (isBuiltIn(uniformInfo.name)) {
						continue;
					}
					final name = uniformInfo.name;
					final type = uniformInfo.type;
					final size = uniformInfo.size;
					final blockIndex = uniformBlocks[i];
					final offset = uniformOffsets[i];

					trace('Uniform: ${name}, Type: ${GL.glEnumToString(type)}, size: ${size}, block index: ${blockIndex}, offset: ${offset}');
					uniformMap[name] = new Uniform(name, type, size, blockIndex, offset, Renderer.gl.getUniformLocation(program, name));
				}
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

	public function setFloatArray(name:String, data:Array<Float>) {
		final uniform = uniformMap[name + "[0]"];
		if (uniform == null)
			return; // Should probably throw error

		Renderer.gl.uniform1fv(uniform.location, data);
	}

	public function setFloat(name:String, data:Float) {
		final uniform = uniformMap[name];
		if (uniform == null)
			return; // Should probably throw error

		Renderer.gl.uniform1f(uniform.location, data);
	}

	public function setVec2(name:String, data:Vec2) {
		final uniform = uniformMap[name];
		if (uniform == null)
			return; // Should probably throw error

		Renderer.gl.uniform2f(uniform.location, data.x, data.y);
	}

	public function setVec3(name:String, data:Vec3) {
		final uniform = uniformMap[name];
		if (uniform == null)
			return; // Should probably throw error

		Renderer.gl.uniform3f(uniform.location, data.x, data.y, data.z);
	}

	public function setVec4(name:String, data:Vec4) {
		final uniform = uniformMap[name];
		if (uniform == null)
			return; // Should probably throw error

		Renderer.gl.uniform4f(uniform.location, data.x, data.y, data.z, data.w);
	}

	public function setMat2(name:String, data:Mat2, transpose:Bool = false,) {
		final uniform = uniformMap[name];
		if (uniform == null)
			return; // Should probably throw error

		Renderer.gl.uniformMatrix2fv(uniform.location, transpose, data.toFloatArray(), 0, 0);
	}

	public function setMat3(name:String, data:Mat3, transpose:Bool = false,) {
		final uniform = uniformMap[name];
		if (uniform == null)
			return; // Should probably throw error

		Renderer.gl.uniformMatrix3fv(uniform.location, transpose, data.toFloatArray(), 0, 0);
	}

	public function setMat4(name:String, data:Mat4, transpose:Bool = false,) {
		final uniform = uniformMap[name];
		if (uniform == null)
			return; // Should probably throw error

		Renderer.gl.uniformMatrix4fv(uniform.location, transpose, data.toFloatArray(), 0, 0);
	}

	public function setUInt(name:String, data:UInt) {
		final uniform = uniformMap[name];
		if (uniform == null)
			return; // Should probably throw error

		Renderer.gl.uniform1ui(uniform.location, data);
	}

	public function setUInt2(name:String, data:Array<UInt>) {
		final uniform = uniformMap[name];
		if (uniform == null)
			return; // Should probably throw error

		Renderer.gl.uniform2ui(uniform.location, data[0], data[1]);
	}

	public function setUInt3(name:String, data:Array<UInt>) {
		final uniform = uniformMap[name];
		if (uniform == null)
			return; // Should probably throw error

		Renderer.gl.uniform3ui(uniform.location, data[0], data[1], data[2]);
	}

	public function setUInt4(name:String, data:Array<UInt>) {
		final uniform = uniformMap[name];
		if (uniform == null)
			return; // Should probably throw error

		Renderer.gl.uniform4ui(uniform.location, data[0], data[1], data[2], data[3]);
	}

	public function setInt(name:String, data:Int) {
		final uniform = uniformMap[name];
		if (uniform == null)
			return; // Should probably throw error

		Renderer.gl.uniform1i(uniform.location, data);
	}

	public function setInt2(name:String, data:Array<Int>) {
		final uniform = uniformMap[name];
		if (uniform == null)
			return; // Should probably throw error

		Renderer.gl.uniform2i(uniform.location, data[0], data[1]);
	}

	public function setInt3(name:String, data:Array<Int>) {
		final uniform = uniformMap[name];
		if (uniform == null)
			return; // Should probably throw error

		Renderer.gl.uniform3i(uniform.location, data[0], data[1], data[2]);
	}

	public function setInt4(name:String, data:Array<Int>) {
		final uniform = uniformMap[name];
		if (uniform == null)
			return; // Should probably throw error

		Renderer.gl.uniform4i(uniform.location, data[0], data[1], data[2], data[3]);
	}

	function isBuiltIn(name:String):Bool {
		return name.lastIndexOf("gl_") == 0 || name.lastIndexOf("webgl_") == 0;
	}
}
