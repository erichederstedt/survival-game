package utils;

import haxe.Http;
import haxe.io.Bytes;
import js.html.Image;
import js.html.XMLHttpRequest;
import js.lib.ArrayBuffer;

class FileSystem {
	static final refHolder:Array<Dynamic> = [];

	public static function getText(file:String):String {
		final xhr = new XMLHttpRequest();
		xhr.open("GET", file, false);
		xhr.responseType = js.html.XMLHttpRequestResponseType.TEXT;
		xhr.send();

		if (xhr.status == 200) {
			trace("Response: " + xhr.responseText);
			return xhr.responseText;
		} else {
			trace("Error: " + xhr.status);
			return null;
		}
	}

	public static function getBytes(file:String):Bytes {
		final xhr = new XMLHttpRequest();
		xhr.open("GET", file, false);
		xhr.responseType = js.html.XMLHttpRequestResponseType.ARRAYBUFFER;
		xhr.send();

		if (xhr.status == 200) {
			final buffer:ArrayBuffer = cast xhr.response;
			trace('Loaded binary file of length: ${buffer.byteLength}');
			return Bytes.ofData(buffer);
		} else {
			trace('Error: ' + xhr.status);
			return null;
		}
	}

	public static function getTextAsync(file:String, onSuccess:(text:String) -> Void, onError:(msg:String) -> Void):Void {
		final req = new Http(file);
		refHolder.push(req);
		req.onData = (data:String) -> {
			trace('getTextAsync onSuccess');
			onSuccess(data);
			refHolder.remove(req);
		};
		req.onError = (msg:String) -> {
			trace('getTextAsync onError');
			onError(msg);
			refHolder.remove(req);
		};
		req.request(false);
	}

	public static function getBytesAsync(file:String, onSuccess:(bytes:Bytes) -> Void, onError:(msg:String) -> Void):Void {
		final req = new Http(file);
		refHolder.push(req);
		req.onBytes = (bytes:Bytes) -> {
			trace('getBytesAsync onSuccess');
			onSuccess(bytes);
			refHolder.remove(req);
		};
		req.onError = (msg:String) -> {
			trace('getBytesAsync onError');
			onError(msg);
			refHolder.remove(req);
		};
		req.request(false);
	}

	public static function getImageAsync(file:String, onSuccess:(image:Image) -> Void, onError:(msg:String) -> Void) {
		final image = new Image();
		refHolder.push(image);
		image.crossOrigin = "anonymous";
		image.addEventListener('load', () -> {
			onSuccess(image);
			refHolder.remove(image);
		});
		image.addEventListener('error', () -> {
			onError('Failed to load image!');
			refHolder.remove(image);
		});
		image.src = file;
	}
}
