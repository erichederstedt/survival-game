package renderer;

import js.html.Console;
import renderer.Format.FormatInfo;

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
