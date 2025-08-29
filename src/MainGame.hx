package;

import engine.*;
import glm.GLM;
import glm.Mat4;
import glm.Quat;
import glm.Vec2;
import glm.Vec3;
import renderer.Renderer;
import renderer.SpineSprite;

class MainGame {
	public static var camera = renderer.Renderer.camera();

	public static function main() {
		Engine.start(main_loop);

		camera.pos.z = 10.0;
		final spineSprite = new SpineSprite();
	}

	public static var pos = new Vec2();

	public static function main_loop() {
		final moveSpeed:Float = 0.05;
		final rotationSpeed:Float = 0.005;
		if (Input.key_held(Key.W))
			camera.pos -= camera.forward() * moveSpeed * Engine.delta_time;
		if (Input.key_held(Key.S))
			camera.pos += camera.forward() * moveSpeed * Engine.delta_time;
		if (Input.key_held(Key.A))
			camera.pos -= camera.right() * moveSpeed * Engine.delta_time;
		if (Input.key_held(Key.D))
			camera.pos += camera.right() * moveSpeed * Engine.delta_time;

		if (Input.key_held(Key.Q))
			camera.rot.y += rotationSpeed * Engine.delta_time;
		if (Input.key_held(Key.E))
			camera.rot.y -= rotationSpeed * Engine.delta_time;

		if (Input.key_pressed(Key.P))
			trace('camera.pos:${camera.pos}, camera.rot:${camera.rot}');

		Renderer.addCamera(camera);
		Renderer.drawQuad(GLM.transform(new Vec3(10.0, 0.0, 0.0), Quat.fromEuler(0.0, 0.0, 0.0, new Quat()), new Vec3(5.0, 5.0, 5.0), new Mat4()));
		Renderer.drawQuad(GLM.transform(new Vec3(0.0, 0.0, 0.0), Quat.fromEuler(0.0, 0.0, 0.0, new Quat()), new Vec3(5.0, 5.0, 5.0), new Mat4()));
		Renderer.drawQuad(GLM.transform(new Vec3(-10.0, 0.0, 0.0), Quat.fromEuler(0.0, 0.0, 0.0, new Quat()), new Vec3(5.0, 5.0, 5.0), new Mat4()));
		Renderer.render();
	}
}
