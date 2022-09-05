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
import flixel.util.FlxDestroyUtil;
import openfl.utils.Assets;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.display3D.textures.Texture;
import ui.AtlasText;

using StringTools;

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

		var sound:Sound = Assets.getSound(path);
		sounds.set(path, sound);
		return sound;
	}

	public static function clear()
	{
		FlxDestroyUtil.destroyArray(images);
		for (key in sounds.keys())
		{
			Assets.cache.clear(key);
			sounds.remove(key);
		}

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

class CoolImage implements IFlxDestroyable
{
	public var path(default, null):String;
	public var graphic(default, null):FlxGraphic;

	#if sys
	var texture:Texture;
	#end

	public function new(path:String)
	{
		this.path = path;

		#if sys
		var data:BitmapData = Assets.getBitmapData(path);
		texture = FlxG.stage.context3D.createTexture(data.width, data.height, BGRA, true);
		texture.uploadFromBitmapData(data);
		Assets.cache.clear(path);
		data.dispose();
		data.disposeImage();
		#end

		graphic = FlxGraphic.fromBitmapData(#if sys BitmapData.fromTexture(texture) #else Assets.getBitmapData(path) #end, false, null, false);
		graphic.persist = true;
		graphic.destroyOnNoUse = false;
	}

	public function destroy()
	{
		#if sys
		texture.dispose();
		texture = null;
		#end

		graphic.bitmap.disposeImage();
		graphic = FlxDestroyUtil.destroy(graphic);
	}
}
