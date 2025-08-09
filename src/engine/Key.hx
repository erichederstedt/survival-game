package engine;

enum abstract Key(String) from String to String {
	// Letters
	var A = "KeyA";
	var B = "KeyB";
	var C = "KeyC";
	var D = "KeyD";
	var E = "KeyE";
	var F = "KeyF";
	var G = "KeyG";
	var H = "KeyH";
	var I = "KeyI";
	var J = "KeyJ";
	var K = "KeyK";
	var L = "KeyL";
	var M = "KeyM";
	var N = "KeyN";
	var O = "KeyO";
	var P = "KeyP";
	var Q = "KeyQ";
	var R = "KeyR";
	var S = "KeyS";
	var T = "KeyT";
	var U = "KeyU";
	var V = "KeyV";
	var W = "KeyW";
	var X = "KeyX";
	var Y = "KeyY";
	var Z = "KeyZ";

	// Numbers (Top Row)
	var Digit0 = "Digit0";
	var Digit1 = "Digit1";
	var Digit2 = "Digit2";
	var Digit3 = "Digit3";
	var Digit4 = "Digit4";
	var Digit5 = "Digit5";
	var Digit6 = "Digit6";
	var Digit7 = "Digit7";
	var Digit8 = "Digit8";
	var Digit9 = "Digit9";

	// Function Keys
	var F1 = "F1";
	var F2 = "F2";
	var F3 = "F3";
	var F4 = "F4";
	var F5 = "F5";
	var F6 = "F6";
	var F7 = "F7";
	var F8 = "F8";
	var F9 = "F9";
	var F10 = "F10";
	var F11 = "F11";
	var F12 = "F12";

	// Arrow Keys
	var ArrowUp = "ArrowUp";
	var ArrowDown = "ArrowDown";
	var ArrowLeft = "ArrowLeft";
	var ArrowRight = "ArrowRight";

	// Control & Modifier Keys
	var ShiftLeft = "ShiftLeft";
	var ShiftRight = "ShiftRight";
	var ControlLeft = "ControlLeft";
	var ControlRight = "ControlRight";
	var AltLeft = "AltLeft";
	var AltRight = "AltRight";
	var MetaLeft = "MetaLeft"; // Command key on Mac, Windows key on Windows
	var MetaRight = "MetaRight";

	// Whitespace & Editing
	var Space = "Space";
	var Enter = "Enter";
	var Tab = "Tab";
	var Backspace = "Backspace";
	var Delete = "Delete";
	var Insert = "Insert";
	var Escape = "Escape";
	var CapsLock = "CapsLock";

	// Numpad Keys
	var Numpad0 = "Numpad0";
	var Numpad1 = "Numpad1";
	var Numpad2 = "Numpad2";
	var Numpad3 = "Numpad3";
	var Numpad4 = "Numpad4";
	var Numpad5 = "Numpad5";
	var Numpad6 = "Numpad6";
	var Numpad7 = "Numpad7";
	var Numpad8 = "Numpad8";
	var Numpad9 = "Numpad9";
	var NumpadAdd = "NumpadAdd";
	var NumpadSubtract = "NumpadSubtract";
	var NumpadMultiply = "NumpadMultiply";
	var NumpadDivide = "NumpadDivide";
	var NumpadDecimal = "NumpadDecimal";
	var NumpadEnter = "NumpadEnter";
}
