package renderer;

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

	public function loadPage(page:TextureAtlasPage, path:String) {
		page.texture = Texture.fromImage('${basePath}/${path}');
	}

	public function loadRegion(region:TextureAtlasRegion):Void {
		region.texture = region.page.texture;
	}

	public function unloadPage(page:TextureAtlasPage):Void {
		page.texture = null;
	}
}
