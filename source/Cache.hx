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
import openfl.media.Sound;
import ui.PreferencesMenu;
import ui.AtlasText;

using StringTools;

class Cache
{
	static final dumpExclusions:Array<String> = ['music/freakyMenu.${Paths.SOUND_EXT}', 'music/breakfast.${Paths.SOUND_EXT}'];

	public static function isExcludedFromDump(suffix:String)
	{
		for (path in dumpExclusions)
		{
			if (path.endsWith(suffix))
				return true;
		}
		return false;
	}

	static var images:Array<CoolImage> = [];
	static var sounds:Map<String, Sound> = new Map<String, Sound>();

	public static function getGraphic(id:String)
	{
		for (bitmap in images)
		{
			if (bitmap.path == id)
				return bitmap.graphic;
		}

		var image:CoolImage = new CoolImage(id, #if sys PreferencesMenu.getPref('gpu-rendering') #else false #end);
		images.push(image);
		return image.graphic;
	}

	#if lime_vorbis
	// we call this "music streaming, without loading the full music in the memory"
	public static function getMusic(id:String)
	{
		if (sounds.exists(id))
			return sounds.get(id);

		var music:Sound = Assets.getMusic(id, false);
		sounds.set(id, music);
		return music;
	}
	#end

	public static function getSound(id:String)
	{
		if (sounds.exists(id))
			return sounds.get(id);

		var sound:Sound = Assets.getSound(id);
		sounds.set(id, sound);
		return sound;
	}

	// it clears EVERYTHING!!!! (even the aggresive flixel cache)
	public static function clear()
	{
		for (image in images)
		{
			if (!isExcludedFromDump(image.path))
			{
				images.remove(image);
				image = FlxDestroyUtil.destroy(image);
			}
		}

		for (key in sounds.keys())
		{
			if (!isExcludedFromDump(key))
			{
				Assets.cache.removeSound(key);
				sounds.remove(key);
			}
		}

		AtlasText.fonts.clear();

		// clearCache function isn't that good, let's do the pussy stuff "manually"
		@:privateAccess
		for (graphic in FlxG.bitmap._cache)
		{
			graphic.bitmap.lock();

			if (graphic.bitmap.__texture != null)
			{
				graphic.bitmap.__texture.dispose();
				graphic.bitmap.__texture = null;
			}
			graphic.bitmap.disposeImage();

			FlxG.bitmap.remove(graphic);
		}

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

	public function new(path:String, gpuCache:Bool = false)
	{
		this.path = path;

		var bitmap = Assets.getBitmapData(path, !gpuCache);
		if (gpuCache)
		{
			bitmap.lock();
			var texture = FlxG.stage.context3D.createRectangleTexture(bitmap.width, bitmap.height, BGRA, true);
			texture.uploadFromBitmapData(bitmap);
			bitmap.disposeImage();
			bitmap = FlxDestroyUtil.dispose(bitmap);
			bitmap = BitmapData.fromTexture(texture);
		}

		graphic = FlxGraphic.fromBitmapData(bitmap, false, null, false);
		graphic.persist = true;
	}

	public function destroy()
	{
		graphic.bitmap.lock();

		@:privateAccess
		if (graphic.bitmap.__texture != null)
		{
			graphic.bitmap.__texture.dispose();
			graphic.bitmap.__texture = null;
		}
		graphic.bitmap.disposeImage();

		graphic = FlxDestroyUtil.destroy(graphic);
	}
}
