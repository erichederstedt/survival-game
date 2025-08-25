package;

import haxe.io.Path;
import sys.FileSystem;
import sys.io.Process;

class Main {
	public static function main() {
		var assetsrc = "./assetsrc";
		final imageFormats = ["png"];
		final imagesToEncode:Array<String> = [];
		findFiles(assetsrc, imagesToEncode, (file:Path) -> imageFormats.contains(file.ext));

		for (image in imagesToEncode) {
			final imagePath = new Path(image);
			try {
				final directory = 'bin/${imagePath.dir}';
				createDir(directory);

				final process = new Process('npx texture-compressor -i ${image} -t s3tc -c DXT1 -q normal -o ${directory}/${imagePath.file}.dxt1.ktx -m -vb');

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

	public static function createDir(dir:String) {
		if (FileSystem.exists(dir) && FileSystem.isDirectory(dir))
			return;

		FileSystem.createDirectory(dir);
	}

	public static function findFiles(path:String, outFiles:Array<String>, ?filter:(file:Path) -> Bool) {
		if (!FileSystem.exists(path)) {
			return;
		}

		if (FileSystem.isDirectory(path)) {
			for (item in FileSystem.readDirectory(path)) {
				var fullPath = Path.join([path, item]);
				findFiles(fullPath, outFiles, filter);
			}
		} else {
			trace("Found: " + path);
			if (filter != null && filter(new Path(path)))
				outFiles.push(path);
			else if (filter == null)
				outFiles.push(path);
		}
	}
}
