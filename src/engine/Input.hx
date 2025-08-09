package engine;

import js.html.KeyboardEvent;
import js.Browser;

enum KeyState {
	Pressed;
	Held;
	Released;
}

enum KeyEventType {
	Pressed;
	Released;
}

typedef KeyEvent = {
	final type:KeyEventType;
	final key:Key;
}

class Input {
	private static var _keyState:Map<Key, KeyState> = new Map();

	private static var _eventQueue:Array<KeyEvent> = [];

	public static function init():Void {
		Browser.window.addEventListener("keydown", _onKeyDown);
		Browser.window.addEventListener("keyup", _onKeyUp);
	}

	public static function update():Void {
		for (key => state in _keyState) {
			if (state == Pressed)
				_keyState.set(key, KeyState.Held);
		}

		for (event in _eventQueue) {
			switch (event.type) {
				case KeyEventType.Pressed:
					_keyState.set(event.key, KeyState.Pressed);
				case KeyEventType.Released:
					_keyState.set(event.key, KeyState.Released);
			}
		}
		_eventQueue = [];
	}

	public static function key_held(key:Key):Bool {
		return _keyState.get(key) == KeyState.Held;
	}

	public static function key_pressed(key:Key):Bool {
		return _keyState.get(key) == KeyState.Pressed;
	}

	public static function key_released(key:Key):Bool {
		return _keyState.get(key) == KeyState.Released;
	}

	private static function _onKeyDown(event:KeyboardEvent):Void {
		if (event.repeat)
			return;

		var key:Key = event.code;
		_eventQueue.push({type: KeyEventType.Pressed, key: key});
	}

	private static function _onKeyUp(event:KeyboardEvent):Void {
		var key:Key = event.code;
		_eventQueue.push({type: KeyEventType.Released, key: key});
	}
}
