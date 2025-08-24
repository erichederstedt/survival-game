package renderer;

enum abstract Format(Int) to Int {
	var Unkown = 0;

	var RGBA8_UINT;
	var RGBA8_SINT;
	var RGBA16_UINT;
	var RGBA16_SINT;
	var RGBA16_FLOAT;
	var RGBA32_UINT;
	var RGBA32_SINT;
	var RGBA32_FLOAT;

	var RGB8_UINT;
	var RGB8_SINT;
	var RGB16_UINT;
	var RGB16_SINT;
	var RGB16_FLOAT;
	var RGB32_UINT;
	var RGB32_SINT;
	var RGB32_FLOAT;

	var RG8_UINT;
	var RG8_SINT;
	var RG16_UINT;
	var RG16_SINT;
	var RG16_FLOAT;
	var RG32_UINT;
	var RG32_SINT;
	var RG32_FLOAT;

	var R8_UINT;
	var R8_SINT;
	var R16_UINT;
	var R16_SINT;
	var R16_FLOAT;
	var R32_UINT;
	var R32_SINT;
	var R32_FLOAT;
}

// The typedef remains the same
typedef FormatInfoView = {
	final elementSize:Int;
	final elementCount:Int;
	final totalSize:Int;
	final webglInternalFormat:Int;
	final webglFormat:Int;
	final webglType:Int;
};

