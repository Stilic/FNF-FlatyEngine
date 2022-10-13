package;

import openfl.utils.Assets;
import openfl.utils.AssetType;
import flixel.FlxG;
import Cache.AtlasType;

class Paths
{
	public static final SOUND_EXT:String = #if web "mp3" #else "ogg" #end;

	static var currentLevel(default, null):String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static public function getPath(file:String, ?type:AssetType, ?library:String)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (Assets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (Assets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:' + getPreloadPath('$library/$file');
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String, persist:Bool = false)
	{
		return returnSound('sounds/$key', library, persist);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String, persist:Bool = false)
	{
		return sound(key + FlxG.random.int(min, max), library, persist);
	}

	inline static public function music(key:String, ?library:String)
	{
		return returnSound('music/$key', library, true);
	}

	inline static public function voicesPath(song:String)
	{
		return getLibraryPathForce('${song.toLowerCase()}/Voices.$SOUND_EXT', 'songs');
	}

	inline static public function instPath(song:String)
	{
		return getLibraryPathForce('${song.toLowerCase()}/Inst.$SOUND_EXT', 'songs');
	}

	inline static public function voices(song:String)
	{
		return returnSound('${song.toLowerCase()}/Voices', 'songs', true);
	}

	inline static public function inst(song:String)
	{
		return returnSound('${song.toLowerCase()}/Inst', 'songs', true);
	}

	inline static public function image(key:String, ?library:String)
	{
		return returnGraphic('images/$key', library);
	}

	inline static public function font(key:String)
	{
		return getPreloadPath('fonts/$key');
	}

	inline static public function fontName(key:String)
	{
		return Assets.getFont(font(key)).fontName;
	}

	inline static public function video(key:String, ?library:String)
	{
		return getPath('videos/$key.mp4', BINARY, library);
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return returnAtlas('images/$key', Sparrow, library);
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return returnAtlas('images/$key', Packer, library);
	}

	public static function returnGraphic(key:String, ?library:String)
	{
		var graphic = Cache.getGraphic(getPath('$key.png', IMAGE, library));
		if (graphic != null)
			return graphic;

		trace('oh no ${key} is returning null NOOOO');
		return null;
	}

	public static function returnAtlas(key:String, type:AtlasType, ?library:String)
	{
		var atlas = Cache.getAtlas(getPath('$key.png', IMAGE, library), type);
		if (atlas != null)
			return atlas;

		trace('oh no ${key} is returning null NOOOO');
		return null;
	}

	public static function returnSound(key:String, ?library:String, stream:Bool = false)
	{
		var path = getPath('$key.$SOUND_EXT', SOUND, library);
		var sound;
		#if lime_vorbis
		if (stream)
			sound = Cache.getMusic(path);
		else
		#end
		sound = Cache.getSound(path);
		if (sound != null)
			return sound;

		trace('oh no ${key} is returning null NOOOO');
		return null;
	}
}
