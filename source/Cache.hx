package;

#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#elseif java
import java.vm.Gc;
#elseif neko
import neko.vm.Gc;
#end
import haxe.ds.StringMap;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import openfl.utils.Assets;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.display3D.textures.Texture;
import ui.AtlasText;

class Cache
{
	static var images:Array<CoolImage> = [];
	static var sounds:StringMap<Sound> = new StringMap<Sound>();

	public static function getGraphic(path:String)
	{
		for (bitmap in images)
			if (bitmap.path == path)
				return bitmap.graphic;

		var image:CoolImage = new CoolImage(path);
		images.push(image);
		return image.graphic;
	}

	public static function getSound(path:String)
	{
		if (sounds.exists(path))
			return sounds.get(path);

		var sound:Sound = Assets.getSound(path, false);
		sounds.set(path, sound);
		return sound;
	}

	public static function clear()
	{
		for (image in images)
			image.dispose();
		images = [];

		sounds.clear();
		AtlasText.fonts.clear();

		#if cpp
		Gc.compact();
		Gc.run(true);
		#elseif hl
		Gc.major();
		#elseif (java || neko)
		Gc.run(true);
		#end
	}
}

class CoolImage
{
	public var path(default, null):String;
	public var graphic(default, null):FlxGraphic;

	var texture:Texture;

	public function new(path:String)
	{
		this.path = path;

		#if !flash
		var data:BitmapData = Assets.getBitmapData(path, false);
		texture = FlxG.stage.context3D.createTexture(data.width, data.height, BGRA, true);
		texture.uploadFromBitmapData(data);
		data.dispose();
		data.disposeImage();
		#end

		graphic = FlxGraphic.fromBitmapData(#if flash Assets.getBitmapData(path, false) #else BitmapData.fromTexture(texture) #end, false, null, false);
		graphic.persist = true;
	}

	public function dispose()
	{
		#if !flash
		texture.dispose();
		#end
		graphic.destroy();
	}
}
