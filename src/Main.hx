package;

import VectorMath;
import engine.*;

class Main {
	public static function main() {
		Engine.start(main_loop);
	}

	public static var pos = vec2(0.0);

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

		Renderer.drawQuad(pos, vec2(50.0));
		Renderer.render();
	}
}
