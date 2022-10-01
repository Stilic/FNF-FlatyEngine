package;

import openfl.utils.Assets;
import openfl.display.BitmapData;
import openfl.media.Sound;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxDestroyUtil;
import ui.PreferencesMenu;
import ui.AtlasText;

using StringTools;

class Cache
{
	public static var persistantAssets:Array<String> = ['music/freakyMenu.${Paths.SOUND_EXT}', 'music/breakfast.${Paths.SOUND_EXT}'];

	public static function isPersistant(suffix:String)
	{
		if (persistantAssets != null)
		{
			for (path in persistantAssets)
			{
				if (path.endsWith(suffix))
					return true;
			}
		}
		return false;
	}

	static var images:Array<CoolImage> = [];
	static var sounds:Map<String, Sound> = new Map<String, Sound>();

	public static function getGraphic(id:String)
	{
		for (bitmap in images)
		{
			if (bitmap.graphic.key == id)
				return bitmap.graphic;
		}

		if (Assets.exists(id, IMAGE))
		{
			var image:CoolImage = new CoolImage(id, #if sys PreferencesMenu.getPref('gpu-rendering') #else false #end);
			images.push(image);
			return image.graphic;
		}
		return null;
	}

	#if lime_vorbis
	// we call this "music streaming, without loading the full music in the memory"
	public static function getMusic(id:String)
	{
		if (sounds.exists(id))
			return sounds.get(id);

		if (Assets.exists(id, SOUND))
		{
			var music:Sound = Assets.getMusic(id, false);
			sounds.set(id, music);
			return music;
		}
		return null;
	}
	#end

	public static function getSound(id:String)
	{
		if (sounds.exists(id))
			return sounds.get(id);

		if (Assets.exists(id, SOUND))
		{
			var sound:Sound = Assets.getSound(id);
			sounds.set(id, sound);
			return sound;
		}
		return null;
	}

	public static function hasGraphic(id:String)
	{
		if (id != null)
		{
			for (image in images)
			{
				if (image.graphic.key == id)
					return true;
			}
		}
		return false;
	}

	public static function hasSound(id:String)
	{
		if (id != null)
			return sounds.exists(id);
		return false;
	}

	public static function clear()
	{
		AtlasText.clearCache();

		// clear the flixel cache manually since the clearCache function is dumb
		@:privateAccess
		for (graphic in FlxG.bitmap._cache)
		{
			// it crashes at some point if i put it after the custom cache clear code bruh
			if (!hasGraphic(graphic.key))
				CoolUtil.destroyGraphic(graphic);
		}

		for (image in images)
		{
			if (!isPersistant(image.graphic.key))
			{
				images.remove(image);
				FlxDestroyUtil.destroy(image);
			}
		}
		for (key in sounds.keys())
		{
			if (!isPersistant(key))
			{
				sounds.remove(key);
				Assets.cache.removeSound(key);
			}
		}

		CoolUtil.runGC();
	}

	public static function clearUnusedGraphics()
	{
		for (image in images)
		{
			if (!isPersistant(image.graphic.key) && image.graphic.useCount <= 0)
			{
				images.remove(image);
				FlxDestroyUtil.destroy(image);
			}
		}
	}
}

class CoolImage implements IFlxDestroyable
{
	public var graphic(default, null):FlxGraphic;

	public function new(path:String, gpuCache:Bool = false)
	{
		var bitmap = Assets.getBitmapData(path);
		if (gpuCache)
		{
			bitmap.lock();
			var texture = FlxG.stage.context3D.createRectangleTexture(bitmap.width, bitmap.height, BGRA, true);
			texture.uploadFromBitmapData(bitmap);
			bitmap.disposeImage();
			FlxDestroyUtil.dispose(bitmap);
			bitmap = BitmapData.fromTexture(texture);
			Assets.cache.setBitmapData(path, bitmap);
		}

		graphic = FlxGraphic.fromBitmapData(bitmap, false, path);
		graphic.persist = true;
	}

	public function destroy()
	{
		graphic = CoolUtil.destroyGraphic(graphic);
	}
}
