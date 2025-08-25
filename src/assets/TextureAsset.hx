package assets;

import haxe.io.Path;
import sys.io.Process;

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

class TextureData {
	final file:String;
	final compressionType:CompressionType;
	final compression:Compression;
	final quality:Quality;

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

class TextureAsset {
	final file:String;
	final textures:Array<TextureData>;

	public function new(file:String) {
		this.file = file;
		this.textures = [];

		this.textures.push(convertTexture(file, CompressionType.s3tc, Compression.DXT1, Quality.Medium));
		this.textures.push(convertTexture(file, CompressionType.etc, Compression.ETC1, Quality.Medium));
	}

	public static function convertTexture(image:String, compressionType:CompressionType, compression:Compression, quality:Quality):TextureData {
		var textureData:TextureData = null;
		final imagePath = new Path(image);
		try {
			final directory = 'bin/${imagePath.dir}';
			final outputFile = '${imagePath.dir}/${imagePath.file}.${compressionType}.${compression}.ktx';
			MainAssets.createDir(directory);

			final cli:String = 'npx texture-compressor -i ${image} -t ${compressionType} -c ${compression} -q ${CompressionQuality(quality, compressionType)} -o bin/${outputFile} -m -vb';
			final process = new Process(cli);

			final output = process.stdout.readAll().toString();
			Sys.print(output);

			final exitCode = process.exitCode();
			if (exitCode != 0)
				trace('texture-compressor failed! CLI:\n${cli}');
			else
				textureData = new TextureData(outputFile, compressionType, compression, quality);

			process.close();
		} catch (e:Dynamic) {
			trace('Error executing command: $e');
		}

		return textureData;
	}
}
