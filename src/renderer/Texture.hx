package renderer;

import assets.TextureAsset;
import haxe.Http;
import haxe.KTX;
import haxe.Signal;
import haxe.io.Bytes;
import js.html.Console;
import js.lib.Uint8Array;
import utils.FileSystem;

class Texture {
	final path:String;
	final texture:js.html.webgl.Texture;

	public var width(default, null):Int;
	public var height(default, null):Int;

	public final onSucces:Signal<(texture:Texture) -> Void>;
	public final onError:Signal<(texture:Texture, msg:String) -> Void>;

	public var status(default, null):Status;

	function new(path:String, texture:js.html.webgl.Texture) {
		this.path = path;
		this.texture = texture;
		this.onSucces = new Signal();
		this.onError = new Signal();
		this.width = 1;
		this.height = 1;
	}

	public static function fromImage(path:String, generateMips:Bool = true):Texture {
		final _this = new Texture(path, Renderer.gl.createTexture());
		_this.status = Status.Loading;

		Renderer.gl.bindTexture(GL.TEXTURE_2D, _this.texture);
		Renderer.gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, 1, 1, 0, GL.RGBA, GL.UNSIGNED_BYTE, new Uint8Array([0, 0, 255, 255]));

		FileSystem.getImageAsync(path, (image:js.html.Image) -> {
			Renderer.gl.bindTexture(GL.TEXTURE_2D, _this.texture);
			Renderer.gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, image);

			_this.width = image.width;
			_this.height = image.height;

			if (generateMips && _this.isPowerOf2()) {
				Renderer.gl.generateMipmap(GL.TEXTURE_2D);
				Renderer.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_LINEAR);
			} else {
				Renderer.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
				Renderer.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
				Renderer.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
			}

			_this.status = Status.Succesful;
			_this.onSucces(_this);
		}, (msg:String) -> {
			Console.error('Failed to load texture at path: ${_this.path}');
			_this.status = Status.Error;
			_this.onError(_this, 'Failed to load texture at path: ${_this.path}');
		});

		return _this;
	}

	public static function fromKtx(texture:TextureAsset):Texture {
		final path = texture.data[0].file; // TODO(Eric): Make texture data selection be based on support of compression formats.
		final _this = new Texture(path, Renderer.gl.createTexture());
		_this.status = Status.Loading;

		Renderer.gl.bindTexture(GL.TEXTURE_2D, _this.texture);
		Renderer.gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, 1, 1, 0, GL.RGBA, GL.UNSIGNED_BYTE, new Uint8Array([0, 0, 255, 255]));

		FileSystem.getBytesAsync(path, (data:Bytes) -> {
			Renderer.gl.bindTexture(GL.TEXTURE_2D, _this.texture);
			final ktxData:KTXData = KTX.load(data);
			_this.width = ktxData.pixelWidth;
			_this.height = ktxData.pixelHeight;
			for (i in 0...ktxData.mips.length) {
				final mip:KTXMipLevel = ktxData.mips[i];
				if (ktxData.glFormat == 0) {
					// Compressed
					Renderer.gl.getExtension("WEBGL_compressed_texture_s3tc");
					Renderer.gl.compressedTexImage2D(ktxData.glTarget, i, ktxData.glInternalFormat, mip.width, mip.height, 0, mip.data.get_view().getData());
				} else {
					// Uncompressed
					Renderer.gl.texImage2D(ktxData.glTarget, i, ktxData.glInternalFormat, mip.width, mip.height, 0, ktxData.glFormat, ktxData.glType,
						mip.data.get_view().getData());
				}
			}
			var ext = Renderer.gl.getExtension("EXT_texture_filter_anisotropic");
			Renderer.gl.texParameterf(GL.TEXTURE_2D, ext.TEXTURE_MAX_ANISOTROPY_EXT, 4);

			_this.status = Status.Succesful;
			_this.onSucces(_this);
		}, (msg:String) -> {
			_this.status = Status.Error;
			Console.error('Failed to load texture! Path: ${path}\n${msg}');

			_this.onError(_this, msg);
		});

		return _this;
	}

	public function isPowerOf2():Bool {
		return (this.width & (this.width - 1)) == 0 && (this.height & (this.height - 1)) == 0;
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
