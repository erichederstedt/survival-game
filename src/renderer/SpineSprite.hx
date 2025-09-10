package renderer;

import glm.Mat2;
import glm.Mat4;
import glm.Quat;
import glm.Vec2;
import renderer.SpineTextureLoader;
import spine.BlendMode;
import spine.Bone;
import spine.Physics;
import spine.Skeleton;
import spine.SkeletonData;
import spine.Slot;
import spine.animation.AnimationState;
import spine.animation.AnimationStateData;
import spine.atlas.TextureAtlas;
import spine.attachments.ClippingAttachment;
import spine.attachments.MeshAttachment;
import spine.attachments.RegionAttachment;
import utils.FileSystem;

class SpineSprite {
	final atlas:TextureAtlas;
	final skeletonData:SkeletonData;
	final skeleton:Skeleton;
	final animationStateData:AnimationStateData;
	final animationState:AnimationState;

	public function new() {
		atlas = new TextureAtlas(FileSystem.getText("assets/raptor.atlas"), new SpineTextureLoader("assets/raptor-pro.atlas"));
		skeletonData = SkeletonData.from(FileSystem.getText("assets/raptor-pro.json"), atlas, .25);
		skeleton = new Skeleton(skeletonData);
		Bone.yDown = false;
		animationStateData = new AnimationStateData(skeletonData);
		animationStateData.defaultMix = 0.25;
		animationState = new AnimationState(animationStateData);
		skeleton.setToSetupPose();
		animationState.setAnimationByName(0, "walk", true);
	}

	private static var QUAD_INDICES:Array<Int> = [0, 1, 2, 2, 3, 0];

	public function update(dt:Float) {
		animationState.update(dt);
		animationState.apply(skeleton);
		skeleton.update(dt);
		skeleton.updateWorldTransform(Physics.update);
	}

	public function draw(gl:GL, program:Program, viewProj:Mat4) {
		final drawOrder:Array<Slot> = skeleton.drawOrder;
		for (slot in drawOrder) {
			if (Std.isOfType(slot.attachment, RegionAttachment)) {
				final attachement:RegionAttachment = cast slot.attachment;
				var offset = 0;
				final stride = 2;

				if (attachement.sequence != null)
					attachement.sequence.apply(slot, attachement);

				final bone = slot.bone;
				untyped final offsets = attachement.offsets; // 8 Float array.
				final x = bone.worldX, y = bone.worldY;
				final a = bone.a, b = bone.b, c = bone.c, d = bone.d;
				program.setMat4("u_mvp", viewProj * glm.GLM.transform(new glm.Vec3(0.0, -7.5, 0.0), new glm.Quat(), new glm.Vec3(0.05, 0.05, 1.0), new Mat4()));
				program.setInt("u_is_spine", 1);

				final regionScaleX = attachement.width / attachement.region.originalWidth * attachement.scaleX;
				final regionScaleY = attachement.height / attachement.region.originalHeight * attachement.scaleY;
				final localX = -attachement.width / 2 * attachement.scaleX + attachement.region.offsetX * regionScaleX;
				final localY = -attachement.height / 2 * attachement.scaleY + attachement.region.offsetY * regionScaleY;
				final localX2 = localX + attachement.region.width * regionScaleX;
				final localY2 = localY + attachement.region.height * regionScaleY;

				final shiX = attachement.region.width * regionScaleX;
				final shiY = attachement.region.height * regionScaleY;

				final boneTransform = glm.GLM.transform(new glm.Vec3(bone.worldX + attachement.region.offsetX, bone.worldY + attachement.region.offsetY, 0.0),
					glm.Quat.fromEuler(0.0, 0.0, 0.0, new glm.Quat()), new glm.Vec3(localX2, localY2), new glm.Mat4());
				program.setMat4("u_bone_transform", boneTransform);

				/*
					program.setFloatArray("u_spine_transform", [a, b, c, d, x, y]);
					program.setFloatArray("u_spine_offsets", offsets);
				 */
				program.setFloatArray("u_spine_uvs", attachement.uvs);

				final texture:Texture = cast attachement.region.texture;
				if (texture != null) {
					texture.bind(program, "u_texture");
				}

				setBlendMode(gl, slot.data.blendMode);

				Renderer.drawIndexed(6);

				program.setInt("u_is_spine", 0);
			} else if (Std.isOfType(slot.attachment, MeshAttachment)) {
				//
			} else if (Std.isOfType(slot.attachment, ClippingAttachment)) {
				//
			} else {}
		}
	}

	function setBlendMode(gl:GL, blendMode:BlendMode) {
		gl.blendEquation(GL.FUNC_ADD);

		switch (blendMode) {
			case BlendMode.normal:
				gl.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
			case BlendMode.additive:
				gl.blendFunc(GL.SRC_ALPHA, GL.ONE);
			case BlendMode.multiply:
				gl.blendFunc(GL.DST_COLOR, GL.ZERO);
			case BlendMode.screen:
				gl.blendFunc(GL.ONE, GL.ONE_MINUS_SRC_COLOR);
		}
	}
}
