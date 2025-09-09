package renderer;

import glm.Mat2;
import glm.Mat4;
import glm.Quat;
import glm.Vec2;
import renderer.SpineTextureLoader;
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
		animationState = new AnimationState(animationStateData);
		skeleton.setToSetupPose();
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
				program.setMat4("u_mvp",
					viewProj * glm.GLM.transform(new glm.Vec3(0.0, -7.5, 0.0), new glm.Quat(), new glm.Vec3(0.05, 0.05, 0.05), new Mat4()));
				program.setInt("u_is_spine", 1);
				program.setFloatArray("u_spine_transform", [a, b, c, d]);
				program.setFloatArray("u_offsets", offsets);
				program.setVec2("u_spine_position", new Vec2(x, y));

				Renderer.drawIndexed(6);
				#if debug
				Renderer.drawIndexed(6, 0, PrimitiveType.LineLoop);
				#end

				program.setInt("u_is_spine", 0);

				#if 0
				var offsetX:Float = 0, offsetY:Float = 0;
				var calculatedPos = new Vec2();

				// BR
				offsetX = offsets[0];
				offsetY = offsets[1];
				calculatedPos.x = offsetX * a + offsetY * b + x;
				calculatedPos.y = offsetX * c + offsetY * d + y;
				offset += stride;
				trace('BR: ${calculatedPos}');

				// BL
				offsetX = offsets[2];
				offsetY = offsets[3];
				calculatedPos.x = offsetX * a + offsetY * b + x;
				calculatedPos.y = offsetX * c + offsetY * d + y;
				offset += stride;
				trace('BL: ${calculatedPos}');

				// UL
				offsetX = offsets[4];
				offsetY = offsets[5];
				calculatedPos.x = offsetX * a + offsetY * b + x;
				calculatedPos.y = offsetX * c + offsetY * d + y;
				offset += stride;
				trace('UL: ${calculatedPos}');

				// UR
				offsetX = offsets[6];
				offsetY = offsets[7];
				calculatedPos.x = offsetX * a + offsetY * b + x;
				calculatedPos.y = offsetX * c + offsetY * d + y;
				trace('UR: ${calculatedPos}');
				#end
			} else if (Std.isOfType(slot.attachment, MeshAttachment)) {
				//
			} else if (Std.isOfType(slot.attachment, ClippingAttachment)) {
				//
			} else {}
		}
	}
}
