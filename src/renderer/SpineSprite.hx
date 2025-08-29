package renderer;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import renderer.SpineTextureLoader;
import spine.SkeletonData;
import spine.animation.AnimationStateData;
import spine.atlas.TextureAtlas;

function getBytes(id:String):Bytes {
	return new BytesBuffer().getBytes();
}

function getText(id:String):String {
	return "";
}

class SpineSprite {
	final atlas:TextureAtlas;
	final skeletondata:SkeletonData;
	final animationStateData:AnimationStateData;

	public function new() {
		atlas = new TextureAtlas(getText("assets/raptor.atlas"), new SpineTextureLoader("assets/raptor-pro.atlas"));
		skeletondata = SkeletonData.from(getText("assets/raptor-pro.json"), atlas, .25);
		animationStateData = new AnimationStateData(skeletondata);
	}
}
