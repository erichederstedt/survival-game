package renderer;

import haxe.Http;
import spine.atlas.TextureAtlasPage;
import spine.atlas.TextureAtlasRegion;
import spine.atlas.TextureLoader;

class SpineTextureLoader implements TextureLoader {
	private var basePath:String;

	public function new(atlasPath:String) {
		basePath = "";
		var slashIndex = atlasPath.lastIndexOf("/");
		if (slashIndex != -1) {
			basePath = atlasPath.substring(0, slashIndex);
		}
	}

	public function loadPage(page:TextureAtlasPage, path:String) {}

	public function loadRegion(region:TextureAtlasRegion):Void {}

	public function unloadPage(page:TextureAtlasPage):Void {}
}
