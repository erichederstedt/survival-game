package;

import assets.AssetList;
import assets.TextureAsset;
import haxe.Json;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

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
				TextureAsset.convertTexture(image, CompressionType.s3tc, Compression.DXT1, Quality.Medium),
				TextureAsset.convertTexture(image, CompressionType.etc, Compression.ETC1, Quality.Medium)
			]));
		}

		final assetListJson = Json.stringify(assetList);
		File.saveContent('bin/assetList.json', assetListJson);

		#if macro
		trace(AssetSystem.f_texture);
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
}
