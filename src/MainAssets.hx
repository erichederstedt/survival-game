package;

import assets.AssetList;
import assets.TextureAsset;
import haxe.Json;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#if !macro
import assets.AssetSystem;
#end

class MainAssets {
	public static function main() {
		final test:Compression = Compression.DXT1;
		var assetsrc = "./assetsrc";
		final imageFormats = ["png"];
		final imagesToEncode:Array<String> = [];
		findFiles(assetsrc, imagesToEncode, (file:Path) -> imageFormats.contains(file.ext));

		final assetList:AssetList = new AssetList();
		for (image in imagesToEncode) {
			assetList.textures.push(new TextureAsset(image, [
				convertTexture(image, CompressionType.s3tc, Compression.DXT1, Quality.Medium),
				convertTexture(image, CompressionType.etc, Compression.ETC1, Quality.Medium)
			]));
		}

		final assetListJson = Json.stringify(assetList);
		File.saveContent('bin/assetList.json', assetListJson);

		#if !macro
		trace(AssetSystem.assetsrc.f_texture);
		#end
	}

	public static function createDir(dir:String) {
		if (FileSystem.exists(dir) && FileSystem.isDirectory(dir))
			return;

		FileSystem.createDirectory(dir);
	}

	public static function findFiles(path:String, outFiles:Array<String>, ?filter:(file:Path) -> Bool) {
		if (!FileSystem.exists(path)) {
			return;
		}

		if (FileSystem.isDirectory(path)) {
			for (item in FileSystem.readDirectory(path)) {
				var fullPath = Path.join([path, item]);
				findFiles(fullPath, outFiles, filter);
			}
		} else {
			trace("Found: " + path);
			if (filter != null && filter(new Path(path)))
				outFiles.push(path);
			else if (filter == null)
				outFiles.push(path);
		}
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
