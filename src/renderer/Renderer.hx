package renderer;

import assets.AssetSystem;
import glm.Mat4;
import glm.Vec2;
import haxe.io.Float32Array;
import js.Browser;
import js.html.CanvasElement;
import renderer.InputLayout;
import renderer.Shader;
import utils.LinearAllocator;

@:structInit
class Quad {
	public var pos:Vec2;
	public var size:Vec2;
}

function quad():Quad {
	return {
		pos: new Vec2(0.0),
		size: new Vec2(0.0),
	};
}

class Renderer {
	public static final quadsToDraw:LinearAllocator<Quad> = new LinearAllocator<Quad>(2048, quad);
	public static final canvas:CanvasElement = getCanvasElement('webgl');
	public static final gl:GL = canvas.getContextWebGL2();
	public static final mainProgram:Program = new Program(new Shader('vertex.glsl', ShaderType.Vertex), new Shader('fragment.glsl', ShaderType.Fragment));
	public static final triangle:VertexBuffer = new VertexBuffer(Float32Array.fromArray([
		// Vertex 0
		- 1.0, // X
		- 1.0, // Y
		0.0, // Z
		0.0, // U
		1.0, // V
		// Vertex 1
		- 1.0, // X
		1.0, // Y
		0.0, // Z
		0.0, // U
		0.0, // V
		// Vertex 2
		1.0, // X
		1.0, // Y
		0.0, // Z
		1.0, // U
		0.0, // V,
		// Vertex 3
		- 1.0, // X
		- 1.0, // Y
		0.0, // Z
		0.0, // U
		1.0, // V
		// Vertex 4
		1.0, // X
		1.0, // Y
		0.0, // Z
		1.0, // U
		0.0, // V,
		// Vertex 5
		1.0, // X
		- 1.0, // Y
		0.0, // Z
		1.0, // U
		1.0, // V
	]).view);
	public static final inputLayout:InputLayout = new InputLayout([
		new InputElementDesc('a_position', Format.RGB32_FLOAT),
		new InputElementDesc('a_uv', Format.RG32_FLOAT)
	]);
	public static final texture:Texture = Texture.fromImage("f-texture.png");
	public static final texture2:Texture = Texture.fromKtx(AssetSystem.assetsrc.f_texture);

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

	public static function resize() {
		if (canvas.width != canvas.clientWidth || canvas.height != canvas.clientHeight) {
			canvas.width = canvas.clientWidth;
			canvas.height = canvas.clientHeight;
			gl.viewport(0, 0, gl.drawingBufferWidth, gl.drawingBufferHeight);
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
		texture2.bind(mainProgram, "u_texture");

		mainProgram.setVec2("u_test", new Vec2(0.25, 1.0));

		for (i in 0...quadsToDraw.length) {
			final quad = quadsToDraw.data[i];
			gl.viewport(Std.int(quad.pos.x), Std.int(quad.pos.y), Std.int(quad.size.x), Std.int(quad.size.y));
			gl.drawArrays(GL.TRIANGLES, 0, 6);
		}

		quadsToDraw.reset();
	}
}
