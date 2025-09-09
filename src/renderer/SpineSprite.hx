package renderer;

import glm.Mat4;
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
		Bone.yDown = true;
		animationStateData = new AnimationStateData(skeletonData);
		animationState = new AnimationState(animationStateData);
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
			final positions = new Array<Float>(); // Array of pairs of X and Y values(Floats)
			final uvs = new Array<Float>(); // Array of pairs of U and V values(Floats)
			if (Std.isOfType(slot.attachment, RegionAttachment)) {
				final attachement:RegionAttachment = cast slot.attachment;
				positions.resize(4 * 2);
				positions.resize(4 * 2);
				var offset = 0;
				final stride = 2;

				if (attachement.sequence != null)
					attachement.sequence.apply(slot, attachement);

				final bone = slot.bone;
				untyped final offsets = attachement.offsets; // 8 Float array.
				final x = bone.worldX, y = bone.worldY;
				final a = bone.a, b = bone.b, c = bone.c, d = bone.d;
				var offsetX:Float = 0, offsetY:Float = 0;
				// @formatter:off
				final transform = new Mat4(
					a, b, 0.0, 0.0, 
					c, d, 0.0, 0.0, 
					0.0, 0.0, 1.0, 0.0, 
					0.0, 0.0, 0.0, 1.0
				);
				// @formatter:on
				trace(transform);
				program.setMat4("u_mvp", viewProj * glm.GLM.translate(new glm.Vec3(), new Mat4()));
				program.setInt("u_is_spine", 1);
				program.setFloatArray("u_offsets", offsets);

				Renderer.drawIndexed(6);
				#if debug
				Renderer.drawIndexed(6, 0, PrimitiveType.LineLoop);
				#end

				program.setInt("u_is_spine", 0);

				#if 0
				// BR
				offsetX = offsets[0];
				offsetY = offsets[1];
				positions[offset] = offsetX * a + offsetY * b + x;
				positions[offset + 1] = offsetX * c + offsetY * d + y;
				uvs[offset] = 1.0;
				uvs[offset + 1] = 1.0;
				offset += stride;

				// BL
				offsetX = offsets[2];
				offsetY = offsets[3];
				positions[offset] = offsetX * a + offsetY * b + x;
				positions[offset + 1] = offsetX * c + offsetY * d + y;
				uvs[offset] = 0.0;
				uvs[offset + 1] = 1.0;
				offset += stride;

				// UL
				offsetX = offsets[4];
				offsetY = offsets[5];
				positions[offset] = offsetX * a + offsetY * b + x;
				positions[offset + 1] = offsetX * c + offsetY * d + y;
				uvs[offset] = 0.0;
				uvs[offset + 1] = 0.0;
				offset += stride;

				// UR
				offsetX = offsets[6];
				offsetY = offsets[7];
				positions[offset] = offsetX * a + offsetY * b + x;
				positions[offset + 1] = offsetX * c + offsetY * d + y;
				uvs[offset] = 1.0;
				uvs[offset + 1] = 0.0;
				#end
			} else if (Std.isOfType(slot.attachment, MeshAttachment)) {
				//
			} else if (Std.isOfType(slot.attachment, ClippingAttachment)) {
				//
			} else {}
		}
	}
}
