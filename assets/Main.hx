package;

import haxe.io.Path;
import sys.FileSystem;
import sys.io.Process;

class Main {
	public static function main() {
		var assetsrc = "./assetsrc";
		final imageFormats = [".png"];
		final imagesToEncode:Array<String> = [];
		if (FileSystem.exists(assetsrc) && FileSystem.isDirectory(assetsrc)) {
			var files = FileSystem.readDirectory(assetsrc).filter((fileName:String) -> {
				return fileName.length > 4 && imageFormats.contains(fileName.substr(fileName.length - 4, 4));
			});

			for (fileName in files) {
				var fullPath = Path.join([assetsrc, fileName]);
				trace('Found: $fullPath');
				imagesToEncode.push(fullPath);
			}
		} else {
			trace('Directory does not exist: $assetsrc');
		}

		for (image in imagesToEncode) {
			try {
				final process = new Process('npx gputexenc -i ${image} -t "BC1" --basis.ktx2 true');

				final output = process.stdout.readAll().toString();
				Sys.print(output);

				final exitCode = process.exitCode();
				if (exitCode != 0)
					trace("gputexenc failed!");

				process.close();
			} catch (e:Dynamic) {
				trace('Error executing command: $e');
			}
		}
	}
}
