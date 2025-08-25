package macro;

import assets.TextureAsset;
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

		final assetTree:Dynamic = {};

		for (texture in assetData.textures) {
			final path = new Path(texture.file);
			var parts = path.dir.split("/");
			if (path.dir == "")
				parts = [];
			parts.push(path.file);

			var currentNode = assetTree;
			for (i in 0...parts.length) {
				var part = parts[i];
				if (i == parts.length - 1) {
					Reflect.setField(currentNode, part, texture);
				} else {
					if (!Reflect.hasField(currentNode, part)) {
						Reflect.setField(currentNode, part, {});
					}
					currentNode = Reflect.field(currentNode, part);
				}
			}
		}

		for (fieldName in Reflect.fields(assetTree)) {
			final fieldContent = Reflect.field(assetTree, fieldName);
			final fieldExpr = buildFieldExpr(fieldContent);
			final field:Field = {
				name: fieldName,
				doc: "Generated asset folder for " + fieldName,
				access: [Access.APublic, Access.AStatic],
				kind: FieldType.FVar(macro :Dynamic, fieldExpr),
				pos: Context.currentPos()
			};
			fields.push(field);
			trace('Generated field: ${fieldName}');
		}

		final stackRecord:Array<Array<String>> = [];
		buildTextureStacks({name: 'assetTree', data: assetTree}, [], stackRecord, true);

		final textureArrayFieldExprs:Array<Expr> = [];
		for (stack in stackRecord) {
			var accessExpr:Expr = null;
			for (i in 0...stack.length) {
				if (accessExpr == null)
					accessExpr = {
						expr: EConst(CIdent(stack[i])),
						pos: Context.currentPos()
					};
				else
					accessExpr = {
						expr: EField(accessExpr, stack[i]),
						pos: Context.currentPos()
					};
			}
			textureArrayFieldExprs.push(accessExpr);
		}

		final textureArrayField:Field = {
			name: "textureArray",
			doc: "Generated asset array for textures",
			access: [Access.APublic, Access.AStatic],
			kind: FieldType.FVar(macro :Array<TextureAsset>, macro $a{textureArrayFieldExprs}),
			pos: Context.currentPos()
		};
		fields.push(textureArrayField);

		return fields;
	}

	static function buildFieldExpr(node:Dynamic):Expr {
		if (Std.is(node, TextureAsset)) {
			var texture:TextureAsset = node;
			var textureDataExprs:Array<Expr> = [];
			for (dataItem in texture.data) {
				textureDataExprs.push(macro new TextureData($v{dataItem.file}, $v{dataItem.compressionType}, $v{dataItem.compression}, $v{dataItem.quality}));
			}
			return macro new TextureAsset($v{texture.file}, $a{textureDataExprs});
		} else {
			var fields = [];
			for (fieldName in Reflect.fields(node)) {
				var subNode = Reflect.field(node, fieldName);
				fields.push({
					field: fieldName,
					expr: buildFieldExpr(subNode)
				});
			}
			return {expr: EObjectDecl(fields), pos: Context.currentPos()};
		}
	}

	static function buildTextureStacks(node:{name:String, data:Dynamic}, stack:Array<String>, stackRecord:Array<Array<String>>, skip:Bool) {
		if (!skip)
			stack.push(node.name);
		if (Std.is(node.data, TextureAsset)) {
			stackRecord.push(stack.copy());
		} else {
			for (field in Reflect.fields(node.data))
				buildTextureStacks({name: field, data: Reflect.field(node.data, field)}, stack, stackRecord, false);
		}
		if (!skip)
			stack.pop();
	}
}
