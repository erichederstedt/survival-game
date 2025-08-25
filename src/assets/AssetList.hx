package assets;

import assets.TextureAsset;
import haxe.Json;

class AssetList {
	public final textures:Array<TextureAsset>;

	public function new() {
		textures = [];
	}

	public static function fromJson(json:Dynamic):AssetList {
		var assetList = new AssetList();

		final textures:Array<Dynamic> = cast(json.textures);
		for (texAsset in textures) {
			var textureAsset = new TextureAsset(texAsset.file);
			final data:Array<Dynamic> = cast(texAsset.data);
			for (texData in data) {
				textureAsset.data.push(new TextureData(texData.file, texData.compressionType, texData.compression, texData.quality));
			}
			assetList.textures.push(textureAsset);
		}

		return assetList;
	}
}
