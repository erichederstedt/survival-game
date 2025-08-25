package;

import assets.TextureAsset;
import haxe.Json;
import haxe.io.Path;
import haxe.macro.Expr.Case;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

class MainAssets {
	public static function main() {
		final test:Compression = Compression.DXT1;
		var assetsrc = "./assetsrc";
		final imageFormats = ["png"];
		final imagesToEncode:Array<String> = [];
		findFiles(assetsrc, imagesToEncode, (file:Path) -> imageFormats.contains(file.ext));

		final textureAssets:Array<TextureAsset> = [];
		for (image in imagesToEncode) {
			textureAssets.push(new TextureAsset(image));
		}

		final assetList:Dynamic = {
			textures: textureAssets
		};
		final assetListJson = Json.stringify(assetList);
		File.saveContent('bin/assetList.json', assetListJson);
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
