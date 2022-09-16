package;

#if cpp
import cpp.NativeGc;
#elseif hl
import hl.Gc;
#elseif java
import java.vm.Gc;
#elseif neko
import neko.vm.Gc;
#end
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxDestroyUtil;
import openfl.utils.Assets;
import openfl.display.BitmapData;
import openfl.display3D.textures.RectangleTexture;
import openfl.media.Sound;
import ui.PreferencesMenu;
import ui.AtlasText;

using StringTools;

class Cache
{
	static var images:Array<CoolImage> = [];
	static var sounds:Map<String, Sound> = new Map<String, Sound>();

	public static function getGraphic(path:String)
	{
		for (bitmap in images)
			if (bitmap.path == path)
				return bitmap.graphic;

		var image:CoolImage = new CoolImage(path, #if sys PreferencesMenu.getPref('gpu-rendering') #else false #end);
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
		NativeGc.compact();
		NativeGc.run(true);
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

	var texture:RectangleTexture;

	public function new(path:String, storeInGPU:Bool = false)
	{
		this.path = path;

		if (storeInGPU)
		{
			var data:BitmapData = Assets.getBitmapData(path);
			texture = FlxG.stage.context3D.createRectangleTexture(data.width, data.height, BGRA, true);
			texture.uploadFromBitmapData(data);
			Assets.cache.clear(path);
			data.disposeImage();
			data = FlxDestroyUtil.dispose(data);
		}

		graphic = FlxGraphic.fromBitmapData(storeInGPU ? BitmapData.fromTexture(texture) : Assets.getBitmapData(path), false, null, false);
		graphic.persist = true;
		graphic.destroyOnNoUse = false;
	}

	public function destroy()
	{
		if (texture != null)
		{
			texture.dispose();
			texture = null;
		}

		graphic.bitmap.disposeImage();
		graphic = FlxDestroyUtil.destroy(graphic);
	}
}
