package;

import engine.*;
import glm.Vec2;
import renderer.Renderer;

class MainGame {
	public static function main() {
		Engine.start(main_loop);
	}

	public static var pos = new Vec2();

	public static function main_loop() {
		final speed:Float = 0.2;
		if (Input.key_held(Key.W))
			pos.y += speed * Engine.delta_time;
		if (Input.key_held(Key.S))
			pos.y -= speed * Engine.delta_time;
		if (Input.key_held(Key.A))
			pos.x -= speed * Engine.delta_time;
		if (Input.key_held(Key.D))
			pos.x += speed * Engine.delta_time;

		Renderer.drawQuad(pos, new Vec2(50.0, 50.0));
		Renderer.drawQuad(new Vec2(50.0, 50.0), new Vec2(50.0, 50.0));
		Renderer.drawQuad(new Vec2(100.0, 100.0), new Vec2(50.0, 50.0));
		Renderer.render();
	}
}
