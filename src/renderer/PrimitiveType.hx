package renderer;

enum abstract PrimitiveType(Int) to Int {
	var Points = GL.POINTS;
	var Lines = GL.LINES;
	var LineLoop = GL.LINE_LOOP;
	var LineStrip = GL.LINE_STRIP;
	var Triangles = GL.TRIANGLES;
	var TriangleStrip = GL.TRIANGLE_STRIP;
	var TriangleFan = GL.TRIANGLE_FAN;
}
