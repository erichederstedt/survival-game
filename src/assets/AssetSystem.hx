package assets;

import assets.TextureAsset;

#if !macro
@:build(macro.AssetSystemBuilder.build())
class AssetSystem {}
#else
class AssetSystem {}
#end