// Assuming `gl` constants are available
final FormatInfo:Array<FormatInfoView> = [
	// Unkown
	{
		elementSize: 0,
		elementCount: 0,
		totalSize: 0,
		webglInternalFormat: 0,
		webglFormat: 0,
		webglType: 0
	},
	// RGBA formats
	{
		elementSize: 1,
		elementCount: 4,
		totalSize: 4,
		webglInternalFormat: GL.RGBA8UI,
		webglFormat: GL.RGBA_INTEGER,
		webglType: GL.UNSIGNED_BYTE
	}, // RGBA8_UINT
	{
		elementSize: 1,
		elementCount: 4,
		totalSize: 4,
		webglInternalFormat: GL.RGBA8I,
		webglFormat: GL.RGBA_INTEGER,
		webglType: GL.BYTE
	}, // RGBA8_SINT
	{
		elementSize: 2,
		elementCount: 4,
		totalSize: 8,
		webglInternalFormat: GL.RGBA16UI,
		webglFormat: GL.RGBA_INTEGER,
		webglType: GL.UNSIGNED_SHORT
	}, // RGBA16_UINT
	{
		elementSize: 2,
		elementCount: 4,
		totalSize: 8,
		webglInternalFormat: GL.RGBA16I,
		webglFormat: GL.RGBA_INTEGER,
		webglType: GL.SHORT
	}, // RGBA16_SINT
	{
		elementSize: 2,
		elementCount: 4,
		totalSize: 8,
		webglInternalFormat: GL.RGBA16F,
		webglFormat: GL.RGBA,
		webglType: GL.HALF_FLOAT
	}, // RGBA16_FLOAT
	{
		elementSize: 4,
		elementCount: 4,
		totalSize: 16,
		webglInternalFormat: GL.RGBA32UI,
		webglFormat: GL.RGBA_INTEGER,
		webglType: GL.UNSIGNED_INT
	}, // RGBA32_UINT
	{
		elementSize: 4,
		elementCount: 4,
		totalSize: 16,
		webglInternalFormat: GL.RGBA32I,
		webglFormat: GL.RGBA_INTEGER,
		webglType: GL.INT
	}, // RGBA32_SINT
	{
		elementSize: 4,
		elementCount: 4,
		totalSize: 16,
		webglInternalFormat: GL.RGBA32F,
		webglFormat: GL.RGBA,
		webglType: GL.FLOAT
	}, // RGBA32_FLOAT
	// RGB formats
	{
		elementSize: 1,
		elementCount: 3,
		totalSize: 3,
		webglInternalFormat: GL.RGB8UI,
		webglFormat: GL.RGB_INTEGER,
		webglType: GL.UNSIGNED_BYTE
	}, // RGB8_UINT
	{
		elementSize: 1,
		elementCount: 3,
		totalSize: 3,
		webglInternalFormat: GL.RGB8I,
		webglFormat: GL.RGB_INTEGER,
		webglType: GL.BYTE
	}, // RGB8_SINT
	{
		elementSize: 2,
		elementCount: 3,
		totalSize: 6,
		webglInternalFormat: GL.RGB16UI,
		webglFormat: GL.RGB_INTEGER,
		webglType: GL.UNSIGNED_SHORT
	}, // RGB16_UINT
	{
		elementSize: 2,
		elementCount: 3,
		totalSize: 6,
		webglInternalFormat: GL.RGB16I,
		webglFormat: GL.RGB_INTEGER,
		webglType: GL.SHORT
	}, // RGB16_SINT
	{
		elementSize: 2,
		elementCount: 3,
		totalSize: 6,
		webglInternalFormat: GL.RGB16F,
		webglFormat: GL.RGB,
		webglType: GL.HALF_FLOAT
	}, // RGB16_FLOAT
	{
		elementSize: 4,
		elementCount: 3,
		totalSize: 12,
		webglInternalFormat: GL.RGB32UI,
		webglFormat: GL.RGB_INTEGER,
		webglType: GL.UNSIGNED_INT
	}, // RGB32_UINT
	{
		elementSize: 4,
		elementCount: 3,
		totalSize: 12,
		webglInternalFormat: GL.RGB32I,
		webglFormat: GL.RGB_INTEGER,
		webglType: GL.INT
	}, // RGB32_SINT
	{
		elementSize: 4,
		elementCount: 3,
		totalSize: 12,
		webglInternalFormat: GL.RGB32F,
		webglFormat: GL.RGB,
		webglType: GL.FLOAT
	}, // RGB32_FLOAT
	// RG formats
	{
		elementSize: 1,
		elementCount: 2,
		totalSize: 2,
		webglInternalFormat: GL.RG8UI,
		webglFormat: GL.RG_INTEGER,
		webglType: GL.UNSIGNED_BYTE
	}, // RG8_UINT
	{
		elementSize: 1,
		elementCount: 2,
		totalSize: 2,
		webglInternalFormat: GL.RG8I,
		webglFormat: GL.RG_INTEGER,
		webglType: GL.BYTE
	}, // RG8_SINT
	{
		elementSize: 2,
		elementCount: 2,
		totalSize: 4,
		webglInternalFormat: GL.RG16UI,
		webglFormat: GL.RG_INTEGER,
		webglType: GL.UNSIGNED_SHORT
	}, // RG16_UINT
	{
		elementSize: 2,
		elementCount: 2,
		totalSize: 4,
		webglInternalFormat: GL.RG16I,
		webglFormat: GL.RG_INTEGER,
		webglType: GL.SHORT
	}, // RG16_SINT
	{
		elementSize: 2,
		elementCount: 2,
		totalSize: 4,
		webglInternalFormat: GL.RG16F,
		webglFormat: GL.RG,
		webglType: GL.HALF_FLOAT
	}, // RG16_FLOAT
	{
		elementSize: 4,
		elementCount: 2,
		totalSize: 8,
		webglInternalFormat: GL.RG32UI,
		webglFormat: GL.RG_INTEGER,
		webglType: GL.UNSIGNED_INT
	}, // RG32_UINT
	{
		elementSize: 4,
		elementCount: 2,
		totalSize: 8,
		webglInternalFormat: GL.RG32I,
		webglFormat: GL.RG_INTEGER,
		webglType: GL.INT
	}, // RG32_SINT
	{
		elementSize: 4,
		elementCount: 2,
		totalSize: 8,
		webglInternalFormat: GL.RG32F,
		webglFormat: GL.RG,
		webglType: GL.FLOAT
	}, // RG32_FLOAT
	// R formats
	{
		elementSize: 1,
		elementCount: 1,
		totalSize: 1,
		webglInternalFormat: GL.R8UI,
		webglFormat: GL.RED_INTEGER,
		webglType: GL.UNSIGNED_BYTE
	}, // R8_UINT
	{
		elementSize: 1,
		elementCount: 1,
		totalSize: 1,
		webglInternalFormat: GL.R8I,
		webglFormat: GL.RED_INTEGER,
		webglType: GL.BYTE
	}, // R8_SINT
	{
		elementSize: 2,
		elementCount: 1,
		totalSize: 2,
		webglInternalFormat: GL.R16UI,
		webglFormat: GL.RED_INTEGER,
		webglType: GL.UNSIGNED_SHORT
	}, // R16_UINT
	{
		elementSize: 2,
		elementCount: 1,
		totalSize: 2,
		webglInternalFormat: GL.R16I,
		webglFormat: GL.RED_INTEGER,
		webglType: GL.SHORT
	}, // R16_SINT
	{
		elementSize: 2,
		elementCount: 1,
		totalSize: 2,
		webglInternalFormat: GL.R16F,
		webglFormat: GL.RED,
		webglType: GL.HALF_FLOAT
	}, // R16_FLOAT
	{
		elementSize: 4,
		elementCount: 1,
		totalSize: 4,
		webglInternalFormat: GL.R32UI,
		webglFormat: GL.RED_INTEGER,
		webglType: GL.UNSIGNED_INT
	}, // R32_UINT
	{
		elementSize: 4,
		elementCount: 1,
		totalSize: 4,
		webglInternalFormat: GL.R32I,
		webglFormat: GL.RED_INTEGER,
		webglType: GL.INT
	}, // R32_SINT
	{
		elementSize: 4,
		elementCount: 1,
		totalSize: 4,
		webglInternalFormat: GL.R32F,
		webglFormat: GL.RED,
		webglType: GL.FLOAT
	} // R32_FLOAT
];
