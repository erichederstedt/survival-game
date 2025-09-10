package renderer;

import assets.AssetSystem;
import glm.GLM;
import glm.Mat4;
import glm.Quat;
import glm.Vec3;
import haxe.io.Float32Array;
import haxe.io.UInt32Array;
import js.Browser;
import js.html.CanvasElement;
import renderer.InputLayout;
import renderer.Shader;
import utils.LinearAllocator;
import utils.Math;

@:structInit
class Quad {
	public var transform:Mat4;
}

function quadConstructor():Quad {
	return {
		transform: Mat4.identity(new Mat4()),
	};
}

@:structInit
class Camera {
	public var pos:Vec3;
	public var rot:Vec3;
	public var fov:Float;
	public var near:Float;
	public var far:Float;

	public static final transform:Mat4 = new Mat4();
	public static final quat:Quat = new Quat();

	public function forward():Vec3 {
		final transform = GLM.transform(pos, Quat.fromEuler(rot.x, rot.y, rot.z, quat), new Vec3(1.0, 1.0, 1.0), transform);
		return new Vec3(transform.r0c2, transform.r1c2, transform.r2c2);
	}

	public function right():Vec3 {
		final transform = GLM.transform(pos, Quat.fromEuler(rot.x, rot.y, rot.z, quat), new Vec3(1.0, 1.0, 1.0), transform);
		return new Vec3(transform.r0c0, transform.r1c0, transform.r2c0);
	}

	public function up():Vec3 {
		final transform = GLM.transform(pos, Quat.fromEuler(rot.x, rot.y, rot.z, quat), new Vec3(1.0, 1.0, 1.0), transform);
		return new Vec3(transform.r0c1, transform.r1c1, transform.r2c1);
	}
}

function camera():Camera {
	return {
		pos: new Vec3(),
		rot: new Vec3(),
		fov: Math.toRadian(60.0),
		near: 0.1,
		far: 1000.0,
	};
}

function cameraCopy(a:Camera, b:Camera) {
	Vec3.copy(b.pos, a.pos);
	Vec3.copy(b.rot, a.rot);
	a.fov = b.fov;
	a.near = b.near;
	a.far = b.far;
}

class Renderer {
	public static var spinesToDraw:Array<SpineSprite> = new Array<SpineSprite>();
	public static final quadsToDraw:LinearAllocator<Quad> = new LinearAllocator<Quad>(2048, quadConstructor);
	public static final camerasToDraw:LinearAllocator<Camera> = new LinearAllocator<Camera>(8, camera);
	public static final canvas:CanvasElement = getCanvasElement('webgl');
	public static final gl:GL = canvas.getContextWebGL2();
	public static final mainProgram:Program = new Program(new Shader('vertex.glsl', ShaderType.Vertex), new Shader('fragment.glsl', ShaderType.Fragment));
	public static final quad:VertexBuffer = new VertexBuffer(Float32Array.fromArray([
		// Vertex 0 (BR)
		1.0, // X
		- 1.0, // Y
		0.0, // Z
		1.0, // U
		1.0, // V
		// Vertex 1 (BL)
		- 1.0, // X
		- 1.0, // Y
		0.0, // Z
		0.0, // U
		1.0, // V
		// Vertex 2 (UL)
		- 1.0, // X
		1.0, // Y
		0.0, // Z
		0.0, // U
		0.0, // V
		// Vertex 3 (UR)
		1.0, // X
		1.0, // Y
		0.0, // Z
		1.0, // U
		0.0, // V,
	]).view);
	public static final inputLayout:InputLayout = new InputLayout([
		new InputElementDesc('a_position', Format.RGB32_FLOAT),
		new InputElementDesc('a_uv', Format.RG32_FLOAT)
	]);
	public static final texture:Texture = Texture.fromImage("f-texture.png");
	public static final texture2:Texture = Texture.fromKtx(AssetSystem.assetsrc.f_texture);
	public static final indexBuffer:IndexBuffer = new IndexBuffer(UInt32Array.fromArray([0, 1, 2, 2, 3, 0]));

	public static function getCanvasElement(id:String):CanvasElement {
		var element = Browser.document.getElementById(id);
		if (element == null)
			return null;

		return cast(element, CanvasElement);
	}

	public static function addCamera(camera:Camera) {
		final target = camerasToDraw.alloc();
		cameraCopy(target, camera);
	}

	public static function drawQuad(transform:Mat4) {
		var quad = quadsToDraw.alloc();
		quad.transform = transform;
	}

	public static function drawSpine(spine:SpineSprite) {
		spinesToDraw.push(spine);
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
		gl.clearDepth(0.0);
		// gl.enable(GL.CULL_FACE);
		// gl.cullFace(GL.BACK);
		gl.frontFace(GL.CW);
		gl.enable(GL.BLEND);

		if (mainProgram.status != Status.Succesful) {
			quadsToDraw.reset();
			camerasToDraw.reset();
			spinesToDraw = new Array<SpineSprite>();
			return;
		}

		mainProgram.bind();
		quad.bind();
		inputLayout.bind(mainProgram);
		texture2.bind(mainProgram, "u_texture");
		indexBuffer.bind();

		for (i in 0...camerasToDraw.length) {
			final camera = camerasToDraw.data[i];
			final camera_transform = GLM.transform(camera.pos, Quat.fromEuler(camera.rot.x, camera.rot.y, camera.rot.z, new Quat()), new Vec3(1.0, 1.0, 1.0),
				new Mat4());
			final view = Mat4.invert(camera_transform, new Mat4());
			final proj = GLM.perspective(camera.fov, canvas.width / canvas.height, camera.near, camera.far, new Mat4());
			final viewProj = proj * view;

			mainProgram.setInt("u_is_spine", 0);
			for (i in 0...quadsToDraw.length) {
				mainProgram.setMat4("u_mvp", viewProj * quadsToDraw.data[i].transform);
				drawIndexed(indexBuffer.length);
				#if debug
				drawIndexed(indexBuffer.length, 0, PrimitiveType.LineLoop);
				#end
			}

			for (spine in spinesToDraw) {
				spine.draw(gl, mainProgram, viewProj);
			}
		}

		quadsToDraw.reset();
		camerasToDraw.reset();
		spinesToDraw = new Array<SpineSprite>();
	}

	public static function drawIndexed(count:Int, offset:Int = 0, countprimitiveType:PrimitiveType = PrimitiveType.Triangles) {
		gl.drawElements(countprimitiveType, count, GL.UNSIGNED_INT, offset);
	}
}
