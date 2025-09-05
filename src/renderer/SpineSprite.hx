package renderer;

import renderer.SpineTextureLoader;
import spine.SkeletonData;
import spine.animation.AnimationStateData;
import spine.atlas.TextureAtlas;
import utils.FileSystem;

class SpineSprite {
	final atlas:TextureAtlas;
	final skeletondata:SkeletonData;
	final animationStateData:AnimationStateData;

	public function new() {
		atlas = new TextureAtlas(FileSystem.getText("assets/raptor.atlas"), new SpineTextureLoader("assets/raptor-pro.atlas"));
		skeletondata = SkeletonData.from(FileSystem.getText("assets/raptor-pro.json"), atlas, .25);
		animationStateData = new AnimationStateData(skeletondata);
	}
}
