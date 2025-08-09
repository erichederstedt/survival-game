package engine;

import utils.LinearAllocator;
import VectorMath;
import js.Browser;
import js.html.CanvasElement;
import js.html.webgl.WebGL2RenderingContext;

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

typedef GL = WebGL2RenderingContext;

class Renderer {
	public static var quads_to_draw:LinearAllocator<Quad> = new LinearAllocator<Quad>(2048, quad());
	public static var canvas:CanvasElement = get_canvas_element("webgl");
	public static var gl:GL = canvas.getContextWebGL2();

	public static function get_canvas_element(id:String):CanvasElement {
		var element = Browser.document.getElementById(id);
		if (element == null)
			return null;

		return cast(element, CanvasElement);
	}

	public static function draw_quad(pos:Vec2, size:Vec2) {
		var quad = quads_to_draw.alloc();
		quad.pos = pos;
		quad.size = size;
	}

	public static function render() {
		// trace("draw width:" + gl.drawingBufferWidth + ", " + "draw height:" + gl.drawingBufferHeight);
		// trace("canvas width:" + canvas.width + ", " + "canvas height:" + canvas.height);
		if (canvas.width != canvas.clientWidth || canvas.height != canvas.clientHeight) {
			canvas.width = canvas.clientWidth;
			canvas.height = canvas.clientHeight;
		}

		gl.clearColor(0, 0, 0, 1);
		gl.clear(GL.COLOR_BUFFER_BIT);

		gl.enable(GL.SCISSOR_TEST);
		gl.clearColor(1, 0, 0, 1);
		for (quad in quads_to_draw.data) {
			gl.scissor(Std.int(quad.pos.x), Std.int(quad.pos.y), Std.int(quad.size.x), Std.int(quad.size.y));
			gl.clear(GL.COLOR_BUFFER_BIT);
		}
		gl.disable(GL.SCISSOR_TEST);

		quads_to_draw.reset();
	}
}
