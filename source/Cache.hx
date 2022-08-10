package;

import haxe.ds.StringMap;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import openfl.system.System;
import openfl.utils.Assets;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.display3D.textures.Texture;
import ui.AtlasText;

class Cache
{
	static final dumpExclusions:Array<String> = [
		'assets/preload/music/freakyMenu.${Paths.SOUND_EXT}',
		'assets/shared/music/breakfast.${Paths.SOUND_EXT}'
	];

	static var bitmaps:Array<BitmapAsset> = [];
	static var sounds:StringMap<Sound> = new StringMap<Sound>();

	public static function getGraphic(path:String, storeInGpu:Bool = false)
	{
		for (bitmap in bitmaps)
			if (bitmap.path == path)
				return bitmap.graphic;

		var dumbMap:BitmapAsset = new BitmapAsset(path, storeInGpu);
		bitmaps.push(dumbMap);
		return dumbMap.graphic;
	}

	public static function getSound(path:String)
	{
		if (sounds.exists(path))
			return sounds.get(path);

		var fartSound:Sound = Assets.getSound(path);
		sounds.set(path, fartSound);
		return fartSound;
	}

	inline static public function hasSound(path:String)
	{
		return sounds.exists(path);
	}

	public static function clear()
	{
		AtlasText.fonts.clear();
		clearBitmaps();
		clearSounds();
		System.gc();
	}

	public static function clearBitmaps()
	{
		for (bitmap in bitmaps)
		{
			if (!dumpExclusions.contains(bitmap.path))
			{
				bitmaps.remove(bitmap);
				bitmap.dispose();
			}
		}
	}

	public static function clearSounds()
	{
		for (key in sounds.keys())
		{
			if (!dumpExclusions.contains(key))
			{
				sounds.remove(key);
				Assets.cache.clear(key);
			}
		}
	}
}

class BitmapAsset
{
	public var path:String;
	public var graphic:FlxGraphic;

	var texture:Texture;

	public function new(path:String, storeInGpu:Bool = true)
	{
		this.path = path;

		var data:BitmapData = Assets.getBitmapData(path, !storeInGpu);
		if (storeInGpu)
		{
			texture = FlxG.stage.context3D.createTexture(data.width, data.height, BGRA, false);
			texture.uploadFromBitmapData(data);
			data.dispose();
			data.disposeImage();
			data = null;
		}

		graphic = FlxGraphic.fromBitmapData(storeInGpu ? BitmapData.fromTexture(texture) : data);
		graphic.persist = true;
		graphic.destroyOnNoUse = false;

		// trace('new bitmap: ' + path);
	}

	public function dispose()
	{
		if (texture != null)
			texture.dispose();
		graphic.bitmap.dispose();
		graphic.bitmap.disposeImage();

		if (Assets.cache.hasBitmapData(path))
		{
			Assets.cache.removeBitmapData(path);
			FlxG.bitmap.remove(graphic);
		}

		// trace('disposed bitmap: ' + path);
	}
}
