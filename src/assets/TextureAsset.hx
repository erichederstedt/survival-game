package assets;

import haxe.io.Path;

enum abstract CompressionType(String) to String from String {
	var astc;
	var etc;
	var s3tc;
	var pvrtc;
}

enum abstract Compression(String) to String from String {
	var ASTC_4x4;
	var ASTC_5x4;
	var ASTC_5x5;
	var ASTC_6x5;
	var ASTC_6x6;
	var ASTC_8x5;
	var ASTC_8x6;
	var ASTC_8x8;
	var ASTC_10x5;
	var ASTC_10x6;
	var ASTC_10x8;
	var ASTC_10x10;
	var ASTC_12x10;
	var ASTC_12x12;
	var ASTC_3x3x3;
	var ASTC_4x3x3;
	var ASTC_4x4x3;
	var ASTC_4x4x4;
	var ASTC_5x4x4;
	var ASTC_5x5x4;
	var ASTC_5x5x5;
	var ASTC_6x5x5;
	var ASTC_6x6x5;
	var ASTC_6x6x6;

	var ETC1;
	var ETC2_RGBA;
	var ETC2_RGB;

	var DXT1;
	var DXT1A;
	var DXT3;
	var DXT5;

	var PVRTC1_2;
	var PVRTC1_4;
	var PVRTC1_2_RGB;
	var PVRTC1_4_RGB;
}

enum abstract Quality(String) to String from String {
	var VeryLow;
	var Low;
	var Medium;
	var High;
	var VeryHigh;
}

@:json
class TextureData {
	public final file:String;
	public final compressionType:CompressionType;
	public final compression:Compression;
	public final quality:Quality;

	public function new(file:String, compressionType:CompressionType, compression:Compression, quality:Quality) {
		this.file = file;
		this.compressionType = compressionType;
		this.compression = compression;
		this.quality = quality;
	}
}

function CompressionQuality(quality:Quality, compressionType:CompressionType):String {
	switch (compressionType) {
		case CompressionType.astc:
			switch (quality) {
				case Quality.VeryLow:
					return 'astcveryfast';
				case Quality.Low:
					return 'astcfast';
				case Quality.Medium:
					return 'astcmedium';
				case Quality.High:
					return 'astcthorough';
				case Quality.VeryHigh:
					return 'astcexhaustive';
			}
		case CompressionType.etc:
			switch (quality) {
				case Quality.VeryLow:
					return 'etcfast';
				case Quality.Low:
					return 'etcfast';
				case Quality.Medium:
					return 'etcfast';
				case Quality.High:
					return 'etcslow';
				case Quality.VeryHigh:
					return 'etcslow';
			}
		case CompressionType.pvrtc:
			switch (quality) {
				case Quality.VeryLow:
					return 'pvrtcfastest';
				case Quality.Low:
					return 'pvrtcfast';
				case Quality.Medium:
					return 'pvrtcnormal';
				case Quality.High:
					return 'pvrtchigh';
				case Quality.VeryHigh:
					return 'pvrtcbest';
			}
		case CompressionType.s3tc:
			switch (quality) {
				case Quality.VeryLow:
					return 'superfast';
				case Quality.Low:
					return 'fast';
				case Quality.Medium:
					return 'normal';
				case Quality.High:
					return 'better';
				case Quality.VeryHigh:
					return 'uber';
			}
	}
}

@:json
class TextureAsset {
	public final file:String;
	public final data:Array<TextureData>;

	public function new(file:String, ?data:Array<TextureData>) {
		this.file = file;
		if (data == null)
			this.data = [];
		else
			this.data = data.copy();
	}
}
