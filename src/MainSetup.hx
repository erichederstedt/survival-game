package;

import haxe.io.Bytes;
import sys.Http;
import sys.io.File;

class MainSetup {
	public static function main() {
		trace("Hello Setup!");

		final req = new Http("https://esotericsoftware.com/files/spine-haxe/4.2/spine-haxe-latest.zip");
		req.onBytes = (data:Bytes) -> {
			// File.saveContent('spine-haxe.zip', data);
			File.saveBytes('spine-haxe.zip', data);
		};
		req.onError = (msg:String) -> {
			trace('Failed to download spine-haxe! Url: ${req.url}\n${msg}');
		};
		req.request(false);
	}
}
