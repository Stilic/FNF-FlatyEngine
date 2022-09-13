package;

import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.util.FlxSort;
import openfl.utils.Assets;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];

	public static function difficultyString():String
	{
		return difficultyArray[PlayState.storyDifficulty];
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	public static function floorDecimal(value:Float, decimals:Int):Float
	{
		if (decimals < 1)
			return Math.floor(value);

		var tempMult:Float = 1;
		for (i in 0...decimals)
			tempMult *= 10;
		var newValue:Float = Math.floor(value * tempMult);
		return newValue / tempMult;
	}

	public static function sortNotes(Order:Int, Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(Order, Obj1.strumTime, Obj2.strumTime);
	}

	public static function camLerpShit(ratio:Float, negative:Bool = false):Float
	{
		var cock:Float = FlxG.elapsed * (ratio * 60);
		return FlxMath.bound(negative ? 1 - cock : cock, 0, 1);
	}

	public static function coolLerp(a:Float, b:Float, ratio:Float, negativeRatio:Bool = false):Float
	{
		return FlxMath.lerp(a, b, camLerpShit(ratio, negativeRatio));
	}

	public static function openURL(url:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [url]);
		#else
		FlxG.openURL(url);
		#end
	}
}
