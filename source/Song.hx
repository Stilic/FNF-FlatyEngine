package;

import haxe.Json;
import openfl.utils.Assets;

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
}

class Song
{
	public static function loadFromJson(jsonInput:String, folder:String = '')
	{
		if (folder.length > 0)
			folder = folder.toLowerCase() + '/';

		var rawJson:String = Assets.getText(Paths.json(folder + jsonInput.toLowerCase())).trim();

		while (!rawJson.endsWith("}"))
			rawJson = rawJson.substr(0, rawJson.length - 1);

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		return cast Json.parse(rawJson).song;
	}
}
