package renderer;

import haxe.Signal;
import js.html.Console;
import js.lib.Uint8Array;

class Texture {
	final path:String;
	final image:js.html.Image;
	final texture:js.html.webgl.Texture;

	public var status(default, null):Status;
	public var onSucces:Signal<(texture:Texture) -> Void>;
	public var onError:Signal<(texture:Texture, msg:String) -> Void>;

	public function new(path:String, generateMips:Bool = true) {
		this.path = path;
		this.image = new js.html.Image();
		this.texture = Renderer.gl.createTexture();
		this.status = Status.Loading;
		this.onSucces = new Signal();
		this.onError = new Signal();

		Renderer.gl.bindTexture(GL.TEXTURE_2D, this.texture);
		Renderer.gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, 1, 1, 0, GL.RGBA, GL.UNSIGNED_BYTE, new Uint8Array([0, 0, 255, 255]));

		this.image.crossOrigin = "anonymous";
		this.image.addEventListener('load', () -> {
			Renderer.gl.bindTexture(GL.TEXTURE_2D, this.texture);
			Renderer.gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, this.image);

			if (generateMips && isPowerOf2()) {
				Renderer.gl.generateMipmap(GL.TEXTURE_2D);
				Renderer.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_LINEAR);
			} else {
				Renderer.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
				Renderer.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
				Renderer.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
			}

			this.status = Status.Succesful;
			this.onSucces(this);
		});
		this.image.addEventListener('error', () -> {
			Console.error('Failed to load texture at path: ${this.path}');
			this.status = Status.Error;
			this.onError(this, 'Failed to load texture at path: ${this.path}');
		});
		this.image.src = path;
	}

	public function isPowerOf2():Bool {
		return (this.image.width & (this.image.width - 1)) == 0 && (this.image.height & (this.image.height - 1)) == 0;
	}

	public function bind(program:Program, uniformName:String, textureUnit:Int = 0) {
		Renderer.gl.activeTexture(GL.TEXTURE0 + textureUnit);
		Renderer.gl.bindTexture(GL.TEXTURE_2D, this.texture);

		final textureUniformLocation = Renderer.gl.getUniformLocation(program.program, uniformName);
		Renderer.gl.uniform1i(textureUniformLocation, textureUnit);
	}

	public function unbind(textureUnit:Int = 0) {
		Renderer.gl.activeTexture(GL.TEXTURE0 + textureUnit);
		Renderer.gl.bindTexture(GL.TEXTURE_2D, null);
	}
}
