package macro;

import haxe.Json;
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;

class AssetSystemBuilder {
	public static function build():Array<Field> {
		if (!FileSystem.exists("bin/assetList.json"))
			return [];

		final fields = Context.getBuildFields();
		final jsonPath = Context.resolvePath("bin/assetList.json");

		final jsonContent = File.getContent(jsonPath);
		final assetData:assets.AssetList = assets.AssetList.fromJson(Json.parse(jsonContent));

		for (texture in assetData.textures) {
			final path = new Path(texture.file);
			trace(path.file);

			var textureDataExprs:Array<Expr> = [];
			for (dataItem in texture.data) {
				textureDataExprs.push(macro new TextureData($v{dataItem.file}, $v{dataItem.compressionType}, $v{dataItem.compression}, $v{dataItem.quality}));
			}
			final field:Field = {
				name: path.file,
				doc: "Generated asset path for " + texture.file,
				access: [Access.APublic, Access.AStatic],
				kind: FieldType.FVar(macro :TextureAsset, macro new assets.TextureAsset($v{texture.file}, $a{textureDataExprs})),
				pos: Context.currentPos()
			};
			fields.push(field);
		}

		return fields;
	}
}
